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

# Test the WebGUI Auth module
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Exception;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Auth::WebGUI;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $user            = WebGUI::User->create( $session );
WebGUI::Test->addToCleanup( $user );

#----------------------------------------------------------------------------
# Test instance

my $auth    = WebGUI::Auth::WebGUI->new( $session, $user );
is( $auth->user, $user, 'Auth accepts user object' );

$auth       = WebGUI::Auth::WebGUI->new( $session, $user->userId );
is( $auth->userId, $user->userId, 'Auth accepts userId' );

$session->user({ user => $user });
$auth       = WebGUI::Auth::WebGUI->new( $session );
is( $auth->user, $user, 'Auth defaults to current user' );

#----------------------------------------------------------------------------
# Test get, delete, and update
lives_ok( sub { $auth->update( test1 => "one" ) }, 'update accepts list of key/value pairs' );
lives_ok( sub { $auth->update({ test2 => "two" }) }, 'update accepts single hashref' );

is( $auth->get('test1'), "one", 'get returns scalar with argument' );
cmp_deeply(
    $auth->get,
    superhashof( {
        test1       => "one",
        test2       => "two",
    } ),
    "get without arguments returns hashref",
);

lives_ok( sub { $auth->delete( "test1" ) }, 'delete a single key' );
ok( !$auth->get('test1'), "delete actually deletes" );
lives_ok( sub { $auth->delete }, 'delete all keys' );
ok( !$auth->get('test2'), "deleted all" );

#----------------------------------------------------------------------------
# 


done_testing;

#vim:ft=perl
