#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------
 
use strict;

use WebGUI::Test;
use WebGUI::Session;

use Test::More; # increment this value for each test you create
use Test::Deep;
use Data::Dumper;

plan tests => 9;
 
my $session = WebGUI::Test->session;
 
# put your tests here

my $output = $session->output;

isa_ok($output, 'WebGUI::Session::Output', 'session has correct object type');

my $otherHandleBuffer;
open my $otherHandle, '>', \$otherHandleBuffer or die "Unable to create second filehandle: $!\n";

my $response = $session->response;

$output->setHandle(undef);
is($output->{_handle}, undef, 'setHandle: handle cleared');

$output->print('Hello STDOUT');
is($response->body->[-1], 'Hello STDOUT', 'print with no handle goes to STDOUT');

$output->print(' more stuff');
cmp_deeply(
    $response->body,
    ['Hello STDOUT', ' more stuff'],
    '... tied variables accumulate'
);

$session->user({userId => 3});
$output->print('^#;');
like($response->body->[-1], qr/3\Z/, '... macro processing');

$output->print('^#;', 1);
like($response->body->[-1], qr/\^#;\Z/, '... macro processing skipped due to flag');

$session->response->content_type('application/json');
$output->print('^#;');
like($response->body->[-1], qr/\^#;\Z/, '... macro processing skipped due to mime type');

$session->response->content_type('');
$output->setHandle($otherHandle);
$output->print('New content');
is($otherHandleBuffer, 'New content', '... set to explicit handle');
unlike($response->body->[-1], qr/New content\Z/, '... no leakage back to STDOUT');

