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

use WebGUI::User;

use Test::More;
use Test::Deep;

my $session = WebGUI::Test->session;

my $user = WebGUI::User->new($session, "new");
WebGUI::Test->addToCleanup($user);

$session->user({user => $user});

my ($userId) = $session->db->quickArray("select userId from userSession where sessionId=?",[$session->getId]);

is($userId, $user->userId, 'changing session user changes sessionId inside userSession table');

$session->user({userId => 3});
is($session->user->userId,  3, 'Set session user to Admin, check userId==3');
is($session->user->get('uiLevel'), 9, 'Set session user to Admin, check uiLevel==9');

my $dupe = $session->duplicate;
WebGUI::Test->addToCleanup($dupe);

is($session->get('sessionId'), $session->getId, 'getId returns sessionId');

is $dupe->getId, $session->getId, 'duplicated session has the same sessionId';

################################################################
#
# dbSlave
#
################################################################

##Manually build one dbSlave in the config file to use

my $slaveHash2 = {
    dsn  => $session->config->get('dsn'),
    user => $session->config->get('dbuser'),
    pass => $session->config->get('dbpass'),
};

$session->config->set('dbslave2', $slaveHash2);
WebGUI::Test->addToCleanup(sub {$session->config->delete('dbslave2');});

my $slave2 = $session->dbSlave;
isa_ok($slave2, 'WebGUI::SQL::db');

cmp_ok($session->get("lastPageView"), '>', 0, "lastPageView set to something");

can_ok($session, qw/isAdminOn switchAdminOn switchAdminOff/);
is($session->isAdminOn, 0, "isAdminOn()");
$session->switchAdminOn;
is($session->isAdminOn, 1, "switchAdminOn()");
$session->switchAdminOff;
is($session->isAdminOn, 0, "switchAdminOff()");

my $token = $session->scratch->get('webguiCsrfToken');
ok( $token, 'CSRF token set');
ok( $session->id->valid($token), '...is a valid GUID');

my $id = $session->getId;
my ($count) = $session->db->quickArray("select count(*) from userSession where sessionId=?", [$id]);
is($count, 1, "created an user session entry in the database");

my $env;
$session->request->env->{REMOTE_ADDR} = '192.168.0.34';

my $varSession = WebGUI::Session->open($session->config, $session->request->env);
WebGUI::Test->addToCleanup($varSession);
my $varTime = time();
isnt($varSession->scratch->get('webguiCsrfToken'), $token, '... calling new without sessionId creates a new token');
isnt($varSession->getId, $session->getId, "new session has a different id from current session");

my $varExpires = $varTime + $session->setting->get('sessionTimeout');
cmp_ok(abs($varSession->get('lastPageView') - $varTime), '<=', 1, 'lastPageView set correctly');
cmp_ok(abs($varSession->get('expires') - $varExpires), '<=', 1, 'expires set correctly');

is($varSession->get('userId'), 1, 'default userId is 1');

is($varSession->get('adminOn'), $varSession->isAdminOn, "get('adminOn') and isAdminOn return the same thing");
is($varSession->get('adminOn'), 0, "adminOn is off by default"); ##retest
is($varSession->get('lastIP'), '192.168.0.34', "lastIP fetched");


my $illegalSessionId = 'illegalSessionIdThatIsTooLong';
#                      '1234567890123456789012'
my $varIllegal = WebGUI::Session->open($session->config, undef, );
WebGUI::Test->addToCleanup($varIllegal);

isa_ok($varIllegal, 'WebGUI::Session', 'invalid sessionId will still produce a Session object');
ok($session->id->valid($varIllegal->getId), 'valid ID created for the new session, when bad Id was suggested');
ok(index($varIllegal->getId, $illegalSessionId) == -1, 'illegal session was not truncated to make the new Id'); 

$session->request->env->{REMOTE_ADDR} = '10.0.0.5';
my $varCopy = WebGUI::Session->open($session->config, $session->request->env, $varSession->getId);
is($varCopy->scratch->get('webguiCsrfToken'), $varSession->scratch->get('webguiCsrfToken'), 'opening a copy of a user session did not change the CSRF token');

cmp_deeply(
	$varCopy,
	methods(
		['get', 'sessionId'] => $varSession->get('sessionId'),
		['get', 'userId']    => $varSession->get('userId'),
		['get', 'adminOn']   => $varSession->get('adminOn'),
	),
	'similar methods in copy of original var object'
);

is($varCopy->get('lastIP'), '10.0.0.5', "lastIP set on copy");

my $varSessionId = $varSession->getId;
$varSession->end;
($count) = $session->db->quickArray("select count(*) from userSession where sessionId=?",[$varSession->getId]);
ok($count == 0,"end() removes current entry from database");

{
    my $sessionId = 'nonExistantIdButValid0';
    #            '1234567890123456789012'
    my $testSession = WebGUI::Session->open($session->config, undef, $sessionId);
    my $guard       = WebGUI::Test->cleanupGuard($testSession);
    isa_ok($testSession, 'WebGUI::Session', 'non-existant sessionId will still produce a Var object');
    is($testSession->getId,  $sessionId, 'user session Id set to non-existant Id');
}

{
    my $expire = WebGUI::Session->open($session->config);
    my $guard  = WebGUI::Test->cleanupGuard($expire);
    $expire->switchAdminOn;
    # jury rig the database and the cache to expire
    my $expire_time = $expire->get('lastPageView') - 1;
    $session->db->write("update userSession set userId=?, expires=? where sessionId=?",  [3, $expire_time, $expire->getId]);
    $session->user({userId => 3});
    my $copyOfSession = { %{ $expire->get() } };
    $copyOfSession->{expires} = $expire_time;
    $session->cache->set($expire->getId, $copyOfSession);
    
    my $copy = WebGUI::Session->open($session->config, undef, $expire->getId);
    my $guard2 = WebGUI::Test->cleanupGuard($copy);
    is   $copy->getId,         $expire->getId,     'new Var object has correct id';
    isnt $copy->isAdminOn,     $expire->isAdminOn, 'new adminOn not equal to old adminOn';
    is   $copy->isAdminOn,     0, 'new Var object has default adminOn';
    isnt $copy->get('userId'), 3, 'new userId not equal to old userId';
}

{
    ##Var objects for noFuss tests
    my $trial    = WebGUI::Session->open($session->config);
    my $expiring = WebGUI::Session->open($session->config);
    my $guard = WebGUI::Test->cleanupGuard($trial, $expiring);
    $session->db->write("update userSession set expires=? where sessionId=?", [$expiring->get('lastPageView')-5, $expiring->getId]);
    $expiring->{_var}{expires} = $expiring->get('lastPageView')-5;

    ##Valid fetch with no fuss
    my $varTest = WebGUI::Session->open($session->config, $session->request->env, $trial->getId, 1);
    my $guard2 = WebGUI::Test->cleanupGuard($varTest);

    cmp_deeply(
        $varTest,
        methods(
            ['get', 'sessionId']    => $trial->getId,
            ['get', 'userId']       => 1,
            ['get', 'adminOn']      => 0,
            ['get', 'lastIP']       => '127.0.0.1',
            ['get', 'expires']      => $trial->get('expires'),
            ['get', 'lastPageView'] => $trial->get('lastPageView'),
        ),
        'fetching a valid session with noFuss does not update the object info'
    );

    ##Test a valid fetch
    my $expired = WebGUI::Session->open($session->config, undef, $expiring->getId, 1);
    my $guard3  = WebGUI::Test->cleanupGuard($expired);

    cmp_deeply(
        $expired,
        methods(
            ['get', 'sessionId']    => $expiring->getId,
            ['get', 'userId']       => 1,
            ['get', 'adminOn']      => 0,
            ['get', 'lastIP']       => '127.0.0.1',
            ['get', 'lastPageView'] => $expiring->get('lastPageView'),
            ['get', 'expires']      => $expiring->get('expires'),
        ),
        'fetching a valid session with noFuss does not update the object info, even if it has expired'
    );

}

my $varId4 = 'idDoesNotExist00779988';
#            '1234567890123456789012'
my $varTest = WebGUI::Session->open($session->config, undef, $varId4, 1);
WebGUI::Test->addToCleanup($varTest);
isa_ok($varTest, "WebGUI::Session", "non-existant Id with noFuss returns a valid object...");
is($varTest->getId, $varId4, "...and we got our requested Id");

$varTest->start(3, $varTest->getId);
is($varTest->get('userId'), 3, 'userId set via start');
$varTest->start("", $varTest->getId);
is($varTest->get('userId'), 1, 'calling start with null userId returns default user (visitor)');


done_testing;

#vim:ft=perl
