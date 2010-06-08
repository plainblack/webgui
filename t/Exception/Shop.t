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
use WebGUI::Exception::Shop;
use Exception::Class;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $e;
eval { WebGUI::Error::Shop::MaxOfItemInCartReached->throw( error => 'Test max of item in cart', )};
$e = Exception::Class->caught;
isa_ok($e, 'WebGUI::Error');
isa_ok($e, 'WebGUI::Error::Shop::MaxOfItemInCartReached');

eval { WebGUI::Error::Shop::RemoteShippingRate->throw( error => 'Test remote shipping rate', )};
$e = Exception::Class->caught;
isa_ok($e, 'WebGUI::Error');
isa_ok($e, 'WebGUI::Error::Shop::RemoteShippingRate');

#vim:ft=perl
