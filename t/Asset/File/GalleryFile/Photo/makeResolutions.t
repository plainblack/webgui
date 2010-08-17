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
use lib "$FindBin::Bin/../../../../lib";

## The goal of this test is to test the creation of photo download 
# resolutions

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use Test::Deep;
use Image::Magick;
use WebGUI::Asset::File::GalleryFile::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my @versionTags = ();
push @versionTags, WebGUI::VersionTag->getWorking($session);
$versionTags[-1]->set({name=>"Photo Test"});
WebGUI::Test->addToCleanup($versionTags[-1]);

my ($gallery, $album, $photo);
$gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        imageResolutions    => "1600\n1024\n800\n640",
    });
$album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

#----------------------------------------------------------------------------
# Tests
plan tests => 13;

#----------------------------------------------------------------------------
# makeResolutions gets default resolutions from a parent Photo Gallery asset
$photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
$versionTags[-1]->commit;
WebGUI::Test->addToCleanup($versionTags[-1]);
$photo->getStorageLocation->addFileFromFilesystem( WebGUI::Test->getTestCollateralPath('page_title.jpg') );
$photo->update({ filename => 'page_title.jpg' });

ok(
    eval{ $photo->makeResolutions; 1 },
    "makeResolutions succeeds when photo under photo gallery and no resolution given",
);
diag( $@ )
    if $@;

cmp_deeply(
    $photo->getStorageLocation->getFiles, 
    bag( '1024.jpg', '1600.jpg', '640.jpg', '800.jpg', 'page_title.jpg' ),
    "makeResolutions makes all the required resolutions with the appropriate names.",
);

TODO: {
    local $TODO = 'Test to ensure the files are created with correct resolution and density';
}

#----------------------------------------------------------------------------
# Array of resolutions passed to makeResolutions overrides defaults from 
# parent asset
push @versionTags, WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTags[-1]);
$gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        imageResolutions    => "1600\n1024\n800\n640",
    });
$album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
$photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
$versionTags[-1]->commit;
$photo->getStorageLocation->addFileFromFilesystem( WebGUI::Test->getTestCollateralPath('page_title.jpg') );
$photo->update({ filename => 'page_title.jpg' });

ok(
    !eval{ $photo->makeResolutions('100','200'); 1 },
    "makeResolutions fails when first argument is not array reference",
);

ok(
    eval{ $photo->makeResolutions(['100','200']); 1 },
    "makeResolutions succeeds when first argument is array reference of resolutions to make",
);
diag( $@ )
    if $@;

is_deeply(
    [ sort({ $a cmp $b} @{ $photo->getStorageLocation->getFiles }) ], 
    ['100.jpg', '200.jpg', 'page_title.jpg'],
    "makeResolutions makes all the required resolutions with the appropriate names.",
);

TODO: {
    local $TODO = 'Test to ensure the files are created with correct resolution and density';
}

#----------------------------------------------------------------------------
# makeResolutions allows API to specify resolutions to make as array reference
# argument
push @versionTags, WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTags[-1]);
$photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
$versionTags[-1]->commit;

$photo->getStorageLocation->addFileFromFilesystem( WebGUI::Test->getTestCollateralPath('page_title.jpg') );
$photo->update({ filename => 'page_title.jpg' });

ok(
    !eval{ $photo->makeResolutions('100','200'); 1 },
    "makeResolutions fails when first argument is not array reference",
);

ok(
    eval{ $photo->makeResolutions(['100','200']); 1 },
    "makeResolutions succeeds when first argument is array reference of resolutions to make",
);

is_deeply(
    [ sort({ $a cmp $b} @{ $photo->getStorageLocation->getFiles }) ], 
    ['100.jpg', '200.jpg', 'page_title.jpg'],
    "makeResolutions makes all the required resolutions with the appropriate names.",
);

TODO: {
    local $TODO = 'Test to ensure the files are created with correct resolution and density';
}

#----------------------------------------------------------------------------
# makeResolutions throws a warning on an invalid resolution but keeps going
push @versionTags, WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTags[-1]);
$photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
$versionTags[-1]->commit;
$photo->getStorageLocation->addFileFromFilesystem( WebGUI::Test->getTestCollateralPath('page_title.jpg') );
$photo->update({ filename => 'page_title.jpg' });
{ # localize our signal handler
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, $_[0]; };
     
    ok(
        eval{ $photo->makeResolutions(['abc','200','3d400']); 1 },
        "makeResolutions succeeds when invalid resolutions are given",
    );
    diag( $@ )
        if $@;

    is(
        scalar @warnings, 2,
        "makeResolutions throws a warning for each invalid resolution given",
    );

    like(
        $warnings[0], qr/abc/,
        "makeResolutions throws a warning for the correct invalid resolution 'abc'",
    );
    
    like(
        $warnings[1], qr/3d400/,
        "makeResolutions throws a warning for the correct invalid resolution '3d400'",
    );

    is_deeply(
        [ sort({ $a cmp $b} @{ $photo->getStorageLocation->getFiles }) ], 
        ['200.jpg', 'page_title.jpg'],
        "makeResolutions still makes valid resolutions when invalid resolutions given",
    );
}

#vim:ft=perl
