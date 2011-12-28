#-------------------------------------------------------------------
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
use WebGUI::Session;
use WebGUI::Utility;

use WebGUI::User;
use WebGUI::Group;
use WebGUI::Cache;

use Test::More skip_all => 'Disabled until the test LDAP server is rejuvenated';
use Test::Deep;

my @ldapTests = (
            {
				dn => 'uid=Byron Hadley,o=shawshank',
				comment => 'bad dn for group',
				expect  => 0,
			},
			{
				dn => 'uid=Andy Dufresne,o=shawshank',
				comment => 'good dn for group',
				expect  => 1,
			},
            {
				dn => 'uid=Bogs Diamond,o=shawshank',
				comment => 'another good dn for group',
				expect  => 1,
			},
);


################################################################
#
# LDAP specific group properties
# These tests have to be done on an isolated group that will NEVER
# have getGroups called on it
#
################################################################

my $ldapProps = WebGUI::Test->getSmokeLDAPProps();
$session->db->setRow('ldapLink', 'ldapLinkId', $ldapProps, $ldapProps->{ldapLinkId});
my $ldap = WebGUI::LDAPLink->new($session, $ldapProps->{ldapLinkId});
is($ldap->getValue("ldapLinkId"),$ldapProps->{ldapLinkId},'ldap link created properly');
WebGUI::Test->addToCleanup($ldap);

my @shawshank;

foreach my $idx (0..$#ldapTests) {
	$shawshank[$idx] = WebGUI::User->new($session, "new");
	$shawshank[$idx]->username("shawshank$idx");
    $shawshank[$idx]->authMethod("LDAP");
    my $auth     = $shawshank[$idx]->authInstance;
    $auth->saveParams($shawshank[$idx]->getId,$shawshank[$idx]->authMethod,{
        connectDN      => $ldapTests[$idx]->{dn},
        ldapConnection => $ldap->getValue("ldapLinkId"),
        ldapUrl        => $ldap->getValue("ldapUrl"),
    });
}

WebGUI::Test->addToCleanup(@shawshank);

my $lGroup = WebGUI::Group->new($session, 'new');

$lGroup->ldapGroup('cn=Convicts,o=shawshank');
is($lGroup->ldapGroup(), 'cn=Convicts,o=shawshank', 'ldapGroup set and fetched correctly');

$lGroup->ldapGroupProperty('member');
is($lGroup->ldapGroupProperty(), 'member', 'ldapGroup set and fetched correctly');

$lGroup->ldapLinkId($ldapProps->{ldapLinkId});
is($lGroup->ldapLinkId(),$ldapProps->{ldapLinkId}, 'ldapLinkId set and fetched correctly');

is_deeply(
	[ (map { $lGroup->hasLDAPUser($_->getId) }  @shawshank) ],
	[0, 1, 1],
	'shawshank user 2, and 3 found in lGroup users from LDAP'
);

$lGroup->ldapRecursiveProperty('LDAP recursive property');
is($lGroup->ldapRecursiveProperty(), 'LDAP recursive property', 'ldapRecursiveProperty set and fetched correctly');

$lGroup->ldapRecursiveFilter('LDAP recursive filter');
is($lGroup->ldapRecursiveFilter(), 'LDAP recursive filter', 'ldapRecursiveFilter set and fetched correctly');

$lGroup->delete;

done_testing;

