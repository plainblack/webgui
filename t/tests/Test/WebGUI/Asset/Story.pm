package Test::WebGUI::Asset::Story;
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use base qw/Test::WebGUI::Asset/;

use Test::More;
use Test::Deep;
use Test::Exception;

sub list_of_tables {
     return [qw/assetData Story/];
}

sub parent_list {
    return ['WebGUI::Asset::Wobject::StoryArchive'];
}

sub t_11_getEditForm : Tests {
    # Override because getEditForm returns straight HTML
    ok(1);
}

1;
