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
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;

use Test::More; # increment this value for each test you create
use Test::Deep;

my $tests = 1;
plan tests => 4
            + $tests
            ;

#TODO: This script tests certain aspects of WebGUI::Storage and it should not

my $session = WebGUI::Test->session;

my $class  = 'WebGUI::Asset::Story';
my $loaded = use_ok($class);
my $story;

my $defaultNode = WebGUI::Asset->getDefault($session);
my $archive     = WebGUI::Asset->newByPropertyHashRef($session, {
    className => 'WebGUI::Asset::Wobject::StoryArchive',
    title     => 'Test Archive',
                 #1234567890123456789012
    assetId   => 'TestStoryArchiveAsset1',
});

SKIP: {

skip "Unable to load module $class", $tests unless $loaded;

############################################################
#
# validParent
#
############################################################

ok(! WebGUI::Asset::Story->validParent($session), 'validParent: no session asset');
$session->asset($defaultNode);
ok(! WebGUI::Asset::Story->validParent($session), 'validParent: wrong type of asset');
$session->asset($archive);
ok(  WebGUI::Asset::Story->validParent($session), 'validParent: StoryArchive is valid');

############################################################
#
# make a new one
#
############################################################

$story = $defaultNode->addChild({
    className => 'WebGUI::Asset::Story',
    title     => 'Story 1',
});

isa_ok($story, 'WebGUI::Asset::Story', 'Created a Story asset');

}

END {
    WebGUI::VersionTag->getWorking($session)->rollback;
    $story->purge   if $story;
    $archive->purge if $archive;
}
