#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# The goal of this test is to test the view and getTemplateVars methods

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../../lib";

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::HTML;
use WebGUI::Session;
use Test::More; 
use Test::Deep;
use WebGUI::Asset::File::GalleryFile::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Photo Test"});
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        groupIdAddComment   => 7,   # Everyone
        groupIdAddFile      => 2,   # Registered Users
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
        ownerUserId         => 3,
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
$versionTag->commit;
$photo->setFile( WebGUI::Test->getTestCollateralPath('page_title.jpg') );

#----------------------------------------------------------------------------
# Tests
plan tests => 1;

#----------------------------------------------------------------------------
# Test getTemplateVars
$session->user( { userId => 1 } );
my $testTemplateVars    = {
    %{ $photo->get },
    synopsis            => '',      # Synopsis is not undef, is changed to empty string
    canComment          => bool( 1 ),
    canEdit             => bool( 0 ),
    ownerUsername       => WebGUI::User->new( $session, 3 )->username,
    synopsis_textonly   => WebGUI::HTML::filter( $photo->get('synopsis'), "all" ),
    url                 => $photo->getUrl,
    url_addArchive      => $album->getUrl('func=addArchive'),
    url_delete          => $photo->getUrl('func=delete'),
    url_demote          => $photo->getUrl('func=demote'),
    url_edit            => $photo->getUrl('func=edit'),
    url_gallery         => $gallery->getUrl,
    url_makeShortcut    => $photo->getUrl('func=makeShortcut'),
    url_listFilesForOwner
        => $gallery->getUrl('func=listFilesForUser;userId=3'),
    url_promote         => $photo->getUrl('func=promote'),
    url_album           => $album->getUrl,
    url_thumbnails      => $album->getUrl('func=thumbnails'),
    url_slideshow       => $album->getUrl('func=slideshow'),
    fileUrl             => $photo->getFileUrl,
    thumbnailUrl        => $photo->getThumbnailUrl,
    numberOfComments    => scalar @{ $photo->getCommentIds },
    resolutions_loop    => ignore(), # Tested elsewhere
    exifLoop            => ignore(), # Tested elsewhere
    
    # Gallery stuff
    url_search          => $gallery->getUrl('func=search'),
    url_listFilesForCurrentUser    => $gallery->getUrl('func=listFilesForUser'),
    gallery_title       => $gallery->get('title'),
    gallery_menuTitle   => $gallery->get('menuTitle'),
    gallery_url         => $gallery->getUrl,

    # Album stuff
    album_title         => $album->get('title'),
    album_menuTitle     => $album->get('menuTitle'),
    album_url           => $album->getUrl,
    album_thumbnailUrl  => $album->getThumbnailUrl,
};

# Ignore all EXIF tags, they're tested in exif.t
for my $tag ( keys %{ $photo->getExifData } ) {
    $testTemplateVars->{ 'exif_' . $tag } = ignore();
}
# Add search vars
$gallery->appendTemplateVarsSearchForm( $testTemplateVars );

# Fix vars that are time-sensitive
$testTemplateVars->{ searchForm_creationDate_before }
    = all(
        re( qr/<input/ ),
        re( qr/name="creationDate_before"/ ),
    );

$testTemplateVars->{ searchForm_creationDate_after }
    = all(
        re( qr/<input/ ),
        re( qr/name="creationDate_after"/ ),
    );

cmp_deeply(
    $photo->getTemplateVars,
    $testTemplateVars,
    "getTemplateVars is correct and complete",
);

#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}
