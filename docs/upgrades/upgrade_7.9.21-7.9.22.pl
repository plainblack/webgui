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


my $toVersion = '7.9.22';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
convertCsMailInterval($session);

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
sub convertCsMailInterval {
    my $session = shift;
    print "\tConvert the getMailInterval from seconds to enumeration... " unless $quiet;
    # and here's our code
    $session->db->write('alter table Collaboration modify column getMailInterval char(64)');
    my $get_row    = $session->db->read('select assetId, revisionDate, getMailInterval from Collaboration');
    my $change_row = $session->db->prepare('update Collaboration set getMailInterval=? where assetId=? and revisionDate=?');
    while (my ($assetId, $revisionDate, $seconds ) = $get_row->array) {
        my $interval;
        if ($seconds <= 60) { $interval = 'every minute'; }
        elsif ($seconds <= 120)  { $interval = 'every other minute'; }
        elsif ($seconds <= 300)  { $interval = 'every 5 minutes'; }
        elsif ($seconds <= 600)  { $interval = 'every 10 minutes'; }
        elsif ($seconds <= 900)  { $interval = 'every 15 minutes'; }
        elsif ($seconds <= 1200) { $interval = 'every 20 minutes'; }
        elsif ($seconds <= 1800) { $interval = 'every 30 minutes'; }
        elsif ($seconds <= 3600) { $interval = 'every hour'; }
        elsif ($seconds <= 7200) { $interval = 'every other hour'; }
        else                     { $interval = 'once per day'; }
        $change_row->execute([$interval, $assetId, $revisionDate]);
    }
    $get_row->finish;
    $change_row->finish;
    print "DONE!\n" unless $quiet;
}


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
