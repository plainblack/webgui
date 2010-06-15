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
use strict;
use lib "$FindBin::Bin/../../../lib";

## The goal of this test is to test the additional functionality of the 
# overridden setFile method

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Asset::File::Image;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTag);
$versionTag->set({name=>"Image Test"});
my $image
    = $node->addChild({
        className           => "WebGUI::Asset::File::Image",
    });
$versionTag->commit;

#----------------------------------------------------------------------------
# Tests
plan tests => 2;

#----------------------------------------------------------------------------
# setFile allows file path argument and adds the file
# setFile also generates thumbnail
# plan tests => 2
$image->setFile( WebGUI::Test->getTestCollateralPath("page_title.jpg") );
my $storage = $image->getStorageLocation;

is_deeply(
    $storage->getFiles, ['page_title.jpg'],
    "Storage location contains only the file we added",
);

# We must do a filesystem test because getFiles doesn't include 'thumb-'
ok(
    -e $storage->getPath('thumb-page_title.jpg'),
    "Thumbnail file exists on the filesystem",
);

#vim:ft=perl
