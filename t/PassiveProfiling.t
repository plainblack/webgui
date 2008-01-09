#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";

use WebGUI::Test;

my $session = WebGUI::Test->session;

use WebGUI::Session;
use WebGUI::VersionTag;
use WebGUI::Asset;

use Test::More;
use Test::Deep;

my $startingTime = $session->datetime->time();

my $numTests = 3; # increment this value for each test you create
plan tests => 1 + $numTests;

my $origPassiveProfiling = $session->setting->get('passiveProfilingEnabled');
my $loaded = use_ok('WebGUI::PassiveProfiling');

my $versionTag = WebGUI::VersionTag->getWorking($session);
my $home = WebGUI::Asset->getDefault($session);

SKIP: {

skip 'Module was not loaded, skipping all tests', $numTests -1 unless $loaded;

$session->setting->set('passiveProfilingEnabled', 0);

WebGUI::PassiveProfiling::add( $session, $home->getId );

my $count = $session->db->quickScalar('select count(*) from passiveProfileLog where assetId=? and dateOfEntry >= ?',[$home->getId, $startingTime]);

is($count, 0, 'add: Nothing added if passive profiling is not enabled');

$session->setting->set('passiveProfilingEnabled', 1);

my $timeLogged;
$timeLogged = $session->datetime->time();
WebGUI::PassiveProfiling::add( $session, $home->getId );

my $count = $session->db->quickScalar('select count(*) from passiveProfileLog where assetId=? and dateOfEntry >= ?',[$home->getId, $startingTime]);

is($count, 1, 'add: Enabling passiveProfiling in the settings allows it to work, only 1 log entry added');

my $logEntry = $session->db->quickHashRef('select * from passiveProfileLog where assetId=? and dateOfEntry >= ?',[$home->getId, $startingTime]);

cmp_deeply(
    $logEntry,
    {
        passiveProfileLogId => re($session->id->getValidator),
        userId              => 1,
        sessionId           => $session->getId,
        assetId             => $home->getId,
        dateOfEntry         => num($timeLogged, 2),
    },
    'add: Correct information added for logged asset',
);

}

END: {
    $session->setting->set('passiveProfilingEnabled', $origPassiveProfiling);
    $session->db->write('delete from passiveProfileLog where dateOfEntry >= ?',[$startingTime-1]);
    $versionTag->rollback;
}
