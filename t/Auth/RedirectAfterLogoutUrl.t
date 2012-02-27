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

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $user = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($user);

$session->setting->set('redirectAfterLogoutUrl');
$user->authInstance->www_logout;
is $session->response->redirect, undef, 'no redirect set on logout';

$session->setting->set('redirectAfterLogoutUrl', '/other_page');
$user->authInstance->www_logout;
is $session->response->redirect, '/other_page', 'redirect set on logout';

done_testing;
