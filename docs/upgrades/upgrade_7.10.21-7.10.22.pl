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


my $toVersion = '7.10.22';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
addAuthorizePaymentDriver($session);

createAddressField($session);
addLinkedProfileAddress($session);

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
# Add the Authorize.net payment driver to each config file
sub addAuthorizePaymentDriver {
    my $session = shift;
    print "\tAdd the Authorize.net payment driver... " unless $quiet;
    # and here's our code
    $session->config->addToArray('paymentDrivers', 'WebGUI::Shop::PayDriver::CreditCard::AuthorizeNet');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addLinkedProfileAddress {
    my $session = shift;
    print "\tAdding linked profile addresses for existing users... " unless $quiet;

    my $users = $session->db->buildArrayRef( q{
        select userId from users where userId not in ('1','3')
    } );

    foreach my $userId (@$users) {
        #check to see if there is user profile information available
        my $u = WebGUI::User->new($session,$userId);
        #skip if user does not have any homeAddress fields filled in
        next unless (
            $u->profileField("homeAddress")
            || $u->profileField("homeCity")
            || $u->profileField("homeState")
            || $u->profileField("homeZip")
            || $u->profileField("homeCountry")
            || $u->profileField("homePhone")
        );

        #Get the address book for the user (one is created if it does not exist)
        my $addressBook = WebGUI::Shop::AddressBook->newByUserId($session,$userId);
        
        #Add the profile address for the user
        $addressBook->addAddress({
            label       => "Profile Address",
            firstName   => $u->profileField("firstName"),
            lastName    => $u->profileField("lastName"),
            address1    => $u->profileField("homeAddress"),
            city        => $u->profileField("homeCity"),
            state       => $u->profileField("homeState"),
            country     => $u->profileField("homeCountry"),
            code        => $u->profileField("homeZip"),
            phoneNumber => $u->profileField("homePhone"),
            email       => $u->profileField("email"),
            isProfile   => 1,
        });
    }

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub createAddressField {
    my $session = shift;

    #skip if field exists
    my $columns  = $session->db->buildArrayRef("show columns from address where Field='isProfile'");
    return if(scalar(@$columns));

    print "\tAdding profile link to Address... " unless $quiet;

    $session->db->write( q{
        alter table address add isProfile tinyint default 0
    } );

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
