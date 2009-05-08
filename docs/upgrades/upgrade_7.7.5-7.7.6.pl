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

my $toVersion = "7.7.6"; 
my $quiet; 

my $session = start(); 

# upgrade functions go here
addTemplateAttachmentsTable($session);
revertUsePacked( $session );
fixDefaultPostReceived($session);
addEuVatDbColumns( $session );
addTransactionTaxColumns( $session );

finish($session); 


#----------------------------------------------------------------------------
# Describe what our function does
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

sub addTemplateAttachmentsTable {
    my $session = shift;
    my $create = q{
        create table template_attachments (
            templateId   varchar(22),
            revisionDate bigint(20),
            url          varchar(256),
            type         varchar(20),
            sequence     int(11),

            primary key (templateId, revisionDate, url)
        )
    };
    $session->db->write($create);
}

#----------------------------------------------------------------------------
# Rollback usePacked. It should be carefully applied manually for now
sub revertUsePacked {
    my $session = shift;
    print "\tReverting use packed... " unless $quiet;
    my $iter    = WebGUI::Asset->getIsa( $session );
    while ( my $asset = $iter->() ) {
        $asset->update({ usePackedHeadTags => 0 });
        if ( $asset->isa('WebGUI::Asset::Template') || $asset->isa('WebGUI::Asset::Snippet') ) {
            $asset->update({ usePacked => 0 });
        }
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub fixDefaultPostReceived {
    my $session = shift;
    $session->db->write(<<EOSQL);
UPDATE Collaboration SET postReceivedTemplateId='default_post_received1' WHERE postReceivedTemplateId='default-post-received'
EOSQL
    $session->db->write(<<EOSQL);
ALTER TABLE Collaboration ALTER COLUMN postReceivedTemplateId SET DEFAULT 'default_post_received1'
EOSQL
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addEuVatDbColumns {
    my $session = shift;
    print "\tAdding columns for improved VAT number checking..." unless $quiet;

    $session->db->write( 'alter table tax_eu_vatNumbers add column viesErrorCode int(3) default NULL' );

    print "Done\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addTransactionTaxColumns {
    my $session = shift;
    print "\tAdding columns for storing tax data in the transaction log..." unless $quiet;

    $session->db->write( 'alter table transactionItem add column taxRate decimal(6,3)' );
    $session->db->write( 'alter table transactionItem add column taxConfiguration mediumtext' );
    $session->db->write( 'alter table transactionItem change vendorPayoutAmount vendorPayoutAmount decimal (8,2) default 0.00' );

    print "Done\n" unless $quiet;

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
