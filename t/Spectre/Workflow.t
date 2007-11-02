# vim: syntax=perl
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
use warnings;
use lib "$FindBin::Bin/../lib", "../../wre/lib";
use WebGUI::Test;
use WebGUI::Session;
use Spectre::Admin;
use WebGUI::Config;
use WebGUI::Workflow::Cron;
use WebGUI::Workflow::Instance;
use WRE::Config;
use WRE::Modperl;
use WRE::Modproxy;
use WRE::Spectre;

use POE::Component::IKC::ClientLite;
use JSON;
use Config::JSON;
use Data::Dumper;

use Test::More tests => 10; # increment this value for each test you create

$|++;

my $session             = WebGUI::Test->session;
my $wreConfig           = WRE::Config->new;
my $isModPerlRunning    = WRE::Modperl->new (   wreConfig=>$wreConfig)->ping;
my $isModProxyRunning   = WRE::Modproxy->new(   wreConfig=>$wreConfig)->ping;
my $isSpectreRunning    = WRE::Spectre->new (   wreConfig=>$wreConfig)->ping;
my $spectreConfigFile   = WebGUI::Test->root . '/etc/spectre.conf';
my $spectreConfig       = Config::JSON->new($spectreConfigFile);
my $ip                  = $spectreConfig->get('ip');
my $port                = $spectreConfig->get('port');

# need to declare these before the skip block so that they're also visible in
# the todo block
my ($structure, $sitename);
SKIP: {
    skip "need modperl, modproxy, and spectre running to test", 10 unless ($isModPerlRunning && $isModProxyRunning && $isSpectreRunning);
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
    my $remote = create_ikc_client(
        port    => $port,
        ip      => $ip,
        name    => rand(100000),
        timeout => 10
    );
    my $result = $remote->post_respond('workflow/getJsonStatus');
    ok(defined $result, 'can call getJsonStatus');
    $remote->disconnect;
    undef $remote;
    ok($structure = jsonToObj($result), 'workflow/getJsonStatus returns a proper JSON data structure');
    cmp_ok(ref $structure, 'eq', 'HASH', 'workflow/getJsonStatus returns a JSON structure parseable into a Perl hashref');
    $sitename = $session->config->get('sitename')->[0];
    ok(exists $structure->{$sitename}, "$sitename exists in returned structure");
}

# Not sure how to handle these; the problem is that there may or may not be
# items in each queue type, and specifically constructing each key for each
# sitename in getJsonStatus even though they may not have data seems a bit
# contrived and kludgish.
TODO: {
    local $TODO = "tests to make later.";
    for my $key(qw/Suspended Waiting Running/) {
    ok(exists $structure->{$sitename}{$key}, "$key exists for $sitename");
    cmp_ok(ref $structure->{$sitename}{$key}, 'eq', 'ARRAY', "$key is an arrayref in the $sitename hash");
    }
}
