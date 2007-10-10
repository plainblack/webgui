#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
my $graphicsClass;
BEGIN {
    if (eval { require Graphics::Magick; 1 }) {
        $graphicsClass = 'Graphics::Magick';
    }
    elsif (eval { require Image::Magick; 1 }) {
        $graphicsClass = 'Image::Magick';
    }
}
use WebGUI::Asset::File::Image::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Photo Test"});

my ($gallery, $album, $photo);

#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}

#----------------------------------------------------------------------------
# Photo not added under a Photo Gallery asset does NOT generate any 
# default resolutions
$photo
    = $node->addChild({
        className           => "WebGUI::Asset::File::Image::Photo",
    });
$photo->getStorageLocation->addFileFromFilesystem( WebGUI::Test->getTestCollateralPath('page_title.jpg') );

ok(
    eval{ $photo->makeResolutions(); 1 },
    "makeResolutions succeeds when photo not under photo gallery and no resolutions to make",
);

is_deeply(
    $photo->getStorageLocation->getFiles, ['page_title.jpg'],
    "makeResolutions does not make any extra resolutions when photo not under photo gallery",
);

#----------------------------------------------------------------------------
# makeResolutions allows API to specify resolutions to make as array reference
# argument
$photo
    = $node->addChild({
        className           => "WebGUI::Asset::File::Image::Photo",
    });
$photo->getStorageLocation->addFileFromFilesystem( WebGUI::Test->getTestCollateralPath('page_title.jpg') );

ok(
    !eval{ $photo->makeResolutions('100x100','200x200'); 1 },
    "makeResolutions fails when first argument is not array reference",
);

ok(
    eval{ $photo->makeResolutions(['100x100','200x200']); 1 },
    "makeResolutions succeeds when first argument is array reference of resolutions to make",
);

is_deeply(
    [ sort({ $a cmp $b} @{ $photo->getStorageLocation->getFiles }) ], 
    ['100x100.jpg', '200x200.jpg', 'page_title.jpg'],
    "makeResolutions makes all the required resolutions with the appropriate names.",
);

TODO: {
    local $TODO = 'Test to ensure the files are created with correct resolution and density';
}

#----------------------------------------------------------------------------
# makeResolutions throws a warning on an invalid resolution but keeps going
$photo
    = $node->addChild({
        className           => "WebGUI::Asset::File::Image::Photo",
    });
$photo->getStorageLocation->addFileFromFilesystem( WebGUI::Test->getTestCollateralPath('page_title.jpg') );
{ # localize our signal handler
    my @warnings;
    local $SIG{__WARN__} = sub { push @warnings, $_[0]; };
     
    ok(
        eval{ $photo->makeResolutions(['abc','200','3d400']); 1 },
        "makeResolutions succeeds when invalid resolutions are given",
    );

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

#----------------------------------------------------------------------------
# makeResolutions gets default resolutions from a parent Photo Gallery asset
$gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::PhotoGallery",
        imageResolutions    => "1600x1200\n1024x768\n800x600\n640x480",
    });
$album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::PhotoAlbum",
    });
$photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::Image::Photo",
    });
$photo->getStorageLocation->addFileFromFilesystem( WebGUI::Test->getTestCollateralPath('page_title.jpg') );

ok(
    eval{ $photo->makeResolutions; 1 },
    "makeResolutions succeeds when photo under photo gallery and no resolution given",
);

is_deeply(
    [ sort({ $a cmp $b} @{ $photo->getStorageLocation->getFiles }) ], 
    [ '1024x768.jpg', '1600x1200.jpg', '640x480.jpg', '800x600.jpg', 'page_title.jpg' ],
    "makeResolutions makes all the required resolutions with the appropriate names.",
);

TODO: {
    local $TODO = 'Test to ensure the files are created with correct resolution and density';
}

#----------------------------------------------------------------------------
# Array of resolutions passed to makeResolutions overrides defaults from 
# parent asset
$gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::PhotoGallery",
        imageResolutions    => "1600x1200\n1024x768\n800x600\n640x480",
    });
$album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::PhotoAlbum",
    });
$photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::Image::Photo",
    });
$photo->getStorageLocation->addFileFromFilesystem( WebGUI::Test->getTestCollateralPath('page_title.jpg') );

ok(
    !eval{ $photo->makeResolutions('100x100','200x200'); 1 },
    "makeResolutions fails when first argument is not array reference",
);

ok(
    eval{ $photo->makeResolutions(['100x100','200x200']); 1 },
    "makeResolutions succeeds when first argument is array reference of resolutions to make",
);

is_deeply(
    [ sort({ $a cmp $b} @{ $photo->getStorageLocation->getFiles }) ], 
    ['100x100.jpg', '200x200.jpg', 'page_title.jpg'],
    "makeResolutions makes all the required resolutions with the appropriate names.",
);

TODO: {
    local $TODO = 'Test to ensure the files are created with correct resolution and density';
}

