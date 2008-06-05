# Tests higher-level Use Case of a Wobject assigned to a Rule with user attempting access
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use Readonly;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
my $tests = 1;
plan tests => $tests;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Rule');

# TODO: Add tests.

#Readonly my $admin_user_id => 3;
#Readonly my $test_user => WebGUI::User->new( $session, "new" );
#
#my $rule => WebGUI::Flux::Rule->new(
#    $session,
#    {   name          => "Test Rule: 1",
#        owner_id      => $admin_user_id,
#        sticky_access => 0,
#    }
#);
#isa_ok( $rule, 'WebGUI::Flux::Rule' );
#
## Create Wobject..
## Assign Wobject's "WhoCanView" to $rule..
## Simulate user access..
#
## Use a mock object for $rule to check that Wobject access code does the right thing
#
##----------------------------------------------------------------------------
## Cleanup
#END {
#
#    # Cleanup users
#    foreach my $u ($test_user) {
#        ( defined $u and ref $u eq 'WebGUI::User' ) and $u->delete;
#    }
#
#    # Cleanup rules (also removes dependent expressions)
#    foreach my $r ($rule) {
#        ( defined $r and ref $r eq 'WebGUI::Flux::Rule' ) and $r->delete;
#    }
#}
