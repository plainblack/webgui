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
for (1..3) { 
    push @threads, $collab->addChild({
        className       => 'WebGUI::Asset::Post::Thread',
    }, @addArgs);
    $threads[-1]->getStorageLocation->addFileFromFilesystem(
        WebGUI::Test->getTestCollateralPath('lamp.jpg')
    );
}

# Add a post to one of the threads, with an image
my @posts;
push @{$posts[0]}, $threads[0]->addChild({
    className           => 'WebGUI::Asset::Post',
}, @addArgs);
$posts[0][0]->getStorageLocation->addFileFromFilesystem(
    WebGUI::Test->getTestCollateralPath('lamp.jpg')
);

#----------------------------------------------------------------------------
# Tests

# addAlbumFromThread tests $thread[0] and @{$posts[0]}
my $threadTests     = 4 * ( 1 + scalar @{ $posts[0] } );

plan tests => 9 + $threadTests;

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

is(
    scalar @{ $album->getFileIds }, 2,
    "addAlbumFromThread adds one file for each attachment to the thread or posts of the thread",
);

# 4 tests for each post/file
for my $fileId ( @{$album->getFileIds} ) {
    my $file = WebGUI::Asset->newByDynamicClass( $session, $fileId );
    is(
        $file->get('revisionDate'), $threads[0]->get('revisionDate'),
        "addAlbumFromThread adds files with same revisionDate as thread",
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
