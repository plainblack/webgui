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
use WebGUI::Utility qw/isIn/;


my $toVersion = '7.7.5';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here

# Story Manager
installStoryManagerTables($session);
sm_upgradeConfigFiles($session);
sm_updateDailyWorkflow($session);

correctEventTemplateVariables($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

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
    my $activities = $config->get('workflowActivities');
    my $none = $activities->{None};
    if (!isIn('WebGUI::Workflow::Activity::ArchiveOldStories', @{ $none })) {
        unshift @{ $none }, 'WebGUI::Workflow::Activity::ArchiveOldStories';
    }
    $config->set('workflowActivities', $activities);
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

sub correctEventTemplateVariables {
    my ($session) = @_;
    print "\tCorrect Event Template Variables for URL actions... " unless $quiet;
    my $root = WebGUI::Asset->getRoot($session);
    my $getATemplate = $root->getLineageIterator(['descendants'], {
        returnObjects      => 1,
        includeOnlyClasses => ['WebGUI::Asset::Template'],
        joinClass          => 'WebGUI::Asset::Template',
        whereClause        => q!template.namespace = 'Calendar/Event' and template.parser='WebGUI::Asset::Template::HTMLTemplate'!,
    });

    TEMPLATE: while (my $templateAsset = $getATemplate->()) {
        print("\t\t Correcting ". $templateAsset->getTitle. "\n") unless $quiet;
        my $template = $templateAsset->get('template');
        $template =~ s{<tmpl_var url>\?func=edit}{<tmpl_var urlEdit>}isg;
        $template =~ s{<tmpl_var url>\?func=delete}{<tmpl_var urlDelete>}isg;
        $template =~ s{<tmpl_var url>\?print=1}{<tmpl_var urlPrint>}isg;
        $template =~ s{<tmpl_var url>\?type=list}{<tmpl_var urlList>}isg;
        $templateAsset->update({
            template => $template,
        });
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
