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

use Test::More;
use Test::MockObject::Extends;

my $numTests = 15;

plan tests => $numTests;

my $session = WebGUI::Test->session;

##Setup for security method test
my %newEnv = ( REMOTE_ADDR => '192.168.0.2' );
$session->env->{_env} = \%newEnv;

my ($eh) = $session->quick('errorHandler');
my $logger = $session->errorHandler->getLogger;
$logger = Test::MockObject::Extends->new( $logger );

is( $logger, $session->errorHandler->getLogger, 'Main logger mocked');

my ($warns, $debug, $info);

$logger->mock( 'warn',  sub { $warns = $_[1]} );
$logger->mock( 'debug', sub { $debug = $_[1]} );
$logger->mock( 'info',  sub { $info = $_[1]} );

####################################################
#
# warn, security
#
####################################################

my $accumulated_warn = "";
$eh->warn("This is a warning");
is($warns, "This is a warning", "warn: Log4perl called");
my $accumulated_warn .= "This is a warning\n";
is($session->errorHandler->{_debug_warn}, $accumulated_warn, "warn: message internally appended");
$eh->warn("Second warning");
is($warns, "Second warning", "warn: Log4perl called again");
$accumulated_warn .= "Second warning\n";
is($session->errorHandler->{_debug_warn}, $accumulated_warn, "warn: second message appended");
$eh->security('Shields up, red alert');
my $security = sprintf '%s (%d) connecting from %s attempted to %s',
	$session->user->username, $session->user->userId, $session->env->getIp, 'Shields up, red alert';
is($warns, $security, 'security: calls warn with username, userId and IP address');

####################################################
#
# info, audit
#
####################################################

my $accumulated_info = '';
$eh->info("This is informative");
is($info, "This is informative", "info: Log4perl called");
$accumulated_info .= "This is informative\n";
is($session->errorHandler->{_debug_info}, $accumulated_info, "info: message internally appended");
$eh->info("More info");
is($info, "More info", "info: Log4perl called again");
$accumulated_info .= "More info\n";
is($session->errorHandler->{_debug_info}, $accumulated_info, "info: second message appended");
$eh->audit('Check this out');
my $audit = sprintf '%s (%d) %s', $session->user->username, $session->user->userId, 'Check this out';
is($info, $audit, 'audit: calls info with username and userId');

####################################################
#
# debug
#
####################################################

$eh->{'_debug_debug'} = ''; ##Manually clean debug
$eh->debug("This is a bug");
is($debug, "This is a bug", "debug: Log4perl called");
is($eh->{'_debug_debug'}, "This is a bug\n", "debug: message internally appended");
$eh->debug("More bugs");
is($debug, "More bugs", "debug: Log4perl called again");
is($eh->{'_debug_debug'}, "This is a bug\nMore bugs\n", "debug: second message appended");
