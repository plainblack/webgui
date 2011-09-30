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
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::LDAPLink;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 9;        # Increment this number for each test you create


###########################################################################
#
# new
#
###########################################################################

{
    my $ldap = WebGUI::LDAPLink->new($session, "new");
    addToCleanup($ldap);
    isa_ok($ldap, 'WebGUI::LDAPLink');
    is $ldap->{_ldapLinkId}, "new", '... created with correct linkId';
}

###########################################################################
#
# successful bind
#
###########################################################################

SKIP: {
    skip "Test LDAP server is down", 3;
    my $ldapProps = WebGUI::Test->getSmokeLDAPProps();
    $session->db->setRow('ldapLink', 'ldapLinkId', $ldapProps, $ldapProps->{ldapLinkId});
    my $ldap = WebGUI::LDAPLink->new($session, $ldapProps->{ldapLinkId});
    addToCleanup($ldap);
    cmp_deeply $ldap->get(), superhashof($ldapProps), 'all db properties retrieved';
    my $connection = $ldap->bind();
    isa_ok $connection, 'Net::LDAP', 'returned by bind';
    is $ldap->getErrorCode, undef, 'no errors from binding';

}

###########################################################################
#
# failed bind
#
###########################################################################

SKIP: {
    skip "Test LDAP server is down", 4;
    my $ldapProps = WebGUI::Test->getSmokeLDAPProps();
    $ldapProps->{identifier} = 'hadley';
    $session->db->setRow('ldapLink', 'ldapLinkId', $ldapProps, $ldapProps->{ldapLinkId});
    my $ldap = WebGUI::LDAPLink->new($session, $ldapProps->{ldapLinkId});
    addToCleanup($ldap);
    my $connection = $ldap->bind();
    isa_ok $connection, 'Net::LDAP', 'returned by bind';
    is $ldap->{_error}, 104, 'auth error due to bad identifier';
    is $ldap->getErrorCode, 104, 'getErrorCode returns the stored error code';
    ok $ldap->getErrorMessage, 'getErrorMessage returns an error message';
}
