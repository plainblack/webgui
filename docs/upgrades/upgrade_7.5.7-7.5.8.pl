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


my $toVersion = '7.5.8';
my $quiet; # this line required


my $session = start(); # this line required

# upgrade functions go here
removeOldGalleryColumns( $session );
moveColumnsToGalleryFile( $session );
moveCommentsToGalleryFile( $session );

finish($session); # this line required


##-------------------------------------------------
#sub exampleFunction {
#	my $session = shift;
#	print "\tWe're doing some stuff here that you should know about.\n" unless ($quiet);
#	# and here's our code
#}

#-------------------------------------------------
sub clearRSSCache {
    my $session = shift;
    print "\tClearing RSS feed cache..." unless $quiet;
    my $cache = WebGUI::Cache->new($session, '', 'RSS');
    $cache->flush;
    print " Done.\n" unless $quiet;
}

#----------------------------------------------------------------------------
sub removeOldGalleryColumns {
    my $session = shift;
    $session->db->write(
        "ALTER TABLE Gallery DROP COLUMN groupIdModerator"
    );
}

#----------------------------------------------------------------------------
# moveColumnsToGalleryFile 
# Move columns from Photo that are better handled under GalleryFile 
sub moveColumnsToGalleryFile {
    my $session = shift;
    print "\tMoving Photo columns to GalleryFile (its superclass)... " unless $quiet;
    
    # Add the galleryfile columns
    $session->db->write(q{
        CREATE TABLE GalleryFile (
            assetId VARCHAR(22) BINARY NOT NULL,
            revisionDate BIGINT NOT NULL,
            userDefined1 LONGTEXT,
            userDefined2 LONGTEXT,
            userDefined3 LONGTEXT,
            userDefined4 LONGTEXT,
            userDefined5 LONGTEXT,
            views BIGINT DEFAULT 0,
            friendsOnly INT(1) DEFAULT 0,
            rating INT(1) DEFAULT 0,
            PRIMARY KEY ( assetId, revisionDate )
        )
    });

    # Move Photo data to GalleryFile
    my $sth     = $session->db->read( "SELECT * FROM Photo" );
    while ( my %row = $sth->hash ) {
        $session->db->write( 
            q{ INSERT INTO GalleryFile ( 
                assetId, revisionDate, userDefined1, userDefined2, userDefined3, userDefined4, 
                userDefined5, views, friendsOnly, rating )
            VALUES ( ?, ?, ?, ?, ?, ?, ?, ?, ?, ? )
            },
            [ @row{ qw( assetId revisionDate userDefined1 userDefined2 userDefined3 userDefined4
                userDefined5 views friendsOnly rating ) } ],
        );
    }

    # Drop the photo columns
    $session->db->write( q{
        ALTER TABLE Photo 
            DROP COLUMN userDefined1, 
            DROP COLUMN userDefined2, 
            DROP COLUMN userDefined3,
            DROP COLUMN userDefined4,
            DROP COLUMN userDefined5,
            DROP COLUMN views,
            DROP COLUMN friendsOnly,
            DROP COLUMN rating
    } );

    print "DONE!\n" unless $quiet;
}

#----------------------------------------------------------------------------
# moveCommentsToGalleryFile 
# Move comments to a better-described table
sub moveCommentsToGalleryFile {
    my $session     = shift;
    print "\tMoving Photo_comment to GalleryFile_comment... " unless $quiet;

    $session->db->write( q{
        ALTER TABLE Photo_comment RENAME TO GalleryFile_comment
    } );

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

