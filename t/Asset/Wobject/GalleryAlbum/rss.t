# $vim: syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

## The goal of this test is to test the rss view of GalleryAlbums

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use Test::Deep;
use XML::Simple;
plan skip_all => 'set WEBGUI_LIVE to enable this test' unless $ENV{WEBGUI_LIVE};

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Album Test"});
WebGUI::Test->addToCleanup($versionTag);
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        groupIdAddComment   => 2,   # Registered Users
        groupIdAddFile      => 2,   # Registered Users
        groupIdView         => 7,   # Everyone
        groupIdEdit         => 3,   # Admins
        ownerUserId         => 3,   # Admin
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
        ownerUserId         => "3", # Admin
        description         => "An RSS Description with an extra &nbsp;space",
        title               => "Title with extra&nbsp; dash",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
note $album->get('title');
note $album->get('description');
my @photos;
for my $i ( 0 .. 5 ) {
    $photos[ $i ] 
        = $album->addChild({
            className           => "WebGUI::Asset::File::GalleryFile::Photo",
            filename            => "$i.jpg",
            synopsis            => "This is a description for $i.jpg",
        },
        undef,
        undef,
        {
            skipAutoCommitWorkflows => 1,
        });
}

$versionTag->commit;

# Override some settings to make things easier to test
# userFunctionStyleId 
$session->setting->set( 'userFunctionStyleId', 'PBtmpl0000000000000132' );
# specialState
$session->setting->set( 'specialState', '' );

my ( $mech );
my $baseUrl         = $session->url->getSiteURL;

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

plan tests => 1;

#----------------------------------------------------------------------------
# Test www_viewRss
$mech   = Test::WWW::Mechanize->new;
my $url = $session->url->getSiteURL . $session->url->makeAbsolute( $album->getUrl('func=viewRss') ); 
$mech->get( $url );
cmp_deeply(
    XMLin( $mech->content ),
    {
        version     => '2.0',
        channel     => {
            link        => $session->url->getSiteURL . $album->getUrl,
            description => $album->get("description"),
            title       => $album->get("title"),
            item        => bag(
                map { 
                    superhashof({
                        link        => $session->url->getSiteURL . $_->getUrl,
                        title       => $_->get("title"),
                        pubDate     => $session->datetime->epochToMail( $_->get("revisionDate") ),
                        description => $_->get("synopsis"),
                    }) 
                } @photos
            ),
        },
    },
    "RSS Datastructure is complete and correct",
);
