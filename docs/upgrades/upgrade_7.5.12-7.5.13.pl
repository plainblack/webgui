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


my $toVersion = '7.5.13';
my $quiet; # this line required


my $session = start(); # this line required

fixShop($session);
addSelectableProfileTemplates($session); 
addCouponThankYouMessage($session);
finish($session); # this line required



#----------------------------------------------------------------------------
sub fixShop {
    my $session = shift;
    print "\tFixing Shop properties.\n" unless $quiet;
    my $db = $session->db;
    $db->write("update EventManagementSystem set registrationStaffGroupId='3' where registrationStaffGroupId=''");
    my ($driverId) = $db->quickScalar("select paymentGatewayId from paymentGateway where className='WebGUI::Shop::PayDriver::ITransact'");
    $db->write("update transaction set paymentDriverId=?",[$driverId]);
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addSelectableProfileTemplates {
    my $session = shift;
    print "\tAdd selectable user profile templates.\n" unless $quiet;
    my $tmpl = $session->setting->get('viewUserProfileTemplate') || 'PBtmpl0000000000000052';
    $session->setting->remove('viewUserProfileTemplate');
    $session->setting->add('viewUserProfileTemplate', $tmpl);
    $tmpl = $session->setting->get('editUserProfileTemplate') || 'PBtmpl0000000000000051';
    $session->setting->remove('editUserProfileTemplate');
    $session->setting->add('editUserProfileTemplate', $tmpl);
}

#----------------------------------------------------------------------------
sub addCouponThankYouMessage {
    my $session = shift;
    print "\tAdding Thank You Message to Coupon table...\n" unless $quiet;
    $session->db->write('alter table FlatDiscount add column thankYouMessage mediumtext');
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
    updateTemplates($session);
    return $session;
}

#-------------------------------------------------
sub finish {
    my $session = shift;
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

