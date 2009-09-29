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
use List::MoreUtils qw/uniq/;

use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;


my $toVersion = '7.7.15';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
replacePayPalDriver($session);
addFieldPriceToThingyRecord( $session );
replaceUsageOfOldTemplates($session);

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
# Add the field price storage to ThingyRecord
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
        $session->db->write('UPDATE Navigation SET templateId=? where templateId=?', [$new, $old])
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
        $session->db->write('UPDATE Article SET templateId=? where templateId=?', [$new, $old])
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
        $session->db->write('UPDATE Layout SET templateId=? where templateId=?', [$new, $old])
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
