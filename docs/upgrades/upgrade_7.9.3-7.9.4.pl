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
use WebGUI::Asset::WikiPage;
use WebGUI::Exception;
use WebGUI::Shop::Pay;


my $toVersion = '7.9.4';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
addWikiSubKeywords($session);
addSynopsistoEachWikiPage($session);
dropVisitorAddressBooks($session);
alterCartTable($session);
alterAddressBookTable($session);
addWizardHandler( $session );
addTemplateExampleImage( $session );
addPayDriverTemplates( $session );

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
# Add example images to templates
sub addTemplateExampleImage {
    my $session = shift;
    print "\tAdding example image field to template... " unless $quiet;

    $session->db->write( q{
        ALTER TABLE template ADD storageIdExample CHAR(22)
    } );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------

sub addWizardHandler {
    my ( $sesssion ) = @_;
    print "\tAdding WebGUI::Wizard... " unless $quiet;

    if ( !grep { $_ eq 'WebGUI::Content::Wizard' } @{$session->config->get('contentHandlers')} ) {
        # Find the place of Operation and add before
        my @handlers = ();
        for my $handler ( @{$session->config->get('contentHandlers')} ) {
            if ( $handler eq 'WebGUI::Content::Operation' ) {
                push @handlers, 'WebGUI::Content::Wizard';
            }
            push @handlers, $handler;
        }
        $session->config->set('contentHandlers',\@handlers);
    }

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addWikiSubKeywords {
    my $session = shift;
    print "\tAdd the WikiMaster sub-keywords table... " unless $quiet;
    # and here's our code
    $session->db->write(<<EOSQL);
CREATE TABLE IF NOT EXISTS WikiMasterKeywords (
    assetId CHAR(22) binary not null primary key,
    keyword CHAR(64),
    subkeyword CHAR(64)
)
EOSQL
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addSynopsistoEachWikiPage {
    my $session = shift;
    print "\tAdd a synopsis to each wiki page this may take a while... " unless $quiet;
    my $pager = WebGUI::Asset::WikiPage->getIsa($session);
    PAGE: while (1) {
       my $page = eval {$pager->()};
       next PAGE if Exception::Class->caught();
       last PAGE unless $page;
       my ($synopsis) = $page->getSynopsisAndContent(undef, $page->get('content'));
       $page->update({synopsis => $synopsis});
    }
    # and here's our code
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub dropVisitorAddressBooks {
    my $session = shift;
    print "\tDrop AddressBooks owned by Visitor... " unless $quiet;
    my $sth = $session->db->read(q|SELECT addressBookId FROM addressBook where userId='1'|);
    BOOK: while (my ($addressBookId) = $sth->array) {
        my $book = eval { WebGUI::Shop::AddressBook->new($session, $addressBookId); };
        next BOOK if Exception::Class->caught();
        $book->delete;
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub alterAddressBookTable {
    my $session = shift;
    print "\tDrop sessionId from the Address Book database table... " unless $quiet;
    # and here's our code
    $session->db->write("ALTER TABLE addressBook DROP COLUMN sessionId");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub alterCartTable {
    my $session = shift;
    print "\tAdd billing address column to the Cart table... " unless $quiet;
    # and here's our code
    $session->db->write("ALTER TABLE cart ADD COLUMN billingAddressId CHAR(22)");
    $session->db->write("ALTER TABLE cart ADD COLUMN gatewayId        CHAR(22)");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addPayDriverTemplates {
    my $session = shift;
    print "\tAdd templates to the Payment Drivers that need them... " unless $quiet;
    # and here's our code
    my $pay = WebGUI::Shop::Pay->new($session);
    my @gateways = @{ $pay->getPaymentGateways };
    GATEWAY: foreach my $gateway (@gateways) {
        next GATEWAY unless $gateway;
        my $properties = $gateway->get;
        if ($gateway->isa('WebGUI::Shop::PayDriver::Cash')) {
            $properties->{summaryTemplateId} = '30h5rHxzE_Q0CyI3Gg7EJw';
        }
        elsif ($gateway->isa('WebGUI::Shop::PayDriver::Ogone')) {
            $properties->{summaryTemplateId} = 'jysVZeUR0Bx2NfrKs5sulg';
        }
        elsif ($gateway->isa('WebGUI::Shop::PayDriver::PayPal::PayPalStd')) {
            $properties->{summaryTemplateId} = '300AozDaeveAjB_KN0ljlQ';
        }
        elsif ($gateway->isa('WebGUI::Shop::PayDriver::PayPal::ExpressCheckout')) {
            $properties->{summaryTemplateId} = 'GqnZPB0gLoZmqQzYFaq7bg';
        }
        else {
            die "Unknown payment driver type found.  Unable to automatically upgrade.\n";
        }
        $gateway->update($properties);
    }
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
