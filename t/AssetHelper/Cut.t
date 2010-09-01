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

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::AssetHelper::Cut;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

my $output;
my $home = WebGUI::Asset->getDefault($session);

$session->user({userId => 1});
$output = WebGUI::AssetHelper::Cut->process($home);
cmp_deeply(
    $output, 
    {
        error => re('You do not have sufficient privileges'),
    },
    'AssetHelper/Cut checks for editing privileges'
);

$session->user({userId => 3});
$output = WebGUI::AssetHelper::Cut->process($home);
cmp_deeply(
    $output, 
    {
        error => re('vital component'),
    },
    'AssetHelper/Cut checks for system pages'
);

my $safe_page = $home->getFirstChild;
$output = WebGUI::AssetHelper::Cut->process($safe_page);
cmp_deeply(
    $output, 
    {
        message  => re('was cut to the clipboard'),
        redirect => $home->getUrl,
    },
    'AssetHelper/Cut returns a message and a redirect'
);
is $safe_page->state, 'clipboard', '... and the asset was really cut';

$session->asset($home);
ok $home->paste($safe_page->getId), 'page pasted correctly';

$session->cache->clear;
my $safe_page2 = WebGUI::Asset->newById($session, $safe_page->assetId);
is $safe_page2->state, 'published', 'reset asset for further testing';

done_testing();

#vim:ft=perl
