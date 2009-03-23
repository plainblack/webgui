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


my $toVersion = '7.7.1';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
addWelcomeMessageTemplateToSettings( $session );
addStatisticsCacheTimeoutToMatrix( $session );

# image mods
addImageAnnotation($session);

# rss mods
addRssLimit($session);

finish($session); # this line required

sub addWelcomeMessageTemplateToSettings {
    my $session = shift;
    print "\tAdding welcome message template to settings \n" unless $quiet;

    $session->db->write("insert into settings values ('webguiWelcomeMessageTemplate', 'PBtmpl0000000000000015');");
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addRssLimit {
    my $session = shift;
    print "\tAdding rssLimit to RSSCapable table, if needed... \n" unless $quiet;
    my $sth = $session->db->read('describe RSSCapable rssCableRssLimit');
    if (! defined $sth->hashRef) {
        $session->db->write("alter table RSSCapable add column rssCableRssLimit integer");
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addImageAnnotation {
    my $session = shift;
    print "\tAdding annotations to imageAsset table, if needed... \n" unless $quiet;
    my $sth = $session->db->read('describe imageAsset annotations');
    if (! defined $sth->hashRef) {
        $session->db->write("alter table imageAsset add column annotations mediumtext");
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addStatisticsCacheTimeoutToMatrix{
    my $session = shift;
    print "\tAdding statisticsCacheTimeout setting to Matrix table... \n" unless $quiet;
    $session->db->write("alter table Matrix add statisticsCacheTimeout int(11) not null default 3600");
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
