# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# This script tests the edit and saving of Photo assets

use strict;

use Test::More;
use Test::Deep;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::Mechanize;
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Gallery;
use WebGUI::Asset::Wobject::GalleryAlbum;
use WebGUI::Asset::File::GalleryFile::Photo;
use WebGUI::VersionTag;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init

my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode( $session );

# Create version tag and make sure it gets cleaned up
my $versionTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTag);

# Create a user for testing purposes
my $user = WebGUI::User->new( $session, "new" );
WebGUI::Test->addToCleanup($user);
$user->username( 'dufresne' . time );

# Create gallery and a single album
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        title               => "gallery",
        groupIdAddFile      => 2,                           # Registered Users
        styleTemplateId     => "PBtmpl0000000000000132",    # Blank Style        
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
        ownerUserId         => $user->getId,
        title               => "album",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

# Commit assets for testing
$versionTag->commit;


#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# Test permissions for new photos

my $mech   = WebGUI::Test::Mechanize->new(config => WebGUI::Test->file);

# Save a new photo
$mech->get( $album->getUrl("func=add;className=WebGUI::Asset::File::GalleryFile::Photo") );
$mech->content_lacks( 'value="editSave"' );
$mech->content_contains( 'value="addSave"' );

#----------------------------------------------------------------------------
# Test editing existing photo

# Create single photo inside the album
my $photo
    = $album->addChild({
        className       => "WebGUI::Asset::File::GalleryFile::Photo",
        ownerUserId     => $user->getId,
        title           => "photo",
        synopsis        => "synopsis",
        keywords        => "keywords",
        location        => "location",
        friendsOnly     => 0,
    },
    undef,
    time() - 5          # Create photo asset in the past to avoid duplicate revision dates
    );
# Attach image file to photo asset
$photo->setFile( WebGUI::Test->getTestCollateralPath("rotation_test.png") );

# New values for photo properties
my %properties = (
    title => 'new photo',
    synopsis => 'new synopsis',
    keywords => 'new keywords',
    location => 'new location',
    friendsOnly => '1',
    );

# Log in 
$mech->get('/');  ##Prime the pump to get a session;
$mech->session->user({ user => $user });

# Request photo edit view
$mech->get_ok( $photo->getUrl('func=edit'), 'Request Photo edit view' );
# Try to submit edit form
$mech->submit_form_ok({
        form_name => 'photoEdit',
        fields => \%properties,        
    }, 
    'Submit Photo edit form' );    
# Re-create instance of Photo asset
$photo = WebGUI::Asset->newById($session, $photo->getId);
# Check whether properties were changed correctly
cmp_deeply($photo->get, superhashof(\%properties), 'All changes applied');


#----------------------------------------------------------------------------
# Test redirect to parent's edit view using the "proceed=editParent" parameter

# Create single photo inside the album
$photo
    = $album->addChild({
        className       => "WebGUI::Asset::File::GalleryFile::Photo",
        ownerUserId     => $user->getId,
    },
    undef,
    time() - 5         # Create photo asset in the past to avoid duplicate revision dates
    );
# Attach image file to photo asset
$photo->setFile( WebGUI::Test->getTestCollateralPath("rotation_test.png") );


# Request photo edit view
$mech->get_ok( $photo->getUrl('func=edit;proceed=editParent'), 'Request Photo edit view with "proceed=editParent"' );
# Submit changes
$mech->submit_form( form_name => 'photoEdit' );
# Currently, a redirect using the proceed parameter will not change the URL 
# nor add the proper "func" argument. We have to look at the page content instead.
$mech->content_contains( 'name="galleryAlbumEdit"', "Redirected to parent's edit view" );


#----------------------------------------------------------------------------
# Test creating a new Photo

SKIP: { 
    skip "File control needs to be fixed to be more 508-compliant before this can be used", 4;
    my $mech   = WebGUI::Test::Mechanize->new(config => WebGUI::Test->file);
    $mech->get('/');  ##Prime the pump to get a session;
    $mech->session->user({ user => $user });
    $mech->get_ok( $album->getUrl("func=add;className=WebGUI::Asset::File::GalleryFile::Photo") );

    open my $file, '<', WebGUI::Test->getTestCollateralPath( 'lamp.jpg' ) 
        or die( "Couldn't open test collateral 'lamp.jpg' for reading: $!" );
    my $properties  = {
        title           => 'Photo Title' . time,
        synopsis        => '<p>Photo Synopsis' . time . '</p>',
        newFile_file    => $file,
    };

    $mech->submit_form_ok( 
        {
            form_number => 1,
            fields      => $properties,
        }, 
        'Submit new Photo' 
    );

    # Add properties that should be default and remove those that should be different
    delete $properties->{ newFile_file };
    $properties = {
        %{ $properties },
        ownerUserId     => $user->userId,
        filename        => 'lamp.jpg',
    };

    # Make sure properties were saved
    my $photo   = WebGUI::Asset->newById( $session, $album->getFileIds->[0] );
    cmp_deeply( $photo->get, superhashof( $properties ), "Photo properties saved correctly" );

    # First File in an album should update assetIdThumbnail
    my $album   = WebGUI::Asset->newById( $session, $album->getId );
    is( 
        $album->get('assetIdThumbnail'), $photo->getId, 
        "Album assetIdThumbnail gets set by first File added",
    );
}

done_testing;
