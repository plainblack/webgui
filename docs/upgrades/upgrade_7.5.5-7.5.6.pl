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


my $toVersion = '7.5.6';
my $quiet; # this line required


my $session = start(); # this line required

convertCacheToBinary($session);
addLayoutOrderSetting( $session );
installThingyAsset($session);

finish($session); # this line required


sub convertCacheToBinary {
    my $session = shift;
    print "\tConverting database cache to binary data.\n" unless ($quiet);
    $session->db->write('ALTER TABLE `cache` MODIFY COLUMN `content` mediumblob');
    $session->db->write('DELETE FROM `cache`');
}

##-------------------------------------------------
#sub exampleFunction {
#	my $session = shift;
#	print "\tWe're doing some stuff here that you should know about.\n" unless ($quiet);
#	# and here's our code
#}

#----------------------------------------------------------------------------
# Add a column to the Gallery
sub addLayoutOrderSetting {
    my $session     = shift;
    print "\tAdding Layout Order Setting... " unless $quiet;

    $session->db->write( q{
        ALTER TABLE Layout ADD COLUMN assetOrder varchar(20) default 'asc';
    } );
	$session->db->write( q{
		UPDATE Layout SET assetOrder='asc';
	});

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# Install the Thingy asset
sub installThingyAsset {
    my $session     = shift;
    print "\tInstalling Thingy asset..." unless $quiet;

    $session->db->write(<<'ENDSQL');
create table if not exists Thingy (
        assetId varchar(22) binary not null,
        revisionDate bigint not null,
        templateId varchar(22) not null,
        defaultThingId varchar(22),
        primary key (assetId, revisionDate)
        )
ENDSQL

    $session->db->write(<<'ENDSQL');
create table if not exists Thingy_things (
        assetId varchar(22) binary not null,
        thingId varchar(22) binary  not null,
        label varchar(255) not null,
        editScreenTitle varchar(255) not null,
        editInstructions text,
        groupIdAdd varchar(22) not null,
        groupIdEdit varchar(22) not null,
        saveButtonLabel varchar(255) not null,
        afterSave varchar(255) not null,
        editTemplateId varchar(22) not null,
        onAddWorkflowId varchar(22),
        onEditWorkflowId varchar(22),
        onDeleteWorkflowId varchar(22),
        groupIdView varchar(22) not null,
        viewTemplateId varchar(22) not null,
        defaultView varchar(255) not null,
        searchScreenTitle varchar(255) not null,
        searchDescription text,
        groupIdSearch varchar(22) not null,
        groupIdImport varchar(22) not null,
        groupIdExport varchar(22) not null,
        searchTemplateId varchar(22) not null,
        thingsPerPage int(11) not null default 25,
        sortBy varchar(22),
        display int(11),
        primary key (thingId)
        )
ENDSQL

    $session->db->write(<<'ENDSQL');
create table if not exists Thingy_fields (
        assetId varchar(22) binary not null,
        thingId varchar(22) binary not null,
        fieldId varchar(22) not null,
        sequenceNumber int(11) not null,
        dateCreated bigint(20) not null,
        createdBy varchar(22) not null,
        dateUpdated bigint(20) not null,
        updatedBy varchar(22) not null,
        label varchar(255) not null,
        fieldType varchar(255) not null,
        defaultValue varchar(255),
        possibleValues varchar(255),
        subText varchar(255),
        status varchar(255) not null,
        width int(11),
        height int(11),
        vertical smallint(1),
        extras varchar(255),
        display int(11),
        viewScreenTitle int(11),
        displayInSearch int(11),
        searchIn int(11),
        fieldInOtherThingId varchar(22),
        primary key (fieldId, thingId, assetId)
        )
ENDSQL

    $session->config->addToArray("assets","WebGUI::Asset::Wobject::Thingy");

    print "DONE!\n" unless $quiet;
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

