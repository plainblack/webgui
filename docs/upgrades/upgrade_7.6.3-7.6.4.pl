#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN {
    $webguiRoot = "../..";
    unshift (@INC, $webguiRoot."/lib");
}

use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;


my $toVersion = '7.6.4';
my $quiet; # this line required


my $session = start(); # this line required

migrateSurvey($session);

finish($session); # this line required



#----------------------------------------------------------------------------
# This method migrates the the old survey system and existing surveys to the new survey system
#
#
sub migrateSurvey{
    my $session = shift;
    print "Migrating surveys to new survey system..." unless $quiet;

    _moveOldSurveyTables($session);
    _addSurveyTables($session);

    print "\n";

    my $surveys = $session->db->buildArrayRefOfHashRefs(
        "SELECT * FROM Survey_old s
        where s.revisionDate = (select max(s1.revisionDate) from Survey_old s1 where s1.assetId = s.assetId)"
    );

    for my $survey(@$surveys){

        #move over survey
        $session->db->write("insert into Survey
            values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            [
                $$survey{groupToTakeSurvey},$$survey{groupToViewReports},'PBtmpl0000000000000064','PBtmpl0000000000000063',$$survey{maxResponsesPerUser},
                $$survey{gradebookTemplateId},$$survey{assetId},'PBtmpl0000000000000061',$$survey{revisionDate},'GRUNFctldUgop-qRLuo_DA','AjhlNO3wZvN5k4i4qioWcg',
                'wAc4azJViVTpo-2NYOXWvg', '1oBRscNIcFOI-pETrCOspA','d8jMMMRddSQ7twP4l1ZSIw','CxMpE_UPauZA3p8jdrOABw','','{}'
            ]
        );

        my $sjson = WebGUI::Asset::Wobject::Survey::SurveyJSON->new();

        #move over sections
        my $sql = "select * from Survey_section_old where Survey_id = '$$survey{Survey_id}' order by sequenceNumber";
        my $sections = $session->db->buildArrayRefOfHashRefs($sql);
        my $sId = 0;
        my %sMap;
        for my $section(@$sections){
            my $random = $$section{questionOrder} eq 'random' ? 1 : 0;
            $sMap{$$section{Survey_sectionId}} = $sId;
            $sjson->update([$sId++],
                {
                    'text','','title',$$section{sectionName},'variable',$$section{Survey_sectionId},
                    'questionsPerPage',$$survey{questionsPerPage},'randomizeQuestions',$random
                }
            );
        }

        #move over questions
        #my %qMap = ('radioList','Multiple Choice','text','Text','HTMLArea','Text','textArea','Text');
        $sql = "select * from Survey_question_old where Survey_id = '$$survey{Survey_id}' order by sequenceNumber";
        my $questions = $session->db->buildArrayRefOfHashRefs($sql);
        my $qId = 0;
        my %qMap;
        my %qS;
        for my $question(@$questions){
            $qMap{$$question{Survey_questionId}} = $qId;
            $qS{$$question{Survey_questionId}} = $$question{Survey_sectionId};
            $sjson->update([$sMap{$$question{Survey_sectionId}},$qId++],
                {
                    'text',$$question{question},'variable',$$question{Survey_questionId},'allowComment',$$question{allowComment},
                    'randomizeAnswers',$$question{randomizeAnswers},'questionType',$qMap{$$question{answerField}}
                }
            );
        }


        #move over answers
        $sql = "select * from Survey_answer_old where Survey_id = '$$survey{Survey_id}' order by sequenceNumber";
        my $answers = $session->db->buildArrayRefOfHashRefs($sql);
        my $aId = 0;
        my %aMap;
        for my $answer(@$answers){
            $aMap{$$survey{Survey_answerId}} = $aId;
            $sjson->update([$sMap{$qS{$$answer{Survey_questionId}}},$qMap{$$answer{Survey_questionId}},$aId++],
                {
                    'text',$$answer{answer},'goto',$$answer{Survey_questionId},'recordedAnswer',$$answer{answer},
                    'isCorrect',$$answer{isCorrect},'NEED TO MAP QUESTION TYPES'
                }
            );
        }
        my $date = $session->db->quickScalar('select max(revisionDate) from Survey where assetId = ?',[$$survey{assetId}]);
        $session->db->write('update Survey set surveyJSON = ? where assetId = ? and revisionDate = ?',[$sjson->freeze,$$survey{assetId},$date]);


        my $rjson = WebGUI::Asset::Wobject::Survey::ResponseJSON->new(undef,undef,$sjson);
        $rjson->createSurveyOrder();
        #move over responses
        $sql = "select * from Survey_response_old where Survey_id = '$$survey{Survey_id}'";
        my $responses = $session->db->buildArrayRefOfHashRefs($sql);
        for my $response(@$responses){
            $session->db->write('insert into Survey_response values(?,?,?,?,?,?,?,?,?,?)',
                [
                    $$survey{assetId},$$response{Survey_responseId},$$response{userId},$$response{userName},$$response{ipAddress},$$response{startDate},$$response{endDate},
                    $$response{isComplete},undef,'{}'
                ]
            );
            #$sql = "select * from Survey_questionResponse_old where Survey_responseId = '$$response{Survey_responseId}'";
            #my $qresponses = $session->db->buildArrayRefOfHashRefs($sql);
            #for my $qresponse(@$qresponses){
            #}
        }
    }

    print "Finished\n" unless $quiet;
}


sub _moveOldSurveyTables{
    my $session = shift;
    eval{
        $session->db->write("alter table Survey rename to Survey_old");
        $session->db->write("alter table Survey_answer rename to Survey_answer_old");
        $session->db->write("alter table Survey_question rename to Survey_question_old");
        $session->db->write("alter table Survey_section rename to Survey_section_old");
        $session->db->write("alter table Survey_response rename to Survey_response_old");
        $session->db->write("alter table Survey_questionResponse rename to Survey_questionResponse_old");
    };
}

sub _addSurveyTables{
    my $session = shift;
    $session->db->write("DROP TABLE IF EXISTS `Survey`");
    $session->db->write("
CREATE TABLE `Survey` (
  `groupToTakeSurvey` char(22) character set utf8 collate utf8_bin NOT NULL default '2',
  `groupToViewReports` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
  `responseTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `overviewTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `maxResponsesPerUser` int(11) NOT NULL default '1',
  `gradebookTemplateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `templateId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `surveyEditTemplateId` char(22) default NULL,
  `answerEditTemplateId` char(22) default NULL,
  `questionEditTemplateId` char(22) default NULL,
  `sectionEditTemplateId` char(22) default NULL,
  `surveyTakeTemplateId` char(22) default NULL,
  `surveyQuestionsId` char(22) default NULL,
  `exitURL` varchar(512) default NULL,
  `surveyJSON` longblob,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
"); 
    $session->db->write("DROP TABLE IF EXISTS `Survey_response`");
    $session->db->write("
CREATE TABLE `Survey_response` (
  `assetId` char(22) character set utf8 collate utf8_bin NOT NULL, 
  `Survey_responseId` char(22) character set utf8 collate utf8_bin NOT NULL,
  `userId` char(22) default NULL,
  `username` char(255) default NULL,
  `ipAddress` char(15) default NULL,
  `startDate` bigint(20) NOT NULL default '0',
  `endDate` bigint(20) NOT NULL default '0',
  `isComplete` int(11) NOT NULL default '0',
  `anonId` varchar(255) default NULL,
  `responseJSON` longblob,
  PRIMARY KEY  (`Survey_responseId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
    ");
    $session->db->write("DROP TABLE IF EXISTS `Survey_tempReport`");
    $session->db->write("
CREATE TABLE `Survey_tempReport` (
  `assetId` char(22) NOT NULL, 
  `Survey_responseId` char(22) NOT NULL,
  `order` smallint(5) unsigned NOT NULL,
  `sectionNumber` smallint(5) unsigned NOT NULL,
  `sectionName` varchar(512) default NULL,
  `questionNumber` smallint(5) unsigned NOT NULL,
  `questionName` varchar(512) default NULL,
  `questionComment` mediumtext,
  `answerNumber` smallint(5) unsigned default NULL,
  `answerValue` mediumtext,
  `answerComment` mediumtext,
  `entryDate` bigint(20) unsigned NOT NULL COMMENT 'UTC Unix Time',
  `isCorrect` tinyint(3) unsigned default NULL,
  `value` int(11) default NULL,
  `fileStoreageId` char(22) default NULL COMMENT 'Not implemented yet',
  PRIMARY KEY  (`assetId`,`Survey_responseId`,`order`),
  KEY `assetId` (`assetId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
    ");
}

# -------------- DO NOT EDIT BELOW THIS LINE --------------------------------

#----------------------------------------------------------------------------
# Add a package to the import node
sub addPackage {
    my $session     = shift;
    my $file        = shift;

    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = WebGUI::Asset->getImportNode($session)->importPackage( $storage );

    # Make the package not a package anymore
    $package->update({ isPackage => 0 });
    
    # Set the default flag for templates added
    my $assetIds
        = $package->getLineage( ['self','descendants'], {
            includeOnlyClasses  => [ 'WebGUI::Asset::Template' ],
        } );
    for my $assetId ( @{ $assetIds } ) {
        my $asset   = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( !$asset ) {
            print "Couldn't instantiate asset with ID '$assetId'. Please check package '$file' for corruption.\n";
            next;
        }
        $asset->update( { isDefault => 1 } );
    }

    return;
}

#-------------------------------------------------
sub start {
    my $configFile;
    $|=1; #disable output buffering
    GetOptions(
        'configFile=s'=>\$configFile,
        'quiet'=>\$quiet
    );
    my $session = WebGUI::Session->open($webguiRoot,$configFile);
    $session->user({userId=>3});
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name=>"Upgrade to ".$toVersion});
    return $session;
}

#-------------------------------------------------
sub finish {
    my $session = shift;
    updateTemplates($session);
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
    $session->close();
}

#-------------------------------------------------
sub updateTemplates {
    my $session = shift;
    return undef unless (-d "packages-".$toVersion);
    print "\tUpdating packages.\n" unless ($quiet);
    opendir(DIR,"packages-".$toVersion);
    my @files = readdir(DIR);
    closedir(DIR);
    my $newFolder = undef;
    foreach my $file (@files) {
        next unless ($file =~ /\.wgpkg$/);
        # Fix the filename to include a path
        $file       = "packages-" . $toVersion . "/" . $file;
        addPackage( $session, $file );
    }
}

#vim:ft=perl
