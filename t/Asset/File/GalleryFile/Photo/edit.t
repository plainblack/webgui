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

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../../lib";

use Test::More;
use Test::Deep;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Asset;
use WebGUI::Asset::Wobject::Gallery;
use WebGUI::Asset::Wobject::GalleryAlbum;
use WebGUI::Asset::File::GalleryFile::Photo;
use WebGUI::VersionTag;
use WebGUI::Session;

plan skip_all => 'set WEBGUI_LIVE to enable this test' unless $ENV{WEBGUI_LIVE};

#----------------------------------------------------------------------------
# Init

my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode( $session );

# Create version tag and make sure it gets cleaned up
my $versionTag = WebGUI::VersionTag->getWorking($session);
addToCleanup($versionTag);

# Override some settings to make things easier to test
# userFunctionStyleId 
$session->setting->set( 'userFunctionStyleId', 'PBtmpl0000000000000132' );
# specialState
$session->setting->set( 'specialState', '' );

# Create a user for testing purposes
my $user = WebGUI::User->new( $session, "new" );
WebGUI::Test->usersToDelete($user);
$user->username( 'dufresne' . time );
my $identifier = 'ritahayworth';
my $auth = WebGUI::Operation::Auth::getInstance( $session, $user->authMethod, $user->userId );
$auth->saveParams( $user->userId, $user->authMethod, {
    'identifier'    => Digest::MD5::md5_base64( $identifier ), 
});

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

# Get the site's base URL
my $baseUrl  = 'http://' . $session->config->get('sitename')->[0];

# Common variables
my ( $mech, $photo );


#----------------------------------------------------------------------------
# Tests

if ( !eval { require Test::WWW::Mechanize; 1; } ) {
    plan skip_all => 'Cannot load Test::WWW::Mechanize. Will not test.';
}
$mech    = Test::WWW::Mechanize->new;
$mech->get( $baseUrl );
if ( !$mech->success ) {
    plan skip_all => "Cannot load URL '$baseUrl'. Will not test.";
}

plan tests => 10;        # Increment this number for each test you create


#----------------------------------------------------------------------------
# Test permissions for new photos

$mech   = Test::WWW::Mechanize->new;

# Save a new photo
$mech->get( $baseUrl . $album->getUrl("func=add;class=WebGUI::Asset::File::GalleryFile::Photo") );
$mech->content_lacks( 'value="editSave"' );


#----------------------------------------------------------------------------
# Test editing existing photo

# Create single photo inside the album
$photo
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
$mech = getMechLogin( $baseUrl, $user, $identifier );

# Request photo edit view
$mech->get_ok( $baseUrl . $photo->getUrl('func=edit'), 'Request Photo edit view' );
# Try to submit edit form
$mech->submit_form_ok({
        form_name => 'photoEdit',
        fields => \%properties,        
    }, 
    'Submit Photo edit form' );    
# Re-create instance of Photo asset
$photo = WebGUI::Asset->newByDynamicClass($session, $photo->getId);
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
$mech->get_ok( $baseUrl . $photo->getUrl('func=edit;proceed=editParent'), 'Request Photo edit view with "proceed=editParent"' );
# Submit changes
$mech->submit_form( form_name => 'photoEdit' );
# Currently, a redirect using the proceed parameter will not change the URL 
# nor add the proper "func" argument. We have to look at the page content instead.
$mech->content_contains( 'name="galleryAlbumEdit"', "Redirected to parent's edit view" );


#----------------------------------------------------------------------------
# Test creating a new Photo

SKIP: { 
    skip "File control needs to be fixed to be more 508-compliant before this can be used", 4;
    $mech   = getMechLogin( $baseUrl, $user, $identifier );
    $mech->get_ok( $baseUrl . $album->getUrl("func=add;class=WebGUI::Asset::File::GalleryFile::Photo") );

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
    my $photo   = WebGUI::Asset->newByDynamicClass( $session, $album->getFileIds->[0] );
    cmp_deeply( $photo->get, superhashof( $properties ), "Photo properties saved correctly" );

    # First File in an album should update assetIdThumbnail
    my $album   = WebGUI::Asset->newByDynamicClass( $session, $album->getId );
    is( 
        $album->get('assetIdThumbnail'), $photo->getId, 
        "Album assetIdThumbnail gets set by first File added",
    );
}


#----------------------------------------------------------------------------
# getMechLogin( baseUrl, WebGUI::User, "identifier" )
# Returns a Test::WWW::Mechanize session after logging in the given user using
# the given identifier (password)
# baseUrl is a fully-qualified URL to the site to login to
sub getMechLogin {
    my $baseUrl     = shift;
    my $user        = shift;
    my $identifier  = shift;
    
    my $mech    = Test::WWW::Mechanize->new;
    $mech->get( $baseUrl . '?op=auth;method=displayLogin' );
    $mech->submit_form( 
        with_fields => {
            username        => $user->username,
            identifier      => $identifier,
        },
    ); 

    return $mech;
}
