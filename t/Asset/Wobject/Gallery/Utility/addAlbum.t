# $vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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
use lib "$FindBin::Bin/../../../../../lib";
use lib "$FindBin::Bin/../../../../lib";
use Test::More;
use Test::Deep;
use WebGUI::Asset;
use WebGUI::Session;
use WebGUI::Test;

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

# Generate a collaboration system to import
my $collab      
    = $node->addChild({
        className       => 'WebGUI::Asset::Wobject::Collaboration',
    });

my @threads;
for (0..2) { 
    push @threads, $collab->addChild({
        className       => 'WebGUI::Asset::Post::Thread',
        content         => "content$_",
        menuTitle       => "menuTitle$_",
        ownerUserId     => "3$_",
        synopsis        => "synopsis$_",
        title           => "title$_",
        userDefined1    => "userDefined1$_",
        userDefined2    => "userDefined2$_",
        userDefined3    => "userDefined3$_",
        userDefined4    => "userDefined4$_",
        userDefined5    => "userDefined5$_",
    }, @addArgs);
    $threads[-1]->getStorageLocation->addFileFromFilesystem(
        WebGUI::Test->getTestCollateralPath('lamp.jpg')
    );
}

# Add a post to one of the threads, with an image
my @posts;
push @{$posts[0]}, $threads[0]->addChild({
    className       => 'WebGUI::Asset::Post',
    content         => "content00",
    menuTitle       => "menuTitle00",
    synopsis        => "synopsis00",
    title           => "title00",
    userDefined1    => "userDefined100",
    userDefined2    => "userDefined200",
    userDefined3    => "userDefined300",
    userDefined4    => "userDefined400",
    userDefined5    => "userDefined500",
}, @addArgs);
$posts[0][0]->getStorageLocation->addFileFromFilesystem(
    WebGUI::Test->getTestCollateralPath('lamp.jpg')
);

# Thread fields mapped to album fields that should be migrated
my %threadFields = (
    content         => "description",
    menuTitle       => "menuTitle",
    ownerUserId     => "ownerUserId",
    synopsis        => "synopsis",
    title           => "title",
    userDefined1    => "userDefined1",
    userDefined2    => "userDefined2",
    userDefined3    => "userDefined3",
    userDefined4    => "userDefined4",
    userDefined5    => "userDefined5",
);

#----------------------------------------------------------------------------
# Tests

# addAlbumFromThread adds 6 tests for $thread[0] and @{$posts[0]}
my $threadPostTests     = 6 * ( 1 + scalar @{ $posts[0] } );

# addAlbumFromThread adds 1 test for each field in %threadFields
my $threadFieldTests    = 1 * scalar keys %threadFields;

plan tests => 9 + $threadPostTests + $threadFieldTests;

#----------------------------------------------------------------------------
# Test use
my $utility = 'WebGUI::Asset::Wobject::Gallery::Utility';
use_ok($utility);

#----------------------------------------------------------------------------
# Test addAlbumFromThread
$gallery        = $node->addChild({ className => 'WebGUI::Asset::Wobject::Gallery' });

ok( 
    !eval{ $utility->addAlbumFromThread( "", $threads[0] ); 1},
    "addAlbumFromThread croaks if first argument is not a Gallery asset",
);

ok( 
    !eval{ $utility->addAlbumFromThread( $gallery, "" ); 1},
    "addAlbumFromThread croaks if second argument is not a Thread asset",
);

$utility->addAlbumFromThread( $gallery, $threads[0] );

is(
    scalar @{ $gallery->getAlbumIds }, 1,
    "addAlbumFromThread creates a new album",
);

$album = WebGUI::Asset->newByDynamicClass( $session, $gallery->getAlbumIds->[0] );

is(
    $album->get('revisionDate'), $threads[0]->get('revisionDate'),
    "addAlbumFromThread creates album with same revisionDate as thread",
);

my $galleryUrl  = $gallery->get('url');
like(
    $album->get('url'), qr/^$galleryUrl/,
    "addAlbumFromThread creates album with url that begins with gallery's url",
);

# 1 test for each field in %threadFields
for my $oldField ( sort keys %threadFields ) {
    is( $album->get( $threadFields{ $oldField } ), $threads[0]->get( $oldField ),
        "addAlbumFromThread migrates Thread $oldField to GalleryAlbum $threadFields{$oldField}",
    );
}

is(
    scalar @{ $album->getFileIds }, 2,
    "addAlbumFromThread adds one file for each attachment to the thread or posts of the thread",
);

# 6 tests for each post/file
# TODO: Test that post-to-file fields are migrated properly, but how?
my $albumUrl        = $album->get('url');
for my $fileId ( @{$album->getFileIds} ) {
    my $file = WebGUI::Asset->newByDynamicClass( $session, $fileId );
    is(
        $file->get('revisionDate'), $threads[0]->get('revisionDate'),
        "addAlbumFromThread adds files with same revisionDate as thread",
    );
    is(
        $file->get('ownerUserId'), $threads[0]->get('ownerUserId'),
        "addAlbumFromThread adds files with same ownerUserId as thread",
    );
    like(
        $file->get('url'), qr/^$albumUrl/,
        "addAlbumFromThread add files with urls that begin with GalleryAlbum url",
    );
    isa_ok( $file->getStorageLocation, 'WebGUI::Storage', 'Storage location exists' );
    ok( $file->get('filename'), '"filename" property was set' );
    cmp_deeply( 
        $file->getStorageLocation->getFiles, superbagof($file->get('filename')), 
        "Storage location contains the filename"
    );
}

#----------------------------------------------------------------------------
# Test addAlbumFromCollaboration
$gallery        = $node->addChild({ className => 'WebGUI::Asset::Wobject::Gallery' });

ok( 
    !eval{ $utility->addAlbumFromCollaboration( "", $collab ); 1},
    "addAlbumFromCollaboration croaks if first argument is not a Gallery asset",
);

ok( 
    !eval{ $utility->addAlbumFromCollaboration( $gallery, "" ); 1},
    "addAlbumFromCollaboration croaks if second argument is not a Collaboration asset",
);

$utility->addAlbumFromCollaboration( $gallery, $collab );

is(
    scalar @{ $gallery->getAlbumIds }, scalar @threads,
    "addAlbumFromCollaboration creates one album per thread",
);

#----------------------------------------------------------------------------
# Test addAlbumFromFilesystem
# TODO!!!

#----------------------------------------------------------------------------
# Cleanup
END {
    for my $tag ( @versionTags ) {
        $tag->rollback;
    }
}
