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
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Collaboration;
use WebGUI::Asset::Wobject::Survey;
use WebGUI::Asset::Wobject::Survey::SurveyJSON;
use WebGUI::Asset::Wobject::Survey::ResponseJSON;
use WebGUI::ProfileField;
use WebGUI::Utility qw(isIn);
use JSON;

my $toVersion = '7.6.4';
my $quiet; # this line required


my $session = start(); # this line required

addVersionTagMode($session);
migrateSurvey($session);
addPosMode($session);
fixFriendsGroups( $session );
upgradeAccount( $session );
removeProcessRecurringPaymentsFromConfig( $session );
addExtendedProfilePrivileges( $session );
addStorageUrlMacro( $session );
addRecurringSubscriptionSwitch( $session );
upgradeMatrix( $session );
increaseDataFormSizeLimits( $session );
finish($session); # this line required

#----------------------------------------------------------------------------
sub increaseDataFormSizeLimits {
    my $session = shift;
    print "\tIncreasing size of DataForm entry data field... " unless $quiet;
    $session->db->write("ALTER TABLE DataForm_entry MODIFY COLUMN entryData mediumtext");
    print "Done.\n" unless $quiet;
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
    $db->write("drop table Matrix_listing");
    $db->write("drop table Matrix_listingData");
    print "DONE!\n" unless $quiet;
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
sub removeProcessRecurringPaymentsFromConfig {
    my $session = shift;

    print qq{\tRemoving old ProcessRecurringPayments workflow activity from config...} if !$quiet;

    my $config = $session->config();
    my $workflowActivities = $config->get('workflowActivities');
    my @noObjects = ();
    foreach my $activity (@{ $workflowActivities->{'None'}}) {
        push @noObjects, $activity unless
            $activity eq 'WebGUI::Workflow::Activity::ProcessRecurringPayments';
    }
    $workflowActivities->{'None'} = [ @noObjects ];
    $config->set('workflowActivities', $workflowActivities);
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
