# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

my $tests = 3;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::Tax');

SKIP: {

skip 'Unable to load module WebGUI::Shop::Tax', $tests unless $loaded;

my $taxer = WebGUI::Shop::Tax->new($session);

isa_ok($taxer, 'WebGUI::Shop::Tax');

isa_ok($taxer->session, 'WebGUI::Session', 'session method returns a session object');

is($session->getId, $taxer->session->getId, 'session method returns OUR session object');

}


#----------------------------------------------------------------------------
# Cleanup
END {

}
