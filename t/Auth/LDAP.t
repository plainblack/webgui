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

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use Test::Deep;
use Scope::Guard;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

# Create LDAP Link
my $ldapProps   = {
    ldapLinkName    => "Test LDAP Link",
    ldapUrl         => "ldaps://smoke.plainblack.com/ou=Convicts,o=shawshank", # Always test ldaps
    connectDn       => "cn=Samuel Norton,ou=Warden,o=shawshank",
    identifier      => "gooey",
    ldapUserRDN     => "dn",
    ldapIdentity    => "cn",
    ldapLinkId      => sprintf( '%022s', "testlink" ),
};
$session->db->setRow("ldapLink","ldapLinkId",$ldapProps, $ldapProps->{ldapLinkId});
my $ldapLink        = WebGUI::LDAPLink->new( $session, $ldapProps->{ldapLinkId} );
my $ldap            = $ldapLink->bind;
$session->setting->set('ldapConnection', $ldapProps->{ldapLinkId} );

# Cleanup
my @cleanup = (
    Scope::Guard->new(sub {
        $session->db->write("delete from ldapLink where ldapLinkId=?", [$ldapProps->{ldapLinkId}]);
    }),
);


#----------------------------------------------------------------------------
# Tests

plan tests => 8;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test Login of existing user
my $user    = WebGUI::User->create( $session );
WebGUI::Test->addToCleanup( $user );
$user->update({
    authMethod      => "LDAP",
    username        => "Andy Dufresne",
});
my $auth    = $user->authInstance;
$auth->saveParams( $user->getId, $user->get('authMethod'), {
    ldapUrl         => $ldapProps->{ldapUrl},
    connectDN       => "cn=Andy Dufresne,ou=Convicts,o=shawshank",
    ldapConnection  => $ldapProps->{ldapLinkId},
} );

$session->request->setup_body({
    username        => 'Andy Dufresne',
    identifier      => 'AndyDufresne',
});
my $out = $auth->login();

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

$out = $auth->createAccountSave;

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
$out    = $auth->login;

is( $session->user->get('username'), 'Bogs Diamond', 'Bogs was created' )
or diag( $auth->error );
WebGUI::Test->addToCleanup( $session->user );

$session->setting->set('automaticLDAPRegistration', 0);
$session->user({ userId => 1 }); # Restore Visitor

#----------------------------------------------------------------------------
# Test DN reset from LDAP

$session->setting->set('automaticLDAPRegistration', 1);
my $result = $ldap->add( 'cn=Brooks Hatley,ou=Convicts,o=shawshank',
    attr    => [
        cn              => 'Brooks Hatley',
        givenName       => 'Brooks',
        sn              => 'Hatley',
        ou              => 'Convicts',
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
$out    = $auth->login;
is $session->user->get('username'), 'Brooks Hatley', 'Brooks was created';
cmp_deeply(
    $auth->getParams,
    {
        connectDN      => 'cn=Brooks Hatley,ou=Convicts,o=shawshank',
        ldapConnection => '00000000000000testlink',
        ldapUrl        => 'ldaps://smoke.plainblack.com/ou=Convicts,o=shawshank',
    },
    'authentication information set after creating account'
);
WebGUI::Test->addToCleanup( $session->user, );
$out    = $auth->logout;
is $session->user->get('username'), 'Visitor', 'Brooks was logged out';

$ldap->moddn( 'cn=Brooks Hatley,ou=Convicts,o=shawshank',
    newrdn => 'cn=Brooks Hatlen',
);

$ldap->modify( 'cn=Brooks Hatlen,ou=Convicts,o=shawshank',
    replace    => {
        sn              => 'Hatlen',
        userPassword    => 'BrooksHatlen',
    },
);

$session->request->setup_body({
    username        => 'Brooks Hatley',
    identifier      => 'BrooksHatlen',
});

$auth   = WebGUI::Auth::LDAP->new( $session, 'LDAP' );
$out    = $auth->login;
is $session->user->get('username'), 'Brooks Hatley', 'Brooks was logged in after name change';
cmp_deeply(
    $auth->getParams,
    {
        connectDN      => 'cn=Brooks Hatlen,ou=Convicts,o=shawshank',
        ldapConnection => '00000000000000testlink',
        ldapUrl        => 'ldaps://smoke.plainblack.com/ou=Convicts,o=shawshank',
    },
    'authentication information updated after name change'
);


$ldap->delete( 'cn=Brooks Hatlen,ou=Convicts,o=shawshank' );
$ldap->delete( 'cn=Brooks Hatley,ou=Convicts,o=shawshank' );

$session->setting->set('automaticLDAPRegistration', 0);
