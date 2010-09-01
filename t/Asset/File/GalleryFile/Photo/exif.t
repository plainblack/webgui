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

## The goal of this test is to test the EXIF functionality of WebGUI's photo
# asset

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use Test::Deep;
use Image::ExifTool qw(:Public);

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTag);
$versionTag->set({name=>"Photo Test"});
WebGUI::Test->addToCleanup($versionTag);
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    },
    undef, undef,
    { skipAutoCommitWorkflows => 1 },
    );
my $photo
    = $album->addChild({
        className               => "WebGUI::Asset::File::GalleryFile::Photo",
    },
    undef, undef,
    { skipAutoCommitWorkflows => 1 },
    );
$versionTag->commit;

$photo->setFile( WebGUI::Test->getTestCollateralPath("lamp.jpg") );

my $exif    = ImageInfo( $photo->getStorageLocation->getPath($photo->get('filename')) );
# Sanitize Exif data by removing keys with references as values
for my $key ( keys %$exif ) {
    if ( ref $exif->{$key} ) {
        delete $exif->{$key};
    }
}
# Also remove things that Photo explicitly removed
for my $key ( qw{ Directory } ) {
    delete $exif->{ $key };
}

#----------------------------------------------------------------------------
# Tests
plan tests => 2;

#----------------------------------------------------------------------------
# Test getTemplateVars exif data
my $var         = $photo->getTemplateVars;

cmp_deeply(
    [ keys %$var ], superbagof( map { unless (ref $exif->{ $_ }) { 'exif_' . $_ } } keys %$exif ),
    'getTemplateVars gets a hash of all valid exif tags',
);

is_deeply(
    [ sort keys %$exif ],
    [ sort map { $_->{tag} } @{ $var->{exifLoop} } ],
    "getTemplateVars gets a loop over the tags",
);

#vim:ft=perl
