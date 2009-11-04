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


my $toVersion = '7.8.4';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
dropSkipNotification($session);
addEMSSubmissionTables($session);
configEMSActivities($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}


#----------------------------------------------------------------------------
# Describe what our function does
sub configEMSActivities {
    my $session = shift;
    print "\tConfigure EMS Activities... " unless $quiet;
    my $config = $session->config;
    $config->addToArray('workflowActivities/None', 'WebGUI::Workflow::Activity::CleanupEMSSubmissions');
    $config->addToArray('workflowActivities/None', 'WebGUI::Workflow::Activity::ProcessEMSApprovals');
    my $workflow = WebGUI::Workflow->new($session, 'pbworkflow000000000001');  # Daily
    BREAK: { foreach my $activity (@{ $workflow->getActivities }) {
           last BREAK if $activity->getName() eq 'WebGUI::Workflow::Activity::CleanupEMSSubmissions';
       }
       my $activity = $workflow->addActivity('WebGUI::Workflow::Activity::CleanupEMSSubmissions');
       $activity->set('title',       'Purge Denied EMS Submissions');
       $activity->set('description', 'Purges EMS Submissions that were denied and are aged according to parameters.');
    } # end of BREAK block
    $workflow = WebGUI::Workflow->new($session, 'pbworkflow000000000004'); # Hourly
    BREAK: { foreach my $activity (@{ $workflow->getActivities }) {
           last BREAK if $activity->getName() eq 'WebGUI::Workflow::Activity::ProcessEMSApprovals';
       }
       my $activity = $workflow->addActivity('WebGUI::Workflow::Activity::ProcessEMSApprovals');
       $activity->set('title',       'Process Approves EMS Submissions');
       $activity->set('description', 'Create EMS Ticket Assets for approved submissions.');
    } # end of BREAK block
    print "DONE!\n" unless $quiet;
}


#----------------------------------------------------------------------------
# make database changes relevant to EMS Submission system
sub addEMSSubmissionTables {
    my $session = shift;
    print "\tCreate EMS Submission Tables... " unless $quiet;
    my $db = $session->db;

    $db->write(<<ENDSQL);
CREATE TABLE EMSSubmissionForm (
    assetId CHAR(22) BINARY NOT NULL,
    revisionDate BIGINT NOT NULL,
    canSubmitGroupId CHAR(22) BINARY,
    daysBeforeCleanup INT,
    deleteCreatedItems INT(1),
    formDescription TEXT,
    submissionDeadline Date,
    pastDeadlineMessage TEXT,
    PRIMARY KEY ( assetId, revisionDate )
)
ENDSQL

    $db->write(<<ENDSQL);
CREATE TABLE EMSSubmission (
    assetId CHAR(22) BINARY NOT NULL,
    revisionDate BIGINT NOT NULL,
    submissionId INT NOT NULL,
    submissionStatus CHAR(30),
    ticketId CHAR(22) BINARY,
    description mediumtext,
    sku char(35),
    vendorId char(22) BINARY,
    displayTitle tinyint(1),
    shipsSeparately tinyint(1),
    price FLOAT,
    seatsAvailable INT,
    startDate DATETIME,
    duration FLOAT,
    eventNumber INT,
    location CHAR(100),
    relatedBadgeGroups MEDIUMTEXT,
    relatedRibbons MEDIUMTEXT,
    eventMetaData MEDIUMTEXT,
    sendEmailOnChange INT(1),
    PRIMARY KEY ( assetId, revisionDate )
)
ENDSQL

    $db->write(<<ENDSQL);
    ALTER TABLE EventManagementSystem
            ADD COLUMN eventSubmissionTemplateId CHAR(22) BINARY;
ENDSQL

    $db->write(<<ENDSQL);
    ALTER TABLE EventManagementSystem
            ADD COLUMN eventSubmissionQueueTemplateId CHAR(22) BINARY;
ENDSQL

    $db->write(<<ENDSQL);
    ALTER TABLE EventManagementSystem
            ADD COLUMN eventSubmissionMainTemplateId CHAR(22) BINARY;
ENDSQL

    $db->write(<<ENDSQL);
    ALTER TABLE EventManagementSystem
            ADD COLUMN eventSubmissionGroups MEDIUMTEXT;
ENDSQL

    $db->write(<<ENDSQL);
    ALTER TABLE EventManagementSystem
            ADD COLUMN submittedLocationsList MEDIUMTEXT;
ENDSQL

    $db->write(<<ENDSQL);
    ALTER TABLE EventManagementSystem
            ADD COLUMN nextSubmissionId INT;
ENDSQL

    $db->write(<<ENDSQL);
    ALTER TABLE EMSEventMetaField
            ADD COLUMN helpText MEDIUMTEXT;
ENDSQL

    print "DONE!\n" unless $;
}


#------------------------------------------------------------------------
sub dropSkipNotification {
    my $session = shift;
    print "\tRemoving duplicate skipNotification field from the Subscribable aspect... " unless $quiet;
    $session->db->write('alter table assetAspect_Subscribable drop column skipNotification');
    print "Done.\n" unless $quiet;
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
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".time().")");
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
