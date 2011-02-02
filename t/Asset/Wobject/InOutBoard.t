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
use Test::MockObject;
use Test::MockObject::Extends;

##The goal of this test is to test the creation of Article Wobjects.

use WebGUI::Test;
use WebGUI::Test::MockAsset;
use WebGUI::Test::Mechanize;
use WebGUI::Session;
use Test::More tests => 15; # increment this value for each test you create
use Test::Deep;
use Data::Dumper;

my $templateId = 'INOUTBOARD_TEMPLATE___';
my $templateMock = WebGUI::Test::MockAsset->new('WebGUI::Asset::Template');
$templateMock->mock_id($templateId);
my $templateVars;
$templateMock->mock('prepare', sub {  } );
$templateMock->mock('process', sub { $templateVars = $_[1]; } );
$templateMock->set_true('prepare');

use WebGUI::Asset::Wobject::InOutBoard;

my $session = WebGUI::Test->session;

#Build a bunch of users
my @names = qw/red andy hadley boggs/;

my @users = ();
foreach my $name (@names) {
    my $user = WebGUI::User->create($session);
    $user->username($name);
    push @users, $user;
}
WebGUI::Test->addToCleanup(@users);

my $board = WebGUI::Test->asset(
    className       => 'WebGUI::Asset::Wobject::InOutBoard',
);

$board->prepareView();

# Test for a sane object type
isa_ok($board, 'WebGUI::Asset::Wobject::InOutBoard');

################################################################
#
#  www_setStatus
#
################################################################

my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ user => $users[0] });

$mech->get_ok( $board->getUrl );
$mech->submit_form_ok({
    fields   => {
        status   => 'In',
        message  => 'work time',
    },
}, "update status" );
my $status;
$status = $session->db->quickHashRef('select * from InOutBoard_status where assetId=? and userId=?',[$board->getId, $users[0]->userId]);
cmp_deeply(
    $status,
    {
        assetId => $board->getId,
        userId  => $users[0]->getId,
        status  => 'In',
        message => 'work time',
        dateStamp => re('^\d+$'),
    },
    'www_setStatus: set status for a user'
);
my $statusLog;
$statusLog = $session->db->quickHashRef('select * from InOutBoard_statusLog where assetId=? and userId=?',[$board->getId, $users[0]->userId]);
cmp_deeply(
    $statusLog,
    {
        assetId => $board->getId,
        userId  => $users[0]->getId,
        status  => 'In',
        message => 'work time',
        dateStamp => re('^\d+$'),
        createdBy => $users[0]->getId, 
    },
    '... set statusLog for a user'
);

my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ user => $users[1] });

$mech->get_ok( $board->getUrl );
$mech->submit_form_ok({
    fields   => {
        status   => undef,
        message  => 'work time',
    },
});
$status = $session->db->quickHashRef('select * from InOutBoard_status where assetId=? and userId=?',[$board->getId, $users[1]->userId]);
cmp_deeply(
    $status,
    { },
    "... no status table entry made when the users's status is blank"
);
my $statusLog;
$statusLog = $session->db->quickHashRef('select * from InOutBoard_statusLog where assetId=? and userId=?',[$board->getId, $users[1]->userId]);
cmp_deeply(
    $statusLog,
    { },
    '... no statusLog set when status is blank'
);

################################################################
#
#  getStatusList
#
################################################################
$board->update({statusList => "In\r\nOut\rHome\nLunch"});
is_deeply [$board->getStatusList], [qw(In Out Home Lunch)], 'getStatusList';

################################################################
#
#  view
#
################################################################

$board->update({ inOutTemplateId => $templateId });
$board->prepareView;
$board->view;
cmp_bag(
    $templateVars->{rows_loop},
    [
        superhashof({
            deptHasChanged => ignore(),
            status         => 'In',
            dateStamp      => ignore(),
            message        => 'work time',
            username       => 'red',
        }),
        superhashof({ username => 'Admin' }),
        superhashof({ username => 'boggs' }),
        superhashof({ username => 'andy' }),
        superhashof({ username => 'hadley' }),
    ],
    'view: returns one entry for each user, entry is correct for user with status'
) or diag(Dumper $templateVars->{rows_loop});

################################################################
#
#  purge
#
################################################################

my $boardId = $board->getId;
$board->purge;
my $count;
$count = $session->db->quickScalar('select count(*) from InOutBoard_status where assetId=?',[$boardId]);
is ($count, 0, 'purge: cleans up status table');
$count = $session->db->quickScalar('select count(*) from InOutBoard_statusLog where assetId=?',[$boardId]);
is ($count, 0, '... cleans up statusLog table');
