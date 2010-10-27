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

use Test::More;
use Test::MockObject::Extends;
use Try::Tiny;

my $numTests = 13;

plan tests => $numTests;

my $session = WebGUI::Test->session;

##Setup for security method test
my $env = $session->request->env;
$env->{REMOTE_ADDR} = '192.168.0.6';

my $log = $session->log;

####################################################
#
# warn, security
#
####################################################

WebGUI::Test->interceptLogging( sub {
    my $log_data = shift;

    my $accumulated_warn = "";
    $log->warn("This is a warning");
    is($log_data->{warn}, "This is a warning", "warn: Log4perl called");
    $log->warn("Second warning");
    is($log_data->{warn}, "Second warning", "warn: Log4perl called again");
    $log->security('Shields up, red alert');
    my $security = sprintf '%s (%d) connecting from %s attempted to %s',
        $session->user->username, $session->user->userId, $session->request->address, 'Shields up, red alert';
    is($log_data->{warn}, $security, 'security: calls warn with username, userId and IP address');
});

####################################################
#
# info, audit
#
####################################################

WebGUI::Test->interceptLogging( sub {
    my $log_data = shift;
    $log->info("This is informative");
    is($log_data->{info}, "This is informative", "info: Log4perl called");
    $log->info("More info");
    is($log_data->{info}, "More info", "info: Log4perl called again");
    $log->audit('Check this out');
    my $audit = sprintf '%s (%d) %s', $session->user->username, $session->user->userId, 'Check this out';
    is($log_data->{info}, $audit, 'audit: calls info with username and userId');
});

####################################################
#
# debug
#
####################################################

WebGUI::Test->interceptLogging( sub {
    my $log_data = shift;
    $log->debug("This is a bug");
    is($log_data->{debug}, "This is a bug", "debug: Log4perl called");
    $log->debug("More bugs");
    is($log_data->{debug}, "More bugs", "debug: Log4perl called again");
});

####################################################
#
# error
#
####################################################

WebGUI::Test->interceptLogging( sub {
    my $log_data = shift;
    $log->error("ERROR");
    is($log_data->{error}, "ERROR", "error: Log4perl called error");
    $log->error("More errors");
    is($log_data->{error}, "More errors", "error: Log4perl called error again");
});

####################################################
#
# fatal, stub
#
####################################################

WebGUI::Test->interceptLogging( sub {
    my $log_data = shift;
    my $thrown = try {
        $log->fatal('Bad things are happenning');
        fail 'fatal throws exception';
        fail ' ... exception isa WebGUI::Exception::Fatal';
    }
    catch {
        pass 'fatal throws exception';
        isa_ok $_, 'WebGUI::Error::Fatal';
    };
    is $log_data->{fatal}, 'Bad things are happenning', 'fatal: logger called correctly';
});
