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

# Test Auth::LDAP to make sure it works with both ldap and ldaps
# 
#

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use Test::Deep;
use Scope::Guard;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

# Create LDAP Link
my $ldapProps   = WebGUI::Test->getSmokeLDAPProps();

$session->db->setRow("ldapLink","ldapLinkId",$ldapProps, $ldapProps->{ldapLinkId});
my $ldapLink        = WebGUI::LDAPLink->new( $session, $ldapProps->{ldapLinkId} );
addToCleanup($ldapLink);
my $ldap            = $ldapLink->bind;
$session->setting->set('ldapConnection', $ldapProps->{ldapLinkId} );

# An LDAP group
my $ldapGroup = WebGUI::Group->new( $session, "new" );
$ldapGroup->set( "ldapLinkId", $ldapProps->{ldapLinkId} );
$ldapGroup->set( "ldapGroup", "cn=Convicts,o=shawshank" );
$ldapGroup->set( "ldapGroupProperty", "member" );
$ldapGroup->set( "ldapRecursiveProperty", "uid" );
addToCleanup($ldapGroup);

#----------------------------------------------------------------------------
# Tests

plan tests => 9;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test Login of existing user
my $user    = WebGUI::User->create( $session );
WebGUI::Test->addToCleanup( $user );
$user->update({
    authMethod      => "LDAP",
    username        => "Andy Dufresne",
});
my $auth    = $user->authInstance;
$auth->update( 
    ldapUrl         => $ldapProps->{ldapUrl},
    connectDN       => "uid=Andy Dufresne,o=shawshank",
    ldapConnection  => $ldapProps->{ldapLinkId},
);

$session->request->setup_body({
    username        => 'Andy Dufresne',
    identifier      => 'AndyDufresne',
});
my $out = $auth->www_login();

is( $session->user->getId, $user->getId, 'Andy is logged in' );

$session->user({ userId => 1 }); # Restore Visitor

#----------------------------------------------------------------------------
# Test anonymous registration
$session->setting->set('anonymousRegistration', 1);
$session->request->setup_body({
    authLDAP_ldapId     => 'Ellis Redding',
    authLDAP_identifier => 'EllisRedding',
    connection          => $ldapProps->{ldapLinkId},
    email               => 'red@shawshank.com', # email is required by profile
});
$auth   = WebGUI::Auth::LDAP->new( $session, 'LDAP' );

$out = $auth->www_createAccountSave;

is( $session->user->get('username'), 'Ellis Redding', 'Ellis was created' );
WebGUI::Test->addToCleanup( $session->user );

$session->user({ userId => 1 }); # Restore Visitor
$session->setting->set('anonymousRegistration', 0);

#----------------------------------------------------------------------------
# Test automatic registration
$session->setting->set('automaticLDAPRegistration', 1);
$session->request->setup_body({
    username        => 'Bogs Diamond',
    identifier      => 'BogsDiamond',
});
$auth   = WebGUI::Auth::LDAP->new( $session, 'LDAP' );
$out    = $auth->www_login;

is( $session->user->get('username'), 'Bogs Diamond', 'Bogs was created' )
or diag( $auth->error );
WebGUI::Test->addToCleanup( $session->user );

# Test the the automatically registered user is in the right group
ok( $session->user->isInGroup( $ldapGroup->getId ), 'Automatically registered user is in the correct group');

$session->setting->set('automaticLDAPRegistration', 0);
$session->user({ userId => 1 }); # Restore Visitor

#----------------------------------------------------------------------------
# Test DN reset from LDAP

$session->setting->set('automaticLDAPRegistration', 1);
my $result = $ldap->add( 'uid=Brooks Hatley,o=shawshank',
    attr    => [
        uid             => 'Brooks Hatley',
        cn              => 'Brooks Hatley',
        givenName       => 'Brooks',
        sn              => 'Hatley',
        o               => 'shawshank',
        objectClass     => [ qw( top inetOrgPerson ) ],
        userPassword    => 'BrooksHatley',
    ]
);

$session->request->setup_body({
    username        => 'Brooks Hatley',
    identifier      => 'BrooksHatley',
});
$auth   = WebGUI::Auth::LDAP->new( $session, 'LDAP' );
$out    = $auth->www_login;
is $session->user->get('username'), 'Brooks Hatley', 'Brooks was created';
cmp_deeply(
    $auth->get,
    {
        connectDN      => 'uid=Brooks Hatley,o=shawshank',
        ldapConnection => '00000000000000testlink',
        ldapUrl        => 'ldaps://smoke.plainblack.com/o=shawshank',
    },
    'authentication information set after creating account'
);
WebGUI::Test->addToCleanup( $session->user, );
$out    = $auth->www_logout;
is $session->user->get('username'), 'Visitor', 'Brooks was logged out';

$ldap->moddn( 'uid=Brooks Hatley,o=shawshank',
    newrdn => 'uid=Brooks Hatlen',
);

$ldap->modify( 'uid=Brooks Hatlen,o=shawshank',
    replace    => {
        cn              => 'Brooks Hatlen',
        sn              => 'Hatlen',
        userPassword    => 'BrooksHatlen',
    },
);

$session->request->setup_body({
    username        => 'Brooks Hatley',
    identifier      => 'BrooksHatlen',
});

$auth   = WebGUI::Auth::LDAP->new( $session, 'LDAP' );
$out    = $auth->www_login;
is $session->user->get('username'), 'Brooks Hatley', 'Brooks was logged in after name change';
cmp_deeply(
    $auth->get,
    {
        connectDN      => 'uid=Brooks Hatlen,o=shawshank',
        ldapConnection => '00000000000000testlink',
        ldapUrl        => 'ldaps://smoke.plainblack.com/o=shawshank',
    },
    'authentication information updated after name change'
);


$ldap->delete( 'uid=Brooks Hatlen,o=shawshank' );
$ldap->delete( 'uid=Brooks Hatley,o=shawshank' );

$session->setting->set('automaticLDAPRegistration', 0);
