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
use WebGUI::Asset::Wobject::Calendar;
use JSON;


my $toVersion = '7.7.19';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
addInboxSmsNotificationTemplateIdSetting($session);
upgradeJSONDatabaseFields($session); 
moveCalendarFeedsToJSON($session); 
addEmsScheduleColumnsDefaultValue($session);
removeOrphanedVersionTags( $session );
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
sub addEmsScheduleColumnsDefaultValue {
    my $session = shift;
    print "\tAdding default value for EMS Schedule Columns per Page..." unless $quiet;

    $session->db->write( 'UPDATE EventManagementSystem set scheduleColumnsPerPage=5 where scheduleColumnsPerPage IS NULL' );

    print "Done\n" unless $quiet;

}

sub addInboxSmsNotificationTemplateIdSetting {
    my $session = shift;
    print "\tAdding inboxSmsNotificationTemplateId setting... " unless $quiet;
    if (!$session->setting->has("inboxSmsNotificationTemplateId")) {
        $session->setting->add('inboxSmsNotificationTemplateId', 'i9-G00ALhJOr0gMh-vHbKA');
    }
    print "DONE!\n" unless $quiet;
}

sub upgradeJSONDatabaseFields {
    my $session = shift;
    print "\tUpgrading all fields which use JSON to LONGTEXT... " unless $quiet;
    print "\n\t\tUpgrading Sku fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE sku MODIFY taxConfiguration      LONGTEXT|);
    print "\n\t\tUpgrading Product fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE Product MODIFY variantsJSON      LONGTEXT|);
    $session->db->write(q|ALTER TABLE Product MODIFY accessoryJSON     LONGTEXT|);
    $session->db->write(q|ALTER TABLE Product MODIFY relatedJSON       LONGTEXT|);
    $session->db->write(q|ALTER TABLE Product MODIFY specificationJSON LONGTEXT|);
    $session->db->write(q|ALTER TABLE Product MODIFY featureJSON       LONGTEXT|);
    $session->db->write(q|ALTER TABLE Product MODIFY benefitJSON       LONGTEXT|);
    print "\n\t\tUpgrading DataForm fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE DataForm MODIFY fieldConfiguration  LONGTEXT|);
    $session->db->write(q|ALTER TABLE DataForm MODIFY tabConfiguration    LONGTEXT|);
    print "\n\t\tUpgrading DataForm entry fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE DataForm_entry MODIFY entryData     LONGTEXT|);
    print "\n\t\tUpgrading Scheduler fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE WorkflowSchedule MODIFY parameters  LONGTEXT|);
    print "\n\t\tUpgrading Workflow Instance fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE WorkflowInstance MODIFY parameters  LONGTEXT|);
    print "\n\t\tUpgrading AssetAspect Comments fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE assetAspectComments MODIFY comments LONGTEXT|);
    print "\n\t\tUpgrading Thingy Record fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE ThingyRecord MODIFY fieldPrice      LONGTEXT|);
    print "\n\t\tUpgrading Payment Gateway fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE paymentGateway MODIFY options       LONGTEXT|);
    print "\n\t\tUpgrading Shipping driver fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE shipper MODIFY options              LONGTEXT|);
    print "\n\t\tUpgrading Tax Driver fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE taxDriver MODIFY options            LONGTEXT|);
    print "\n\t\tUpgrading Transaction Item fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE transactionItem MODIFY options      LONGTEXT|);
    $session->db->write(q|ALTER TABLE transactionItem MODIFY taxConfiguration LONGTEXT|);
    print "\n\t\tUpgrading Cart Item fields... " unless $quiet;
    $session->db->write(q|ALTER TABLE cartItem MODIFY options             LONGTEXT|);
    print "DONE!\n" unless $quiet;
}

sub moveCalendarFeedsToJSON {
    my $session = shift;
    print "\tMoveing Calendar feeds from database collateral to JSON... " unless $quiet;
    $session->db->write(q|ALTER TABLE Calendar ADD COLUMN icalFeeds LONGTEXT|);
    my $getCalendar = WebGUI::Asset::Wobject::Calendar->getIsa($session, 0, { returnAll => 1 } );
    while (my $calendar = $getCalendar->()) {
        my $feeds = $session->db->buildHashRefOfHashRefs(
            "select * from Calendar_feeds where assetId=?",
            [$calendar->getId],
            "feedId"
        );
        foreach my $feedParams (values %{ $feeds }) {
            delete $feedParams->{assetId};
            $calendar->addFeed($feedParams);
        }
        ##Copy the JSON across all the revisions of this Calendar.
        my $jsonFeeds = $session->db->quickScalar('select icalFeeds from Calendar where assetId=? and revisionDate=?', [ $calendar->getId, $calendar->get('revisionDate')]);
        $session->db->write('update Calendar set icalFeeds=? where assetId=?', [$jsonFeeds, $calendar->getId]);
    }
    $session->db->write(q|DROP TABLE Calendar_feeds|);

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Remove the orphan version tags, tags with no revisions in them
sub removeOrphanedVersionTags {
    my $session = shift;
    print "\tRemoving orphan version tags (this may take a while)... " unless $quiet;
    
    # Get all Version Tag ids
    my %tags = map { $_ => 1 } @{$session->db->buildArrayRef("SELECT tagId FROM assetVersionTag")};
    #print "\nSite has " . keys(%tags) . " Version Tags in total\n" unless $quiet;
    
    # Get all Version Tags with associated assetData
    my %tags_with_data = map { $_ => 1 } @{$session->db->buildArrayRef("SELECT tagId FROM assetData")};
    #print "* " . keys(%tags_with_data) . " with associated assetData\n" unless $quiet;
    
    # Figure out the set of ophans
    my @orphans = grep { !$tags_with_data{$_} } keys %tags;
    #print "* " . scalar(@orphans) . " orphans\n" unless $quiet;
    
    # Sanity check
    if (keys(%tags) - keys(%tags_with_data) != scalar(@orphans)) { die "Something is broken in your Version Tag table" }

    # Remove the orphans
    my $count = 0;
    for my $tagId (@orphans) {
        
        # Progress
        if ($count % 100 == 0) { print '*' unless $quiet; }
        
        # Double-check on reduced set (remove to speed up even further)
        if ( $session->db->quickScalar("SELECT COUNT(*) FROM assetData WHERE tagId=?", [ $tagId ]) ) {
            die "Version Tag was supposed to be an orphan, but had assetData: $tagId";
        }
        
        my $tag = WebGUI::VersionTag->new( $session, $tagId );
        $tag->rollback;
        
        $count++;
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
