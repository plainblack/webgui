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
use List::Util qw(first);

my $toVersion = '7.10.2';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
addBackgroundProcessTable($session);
installBackgroundProcessCleanup($session);

finish($session); # this line required

#----------------------------------------------------------------------------
# Creates a new table for tracking background processes
sub addBackgroundProcessTable {
    my $session = shift;
    my $db      = $session->db;
    my $sth     = $db->dbh->table_info('', '', 'BackgroundProcess', 'TABLE');
    return if ($sth->fetch);
    print "\tAdding BackgroundProcess table..." unless $quiet;
    my $sql = q{
        CREATE TABLE BackgroundProcess (
            id        CHAR(22),
            groupId   CHAR(22),
            status    LONGTEXT,
            error     TEXT,
            startTime BIGINT(20),
            endTime   BIGINT(20),
            finished  BOOLEAN DEFAULT FALSE,
            latch     BOOLEAN DEFAULT FALSE,

            PRIMARY KEY(id)
        );
    };
    $db->write($sql);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# install a workflow to clean up old background processes
sub installBackgroundProcessCleanup {
    my $session = shift;
    print "\tInstalling Background Process Cleanup workflow..." unless $quiet;
    my $class = 'WebGUI::Workflow::Activity::RemoveOldBackgroundProcesses';
    $session->config->addToArray('workflowActivities/None', $class);
    my $wf = WebGUI::Workflow->new($session, 'pbworkflow000000000001');
    my $a  = first { ref $_ eq $class } @{ $wf->getActivities };
    unless ($a) {
        $a = $wf->addActivity($class);
        $a->set(title => 'Remove Old Background Processes');
    };
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
