#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# The goal of this test is to test the editSave, 
# processPropertiesFromFormPost, and applyConstraints methods.

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../../lib";

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Asset::File::GalleryFile::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);

my @versionTags = ();
push @versionTags, WebGUI::VersionTag->getWorking($session);
$versionTags[-1]->set({name=>"Photo Test, add Gallery, Album and 1 Photo"});

$session->user( { userId => 3 } ); # Admins can do everything

# Create a user for testing purposes
my $user        = WebGUI::User->new( $session, "new" );
$user->username( 'dufresne' );
$user->addToGroups( ['3'] );
my $identifier  = 'ritahayworth';
my $auth        = WebGUI::Operation::Auth::getInstance( $session, $user->authMethod, $user->userId );
$auth->saveParams( $user->userId, $user->authMethod, {
    'identifier'    => Digest::MD5::md5_base64( $identifier ), 
});

my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        groupIdAddFile      => 3,   # Admins
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
my $photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

$versionTags[-1]->commit;

#----------------------------------------------------------------------------
# Tests
plan skip_all => "Tests not working yet";
#plan tests => 1;

use_ok("Test::WWW::Mechanize");
my $mech;

#----------------------------------------------------------------------------
# Test permissions
$mech   = Test::WWW::Mechanize->new;

# Edit an existing photo
$mech->get( $session->url->getSiteURL . $photo->getUrl("func=edit") );
$mech->content_contains("permission denied");

$mech->get( $session->url->getSiteURL . $photo->getUrl("func=editSave") );
$mech->content_contains("permission denied");

# Save a new photo
$mech->get( $session->url->getSiteURL . $album->getUrl("func=add;class=WebGUI::Asset::File::GalleryFile::Photo") );
$mech->content_contains("permission denied");

$mech->get( $session->url->getSiteURL . $album->getUrl("func=editSave;assetId=new;class=WebGUI::Asset::File::GalleryFile::Photo") );
$mech->content_contains("permission denied");

#----------------------------------------------------------------------------
# Test processPropertiesFromFormPost errors
# TODO: This test should use i18n.
# TODO: This error / test should occur in File, not Photo
$mech       = Test::WWW::Mechanize->new;
# Login mech object
$mech->get( $session->url->getSiteURL . '?op=auth;method=login;username=dufresne;identifier=ritahayworth' );

$mech->get_ok( $album->getUrl('func=add;class=WebGUI::Asset::File::GalleryFile::Photo') );
$mech->submit_form( 
    with_fields => {
        title           => '',
        newFile_file    => '',
    },
);

#----------------------------------------------------------------------------
# Test editSave success result
# TODO: This test should use i18n


#----------------------------------------------------------------------------
# Cleanup
END {
    foreach my $versionTag (@versionTags) {
        $versionTag->rollback;
    }
    $user->delete;
}


