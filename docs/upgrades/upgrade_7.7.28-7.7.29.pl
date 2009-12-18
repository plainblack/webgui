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


my $toVersion = '7.7.29';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
recalculateMatrixListingStatistics( $session );
addEuTaxRecheckWorkflow( $session );

finish($session); # this line required


#----------------------------------------------------------------------------
sub addEuTaxRecheckWorkflow {
    my $session = shift;
 
    print "\tAdding EU Tax plugin VAT number recheck workflow..." unless $quiet;
 
    my $workflow = WebGUI::Workflow->create( $session, {
        title => 'Recheck unverified EU VAT numbers',
        description =>
            'Utility workflow that automatically rechecks VAT numbers that could not be checked when they were submitted',
        enabled => 1,
        type => 'None',
        mode => 'parallel',
    }, 'taxeurecheckworkflow01' );
    $workflow->addActivity( 'WebGUI::Workflow::Activity::RecheckVATNumber', 'taxeurecheckactivity01' );
 
    print "Done\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Describe what our function does
sub recalculateMatrixListingStatistics {
    my $session = shift;
    my $db      = $session->db;
    print "\tRecalculating Matrix Listing Statistics that were erased in the 7.7.28 upgrade.  This could take a long time... " unless $quiet;
    # and here's our code
    my $sumSth = $db->read('select assetId, listingId, countValue, category from MatrixListing_ratingSummary where countValue < 10');
    while (my ($assetId, $listingId, $countvalue, $category) = $sumSth->array) {
        my $sql     = "from MatrixListing_rating where listingId=? and category=?";
        my $sum     = $db->quickScalar("select sum(rating) $sql", [$listingId, $category]);
        my $count   = $db->quickScalar("select count(*) $sql",    [$listingId, $category]);
        
        my $half    = round($count/2);
        my $mean    = $sum / ($count || 1);
        my $median  = $db->quickScalar("select rating $sql order by rating limit $half,1",[$listingId, $category]);
        
        $db->write("replace into MatrixListing_ratingSummary 
            (listingId, category, meanValue, medianValue, countValue, assetId) 
            values (?,?,?,?,?,?)",[$listingId,$category,$mean,$median,$count,$assetId]);
 
    }
    $sumSth->finish;
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
