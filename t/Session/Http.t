#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

use Test::More; # increment this value for each test you create

my $num_tests = 6;

plan tests => $num_tests;
 
my $session = WebGUI::Test->session;
 
# put your tests here

my $http = $session->http;

isa_ok($http, 'WebGUI::Session::Http', 'session has correct object type');

$http->setStatus('123');

is($http->getStatus, '123', 'getStatus: returns correct code');
is($http->getStatusDescription, 'OK', 'getStatusDescription: returns default description via getStatus');

$http->setStatus('');

is($http->getStatusDescription, 'OK', 'getStatusDescription: returns default description via itself');
is($http->getStatus, '200', 'getStatus: returns default code');

$http->setStatus('', 'packets are great');

is($http->getStatusDescription, 'packets are great', 'getStatusDescription: returns correct description');

END {
}
