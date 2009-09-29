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
use WebGUI::Shop::Ship;
use WebGUI::Shop::ShipDriver;


my $toVersion = '7.7.11';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
setDefaultIcalInterval($session);
makeSurveyResponsesVersionAware($session);
addShipperGroupToUse($session);
shrinkSurveyJSON($session);

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
sub setDefaultIcalInterval {
    my $session = shift;
    print "\tSet default ICAL interval in older calendars... " unless $quiet;
    $session->db->write("UPDATE Calendar SET icalInterval = 7776000 where icalInterval is null or icalInterval = ''");
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addShipperGroupToUse {
    my $session = shift;
    print "\tAdd Group to Use for all existing shipping drivers... " unless $quiet;
    my $ship     = WebGUI::Shop::Ship->new($session);
    my $shippers = $ship->getShippers($session);
    foreach my $shipper (@{ $shippers }) {
        my $options = $shipper->get();
        $options->{groupToUse} = 7;
        $shipper->update($options);
    }
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub makeSurveyResponsesVersionAware {
    my $session = shift;
    print "\tAdding revisionDate column to Survey_response table...\n" unless $quiet;
    $session->db->write("alter table Survey_response add column revisionDate bigint(20) not null default 0");
    
    print "\tDefaulting revisionDate on existing responses to current latest revision... " unless $quiet;
    for my $assetId ($session->db->buildArray('select assetId from Survey_response')) {
        $session->db->write(<<END_SQL, [ $assetId, $assetId]);
update Survey_response 
set revisionDate = ( 
    select max(revisionDate)
    from Survey 
    where Survey.assetId = ?
    )
where Survey_response.assetId = ?
END_SQL
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub shrinkSurveyJSON {
    my $session = shift;
    print "\tCompressing surveyJSON column in Survey table (this may take some time)... " unless $quiet;
    my $sth = $session->db->read('select assetId, revisionDate from Survey');
    use WebGUI::Asset::Wobject::Survey;
    while (my ($assetId, $revision) = $sth->array) {
        my $survey = WebGUI::Asset->new($session, $assetId, 'WebGUI::Asset::Wobject::Survey', $revision);
        $survey->persistSurveyJSON;
    }
    print "DONE!\n" unless $quiet;
    
    print "\tOptimizing Survey table... " unless $quiet;
    $session->db->write('optimize table Survey');    
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

    return 1;
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
