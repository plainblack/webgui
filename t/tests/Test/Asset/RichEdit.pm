package Test::Asset::RichEdit;
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
use lib "$FindBin::Bin/lib";

use base qw/Test::AssetBase/;

use Test::More;
use Test::Deep;
use Test::Exception;

sub class {
     return qw/WebGUI::Asset::RichEdit/;
}

sub assetUiLevel {
     return 5;
}

sub list_of_tables {
     return [qw/assetData RichEdit/];
}

1;
