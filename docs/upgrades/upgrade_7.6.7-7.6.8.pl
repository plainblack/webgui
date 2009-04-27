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
use WebGUI::Asset::File::GalleryFile;
use WebGUI::Shop::Pay;
use WebGUI::Shop::PayDriver;


my $toVersion = '7.6.8';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
setDefaultItransactCredentialTemplate($session);
hideGalleryPhotos($session);
addSubscriptionRedeemTemplateSetting($session);
reFixAccountMisspellings($session);
finish($session); # this line required


#----------------------------------------------------------------------------
# Describe what our function does
sub setDefaultItransactCredentialTemplate {
    my $session = shift;
    print "\tSet default ITransact Credentials template if it is not set... " unless $quiet;
    # and here's our code
    my $pay = WebGUI::Shop::Pay->new($session);
    my $drivers = $pay->getPaymentGateways($session);
    DRIVER: foreach my $driver (@{ $drivers }) {
        ##Only work on ITransact drivers
        next DRIVER unless $driver && $driver->className eq "WebGUI::Shop::PayDriver::ITransact";
        my $properties = $driver->get();
        ##And only ones that don't already have a template set
        next DRIVER if $properties->{credentialsTemplateId};
        $properties->{credentialsTemplateId} = 'itransact_credentials1';
        $driver->update($properties);
    }

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub addSubscriptionRedeemTemplateSetting {
    my $session = shift;
    print "\tAdd a field to the Subscription Asset so the user can select which Redeem Subscription code template to use... " unless $quiet;
    # and here's our code
    $session->db->write(<<EOSQL);
alter table Subscription add column redeemSubscriptionCodeTemplateId char(22) NOT NULL default ''
EOSQL
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Describe what our function does
sub hideGalleryPhotos {
    my $session = shift;
    print "\tSet the isHidden bit in all Photos so your navigations do not blow up... " unless $quiet;
    # and here's our code
    my $getAPhoto = WebGUI::Asset::File::GalleryFile->getIsa($session);
    while (my $photo = $getAPhoto->()) {
        $photo->update({isHidden => 1});
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
#Describe what our function does
sub reFixAccountMisspellings {
    my $session = shift;
    my $setting = $session->setting;
    print "\tFix misspellings in Account settings... " unless $quiet;
    # and here's our code
    $setting->add("profileViewTemplateId",   $setting->get('profileViewTempalteId')  );
    $setting->add("profileErrorTemplateId",  $setting->get('profileErrorTempalteId') );
    $setting->add("inboxLayoutTemplateId",   $setting->get('inboxLayoutTempalteId')  );
    $setting->add("friendsLayoutTemplateId", $setting->get('friendsLayoutTempalteId'));
    $setting->remove("profileViewTempalteId");
    $setting->remove("profileErrorTempalteId");
    $setting->remove("inboxLayoutTempalteId");
    $setting->remove("friendsLayoutTempalteId");
    print "DONE!\n" unless $quiet;
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
