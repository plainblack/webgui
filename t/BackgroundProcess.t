# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# WebGUI::BackgroundProcess tests

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
use WebGUI::BackgroundProcess;

my $session   = WebGUI::Test->session;
my $class     = 'WebGUI::BackgroundProcess';
my $testClass = 'WebGUI::Test::BackgroundProcess';

# test simplest (non-forking) case

my $process = $class->create($session);
my @argv    = $process->argv( $testClass, 'simple', ['data'] );
my $hash    = $class->argvToHash( \@argv );

is ref $hash, 'HASH', 'got hash from argv';
cmp_bag(
    [ keys %$hash ],
    [ qw(webguiRoot configFile sessionId id module subname data) ],
    'argvToHash has the right keys'
);

my $now = time;

$class->runFromHash($hash);
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
@argv    = $process->argv( $testClass, 'error', ['error'] );
$hash    = $class->argvToHash( \@argv );
$class->runFromHash($hash);
ok $process->isFinished, 'finished';
is $process->getError, "error\n", 'has error code';
$process->setWait(0);
my $status = $process->getStatus;
ok( !$status, 'no discernable status' ) or diag $status;
ok( ( $process->endTime >= $started ), 'sane endTime' );

note "Testing with actual fork\n";
$process = $class->start( $session, $testClass, 'complex', ['data'] );
my $sleeping;
while ( !$process->isFinished && $sleeping++ < 10 ) {
    sleep 1;
}
ok $process->isFinished, 'finished';
is $process->getStatus, 'baz', 'correct status'
    or diag $process->getError . "\n";

$process->delete;

done_testing;

#vim:ft=perl
