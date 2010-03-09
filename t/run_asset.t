#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use lib 'tests';

use Test::AssetBase;
use Test::Asset::File;
use Test::Asset::Snippet;
use Test::Asset::RichEdit;
use Test::Asset::Shortcut;
use Test::Asset::Sku;
use Test::Asset::Wobject;
use Test::Asset::Template;
use Test::Asset::Redirect;

Test::Class->runtests;
