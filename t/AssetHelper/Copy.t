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
use WebGUI::AssetHelper::Copy;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 3;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $output;
my $helper = WebGUI::AssetHelper::Copy->new( id => 'copy', session => $session );
my $home = WebGUI::Asset->getDefault($session);
my $root = WebGUI::Asset->getRoot($session);

{ 

    $output = $helper->process($home);
    cmp_deeply(
        $output, 
        {
            openDialog  => all(
                            re('helperId=copy'),
                            re('method=copy'),
                            re('assetId=' . $home->getId ),
                        ),
        },
        'AssetHelper/Copy opens a dialog for the copy method'
    );
}

my $mech    = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/?op=assetHelper;helperId=copy;method=copy;assetId=' . $home->getId );

my $clippies = $root->getLineage(["descendants"], {statesToInclude => [qw{clipboard clipboard-limbo}], returnObjects => 1,});
is @{ $clippies }, 1, '... only copied 1 asset to the clipboard, no children';
addToCleanup(@{ $clippies });

#vim:ft=perl
