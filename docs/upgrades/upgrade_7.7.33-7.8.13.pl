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
use WebGUI::Utility;


my $toVersion = "7.8.13"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
reorganizeAdSpaceProperties($session);
addSubscribableAspect( $session );
addFeaturedPageWiki( $session );
fixWikis( $session );
addVendorPayouts($session);
addEMSEnhancements($session);
installUPSDriver($session);
addClipboardAdminSetting($session);
addTrashAdminSetting($session);
addPickLanguageMacro($session);
installSetLanguage($session);
dropSkipNotification($session);
removeOldWebGUICSS($session);
addEMSSubmissionTables($session);
configEMSActivities($session);
addUSPSInternationalShippingDriver( $session );
deleteFieldFromEMSSubmission($session);

finish($session); # this line required

sub upgradeToYUI28 {
    my $session = shift;
    print "\tUpgrading to YUI 2.8... " unless $quiet;

    $session->db->write(
        "UPDATE template SET template = REPLACE(template, 'element-beta.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE template SET template = REPLACE(template, 'element-beta-min.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE template SET templatePacked = REPLACE(templatePacked, 'element-beta.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE template SET templatePacked = REPLACE(templatePacked, 'element-beta-min.js', 'element-min.js')"
    );

    $session->db->write(
        "UPDATE assetData SET extraHeadTags = REPLACE(extraHeadTags, 'element-beta.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTags = REPLACE(extraHeadTags, 'element-beta-min.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTagsPacked = REPLACE(extraHeadTagsPacked, 'element-beta.js', 'element-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTagsPacked = REPLACE(extraHeadTagsPacked, 'element-beta-min.js', 'element-min.js')"
    );

    $session->db->write(
        "UPDATE template SET template = REPLACE(template, 'carousel-beta.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE template SET template = REPLACE(template, 'carousel-beta-min.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE template SET templatePacked = REPLACE(templatePacked, 'carousel-beta.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE template SET templatePacked = REPLACE(templatePacked, 'carousel-beta-min.js', 'carousel-min.js')"
    );

    $session->db->write(
        "UPDATE assetData SET extraHeadTags = REPLACE(extraHeadTags, 'carousel-beta.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTags = REPLACE(extraHeadTags, 'carousel-beta-min.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTagsPacked = REPLACE(extraHeadTagsPacked, 'carousel-beta.js', 'carousel-min.js')"
    );
    $session->db->write(
        "UPDATE assetData SET extraHeadTagsPacked = REPLACE(extraHeadTagsPacked, 'carousel-beta-min.js', 'carousel-min.js')"
    );

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub reorganizeAdSpaceProperties {
    my $session = shift;
    print "\tReorganize AdSpace and Ad Sales properties... " unless $quiet;
    $session->db->write(q|ALTER TABLE adSpace DROP COLUMN costPerClick|);
    $session->db->write(q|ALTER TABLE adSpace DROP COLUMN costPerImpression|);
    $session->db->write(q|ALTER TABLE adSpace DROP COLUMN groupToPurchase|);
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add tables for the subscribable aspect
sub addSubscribableAspect {
    my $session = shift;
    print "\tAdding Subscribable aspect..." unless $quiet;

    $session->db->write( <<'ESQL' );
CREATE TABLE assetAspect_Subscribable (
    assetId CHAR(22) BINARY NOT NULL,
    revisionDate BIGINT NOT NULL,
    subscriptionGroupId CHAR(22) BINARY,
    subscriptionTemplateId CHAR(22) BINARY,
    skipNotification INT,
    PRIMARY KEY ( assetId, revisionDate )
)
ESQL

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the column for featured wiki pages
sub addFeaturedPageWiki {
    my $session = shift;
    print "\tAdding featured pages to the Wiki " unless $quiet;

    $session->db->write( 
        "ALTER TABLE WikiPage ADD COLUMN isFeatured INT(1)",
    );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub fixWikis {
    my $session = shift;
    print "\tFixing Wikis... " unless $quiet;
    $session->db->write('INSERT IGNORE INTO assetAspect_Subscribable (assetId, revisionDate) SELECT assetId, revisionDate FROM WikiMaster');
    $session->db->write('INSERT IGNORE INTO assetAspect_Subscribable (assetId, revisionDate) SELECT assetId, revisionDate FROM WikiPage');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addVendorPayouts {
    my $session = shift;
    print "\tAdding vendor payouts... " unless $quiet;
    my $db = $session->db;
    $db->write(" create table if not exists vendorPayoutLog (
        payoutId        char(22) binary not null primary key,
            isSuccessful    tinyint(1) not null,
                errorCode       char(10),
                    errorMessage    char(255),
                        paypalTimestamp char(20) not null,
                            amount          decimal(7,2) not null,
                                currency        char(3) not null,
                                    correlationId   char(13) not null,
                                        paymentInformation  char(255) not null
                                        )");
    $db->write(" create table if not exists vendorPayoutLog_items (
        payoutId            char(22) binary not null,
            transactionItemId   char(22) binary not null,
                amount              decimal(7,2) not null,
                    primary key( payoutId, transactionItemId )
                    )");

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addEMSEnhancements {
    my $session = shift;
    print "\tAdding EMS Enhancements, if needed... " unless $quiet;
    my $sth = $session->db->read('describe EventManagementSystem printRemainingTicketsTemplateId');
    if (! defined $sth->hashRef) {
        $session->db->write("alter table EventManagementSystem add column printRemainingTicketsTemplateId char(22) not null default 'hreA_bgxiTX-EzWCSZCZJw' after printTicketTemplateId");
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub installUPSDriver {
    my $session = shift;
    print "\tAdding UPS Shipping Driver... " unless $quiet;
    $session->config->addToArray('shippingDrivers', 'WebGUI::Shop::ShipDriver::UPS');

    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
sub addClipboardAdminSetting {
    my $session = shift;
    print "\tAdding clipboard admin setting... " unless $quiet;
    $session->setting->add('groupIdAdminClipboard', 3);
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addTrashAdminSetting {
    my $session = shift;
    print "\tAdding trash admin setting... " unless $quiet;
    $session->setting->add('groupIdAdminTrash', 3);
    print "Done.\n" unless $quiet;
}

#------------------------------------------------------------------------
sub addPickLanguageMacro {
    my $session = shift;
    print "\tAdding Pick Language macro... " unless $quiet;
    $session->config->set('macros/PickLanguage', 'PickLanguage');
    print "Done.\n" unless $quiet;
}

#------------------------------------------------------------------------
sub installSetLanguage {
    my $session = shift;
    print "\tAdding SetLanguage content handler... " unless $quiet;
    ##Content Handler
    my $contentHandlers = $session->config->get('contentHandlers');
    if (!isIn('WebGUI::Content::SetLanguage', @{ $contentHandlers }) ) {
        my @newHandlers = ();
        foreach my $handler (@{ $contentHandlers }) {
            push @newHandlers, $handler;
            push @newHandlers, 'WebGUI::Content::SetLanguage' if
                $handler eq 'WebGUI::Content::PassiveAnalytics';
        }
        $session->config->set('contentHandlers', \@newHandlers);
    }
    print "Done.\n" unless $quiet;
}

#------------------------------------------------------------------------
sub dropSkipNotification {
    my $session = shift;
    print "\tRemoving duplicate skipNotification field from the Subscribable aspect... " unless $quiet;
    $session->db->write('alter table assetAspect_Subscribable drop column skipNotification');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub removeOldWebGUICSS {
    my $session = shift;
    print "\tRemoving the old webgui.css file... " unless $quiet;
    my $snippet = WebGUI::Asset->newByDynamicClass($session, 'PcRRPhh-0KfvLLNIPdxJTw');
    if ($snippet) {
        $snippet->purge;
    }
    # and here's our code
    print "DONE!\n" unless $quiet;
}

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

sub addUSPSInternationalShippingDriver {
    my $session = shift;
    print "\tAdd the USPS International shipping driver... " unless $quiet;
    # and here's our code
    $session->config->addToArray('shippingDrivers', 'WebGUI::Shop::ShipDriver::USPSInternational');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Drop send mail on change collumn from ems submission table
sub deleteFieldFromEMSSubmission {
    my $session = shift;
    print "\tDrop collumn from EMS Submission Table... " unless $quiet;
    my $db = $session->db;

    $db->write(<<ENDSQL);
    ALTER TABLE EMSSubmission
            DROP COLUMN sendEmailOnChange;
ENDSQL

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# make database changes relevant to EMS Submission system
sub addEMSSubmissionTables {
    my $session = shift;
    print "\tCreate EMS Submission Tables... " unless $quiet;
    my $db = $session->db;

    $db->write(<<ENDSQL);
INSERT INTO incrementer (incrementerId,nextValue) VALUES ('submissionId',1);
ENDSQL

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
    ALTER TABLE EMSEventMetaField
            ADD COLUMN helpText MEDIUMTEXT;
ENDSQL

    print "DONE!\n" unless $quiet;
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
    my $package = eval {
        my $node = WebGUI::Asset->getImportNode($session);
        my $node->importPackage( $storage, {
            overwriteLatest    => 1,
            clearPackageFlag   => 1,
            setDefaultTemplate => 1,
        } );
    };

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
    upgradeToYUI28( $session );
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".time().")");
    $session->close();
}

#-------------------------------------------------
sub updateTemplates {
    my $session = shift;
    print "\tUpdating packages.\n" unless ($quiet);
    addPackage( $session, 'packages-7.7.33-7.8.13/merged.wgpkg' );
}

#vim:ft=perl
