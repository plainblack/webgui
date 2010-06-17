#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

my $skip_tests = 8;
my $num_tests = 1 + $skip_tests;

plan tests => $num_tests;
 
my $session = WebGUI::Test->session;
 
# put your tests here

my $output = $session->output;

isa_ok($output, 'WebGUI::Session::Output', 'session has correct object type');

my $recentVersion = $^V gt v5.8;


my $otherHandleBuffer;
open my $otherHandle, '>', \$otherHandleBuffer or die "Unable to create second filehandle: $!\n";

my $request = $session->request;

$output->setHandle(undef);
is($output->{_handle}, undef, 'setHandle: handle cleared');

$output->print('Hello STDOUT');
is($request->get_output, 'Hello STDOUT', 'print with no handle goes to STDOUT');

$output->print(' more stuff');
is($request->get_output, 'Hello STDOUT more stuff', 'print: tied variables accumulate');

$session->user({userId => 3});
$output->print('^#;');
like($request->get_output, qr/3\Z/, 'print: macro processing');

$output->print('^#;', 1);
like($request->get_output, qr/\^#;\Z/, 'print: macro processing skipped');

$session->http->setMimeType('application/json');
$output->print('^#;');
like($request->get_output, qr/\^#;\Z/, 'print: macro processing skipped');

$session->http->setMimeType('');
$output->setHandle($otherHandle);
$output->print('New content');
is($otherHandleBuffer, 'New content', 'print: set to explicit handle');
unlike($request->get_output, qr/New content\Z/, 'print: no leakage back to STDOUT');

