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


my $toVersion = '7.10.27';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
fixMetaDataRevisionDates($session);
addPhotoHeightToStoryArchive($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
sub fixMetaDataRevisionDates {
    my $session = shift;
    print "\tCheck to see if metaData has bad revision dates... " unless $quiet;
    my $getMeta0 = $session->db->read(
        'SELECT fieldId, assetId, value from metaData_values where revisionDate=0'
    );
    my $getRevisionDates = $session->db->prepare(
        'select revisionDate from assetData where assetId=? order by revisionDate'
    );
    my $getMetaValue = $session->db->prepare(
        'select value from metaData_values where assetId=? and fieldId=? and revisionDate=?'
    );
    my $updateMetaValue = $session->db->prepare(
        'UPDATE metaData_values set value=? where assetId=? AND fieldId=? and revisionDate=?'
    );
    my $insertMetaValue = $session->db->prepare(
        'INSERT INTO metaData_values (assetId, fieldId, value, revisionDate) VALUES (?,?,?,?)'
    );
    ##Get each metaData_value entry
    METAENTRY: while (my $metaEntry = $getMeta0->hashRef) {
        $getRevisionDates->execute([$metaEntry->{assetId}]);
        ##Get all revisionDates for the asset in that entry
        REVISIONDATE: while (my ($revisionDate) = $getRevisionDates->array) {
            ##Find the metaData value for that revisionDate
            $getMetaValue->execute([$metaEntry->{assetId}, $metaEntry->{fieldId}, $revisionDate, ]);
            my ($metaValue) = $getMetaValue->array;
            ##If that matches the current entry, we're done with this revisionDate
            next REVISIONDATE if $metaValue eq $metaEntry->{value};
            ##It doesn't match, so we have to fix it.
            ##Update a bad entry
            if (defined $metaValue) {
                $updateMetaValue->execute([
                    @{$metaEntry}{qw/value assetId fieldId/}, $revisionDate,
                ]);
            }
            ##Insert a new one
            else {
                $insertMetaValue->execute([
                    @{$metaEntry}{qw/assetId fieldId value/}, $revisionDate,
                ]);
            }
        }
    }
    $getMeta0->finish;
    $getRevisionDates->finish;
    $getMetaValue->finish;
    $insertMetaValue->finish;
    $updateMetaValue->finish;
    $session->db->write('delete from metaData_values where revisionDate=0');
    print "DONE!\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Describe what our function does
sub addPhotoHeightToStoryArchive {
    my $session = shift;
    print "\tAdd Photo Height to the Story Manager... " unless $quiet;
    # and here's our code
    $session->db->write(<<EOSQL);
ALTER TABLE StoryArchive add column photoHeight INT(11);
EOSQL
    $session->db->write(<<EOSQL);
UPDATE StoryArchive set photoHeight=300
EOSQL
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

    print "\tUpgrading package $file\n" unless $quiet;
    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = eval {
        my $node = WebGUI::Asset->getImportNode($session);
        $node->importPackage( $storage, {
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
