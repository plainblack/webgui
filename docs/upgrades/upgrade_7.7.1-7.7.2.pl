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


my $toVersion = '7.7.2';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here

recalculateMatrixListingMedianValue( $session );

finish($session); # this line required

#----------------------------------------------------------------------------
sub recalculateMatrixListingMedianValue{
    my $session = shift;
    print "\tRecalculating median value for Matrix Listing ratings... \n" unless $quiet;
    my $matrices   = WebGUI::Asset->getRoot($session)->getLineage(['descendants'],
        {
            statesToInclude     => ['published','trash','clipboard','clipboard-limbo','trash-limbo'],
            statusToInclude     => ['pending','approved','deleted','archived'],
            includeOnlyClasses  => ['WebGUI::Asset::Wobject::Matrix'],
            returnObjects       => 1,
        });

    for my $matrix (@{$matrices})
    {
        next unless defined $matrix;
    my %categories = keys %{$matrix->getCategories};
    my $listings = $session->db->read("select distinct listingId from MatrixListing_rating where assetId = ?"
        ,[$matrix->getId]);
        while (my $listing= $listings->hashRef){
        foreach my $category (%categories) {
            my $half = $session->db->quickScalar("select round((select count(*) from MatrixListing_rating where
listingId = ? and category = ?)/2)",[$listing->{listingId},$category]);
            my $medianValue = $session->db->quickScalar("select rating from MatrixListing_rating where listingId =?
and category =? order by rating limit $half,1;",[$listing->{listingId},$category]);
            $session->db->write("update MatrixListing_ratingSummary set medianValue = ? where listingId = ? and
category = ?",[$medianValue,$listing->{listingId},$category]);
        }
    }
    }
    print "Done.\n" unless $quiet;
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
