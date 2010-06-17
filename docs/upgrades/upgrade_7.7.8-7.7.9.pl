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
use WebGUI::Shop::AddressBook;


my $toVersion = '7.7.9';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
repackTemplates( $session );
deleteUnattachedAddressBooks( $session );
addDefaultPrivacySettings( $session );

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
sub addDefaultPrivacySettings {
    my $session = shift;
    print "\tAdding default privacy setting to profile fields..." unless $quiet;
    $session->db->write("alter table userProfileField add defaultPrivacySetting char(128);");
    $session->db->write("update userProfileField set defaultPrivacySetting = 'all' where profileCategoryId IN(2,3,6);");
    $session->db->write("update userProfileField set defaultPrivacySetting = 'none' where !(profileCategoryId IN(2,3,6));");
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
# Delete all AddressBooks where the userId does not exist in the users table
sub deleteUnattachedAddressBooks {
    my $session = shift;

    print "\n\t\tDelete all AddressBooks if the user for that book was deleted..." unless $quiet;
    my $sth = $session->db->read( "SELECT addressBookId FROM addressBook where userId NOT IN (SELECT userId FROM users)" );
    while ( my ($addressBookId) = $sth->array ) {
        my $book = WebGUI::Shop::AddressBook->new($session, $addressBookId);
        $book->delete;
    }

    print "\n\t... DONE!\n" unless $quiet;
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
