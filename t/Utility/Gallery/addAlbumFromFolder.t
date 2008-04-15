# $vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Test the addAlbum* methods from the Gallery::Utility class
# 
#

use strict;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test;
use WebGUI::Asset;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode( $session ); 

# Add arguments to avoid autocommit workflows
my @addArgs         = ( undef, undef, { skipAutoCommitWorkflows => 1 } );

my @versionTags;
push @versionTags,  WebGUI::VersionTag->getWorking( $session );

# Generate a Gallery to import into
my $gallery;
my $album;

# Generate a folder to import
my $folder
    = $node->addChild({
        className       => 'WebGUI::Asset::Wobject::Folder',
    });

my @files;
for (0..2) { 
    push @files, $folder->addChild({
        className       => 'WebGUI::Asset::File::Image',
        menuTitle       => "menuTitle$_", 
        ownerUserId     => "3$_",
        synopsis        => "synopsis$_",
        title           => "title$_", # This is important. Used to detect which GalleryFile is from which File
        filename        => 'lamp.jpg',
    }, @addArgs);
    $files[-1]->getStorageLocation->addFileFromFilesystem(
        WebGUI::Test->getTestCollateralPath('lamp.jpg')
    );
}

# File to GalleryFile field mappings. Should be mostly the same
my %fileField  = (
    title       => "title",
    menuTitle   => "menuTitle",
    synopsis    => "synopsis",
    ownerUserId => "ownerUserId",
    filename    => "filename",
);

# Folder to GalleryAlbum field mappings.
my %folderField    = (
    title           => "title",
    menuTitle       => "menuTitle",
    description     => "description",
    createdBy       => 'createdBy',
    creationDate    => 'creationDate',
    ownerUserId     => 'ownerUserId',
    synopsis        => 'synopsis',
);

#----------------------------------------------------------------------------
# Tests

# 1 test for each file + file field tests
my $fileTests   = scalar @files * ( 3 + scalar keys %fileField );

# 1 test for each item in folderField
my $folderTests = scalar keys %folderField;

plan tests => 10 
            + $fileTests
            + $folderTests
            ; 

#----------------------------------------------------------------------------
# Test use
my $utility = 'WebGUI::Utility::Gallery';
use_ok($utility);

#----------------------------------------------------------------------------
# Test addAlbumFromFolder
$gallery        = $node->addChild({ className => 'WebGUI::Asset::Wobject::Gallery' });

ok( 
    !eval{ $utility->addAlbumFromFolder( "", $folder ); 1},
    "addAlbumFromFolder croaks if first argument is not a Gallery asset",
);

ok( 
    !eval{ $utility->addAlbumFromFolder( $gallery, "" ); 1},
    "addAlbumFromFolder croaks if second argument is not a Folder asset",
);

$utility->addAlbumFromFolder( $gallery, $folder );

is(
    scalar @{ $gallery->getAlbumIds }, 1,
    "addAlbumFromFolder creates a new album",
);

$album = WebGUI::Asset->newByDynamicClass( $session, $gallery->getAlbumIds->[0] );

is(
    $album->get('revisionDate'), $folder->get('revisionDate'),
    "addAlbumFromFolder creates album with same revisionDate as folder",
);

my $galleryUrl  = $gallery->get('url');
like(
    $album->get('url'), qr/^$galleryUrl/,
    "addAlbumFromFolder creates album with url that begins with gallery's url",
);

# 1 test for each field in %folderField
for my $oldField ( sort keys %folderField ) {
    is( $album->get( $folderField{ $oldField } ), $folder->get( $oldField ),
        "addAlbumFromFolder migrates Folder $oldField to GalleryAlbum $folderField{$oldField}",
    );
}

is(
    scalar @{ $album->getFileIds }, $folder->getChildCount,
    "addAlbumFromFolder adds one file for each File in the Folder",
);

# 4 tests for each file + fileField tests
my $albumUrl        = $album->get('url');
for my $fileId ( @{$album->getFileIds} ) {
    my $newFile = WebGUI::Asset->newByDynamicClass( $session, $fileId );

    # Find which File this was in the original Folder
    ( my $index )   = $newFile->get('title') =~ /title(\d+)/;
    my $oldFile     = $files[ $index ];

    for my $oldField ( sort keys %fileField ) {
        is ( $newFile->get( $fileField{ $oldField } ), $oldFile->get( $oldField ),
            "addAlbumFromFolder migrates File $oldField to GalleryFile $fileField{$oldField}",
        );
    }
    
    like(
        $newFile->get('url'), qr/^$albumUrl/,
        "addAlbumFromFolder add files with urls that begin with GalleryAlbum url",
    );
    isa_ok( $newFile->getStorageLocation, 'WebGUI::Storage', 'Storage location exists' );
    ok( $newFile->get('filename'), '"filename" property was set' );
    cmp_deeply( 
        $newFile->getStorageLocation->getFiles, superbagof($newFile->get('filename')), 
        "Storage location contains the filename"
    );
}


#----------------------------------------------------------------------------
# Cleanup
END {
    for my $tag ( @versionTags ) {
        $tag->rollback;
    }
}
