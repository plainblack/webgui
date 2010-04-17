#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
my $previousPhoto
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
        ownerUserId         => 3,
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
my $nextPhoto
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
    url_album           => $album->getUrl('pn=1'),
    url_thumbnails      => $album->getUrl('func=thumbnails'),
    url_slideshow       => $album->getUrl('func=slideshow'),
    fileUrl             => $photo->getFileUrl,
    thumbnailUrl        => $photo->getThumbnailUrl,
    numberOfComments    => scalar @{ $photo->getCommentIds },
    exifLoop            => ignore(), # Tested elsewhere
    isPending           => ( $photo->get("status") eq "pending" ),
    firstFile_url       => $previousPhoto->getUrl,
    firstFile_thumbnailUrl 
        => $previousPhoto->getThumbnailUrl,
    firstFile_title     => $previousPhoto->get("title"),
    previousFile_url    => $previousPhoto->getUrl,
    previousFile_thumbnailUrl 
        => $previousPhoto->getThumbnailUrl,    
    previousFile_title  => $previousPhoto->get("title"),
    nextFile_url        => $nextPhoto->getUrl,
    nextFile_thumbnailUrl 
        => $nextPhoto->getThumbnailUrl,    
    nextFile_title      => $nextPhoto->get("title"),
    firstFile_title     => $previousPhoto->get("title"),
    lastFile_url        => $nextPhoto->getUrl,
    lastFile_thumbnailUrl 
        => $nextPhoto->getThumbnailUrl,    
    lastFile_title      => $nextPhoto->get("title"),
};

# Ignore all EXIF tags, they're tested in exif.t
for my $tag ( keys %{ $photo->getExifData } ) {
    $testTemplateVars->{ 'exif_' . $tag } = ignore();
}

# Add resolution vars
for my $resolution ( @{ $photo->getResolutions } ) {
    my $label       = $resolution;
    $label          =~ s/\.[^.]+$//;
    my $downloadUrl = $photo->getStorageLocation->getUrl( $resolution );
    push @{ $testTemplateVars->{ resolutions_loop } }, { 
        resolution      => $label,
        url_download    => $downloadUrl,
    };
    $testTemplateVars->{ "resolution_" . $resolution } = $downloadUrl;
}

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
