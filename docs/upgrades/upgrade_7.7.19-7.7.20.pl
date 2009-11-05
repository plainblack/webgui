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
use WebGUI::Shop::Pay;
use WebGUI::Shop::PayDriver;

my $toVersion = '7.7.20';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
fixTemplateSettingsFromShunt($session);
addMatrixColumnDefaults($session);
resetShopNotificationGroup($session);

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
sub addMatrixColumnDefaults {
    my $session = shift;
    print "\tUpdate existing Matrixes with default values for maxComparisons... " unless $quiet;
    $session->db->write(q|UPDATE Matrix set maxComparisons=25           where maxComparisons           IS NULL|);
    $session->db->write(q|UPDATE Matrix set maxComparisonsGroupInt=25   where maxComparisonsGroupInt   IS NULL|);
    $session->db->write(q|UPDATE Matrix set maxComparisonsPrivileged=25 where maxComparisonsPrivileged IS NULL|);
    # and here's our code
    print "DONE!\n" unless $quiet;
}

sub fixTemplateSettingsFromShunt {
    my $session = shift;
    print "\tClear isPackage and set isDefault on recently imported templates... " unless $quiet;
    ASSET: foreach my $assetId (qw/PBtmpl0000000000000137 CarouselTmpl0000000002 aIpCmr9Hi__vgdZnDTz1jw
                                   2CS-BErrjMmESOtGT90qOg 2rC4ErZ3c77OJzJm7O5s3w pbtmpl0000000000000220
                                   pbtmpl0000000000000221 2gtFt7c0qAFNU3BG_uvNvg PBtmpl0000000000000081
                                   ThingyTmpl000000000001 PcRRPhh-0KfvLLNIPdxJTw g8W53Pd71uHB9pxaXhWf_A/) {
        my $asset = WebGUI::Asset->newByDynamicClass($session, $assetId);
        next ASSET unless $asset;
        $asset->update({
            isPackage => 0,
            isDefault => 1,
        });
    }
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#------------------------------------------------------------------------
sub resetShopNotificationGroup {
    my $session = shift;
    print "\tResetting the shop reciept notification group to Admins if it is set to Everyone... " unless $quiet;
    $session->db->write(q{update settings set value='3' where name='shopSaleNotificationGroupId' and value='7'});
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
