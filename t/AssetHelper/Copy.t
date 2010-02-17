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
use WebGUI::AssetHelper::Copy;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 3;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $output;
my $home = WebGUI::Asset->getDefault($session);
my $root = WebGUI::Asset->getRoot($session);

{ 

    $output = WebGUI::AssetHelper::Copy->process($home);
    cmp_deeply(
        $output, 
        {
            message  => re('was copied to the clipboard'),
        },
        'AssetHelper/Copy redirects the back to the copied asset'
    );

    my $clippies = $root->getLineage(["descendants"], {statesToInclude => [qw{clipboard clipboard-limbo}], returnObjects => 1,});
    is @{ $clippies }, 1, '... only copied 1 asset to the clipboard, no children';
    addToCleanup(@{ $clippies });
}

{
    $session->setting->set('skipCommitComments', 0);

    $output = WebGUI::AssetHelper::Copy->process($home);
    cmp_deeply(
        $output, 
        {
            message  => re('was copied to the clipboard'),
            open_tab => re('^'.$home->getUrl),
        },
        'AssetHelper/Copy opens a tab for commit comments'
    );

    my $clippies = $root->getLineage(["descendants"], {statesToInclude => [qw{clipboard clipboard-limbo}], returnObjects => 1,});
    addToCleanup(@{ $clippies });
}

#vim:ft=perl
