# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# WebGUI::Fork tests

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/lib";
use lib "$FindBin::Bin/../lib";

use Test::More;
use Test::Deep;
use Data::Dumper;
use JSON;

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Fork;

my $class     = 'WebGUI::Fork';
my $testClass = 'WebGUI::Test::Fork';
my $pipe      = $class->init();
my $session   = WebGUI::Test->session;

# test simplest (non-forking) case

my $process = $class->create($session);
my $request = $process->request( $testClass, 'simple', ['data'] );

cmp_bag(
    [ keys %$request ],
    [qw(configFile sessionId id module subname data)],
    'request hash has the right keys'
);

my $now = time;

$class->runRequest($request);
ok $process->isFinished, 'finished';
my $error = $process->getError;
ok( !$error, 'no errors' ) or diag "  Expected nothing, got: $error\n";
$process->setWait(0);
is $process->getStatus, 'data', 'proper status';
my $started = $process->startTime;
ok( ( $started >= $now ), 'sane startTime' );
ok( ( $process->endTime >= $started ), 'sane endTime' );

$process->delete;

note "Testing error case\n";
$process = $class->create($session);
$request = $process->request( $testClass, 'error', ['error'] );
$class->runRequest($request);
ok $process->isFinished, 'finished';
is $process->getError, "error\n", 'has error code';
$process->setWait(0);
my $status = $process->getStatus;
ok( !$status, 'no discernable status' ) or diag $status;
ok( ( $process->endTime >= $started ), 'sane endTime' );

my $forkCount   = 0;
my $forkAndExec = $class->can('forkAndExec');
my $replace     = sub {
    my $self = shift;
    $forkCount++;
    $self->$forkAndExec(@_);
};

{
    no strict 'refs';
    no warnings 'redefine';
    *{ $class . '::forkAndExec' } = $replace;
}

sub backgroundTest {
    note "$_[0]\n";
    $process = $class->start( $session, $testClass, 'complex', ['data'] );
    my $sleeping;
    while ( !$process->isFinished && $sleeping++ < 10 ) {
        sleep 1;
    }
    ok $process->isFinished, 'finished';
    is $process->getStatus, 'baz', 'correct status'
        or diag $process->getError . "\n";

    $process->delete;
}
backgroundTest('talk to background');
is $forkCount, 0, 'we did not fork';
close $pipe;
backgroundTest('On-demand fork');
is $forkCount, 1, 'we did fork';

ok(WebGUI::Test->waitForAllForks(10), "Forks finished");

done_testing;

#vim:ft=perl
