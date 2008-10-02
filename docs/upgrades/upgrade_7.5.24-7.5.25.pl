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
use WebGUI::Asset::Sku::Product;


my $toVersion = '7.5.25';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
repairBrokenProductSkus($session);
addDataFormDataIndexes($session);

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
sub repairBrokenProductSkus {
    my $session     = shift;
    print "\tRepairing broken Products that were imported... " unless $quiet;
    my $getAProduct = WebGUI::Asset::Sku::Product->getIsa($session);
    while (my $product = $getAProduct->()) {
        COLLATERAL: foreach my $collateral (@{ $product->getAllCollateral('variantsJSON') }) {
            next COLLATERAL unless exists $collateral->{sku};
            $collateral->{varSku} = $collateral->{sku};
            delete $collateral->{sku};
            $product->setCollateral('variantsJSON', 'variantId', $collateral->{variantId}, $collateral);
        }
    }
    print "DONE!\n" unless $quiet;
}

sub addDataFormDataIndexes {
    my $session     = shift;
    print "\tAssing indexes to DataForm entry table... " unless $quiet;
    $session->db->write('ALTER TABLE `DataForm_entry` ADD INDEX `assetId` (`assetId`)');
    $session->db->write('ALTER TABLE `DataForm_entry` ADD INDEX `assetId_submissionDate` (`assetId`, `submissionDate`)');
    print "Done.\n" unless $quiet;
}

sub fixShortAssetIds {
    print "\tFixing assets with short ids... " unless $quiet;
    my %assetIds = (
        'SQLReportDownload0001'     => 'SQLReportDownload00001',
        'UserListTmpl0000001'       => 'UserListTmpl0000000001',
        'UserListTmpl0000002'       => 'UserListTmpl0000000002',
        'UserListTmpl0000003'       => 'UserListTmpl0000000003',
    );
    while (my ($fromId, $toId) = each %assetIds) {
        $session->db->write('UPDATE `template` SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `assetData` SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `asset` SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `assetIndex` SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `template` SET `assetId`=? WHERE `assetId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `UserList` SET `templateId`=? WHERE `templateId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `SQLReport` SET `downloadTemplateId`=? WHERE `downloadTemplateId`=?', [$toId, $fromId])
    }
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

