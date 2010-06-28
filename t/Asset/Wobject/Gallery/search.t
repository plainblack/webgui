#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../lib";

# Test of the Gallery basic and advanced search. In non-live tests, the Gallery 
# search is accessed via the "search" method. Form parameters are passed in via
# the pseudo request object of the test session.

use Test::More; 
use Test::Deep;

use WebGUI::Test;       # Must use this before any other WebGUI modules
use WebGUI::Asset::Wobject::Gallery;
use WebGUI::Asset::Wobject::GalleryAlbum;
use WebGUI::Asset::File::GalleryFile::Photo;
use WebGUI::DateTime;
use WebGUI::Session;


#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);

$versionTag->set( { name=>"Gallery Search Test" } );
addToCleanup( $versionTag );

# Create gallery and a single album
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

my $album
    = $gallery->addChild({
        className       => "WebGUI::Asset::Wobject::GalleryAlbum",
        title           => "album",
        synopsis        => "synopsis2",
        keywords        => "group2",        
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
my $albumId = $album->getId;    

# Populate album with different photos    
my $photo1
    = $album->addChild({
        className       => "WebGUI::Asset::File::GalleryFile::Photo",
        title           => "photo1",
        synopsis        => "synopsis1",
        keywords        => "group1",
        location        => "Heidelberg",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
my $id1 = $photo1->getId;    
    
my $photo2
    = $album->addChild({
        className       => "WebGUI::Asset::File::GalleryFile::Photo",
        title           => "photo2",
        synopsis        => "synopsis2",
        keywords        => "group1",
        location        => "Mannheim",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
my $id2 = $photo2->getId;    

my $photo3
    = $album->addChild({
        className       => "WebGUI::Asset::File::GalleryFile::Photo",
        title           => "photo3",
        synopsis        => "synopsis1",
        keywords        => "group2",
        location        => "Mannheim",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
my $id3 = $photo3->getId;
    
# Commit all changes
$versionTag->commit;

# Make gallery default asset
$session->asset( $gallery );

# Define some general variables
my $result;


#----------------------------------------------------------------------------
# Tests
plan tests => 32;

#----------------------------------------------------------------------------
# Basic search

note( "Basic gallery search" );

# Search by title

my $hits = search( { basicSearch => "album" } );
# Basic search will behave differently from advanced search. The album and all 
# photos of the album will be returned, since the name of the album is added to
# index keywords of photos.
cmp_bag( $hits, [ $albumId, $id1, $id2, $id3 ], "Search for album entitled 'album' (basic search)" );

my $hits = search( { basicSearch => "photo1" } );
cmp_bag( $hits, [ $id1 ], "Search for photo entitled 'photo1' (basic search)" );

my $hits = search( { title => "photo4" } );
cmp_bag( $hits, [ ], "Search for non-existing photo entitled 'photo4' (basic search)" );

# Search by keywords

my $hits = search( { basicSearch => "group1" } );
cmp_bag( $hits, [ $id1, $id2 ], "Search for albums/photos with keywords 'group1' (basic search)" );

my $hits = search( { basicSearch => "group2" } );
cmp_bag( $hits, [ $albumId, $id3 ], "Search for albums/photos with keywords 'group2' (basic search)" );

# Search by description

my $hits = search( { basicSearch => "synopsis1" } );
cmp_bag( $hits, [ $id1, $id3 ], "Search for albums/photos with synopsis 'synopsis1' (basic search)" );

my $hits = search( { basicSearch => "synopsis2" } );
cmp_bag( $hits, [ $albumId, $id2 ], "Search for albums/photos with synopsis 'synopsis2' (basic search)" );


# Warning: Tried to use 'here' and 'there' as locations for the following test.
# For unknown reasons the test failed. It seems that these and possibly other
# keywords are either filtered out by MySQL and/or are reserved words. Needs to
# be checked!!!

my $hits = search( { basicSearch => "Mannheim" } );
cmp_bag( $hits, [ $id2, $id3 ], "Search for photos taken at location 'Mannheim' (basic search)" );

my $hits = search( { basicSearch => "Heidelberg" } );
cmp_bag( $hits, [ $id1 ], "Search for photos taken at location 'Heidelberg' (basic search)" );

# Search by multiple criteria

my $hits = search({ basicSearch => "group1 synopsis1" });
cmp_bag( $hits, [ $id1 ], "Search for photo with keywords 'group1' and synopsis 'synopsis1' (basic search)" );

my $hits = search({ basicSearch => "group2 Mannheim" });
cmp_bag( $hits, [ $id3 ], "Search for photo with keywords 'group2' and location 'Mannheim' (basic search)" );

my $hits = search({ basicSearch => "synopsis1 Mannheim" });
cmp_bag( $hits, [ $id3 ], "Search for photo with synopsis 'synopsis1' and location 'Mannheim' (basic search)" );


#----------------------------------------------------------------------------
# Advanced search

note( "Advanced gallery search" );

my $hits = search( { } );
cmp_bag( $hits, [ ], "Empty search (advanced search)" );

# Search by class

my $hits = search( { className => "WebGUI::Asset::File::GalleryFile::Photo" } );
cmp_bag( $hits, [ $id1, $id2, $id3 ], "Search for all photos (advanced search)" );

my $hits = search( { className => "WebGUI::Asset::Wobject::GalleryAlbum" } );
cmp_bag( $hits, [ $albumId ], "Search for all albums (advanced search)" );

# Search by date

my $oneYearAgo = WebGUI::DateTime->new( $session, time )->add( years => -1 )->epoch;
my $hits 
    = search({ 
        creationDate_after  => $oneYearAgo,
        creationDate_before => time(), 
    });
cmp_bag( $hits, [ $albumId, $id1, $id2, $id3 ], "Search by date, all included (advanced search)" );

my $hits 
    = search({ 
        creationDate_after  => time() + 1,
        creationDate_before => time() + 1,
    });
cmp_bag( $hits, [ ], "Search by date, all excluded (advanced search)" );

# Search by title

my $hits = search( { title => "album" } );
cmp_bag( $hits, [ $albumId ], "Search for album entitled 'album' (advanced search)" );

my $hits = search( { title => "photo1" } );
cmp_bag( $hits, [ $id1 ], "Search for photo entitled 'photo1' (advanced search)" );

my $hits = search( { title => "photo4" } );
cmp_bag( $hits, [ ], "Search for non-existing photo entitled 'photo4' (advanced search)" );

# Search by keywords

my $hits = search( { keywords => "group1" } );
cmp_bag( $hits, [ $id1, $id2 ], "Search for albums/photos with keywords 'group1' (advanced search)" );

my $hits = search( { keywords => "group2" } );
cmp_bag( $hits, [ $albumId, $id3 ], "Search for albums/photos with keywords 'group2' (advanced search)" );

my $hits = search( { keywords => "group3" } );
cmp_bag( $hits, [ ], "Search for non-existing albums/photos with keywords 'group3' (advanced search)" );

# Search by description

my $hits = search( { description => "synopsis1" } );
cmp_bag( $hits, [ $id1, $id3 ], "Search for albums/photos with synopsis 'synopsis1' (advanced search)" );

my $hits = search( { description => "synopsis2" } );
cmp_bag( $hits, [ $albumId, $id2 ], "Search for albums/photos with synopsis 'synopsis2' (advanced search)" );

my $hits = search( { description => "synopsis3" } );
cmp_bag( $hits, [ ], "Search for non-existing albums/photos with synopsis 'synopsis3' (advanced search)" );

# Search by location
# Warning: Tried to use 'here' and 'there' as locations for the following test.
# For unknown reasons the test failed. It seems that these and possibly other
# keywords are either filtered out by MySQL and/or are reserved words. Needs to
# be checked!!!

my $hits = search( { location => "Mannheim" } );
cmp_bag( $hits, [ $id2, $id3 ], "Search for photos taken at location 'Mannheim' (advanced search)" );

my $hits = search( { location => "Heidelberg" } );
cmp_bag( $hits, [ $id1 ], "Search for photos taken at location 'Heidelberg' (advanced search)" );

my $hits = search( { location => "Frankfurt" } );
cmp_bag( $hits, [ ], "Search for non-existing photos taken at location 'Frankfurt' (advanced search)" );

# Search by multiple criteria

my $hits 
    = search({ 
        keywords => "group1",
        description => "synopsis1",
    });
cmp_bag( $hits, [ $id1 ], "Search for photo with keywords 'group1' and synopsis 'synopsis1' (advanced search)" );

my $hits 
    = search({ 
        keywords => "group2",
        location => "Mannheim",
    });
cmp_bag( $hits, [ $id3 ], "Search for photo with keywords 'group2' and location 'Mannheim' (advanced search)" );

my $hits 
    = search({ 
        description => "synopsis1",
        location => "Mannheim",
    });
cmp_bag( $hits, [ $id3 ], "Search for photo with synopsis 'synopsis1' and location 'Mannheim' (advanced search)" );


#----------------------------------------------------------------------------
# search( formParams )
# Execute a search for photos and albums in the test gallery. 
#
# Accepts a hash ref as single parameter. All key/value pairs in the hash are 
# added as form parameters to the pseudo request object before the search is 
# executed. See the Gallery search method for valid form fields. 
#
# Returns a reference pointing an array containg the asset Ids of all hits.

sub search {
    my $formParams      = shift;
    my $hits = [];

    # Setup the mock request object
    $session->request->method( 'GET' );
    $session->request->setup_param( $formParams );
    
    # Call gallery search function
    my ( $paginator, $keywords ) = $gallery->search;
    # Return ref to empty array if search could not be executed
    return $hits unless $paginator;

    # Extract asset Ids from search results and compile array.
    for ( my $i = 1; $i <= $paginator->getNumberOfPages; $i++ ) {
        for my $result ( @{ $paginator->getPageData( $i ) } ) {            
            push @{ $hits }, $result->{ assetId };
        }
    }
    return $hits;
}
