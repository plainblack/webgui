package Test::WebGUI::Asset::Wobject::Navigation;
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

use Test::More;
use Test::Deep;
use Test::Exception;


sub list_of_tables {
     return [qw/assetData wobject Navigation/];
}

1;
