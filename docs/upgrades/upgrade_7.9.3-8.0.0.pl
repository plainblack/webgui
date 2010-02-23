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

use strict;
use File::Path qw/rmtree/;
use Getopt::Long;
use WebGUI::Paths -inc;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;


my $toVersion = "8.0.0"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required

moveMaintenance($session);
migrateToNewCache($session);

finish($session); # this line required


#----------------------------------------------------------------------------
sub migrateToNewCache {
    my $session = shift;
    print "\tMigrating to new cache " unless $quiet;
    rmtree "../../lib/WebGUI/Cache";
    unlink "../../lib/WebGUI/Workflow/Activity/CleanDatabaseCache.pm";
    unlink "../../lib/WebGUI/Workflow/Activity/CleanFileCache.pm";
    my $config = $session->config;
    $config->set("cacheServers", [ { "socket" => "/data/wre/var/memcached.sock", "host" => "127.0.0.1", "port" => "11211" } ]);
    $config->set("hotSessionFlushToDb", 600);
    $config->delete("disableCache");
    $config->delete("cacheType");
    $config->delete("fileCacheRoot");
    $config->deleteFromArray("workflowActivities/None", "WebGUI::Workflow::Activity::CleanDatabaseCache");
    $config->deleteFromArray("workflowActivities/None", "WebGUI::Workflow::Activity::CleanFileCache");
    my $db = $session->db;
    $db->write("drop table cache");
    $db->write("delete from WorkflowActivity where className in ('WebGUI::Workflow::Activity::CleanDatabaseCache','WebGUI::Workflow::Activity::CleanFileCache')");
    $db->write("delete from WorkflowActivityData where activityId in  ('pbwfactivity0000000002','pbwfactivity0000000022')");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub moveMaintenance {
    my $session = shift;
    print "\tMoving maintenance file " unless $quiet;
    unlink "../maintenance.html";
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
    my $package = eval { WebGUI::Asset->getImportNode($session)->importPackage( $storage ); };

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
    my $session = WebGUI::Session->open($configFile);
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
