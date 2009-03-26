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

# This tests the operation of WebGUI::Account modules. You can use
# as a base to test your own modules.

package Test::WebGUI::Account::User;

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use base 'Test::WebGUI::Account';
use Test::More;
use Test::Exception;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

sub class {
     return 'WebGUI::Account::User';
}

sub canView : Test(2) {
    my $test    = shift;
    my $session = $test->{_session};
    my $class   = $test->class;
    my $account = $class->new($session);
    $account->uid(3);
    ok(! $account->canView, 'canView is 0 if uid is set, for any userId');
    $account->uid('');
    ok(  $account->canView, 'canView is 0 if uid is empty string');
}

1;

#vim:ft=perl
