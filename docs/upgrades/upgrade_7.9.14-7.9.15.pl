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


my $toVersion = '7.9.15';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
removeBadSpanishFile($session);
repackTemplates( $session );

finish($session); # this line required

#----------------------------------------------------------------------------
# Describe what our function does
sub removeBadSpanishFile {
    my $session = shift;
    print "\tRemove a bad Spanish translation file... " unless $quiet;
    use File::Spec;
    unlink File::Spec->catfile($webguiRoot, qw/lib WebGUi i18n Spanish .pm/);
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Repack all templates since the packed columns may have been wiped out due to the bug.
sub repackTemplates {
    my $session = shift;

    print "\n\t\tRepacking all templates, this may take a while..." unless $quiet;
    my $sth = $session->db->read( "SELECT assetId, revisionDate FROM template" );
    while ( my ($assetId, $revisionDate) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId, $revisionDate );
        next unless $asset;
        $asset->update({
            template        => $asset->get('template'),
        });
    }

    print "\n\t\tRepacking head tags in all assets, this may take a while..." unless $quiet;
    $sth = $session->db->read( "SELECT assetId, revisionDate FROM assetData where usePackedHeadTags=1" );
    while ( my ($assetId, $revisionDate) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId, $revisionDate );
        next unless $asset;
        $asset->update({
            extraHeadTags       => $asset->get('extraHeadTags'),
        });
    }

    print "\n\t\tRepacking all snippets, this may take a while..." unless $quiet;
    $sth = $session->db->read( "SELECT assetId, revisionDate FROM snippet" );
    while ( my ($assetId, $revisionDate) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId, $revisionDate );
        next unless $asset;
        $asset->update({
            snippet         => $asset->get('snippet'),
        });
    }

    print "\n\t... DONE!\n" unless $quiet;
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
