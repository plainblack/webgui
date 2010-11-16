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

my $varSession = WebGUI::Session->open($session->config);
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


my $var2 = WebGUI::Session->open($session->config, undef, 'illegalSessionIdThatIsTooLong');
#                                      '1234567890123456789012'
isa_ok($var2, 'WebGUI::Session', 'invalid sessionId will still produce a Session object');
($count) = $session->db->quickArray("select count(*) from userSession where sessionId=?",[$var2->getId]);
is($count, 0, "object store of sessionId does not match database record");
my $var2Id = $var2->getId;
$var2->end;
my $idToDelete = substr $var2Id,0,22;
($count) = $session->db->quickArray("select count(*) from userSession where sessionId=?",[$idToDelete]);
is($count, 1, "Unable to delete database record for Var object with invalid sessionId");


done_testing;

#vim:ft=perl
