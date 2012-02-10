
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::Form::User;
use WebGUI::Group;
use WebGUI::Session;

#The goal of this test is to verify that various www_ methods for the Group plugin work.

use Test::More;
use Test::Deep;
use JSON ();
use Data::Dumper;

my $session = WebGUI::Test->session;

# put your tests here

plan tests => 4;

my $userAdminUser = WebGUI::User->new($session, 'new');
my $userAdminGroup = WebGUI::Group->new($session, 'new');
$userAdminGroup->addUsers([$userAdminUser->userId]);
$session->setting->set('groupIdAdminUser', $userAdminGroup->getId);
WebGUI::Test->addToCleanup($userAdminUser, $userAdminGroup);

my $json;

$json = WebGUI::Form::User::www_searchUsers($session);
is $json, '{"results":[]}', 'www_searchUsers: unprivileged user is not allowed to use this';

$session->user({user => $userAdminUser});
$json = WebGUI::Form::User::www_searchUsers($session);
is $json, '{"results":[]}', '... without a body parameter, returns valid empty JSON array';

$session->request->setup_body({query => 'Visitor'});
$json = WebGUI::Form::User::www_searchUsers($session);
my $group_data = JSON::from_json($json);
cmp_deeply(
    $group_data,
    {
    results => [
    {
        userId   => 1,
        username => 'Visitor',
    },
    ],
    },
    '... with an exact match, get one result back'
);

{
    my @users = map { my $user = WebGUI::User->new($session, 'new'); $user->username('Test User '. $_); $user; } 1..20;
    my $cleanup = WebGUI::Test->cleanupGuard(@users);
    $session->request->setup_body({query => 'Test User'});
    $json = WebGUI::Form::User::www_searchUsers($session);
    my $group_data = JSON::from_json($json);
    is scalar @{ $group_data->{results} }, 15, '... results are limited to 15';
}


