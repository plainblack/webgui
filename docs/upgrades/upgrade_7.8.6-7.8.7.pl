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
use WebGUI::Workflow::Cron;
use WebGUI::Asset::Wobject::Collaboration;


my $toVersion = '7.8.7';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
clearOrphanedCSMailCronJobs($session);
deleteExtraCronJobsForCS($session);

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
sub clearOrphanedCSMailCronJobs {
    my $session = shift;
    print "\tClear orphaned csworkflow000000000001 Cron Jobs with no CS attached... " unless $quiet;
    my $crons = WebGUI::Workflow::Cron->getAllTasks($session);
    ##This section of code handles cron jobs created for CS'es where the revision of the
    ##CS with the cron has been deleted.
    CRON: foreach my $cron (@{ $crons }) {
        next CRON unless $cron->get('workflowId') eq 'csworkflow000000000001';
        my $assetId = $cron->get('parameters');
        my $asset   = WebGUI::Asset->newByDynamicClass($session, $assetId);
        next CRON if $asset;
        print "\n\t\tDeleting ".$cron->get('title') unless $quiet;
        $cron->delete;
    }
    print "\tDONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub deleteExtraCronJobsForCS {
    my $session = shift;
    print "\tGuarantee that each CS has one and only one Cron job.  Older jobs will be deleted... " unless $quiet;
    my $cses = WebGUI::Asset::Wobject::Collaboration->getIsa($session);
    CS: while( my $cs = $cses->() ) {
        my @cronIds = $session->db->buildArray('select distinct(getMailCronId) from Collaboration where assetId=?',[$cs->getId]);
        next CS unless @cronIds > 1;
        my @oldCronIds = grep { $_ ne $cs->get('getMailCronId') } @cronIds;
        CRON: foreach my $cronId (@oldCronIds) {
            my $cron = WebGUI::Workflow::Cron->new($session, $cronId);
            next CRON unless $cron;
            print "\n\t\tDeleting ".$cron->get('title') unless $quiet;
            $cron->delete;
        }
        $session->db->write('update Collaboration set getMailCronId=? where assetId=?', [$cs->get('getMailCronId'), $cs->getId]);
    }
    print "\tDONE!\n" unless $quiet;
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
