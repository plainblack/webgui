use warnings;
use strict;

use FindBin;
use lib "$FindBin::Bin/../../lib";
use lib "$FindBin::Bin/../../t/lib";

use WebGUI::Test;
use Test::More tests => 28;
use Test::MockObject;
use Test::MockObject::Extends;
use WebGUI::Workflow::Activity;
use Kwargs;
use URI;

my $session = WebGUI::Test->session;
WebGUI::Test->originalConfig('templateParsers');
$session->config->addToArray('templateParsers', 'WebGUI::Asset::Template::TemplateToolkit');

my $act = WebGUI::Workflow::Activity->newByPropertyHashRef(
    $session, {
        className      => 'WebGUI::Workflow::Activity::WaitForUserConfirmation',
        activityId     => 'test-activity',
        expireAfter    => 60*60*24,
        waitBetween    => 60*5,
        emailFrom      => 3,
        emailSubject   => 'Confirmation Email',
        templateParser => 'WebGUI::Asset::Template::TemplateToolkit',
        template       => 'Hey [% user.firstName %] [% user.lastName %], '
            . 'click $link!',
    }
);

is $act->wait, $act->WAITING(60*5), 'wait helper method';

$act = Test::MockObject::Extends->new($act);

my (%scratch, %profile);
%profile = (
    email     => 'target@test.com',
    firstName => 'Target',
    lastName  => 'Targetson',
);

my $user = Test::MockObject->new
    ->mock(get => sub { \%profile })
    ->mock(userId => sub { 'test-user-id' });

my $workflow = Test::MockObject->new
    ->mock(setScratch => sub { $scratch{$_[1]} = $_[2] })
    ->mock(getScratch => sub { $scratch{$_[1]} })
    ->mock(getId      => sub { 'test-workflow' });

my ($expired, $sent) = (0,0);
$act->mock(sendEmail => sub { $sent++ })
    ->mock(expire => sub { $expired++ })
    ->mock(now => sub { 100 })
    ->mock(token => sub { 'test-token' });

my $st = 'test-activity-status';

sub ex { $act->execute($user, $workflow) }
sub clr {
    delete @scratch{'test-activity-started', $st};
    $sent = 0;
    $expired = 0;
}

is ex, $act->wait, 'from scratch returns waiting';
is $sent, 1, 'one email sent';
is $scratch{$st}, 'waiting', 'scratch is waiting';
is $scratch{'test-activity-started'}, 100, 'started at mocked time';
is ex, $act->wait, 'still waiting';
is $sent, 1, 'did not send second email';
is $scratch{$st}, 'waiting', 'scratch still waiting';
$scratch{$st} = 'done';
is ex, $act->COMPLETE, 'returns complete after done';
is ex, $act->COMPLETE, 'forever';
is $expired, 0, 'not expired though';
clr;
is $act->execute($user, $workflow), $act->wait, 'waiting after clear';
is $sent, 1, 'one email sent';
$act->mock(now => sub { 60*60*24+101 });
is ex, $act->COMPLETE, 'complete after expired';
is $scratch{$st}, 'expired', 'expired status';
is $expired, 1, 'expire called';

clr;
my ($self, $to, $from, $subject, $body);
$act->mock(
    sendEmail => sub {
        ($self, $to, $from, $subject, $body) = kwn @_, 1,
            qw(to from subject body);
    }
);
ex;
is $to, $user->userId, 'to';
is $from, 3, 'from';
is $subject, 'Confirmation Email', 'subject';
my $link = URI->new($act->link($workflow));
my %p    = $link->query_form;
is $body, "Hey Target Targetson, click $link!", 'body';
is $p{token}, 'test-token', 'token in link';
is $p{instanceId}, 'test-workflow', 'instance id in link';
is $p{activityId}, 'test-activity', 'activity id in link';
$act->unmock('token');
is $act->link($workflow), $link, 'token only generated once';

ok !$act->confirm($workflow, 'not-the-token'), 'bad token';
is $scratch{$st}, 'waiting', 'wait after bad';
ok $act->confirm($workflow, 'test-token'), 'good token';
is $scratch{$st}, 'done', 'done after good';
