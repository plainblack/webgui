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

package Test::WebGUI::Account;

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use base 'Test::Class';
use Test::More;
use Test::Exception;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

sub class {
     return 'WebGUI::Account';
}

sub __useItFirst : Test(startup) {
    my $test  = shift;
    my $class = $test->class;
    eval "use $class";
    die $@ if $@;
    my $session       = WebGUI::Test->session;
    $test->{_session} = $session;
}

sub _new : Test(3) {
    my $test    = shift;
    my $session = $test->{_session};
    my $class   = $test->class;
    throws_ok(
        sub { $class->new }, 'WebGUI::Error::InvalidObject',
        'new() throws exception without session object'
    );
    my $account;
    ok( $account = $class->new( $session ), 
        "$class object created successfully" 
    );
    isa_ok( $account, $class, 'Blessed into the right class' );
}

sub getUrl : Test(3) {
    my $test    = shift;
    my $session = $test->{_session};
    my $class   = $test->class;
    my $account = $class->new($session);
    is( $account->getUrl, $session->url->page('op=account;module=;do='.$account->method), 
        'getUrl adds op, module, and do since no method has been set' 
    );

    is( $account->getUrl( 'foo=bar' ), $session->url->page( 'op=account;foo=bar' ),
        'getUrl adds op if passed other parameters'
    );

    is( $account->getUrl( 'op=account' ), $session->url->page( 'op=account' ),
        'getUrl doesnt add op=account if already exists'
    );

}

1;

#vim:ft=perl
