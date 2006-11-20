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

my $numTests = 13;

plan tests => $numTests;

my $session = WebGUI::Test->session;

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
# warn
#
####################################################

$eh->warn("This is a warning");
is($warns, "This is a warning", "warn: Log4perl called");
is($session->errorHandler->{_debug_warn}, "This is a warning\n", "warn: message internally appended");
$eh->warn("Second warning");
is($warns, "Second warning", "warn: Log4perl called again");
is($session->errorHandler->{_debug_warn}, "This is a warning\nSecond warning\n", "warn: second message appended");

####################################################
#
# info
#
####################################################

$eh->info("This is informative");
is($info, "This is informative", "info: Log4perl called");
is($session->errorHandler->{_debug_info}, "This is informative\n", "info: message internally appended");
$eh->info("More info");
is($info, "More info", "info: Log4perl called again");
is($session->errorHandler->{_debug_info}, "This is informative\nMore info\n", "info: second message appended");

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
