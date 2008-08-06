#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::Shop::PayDriver;

my $toVersion = '7.5.19';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
addNewInboxIndexes( $session );
updateAddressTable( $session );
addProductShipping( $session );
addGalleryImageDensity( $session );
updatePaymentDrivers( $session );
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
# Add the image density property to the Gallery
sub addGalleryImageDensity {
    my $session = shift;
    print "\tAdding Image Density to Gallery... " unless $quiet;
    
    $session->db->write(
        "ALTER TABLE Gallery ADD COLUMN imageDensity INT"
    );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Corrects the asset id of the default receipt email template for the PayDriver
sub updatePaymentDrivers{
    my $session = shift;

    #Grab all PaymentDriver id's.
    my @ids = $session->db->buildArray("select paymentGatewayId from paymentGateway");
    for my $id(@ids){
        my $paymentGateway = WebGUI::Shop::PayDriver->new($session,$id);
        my $options = $paymentGateway->get();
        my $needsUpdated = 0;
        if($options->{'receiptEmailTemplateId'} eq 'BMzuE91-XB8E-XGll1zpvA'){
            $options->{'receiptEmailTemplateId'} = 'bPz1yk6Y9uwMDMBcmMsSCg';
            $needsUpdated = 1;
        }
        if ( exists $options->{'groupToUse'} and !defined $options->{'groupToUse'}) {
            $options->{'groupToUse'} = 7; #Everyone
            $needsUpdated = 1;
        }
        if ( !exists $options->{'saleNotificationGroupId'} ) {
            $options->{'saleNotificationGroupId'} = 3; #Admins
            $needsUpdated = 1;
        }
        if ( !exists $options->{'enabled'} ) {
            $options->{'enabled'} = 1; #on
            $needsUpdated = 1;
        }
        if ($needsUpdated) {
            $paymentGateway->update($options);
        }
    }
}

#----------------------------------------------------------------------------
# Removes the name field and adds a firstName and lastName field
sub updateAddressTable {
    my $session = shift;
    print "\tUpdating TABLE address... " unless $quiet;
    $session->db->write("ALTER TABLE address DROP COLUMN name");
    $session->db->write("ALTER TABLE address ADD COLUMN firstName VARCHAR(35)  AFTER label, ADD COLUMN lastName VARCHAR(35)  AFTER firstName");
    print "\tDone.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Removes the name field and adds a firstName and lastName field
sub addProductShipping {
    my $session = shift;
    print "\tAdding shippingRequired to the Product table... " unless $quiet;
    $session->db->write("ALTER TABLE Product add COLUMN isShippingRequired INT(11)");
    print "\tDone.\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add new indexes to the inbox to make millions of messages possible
sub addNewInboxIndexes {
    my $session = shift;
    print "\tAdding new indexes to inbox. This may take a while... " unless $quiet;

    print "\n\t\tIndex on userId..." unless $quiet;
    $session->db->write( 
        "CREATE INDEX pb_userId ON inbox ( userId )"
    );

    print "\n\t\tIndex on groupId..." unless $quiet;
    $session->db->write(
        "CREATE INDEX pb_groupId ON inbox ( groupId )"
    );

    print "\n\t\tDONE!\n" unless $quiet;
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
    $session->db->write("insert into webguiVersion values (".$session->db->quote($toVersion).",'upgrade',".$session->datetime->time().")");
    return $session;
}

#-------------------------------------------------
sub finish {
    my $session = shift;
    updateTemplates($session);
    my $versionTag = WebGUI::VersionTag->getWorking($session);
    $versionTag->commit;
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

