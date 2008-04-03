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


my $toVersion = '7.5.9';
my $quiet; # this line required


my $session = start(); # this line required

addRichEditInlinePopup($session);
updateRichEditorButtons($session);
setPMFloatingDuration($session);

finish($session); # this line required


#----------------------------------------------------------------------------
#sub exampleFunction {
#    my $session = shift;
#    print "\tWe're doing some stuff here that you should know about... " unless $quiet;
#    # and here's our code
#    print "DONE!\n" unless $quiet;
#}

#----------------------------------------------------------------------------
sub setPMFloatingDuration {
    my $session = shift;
    print "\tChanging Project manager to use floating numbers for duration... " unless $quiet;
    $session->db->write('ALTER TABLE `PM_task` MODIFY `duration` FLOAT');
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addRichEditInlinePopup {
    my $session = shift;
    print "\tAdding inline popup column to Rich editor... " unless $quiet;
    $session->db->write("ALTER TABLE `RichEdit` ADD COLUMN `inlinePopups` INT(11) NOT NULL DEFAULT 0");
    print "Done!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub updateRichEditorButtons {
    my $session = shift;
    print "\tUpdate Rich Editor buttons... " unless $quiet;
    my $editors = WebGUI::Asset->getRoot($session)->getLineage(['descendants'], {
        includeOnlyClasses  => ['WebGUI::Asset::RichEdit'],
        returnObjects       => 1,
    });
    for my $editor (@$editors) {
        my %prop;
        for my $toolbar (qw(toolbarRow1 toolbarRow2 toolbarRow3)) {
            my $current = $editor->get($toolbar);
            $current =~ s/^insertImage$/wginsertimage/m;
            $current =~ s/^pagetree$/wgpagetree/m;
            $current =~ s/^collateral$/wgmacro/m;
            if ($current ne $editor->get($toolbar)) {
                $prop{$toolbar} = $current;
            }
        }
        if (%prop) {
            $editor->addRevision(\%prop);
        }
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

