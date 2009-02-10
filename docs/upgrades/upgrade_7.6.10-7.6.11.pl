#!/usr/bin/env perl

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
use WebGUI::Asset::Wobject::GalleryAlbum;


my $toVersion = '7.6.11';
my $quiet; # this line required


my $session = start(); # this line required
hideGalleryAlbums($session);
removeBrokenWorkflowInstances($session);
undotBinaryExtensions($session);
removeProcessRecurringPaymentsFromConfig($session);
noSessionSwitch($session);

fixDottedAssetIds($session);  ##This one should run last
finish($session); # this line required


#----------------------------------------------------------------------------
sub noSessionSwitch {
    my $session = shift;
    print "\tAdding noSession switch to Workflow Instances..." unless $quiet;
    $session->db->write("alter table WorkflowInstance add column noSession boolean not null default 0");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeProcessRecurringPaymentsFromConfig {
    my $session = shift;
    print "\tRemoving old ProcessRecurringPayments workflow activity from config..." unless $quiet;

    $session->config->deleteFromArray('workflowActivities/None',
        'WebGUI::Workflow::Activity::ProcessRecurringPayments');

    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub hideGalleryAlbums {
    my $session = shift;
    print "\tHiding all Gallery Albums from Navigation... " unless $quiet;
    # and here's our code
    my $getAnAlbum = WebGUI::Asset::Wobject::GalleryAlbum->getIsa($session);
    while (my $album = $getAnAlbum->()) {
        $album->update({});  ##The album will do the hiding automatically now
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub undotBinaryExtensions {
    my $session = shift;
    print "\tRemoving dots from list of exportBinaryExtensions... " unless $quiet;
    # and here's our code
    my $extensions = $session->config->get('exportBinaryExtensions');
    my @newExtensions = map { s/\.//; $_ } @{ $extensions };
    $session->config->set('exportBinaryExtensions', \@newExtensions);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub fixDottedAssetIds {
    my $session = shift;
    print "\tRemoving dots from Asset IDs... " unless $quiet;
    my @assetIds = $session->db->buildArray("select distinct(assetId) from asset where assetId like '%.%'");
    my %assetIds = map { my $id = $_; $id =~ tr/./-/; $_ => $id } @assetIds;
    # and here's our code
    while (my ($fromId, $toId) = each %assetIds) {
        $session->db->write('UPDATE `assetData`  SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `asset`      SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `assetIndex` SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `wobject`    SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `Folder`     SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `Navigation` SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `FileAsset`  SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `ImageAsset` SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `snippet`    SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);

        $session->db->write('UPDATE `asset`      SET `parentId`=? WHERE `parentId`=?', [$toId, $fromId]);
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeBrokenWorkflowInstances {
    my $session = shift;
    print "\tRemove Workflow Instances whose Workflows have been deleted... " unless $quiet;
    # and here's our code
    my $instances = WebGUI::Workflow::Instance->getAllInstances($session);
    foreach my $instance (@{ $instances }) {
        my $workflow = $instance->getWorkflow;
        $instance->delete('skipNotify') if !defined $workflow;
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
