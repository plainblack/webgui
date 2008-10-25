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


my $toVersion = '7.6.2';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
repairManageWorkflows($session); 
addPreTextToThingyFields($session);
updateAddressBook($session);
changeDefaultPaginationInSearch($session);
upgradeToYui26($session);
addUsersOnlineMacro($session);
addProfileExtrasField($session);
addWorkflowToDataform( $session );
finish($session); # this line required

#----------------------------------------------------------------------------
sub upgradeToYui26 {
    my $session = shift;
    print "\tUpgrading to YUI 2.6... " unless $quiet;
    $session->db->write("update template set template=replace(template, 'resize-beta.js', 'resize-min.js'), headBlock=replace(headBlock, 'resize-beta.js', 'resize-min.js')");
    $session->db->write("update template set template=replace(template, 'resize-beta-min.js', 'resize-min.js'), headBlock=replace(headBlock, 'resize-beta-min.js', 'resize-min.js')");
    $session->db->write("update template set template=replace(template, 'datasource-beta.js', 'datasource-min.js'), headBlock=replace(headBlock, 'datasource-beta.js', 'datasource-min.js')");
    $session->db->write("update template set template=replace(template, 'datasource-beta-min.js', 'datasource-min.js'), headBlock=replace(headBlock, 'datasource-beta-min.js', 'datasource-min.js')");
    $session->db->write("update template set template=replace(template, 'datatable-beta.js', 'datatable-min.js'), headBlock=replace(headBlock, 'datatable-beta.js', 'datatable-min.js')");
    $session->db->write("update template set template=replace(template, 'datatable-beta-min.js', 'datatable-min.js'), headBlock=replace(headBlock, 'datatable-beta-min.js', 'datatable-min.js')");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub changeDefaultPaginationInSearch {
    my $session = shift;
    print "\tAllow content managers to change the default pagination in the search asset... " unless $quiet;
    $session->db->write("ALTER TABLE `search` ADD COLUMN `paginateAfter` INTEGER  NOT NULL DEFAULT 25");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addUsersOnlineMacro {
    my $session = shift;
    print "\tMaking the UsersOnline macro available... " unless $quiet;
    $session->config->addToHash("macros","UsersOnline","UsersOnline");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub updateAddressBook {
    my $session = shift;
    print "\tAdding organization and email to address book... " unless $quiet;
    my $db = $session->db;
    $db->write("alter table address add column organization char(255)");
    $db->write("alter table address add column email char(255)");
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub repairManageWorkflows {
    my $session = shift;
    print "\tCorrecting the Manage Workflow link in configuration file... " unless $quiet;
    # and here's our code
    my $ac = $session->config->get('adminConsole');
    if (exists $ac->{'workflow'}) {
        $ac->{'workflow'}->{'url'} = "^PageUrl(\"\",op=manageWorkflows);";
        $session->config->set('adminConsole', $ac);
    }
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addPreTextToThingyFields {
    my $session = shift;
    print "\tAdding a pre-text property to Thingy fields... " unless $quiet;
    $session->db->write('ALTER TABLE `Thingy_fields` ADD pretext varchar(255)');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addProfileExtrasField {
    my $session = shift;
    print "\tAdding the Extras field for profile fields... " unless $quiet;
    my $db = $session->db;
    $db->write('alter table userProfileField add extras text default NULL');
    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Add the workflow property to DataForm
sub addWorkflowToDataform {
    my $session     = shift;
    print "\tAdding Workflow to DataForm... " unless $quiet;

    my $sth = $session->db->read('DESCRIBE `DataForm`');
    while (my ($col) = $sth->array) {
        if ( $col eq 'workflowIdAddEntry' ) {
            print "Already done, skipping.\n" unless $quiet;
            return;
        }
    }
     
    $session->db->write( "ALTER TABLE DataForm ADD COLUMN workflowIdAddEntry CHAR(22) BINARY" );
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
