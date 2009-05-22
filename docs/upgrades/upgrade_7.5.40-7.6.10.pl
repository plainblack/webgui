#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use JSON;
use WebGUI::Asset::File::GalleryFile;
use WebGUI::Asset::Sku::Product;
use WebGUI::Asset::Template;
use WebGUI::Asset::Wobject::Collaboration;
use WebGUI::Asset::Wobject::GalleryAlbum;
use WebGUI::Asset::Wobject::Survey::ResponseJSON;
use WebGUI::Asset::Wobject::Survey::SurveyJSON;
use WebGUI::Asset::Wobject::Survey;
use WebGUI::Asset;
use WebGUI::ProfileField;
use WebGUI::Session;
use WebGUI::Shop::Pay;
use WebGUI::Shop::PayDriver;
use WebGUI::Storage;
use WebGUI::Utility qw(isIn);

my $toVersion = '7.6.10';
my $quiet; # this line required

# in case we need to output UTF-8 chars
binmode STDOUT, ':utf8';

my $session = start(); # this line required

addUrlToAssetHistory ( $session ); ##This sub MUST GO FIRST
removeDoNothingOnDelete( $session );
fixIsPublicOnTemplates ( $session );
addSortOrderToFolder( $session );
addLoginTimeStats( $session );
addCSPostReceivedTemplate ( $session );
redirectChoice ($session);
badgePriceDates ($session);
addIsDefaultTemplates( $session );
addAdHocMailGroups( $session );
makeAdminConsolePluggable( $session );
migrateAssetsToNewConfigFormat($session);
deleteAdminBarTemplates($session);
repairBrokenProductSkus($session);
removeUnusedTemplates($session);
addExportExtensionsToConfigFile($session);
addThingyColumns( $session );
addCommentsAspect( $session );
addCommentsAspectToWiki( $session );
addAssetDiscoveryService( $session );
repairManageWorkflows($session); 
addPreTextToThingyFields($session);
updateAddressBook($session);
changeDefaultPaginationInSearch($session);
upgradeToYui26($session);
addUsersOnlineMacro($session);
addProfileExtrasField($session);
addWorkflowToDataform( $session );
installDataTableAsset( $session );
installAjaxI18N( $session );
installSiteIndex( $session );
createLastUpdatedField($session);
createFieldShowOnline($session);
upgradeSyndicatedContentTemplates($session);
removeCaseInsensitiveConfig($session);
addVersionTagMode($session);
migrateSurvey($session);
addPosMode($session);
fixFriendsGroups( $session );
upgradeAccount( $session );
addExtendedProfilePrivileges( $session );
addStorageUrlMacro( $session );
addRecurringSubscriptionSwitch( $session );
upgradeMatrix( $session );
fixAccountMisspellings(  $session );
removeTemplateHeadBlock( $session );
updateMatrixListingScores( $session );
removeSqlForm( $session );
addMatrixEditListingTemplate( $session );
reFixAccountMisspellings($session);
addRichEditorInboxSetting( $session );
alterSurveyJSONFields($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

#Change the Survey and Survey_response tables' json fields to longText instead of longBlob to get back non-binary text
#----------------------------------------------------------------------------
sub alterSurveyJSONFields{
    my $session = shift;
    $session->db->write("alter table Survey modify surveyJSON longText");
    $session->db->write("alter table Survey_response modify responseJSON longText");
}

#----------------------------------------------------------------------------
# Add ability to select which rich editor for messages between users
sub addRichEditorInboxSetting {
    my $session = shift;
    print "\tAdding rich editor selection to Inbox... " unless $quiet;

    $session->setting->add("inboxRichEditId","PBrichedit000000000001");

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
#Describe what our function does
sub reFixAccountMisspellings {
    my $session = shift;
    my $setting = $session->setting;
    print "\tFix misspellings in Account settings... " unless $quiet;
    # and here's our code
    $setting->add("profileViewTemplateId",   $setting->get('profileViewTempalteId')  );
    $setting->add("profileErrorTemplateId",  $setting->get('profileErrorTempalteId') );
    $setting->add("inboxLayoutTemplateId",   $setting->get('inboxLayoutTempalteId')  );
    $setting->add("friendsLayoutTemplateId", $setting->get('friendsLayoutTempalteId'));
    $setting->remove("profileViewTempalteId");
    $setting->remove("profileErrorTempalteId");
    $setting->remove("inboxLayoutTempalteId");
    $setting->remove("friendsLayoutTempalteId");
    print "DONE!\n" unless $quiet;
}

# Add editListingTemplate property to Matrix
sub addMatrixEditListingTemplate {
    my $session = shift;
    print "\tAdd editListingTemplate property to Matrix... " unless $quiet;
    $session->db->write("alter table Matrix add editListingTemplateId char(22)");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------

sub removeSqlForm {
    my $session = shift;
    print "\tOptionally removing Web Services Client...\n" unless $quiet;
    my $db = $session->db;
    unless ($db->quickScalar("select count(*) from asset where className='WebGUI::Asset::Wobject::WSClient'")) {
        print "\t\tNot using it, so we're uninstalling it.\n" unless $quiet;
        $session->config->delete("assets/WebGUI::Asset::Wobject::WSClient");
        my @ids = $db->buildArray("select distinct assetId from template where namespace = 'WSClient'");
        push @ids, qw(5YAbuwiVFUx-z8hcOAnsdQ);
        foreach my $id (@ids) {
            my $asset = WebGUI::Asset->newByDynamicClass($session, $id);
            if (defined $asset) {
                $asset->purge;
            }
        }
        $db->write("drop table WSClient");
    }
    else {
        print "\t\tThis site uses Web Services Client, so we won't uninstall it.\n" unless $quiet;
    }
}

#----------------------------------------------------------------------------

sub updateMatrixListingScores {
    my $session = shift;
    print "\tUpdating score for every MatrixListing asset... " unless $quiet;
    my $matrixListings   = WebGUI::Asset->getRoot($session)->getLineage(['descendants'],
        {
            statesToInclude     => ['published','trash','clipboard','clipboard-limbo','trash-limbo'],
            statusToInclude     => ['pending','approved','deleted','archived'],
            includeOnlyClasses  => ['WebGUI::Asset::MatrixListing'],
            returnObjects       => 1,
        });

    for my $matrixListing (@{$matrixListings})
    {
        next unless defined $matrixListing;
        my $score = $session->db->quickScalar("select sum(value) from MatrixListing_attribute 
            left join Matrix_attribute using(attributeId) 
            where matrixListingId = ? and fieldType = 'MatrixCompare'",
            [$matrixListing->getId]);
        $matrixListing->update({score => $score});
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------

sub removeTemplateHeadBlock {
    my $session = shift;
    print "\tMerging Template head blocks into the Extra Head Tags field... " unless $quiet;
    my $sth = $session->db->prepare('select assetId, revisionDate, headBlock from template');
    $sth->execute();
    TMPL: while (my $templateData = $sth->hashRef) {
        my $template = WebGUI::Asset->new($session,
            $templateData->{assetId}, 'WebGUI::Asset::Template',
            $templateData->{revisionDate},
        );
        next TMPL unless defined $template;
        if ($template->get('namespace') eq 'style') {
            $template->update({
                extraHeadTags => '',
            });
        }
        else {
            $template->update({
                extraHeadTags => $template->getExtraHeadTags . $templateData->{headBlock},
            });
        }
    }
    $session->db->write('ALTER TABLE template DROP COLUMN headBlock');
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
#Describe what our function does
sub fixAccountMisspellings {
    my $session = shift;
    my $setting = $session->setting;
    print "\tFix misspellings in Account settings... " unless $quiet;
    # and here's our code
    $setting->add("profileViewTemplateId",   $setting->get('profileViewTempalteId')  );
    $setting->add("profileErrorTemplateId",  $setting->get('profileErrorTempalteId') );
    $setting->add("inboxLayoutTemplateId",   $setting->get('inboxLayoutTempalteId')  );
    $setting->add("friendsLayoutTemplateId", $setting->get('friendsLayoutTempalteId'));
    $setting->remove("profileViewTemplateId");
    $setting->remove("profileErrorTemplateId");
    $setting->remove("inboxLayoutTemplateId");
    $setting->remove("friendsLayoutTemplateId");
    print "DONE!\n" unless $quiet;
}

sub upgradeMatrix {
    my $session = shift;
    print "\tUpgrading matrix assets... \n" unless $quiet;
    my $db = $session->db;
    $db->write("alter table Matrix drop column groupToRate, drop column privilegedGroup,
        drop column ratingTimeout, drop column ratingTimeoutPrivileged, drop column ratingDetailTemplateId,
        drop column visitorCacheTimeout");
    $db->write("alter table Matrix add column defaultSort char(22) not null default 'score',
        add column compareColorNo char(22) default '#ffaaaa', 
        add column compareColorLimited char(22) not null default '#ffffaa', 
        add column compareColorCostsExtra char(22) not null default '#ffffaa', 
        add column compareColorFreeAddOn char(22) not null default '#ffffaa', 
        add column compareColorYes char(22) not null default '#aaffaa',
        add column submissionApprovalWorkflowId char(22) not null,
        add column ratingsDuration int(11) not null default 7776000");
    $db->write("create table MatrixListing (
        assetId         char(22) binary not null,
        revisionDate    bigint not null,
        screenshots     char(22),
        description     text,
        version         char(255),
        views           int(11),
        compares        int(11),
        clicks          int(11),
        viewsLastIp     char(255),
        comparesLastIp  char(255),
        clicksLastIp    char(255),
        lastUpdated     int(11),
        maintainer      char(22),
        manufacturerName    char(255),
        manufacturerURL     char(255),
        productURL          char(255),
        score           int(11),
        primary key (assetId, revisionDate)
    )");
    $db->write("create table MatrixListing_attribute (
        matrixId char(22) not null, 
        matrixListingId char(22) not null, 
        attributeId char(22) not null, 
        value char(255),
        primary key (matrixId, matrixListingId, attributeId)
    )");
    $db->write("alter table Matrix_rating rename MatrixListing_rating");
    $db->write("alter table Matrix_ratingSummary rename MatrixListing_ratingSummary");
    $db->write("alter table Matrix_field rename Matrix_attribute");
    $db->write("alter table Matrix_attribute drop column name");
    $db->write("alter table Matrix_attribute change label name char(255)");
    $db->write("alter table Matrix_attribute add column options text");
    $db->write("alter table Matrix_attribute change fieldType fieldType char(255) not null default 'MatrixCompare'");
    $db->write("alter table Matrix_attribute change fieldId attributeId char(22) not null");
    $db->write("update Matrix_attribute set fieldType = 'MatrixCompare' where fieldType = 'GoodBad'");	
    $db->write("update Matrix_attribute set fieldType = 'Combo' where fieldType != 'MatrixCompare'");
    $db->write("update Matrix_listingData set value = 0 where value = 'No'");
    $db->write("update Matrix_listingData set value = 1 where value = 'Limited'");
    $db->write("update Matrix_listingData set value = 2 where value = 'Costs Extra'");
    $db->write("update Matrix_listingData set value = 3 where value = 'Free Add On'");
    $db->write("update Matrix_listingData set value = 4 where value = 'Yes'");

    # get existing Matrix wobjects
    my $matrices   = WebGUI::Asset->getRoot($session)->getLineage(['descendants'],
        {
            statesToInclude     => ['published','trash','clipboard','clipboard-limbo','trash-limbo'],
            statusToInclude     => ['pending','approved','deleted','archived'],
            includeOnlyClasses  => ['WebGUI::Asset::Wobject::Matrix'],
            returnObjects       => 1,
        });

    for my $matrix (@{$matrices})
    {
        next unless defined $matrix;
        # If the asset is in the trash, ignore the migration, we're just going
        # to purge it.
        if ($matrix->get("state") =~ m/trash/) {
            $matrix->purge;
            next;
        }
    
        # get listings for each Matrix
        my @listings = @{ $db->buildArrayRefOfHashRefs("select * from Matrix_listing where assetId =?",[$matrix->getId]) };
        foreach my $listing (@listings){
            # add MatrixListing asset for each listing
            print "Migrating listing: ".$listing->{productName}."\n" unless $quiet;;
            $listing->{className} = 'WebGUI::Asset::MatrixListing';
            $listing->{assetId} = 'new';
            $listing->{title}   = $listing->{productName};
            $listing->{version} = $listing->{versionNumber};
            $listing->{screenshots} = $listing->{storageId};
            $listing->{ownerUserId} = $listing->{maintainerId};
        $listing->{productURL} = $listing->{productUrl};		
        $listing->{manufacturerURL} = $listing->{manufacturerUrl};
            my $newMatrixListing = $matrix->addChild($listing,undef,undef,{skipAutoCommitWorkflows=>1});
            # get listingData for each listing
            my $listingData = $db->buildArrayRefOfHashRefs("select * from Matrix_listingData where listingId =?",[$listing->{listingId}]);
            # add listing attribute for each listing field
            foreach my $attribute (@{$listingData}){
                $db->write("insert into MatrixListing_attribute (matrixId, matrixListingId, attributeId, value) values 
                (?,?,?,?)",[$matrix->getId,$newMatrixListing->getId,$attribute->{fieldId},$attribute->{value}]);
            }
            # update listingIds to MatrixListingIds in MatrixListing_rating/Summary tables
            $db->write("update MatrixListing_rating set listingId = ? where listingId =?",
                [$newMatrixListing->getId,$listing->{listingId}]);
            $db->write("update MatrixListing_ratingSummary set listingId = ? where listingId =?",
                [$newMatrixListing->getId,$listing->{listingId}]);
            # migrate comments
            if($listing->{forumId}){
                my $forum = WebGUI::Asset::Wobject::Collaboration->new($session, $listing->{forumId});
                if ( defined $forum ) {
                my @comments = @{ $forum->getLineage(['descendants'], {
                    includeOnlyClasses  => ["WebGUI::Asset::Post", "WebGUI::Asset::Post::Thread"],
                    returnObjects       => 1,
                    }) };
                foreach my $comment (@comments){
                # add comment
                my $content = $comment->get('content');
        $content =~ s/^<p>//;
        $content =~ s/<\/p>//;
                my $ownerUser = WebGUI::User->new($session,$comment->get('ownerUserId'));
                $newMatrixListing->addComment($content,0,$ownerUser);
                }
            }
            }
        }
    }
    $db->write("drop table Matrix_listing");
    $db->write("drop table Matrix_listingData");
    print "\tDONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addExtendedProfilePrivileges {
    my $session = shift;

    print qq{\tExtending User Profile Privileges..} if !$quiet;
    
    my $userProfDesc = $session->db->buildHashRef('describe userProfileData');
    if(grep { $_ =~ /^wg_privacySettings/ } keys %{$userProfDesc}) {
        $session->db->write("alter table userProfileData drop column wg_privacySettings");
    }
    $session->db->write("alter table userProfileData add wg_privacySettings longtext");

    my $fields = WebGUI::ProfileField->getFields($session);
    
    my $users = $session->db->buildArrayRef("select userId from users");
    foreach my $userId (@{$users}) {
        my $hash = {};
        foreach my $field (@{$fields}) {
            if($field->getId eq "publicEmail") {
                my $u = WebGUI::User->new($session,$userId);
                $hash->{$field->getId} = $u->profileField("publicEmail") ? "all" : "none";
                next;
            }
            $hash->{$field->getId} = $field->isViewable ? "all" : "none";
        }
        my $json = JSON->new->encode($hash);
        $session->db->write("update userProfileData set wg_privacySettings=? where userId=?",[$json,$userId]);
    }

    #Delete the public email field
    my $publicEmail = WebGUI::ProfileField->new($session,"publicEmail");
    if(defined $publicEmail) {
        $publicEmail->delete;
    }

    print qq{Finished\n} if !$quiet;
} 


#----------------------------------------------------------------------------
sub addPosMode {
    my $session = shift;

    print qq{\tAdding Point of Sale mode to the Shop...} if !$quiet;

    my $db      = $session->db();
    my $setting = $session->setting();

    $setting->add("groupIdCashier","3");
    $db->write(q{ALTER TABLE cart drop column couponId});
    $db->write(q{ALTER TABLE cart add column posUserId char(22) binary});
    $db->write(q{ALTER TABLE transaction add column cashierUserId char(22) binary});
    $db->write(q{update transaction set cashierUserId=userId});
    $db->write(q{ALTER TABLE addressBook add column defaultAddressId char(22) binary});

    print qq{Finished\n} if !$quiet;
} 

#----------------------------------------------------------------------------
sub addStorageUrlMacro {
    my $session = shift;
    print qq{\tAdding StorageUrl Macro... } if !$quiet;
    $session->config->addToHash( "macros", "StorageUrl" => "StorageUrl" );
    print qq{Done!\n} if !$quiet;
}

#----------------------------------------------------------------------------
# This method add support for versionTagMode
#
sub addVersionTagMode {
    my $session = shift;

    print qq{\tAdding support for versionTagMode...} if !$quiet;

    my $db      = $session->db();
    my $setting = $session->setting();


    $db->write(q{ALTER TABLE `assetVersionTag` ADD `isSiteWide` BOOL NOT NULL DEFAULT '0'});

    ##Use the API...
    my $newField = WebGUI::ProfileField->create(
        $session,
        'versionTagMode',
        {
            label    => 'WebGUI::International::get("version tag mode","WebGUI");',
            visible  => 1,
            required => 0,
            protected => 1,
            editable  => 1,
            forceImageOnly => 0,
            requiredForPasswordRecovery => 0,
            fieldType => 'selectBox',
            possibleValues => q|
{
    inherited     => WebGUI::International::get("versionTagMode inherited"),
    multiPerUser  => WebGUI::International::get("versionTagMode multiPerUser"),
    singlePerUser => WebGUI::International::get("versionTagMode singlePerUser"),
    siteWide      => WebGUI::International::get("versionTagMode siteWide"),
    autoCommit    => WebGUI::International::get("versionTagMode autoCommit"),
}
|,
            dataDefault => 'inherited',
        }
    );
    $newField->setCategory(4);
    $setting->add('versionTagMode', '');

    # Keep autoRequestCommit if enabled
    my $versionTagMode    = q{multiPerUser};
    if ($setting->get('autoRequestCommit')) {
        $versionTagMode = q{autoCommit};
    }
    $setting->set('versionTagMode', $versionTagMode);

    $setting->remove('autoRequestCommit');

    print qq{Finished\n} if !$quiet;

    return;
} #addVersionTagMode


#----------------------------------------------------------------------------
# This method migrates the the old survey system and existing surveys to the new survey system
#
#
sub migrateSurvey{
    my $session = shift;
    print "\tMigrating surveys to new survey system..." unless $quiet;

    _moveOldSurveyTables($session);
    _addSurveyTables($session);


    my $surveys = $session->db->buildArrayRefOfHashRefs(
        "SELECT * FROM Survey_old s
        where s.revisionDate = (select max(s1.revisionDate) from Survey_old s1 where s1.assetId = s.assetId)"
    );

    for my $survey(@$surveys){

        #move over survey
        $session->db->write("insert into Survey
            values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
            [
                $$survey{groupToTakeSurvey},$$survey{groupToViewReports},$$survey{groupToViewReports},'PBtmpl0000000000000064','PBtmpl0000000000000063',$$survey{maxResponsesPerUser},
                $$survey{gradebookTemplateId},$$survey{assetId},'PBtmpl0000000000000061',$$survey{revisionDate},'GRUNFctldUgop-qRLuo_DA','AjhlNO3wZvN5k4i4qioWcg',
                'wAc4azJViVTpo-2NYOXWvg', '1oBRscNIcFOI-pETrCOspA','d8jMMMRddSQ7twP4l1ZSIw','CxMpE_UPauZA3p8jdrOABw','','{}',0,0,0
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
        $sql = "select * from Survey_question_old where Survey_id = '$$survey{Survey_id}' order by sequenceNumber";
        my $questions = $session->db->buildArrayRefOfHashRefs($sql);
        my $qId = 0;
        my %qMap = ('radioList','Multiple Choice','text','Text','HTMLArea','Text','textArea','Text');
        my %qS;
        my $lastSection = $$questions[0]->{Survey_sectionid};
        for my $question(@$questions){
            if($lastSection ne $$question{Survey_sectionId}){
                $qId = 0;
            }
            $qMap{$$question{Survey_questionId}} = $qId;
            $qS{$$question{Survey_questionId}} = $$question{Survey_sectionId};
            $sjson->update([$sMap{$$question{Survey_sectionId}},$qId++],
                {
                    'text',$$question{question},'variable',$$question{Survey_questionId},'allowComment',$$question{allowComment},
                    'randomizeAnswers',$$question{randomizeAnswers},'questionType',$qMap{$$question{answerFieldType}}
                }
            );
            $lastSection = $$question{Survey_sectionId};
        }

        #move over answers
        $sql = "select * from Survey_answer_old where Survey_id = '$$survey{Survey_id}' order by sequenceNumber";
        my $answers = $session->db->buildArrayRefOfHashRefs($sql);
        my $aId = 0;
        my %aMap;
        my $lastQuestion = $$answers[0]->{Survey_questionId};
        for my $answer(@$answers){
            if($lastQuestion ne $$answer{Survey_questionId}){
                $aId = 0;
            }
            $aMap{$$survey{Survey_answerId}} = $aId;
            $sjson->update([$sMap{$qS{$$answer{Survey_questionId}}},$qMap{$$answer{Survey_questionId}},$aId++],
                {
                    'text',$$answer{answer},'goto',$$answer{Survey_questionId},'recordedAnswer',$$answer{answer},
                    'isCorrect',$$answer{isCorrect},'NEED TO MAP QUESTION TYPES'
                }
            );
            $lastQuestion = $$answer{Survey_questionId};
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
  `groupToEditSurvey` char(22) character set utf8 collate utf8_bin NOT NULL default '3',
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
  `timeLimit` mediumint(8) unsigned NOT NULL,
  `showProgress` tinyint(3) unsigned NOT NULL default '0',
  `showTimeLimit` tinyint(3) unsigned NOT NULL default '0',
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

#----------------------------------------------------------------------------
sub fixFriendsGroups {
    my $session = shift;
    my $users = $session->db->buildArrayRef("select userId from users where friendsGroup is not null && friendsGroup != ''");
    foreach my $userId (@{$users}) {
        #purge the admin group
        WebGUI::User->new($session,$userId)->friends->deleteGroups([3]);
    }
}

#----------------------------------------------------------------------------
sub addRecurringSubscriptionSwitch {
    my $session = shift;

    print "\tAdding a recurring/nonrecurring switch to subscriptions... " unless $quiet;

    $session->db->write('alter table Subscription add column recurringSubscription tinyint(1) not null default 1');

    print "Done!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub upgradeAccount {
    my $session = shift;
    my $config  = $session->config;
    my $setting = $session->setting;

    print "\tUpgrading WebGUI Account System... " unless $quiet;
    #Add account properties to config file
    $session->config->delete("account"); #Delete account if it exists
    $session->config->set("account",[
        {
            identifier    => "profile",
            title         => "^International(title,Account_Profile);",
            className     => "WebGUI::Account::Profile"
        },
        {
            identifier    => "inbox",
            title         => "^International(title,Account_Inbox);",
            className     => "WebGUI::Account::Inbox"
        },
        {
            identifier    => "friends",
            title         => "^International(title,Account_Friends);",
            className     => "WebGUI::Account::Friends"
        },
        {
            identifier    => "contributions",
            title         => "^International(title,Account_Contributions);",
            className     => "WebGUI::Account::Contributions"
        },
        {
            identifier    => "shop",
            title         => "^International(title,Account_Shop);",
            className     => "WebGUI::Account::Shop"
        },
        {
            identifier    => "user",
            title         => "^International(title,Account_User);",
            className     => "WebGUI::Account::User"
        },
    ]);
    $session->config->set("profileModuleIdentifier","profile");
    #Add the content handler to the config file if it's not there
    my $oldHandlers = $session->config->get( "contentHandlers" );
    unless (isIn("WebGUI::Content::Account",@{$oldHandlers})) {
        my @newHandlers;
        for my $handler ( @{ $oldHandlers } ) {
            if ( $handler eq "WebGUI::Content::Operation" ) {
                push @newHandlers, "WebGUI::Content::Account";
            }
            push @newHandlers, $handler;
        }
        $session->config->set( "contentHandlers", \@newHandlers );
    }

    #Add new macros to the config file
    $session->config->addToHash("macros","BackToSite","BackToSite");
    $session->config->addToHash("macros","If","If");
    $session->config->addToHash("macros","DeactivateAccount","DeactivateAccount");

    
    #Add the settings for the profile module
    $setting->add("profileStyleTemplateId",""); #Use the userStyle by default
    $setting->add("profileLayoutTemplateId","FJbUTvZ2nUTn65LpW6gjsA");
    $setting->add("profileEditTemplateId","75CmQgpcCSkdsL-oawdn3Q");
    $setting->add("profileViewTempalteId","2CS-BErrjMmESOtGT90qOg");
    $setting->add("profileErrorTempalteId","MBmWlA_YEA2I6D29OMGtRg");

    #Add the settings for the inbox module
    $setting->add("inboxStyleTemplateId",""); #Use the userStyle by default
    $setting->add("inboxLayoutTempalteId","gfZOwaTWYjbSoVaQtHBBEw");
    $setting->add("inboxViewTemplateId","c8xrwVuu5QE0XtF9DiVzLw");
    $setting->add("inboxViewMessageTemplateId","0n4HtbXaWa_XJHkFjetnLQ");
    $setting->add("inboxSendMessageTemplateId","6uQEULvXFgCYlRWnYzZsuA");
    $setting->add("inboxErrorTemplateId","ErEzulFiEKDkaCDVmxUavw");
    $setting->add("inboxMessageConfirmationTemplateId","DUoxlTBXhVS-Zl3CFDpt9g");
    #Invitations
    $setting->add("inboxManageInvitationsTemplateId","1Q4Je3hKCJzeo0ZBB5YB8g");
    $setting->add("inboxViewInvitationTemplateId","VBkY05f-E3WJS50WpdKd1Q");
    $setting->add("inboxInvitationConfirmTemplateId","5A8Hd9zXvByTDy4x-H28qw");
    #Inbox Invitations
    $setting->add("inboxInviteUserEnabled",$session->setting->get("userInvitationsEnabled"));
    $setting->add("inboxInviteUserRestrictSubject","0");
    $setting->add("inboxInviteUserSubject","^International(invite subject,Account_Inbox,^u;);");
    $setting->add("inboxInviteUserRestrictMessage","0");
    $setting->add("inboxInviteUserMessage","^International(invite message,Account_Inbox);");    
    $setting->add("inboxInviteUserMessageTemplateId","XgcsoDrbC0duVla7N7JAdw");
    $setting->add("inboxInviteUserTemplateId","cR0UFm7I1qUI2Wbpj--08Q");
    $setting->add("inboxInviteUserConfirmTemplateId","SVIhz68689hwUGgcDM-gWw");
    
    #Add the settings for the friends module
    $setting->add("friendsStyleTemplateId",""); #Use the userStyle by default
    $setting->add("friendsLayoutTempalteId","zrNpGbT3odfIkg6nFSUy8Q");
    $setting->add("friendsViewTemplateId","1Yn_zE_dSiNuaBGNLPbxtw");
    $setting->add("friendsEditTemplateId","AZFU33p0jpPJ-E6qLSWZng");
    $setting->add("friendsSendRequestTemplateId","AGJBGviWGAwjnwziiPjvDg");
    $setting->add("friendsErrorTemplateId","7Ijdd8SW32lVgg2H8R-Aqw");
    $setting->add("friendsConfirmTemplateId","K8F0j_cq_jgo8dvWY_26Ag");
    $setting->add("friendsRemoveConfirmTemplateId","G5V6neXIDiFXN05oL-U3AQ");

    #Add the settings for the user module
    $setting->add("userAccountStyleTemplateId",""); #Use the userStyle by default
    $setting->add("userAccountLayoutTemplateId","9ThW278DWLV0-Svf68ljFQ");

    #Add the settings for the shop module
    $setting->add("shopStyleTemplateId",""); #Use the userStyle by default
    $setting->add("shopLayoutTemplateId","aUDsJ-vB9RgP-AYvPOy8FQ");

    #Add the settings for the contributions module
    $setting->add("contribStyleTemplateId",""); #Use the userStyle by default
    $setting->add("contribLayoutTemplateId","b4n3VyUIsAHyIvT-W-jziA");
    $setting->add("contribViewTemplateId","1IzRpX0tgW7iuCfaU2Kk0A");


    #Add inbox changes
    $session->db->write(q{
        create table inbox_messageState (
            messageId char(22) binary not null,
            userId char(22) binary not null,
            isRead tinyint(4) not null default 0,
            repliedTo tinyint(4) not null default 0,
            deleted tinyint(4) not null default 0,
            primary key (messageId, userId)
        )
    });

    #Update the inbox
    my $sth = $session->db->read("select messageId, groupId, userId, status from inbox");
    while(my ($messageId,$groupId,$userId,$status) = $sth->array) {
        my $repliedTo = $status eq "replied";
        my $isRead    = ($status ne "unread" && $status ne "pending")?1:0;
        my $deleted   = 0;

        if($status eq "deleted") {
            #Purge deleted messages
            $session->db->write("delete from inbox where messageId=?",[$messageId]);
            next;
        }

        if($groupId) {
            my $g     = WebGUI::Group->new($session,$groupId);
            my $users = $g->getAllUsers;
            foreach my $userId (@{$users}) {
                $session->db->write(
                    q{ REPLACE INTO inbox_messageState (messageId,userId,isRead,repliedTo,deleted) VALUES (?,?,?,?,?) },
                    [$messageId,$userId,$isRead,$repliedTo,$deleted]
                );
            }
        }

        if($userId) {
            $session->db->write(
                q{ REPLACE INTO inbox_messageState (messageId,userId,isRead,repliedTo,deleted) VALUES (?,?,?,?,?) },
                [$messageId,$userId,$isRead,$repliedTo,$deleted]
            );
        }

        if($status ne "completed" && $status ne "pending") {
            $session->db->write(
                q{ UPDATE inbox SET status='active' WHERE messageId=? },
                [$messageId]
            );
        }
    }

    #Add the profile field changes
    $session->db->write(q{alter table userProfileCategory add column shortLabel char(255) default NULL after label});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("misc info short","WebGUI");' where profileCategoryId='1'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("contact info short","WebGUI");' where profileCategoryId='2'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("personal info short","WebGUI");' where profileCategoryId='3'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("preferences short","WebGUI");' where profileCategoryId='4'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("home info short","WebGUI");' where profileCategoryId='5'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("work info short","WebGUI");' where profileCategoryId='6'});
    $session->db->write(q{update userProfileCategory set shortLabel='WebGUI::International::get("demographic info short","WebGUI");' where profileCategoryId='7'});

    $session->db->write(q{alter table userProfileData modify publicProfile char(10) default 'none'});
    $session->db->write(q{update userProfileData set publicProfile='none' where publicProfile='0' || publicProfile is NULL || publicProfile=''});
    $session->db->write(q{update userProfileData set publicProfile='all' where publicProfile='1'});
    $session->db->write(q{REPLACE INTO `userProfileField` VALUES ('publicProfile','WebGUI::International::get(861)',1,0,'RadioList','{ all=>WebGUI::International::get(\'public label\',\'Account_Profile\'), friends=>WebGUI::International::get(\'friends only label\',\'Account_Profile\'), none=>WebGUI::International::get(\'private label\',\'Account_Profile\')}','[\"none\"]',8,'4',1,1,0,0,0,'')});
    
    #Clean up old templates and settings
    my $oldsettings = {
        editUserProfileTemplate        => 'Operation/Profile/Edit',
        viewUserProfileTemplate        => 'Operation/Profile/View',
        manageFriendsTemplateId        => 'friends/manage',
        sendPrivateMessageTemplateId   => 'Inbox/SendPrivateMessage',
        viewInboxTemplateId            => 'Inbox',
        viewInboxMessageTemplateId     => 'Inbox/Message',
        userInvitationsEmailTemplateId => 'userInvite/Email',
        userInvitationsEnabled         => 'userInvite',
        userInvitationsEmailExists     => '',
    };

    foreach my $setting (keys %{$oldsettings}) {
        #Remove the setting
        $session->setting->remove($setting);
        #$session->db->write("delete from settings where name=?",[$setting]);
        #Remove all the templates with the related namespace
        next if ($oldsettings->{$setting} eq "");
        my $assets = $session->db->buildArrayRef("select distinct assetId from template where namespace=?",[$oldsettings->{$setting}]);
        #Purge the template
        foreach my $assetId (@{$assets}) {
            WebGUI::Asset->newByDynamicClass($session,$assetId)->purge;
        }
    }
    
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# removes the caseInsensitiveOS flag from the config file, as it isn't used anymore
sub removeCaseInsensitiveConfig {
    my $session = shift;
    print "\tRemoving caseInsensitiveOS flag from config..." unless $quiet;
    $session->config->delete('caseInsensitiveOS');
    $session->db->write('DROP TABLE storageTranslation');
    print " Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub createLastUpdatedField {
    my $session = shift;
    print "\tAdding last updated field to all assets... " unless $quiet;
    my $db = $session->db;
    $db->write("alter table assetData add column lastModified bigint");
    $db->write("update assetData set lastModified=revisionDate");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub upgradeSyndicatedContentTemplates {
    my $session = shift;
    print "\tUpgrading syndicated content assets... " unless $quiet;
    my $db = $session->db;
    my $templates = $db->read("select distinct assetId from template where namespace='SyndicatedContent'");
    while (my ($id) = $templates->array) {
        my $asset = WebGUI::Asset::Template->new($session, $id);
        if (defined $asset) {
            if ($asset->getId eq "DPUROtmpl0000000000001") { # this one no longer applies
                $asset->trash;
                next;
            }
            my $template = $asset->get('template');
            $template =~ s{channel.title}{channel_title}xmsi;
            $template =~ s{channel.description}{channel_description}xmsi;
            $template =~ s{channel.link}{channel_link}xmsi;
            $template =~ s{site_link}{channel_link}xmsi;
            $template =~ s{site_title}{channel_title}xmsi;
            $template =~ s{descriptionFull}{description}xmsi;
            $template =~ s{rss.url.0.9}{rss_url}xmsi;
            $template =~ s{rss.url}{rss_url}xmsi;
            $template =~ s{rss.url.0.91}{rss_url}xmsi;
            $template =~ s{rss.url.1.0}{rdf_url}xmsi;
            $template =~ s{rss.url.2.0}{rss_url}xmsi;
            $asset->addRevision({template=>$template});
        }
    }
    $db->write("update SyndicatedContent set templateId='PBtmpl0000000000000065' where templateId='DPUROtmpl0000000000001'");
    $db->write("alter table SyndicatedContent drop column displayMode");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub createFieldShowOnline {
    my $session = shift;
    print "\tCreating an additional profile field 'showOnline' for the UsersOnline macro... " unless $quiet;

    # Define field properties
    my $properties = {
        label => q!WebGUI::International::get('Show when online?','WebGUI')!,
        visible => 1,
        required => 0,
        protected => 1,                 # The UsersOnline macro requires this field for working properly.
        editable => 1,
        fieldType => 'YesNo',
        dataDefault => 0                # Users are not shown by default.
    };
    # Create field in category "preferences"
    my $field = WebGUI::ProfileField->create($session, 'showOnline', $properties, 4);

    # Check for failure
    if ($field == undef) {
        print "Creation of the field 'showOnline' failed, possibly because it does already exist. Note that this may cause the UsersOnline macro not to work properly.\n";
    }
    else {
        print "DONE!\n" unless $quiet;
    }
    
    return;
}

#----------------------------------------------------------------------------
# installDataTableAsset
# Install the asset by creating the DB table and adding it to the config file
sub installDataTableAsset {
    my $session     = shift;
    print "\tInstalling the DataTable asset... " unless $quiet;

    $session->db->write( <<'ENDSQL' );
        CREATE TABLE DataTable ( 
            assetId VARCHAR(22) BINARY NOT NULL, 
            revisionDate BIGINT NOT NULL, 
            data LONGTEXT, 
            templateId VARCHAR(22) BINARY,
            PRIMARY KEY ( assetId, revisionDate ) 
        )
ENDSQL

    my $assets  = $session->config->get( "assets" );
    $assets->{ "WebGUI::Asset::Wobject::DataTable" } = { category => "basic" };
    $session->config->set( "assets", $assets );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# installDataTableAsset
# Install the content handler by adding it to the config file
sub installAjaxI18N {
    my $session     = shift;
    print "\tInstalling the AjaxI18N content handler... " unless $quiet;

    my @newHandlers;
    my $oldHandlers = $session->config->get( "contentHandlers" );
    for my $handler ( @{ $oldHandlers } ) {
        if ( $handler eq "WebGUI::Content::Operation" ) {
            push @newHandlers, "WebGUI::Content::AjaxI18N";
        }
        elsif ( $handler eq "WebGUI::Content::AjaxI18N" ) {
            next;
        }
        push @newHandlers, $handler;
    }
    $session->config->set( "contentHandlers", \@newHandlers );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# installSiteIndex
# Install the content handler by adding it to the config file
sub installSiteIndex {
    my $session     = shift;
    print "\tInstalling the SiteIndex content handler... " unless $quiet;

    my $oldHandlers = $session->config->get( "contentHandlers" );
    my @newHandlers;
    for my $handler ( @{ $oldHandlers } ) {
        if ( $handler eq "WebGUI::Content::Asset" ) {
            push @newHandlers, "WebGUI::Content::SiteIndex";
        }
        push @newHandlers, $handler;
    }
    $session->config->set( "contentHandlers", \@newHandlers );

    print "DONE!\n" unless $quiet;
}


#----------------------------------------------------------------------------
sub upgradeToYui26 {
    my $session = shift;
    print "\tUpgrading to YUI 2.6... " unless $quiet;
    $session->db->write("update template set template=replace(template, 'resize-beta.js', 'resize-min.js'), headBlock=replace(headBlock, 'resize-beta.js', 'resize-min.js')");
    $session->db->write("update template set template=replace(template, 'resize-beta-min.js', 'resize-min.js'), headBlock=replace(headBlock, 'resize-beta-min.js', 'resize-min.js')");
    $session->db->write("update template set template=replace(template, 'datasource-beta.js', 'datasource-min.js'), headBlock=replace(headBlock, 'datasource-beta.js', 'datasource-min.js')");
    $session->db->write("update template set template=replace(template, 'datasource-beta-min.js', 'datasource-min.js'), headBlock=replace(headBlock, 'datasource-beta-min.js', 'datasource-min.js')");
    $session->db->write("update template set template=replace(template, 'datatable-beta.js', 'datatable-min.js'), headBlock=replace(headBlock, 'datatable-beta.js', 'datatable-min.js')");
    $session->db->write("update template set template=replace(template, 'datatable-beta-min.js', 'datatable-min.js'), headBlock=replace(headBlock, 'datatable-beta-min.js', 'datatable-min.js')");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub changeDefaultPaginationInSearch {
    my $session = shift;
    print "\tAllow content managers to change the default pagination in the search asset... " unless $quiet;
    $session->db->write("ALTER TABLE `search` ADD COLUMN `paginateAfter` INTEGER  NOT NULL DEFAULT 25");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addUsersOnlineMacro {
    my $session = shift;
    print "\tMaking the UsersOnline macro available... " unless $quiet;
    $session->config->addToHash("macros","UsersOnline","UsersOnline");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub updateAddressBook {
    my $session = shift;
    print "\tAdding organization and email to address book... " unless $quiet;
    my $db = $session->db;
    $db->write("alter table address add column organization char(255)");
    $db->write("alter table address add column email char(255)");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub repairManageWorkflows {
    my $session = shift;
    print "\tCorrecting the Manage Workflow link in configuration file... " unless $quiet;
    # and here's our code
    my $ac = $session->config->get('adminConsole');
    if (exists $ac->{'workflow'}) {
        $ac->{'workflow'}->{'url'} = "^PageUrl(\"\",op=manageWorkflows);";
        $session->config->set('adminConsole', $ac);
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addPreTextToThingyFields {
    my $session = shift;
    print "\tAdding a pre-text property to Thingy fields... " unless $quiet;
    $session->db->write('ALTER TABLE `Thingy_fields` ADD pretext varchar(255)');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addProfileExtrasField {
    my $session = shift;
    print "\tAdding the Extras field for profile fields... " unless $quiet;
    my $db = $session->db;
    $db->write('alter table userProfileField add extras text default NULL');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the workflow property to DataForm
sub addWorkflowToDataform {
    my $session     = shift;
    print "\tAdding Workflow to DataForm... " unless $quiet;

    my $sth = $session->db->read('DESCRIBE `DataForm`');
    while (my ($col) = $sth->array) {
        if ( $col eq 'workflowIdAddEntry' ) {
            print "Already done, skipping.\n" unless $quiet;
            return;
        }
    }
     
    $session->db->write( "ALTER TABLE DataForm ADD COLUMN workflowIdAddEntry CHAR(22) BINARY" );
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addAssetDiscoveryService {
    my $session = shift;
    print "\tAdding asset discovery service..." unless $quiet;
    my @handlers;
    foreach my $handler (@{$session->config->get("contentHandlers")}) {
        if ($handler eq "WebGUI::Content::Operation") {
            push @handlers, 'WebGUI::Content::AssetDiscovery';
        }
        push @handlers, $handler;
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addCommentsAspectToWiki {
    my $session = shift;
    print "\tAdding comments aspect to wiki..." unless $quiet;
    my $db = $session->db;
    my $pages = $db->read("select assetId,revisionDate from WikiPage");
    while (my ($id, $rev) = $pages->array) {
        $db->write("insert into assetAspectComments (assetId, revisionDate, comments, averageCommentRating) values (?,?,'[]',0)",[$id,$rev]);
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addCommentsAspect {
    my $session = shift;
    print "\tAdding comments asset aspect..." unless $quiet;
    $session->db->write("create table assetAspectComments (
        assetId char(22) binary not null,
        revisionDate bigint not null,
        comments mediumtext,
        averageCommentRating int,
        primary key (assetId, revisionDate)
        )");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# make sure each config file has the extensions to export as-is. however, if
# this system received a backport, leave the field as is.
sub addExportExtensionsToConfigFile {
    my $session = shift;
    print "\tAdding binary export extensions to config file... " unless $quiet;
    # skip if the field has been defined already by backporting
    unless ( defined $session->config->get('exportBinaryExtensions') ) {
        # otherwise, set the field
        $session->config->set('exportBinaryExtensions',
            [ qw/.html .htm .txt .pdf .jpg .css .gif .png .doc .xls .xml .rss .bmp
            .mp3 .js .fla .flv .swf .pl .php .php3 .php4 .php5 .ppt .docx .zip .tar
            .rar .gz .bz2/ ] );
    }

    print "Done.\n" unless $quiet;
}

sub addThingyColumns {
    my $session     = shift;
    print "\tAdding exportMetaData and maxEntriesPerUser columns to Thingy_things table... " unless $quiet;
    $session->db->write('ALTER TABLE `Thingy_things` ADD exportMetaData int(11)');
    $session->db->write('ALTER TABLE `Thingy_things` ADD maxEntriesPerUser int(11)');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeUnusedTemplates {
    my $session     = shift;
    print "\tDeleting old unused templates... " unless $quiet;
    foreach my $id (qw(PBtmpl0000000000000046 e-WvgcKROPCoHwiiHLktCg PBtmpl0000000000000034 AFdXZZmGnSKalNSobQMB5w)) {
        my $asset = WebGUI::Asset->new($session, $id);
        if (defined $asset && $asset->getChildCount == 0) {
            $asset->purge;
        }
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub deleteAdminBarTemplates {
    my $session     = shift;
    print "\tDeleting AdminBar templates... " unless $quiet;
    foreach my $id (qw(PBtmpl0000000000000090 Ov2ssJHwp_1eEWKlDyUKmg)) {
        my $asset = WebGUI::Asset->newByDynamicClass($session, $id);
        if (defined $asset) {
            $asset->trash;
        }
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub repairBrokenProductSkus {
    my $session     = shift;
    print "\tRepairing broken Products that were imported... " unless $quiet;
    my $getAProduct = WebGUI::Asset::Sku::Product->getIsa($session);
    while (my $product = $getAProduct->()) {
        COLLATERAL: foreach my $collateral (@{ $product->getAllCollateral('variantsJSON') }) {
            next COLLATERAL unless exists $collateral->{sku};
            $collateral->{varSku} = $collateral->{sku};
            delete $collateral->{sku};
            $product->setCollateral('variantsJSON', 'variantId', $collateral->{variantId}, $collateral);
        }
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub migrateAssetsToNewConfigFormat {
    my $session     = shift;
    print "\tRestructuring asset configuration... " unless $quiet;
    my $config = $session->config;
    
    # devs doing multiple upgrades
    # the list has already been updated by a previous run
    my $assetList = $config->get("assets");
    unless (ref $assetList eq "ARRAY") {
        warn "ERROR: Looks like you've already run this upgrade.\n";
        return undef;
    }
    
    # add categories
    $config->set('assetCategories', {
        basic => {
            title   => "^International(basic,Macro_AdminBar);",
            uiLevel => 1,
        },
        intranet => {
            title   => "^International(intranet,Macro_AdminBar);",
            uiLevel => 5,
        },
        shop => {
            title   => "^International(shop,Shop);",
            uiLevel => 5,
        },
        utilities => {
            title   => "^International(utilities,Macro_AdminBar);",
            uiLevel => 9,
        },
        community => {
            title   => "^International(community,Macro_AdminBar);",
            uiLevel => 5,
        },
    });

    # deal with the old asset list
    my $assetContainers = $config->get("assetContainers");
    $assetContainers = [] unless (ref $assetContainers eq "ARRAY");
    my $utilityAssets = $config->get("utilityAssets");
    $utilityAssets = [] unless (ref $utilityAssets eq "ARRAY");
    my @oldAssetList = (@$assetList, @$utilityAssets, @$assetContainers);
    my %assets = (
        'WebGUI::Asset::Wobject::Collaboration::Newsletter' => {
            category    => "community",    
            }
        );
    foreach my $class (@oldAssetList) {
        my %properties;
        if (isIn($class, qw(
            WebGUI::Asset::Wobject::Article
            WebGUI::Asset::Wobject::Layout
            WebGUI::Asset::Wobject::Folder
            WebGUI::Asset::Wobject::Calendar
            WebGUI::Asset::Wobject::Poll
            WebGUI::Asset::Wobject::Search
            WebGUI::Asset::FilePile
            WebGUI::Asset::Snippet
            WebGUI::Asset::Wobject::DataForm
            ))) {
            $properties{category} = 'basic';
        }
        elsif (isIn($class, qw(
            WebGUI::Asset::Wobject::Collaboration::Newsletter
            WebGUI::Asset::Wobject::WikiMaster
            WebGUI::Asset::Wobject::Collaboration
            WebGUI::Asset::Wobject::Survey
            WebGUI::Asset::Wobject::Gallery
            WebGUI::Asset::Wobject::MessageBoard
            WebGUI::Asset::Wobject::Matrix
            ))) {
            $properties{category} = 'community';
        }
        elsif (isIn($class, qw(
            WebGUI::Asset::Wobject::StockData
            WebGUI::Asset::Wobject::Dashboard
            WebGUI::Asset::Wobject::InOutBoard
            WebGUI::Asset::Wobject::MultiSearch
            WebGUI::Asset::Wobject::ProjectManager
            WebGUI::Asset::Wobject::TimeTracking
            WebGUI::Asset::Wobject::UserList
            WebGUI::Asset::Wobject::WeatherData
            WebGUI::Asset::Wobject::Thingy
            ))) {
            $properties{category} = 'intranet';
        }
        elsif (isIn($class, qw(
            WebGUI::Asset::Wobject::Bazaar
            WebGUI::Asset::Wobject::EventManagementSystem
            WebGUI::Asset::Wobject::Shelf
            WebGUI::Asset::Sku::Product
            WebGUI::Asset::Sku::FlatDiscount
            WebGUI::Asset::Sku::Donation
            WebGUI::Asset::Sku::Subscription
            ))) {
            $properties{category} = 'shop';
        }
        elsif (isIn($class, qw(
            WebGUI::Asset::Wobject::WSClient
            WebGUI::Asset::Wobject::SQLReport
            WebGUI::Asset::Wobject::SyndicatedContent
            WebGUI::Asset::Redirect
            WebGUI::Asset::Template
            WebGUI::Asset::Wobject::Navigation
            WebGUI::Asset::File
            WebGUI::Asset::Wobject::HttpProxy
            WebGUI::Asset::File::Image
            WebGUI::Asset::File::ZipArchive
            WebGUI::Asset::RichEdit
            ))) {
            $properties{category} = 'utilities';
        }
        else {
            # other assets listed but not in the core
            $properties{category} = 'utilities';
        }       
        $assets{$class} = \%properties;
    }
    
    # deal with containers
    foreach my $class (@$assetContainers) {
        $assets{$class}{isContainer} = 1;
    }
    
    # deal with custom add privileges
    my $addGroups = $config->get("assetAddPrivilege");
    if (ref $addGroups eq "HASH") {
        foreach my $class (keys %{$addGroups}) {
            $assets{$class}{addGroup} = $addGroups->{$class};
        }
    }
    
    # deal with custom ui levels
    my $uiLevels = $config->get("assetUiLevel");
    if (ref $uiLevels eq "HASH") {
        foreach my $class (keys %{$addGroups}) {
            $assets{$class}{uiLevel} = $uiLevels->{$class};
        }
    }

    # deal with custom field ui levels
    foreach my $class (keys %assets) {
        my $directive =~ s/::/_/g;
        $directive .= '_uiLevel';
        my $value = $config->get($directive);
        if (ref $value eq "HASH") {
            foreach my $field (keys %{$value}) {
                $assets{$class}{fields}{$field}{uiLevel} = $value->{$field};
            }
            $config->delete($directive);
        }
    }
    
    # write the file
    $config->delete('assetContainers');
    $config->delete('utilityAssets');
    $config->delete("assetUiLevel");
    $config->delete("assetAddPrivilege");
    $config->set("assets",\%assets);
        
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub makeAdminConsolePluggable {
    my $session     = shift;
    print "\tMaking admin console pluggable... " unless $quiet;
    $session->config->set("adminConsole",{
        "spectre" => {
            title => "^International(spectre,Spectre);",
            icon    => "spectre.gif",
            url     => "^PageUrl(\"\",op=spectreStatus);",
            uiLevel => 9,
            groupSetting   => "groupIdAdminSpectre"
        },
        "assets" => {
            title   => "^International(assets,Asset);",
            icon    => "assets.gif",
            url      => "^PageUrl(\"\",op=assetManager);",
            uiLevel => 5,
            group   => "12"
        },
        "versions" => {
            title => "^International(version tags,VersionTag);",
            icon    => "versionTags.gif",
            url      => "^PageUrl(\"\",op=manageVersions);",
            uiLevel => 7,
            groupSetting   => "groupIdAdminVersionTag"
        },
        "workflow" => {
            title => "^International(topicName,Workflow);",
            icon    => "workflow.gif",
            url      => "^PageUrl(\"\",manageWorkflows);",
            uiLevel => 7,
            groupSetting   => "groupIdAdminWorkflow"
        },
        "adSpace" => {
            title => "^International(topicName,AdSpace);",
            icon    => "advertising.gif",
            url      => "^PageUrl(\"\",op=manageAdSpaces);",
            uiLevel => 5,
            groupSetting   => "groupIdAdminAdSpace"
        },
        "cron" => {
            title => "^International(topicName,Workflow_Cron);",
            icon    => "cron.gif",
            url      => "^PageUrl(\"\",op=manageCron);",
            uiLevel => 9,
            groupSetting   => "groupIdAdminCron"
        },
        "users" => {
            title => "^International(149,WebGUI);",
            icon    => "users.gif",
            url      => "^PageUrl(\"\",op=listUsers);",
            uiLevel => 5,
            groupSetting   => "groupIdAdminUser"
        },
        "clipboard" => {
            title => "^International(948,WebGUI);",
            icon    => "clipboard.gif",
            url    => "^PageUrl(\"\",func=manageClipboard);",
            uiLevel => 5,
            group   => "12"
        },
        "trash" => {
            title => "^International(trash,WebGUI);",
            icon    => "trash.gif",
            url    => "^PageUrl(\"\",func=manageTrash);",
            uiLevel => 5,
            group   => "12"
        },
        "databases" => {
            title => "^International(databases,WebGUI);",
            icon    => "databases.gif",
            url      => "^PageUrl(\"\",op=listDatabaseLinks);",
            uiLevel => 9,
            groupSetting   => "groupIdAdminDatabaseLink"
        },
        "ldapconnections" => {
            title => "^International(ldapconnections,AuthLDAP);",
            icon    => "ldap.gif",
            url      => "^PageUrl(\"\",op=listLDAPLinks);",
            uiLevel => 9,
            groupSetting   => "groupIdAdminLDAPLink"
        },
        "groups" => {
            title => "^International(89,WebGUI);",
            icon    => "groups.gif",
            url      => "^PageUrl(\"\",op=listGroups);",
            uiLevel => 5,
            groupSetting   => "groupIdAdminGroup"
        },
        "settings" => {
            title => "^International(settings,WebGUI);",
            icon    => "settings.gif",
            url      => "^PageUrl(\"\",op=editSettings);",
            uiLevel => 5,
            group   => "3"
        },
        "help" => {
            title => "^International(help,WebGUI);",
            icon    => "help.gif",
            url      => "^PageUrl(\"\",op=viewHelpIndex);",
            uiLevel => 1,
            groupSetting   => "groupIdAdminHelp"
        },
        "statistics" => {
            title => "^International(437,WebGUI);",
            icon    => "statistics.gif",
            url      => "^PageUrl(\"\",op=viewStatistics);",
            uiLevel => 1,
            groupSetting   => "groupIdAdminStatistics"
        },
        "contentProfiling" => {
            title => "^International(content profiling,Asset);",
            icon    => "contentProfiling.gif",
            url    => "^PageUrl(\"\",func=manageMetaData);",
            uiLevel => 5,
            group   => "4"
        },
        "contentFilters" => {
            title => "^International(content filters,WebGUI);",
            icon    => "contentFilters.gif",
            url      => "^PageUrl(\"\",op=listReplacements);",
            uiLevel => 3,
            groupSetting   => "groupIdAdminReplacements"
        },
        "userProfiling" => {
            title => "^International(user profiling,WebGUIProfile);",
            icon    => "userProfiling.gif",
            url      => "^PageUrl(\"\",op=editProfileSettings);",
            uiLevel => 5,
            groupSetting   => "groupIdAdminProfileSettings"
        },
        "loginHistory" => {
            title => "^International(426,WebGUI);",
            icon    => "loginHistory.gif",
            url      => "^PageUrl(\"\",op=viewLoginHistory);",
            uiLevel => 5,
            groupSetting   => "groupIdAdminLoginHistory"
        },
        "inbox" => {
            title => "^International(159,WebGUI);",
            icon    => "inbox.gif",
            url      => "^PageUrl(\"\",op=viewInbox);",
            uiLevel => 1,
            group   => "2"
        },
        "activeSessions" => {
            title => "^International(425,WebGUI);",
            icon    => "activeSessions.gif",
            url      => "^PageUrl(\"\",op=viewActiveSessions);",
            uiLevel => 5,
            groupSetting   => "groupIdAdminActiveSessions"
        },
        "shop" => {
            title => "^International(shop,Shop);",
            icon    => "shop.gif",
            url      => "^PageUrl(\"\",shop=admin);",
            uiLevel => 5,
            groupSetting   => 'groupIdAdminCommerce'
        },
        "cache" => {
            title => "^International(manage cache,WebGUI);",
            icon    => "cache.gif",
            url      => "^PageUrl(\"\",op=manageCache);",
            uiLevel => 5,
            groupSetting   => "groupIdAdminCache"
        },
        "graphics" => {
            title => "^International(manage graphics,Graphics);",
            icon    => "graphics.gif",
            url      => "^PageUrl(\"\",op=listGraphicsOptions);",
            uiLevel => 5,
            groupSetting   => "groupIdAdminGraphics"
        },                                          
        });
    print "DONE!\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Add the "isDefault" flag and set it for the right templates
sub addIsDefaultTemplates {
    my $session     = shift;
    print "\tAdding warning when editing default templates... " unless $quiet;
    $session->db->write( "ALTER TABLE template ADD COLUMN isDefault INT(1) DEFAULT 0" );
    print "DONE!\n" unless $quiet;
}

sub setDefaultTemplates {
    my $session     = shift;
    print "\tUpdating default templates to show warning... " unless $quiet; 
    my $defaultTemplates    =[
          '-ANLpoTEP-n4POAdRxCzRw','05FpjceLYhq4csF1Kww1KQ','0X4Q3tBWUb_thsVbsYz9xQ',
          '2gtFt7c0qAFNU3BG_uvNvg','2rC4ErZ3c77OJzJm7O5s3w','3womoo7Teyy2YKFa25-MZg',
          '63ix2-hU0FchXGIWkG3tow','6X-7Twabn5KKO_AbgK3PEw','7JCTAiu1U_bT9ldr655Blw',
          'BMybD3cEnmXVk2wQ_qEsRQ','CalendarDay00000000001','CalendarEvent000000001',
          'CalendarEventEdit00001','CalendarMonth000000001','CalendarPrintDay000001',
          'CalendarPrintEvent0001','CalendarPrintMonth0001','CalendarPrintWeek00001',
          'CalendarSearch00000001','CalendarWeek0000000001','DPUROtmpl0000000000001',
          'DashboardViewTmpl00001','EBlxJpZQ9o-8VBOaGQbChA','GNvjCFQWjY2AF2uf0aCM8Q',
          'IOB0000000000000000001','IOB0000000000000000002','KAMdiUdJykjN02CPHpyZOw',
          'MultiSearchTmpl0000001','OOyMH33plAy6oCj_QWrxtg','OkphOEdaSGTXnFGhK4GT5A',
          'OxJWQgnGsgyGohP2L3zJPQ','PBnav00000000000bullet','PBnav00000000indentnav',
          'PBnav000000style01lvl2','PBtmpl0000000000000001','PBtmpl0000000000000002',
          'PBtmpl0000000000000004','PBtmpl0000000000000005','PBtmpl0000000000000006',
          'PBtmpl0000000000000010','PBtmpl0000000000000011','PBtmpl0000000000000012',
          'PBtmpl0000000000000013','PBtmpl0000000000000014','PBtmpl0000000000000020',
          'PBtmpl0000000000000021','PBtmpl0000000000000024','PBtmpl0000000000000026',
          'PBtmpl0000000000000027','PBtmpl0000000000000029','PBtmpl0000000000000031',
          'PBtmpl0000000000000032','PBtmpl0000000000000033','PBtmpl0000000000000036',
          'PBtmpl0000000000000037','PBtmpl0000000000000038','PBtmpl0000000000000039',
          'PBtmpl0000000000000040','PBtmpl0000000000000041','PBtmpl0000000000000042',
          'PBtmpl0000000000000043','PBtmpl0000000000000044','PBtmpl0000000000000045',
          'PBtmpl0000000000000047','PBtmpl0000000000000048','PBtmpl0000000000000051',
          'PBtmpl0000000000000053','PBtmpl0000000000000054',
          'PBtmpl0000000000000055','PBtmpl0000000000000056','PBtmpl0000000000000057',
          'PBtmpl0000000000000059','PBtmpl0000000000000060','PBtmpl0000000000000061',
          'PBtmpl0000000000000062','PBtmpl0000000000000063','PBtmpl0000000000000064',
          'PBtmpl0000000000000065','PBtmpl0000000000000066','PBtmpl0000000000000067',
          'PBtmpl0000000000000068','PBtmpl0000000000000077',
          'PBtmpl0000000000000078','PBtmpl0000000000000079','PBtmpl0000000000000080',
          'PBtmpl0000000000000081','PBtmpl0000000000000082','PBtmpl0000000000000083',
          'PBtmpl0000000000000084','PBtmpl0000000000000085','PBtmpl0000000000000088',
          'PBtmpl0000000000000090','PBtmpl0000000000000091','PBtmpl0000000000000092',
          'PBtmpl0000000000000093','PBtmpl0000000000000094','PBtmpl0000000000000097',
          'PBtmpl0000000000000098','PBtmpl0000000000000099',
          'PBtmpl0000000000000101','PBtmpl0000000000000103','PBtmpl0000000000000104',
          'PBtmpl0000000000000107','PBtmpl0000000000000108','PBtmpl0000000000000109',
          'PBtmpl0000000000000111','PBtmpl0000000000000112','PBtmpl0000000000000113',
          'PBtmpl0000000000000114','PBtmpl0000000000000115','PBtmpl0000000000000116',
          'PBtmpl0000000000000117','PBtmpl0000000000000118','PBtmpl0000000000000121',
          'PBtmpl0000000000000122','PBtmpl0000000000000123','PBtmpl0000000000000124',
          'PBtmpl0000000000000125','PBtmpl0000000000000128','PBtmpl0000000000000129',
          'PBtmpl0000000000000130','PBtmpl0000000000000131','PBtmpl0000000000000132',
          'PBtmpl0000000000000133','PBtmpl0000000000000134','PBtmpl0000000000000135',
          'PBtmpl0000000000000136','PBtmpl0000000000000137','PBtmpl0000000000000140',
          'PBtmpl0000000000000141','PBtmpl0000000000000142','PBtmpl0000000000000200',
          'PBtmpl0000000000000207',
          'PBtmpl0000000000000208','PBtmpl0000000000000209','PBtmpl0000000000000210',
          'PBtmpl000000000table54','PBtmpl00000000table094','PBtmpl00000000table109',
          'PBtmpl00000000table118','PBtmpl00000000table125','PBtmpl00000000table131',
          'PBtmpl00000000table135','PBtmplBlankStyle000001','PBtmplHelp000000000001',
          'ProjectManagerTMPL0001','ProjectManagerTMPL0002','ProjectManagerTMPL0003',
          'ProjectManagerTMPL0004','ProjectManagerTMPL0005','ProjectManagerTMPL0006',
          'PsFn7dJt4wMwBa8hiE3hOA','SQLReportDownload00001','StockDataTMPL000000001',
          'StockDataTMPL000000002','TEId5V-jEvUULsZA0wuRuA','ThingyTmpl000000000001',
          'ThingyTmpl000000000002','ThingyTmpl000000000003','ThingyTmpl000000000004',
          'TimeTrackingTMPL000001','TimeTrackingTMPL000002','TimeTrackingTMPL000003',
          'UTNFeV7B_aSCRmmaFCq4Vw','UserListTmpl0000000001','UserListTmpl0000000002',
          'UserListTmpl0000000003','WVtmpl0000000000000001','WeatherDataTmpl0000001',
          'WikiFrontTmpl000000001','WikiKeyword00000000001','WikiMPTmpl000000000001',
          'WikiPHTmpl000000000001','WikiPageEditTmpl000001','WikiPageTmpl0000000001',
          'WikiRCTmpl000000000001','WikiSearchTmpl00000001','XNd7a_g_cTvJVYrVHcx2Mw',
          'ZipArchiveTMPL00000001','aIpCmr9Hi__vgdZnDTz1jw','azCqD0IjdQSlM3ar29k5Sg',
          'bPz1yk6Y9uwMDMBcmMsSCg','eqb9sWjFEVq0yHunGV8IGw','g8W53Pd71uHB9pxaXhWf_A',
          'ilu5BrM-VGaOsec9Lm7M6Q','jME5BEDYVDlBZ8jIQA9-jQ','kj3b-X3i6zRKnhLb4ZiCLw',
          'm3IbBavqzuKDd2PGGhKPlA','mM3bjP_iG9sv5nQb4S17tQ','managefriends_________',
          'matrixtmpl000000000001','matrixtmpl000000000002','matrixtmpl000000000003',
          'matrixtmpl000000000004','matrixtmpl000000000005','nFen0xjkZn8WkpM93C9ceQ',
          'newsletter000000000001','newslettercs0000000001','newslettersubscrip0001',
          'pbtmpl0000000000000220','pbtmpl0000000000000221','q5O62aH4pjUXsrQR3Pq4lw',
          'stevecoolmenu000000001','stevenav00000000000001','stevestyle000000000001',
          'stevestyle000000000002','stevestyle000000000003','uRL9qtk7Rb0YRJ41LmHOJw',
          'vrKXEtluIhbmAS9xmPukDA','yBwydfooiLvhEFawJb0VTQ','zcX-wIUct0S_np14xxOA-A'
        ];
    
    for my $assetId ( @{ $defaultTemplates } ) {
        my $asset   = WebGUI::Asset::Template->new( $session, $assetId );
        if ( !$asset ) {
            print "\n\t\tCouldn't instanciate default asset '$assetId', skipping...";
            next;
        }
        else {
            $asset->update( { isDefault => 1 } );
        }
    } 

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub badgePriceDates {
    my $session = shift;
    print "\tAllowing badges to have multiple prices set by date." unless $quiet;
    my $db = $session->db;
    $db->write("alter table EMSBadge add column earlyBirdPrice float not null default 0.0");
    $db->write("alter table EMSBadge add column earlyBirdPriceEndDate bigint");
    $db->write("alter table EMSBadge add column preRegistrationPrice float not null default 0.0");
    $db->write("alter table EMSBadge add column preRegistrationPriceEndDate bigint");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub fixIsPublicOnTemplates {
    my $session = shift;
    print "\tFixing 'is public' on templates" unless $quiet;
    $session->db->write('UPDATE `assetIndex` SET `isPublic` = 0 WHERE assetId IN (SELECT assetId FROM asset WHERE className IN ("WebGUI::Asset::RichEdit", "WebGUI::Asset::Snippet", "WebGUI::Asset::Template") )');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addCSPostReceivedTemplate {
    my $session = shift;
    print "\tAdding Post Received Template ID field for CS..." unless $quiet;
    $session->db->write("ALTER TABLE Collaboration ADD COLUMN postReceivedTemplateId VARCHAR(22) DEFAULT 'default_post_received';");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addUrlToAssetHistory {
    my $session = shift;
    print "\tAdding URL column to assetHistory" unless $quiet;
    $session->db->write('ALTER TABLE assetHistory ADD COLUMN url VARCHAR(255)');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addSortOrderToFolder {
    my $session = shift;
    print "\tAdding Sort Order to Folder... " unless $quiet;
    $session->db->write( 'alter table Folder add column sortOrder ENUM("ASC","DESC") DEFAULT "ASC"' );
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addLoginTimeStats {
    my $session     = shift;
    print "\tAdding login time statistics... " unless $quiet;
    $session->db->write( "alter table userLoginLog add column sessionId varchar(22)" );
    $session->db->write( "alter table userLoginLog add column lastPageViewed int(11)" );
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeDoNothingOnDelete {
    my $session = shift;
    print "\tRemoving 'Do Nothing On Delete workflow if not customized... " unless $quiet;
    my $workflow = WebGUI::Workflow->new($session, 'DPWwf20061030000000001');
    if ($workflow) {
        my $activities = $workflow->getActivities;
        if (@$activities == 0) {
            # safe to delete.
            for my $setting (qw(trashWorkflow purgeWorkflow changeUrlWorkflow)) {
                my $setValue = $session->setting->get($setting);
                if ($setValue eq 'DPWwf20061030000000001') {
                    $session->setting->set($setting, undef);
                }
            }
            $workflow->delete;
        }
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub redirectChoice {
    my $session = shift;
    print "\tGiving a user choice about which type of redirect they'd like to perform... " unless $quiet;
    $session->db->write("alter table redirect add column redirectType int not null default 302");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addAdHocMailGroups {
    my $session = shift;
    print "\tAdding AdHocMailGroups to Groups.. " unless $quiet;
    $session->db->write("alter table groups add column isAdHocMailGroup tinyint(4) not null default 0");
    print "DONE!\n" unless $quiet;
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
    setDefaultTemplates( $session );
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
    addPackage( $session, 'packages-7.5.40-7.6.10/merged.wgpkg' );
}

