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


my $toVersion = '7.6.1';
my $quiet; # this line required


my $session = start(); # this line required

addExportExtensionsToConfigFile($session);
fixShortAssetIds( $session );
addDataFormDataIndexes($session);
addThingyColumns( $session );
addCommentsAspect( $session );
addCommentsAspectToWiki( $session );

finish($session); # this line required

#----------------------------------------------------------------------------
sub addCommentsAspectToWiki {
    my $session = shift;
    print "\tAdding comments aspect to wiki..." unless $quiet;
    my $db = $session->db;
    my $pages = $db->read("select assetId,revisionDate from WikiPage");
    while (my ($id, $rev) = $pages->array) {
        $db->write("insert into assetAspectComments (assetId, revisionDate, comments, averageCommentRating) values (?,?,'[]',0)",[$id,$rev]);
    }
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub addCommentsAspect {
    my $session = shift;
    print "\tAdding comments asset aspect..." unless $quiet;
    $session->db->write("create table assetAspectComments (
        assetId char(22) binary not null,
        revisionDate bigint not null,
        comments mediumtext,
        averageCommentRating int,
        primary key (assetId, revisionDate)
        )");
    print "Done.\n" unless $quiet;
}


#----------------------------------------------------------------------------
# make sure each config file has the extensions to export as-is. however, if
# this system received a backport, leave the field as is.
sub addExportExtensionsToConfigFile {
    my $session = shift;
    print "\tAdding binary export extensions to config file... " unless $quiet;
    # skip if the field has been defined already by backporting
    return if defined $session->config->get('exportBinaryExtensions');

    # otherwise, set the field
    $session->config->set('exportBinaryExtensions',
        [ qw/.html .htm .txt .pdf .jpg .css .gif .png .doc .xls .xml .rss .bmp
        .mp3 .js .fla .flv .swf .pl .php .php3 .php4 .php5 .ppt .docx .zip .tar
        .rar .gz .bz2/ ] );
    print "Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub fixShortAssetIds {
    print "Fixing assets with short ids... " unless $quiet;
    my %assetIds = (
        'default_post_received'     => 'default_post_received1',
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
        $session->db->write('UPDATE `Collaboration` SET `postReceivedTemplateId`=? WHERE `postReceivedTemplateId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `UserList` SET `templateId`=? WHERE `templateId`=?', [$toId, $fromId]);
        $session->db->write('UPDATE `SQLReport` SET `downloadTemplateId`=? WHERE `downloadTemplateId`=?', [$toId, $fromId]);
    }
    print "Done.\n" unless $quiet;
}

sub addDataFormDataIndexes {
    my $session     = shift;
    print "\tAssing indexes to DataForm entry table... " unless $quiet;
    $session->db->write('ALTER TABLE `DataForm_entry` ADD INDEX `assetId` (`assetId`)');
    $session->db->write('ALTER TABLE `DataForm_entry` ADD INDEX `assetId_submissionDate` (`assetId`,`submissionDate`)');
    print "Done.\n" unless $quiet;
}

sub addThingyColumns {
    my $session     = shift;
    print "\tAdding exportMetaData and maxEntriesPerUser columns to Thingy_things table... " unless $quiet;
    $session->db->write('ALTER TABLE `Thingy_things` ADD exportMetaData int(11)');
    $session->db->write('ALTER TABLE `Thingy_things` ADD maxEntriesPerUser int(11)');
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
