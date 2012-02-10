# vim: syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use warnings;

use Test::More;


use WebGUI::Test;
use WebGUI::Paths;
use WebGUI::Session;
use Spectre::Admin;
use WebGUI::Config;
use WebGUI::Workflow::Cron;
use WebGUI::Workflow::Instance;

use POE::Component::IKC::ClientLite;
use JSON;
use Config::JSON;
use Carp qw(croak);
plan tests => 19;



$|++;

my $session             = WebGUI::Test->session;
my $spectreConfigFile   = WebGUI::Paths->spectreConfig;
my $spectreConfig       = Config::JSON->new($spectreConfigFile);
my $ip                  = $spectreConfig->get('ip');
my $port                = $spectreConfig->get('port');

# need to declare these out here so that they're visible in the TODO: block as well
my ($allSitesStructure, $oneSiteStructure, $sitename);
$sitename = $session->config->get('sitename')->[0];

# tests for retrieving more than one site, the default
SKIP: {
    if (! eval { spectre_ping($spectreConfig) } ) {
        skip "Spectre doesn't seem to be running: $@", 7;
    }
    # XXX kinda evil kludge to put an activity in the scheduler so that the
    # below calls return data; suggestions on a better way to do this welcomed.
    my $taskId = 'pbcron0000000000000001'; # hopefully people don't delete daily maintenance
    my $task = WebGUI::Workflow::Cron->new($session, $taskId);
    # just in case they did...
    skip "need daily maintenance task for test", 10 unless defined $task;
    my $instance = WebGUI::Workflow::Instance->create($session, {
        workflowId  => $task->get('workflowId'),
        className   => $task->get('className'),
        methodName  => $task->get('methodName'),
        parameters  => $task->get('parameters'),
        priority    => $task->get('priority'),
        },
    );
    $instance->start;
    my $remote = create_ikc_client(
        port    => $port,
        ip      => $ip,
        name    => rand(100000),
        timeout => 10
    );
    my $allSitesResult  = $remote->post_respond('workflow/getJsonStatus');
    my $oneSiteResult   = $remote->post_respond('workflow/getJsonStatus', $sitename);
    ok(defined $allSitesResult, 'can call getJsonStatus for all sites');
    ok(defined $oneSiteResult,  "can call getJsonStatus for $sitename");
    $remote->disconnect;
    undef $remote;

    # first test the data structure returned for all sites
    ok($allSitesStructure = from_json($allSitesResult), 'workflow/getJsonStatus for all sites returns a proper JSON data structure');
    isa_ok($allSitesStructure, 'HASH', 'workflow/getJsonStatus for all sites returns a JSON structure parseable into a Perl hashref');
    ok(exists $allSitesStructure->{$sitename}, "$sitename exists in all sites result structure");

    # then check it for the old style, single site result structure
    ok($oneSiteStructure = from_json($oneSiteResult),  'workflow/getJsonStatus for one site returns a proper JSON data structure');
    isa_ok($oneSiteStructure, 'HASH', 'workflow/getJsonStatus for one site returns a JSON structure parseable into a Perl hashref');
}

# Not sure how to handle these; the problem is that there may or may not be
# items in each queue type, and specifically constructing each key for each
# sitename in getJsonStatus even though they may not have data seems a bit
# contrived and kludgish.
TODO: {
    local $TODO = "tests to make later.";
    foreach my $key(qw/Suspended Waiting Running/) {
        ok(exists $allSitesStructure->{$sitename}{$key}, "$key exists for $sitename in all sites structure");
        isa_ok($allSitesStructure->{$sitename}{$key}, 'ARRAY', "$key is an arrayref in the $sitename hash in all sites structure");

        ok(exists $oneSiteStructure->{$key}, "$key exists for $sitename in one site structure");
        isa_ok($oneSiteStructure->{$key}, 'ARRAY', "$key is an arrayref in the $sitename hash in one site structure");
    }
}

sub spectre_ping {
    my $spectreConfig = shift;
    my $remote = create_ikc_client(
        port    => $spectreConfig->get("port"),
        ip      => $spectreConfig->get("ip"),
        name    => rand(100000),
        timeout => 10
    );
    unless ($remote) {
        croak "Couldn't connect to Spectre because ".$POE::Component::IKC::ClientLite::error;
    }
    my $result = $remote->post_respond('admin/ping');
    $remote->disconnect;
    unless (defined $result) {
        croak "Didn't get a response from Spectre because ".$POE::Component::IKC::ClientLite::error;
    }
    undef $remote;
    if ($result eq "pong") {
        return 1;
    } else {
        croak "Received '".$result."' when we expected 'pong'.";
    }
}

