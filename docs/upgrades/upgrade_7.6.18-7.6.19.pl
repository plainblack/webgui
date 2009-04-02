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
use WebGUI::Workflow;
use WebGUI::Utility;

my $toVersion = '7.6.19';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
addCreationTimeToCart($session);
addCartKillerActivityToConfig($session);
addCartKillerActivityToWorkflow($session);

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
sub addCreationTimeToCart {
    my $session = shift;
    print "\tAdding creation time to cart..." unless $quiet;
    $session->db->write("alter table cart add column creationDate int(20)");
    $session->db->write('update cart set creationDate=NOW()');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addCartKillerActivityToConfig {
    my $session = shift;
    print "\tAdding Remove Old Carts workflow activity to config files..." unless $quiet;
    my $activities = $session->config->get('workflowActivities');
    my $none = $activities->{'None'};
    if (!isIn('WebGUI::Workflow::Activity::RemoveOldCarts', @{ $none })) {
        push @{ $none }, 'WebGUI::Workflow::Activity::RemoveOldCarts';
    }
    $session->config->set('workflowActivities', $activities);
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addCartKillerActivityToWorkflow {
    my $session = shift;
    print "\tAdding Remove Old Carts workflow activity to Daily Workflow..." unless $quiet;
    my $workflow = WebGUI::Workflow->new($session, 'pbworkflow000000000001');
    my $removeCarts = $workflow->addActivity('WebGUI::Workflow::Activity::RemoveOldCarts');
    $removeCarts->set('title', 'Remove old carts');
    print "Done.\n" unless $quiet;
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
