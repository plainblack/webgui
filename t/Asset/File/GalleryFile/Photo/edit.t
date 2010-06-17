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
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Asset;
use WebGUI::VersionTag;
use WebGUI::Session;
plan skip_all => 'set WEBGUI_LIVE to enable this test' unless $ENV{WEBGUI_LIVE};

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode( $session );
my @versionTags     = ( WebGUI::VersionTag->getWorking( $session ) );

# Override some settings to make things easier to test
# userFunctionStyleId 
$session->setting->set( 'userFunctionStyleId', 'PBtmpl0000000000000132' );
# specialState
$session->setting->set( 'specialState', '' );

# Create a user for testing purposes
my $user        = WebGUI::User->new( $session, "new" );
WebGUI::Test->usersToDelete($user);
$user->username( 'dufresne' . time );
my $identifier  = 'ritahayworth';
my $auth        = WebGUI::Operation::Auth::getInstance( $session, $user->authMethod, $user->userId );
$auth->saveParams( $user->userId, $user->authMethod, {
    'identifier'    => Digest::MD5::md5_base64( $identifier ), 
});

my ( $mech );

# Get the site's base URL
my $baseUrl         = 'http://' . $session->config->get('sitename')->[0];

my @addArgs = ( undef, undef, { skipAutoCommitWorkflows => 1 } );

my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        groupIdAddFile      => 2,                           # Registered Users
        styleTemplateId     => "PBtmpl0000000000000132",    # Blank Style
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    }, @addArgs );

$versionTags[-1]->commit;

my $photo;


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

plan tests => 5;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test permissions for new photos
$mech   = Test::WWW::Mechanize->new;

# Save a new photo
$mech->get( $baseUrl . $album->getUrl("func=add;class=WebGUI::Asset::File::GalleryFile::Photo") );
$mech->content_lacks( 'value="editSave"' );

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
# Cleanup
END {
    for my $tag ( @versionTags ) {
        $tag->rollback;
    }

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
