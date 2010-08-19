package Test::WebGUI::Asset::File::GalleryFile;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use base qw/Test::WebGUI::Asset::File/;

use Test::More;
use Test::Deep;
use Test::Exception;


sub list_of_tables {
     return [qw/assetData FileAsset GalleryFile/];
}

sub parent_list {
    return [qw/WebGUI::Asset::Wobject::Gallery WebGUI::Asset::Wobject::GalleryAlbum /];
}

sub dynamic_form_labels { return 'New file to upload' };

1;
