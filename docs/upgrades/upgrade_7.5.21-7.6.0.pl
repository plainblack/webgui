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


my $toVersion = '7.6.0';
my $quiet; # this line required


my $session = start(); # this line required

addUrlToAssetHistory ( $session ); ##This sub MUST GO FIRST
removeDoNothingOnDelete( $session );
fixIsPublicOnTemplates ( $session );
addSortOrderToFolder( $session );
addLoginTimeStats( $session );
addEMSBadgeTemplate ( $session );
redirectChoice ($session);

finish($session); # this line required


#----------------------------------------------------------------------------
sub fixIsPublicOnTemplates {
    my $session = shift;
    $session->db->write('UPDATE `assetIndex` SET `isPublic` = 0 WHERE assetId IN (SELECT assetId FROM asset WHERE className IN ("WebGUI::Asset::RichEdit", "WebGUI::Asset::Snippet", "WebGUI::Asset::Template") )');
}

#----------------------------------------------------------------------------
sub addEMSBadgeTemplate {
    my $session = shift;
    print "\tAdding EMS Badge Template... " unless $quiet;
    $session->db->write('ALTER TABLE EMSBadge ADD COLUMN templateId VARCHAR(22) BINARY NOT NULL');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addUrlToAssetHistory {
    my $session = shift;
    print "\tAdding URL column to assetHistory" unless $quiet;
    $session->db->write('ALTER TABLE assetHistory ADD COLUMN url VARCHAR(255)');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addSortOrderToFolder {
    my $session = shift;
    print "\tAdding Sort Order to Folder... " unless $quiet;
    $session->db->write( 'alter table Folder add column sortOrder ENUM("ASC","DESC") DEFAULT "ASC"' );
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addLoginTimeStats {
    my $session     = shift;
    print "\tAdding login time statistics... " unless $quiet;
    $session->db->write( "alter table userLoginLog add column sessionId varchar(22)" );
    $session->db->write( "alter table userLoginLog add column lastPageViewed int(11)" );
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeDoNothingOnDelete {
    my $session = shift;
    print "\tRemoving 'Do Nothing On Delete workflow if not customized... " unless $quiet;
    my $workflow = WebGUI::Workflow->new($session, 'DPWwf20061030000000001');
    if ($workflow) {
        my $activities = $workflow->getActivities;
        if (@$activities == 0) {
            # safe to delete.
            for my $setting (qw(trashWorkflow purgeWorkflow changeUrlWorkflow)) {
                my $setValue = $session->setting->get($setting);
                if ($setValue eq 'DPWwf20061030000000001') {
                    $session->setting->set($setting, undef);
                }
            }
            $workflow->delete;
        }
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub redirectChoice {
    my $session = shift;
    print "\tGiving a user choice about which type of redirect they'd like to perform... " unless $quiet;
    $session->db->write("alter table redirect add column redirectType int not null default 302");
    print "DONE!\n" unless $quiet;
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

