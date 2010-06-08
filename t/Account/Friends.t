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

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 7;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test the creation of WebGUI::Account::Friends

# Can we load it?
use_ok( "WebGUI::Account::Friends" );

SKIP: { # Not everyone has Test::Exception yet
    eval { require Test::Exception; import Test::Exception };
    # Skip 1 test if Test::Exception couldn't be loaded
    skip 1, 'Test::Exception not found' if $@;
    throws_ok( sub { WebGUI::Account::Friends->new }, 'WebGUI::Error::InvalidObject', 
        'new() throws exception without session object'
    );
};

my $friends;
# ok() tests booleans. assignment evaluates to the value assigned (it's how '$a = $b = 4' works)
my $account;
ok( $account = WebGUI::Account->new( $session ), 
    "WebGUI::Account object created successfully" 
);

# Test $account->isa
isa_ok( $account, "WebGUI::Account", 'Blessed into the right class' );

#----------------------------------------------------------------------------
# Test getUrl

is( $account->getUrl, $session->url->page('op=account;module=;do='.$account->method), 
    'getUrl adds op, module, and do since no method has been set' 
);

is( $account->getUrl( 'foo=bar' ), $session->url->page( 'op=account;foo=bar' ),
    'getUrl adds op if passed other parameters'
);

is( $account->getUrl( 'op=account' ), $session->url->page( 'op=account' ),
    'getUrl doesnt add op=account if already exists'
);


#vim:ft=perl
