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

my $toVersion = '7.7.3';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here

addSurveyQuizModeColumns($session);
addSurveyExpressionEngineConfigFlag($session);
addCarouselWobject($session);
reInstallPassiveAnalyticsConfig($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

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
