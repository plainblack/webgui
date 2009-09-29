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
use WebGUI::ProfileField;
use List::MoreUtils qw/uniq/;

my $toVersion = '7.7.16';
my $quiet; # this line required


my $session = start(); # this line required
replaceUsageOfOldTemplatesAgain($session);
updatePayPalDriversAgain($session);
addThingyRecordFieldPriceDefaults($session);
correctProfileFieldColumnTypes($session);

# upgrade functions go here

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
sub correctProfileFieldColumnTypes {
    my $session = shift;
    my $config  = $session->config;
    print "\tCheck database profile field types against form settings..." unless $quiet;
    WebGUI::ProfileField->fixDataColumnTypes($session);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub updatePayPalDriversAgain {
    my $session = shift;
    my $config  = $session->config;
    print "\tUpdating paypal drivers in config file..." unless $quiet;
    my $old = 'WebGUI::Shop::PayDriver::PayPal';
    my @new = qw(
        WebGUI::Shop::PayDriver::PayPal::PayPalStd
        WebGUI::Shop::PayDriver::PayPal::ExpressCheckout
    );
    $config->deleteFromArray('paymentDrivers', $old);
    foreach my $n (@new) {
        $config->deleteFromArray('paymentDrivers', $n);
        $config->addToArray('paymentDrivers', $n) ;
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub replaceUsageOfOldTemplatesAgain {
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
    print "\n\t\tPurging old templates... " unless $quiet;
    my @oldTemplates = uniq(map { $_->[1] } (@navigationPairs));
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

#----------------------------------------------------------------------------
sub addThingyRecordFieldPriceDefaults {
    my $session = shift;
    print "\tAdd default fieldPrice JSON to ThingyRecord... " unless $quiet;
    # and here's our code
    $session->db->write(q|UPDATE ThingyRecord set fieldPrice='{}' where fieldPrice IS NULL|);
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
