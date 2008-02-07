#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use lib "../../lib";
use strict;
use Getopt::Long;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Asset;


my $toVersion = "7.5.1"; # make this match what version you're going to
my $quiet; # this line required


my $session = start(); # this line required
removeOldPhotoGallery($session);
speedUp($session);
enhanceITransactLogging($session);
finish($session); # this line required


#-------------------------------------------------
sub speedUp {
	my $session = shift;
    print "\tSlight asset performance increase.\n" unless ($quiet);
    $session->db->write("alter table assetData add index assetId_status (assetId,status)");
}

#----------------------------------------------------------------------------
# Add more data to the transaction table
sub enhanceITransactLogging {
    my $session = shift;
    print "\tAdd additional ITransact data to the transaction table..." unless $quiet;
    $session->db->write('alter table transaction add column XID varchar(100) default null');
    $session->db->write('alter table transaction add column authcode varchar(100) default null');
    $session->db->write('alter table transaction add column message text default null');
    print "DONE!\n" unless $quiet;
}

#-------------------------------------------------
sub removeOldPhotoGallery {
	my $session = shift;
    print "\tRemoving CS Photo Gallery prototype.\n" unless ($quiet);
    my $gallery = WebGUI::Asset->newByDynamicClass($session, "pbproto000000000000001");
    if (defined $gallery) {
        $gallery->purge;
    }
}


# --------------- DO NOT EDIT BELOW THIS LINE --------------------------------

#----------------------------------------------------------------------------
# Add a package to the import node
sub addPackage {
    my $session     = shift;
    my $file        = shift;

    # Make a storage location for the package
    my $storage     = WebGUI::Storage->createTemp( $session );
    $storage->addFileFromFilesystem( $file );

    # Import the package into the import node
    my $package = WebGUI::Asset->getImportNode($session)->importPackage( $storage, { skipAutoCommit => 0 } );

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
    my $session = WebGUI::Session->open("../..",$configFile);
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

