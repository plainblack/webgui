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


my $toVersion = '7.10.1';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
uniqueProductLocations($session);
removeBadSpanishFile($session);

finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
sub uniqueProductLocations {
    my $session = shift;
    print "\tMake sure each Product revision has its own storage location... " unless $quiet;
    use WebGUI::Asset::Sku::Product;
    my $get_product = WebGUI::Asset::Sku::Product->getIsa($session);
    # and here's our code
    PRODUCT: while (1) {
        my $product = eval { $get_product->(); };
        next PRODUCT if Exception::Class->caught();
        last PRODUCT unless $product;
        next PRODUCT unless $product->getRevisionCount > 1;
        my $products = $product->getRevisions;
        ##We already have the first revision, so remove it.
        shift @{ $products };
        foreach my $property (qw/image1 image2 image3 brochure manual warranty/) {
            ##Check each property.  If there's a duplicate, then make copy of the storage location and update the older version.
            foreach my $revision (@{ $products }) {
                if ($revision->get($property) eq $product->get($property)) {
                    $product->_duplicateFile($revision, $property,);
                }
            }
        }
    }
    print "DONE!\n" unless $quiet;
}

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

    print "\tRepacking all templates, this may take a while..." unless $quiet;
    my $sth = $session->db->read( "SELECT assetId, revisionDate FROM template" );
    while ( my ($assetId, $revisionDate) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId, $revisionDate );
        next unless $asset;
        $asset->update({
            template        => $asset->get('template'),
        });
    }
    print "\t... DONE!\n" unless $quiet;

    print "\tRepacking head tags in all assets, this may take a while..." unless $quiet;
    $sth = $session->db->read( "SELECT assetId, revisionDate FROM assetData where usePackedHeadTags=1" );
    while ( my ($assetId, $revisionDate) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId, $revisionDate );
        next unless $asset;
        $asset->update({
            extraHeadTags       => $asset->get('extraHeadTags'),
        });
    }
    print "\t... DONE!\n" unless $quiet;

    print "\tRepacking all snippets, this may take a while..." unless $quiet;
    $sth = $session->db->read( "SELECT assetId, revisionDate FROM snippet" );
    while ( my ($assetId, $revisionDate) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId, $revisionDate );
        next unless $asset;
        $asset->update({
            snippet         => $asset->get('snippet'),
        });
    }

    print "\t... DONE!\n" unless $quiet;
}


#----------------------------------------------------------------------------
# Rename template variables
sub renameAccountMacroTemplateVariables {
    my $session = shift;

    print "\tRename Account Macro template variables..." unless $quiet;
    my $sth = $session->db->read( q|SELECT assetId, revisionDate FROM template where namespace="Macro/a_account"| );
    while ( my ($assetId, $revisionDate) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId, $revisionDate );
        next unless $asset;
        my $template = $asset->get('template');
        $template =~ s/account\.url/account_url/msg;
        $template =~ s/account\.text/account_text/msg;
        $asset->update({
            template        => $template,
        });
    }
    print "\t... DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Rename template variables
sub renameAdminToggleMacroTemplateVariables {
    my $session = shift;

    print "\tRename Admin Toggle Macro template variables..." unless $quiet;
    my $sth = $session->db->read( q|SELECT assetId, revisionDate FROM template where namespace="Macro/AdminToggle"| );
    while ( my ($assetId, $revisionDate) = $sth->array ) {
        my $asset       = WebGUI::Asset->newByDynamicClass( $session, $assetId, $revisionDate );
        next unless $asset;
        my $template = $asset->get('template');
        $template =~ s/toggle\.url/toggle_url/msg;
        $template =~ s/toggle\.text/toggle_text/msg;
        $asset->update({
            template        => $template,
        });
    }
    print "\t... DONE!\n" unless $quiet;
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
    repackTemplates( $session );
    renameAccountMacroTemplateVariables( $session );
    renameAdminToggleMacroTemplateVariables( $session );
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
