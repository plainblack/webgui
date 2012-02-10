package Test::WebGUI::Asset::Wobject::GalleryAlbum;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use base qw/Test::WebGUI::Asset::Wobject/;

use Test::More;
use Test::Deep;
use Test::Exception;


sub list_of_tables {
     return [qw/assetData wobject GalleryAlbum assetAspectRssFeed/];
}

sub parent_list {
    return [qw/WebGUI::Asset::Wobject::Gallery/];
}

sub postProcessMergedProperties {
    my ( $test, $props ) = @_;
    $props->{save} = "save"; # GalleryAlbum www_edit checks for this to go to editSave
}

1;
