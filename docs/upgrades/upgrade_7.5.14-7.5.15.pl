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
use File::Path;

my $toVersion = '7.5.15';
my $quiet; # this line required


my $session = start(); # this line required

removeOldGalleryImport($session);
addMissingWorkflowActivities($session);

finish($session); # this line required

#----------------------------------------------------------------------------
sub addMissingWorkflowActivities {
    my $session = shift;
    print "\tAdding Request Approval and Wait Until workflow activities to config..." unless $quiet;
    $session->config->addToArray("workflowActivities/WebGUI::VersionTag", "WebGUI::Workflow::Activity::RequestApprovalForVersionTag::ByCommitterGroup");
    $session->config->addToArray("workflowActivities/WebGUI::VersionTag", "WebGUI::Workflow::Activity::RequestApprovalForVersionTag::ByLineage");
    $session->config->addToArray("workflowActivities/WebGUI::VersionTag", "WebGUI::Workflow::Activity::WaitUntil");
    print " Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeOldGalleryImport {
    my $session = shift;
    print "\tRemoving old gallery import mechanism... " unless $quiet;
    unlink "../../sbin/migrateCollabToGallery.pl";
    unlink "../../sbin/migrateFolderToGallery.pl";
    rmtree "../../lib/WebGUI/Utility";
    rmtree "../../t/Utility/Gallery";
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

