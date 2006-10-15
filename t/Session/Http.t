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

my $num_tests = 8;

plan tests => $num_tests;
 
my $session = WebGUI::Test->session;
 
# put your tests here

my $http = $session->http;

isa_ok($http, 'WebGUI::Session::Http', 'session has correct object type');

$http->setStatus('123');

is($http->getStatus, '123', 'getStatus: returns correct code in scalar context');

my ($status, $description) = $http->getStatus;
is($status, '123', 'getStatus: returns correct code');
is($description, 'OK', 'getStatus: default description returned');

$http->setStatus('');

($status, $description) = $http->getStatus;
is($status, '200', 'getStatus: returns default code');
is($description, 'OK', 'getStatus: default description returned');

$http->setStatus('', 'packets are great');

($status, $description) = $http->getStatus;
is($status, '200', 'getStatus: returns default code');
is($description, 'packets are great', 'getStatus: default description returned');

END {
}
