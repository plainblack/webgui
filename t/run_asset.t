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
use Test::Asset::File::Image;
use Test::Asset::File::ZipArchive;
use Test::Asset::File::GalleryFile;
use Test::Asset::Redirect;
use Test::Asset::RichEdit;
use Test::Asset::Shortcut;
use Test::Asset::Sku;
use Test::Asset::Snippet;
use Test::Asset::Template;
use Test::Asset::Wobject;
use Test::Asset::Wobject::Article;
use Test::Asset::Wobject::Calendar;
use Test::Asset::Wobject::Carousel;
use Test::Asset::Wobject::Collaboration;
use Test::Asset::Wobject::DataForm;
use Test::Asset::Wobject::DataTable;
use Test::Asset::Wobject::EventManagementSystem;
use Test::Asset::Wobject::Folder;
use Test::Asset::Wobject::Gallery;
use Test::Asset::Wobject::GalleryAlbum;
use Test::Asset::Wobject::HttpProxy;

Test::Class->runtests;
