#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# The goal of this test is to test the getDownloadFileUrl and www_download()
# methods

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../../lib";

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Asset::File::GalleryFile::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);

my @versionTags = ();
push @versionTags, WebGUI::VersionTag->getWorking($session);
$versionTags[-1]->set({name=>"Photo Test, add Gallery, Album and 1 Photo"});
my $versionTag      = WebGUI::VersionTag->getWorking($session);

my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        imageResolutions    => "100\n200\n300",
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
    = $gallery->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

$versionTags[-1]->commit;

#----------------------------------------------------------------------------
# Tests
plan tests => 1;

TODO: {
    local $TODO = 'Write some tests for download testing';
    ok(0, 'No tests yet');
}

#----------------------------------------------------------------------------
# Cleanup
END {
    foreach my $versionTag (@versionTags) {
        $versionTag->rollback;
    }
}


