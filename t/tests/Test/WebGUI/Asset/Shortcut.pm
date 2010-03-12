package Test::WebGUI::Asset::Shortcut;
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

use base qw/Test::WebGUI::Asset/;

use Test::WebGUI::More;
use Test::WebGUI::Deep;
use Test::WebGUI::Exception;

sub class {
     return qw/WebGUI::Asset::Shortcut/;
}

sub list_of_tables {
     return [qw/assetData Shortcut/];
}

1;
