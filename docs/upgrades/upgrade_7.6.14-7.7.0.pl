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
use WebGUI::PassiveAnalytics::Rule;
use WebGUI::Utility;

my $toVersion = '7.7.0';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here

addAccountActivationTemplateToSettings( $session );
addGroupToAddToMatrix( $session );
addScreenshotTemplatesToMatrix( $session );
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

finish($session); # this line required


#----------------------------------------------------------------------------
sub addAccountActivationTemplateToSettings {
    my $session = shift;
    print "\tAdding account activation template to settings \n" unless $quiet;

    $session->db->write("insert into settings (name, value) values ('webguiAccountActivationTemplate','PBtmpl0000000000000016')");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addGroupToAddToMatrix {
    my $session = shift;
    print "\tAdding groupToAdd to Matrix table, if needed... \n" unless $quiet;
    my $sth = $session->db->read('describe Matrix groupToAdd');
    if (! defined $sth->hashRef) {
        $session->db->write("alter table Matrix add column groupToAdd char(22) default 2");
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addScreenshotTemplatesToMatrix {
    my $session = shift;
    print "\tAdding screenshot templates to Matrix table \n" unless $quiet;
    
    $session->db->write("alter table Matrix add screenshotsConfigTemplateId char(22);");
    $session->db->write("update Matrix set screenshotsConfigTemplateId = 'matrixtmpl000000000007';");
    $session->db->write("alter table Matrix add screenshotsTemplateId char(22);");
    $session->db->write("update Matrix set screenshotsTemplateId = 'matrixtmpl000000000006';");
    
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
    print "\tAdding Asset History content handler... \n" unless $quiet;
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

#----------------------------------------------------------------------------
# Add a package to the import node
sub addPackage {
    my $session     = shift;
    my $file        = shift;

    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = WebGUI::Asset->getImportNode($session)->importPackage( $storage, { overwriteLatest => 1 } );

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
