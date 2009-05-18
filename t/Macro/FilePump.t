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
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

my  $tests =  0;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $macro = 'WebGUI::Macro::FilePump';
my $loaded = use_ok($macro);

my $bundle = WebGUI::FilePump::Bundle->create($session, { bundleName => 'test bundle'});

SKIP: {

skip "Unable to load $macro", $tests unless $loaded;

}


#----------------------------------------------------------------------------
# Cleanup
END {

$bundle->delete;

}
#vim:ft=perl
