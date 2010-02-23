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

use Test::More;
use Test::MockObject::Extends;

my $numTests = 39;

plan tests => $numTests;

my $session = WebGUI::Test->session;

##Setup for security method test
my %newEnv = ( REMOTE_ADDR => '192.168.0.6' );
$session->env->{_env} = \%newEnv;

my ($eh) = $session->quick('errorHandler');

####################################################
#
# warn, security
#
####################################################

WebGUI::Test->interceptLogging();

my $accumulated_warn = "";
$eh->warn("This is a warning");
is($WebGUI::Test::logger_warns, "This is a warning", "warn: Log4perl called");
$accumulated_warn .= "This is a warning\n";
is($session->errorHandler->{_debug_warn}, $accumulated_warn, "warn: message internally appended");
$eh->warn("Second warning");
is($WebGUI::Test::logger_warns, "Second warning", "warn: Log4perl called again");
$accumulated_warn .= "Second warning\n";
is($session->errorHandler->{_debug_warn}, $accumulated_warn, "warn: second message appended");
$eh->security('Shields up, red alert');
my $security = sprintf '%s (%d) connecting from %s attempted to %s',
	$session->user->username, $session->user->userId, $session->env->getIp, 'Shields up, red alert';
is($WebGUI::Test::logger_warns, $security, 'security: calls warn with username, userId and IP address');

####################################################
#
# info, audit
#
####################################################

my $accumulated_info = '';
$eh->info("This is informative");
is($WebGUI::Test::logger_info, "This is informative", "info: Log4perl called");
$accumulated_info .= "This is informative\n";
is($session->errorHandler->{_debug_info}, $accumulated_info, "info: message internally appended");
$eh->info("More info");
is($WebGUI::Test::logger_info, "More info", "info: Log4perl called again");
$accumulated_info .= "More info\n";
is($session->errorHandler->{_debug_info}, $accumulated_info, "info: second message appended");
$eh->audit('Check this out');
my $audit = sprintf '%s (%d) %s', $session->user->username, $session->user->userId, 'Check this out';
is($WebGUI::Test::logger_info, $audit, 'audit: calls info with username and userId');

####################################################
#
# debug, query
#
####################################################

$eh->{'_debug_debug'} = ''; ##Manually clean debug
$eh->debug("This is a bug");
is($WebGUI::Test::logger_debug, "This is a bug", "debug: Log4perl called");
is($eh->{'_debug_debug'}, "This is a bug\n", "debug: message internally appended");
$eh->debug("More bugs");
is($WebGUI::Test::logger_debug, "More bugs", "debug: Log4perl called again");
is($eh->{'_debug_debug'}, "This is a bug\nMore bugs\n", "debug: second message appended");

$eh->{'_debug_debug'} = ''; ##Manually clean debug
my $queryCount = $eh->{_queryCount};
$eh->query('select this');
++$queryCount;
is($WebGUI::Test::logger_debug, "query $queryCount:\n  select this", "query: Log4perl called debug via query");

$eh->query('select that', 'literal');
++$queryCount;
is($WebGUI::Test::logger_debug, "query $queryCount:\n  select that", "query: Log4perl called debug via query, literal placeholder");

$eh->query('select more', []);
++$queryCount;
is($WebGUI::Test::logger_debug, "query $queryCount:\n  select more", "query: Log4perl called debug via query, empty placeholder");

$eh->query('select many', [1, 2]);
++$queryCount;
is($WebGUI::Test::logger_debug, "query $queryCount:\n  select many\n  with placeholders:  [1,2]", "query: Log4perl called debug via query, empty placeholder");

####################################################
#
# error
#
####################################################

$eh->{'_debug_debug'} = ''; ##Manually clean debug
$eh->error("ERROR");
is($WebGUI::Test::logger_error, "ERROR", "error: Log4perl called error");
like($WebGUI::Test::logger_debug, qr/^Stack trace for ERROR ERROR/, "error: Log4perl called debug");
is($eh->{'_debug_error'}, "ERROR\n", "error: message internally appended");
$eh->error("More errors");
is($WebGUI::Test::logger_error, "More errors", "error: Log4perl called error again");
is($eh->{'_debug_error'}, "ERROR\nMore errors\n", "error: new message internally appended");

####################################################
#
# getStackTrace
#
####################################################

is ($eh->getStackTrace, undef, 'no stack trace due to shallow depth, must be 2 deep for a stack trace');
like(&depth1(), qr/main(.*?)ErrorHandler\.t/, 'stack trace has correct information');

sub depth1 {
	return &depth2();
}

sub depth2 {
	return $eh->getStackTrace;
}

####################################################
#
# canShowBasedOnIP
#
####################################################

is($eh->canShowBasedOnIP(''), 0, 'canShowBasedOnIP: must send IP setting');

####################################################
#
# canShowDebug
#
####################################################


$session->setting->set('showDebug', 0);
delete $eh->{_canShowDebug};
ok(! $eh->canShowDebug, 'canShowDebug: returns 0 if not enabled');

$session->setting->set('showDebug', 1);
$session->http->setMimeType('audio/mp3');
delete $eh->{_canShowDebug};
ok(! $eh->canShowDebug, 'canShowDebug: returns 0 if mime type is wrong');

$session->http->setMimeType('text/html');
$session->setting->set('debugIp', '');
delete $eh->{_canShowDebug};
ok($eh->canShowDebug, 'canShowDebug: returns 1 if debugIp is empty string');

$session->setting->set('debugIp', '10.0.0.5/32, 192.168.0.4/30');
$newEnv{REMOTE_ADDR} = '172.17.0.5';
delete $eh->{_canShowDebug};
ok(! $eh->canShowDebug, 'canShowDebug: returns 0 if debugIp is set and IP address is out of filter');
$newEnv{REMOTE_ADDR} = '10.0.0.5';
delete $eh->{_canShowDebug};
ok($eh->canShowDebug, 'canShowDebug: returns 1 if debugIp is set and IP address matches filter');
$newEnv{REMOTE_ADDR} = '192.168.0.5';
delete $eh->{_canShowDebug};
ok($eh->canShowDebug, 'canShowDebug: returns 1 if debugIp is set and IP address matches filter');

####################################################
#
# canShowPerformanceIndicators
#
####################################################

$session->setting->set('showPerformanceIndicators', 0);
is($eh->canShowPerformanceIndicators, 0, 'canShowPerformanceIndicators: returns 0 if not enabled');

$session->setting->set('showPerformanceIndicators', 1);
$session->setting->set('debugIp', '');
is($eh->canShowPerformanceIndicators, 1, 'canShowPerformanceIndicators: returns 1 if debugIp is blank');

$session->setting->set('debugIp', '10.0.0.5/32, 192.168.0.4/30');
$newEnv{REMOTE_ADDR} = '172.17.0.5';
is($eh->canShowPerformanceIndicators, 0, 'canShowPerformanceIndicators: returns 0 if debugIp is set and IP address does not match');
$newEnv{REMOTE_ADDR} = '10.0.0.5';
is($eh->canShowPerformanceIndicators, 1, 'canShowPerformanceIndicators: returns 0 if debugIp is set and IP address matches exactly');
$newEnv{REMOTE_ADDR} = '192.168.0.5';
is($eh->canShowPerformanceIndicators, 1, 'canShowPerformanceIndicators: returns 0 if debugIp is set and IP address matches subnet');

####################################################
#
# showDebug
#
####################################################

my $form = $session->form;
$form = Test::MockObject::Extends->new($form);
$form->mock('paramsHashRef',
	sub {
		return {
			password => 'passWord',
			identifier => 'qwe123',
			username => 'Admin',
		};
	});

foreach my $entry (qw/_debug_error _debug_warn _debug_info _debug_debug/) {
	$eh->{$entry} = $entry . "\n";
}

my $showDebug = $eh->showDebug;

####################################################
#
# fatal, stub
#
####################################################

my $newSession = WebGUI::Session->open(WebGUI::Test::file);
addToCleanup($newSession);
my $outputBuffer;
open my $outputHandle, '>', \$outputBuffer or die "Unable to create scalar filehandle: $!\n";
$newSession->output->setHandle($outputHandle);
WEBGUI_FATAL: {
    $newSession->log->fatal('Bad things are happenning');
}
ok(1, 'fatal: recovered from fatal okay');
TODO: {
    local $TODO = 'Validate the fatal output';
    ok(0, 'output from fatal when there is a db handler and request present');
}

END {
}
