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
use WebGUI::AssetHelper::Cut;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 5;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

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
is $safe_page->get('state'), 'clipboard', '... and the asset was really cut';

$home->paste($safe_page->getId);

$safe_page = $safe_page->cloneFromDb();
is $safe_page->get('state'), 'published', 'reset asset for further testing';

#vim:ft=perl
