# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::AssetHelper::Manage;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 2;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $output;
my $home = WebGUI::Asset->getDefault($session);

$session->user({userId => 3});

my $versionTag = WebGUI::VersionTag->getWorking($session);

my $newPage = $home->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Test page',
}, undef, undef, { skipAutoCommitWorkflows => 1, });

my $article1 = $newPage->addChild({
    className => 'WebGUI::Asset::Wobject::Article',
    title     => 'Article_1',
}, undef, undef, { skipAutoCommitWorkflows => 1, });

my $article2 = $newPage->addChild({
    className => 'WebGUI::Asset::Wobject::Article',
    title     => 'Article_2',
}, undef, undef, { skipAutoCommitWorkflows => 1, });

$versionTag->commit;
addToCleanup($versionTag);

$session->user({userId => 1});
$output = WebGUI::AssetHelper::Manage->process($article2);
cmp_deeply(
    $output, 
    {
        error => re('You do not have sufficient privileges'),
    },
    'AssetHelper/Promote checks for editing privileges'
);

$session->user({userId => 3});
$output = WebGUI::AssetHelper::Manage->process($article2);
cmp_deeply(
    $output, 
    {
        open_tab  => $article2->getManagerUrl,
    },
    'AssetHelper/Promote returns a message'
);

#vim:ft=perl
