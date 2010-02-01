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
use List::MoreUtils qw/uniq/;
use WebGUI::Asset;
use WebGUI::Asset::Template;
use WebGUI::Asset::Wobject::Survey::Test;
use WebGUI::AssetCollateral::Sku::Ad::Ad;
use WebGUI::AssetCollateral::Sku::ThingyRecord::Record;
use WebGUI::FilePump::Bundle;
use WebGUI::International;
use WebGUI::PassiveAnalytics::Rule;
use WebGUI::ProfileField;
use WebGUI::Utility;
use WebGUI::VersionTag;
use WebGUI::Workflow;
use JSON qw/to_json/;

my $toVersion = "7.7.17"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

###############################################################
##   7.6.14 - 7.7.0
###############################################################
addTemplateAttachmentsTable($session);
reKeyTemplateAttachments($session);
addAccountActivationTemplateToSettings( $session );
surveyDoAfterTimeLimit($session);
surveyRemoveResponseTemplate($session);
surveyEndWorkflow($session);
installAssetHistory($session);
addMinimumCartCheckoutSetting( $session );

# Passive Analytics
pa_installLoggingTables($session);
pa_installPassiveAnalyticsRule($session);
pa_installPassiveAnalyticsConfig($session);
pa_installWorkflow($session);
pa_addPassiveAnalyticsSettings($session);
pa_addPassiveAnalyticsStatus($session);

# vendor payouts
addTransactionItemFlags( $session );
createShopAcccountPluginSettings( $session );

###############################################################
##   7.7.0 - 7.7.1
###############################################################
adSkuInstall($session);
addWelcomeMessageTemplateToSettings( $session );
removeOldSettings( $session );

#add Survey table
addSurveyQuestionTypes($session);

# image mods
addImageAnnotation($session);

# rss mods
addRssLimit($session);

###############################################################
##   7.7.1 - 7.7.2
###############################################################
addRssFeedAspect($session);
addRssFeedAspectToAssets($session);
convertCollaborationToRssAspect($session);
removeRssCapableAsset($session);

###############################################################
##   7.7.2 - 7.7.3
###############################################################
addSurveyQuizModeColumns($session);
addSurveyExpressionEngineConfigFlag($session);
addCarouselWobject($session);
reInstallPassiveAnalyticsConfig($session);

###############################################################
##   7.7.4 - 7.7.5
###############################################################
updateSurveyQuestionTypes($session);
installThingyRecord( $session );
installPluggableTax( $session );
addSurveyBackButtonColumn( $session );

# Story Manager
installStoryManagerTables($session);
sm_upgradeConfigFiles($session);
sm_updateDailyWorkflow($session);
turnOffAdmin($session);

fixConfigs($session);

addGlobalHeadTags( $session );
addShipsSeparateToSku($session);

addTemplatePacking( $session );

###############################################################
##   7.7.5 - 7.7.6
###############################################################
addMobileStyleTemplate( $session );
revertUsePacked( $session );
addEuVatDbColumns( $session );
addShippingDrivers( $session );
addTransactionTaxColumns( $session );
sendWebguiStats($session);
addDataFormColumns($session);
addListingsCacheTimeoutToMatrix( $session );
addSurveyFeedbackTemplateColumn( $session );
installCopySender($session);
installNotificationsSettings($session);
installSMSUserProfileFields($session);
installSMSSettings($session);
upgradeSMSMailQueue($session);
addPayDrivers($session);
addCollaborationColumns($session);
installSurveyTest($session);
installFriendManagerSettings($session);
installFriendManagerConfig($session);

###############################################################
##   7.7.6 - 7.7.7
###############################################################
removeDanglingOldRssAssets( $session );
addOgoneToConfig( $session );
addUseEmailAsUsernameToSettings( $session );
alterVATNumberTable( $session );
addRedirectAfterLoginUrlToSettings( $session );
addSurveyTestResultsTemplateColumn( $session );
updateSurveyTest( $session );
fixSMSUserProfileI18N($session);
addEmsScheduleColumns ($session);
addMapAsset( $session );
installFilePumpHandler($session);
installFilePumpTable($session);
installFilePumpAdminGroup($session);
addUserControlWorkflows($session);

###############################################################
##   7.7.7 - 7.7.8
###############################################################
addMobileStyleConfig($session);

###############################################################
##   7.7.9 - 7.7.9
###############################################################
repackTemplates( $session );

###############################################################
##   7.7.9 - 7.7.10
###############################################################
addStoryPhotoWidth($session);

###############################################################
##   7.7.10 - 7.7.11
###############################################################
makeSurveyResponsesVersionAware($session);
shrinkSurveyJSON($session);

###############################################################
##   7.7.11 - 7.7.12
###############################################################
surveyCleanUp($session);
addUTCMacro($session);

###############################################################
##   7.7.14 - 7.7.15
###############################################################
replacePayPalDriver($session);
addFieldPriceToThingyRecord( $session );
replaceUsageOfOldTemplates($session);

###############################################################
##   7.7.15 - 7.7.16
###############################################################
replaceUsageOfOldTemplatesAgain($session);
updatePayPalDriversAgain($session);
addThingyRecordFieldPriceDefaults($session);

###############################################################
##   7.7.16 - 7.7.17
###############################################################
addFriendManagerSettings($session);
fixMapTemplateFolderStyle($session);
addExpireIncompleteSurveyResponsesWorkflow($session);

finish($session); # this line required


#----------------------------------------------------------------------------
sub addAccountActivationTemplateToSettings {
    my $session = shift;
    print "\tAdding account activation template to settings... " unless $quiet;

    $session->db->write("insert into settings (name, value) values ('webguiAccountActivationTemplate','PBtmpl0000000000000016')");
    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
sub surveyDoAfterTimeLimit {
    my $session = shift;
    print "\tAdding column doAfterTimeLimit to Survey table... " unless $quiet;
    $session->db->write('alter table Survey add doAfterTimeLimit char(22)');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub surveyEndWorkflow {
    my $session = shift;
    print "\tAdding column onSurveyEndWorkflowId to Survey table... " unless $quiet;
    $session->db->write('alter table Survey add onSurveyEndWorkflowId varchar(22) character set utf8 collate utf8_bin');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub surveyRemoveResponseTemplate {
    my $session = shift;
    print "\tRemoving responseTemplate... " unless $quiet;
    $session->db->write('alter table Survey drop responseTemplateId');
    if (my $template = WebGUI::Asset->new($session, 'PBtmpl0000000000000064')) {
        $template->purge();
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub installAssetHistory {
    my $session = shift;
    print "\tAdding Asset History content handler... " unless $quiet;
    ##Content Handler
    my $contentHandlers = $session->config->get('contentHandlers');
    if (! isIn('WebGUI::Content::AssetHistory', @{ $contentHandlers }) ) {
        my @newHandlers = ();
        foreach my $handler (@{ $contentHandlers }) {
            push @newHandlers, $handler;
            push @newHandlers, 'WebGUI::Content::AssetHistory' if
                $handler eq 'WebGUI::Content::Account';
        }
        $session->config->set('contentHandlers', \@newHandlers);
    }
    ##Admin Console
    $session->config->addToHash('adminConsole', 'assetHistory', {
      "icon" => "assetHistory.gif",
      "groupSetting" => "groupIdAdminHistory",
      "uiLevel" => 5,
      "url" => "^PageUrl(\"\",op=assetHistory);",
      "title" => "^International(assetHistory,Asset);"
    });
    ##Setting for custom group
    $session->setting->add('groupIdAdminHistory', 12);
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub pa_installLoggingTables {
    my $session = shift;
    print "\tInstall logging tables... " unless $quiet;
    my $db = $session->db;
    $db->write(<<EOT1);
DROP TABLE IF EXISTS `passiveLog`
EOT1
$db->write(<<EOT1);
CREATE TABLE `passiveLog` (
    `userId`    varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `assetId`   varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `sessionId` varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `timeStamp` bigint(20),
    `url`       varchar(255) character set utf8 collate utf8_bin NOT NULL default ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT1
    $db->write(<<EOT2);
DROP TABLE IF EXISTS `deltaLog`
EOT2
    $db->write(<<EOT2);
CREATE TABLE `deltaLog` (
    `userId`    varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `assetId`   varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `delta`     integer,           
    `timeStamp` bigint(20),
    `url`       varchar(255) character set utf8 collate utf8_bin NOT NULL default ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT2
    $db->write(<<EOT3);
DROP TABLE IF EXISTS `bucketLog`
EOT3
    $db->write(<<EOT3);
CREATE TABLE `bucketLog` (
    `userId`    varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `Bucket`    varchar(22)  character set utf8 collate utf8_bin NOT NULL default '',
    `duration`  integer,           
    `timeStamp` datetime
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT3
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the PassiveAnalytics Rule table
sub pa_installPassiveAnalyticsRule {
    my $session = shift;
    print "\tInstall Passive Analytics rule table, via Crud... " unless $quiet;
    # and here's our code
    WebGUI::PassiveAnalytics::Rule->crud_createTable($session);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the PassiveAnalytics Settings
sub pa_addPassiveAnalyticsSettings {
    my $session = shift;
    print "\tInstall Passive Analytics settings... " unless $quiet;
    # and here's our code
    $session->setting->add('passiveAnalyticsInterval', 300);
    $session->setting->add('passiveAnalyticsDeleteDelta', 0);
    $session->setting->add('passiveAnalyticsEnabled', 0);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the PassiveAnalytics Rule table
sub pa_addPassiveAnalyticsStatus {
    my $session = shift;
    my $db      = $session->db;
    print "\tInstall Passive Analytics status table... " unless $quiet;
    # and here's our code
    $db->write(<<EOT2);
DROP TABLE if exists passiveAnalyticsStatus;
EOT2
    $db->write(<<EOT3);
CREATE TABLE `passiveAnalyticsStatus` (
    `startDate` datetime,
    `endDate`   datetime,
    `running`   integer(2) DEFAULT 0,
    `userId`    varchar(22)  character set utf8 collate utf8_bin NOT NULL default ''
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
EOT3
    $db->write('insert into passiveAnalyticsStatus (userId) VALUES (3)');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the Passive Analytics config file entry
# for the adminConsole and the content handler
sub pa_installPassiveAnalyticsConfig {
    my $session = shift;
    print "\tAdd Passive Analytics entry to the config file... " unless $quiet;
    # Admin Bar/Console
    my $adminConsole = $session->config->get('adminConsole');
    if (!exists $adminConsole->{'passiveAnalytics'}) {
        $adminConsole->{'passiveAnalytics'} = {
            "icon"         => "passiveAnalytics.png",
            "uiLevel"      => 1,
            "url"          => "^PageUrl(\"\",op=passiveAnalytics;func=editRuleflow);",
            "title"        => "^International(Passive Analytics,PassiveAnalytics);",
            "groupSetting" => "3",
        };
        $session->config->set('adminConsole', $adminConsole);
    }
    # Content Handler
    my $contentHandlers = $session->config->get('contentHandlers');
    if (!isIn('WebGUI::Content::PassiveAnalytics',@{ $contentHandlers} ) ) {
        my $contentIndex = 0;
        HANDLER: while ($contentIndex <= $#{ $contentHandlers } ) {
            ##Insert before Operation
            if($contentHandlers->[$contentIndex] eq 'WebGUI::Content::Operation') {
                splice @{ $contentHandlers }, $contentIndex, 0, 'WebGUI::Content::PassiveAnalytics';
                last HANDLER;
            }
            ++$contentIndex;
        }
        $session->config->set('contentHandlers', $contentHandlers);
    }
    # Workflow Activities
    my $workflowActivities = $session->config->get('workflowActivities');
    my @none = @{ $workflowActivities->{'None'} };
    if (!isIn('WebGUI::Workflow::Activity::SummarizePassiveAnalytics', @none)) {
        push  @none, 'WebGUI::Workflow::Activity::SummarizePassiveAnalytics';
    }
    if (!isIn('WebGUI::Workflow::Activity::BucketPassiveAnalytics', @none)) {
        push  @none, 'WebGUI::Workflow::Activity::BucketPassiveAnalytics';
    }
    $workflowActivities->{'None'} = [ @none ];
    $session->config->set('workflowActivities', $workflowActivities);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the Passive Analytics Workflow
sub pa_installWorkflow {
    my $session = shift;
    print "\tAdd Passive Analytics Workflow... " unless $quiet;
    my $workflow = WebGUI::Workflow->create(
        $session,
        {
            title   => 'Analyze Passive Analytics',
            mode    => 'singleton',
            type    => 'None',
            description => 'Manual changes to this workflow will be lost.  Please only use the Passive Analytics screen to make changes',
        },
        'PassiveAnalytics000001',
    );
    my $summarize = $workflow->addActivity('WebGUI::Workflow::Activity::SummarizePassiveAnalytics');
    my $bucket    = $workflow->addActivity('WebGUI::Workflow::Activity::BucketPassiveAnalytics');
    $summarize->set('title', 'Perform duration analysis');
    $bucket->set(   'title', 'Please log entries into buckets');
    $workflow->set({enabled => 1});
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addTransactionItemFlags {
    my $session = shift;
    print "\tAdding columns for vendor payout tracking to transaction items..." unless $quiet;
    
    $session->db->write('alter table transactionItem add column vendorPayoutStatus char(10) default \'NotPaid\'');
    $session->db->write('alter table transactionItem add column vendorPayoutAmount float (6,2) default 0.00');

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub createShopAcccountPluginSettings {
    my $session = shift;
    print "\tCreating default settings for the account plugin..." unless $quiet;

    $session->setting->add('shopMySalesTemplateId', '-zxyB-O50W8YnL39Ouoc4Q');

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addMinimumCartCheckoutSetting {
    my $session = shift;
    print "\tAdding setting for minimum cart checkout..." unless $quiet;

    $session->setting->add( 'shopCartCheckoutMinimum', '0.00' );

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}


# -------------- DO NOT EDIT BELOW THIS LINE --------------------------------
sub removeOldSettings {
    my $session = shift;
    print "\tRemoving old, unused settings... " unless $quiet;
    my $setting = $session->setting;

    $setting->remove('commerceCheckoutCanceledTemplateId');
    $setting->remove('commerceConfirmCheckoutTemplateId');
    $setting->remove('commerceEnableSalesTax');
    $setting->remove('commercePaymentPlugin');
    $setting->remove('commercePurchaseHistoryTemplateId');
    $setting->remove('commerceSelectPaymentGatewayTemplateId');
    $setting->remove('commerceSelectShippingMethodTemplateId');
    $setting->remove('commerceSendDailyReportTo');
    $setting->remove('commerceViewShoppingCartTemplateId');

    print "Done.\n" unless $quiet;
}

sub addSurveyQuestionTypes{
    my $session = shift;
    print "\tAdding new survey table Survey_questionTypes... " unless $quiet;
    $session->db->write("
	CREATE TABLE `Survey_questionTypes` (
          `questionType` varchar(56) NOT NULL,
          `answers` text NOT NULL,
          PRIMARY KEY  (`questionType`))
	");
    $session->db->write(q{
    INSERT INTO `Survey_questionTypes` VALUES ('Scale',''),('Gender','Male,Female'),('Education','Elementary or some high school,High school/GED,Some college/vocational school,College graduate,Some graduate work,Master\\'s degree,Doctorate (of any type),Other degree (verbatim)'),('Importance','Not at all important,,,,,,,,,,Extremely important'),('Yes/No','Yes,No'),('Confidence','Not at all confident,,,,,,,,,,Extremely confident'),('Effectiveness','Not at all effective,,,,,,,,,,Extremely effective'),('Oppose/Support','Strongly oppose,,,,,,Strongly support'),('Certainty','Not at all certain,,,,,,,,,,Extremely certain'),('True/False','True,False'),('Concern','Not at all concerned,,,,,,,,,,Extremely concerned'),('Ideology','Strongly liberal,Liberal,Somewhat liberal,Middle of the road,Slightly conservative,Conservative,Strongly conservative'),('Security','Not at all secure,,,,,,,,,,Extremely secure'),('Risk','No risk,,,,,,,,,,Extreme risk'),('Agree/Disagree','Strongly disagree,,,,,,Strongly agree'),('Race','American Indian,Asian,Black,Hispanic,White non-Hispanic,Something else (verbatim)'),('Threat','No threat,,,,,,,,,,Extreme threat'),('Party','Democratic party,Republican party (or GOP),Independent party,Other party (verbatim)'),('Likelihood','Not at all likely,,,,,,,,,,Extremely likely'),('Multiple Choice',''),('Satisfaction','Not at all satisfied,,,,,,,,,,Extremely satisfied')
	});
    print "Done.\n" unless $quiet;
}

sub addWelcomeMessageTemplateToSettings {
    my $session = shift;
    print "\tAdding welcome message template to settings... " unless $quiet;

    $session->db->write("insert into settings values ('webguiWelcomeMessageTemplate', 'PBtmpl0000000000000015');");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addRssLimit {
    my $session = shift;
    print "\tAdding rssLimit to RSSCapable table, if needed... " unless $quiet;
    my $sth = $session->db->read('describe RSSCapable rssCapableRssLimit');
    if (! defined $sth->hashRef) {
        $session->db->write("alter table RSSCapable add column rssCapableRssLimit integer");
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addImageAnnotation {
    my $session = shift;
    print "\tAdding annotations to ImageAsset table, if needed... " unless $quiet;
    my $sth = $session->db->read('describe ImageAsset annotations');
    if (! defined $sth->hashRef) {
        $session->db->write("alter table ImageAsset add column annotations mediumtext");
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub adSkuInstall {
    my $session = shift;
    print "\tInstalling the AdSku Asset...\n" unless $quiet;
    print "\t\tCreate AdSku database table.\n" unless $quiet;
    $session->db->write("CREATE TABLE AdSku (
	assetId VARCHAR(22) BINARY NOT NULL,
	revisionDate BIGINT NOT NULL,
	purchaseTemplate VARCHAR(22) BINARY NOT NULL,
	manageTemplate VARCHAR(22) BINARY NOT NULL,
	adSpace VARCHAR(22) BINARY NOT NULL,
	priority INTEGER DEFAULT '1',
	pricePerClick Float DEFAULT '0',
	pricePerImpression Float DEFAULT '0',
	clickDiscounts VARCHAR(1024) default '',
	impressionDiscounts VARCHAR(1024) default '',
	PRIMARY KEY (assetId,revisionDate)
    )");
    print "\t\tCreate Adsku crud table.\n" unless $quiet;
    use WebGUI::AssetCollateral::Sku::Ad::Ad;
    WebGUI::AssetCollateral::Sku::Ad::Ad->crud_createTable($session);
    print "\t\tAdding to config file.\n" unless $quiet;
    $session->config->addToHash("assets", 'WebGUI::Asset::Sku::Ad' => { category => 'shop' } );
    print "\tDone.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addRssFeedAspect {
    my $session = shift;
    print "\tAdding RssFeed asset aspect..." unless $quiet;
    $session->db->write(q{create table assetAspectRssFeed (
        assetId char(22) binary not null,
        revisionDate bigint not null,
        itemsPerFeed int(11) default 25,
        feedCopyright text,
        feedTitle text,
        feedDescription mediumtext,
        feedImage char(22) binary,
        feedImageLink text,
        feedImageDescription mediumtext,
        feedHeaderLinks char(32) default 'rss\natom',
        primary key (assetId, revisionDate)
        )});
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addRssFeedAspectToAssets {
    my $session = shift;
    my $db = $session->db;
    foreach my $asset_class (qw( WikiMaster SyndicatedContent Gallery GalleryAlbum )) {
        print "\tAdding RssFeed aspect to $asset_class table..." unless $quiet;
        my $pages = $db->read("select assetId,revisionDate from $asset_class");
        while (my ($id, $rev) = $pages->array) {
            $db->write("INSERT INTO assetAspectRssFeed (assetId, revisionDate, itemsPerFeed, feedTitle, feedDescription, feedImage, feedImageLink, feedImageDescription) VALUES (?,?,25,'','',NULL,'','')",[$id,$rev]);
        }
        print "Done.\n" unless $quiet;
    }
}

#----------------------------------------------------------------------------
sub convertCollaborationToRssAspect {
    my $session = shift;
    print "\tAdding RssFeed aspect to Collaboration, (porting rssCapableRssLimit to itemsPerFeed)..." unless $quiet;
    my $db = $session->db;
    my @rssFromParents;
    my $pages = $db->read("SELECT Collaboration.assetId, Collaboration.revisionDate, RSSCapable.rssCapableRssLimit, RSSCapable.rssCapableRssFromParentId, RSSCapable.rssCapableRssEnabled FROM Collaboration INNER JOIN RSSCapable ON Collaboration.assetId=RSSCapable.assetId AND Collaboration.revisionDate=RSSCapable.revisionDate");
    while (my ($id, $rev, $limit, $fromParent, $enabled) = $pages->array) {
        if ($fromParent) {
            push @rssFromParents, $fromParent;
        }
        my $headerLinks = $enabled ? "rss\natom" : q{};
        $db->write("INSERT INTO assetAspectRssFeed (assetId, revisionDate, itemsPerFeed, feedTitle, feedDescription, feedImage, feedImageLink, feedImageDescription, feedHeaderLinks) VALUES (?,?,?,'','',NULL,'','',?)",[$id,$rev,$limit || 25, $headerLinks]);
    }
    for my $assetId (@rssFromParents) {
        my $asset = eval { WebGUI::Asset->newPending($session, $assetId) };
        if ($asset) {
            $asset->purge;
        }
    }
    $db->write("DELETE FROM RSSCapable WHERE assetId IN (SELECT assetId FROM Collaboration GROUP BY assetId)");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeRssCapableAsset {
    my $session = shift;
    print "\tChecking for uses of RSSCapable...\n" unless $quiet;
    my @rssCapableClasses = $session->db->buildArray('SELECT className FROM RSSCapable INNER JOIN asset ON RSSCapable.assetId=asset.assetId GROUP BY className');
    if (@rssCapableClasses) {
        warn "\t\tThis site is using the assets\n\t\t\t" . join(', ', @rssCapableClasses) . "\n\t\twhich use the RSSCapable class!  Support RSSCapable has been dropped and it will no longer be maintained.\n";
    }
    else {
        print "\t\tNot used, removing.\n" unless $quiet;
        $session->db->write(q|DELETE FROM assetData WHERE assetId IN (SELECT assetId FROM asset WHERE className="WebGUI::Asset::RssFromParent")|);
        $session->db->write(q|DELETE FROM asset WHERE className = "WebGUI::Asset::RssFromParent"|);
        $session->db->write("DROP TABLE RSSCapable");
        $session->db->write("DROP TABLE RSSFromParent");
        my $rssCapableTemplates = WebGUI::Asset->getRoot($session)->getLineage(['descendants'], {
            statesToInclude     => [qw(published clipboard clipboard-limbo trash-limbo)],
            statusToInclude     => [qw(approved pending archived)],
            returnObjects       => 1,
            includeOnlyClasses  => ['WebGUI::Asset::Template'],
            joinClass           => 'WebGUI::Asset::Template',
            whereClause         => q{template.namespace = 'RSSCapable/RSS'},
        });
        for my $template (@{$rssCapableTemplates}) {
            $template->trash;
        }
    }
    print "\tDone.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub makeSurveyResponsesVersionAware {
    my $session = shift;
    print "\tAdding revisionDate column to Survey_response table...\n" unless $quiet;
    $session->db->write("alter table Survey_response add column revisionDate bigint(20) not null default 0");
    
    print "\tDefaulting revisionDate on existing responses to current latest revision... " unless $quiet;
    for my $assetId ($session->db->buildArray('select assetId from Survey_response')) {
        $session->db->write(<<END_SQL, [ $assetId, $assetId]);
update Survey_response 
set revisionDate = ( 
    select max(revisionDate)
    from Survey 
    where Survey.assetId = ?
    )
where Survey_response.assetId = ?
END_SQL
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub shrinkSurveyJSON {
    my $session = shift;
    print "\tCompressing surveyJSON column in Survey table (this may take some time)... " unless $quiet;
    my $sth = $session->db->read('select assetId, revisionDate from Survey');
    use WebGUI::Asset::Wobject::Survey;
    while (my ($assetId, $revision) = $sth->array) {
        my $survey = WebGUI::Asset->new($session, $assetId, 'WebGUI::Asset::Wobject::Survey', $revision);
        $survey->persistSurveyJSON;
    }
    print "DONE!\n" unless $quiet;
    
    print "\tOptimizing Survey table... " unless $quiet;
    $session->db->write('optimize table Survey');    
    print "DONE!\n" unless $quiet;
}


sub addUTCMacro {
    my $session = shift;
    print "\tAdd ConvertUTCToTZ Macro to config files... " unless $quiet;
    # and here's our code
    $session->config->addToHash('macros', 'ConvertUTCToTZ', 'ConvertUTCToTZ' );
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub surveyCleanUp {
    my $session = shift;
    print "\tRemoving extra properties that may have crept into surveyJSON... " unless $quiet;
    
    my $sth = $session->db->read('select assetId, revisionDate from Survey');
    
    while (my ($assetId, $revision) = $sth->array) {
        my $survey = WebGUI::Asset->new($session, $assetId, 'WebGUI::Asset::Wobject::Survey', $revision);
        
        # Remove recursive properties that snuck into the mold
        if (my $mold = $survey->surveyJSON->mold) {
            $mold->{question}{answers} = [];
            $mold->{section}{questions} = [];
        }
        
        # Remove keys that should never have been added to sections/questions/answers
        for my $s (@{$survey->surveyJSON->sections}) {
            for my $q (@{$s->{questions} || []}) {
                for my $a (@{$q->{answers} || []}) {
                    delete $a->{$_} for qw(delete copy removetype addtype func);
                }
                delete $q->{$_} for qw(delete copy removetype addtype func);
            }
            delete $s->{$_} for qw(delete copy removetype addtype func);
        }
        $survey->persistSurveyJSON;
    }
    
    print "DONE!\n" unless $quiet;
}


sub addFieldPriceToThingyRecord {
    my $session = shift;
    print "\tAdd field prices to ThingyRecord... " unless $quiet;

    $session->db->write(
        "ALTER TABLE ThingyRecord ADD COLUMN fieldPrice LONGTEXT",
    );

    print "DONE!\n" unless $quiet;
}

sub replacePayPalDriver {
    my $session = shift;
    my $config  = $session->config;
    my $prop    = 'paymentDrivers';
    my $old     = 'WebGUI::Shop::PayDriver::PayPal::PayPalStd';
    my $drivers = $config->get($prop);
    foreach my $driver (@$drivers) {
        # We'll do nothing if the old paypal driver isn't used
        next unless $driver eq $old;

        print "\tUpdating config to use new PayPal driver..." unless $quiet;
        $config->deleteFromArray($prop, $old);
        $config->addToArray($prop, 'WebGUI::Shop::PayDriver::PayPal');
        print "DONE!\n" unless $quiet;
        last;
    }
}

#----------------------------------------------------------------------------
sub replaceUsageOfOldTemplates {
    my $session = shift;
    print "\tRemoving usage of outdated templates with new ones... " unless $quiet;
    # and here's our code
    print "\n\t\tUpgrading Navigation templates... " unless $quiet;
    my @navigationPairs = (
        ##   New                    Old
        [ qw/PBnav00000000000bullet PBtmpl0000000000000048/ ]  ##Bulleted List <- Vertical Menu
    );
    foreach my $pairs (@navigationPairs) {
        my ($new, $old) = @{ $pairs };
        $session->db->write('UPDATE Navigation SET templateId=? where templateId=?', [$new, $old]);
    }
    print "\n\t\tUpgrading Article templates... " unless $quiet;
    my @articlePairs = (
        ##   New                    Old
        [ qw/PBtmpl0000000000000103 PBtmpl0000000000000084/ ], ##Article with Image <- Center Image 
        [ qw/PBtmpl0000000000000123 PBtmpl0000000000000129/ ], ##Item               <- Item w/pop-up Links
        [ qw/PBtmpl0000000000000002 PBtmpl0000000000000207/ ], ##Default Article    <- Article with Files
    );
    foreach my $pairs (@articlePairs) {
        my ($new, $old) = @{ $pairs };
        $session->db->write('UPDATE Article SET templateId=? where templateId=?', [$new, $old]);
    }
    print "\n\t\tUpgrading Layout templates... " unless $quiet;
    my @layoutPairs = (
        ##   New                    Old
        [ qw/PBtmpl0000000000000135 PBtmpl00000000table125/ ], ## Side By Side   <- Left Column (Table)
        [ qw/PBtmpl0000000000000094 PBtmpl00000000table094/ ], ## One over two   <- News (Table)
        [ qw/PBtmpl0000000000000131 PBtmpl00000000table131/ ], ## Right Column   <- Right Column (Table)
        [ qw/PBtmpl0000000000000135 PBtmpl00000000table135/ ], ## Side By Side   <- Side By Side (Table)
        [ qw/PBtmpl0000000000000054 PBtmpl00000000table118/ ], ## Default Page   <- Three Over One (Table)
        [ qw/PBtmpl0000000000000054 PBtmpl000000000table54/ ], ## Default Page   <- Default Page (Table)
        [ qw/PBtmpl0000000000000109 PBtmpl00000000table109/ ], ## One Over Three <- One Over Three (Table)
        [ qw/PBtmpl0000000000000135 PBtmpl0000000000000125/ ], ## Side By Side   <- Left Column
        [ qw/PBtmpl0000000000000054 PBtmpl0000000000000118/ ], ## Default Page   <- Three Over One
    );
    foreach my $pairs (@layoutPairs) {
        my ($new, $old) = @{ $pairs };
        $session->db->write('UPDATE Layout SET templateId=? where templateId=?', [$new, $old]);
    }
    print "\n\t\tPurging old templates... " unless $quiet;
    my @oldTemplates = uniq map { $_->[1] } (@navigationPairs, @articlePairs, @layoutPairs);
    TEMPLATE: foreach my $templateId (@oldTemplates) {
        my $template = eval { WebGUI::Asset->newPending($session, $templateId); };
        if ($@) {
            print "\n\t\t\tUnable to instanciate templateId: $templateId.  Skipping...";
            next TEMPLATE;
        }
        print "\n\t\t\tPurging ". $template->getTitle . " ..." unless $quiet;
        $template->purge;
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub updatePayPalDriversAgain {
    my $session = shift;
    my $config  = $session->config;
    print "\tUpdating paypal drivers in config file..." unless $quiet;
    my $old = 'WebGUI::Shop::PayDriver::PayPal';
    my @new = qw(
        WebGUI::Shop::PayDriver::PayPal::PayPalStd
        WebGUI::Shop::PayDriver::PayPal::ExpressCheckout
    );
    $config->deleteFromArray('paymentDrivers', $old);
    foreach my $n (@new) {
        $config->deleteFromArray('paymentDrivers', $n);
        $config->addToArray('paymentDrivers', $n) ;
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub replaceUsageOfOldTemplatesAgain {
    my $session = shift;
    print "\tRemoving usage of outdated templates with new ones... " unless $quiet;
    # and here's our code
    print "\n\t\tUpgrading Navigation templates... " unless $quiet;
    my @navigationPairs = (
        ##   New                    Old
        [ qw/PBnav00000000000bullet PBtmpl0000000000000048/ ]  ##Bulleted List <- Vertical Menu
    );
    foreach my $pairs (@navigationPairs) {
        my ($new, $old) = @{ $pairs };
        $session->db->write('UPDATE Navigation SET templateId=? where templateId=?', [$new, $old])
    }
    print "\n\t\tPurging old templates... " unless $quiet;
    my @oldTemplates = uniq(map { $_->[1] } (@navigationPairs));
    TEMPLATE: foreach my $templateId (@oldTemplates) {
        my $template = eval { WebGUI::Asset->newPending($session, $templateId); };
        if ($@) {
            print "\n\t\t\tUnable to instanciate templateId: $templateId.  Skipping...";
            next TEMPLATE;
        }
        print "\n\t\t\tPurging ". $template->getTitle . " ..." unless $quiet;
        $template->purge;
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addThingyRecordFieldPriceDefaults {
    my $session = shift;
    print "\tAdd default fieldPrice JSON to ThingyRecord... " unless $quiet;
    # and here's our code
    $session->db->write(q|UPDATE ThingyRecord set fieldPrice='{}' where fieldPrice IS NULL|);
    print "DONE!\n" unless $quiet;
}


sub addFriendManagerSettings {
    my $session = shift;
    print "\tAdding Friend Manager Style and Layout template settings... " unless $quiet;
    $session->setting->add('fmStyleTemplateId', $session->setting->get("userFunctionStyleId"));
    $session->setting->add('fmLayoutTemplateId', 'N716tpSna0iIQTKxS4gTWA');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub fixMapTemplateFolderStyle {
    my $session = shift;
    print "\tFix the Map Template subfolder style template... " unless $quiet;
    my $folder = WebGUI::Asset->new($session, 'brxm_faNdZX5tRo3p50g3g', 'WebGUI::Asset::Wobject::Folder');
    return unless $folder;
    if ($folder) {
        $folder->addRevision({
            styleTemplateId => 'PBtmpl0000000000000060',
        });
    }
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addExpireIncompleteSurveyResponsesWorkflow {
    my $session = shift;
    
    print "\tAdd ExpireIncompleteSurveyResponses workflow activity... " unless $quiet;
    
    my $none = $session->config->get('workflowActivities/None');
    if (! grep { $_ eq 'WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses' } @$none) {
        push @$none, 'WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses';
    }
    $session->config->set('workflowActivities/None', [@$none]);
    
    my $workflow = WebGUI::Workflow->new($session, 'pbworkflow000000000001');
    my $activity = $workflow->addActivity('WebGUI::Workflow::Activity::ExpireIncompleteSurveyResponses');
    $activity->set('title', 'Expire Incomplete Survey Responses');
    $activity->set('description', 'Expires incomplete Survey Responses according to per-instance Survey settings');
    
    print "DONE!\n" unless $quiet;
}

sub addCarouselWobject{
    my $session = shift;
    print "\tAdding Carousel wobject... " unless $quiet;
    $session->db->write("create table Carousel (
        assetId         char(22) binary not null,
        revisionDate    bigint      not null,
        items           mediumtext,
        templateId      char(22),
        primary key (assetId, revisionDate)
        )");
    my $assets  = $session->config->get( "assets" );
    $assets->{ "WebGUI::Asset::Wobject::Carousel" } = { category => "utilities" };
    $session->config->set( "assets", $assets );
    print "Done.\n" unless $quiet;
}

sub addSurveyQuizModeColumns{
    my $session = shift;
    print "\tAdding columns to Survey table... " unless $quiet;
    $session->db->write("alter table Survey add column `quizModeSummary` TINYINT(3)");
    $session->db->write("alter table Survey add column `surveySummaryTemplateId` char(22)");
    print "Done.\n" unless $quiet;
}

sub addSurveyExpressionEngineConfigFlag{
    my $session = shift;
    print "\tAdding enableSurveyExpressionEngine config option... " unless $quiet;
    $session->config->set('enableSurveyExpressionEngine', 0);
    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Conditionally re-add passive analytics config because it wasn't added to WebGUI.conf.original
# in version 7.7.0.
sub reInstallPassiveAnalyticsConfig {
    my $session = shift;
    print "\tAdd Passive Analytics entry to the config file... " unless $quiet;
    # Admin Bar/Console
    my $adminConsole = $session->config->get('adminConsole');
    if (!exists $adminConsole->{'passiveAnalytics'}) {
        $adminConsole->{'passiveAnalytics'} = {
            "icon"         => "passiveAnalytics.png",
            "uiLevel"      => 1,
            "url"          => "^PageUrl(\"\",op=passiveAnalytics;func=editRuleflow);",
            "title"        => "^International(Passive Analytics,PassiveAnalytics);",
            "groupSetting" => "3",
        };
        $session->config->set('adminConsole', $adminConsole);
    }
    # Content Handler
    my $contentHandlers = $session->config->get('contentHandlers');
    if (!isIn('WebGUI::Content::PassiveAnalytics',@{ $contentHandlers} ) ) {
        my $contentIndex = 0;
        HANDLER: while ($contentIndex <= $#{ $contentHandlers } ) {
            ##Insert before Operation
            if($contentHandlers->[$contentIndex] eq 'WebGUI::Content::Operation') {
                splice @{ $contentHandlers }, $contentIndex, 0, 'WebGUI::Content::PassiveAnalytics';
                last HANDLER;
            }
            ++$contentIndex;
        }
        $session->config->set('contentHandlers', $contentHandlers);
    }
    # Workflow Activities
    my $workflowActivities = $session->config->get('workflowActivities');
    my @none = @{ $workflowActivities->{'None'} };
    if (!isIn('WebGUI::Workflow::Activity::SummarizePassiveAnalytics', @none)) {
        push  @none, 'WebGUI::Workflow::Activity::SummarizePassiveAnalytics';
    }
    if (!isIn('WebGUI::Workflow::Activity::BucketPassiveAnalytics', @none)) {
        push  @none, 'WebGUI::Workflow::Activity::BucketPassiveAnalytics';
    }
    $workflowActivities->{'None'} = [ @none ];
    $session->config->set('workflowActivities', $workflowActivities);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub updateSurveyQuestionTypes{
    my $session = shift;
    my $refs = $session->db->buildArrayRefOfHashRefs("SELECT * FROM Survey_questionTypes");
    for my $ref(@$refs){
        my $name = $ref->{questionType};
        my $params;
        my @texts = split/,/,$ref->{answers};
        #next if(@texts == 0);
        my $count = 0;
        for my $text(@texts){
            my $verbatim = 0;
            $verbatim = 1 if($text =~ /verbatim/);
            push(@$params,[$text,$count++,$verbatim]);
        }
        _loadValues($name,$params,$session);
    }
}

sub _loadValues{
    my $name = shift;
    my $values = shift;
    my $session = shift;
    my $answers = [];
    for my $value(@$values){
        my $answer = _getAnswer();
        $answer->{text} = $value->[0];
        if($answer->{text} eq 'No'){
            $answer->{recordedAnswer} = 0;
        }elsif($answer->{text} eq 'Yes'){
            $answer->{recordedAnswer} = 1;
        }elsif($answer->{text} eq 'True'){
            $answer->{recordedAnswer} = 1;
        }elsif($answer->{text} eq 'False'){
            $answer->{recordedAnswer} = 0;
        }else{
            $answer->{recordedAnswer} = $value->[1];
        }
        $answer->{verbatim} = $value->[2];
        push @$answers,$answer;
    }
    my $json = to_json($answers);
    $session->db->write("UPDATE Survey_questionTypes SET answers = ? WHERE questionType = ?",[$json,$name]);
}

sub _getAnswer{
    my $answer = {
            text           => q{},
            verbatim       => 0,
            textCols       => 10,
            textRows       => 5,
            goto           => q{},
            gotoExpression => q{},
            recordedAnswer => q{},
            isCorrect      => 1,
            min            => 1,
            max            => 10,
            step           => 1,
            value          => 1,
            terminal       => 0,
            terminalUrl    => q{},
            type           => 'answer'
    };
    return $answer;
}

#----------------------------------------------------------------------------
sub installPluggableTax {
    my $session = shift;
    my $db      = $session->db;
    print "\tInstall tables for pluggable tax system..." unless $quiet;

    # Rename table for the Generic tax plugin
    $db->write( 'alter table tax rename tax_generic_rates' );

    # Create tax driver table
    $db->write( 'create table taxDriver (className char(255) not null primary key, options mediumtext)' );

    # Table for storing EU VAT numbers.
    $db->write( <<EOSQL2 );
        create table tax_eu_vatNumbers (
            userId      char(22)    binary  not null, 
            countryCode char(3)             not null, 
            vatNumber   char(20)            not null, 
            approved    tinyint(1)          not null default 0, 
            primary key( userId, vatNumber )
        );
EOSQL2

    # Add the Generic and EU taxdrivers to the config file.
    $session->config->set( 'taxDrivers', [
        'WebGUI::Shop::TaxDriver::Generic',
        'WebGUI::Shop::TaxDriver::EU',
    ] );

    # Add a setting to store the active tax plugin.
    $session->setting->add( 'activeTaxPlugin', 'WebGUI::Shop::TaxDriver::Generic' );

    # Add column to sku for storing each sku's tax configuration.
    $db->write( "alter table sku add column taxConfiguration mediumtext " );

    # Migrate the tax overrides of skus into the tax configuration column.
    # Don't use getLineage because this has to be done for each revision.
    my $sth = $db->read( "select assetId, revisionDate, overrideTaxRate, taxRateOverride from sku" );
    while (my $row = $sth->hashRef) {
        my $config = {
            overrideTaxRate => $row->{ overrideTaxRate } || 0,
            taxRateOverride => $row->{ taxRateOverride } || 0,
        };

        $db->write( 'update sku set taxConfiguration=? where assetId=? and revisionDate=?', [
            to_json( $config ),
            $row->{ assetId },
            $row->{ revisionDate },
        ]);
    }
    $sth->finish;

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the ThingyRecord sku
sub installThingyRecord {
    my ( $session ) = shift;
    print "\tInstalling ThingyRecord sku... " unless $quiet;
    
    $session->config->addToHash('assets','WebGUI::Asset::Sku::ThingyRecord', {
        category        => "shop",
    });
    
    # Install ThingyRecord
    $session->db->write( <<'ENDSQL' );
    CREATE TABLE IF NOT EXISTS ThingyRecord (
        assetId CHAR(22) BINARY NOT NULL,
        revisionDate BIGINT NOT NULL,
        templateIdView CHAR(22) BINARY,
        thingId CHAR(22) BINARY,
        thingFields LONGTEXT,
        thankYouText LONGTEXT,
        price FLOAT,
        duration BIGINT,
        PRIMARY KEY (assetId, revisionDate)
    );
ENDSQL

    # Install collateral
    use WebGUI::AssetCollateral::Sku::ThingyRecord::Record;
    WebGUI::AssetCollateral::Sku::ThingyRecord::Record->crud_createTable($session);

    # Update workflow
    my $activityClass   = 'WebGUI::Workflow::Activity::ExpirePurchasedThingyRecords';
    $session->config->addToArray( 'workflow/None', $activityClass );
    my $workflow    = WebGUI::Workflow->new( $session, 'pbworkflow000000000004' );
    my $activity    = $workflow->addActivity( $activityClass );
    $activity->set('title', "Expire Purchased Thingy Records");
    $activity->set('description', "Expire any expired thingy records. Send notifications of imminent expiration.");

    print "DONE!\n" unless $quiet;
}

sub addSurveyBackButtonColumn{
    my $session = shift;
    print "\tAdding allowBackBtn column to Survey table... " unless $quiet;
    $session->db->write("alter table Survey add column `allowBackBtn` TINYINT(3)");
    print "Done.\n" unless $quiet;
}

sub turnOffAdmin {
    my $session = shift;
    print "\tAdding admin off link to admin console." unless $quiet;
    $session->config->addToHash("adminConsole","adminConsoleOff", {
      "icon" => "adminConsoleOff.gif",
      "group" => "12",
      "uiLevel" => 1,
      "url" => "^PageUrl(\"\",op=switchOffAdmin);",
      "title" => "^International(12,WebGUI);"
   });
    print "OK\n" unless $quiet;
}

sub addGlobalHeadTags {
    my ( $session ) = @_;
    print "\tAdding Global HEAD tags setting... " unless $quiet;
    $session->setting->add('globalHeadTags','');
    print "OK\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub fixConfigs {
    my $session = shift;
    print "\tFixing misconfigurations... " unless $quiet;
    my $config = $session->config;
    $config->delete('workflow');
    $config->addToArray( 'workflowActivities/None', 'WebGUI::Workflow::Activity::ExpirePurchasedThingyRecords');
    $config->set('taxDrivers', [
        "WebGUI::Shop::TaxDriver::Generic",
        "WebGUI::Shop::TaxDriver::EU"
    ]);
    $config->set('macros/SpectreCheck', 'SpectreCheck');
    $config->set('assets/WebGUI::Asset::Sku::ThingyRecord', {
        category => 'shop',
    });
    $config->set('assets/WebGUI::Asset::Wobject::Carousel', {
        category => 'utilities',
    });

    print "Done.\n" unless $quiet;
}


sub installStoryManagerTables {
    my ($session) = @_;
    print "\tAdding Story Manager tables... " unless $quiet;
    my $db = $session->db;
    $db->write(<<EOSTORY);
CREATE TABLE Story (
    assetId      CHAR(22) BINARY NOT NULL,
    revisionDate BIGINT          NOT NULL,
    headline     CHAR(255),
    subtitle     CHAR(255),
    byline       CHAR(255),
    location     CHAR(255),
    highlights   TEXT,
    story        MEDIUMTEXT,
    photo        LONGTEXT,
    PRIMARY KEY ( assetId, revisionDate )
)
EOSTORY

    $db->write(<<EOARCHIVE);
CREATE TABLE StoryArchive (
    assetId               CHAR(22) BINARY NOT NULL,
    revisionDate          BIGINT          NOT NULL,
    storiesPerPage        INTEGER,
    groupToPost           CHAR(22) BINARY,
    templateId            CHAR(22) BINARY,
    storyTemplateId       CHAR(22) BINARY,
    editStoryTemplateId   CHAR(22) BINARY,
    keywordListTemplateId CHAR(22) BINARY,
    archiveAfter          INT(11),
    richEditorId          CHAR(22) BINARY,
    approvalWorkflowId    CHAR(22) BINARY DEFAULT 'pbworkflow000000000003',
    PRIMARY KEY ( assetId, revisionDate )
)
EOARCHIVE

    $db->write(<<EOTOPIC);
CREATE TABLE StoryTopic (
    assetId         CHAR(22) BINARY NOT NULL,
    revisionDate    BIGINT          NOT NULL,
    storiesPer      INTEGER,
    storiesShort    INTEGER,
    templateId      CHAR(22) BINARY,
    storyTemplateId CHAR(22) BINARY,
    PRIMARY KEY ( assetId, revisionDate )
)
EOTOPIC

    print "DONE!\n" unless $quiet;
}

sub sm_upgradeConfigFiles {
    my ($session) = @_;
    print "\tAdding Story Manager to config file... " unless $quiet;
    my $config = $session->config;
    $config->addToHash(
        'assets',
        'WebGUI::Asset::Wobject::StoryTopic' => {
            'category' => 'community'
        },
    );
    $config->addToHash(
        'assets',
        "WebGUI::Asset::Wobject::StoryArchive" => {
            "isContainer" => 1,
            "category" => "community"
        },
    );
    $config->addToArray('workflowActivities/None', 'WebGUI::Workflow::Activity::ArchiveOldStories');
    print "DONE!\n" unless $quiet;
}

sub sm_updateDailyWorkflow {
    my ($session) = @_;
    print "\tAdding Archive Old Stories to Daily Workflow... " unless $quiet;
    my $workflow = WebGUI::Workflow->new($session, 'pbworkflow000000000001');
    foreach my $activity (@{ $workflow->getActivities }) {
        return if $activity->getName() eq 'WebGUI::Workflow::Activity::ArchiveOldStories';
    }
    my $activity = $workflow->addActivity('WebGUI::Workflow::Activity::ArchiveOldStories');
    $activity->set('title',       'Archive Old Stories');
    $activity->set('description', 'Archive old stories, based on the settings of the Story Archives that own them');
    print "DONE!\n" unless $quiet;
}


sub addShipsSeparateToSku {
    my ($session) = @_;
    print "\tAdd shipsSeparate property to Sku... " unless $quiet;
    $session->db->write(<<EOSQL);
ALTER TABLE sku ADD COLUMN shipsSeparately tinyint(1) NOT NULL
EOSQL
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the template packer
# Pre-pack all templates
sub addTemplatePacking {
    my $session = shift;
    print "\tAdding template packing/minifying... " unless $quiet;
    $session->db->write("ALTER TABLE template ADD templatePacked LONGTEXT");
    $session->db->write("ALTER TABLE template ADD usePacked INT(1)");

    print "\n\t\tPre-packing all templates, this may take a while..." unless $quiet;
    my $sth = $session->db->read( "SELECT DISTINCT(assetId) FROM template" );
    while ( my ($assetId) = $sth->array ) {
        my $asset       = WebGUI::Asset::Template->new( $session, $assetId );
        next unless $asset;
        $asset->update({
            template        => $asset->get('template'),
            usePacked       => 0,
        });
    }

    print "\n\t\tAdding extra head tags packing..." unless $quiet;
    $session->db->write("ALTER TABLE assetData ADD extraHeadTagsPacked LONGTEXT");
    $session->db->write("ALTER TABLE assetData ADD usePackedHeadTags INT(1)");

    print "\n\t\tPre-packing all head tags, this may take a while..." unless $quiet;
    $sth = $session->db->read( "SELECT assetId FROM asset" );
    while ( my ($assetId) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        next unless $asset;
        $asset->update({
            extraHeadTags       => $asset->get('extraHeadTags'),
            usePackedHeadTags   => 0,
        });
    }

    print "\n\t\tAdding snippet packing..." unless $quiet;
    $session->db->write("ALTER TABLE snippet ADD snippetPacked LONGTEXT");
    $session->db->write("ALTER TABLE snippet ADD usePacked INT(1)");

    print "\n\t\tPre-packing all snippets, this may take a while..." unless $quiet;
    $sth = $session->db->read( "SELECT DISTINCT(assetId) FROM snippet" );
    while ( my ($assetId) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        next unless $asset;
        $asset->update({
            snippet         => $asset->get('snippet'),
            usePacked       => 0,
        });
    }

    print "\n\t... DONE!\n" unless $quiet;
}

sub sendWebguiStats {
    my $session = shift;
    print "\tAdding a workflow to allow users to take part in the WebGUI stats project..." unless $quiet;
    my $wf = WebGUI::Workflow->create($session, {
        type        => 'None',
        mode        => 'singleton',
        enabled     => 1,
        title       => 'Send WebGUI Stats',
        description => 'This workflow sends some information about your site to the central WebGUI statistics repository. No personal information is sent. The information is used to help determine the future direction WebGUI should take.',
        }, 'send_webgui_statistics');
    my $act = $wf->addActivity('WebGUI::Workflow::Activity::SendWebguiStats','send_webgui_statistics');
    $act->set('title', 'Send WebGUI Stats');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addMobileStyleTemplate {
    my $session = shift;
    print "\tAdding mobile style template field... " unless $quiet;
    $session->db->write(q{
        ALTER TABLE wobject ADD COLUMN mobileStyleTemplateId CHAR(22) BINARY DEFAULT 'PBtmpl0000000000000060'
    });
    $session->db->write(q{
        UPDATE wobject SET mobileStyleTemplateId = styleTemplateId
    });
    $session->db->write(q{
        ALTER TABLE Layout ADD COLUMN mobileTemplateId CHAR(22) BINARY DEFAULT 'PBtmpl0000000000000054'
    });
    $session->setting->add('useMobileStyle', 0);
    $session->config->set('mobileUserAgents', [
        'AvantGo',
        'DoCoMo',
        'Vodafone',
        'EudoraWeb',
        'Minimo',
        'UP\.Browser',
        'PLink',
        'Plucker',
        'NetFront',
        '^WM5 PIE$',
        'Xiino',
        'iPhone',
        'Opera Mobi',
        'BlackBerry',
        'Opera Mini',
        'HP iPAQ',
        'IEMobile',
        'Profile/MIDP',
        'Smartphone',
        'Symbian ?OS',
        'J2ME/MIDP',
        'PalmSource',
        'PalmOS',
        'Windows CE',
        'Opera Mini',
    ]);
    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
sub addListingsCacheTimeoutToMatrix{
    my $session = shift;
    print "\tAdding listingsCacheTimeout setting to Matrix table... " unless $quiet;
    $session->db->write("alter table Matrix add listingsCacheTimeout int(11) not null default 3600;");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addTemplateAttachmentsTable {
    my $session = shift;
    print "\tAdding template attachments table... " unless $quiet;
    my $create = q{
        CREATE TABLE template_attachments (
            templateId   CHAR(22) BINARY,
            revisionDate bigint(20),
            url          varchar(256),
            type         varchar(20),
            sequence     int(11),

            PRIMARY KEY (templateId, revisionDate, url)
        )
    };
    $session->db->write($create);
    print "Done.\n" unless $quiet;
}

sub reKeyTemplateAttachments {
    my $session = shift;
    print "\tChanging the key structure for the template attachments table... " unless $quiet;
    # and here's our code
    $session->db->write('ALTER TABLE template_attachments ADD COLUMN attachId CHAR(22) BINARY NOT NULL');
    my $rh = $session->db->read('select url, templateId, revisionDate from template_attachments');
    my $wh = $session->db->prepare('update template_attachments set attachId=? where url=? and templateId=? and revisionDate=?');
    while (my @key = $rh->array) {
        $wh->execute([$session->id->generate, @key ]);
    }
    $rh->finish;
    $wh->finish;
    $session->db->write('ALTER TABLE template_attachments DROP PRIMARY KEY');
    $session->db->write('ALTER TABLE template_attachments ADD PRIMARY KEY (attachId)');
    print "DONE!\n" unless $quiet;
}
#----------------------------------------------------------------------------
# Rollback usePacked. It should be carefully applied manually for now
sub revertUsePacked {
    my $session = shift;
    print "\tReverting use packed... " unless $quiet;
    my $iter    = WebGUI::Asset->getIsa( $session, 0, { returnAll => 1 } );
    ASSET: while ( 1 ) {
        my $asset = eval { $iter->() };
        if (my $e = Exception::Class->caught()) {
            warn "Problem with asset with assetId: ".$e->id."\n";
            next ASSET;
        }
        last ASSET unless $asset;
        $asset->update({ usePackedHeadTags => 0 });
        if ( $asset->isa('WebGUI::Asset::Template') || $asset->isa('WebGUI::Asset::Snippet') ) {
            $asset->update({ usePacked => 0 });
        }
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addShippingDrivers {
    my $session = shift;
    print "\tAdding columns for improved VAT number checking..." unless $quiet;
    $session->config->addToArray('shippingDrivers', 'WebGUI::Shop::ShipDriver::USPS');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addEuVatDbColumns {
    my $session = shift;
    print "\tAdding columns for improved VAT number checking..." unless $quiet;
    
    $session->db->write( 'alter table tax_eu_vatNumbers add column viesErrorCode int(3) default NULL' );

    print "Done\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addTransactionTaxColumns {
    my $session = shift;
    print "\tAdding columns for storing tax data in the transaction log..." unless $quiet;

    $session->db->write( 'alter table transactionItem add column taxRate decimal(6,3)' );
    $session->db->write( 'alter table transactionItem add column taxConfiguration mediumtext' );
    $session->db->write( 'alter table transactionItem change vendorPayoutAmount vendorPayoutAmount decimal (8,2) default 0.00' );

    print "Done\n" unless $quiet;

}

sub addDataFormColumns {
    my $session = shift;
    print "\tAdding column to store htmlArea Rich Editor in DataForm Table ..." unless $quiet;

    my $sth = $session->db->read( 'show columns in DataForm  where field = "htmlAreaRichEditor"' );
    if ($sth->rows() == 0) { # only add column if it is not already there
       $session->db->write( 'alter TABLE `DataForm` add column `htmlAreaRichEditor` varchar(22) default "**Use_Default_Editor**"' );
    }

    print "Done\n" unless $quiet;

}

#----------------------------------------------------------------------------
sub addSurveyFeedbackTemplateColumn {
    my $session = shift;
    print "\tAdding columns for Survey Feedback Template..." unless $quiet;
    $session->db->write("alter table Survey add column `feedbackTemplateId` char(22)");

    print "Done\n" unless $quiet;

}

#----------------------------------------------------------------------------
# Your sub here
sub installCopySender {
    my $session = shift;
    return if $session->setting->has('inboxCopySender');
    $session->setting->add('inboxCopySender',0);
}

sub installNotificationsSettings {
    my $session = shift;
    $session->setting->add('sendInboxNotificationsOnly', 0);
    $session->setting->add('inboxNotificationTemplateId', 'b1316COmd9xRv4fCI3LLGA');
}

sub installSMSUserProfileFields {
    my $session = shift;
    WebGUI::ProfileField->create(
        $session,
        'receiveInboxEmailNotifications',
        {
            label          => q!WebGUI::International::get('receive inbox emails','Message_Center')!,
            visible        => 1,
            required       => 0,
            protected      => 1,
            editable       => 1,
            fieldType      => 'yesNo',
            dataDefault    => 1,
        },
        4,
    );
    WebGUI::ProfileField->create(
        $session,
        'receiveInboxSmsNotifications',
        {
            label          => q!WebGUI::International::get('receive inbox sms','Message_Center')!,
            visible        => 1,
            required       => 0,
            protected      => 1,
            editable       => 1,
            fieldType      => 'yesNo',
            dataDefault    => 0,
        },
        4,
    );
}

sub installSMSSettings {
    my $session = shift;
    $session->setting->add('smsGateway', '');
}

sub upgradeSMSMailQueue {
    my $session = shift;
    $session->db->write('alter table mailQueue add column isInbox TINYINT(4) default 0');
}

#----------------------------------------------------------------------------
sub addPayDrivers {
    my $session = shift;
    print "\tAdding PayPal driver checking..." unless $quiet;
    $session->config->addToArray('paymentDrivers', 'WebGUI::Shop::PayDriver::PayPal::PayPalStd');
    print "DONE!\n" unless $quiet;
}

sub installSurveyTest {
    my $session = shift;
    print "\tInstall Survey test table, via Crud... " unless $quiet;
    use WebGUI::Asset::Wobject::Survey::Test;
    WebGUI::Asset::Wobject::Survey::Test->crud_createTable($session);
    print "DONE!\n" unless $quiet;
}

sub addCollaborationColumns {
    my $session = shift;
    print "\tAdding columns to store htmlArea Rich Editor and Filter Code for Replies in Collaboration Table ..." unless $quiet;

    my $sth = $session->db->read( 'show columns in Collaboration where field = "replyRichEditor"' );
    if ($sth->rows() == 0) { # only add columns if it hasn't been added already
       $session->db->write( 'alter TABLE `Collaboration` add column `replyRichEditor` varchar(22) default "PBrichedit000000000002"') ;
       $session->db->write( 'update `Collaboration` set `replyRichEditor` = `richEditor` ') ;
    }

   $sth = $session->db->read( 'show columns in Collaboration where field = "replyFilterCode"' );
    if ($sth->rows() == 0) { # only add columns if it hasn't been added already
       $session->db->write( 'alter TABLE `Collaboration` add column `replyFilterCode` varchar(30) default "javascript"') ;
       $session->db->write( 'update `Collaboration` set `replyFilterCode` = `filterCode` ') ;
    }

    print "Done\n" unless $quiet;

}

sub installFriendManagerSettings {
    my $session = shift;
    print "\tInstalling FriendManager into settings...";
    $session->setting->add('groupIdAdminFriends',         '3');
    $session->setting->add('fmViewTemplateId', '64tqS80D53Z0JoAs2cX2VQ');
    $session->setting->add('fmEditTemplateId', 'lG2exkH9FeYvn4pA63idNg');
    $session->setting->add('groupsToManageFriends',       '2');
    $session->setting->add('overrideAbleToBeFriend',       0);
    print "\tDone\n";
}

sub installFriendManagerConfig {
    my $session = shift;
    my $config  = $session->config;
    my $account = $config->get('account');
    my @classes = map { $_->{className} } @{ $account };
    return if isIn('WebGUI::Account::FriendManager', @classes);
    print "\tInstalling FriendManager into config file...";
    push @{ $account },
        {
            identifier => 'friendManager',
            title      => '^International(title,Account_FriendManager);',
            className  => 'WebGUI::Account::FriendManager',
        }
    ;
    $config->set('account', $account);
    print "\tDone\n";
}

sub removeDanglingOldRssAssets {
    my $session = shift;
    print "\tChecking for uses of RSSCapable...\n" unless $quiet;
    my $peek = $session->db->dbh->table_info(undef, undef, 'RSSCapable');
    if ($peek->fetchrow_hashref()) {
        my @rssCapableClasses = $session->db->buildArray('SELECT className FROM RSSCapable INNER JOIN asset ON RSSCapable.assetId=asset.assetId GROUP BY className');
        if (@rssCapableClasses) {
            warn "\t\tThis site is using the assets\n\t\t\t" . join(', ', @rssCapableClasses) . "\n\t\twhich use the RSSCapable class!  Support RSSCapable has been dropped and it will no longer be maintained.\n";
        }
        else {
            print "\t\tNot used, removing leftover assets, if any.\n" unless $quiet;
            $session->db->write(q|DELETE FROM assetData WHERE assetId IN (SELECT assetId FROM asset WHERE className="WebGUI::Asset::RssFromParent")|);
            $session->db->write(q|DELETE FROM asset WHERE className = "WebGUI::Asset::RssFromParent"|);
        }
    }
    print "\tDone.\n" unless $quiet;
}


#----------------------------------------------------------------------------
sub addUserControlWorkflows {
    my $session = shift;
    print "\tAdding Activate, Deactivate, Delete User workflow activities..." unless $quiet;
    $session->config->addToArray('workflowActivities/WebGUI::User', 'WebGUI::Workflow::Activity::ActivateUser');
    $session->config->addToArray('workflowActivities/WebGUI::User', 'WebGUI::Workflow::Activity::DeactivateUser');
    $session->config->addToArray('workflowActivities/WebGUI::User', 'WebGUI::Workflow::Activity::DeleteUser');
    print " Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub fixSMSUserProfileI18N {
    my $session = shift;
    print "\tFixing bad I18N in SMS user profile fields..." unless $quiet;
    my $field = WebGUI::ProfileField->new($session, 'receiveInboxEmailNotifications');
    my $properties = $field->get();
    $properties->{label} = q!WebGUI::International::get('receive inbox emails','WebGUI')!;
    $field->set($properties);

    $field = WebGUI::ProfileField->new($session, 'receiveInboxSmsNotifications');
    $properties = $field->get();
    $properties->{label} = q!WebGUI::International::get('receive inbox sms','WebGUI')!;
    $field->set($properties);

    print "Done\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addOgoneToConfig {
    my $session = shift;
    print "\tAdding Ogone payment plugin..." unless $quiet;

    $session->config->addToArray('paymentDrivers', 'WebGUI::Shop::PayDriver::Ogone');
    
    print "Done\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addUseEmailAsUsernameToSettings {
    my $session = shift;
    print "\tAdding webguiUseEmailAsUsername to settings " unless $quiet;

    $session->db->write("insert into settings (name, value) values ('webguiUseEmailAsUsername',0)");

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addRedirectAfterLoginUrlToSettings {
    my $session = shift;
    print "\tAdding redirectAfterLoginUrl to settings " unless $quiet;

    $session->db->write("insert into settings (name, value) values ('redirectAfterLoginUrl',NULL)");

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub alterVATNumberTable {
    my $session = shift;
    print "\tAdapting VAT Number table..." unless $quiet;

    $session->db->write('alter table tax_eu_vatNumbers change column approved viesValidated tinyint(1)');
    $session->db->write('alter table tax_eu_vatNumbers add column approved tinyint(1)');

    print "Done\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addSurveyTestResultsTemplateColumn {
    my $session = shift;
    print "\tAdding columns for Survey Test Results Template..." unless $quiet;
    my $sth = $session->db->read('describe Survey testResultsTemplateId');
    if (! defined $sth->hashRef) {
        $session->db->write("alter table Survey add column `testResultsTemplateId` char(22)");
    }

    print "Done\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub updateSurveyTest {
    my $session = shift;
    print "\tUpdate Survey test table, via Crud... " unless $quiet;
    use WebGUI::Asset::Wobject::Survey::Test;
    WebGUI::Asset::Wobject::Survey::Test->crud_updateTable($session);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub installFilePumpAdminGroup {
    my $session = shift;
    print "\tAdding FilePump admin group setting... " unless $quiet;
    ##Content Handler
    #if (! $session->setting->has('groupIdAdminFilePump')) {
        $session->setting->add('groupIdAdminFilePump','8');
        print "\tAdded FilePump admin group ... \n" unless $quiet;
    #}
    print "Done.\n" unless $quiet;
}
#----------------------------------------------------------------------------
sub addEmsScheduleColumns {
    my $session = shift;
    print "\tAdding columns for the EMS Schedule table..." unless $quiet;

    $session->db->write( 'alter table EventManagementSystem add column scheduleTemplateId char(22)' );
    $session->db->write( 'alter table EventManagementSystem add column scheduleColumnsPerPage integer' );

    print "Done\n" unless $quiet;

}


#----------------------------------------------------------------------------
sub installFilePumpHandler {
    my $session = shift;
    print "\tAdding FilePump content handler... " unless $quiet;
    ##Content Handler
    my $contentHandlers = $session->config->get('contentHandlers');
    $session->config->addToHash( 'macros',          { FilePump => 'FilePump' });
    my $handlers    = $session->config->get('contentHandlers');
    my $newHandlers = [];
    if (!isIn('WebGUI::Content::FilePump', @{ $handlers })) {
        foreach my $handler (@{ $handlers }) {
            if ($handler eq 'WebGUI::Content::Operation') {
                push @{ $newHandlers }, 'WebGUI::Content::FilePump';
            }
            push @{ $newHandlers }, $handler;
        }
    }
    else {
        $newHandlers = $handlers;
    }
    $session->config->set('contentHandlers', $newHandlers);

    ##Admin Console
    $session->config->addToHash('adminConsole', 'filePump', {
      "icon" => "filePump.png",
      "groupSetting" => "groupIdAdminFilePump",
      "uiLevel" => 5,
      "url" => "^PageUrl(\"\",op=filePump);",
      "title" => "^International(File Pump,FilePump);"
    });
    ##Setting for custom group
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub installFilePumpTable {
    my $session = shift;
    print "\tAdding FilePump database table via CRUD... " unless $quiet;
    WebGUI::FilePump::Bundle->crud_createTable($session);
    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Add the map asset
sub addMapAsset {
    my $session = shift;
    print "\tAdding Google Map asset..." unless $quiet;
    
    # Map asset
    $session->db->write(<<'ENDSQL');
CREATE TABLE IF NOT EXISTS Map (
    assetId CHAR(22) BINARY NOT NULL,
    revisionDate BIGINT NOT NULL,
    groupIdAddPoint CHAR(22) BINARY,
    mapApiKey TEXT,
    mapHeight CHAR(12),
    mapWidth CHAR(12),
    startLatitude FLOAT,
    startLongitude FLOAT,
    startZoom TINYINT UNSIGNED,
    templateIdEditPoint CHAR(22) BINARY,
    templateIdView CHAR(22) BINARY,
    templateIdViewPoint CHAR(22) BINARY,
    workflowIdPoint CHAR(22) BINARY,
    PRIMARY KEY (assetId, revisionDate)
);
ENDSQL

    # MapPoint asset
    $session->db->write(<<'ENDSQL');
CREATE TABLE IF NOT EXISTS MapPoint (
    assetId CHAR(22) BINARY NOT NULL,
    revisionDate BIGINT NOT NULL,
    latitude FLOAT,
    longitude FLOAT,
    website VARCHAR(255),
    address1 VARCHAR(255),
    address2 VARCHAR(255),
    city VARCHAR(255),
    state VARCHAR(255),
    zipCode VARCHAR(255),
    country VARCHAR(255),
    phone VARCHAR(255),
    fax VARCHAR(255),
    email VARCHAR(255),
    storageIdPhoto CHAR(22) BINARY,
    userDefined1 TEXT,
    userDefined2 TEXT,
    userDefined3 TEXT,
    userDefined4 TEXT,
    userDefined5 TEXT,
    PRIMARY KEY (assetId, revisionDate)
);
ENDSQL

    # Add to assets
    $session->config->addToHash( "assets", 'WebGUI::Asset::Wobject::Map', {
       "category" => "basic",
    });

    print "Done!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addMobileStyleConfig {
    my $session = shift;
    print "\tAdding mobile style user agents to config file... " unless $quiet;
    $session->config->set('mobileUserAgents', [
        'AvantGo',
        'DoCoMo',
        'Vodafone',
        'EudoraWeb',
        'Minimo',
        'UP\.Browser',
        'PLink',
        'Plucker',
        'NetFront',
        '^WM5 PIE$',
        'Xiino',
        'iPhone',
        'Opera Mobi',
        'BlackBerry',
        'Opera Mini',
        'HP iPAQ',
        'IEMobile',
        'Profile/MIDP',
        'Smartphone',
        'Symbian ?OS',
        'J2ME/MIDP',
        'PalmSource',
        'PalmOS',
        'Windows CE',
        'Opera Mini',
    ]);
    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Repack all templates since the packed columns may have been wiped out due to the bug.
sub repackTemplates {
    my $session = shift;

    print "\n\t\tRepacking all templates that use packing, this may take a while..." unless $quiet;
    my $sth = $session->db->read( "SELECT DISTINCT(assetId) FROM template where usePacked=1" );
    while ( my ($assetId) = $sth->array ) {
        my $asset       = WebGUI::Asset::Template->new( $session, $assetId );
        next unless $asset;
        $asset->update({
            template        => $asset->get('template'),
            usePacked       => 0,
        });
    }

    print "\n\t\tRepacking head tags in assets that use packing, this may take a while..." unless $quiet;
    $sth = $session->db->read( "SELECT distinct(assetId) FROM assetData where usePackedHeadTags=1" );
    while ( my ($assetId) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        next unless $asset;
        $asset->update({
            extraHeadTags       => $asset->get('extraHeadTags'),
            usePackedHeadTags   => 0,
        });
    }

    print "\n\t\tRepacking snippets that use packing, this may take a while..." unless $quiet;
    $sth = $session->db->read( "SELECT DISTINCT(assetId) FROM snippet where usePacked=1" );
    while ( my ($assetId) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        next unless $asset;
        $asset->update({
            snippet         => $asset->get('snippet'),
            usePacked       => 0,
        });
    }

    print "\n\t... DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addStoryPhotoWidth {
    my $session = shift;
    print "\tAdd a width parameter to the StoryManager... " unless $quiet;
    # and here's our code
    $session->db->write(<<EOSQL);
alter table StoryArchive add column photoWidth int(11)
EOSQL
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
    my $package = eval { WebGUI::Asset->getImportNode($session)->importPackage( $storage, { overwriteLatest => 1 } ); };

    if ($package eq 'corrupt') {
        die "Corrupt package found in $file.  Stopping upgrade.\n";
    }
    if ($@ || !defined $package) {
        die "Error during package import on $file: $@\nStopping upgrade\n.";
    }

    # Turn off the package flag, and set the default flag for templates added
    my $assetIds = $package->getLineage( ['self','descendants'] );
    for my $assetId ( @{ $assetIds } ) {
        my $asset   = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        if ( !$asset ) {
            print "Couldn't instantiate asset with ID '$assetId'. Please check package '$file' for corruption.\n";
            next;
        }
        my $properties = { isPackage => 0 };
        if ($asset->isa('WebGUI::Asset::Template')) {
            $properties->{isDefault} = 1;
        }
        $asset->update( $properties );
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
    print "\tUpdating packages.\n" unless ($quiet);
    addPackage( $session, 'packages-7.6.35-7.7.17/merged.wgpkg' );
}

#vim:ft=perl
