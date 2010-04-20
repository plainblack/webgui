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


my $toVersion = '7.9.3';
my $quiet; # this line required


my $session = start(); # this line required

reindexSiteForDefaultSynopsis( $session );
addTopLevelWikiKeywords( $session );
renameMapPointStateColumn( $session );

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
sub renameMapPointStateColumn {
    my $session = shift;
    print "\tRename the MapPoint column state to region... " unless $quiet;

    $session->db->write('ALTER TABLE MapPoint CHANGE state region char(35)');

    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
sub addTopLevelWikiKeywords {
    my $session = shift;
    print "\tAdding top level keywords page to WikiMaster... " unless $quiet;

    my $sth = $session->db->read('DESCRIBE `WikiMaster`');
    while (my ($col) = $sth->array) {
        if ($col eq 'topLevelKeywords') {
            print "Skipped.\n" unless $quiet;
            return;
        }
    }
    $session->db->write('ALTER TABLE WikiMaster ADD COLUMN topLevelKeywords LONGTEXT');

    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Reindex the site to clear out default synopsis
sub reindexSiteForDefaultSynopsis {
    my $session = shift;
    print "\tRe-indexing site to clear out default synopses... " unless $quiet;

    my $rs = $session->db->read("select assetId, className from asset where state='published'");
    my @searchableAssetIds;
    while (my ($id, $class) = $rs->array) {
        my $asset = WebGUI::Asset->new($session,$id,$class);
        if (defined $asset && $asset->get("state") eq "published" && ($asset->get("status") eq "approved" || $asset->get("status") eq "archived")) {
            $asset->indexContent;
            push (@searchableAssetIds, $id);
        }
    }

    # delete indexes of assets that are no longer searchable
    my $list = $session->db->quoteAndJoin(\@searchableAssetIds) if scalar(@searchableAssetIds);
    $session->db->write("delete from assetIndex where assetId not in (".$list.")") if $list;

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
