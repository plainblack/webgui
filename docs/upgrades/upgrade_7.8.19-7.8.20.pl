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


my $toVersion = '7.8.20';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
updateGroupGroupingsTable($session);
fixConvertUTCMacroName($session);
dropOldEMSTableColumn($session);

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
# Add keys and indicies to groupGroupings to help speed up group queries
sub updateGroupGroupingsTable {
    my $session = shift;
    print "\tAdding primary key and indicies to groupGroupings table... " unless $quiet;
    my $sth = $session->db->read('show create table groupGroupings');
    my ($field,$stmt) = $sth->array;
    $sth->finish;
    unless ($stmt =~ m/PRIMARY KEY/i) {
        $session->db->write("alter table groupGroupings add primary key (groupId,inGroup)");
    }
    unless ($stmt =~ m/KEY `inGroup`/i) {
        $session->db->write("alter table groupGroupings add index inGroup (inGroup)");
    }
    print "DONE!\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Describe what our function does
sub fixConvertUTCMacroName {
    my $session = shift;
    print "\tFix the name of the ConvertUTCToTZ macro in the config file... " unless $quiet;
    $session->config->deleteFromHash('macros', 'ConvertToUTC');
    $session->config->addToHash('macros', 'ConvertUTCToTZ', 'ConvertUTCToTZ');
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub dropOldEMSTableColumn {
    my $session = shift;
    print "\tDrop an old column from the EventMangementSystem table that is no longer used... " unless $quiet;
    $session->db->write(q|ALTER TABLE EventManagementSystem DROP COLUMN groupToApproveEvents|);
    # and here's our code
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
