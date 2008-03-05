#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# The goal of this test is to test the view and getTemplateVars methods

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../../lib";

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Test::Maker::HTML;
use WebGUI::Asset::File::GalleryFile::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Photo Test"});
my $maker           = WebGUI::Test::Maker::HTML->new;
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
my $photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });
$versionTag->commit;
$photo->setFile( WebGUI::Test->getTestCollateralPath('page_title.jpg') );

#----------------------------------------------------------------------------
# Tests
plan tests => 1;

TODO: {
    local $TODO = "Write some tests";
    ok(0, 'No tests here, move on');
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}
