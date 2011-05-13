
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Form;
use WebGUI::Form::Group;
use WebGUI::Group;
use WebGUI::Session;

#The goal of this test is to verify that various www_ methods for the Group plugin work.

use Test::More;
use Test::Deep;
use JSON ();
use Data::Dumper;

my $session = WebGUI::Test->session;

# put your tests here

plan tests => 11;

my $groupAdminUser = WebGUI::User->new($session, 'new');
my $groupAdminGroup = WebGUI::Group->new($session, 'new');
$groupAdminGroup->addUsers([$groupAdminUser->userId]);
$session->setting->set('groupIdAdminGroup', $groupAdminGroup->getId);
WebGUI::Test->addToCleanup($groupAdminUser, $groupAdminGroup);

my $json;

$json = WebGUI::Form::Group::www_searchGroups($session);
is $json, '{"results":[]}', 'www_searchGroups: unprivileged user is not allowed to use this';

$session->user({user => $groupAdminUser});
$json = WebGUI::Form::Group::www_searchGroups($session);
is $json, '{"results":[]}', '... without a body parameter, returns valid empty JSON array';

$session->request->setup_body({query => 'Registered Users'});
$json = WebGUI::Form::Group::www_searchGroups($session);
my $group_data = JSON::from_json($json);
cmp_deeply(
    $group_data,
    {
    results => [
    {
        groupId   => 2,
        groupName => 'Registered Users',
    },
    ],
    },
    '... with an exact match, get one result back'
);

{
    my @groups = map { my $group = WebGUI::Group->new($session, 'new'); $group->name('Test Group '. $_); $group; } 1..20;
    my $cleanup = WebGUI::Test->cleanupGuard(@groups);
    $session->request->setup_body({query => 'Test Group'});
    $json = WebGUI::Form::Group::www_searchGroups($session);
    my $group_data = JSON::from_json($json);
    is scalar @{ $group_data->{results} }, 15, '... results are limited to 15';
}

{
    my @groups = map { my $group = WebGUI::Group->new($session, 'new'); $group->name('Test Group '. $_); $group; } 1..5;
    $groups[0]->showInForms(0);
    my $cleanup = WebGUI::Test->cleanupGuard(@groups);
    $session->request->setup_body({query => 'Test Group'});
    $json = WebGUI::Form::Group::www_searchGroups($session);
    my $group_data = JSON::from_json($json);
    my $has_group0 = grep { $_->{groupName} eq $groups[0]->name } @{ $group_data->{results} };
    ok ! $has_group0, '... group with showInForms set to false does not show up in the results';
}

my $test_group = WebGUI::Group->new($session, 'new');
$test_group->name('Testing Group');

my $andy = WebGUI::User->new($session, 'new');
$andy->username('andy');

my $red = WebGUI::User->new($session, 'new');
$red->username('red');

WebGUI::Test->addToCleanup($test_group, $andy, $red);

$session->request->setup_body({});
$session->user({userId => 1});
$json = WebGUI::Form::Group::www_groupMembers($session);
is $json, '{}', 'www_groupMembers: returns empty hashref for an unprivileged user';

$session->user({user => $groupAdminUser});
$json = WebGUI::Form::Group::www_groupMembers($session);
is $json, '{}', '... returns empty hashref if no form variable';

                                          #1234567890123456789012
$session->request->setup_body({groupId => 'neverAWebGUIGroupId001'});
$json = WebGUI::Form::Group::www_groupMembers($session);
is $json, '{}', 'www_groupMembers: returns empty hashref if no groupId does not exist in the db';

$session->request->setup_body({groupId => $test_group->getId});
$json = WebGUI::Form::Group::www_groupMembers($session);
$group_data = JSON::from_json($json);
cmp_deeply(
    $group_data,
    {
        groupName => 'Testing Group',
        users   => [ ],
        groups  => [
            {
                groupId => '3',
                groupName => 'Admins',
            },
        ],
    },
    '... with an exact match on an empty group, returns a hashref with arrayrefs'
);

$test_group->addUsers([$andy->getId]);
$json = WebGUI::Form::Group::www_groupMembers($session);
$group_data = JSON::from_json($json);
cmp_deeply(
    $group_data,
    {
        groupName => 'Testing Group',
        users   => [
            {
                userId   => $andy->userId,
                username => 'andy',
            }
        ],
        groups  => [
            {
                groupId   => '3',
                groupName => 'Admins',
            },
        ],
    },
    '... with an exact match on a populated group, return users and groups'
);

$test_group->addGroups(['2']);
$json = WebGUI::Form::Group::www_groupMembers($session);
$group_data = JSON::from_json($json);
cmp_deeply(
    $group_data,
    {
        groupName => 'Testing Group',
        users   => [
            {
                userId   => $andy->userId,
                username => 'andy',
            }
        ],
        groups  => bag(
            {
                groupId   => '2',
                groupName => 'Registered Users',
            },
            {
                groupId   => '3',
                groupName => 'Admins',
            },
        ),
    },
    '... users not listed recursively, groups do not show up twice'
);


