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

# Test the User operation
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Test::Mechanize;
use WebGUI::Operation::User;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 17;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Create a new user
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({userId => 3});

$mech->get_ok( '?op=editUser;uid=new' );
my %fields = (
            username    => 'AndyDufresne',
            email       => 'andy@shawshank.doj.gov',
            alias       => 'Randall Stevens',
            status      => 'Active',
        );
$mech->submit_form_ok({
        fields => {
            %fields,
            'authWebGUI.identifier' => 'zihuatanejo',
            groupsToAdd => '12',
        },
    },
    "Add a new user",
);

ok( my $user = WebGUI::User->newByUsername( $session, 'AndyDufresne' ), "user exists" );
WebGUI::Test->addToCleanup( $user );
is( $user->get('email'), $fields{email} );
is( $user->get('alias'), $fields{alias} );
is( $user->status, $fields{status} );
ok( $user->isInGroup( 12 ) );
my $auth = WebGUI::Auth::WebGUI->new( $session, $user );
is( $auth->get('identifier'), $auth->hashPassword('zihuatanejo'), "password was set correctly" );

# Edit an existing user
$mech->get_ok( '?op=editUser;uid=' . $user->getId );
%fields = (
    username    => "EllisRedding",
    email       => 'red@shawshank.doj.gov',
    alias       => 'Red',
    status      => 'Active',
);
$mech->submit_form_ok({
        fields  => {
            %fields,
            'authWebGUI.identifier' => 'rehabilitated',
            groupsToDelete => '12',
        },
    },
    "Edit an existing user",
);

ok( my $user = WebGUI::User->newByUsername( $mech->session, 'EllisRedding' ), "user exists" );
is( $user->get('email'), $fields{email} );
is( $user->get('alias'), $fields{alias} );
is( $user->status, $fields{status} );
ok( not $user->isInGroup( 12 ) );
$auth = WebGUI::Auth::WebGUI->new( $session, $user );
is( $auth->get('identifier'), $auth->hashPassword('rehabilitated'), "password was set correctly" );

#vim:ft=perl
