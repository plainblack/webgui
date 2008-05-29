# Tests WebGUI::Flux
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
my $tests = 4;
plan tests => $tests;

#----------------------------------------------------------------------------
# put your tests here

Readonly my $admin_user_id => 3;
my ( $rule1, $rule2 );

use_ok('WebGUI::Flux');
use_ok('WebGUI::Flux::Rule');

# Rule-related methods (with single Rule)
{
    is( WebGUI::Flux->count_rules($session), 0, 'initially no rules defined' );
    cmp_deeply( WebGUI::Flux->get_rules($session), [], 'initially no rules defined' );

    $rule1 = WebGUI::Flux::Rule->new(
        $session,
        {   name          => "Test Rule: 1",
            owner_id    => $admin_user_id,
            sticky_access => 0,
        }
    );

    is( WebGUI::Flux->count_rules($session), 1, 'after adding rule1, count is 1' );
    cmp_deeply( WebGUI::Flux->get_rules($session), [$rule1], 'rule1 is the only rule defined' );

    $rule1->delete();

    is( WebGUI::Flux->count_rules($session), 0, 'no rules defined after delete' );
    cmp_deeply( WebGUI::Flux->get_rules($session), [], 'no rules defined after delete' );
}

# Rule-related methods (with multiple Rules)
{
    $rule1 = WebGUI::Flux::Rule->new(
        $session,
        {   name          => "Test Rule: 1",
            owner_id    => $admin_user_id,
            sticky_access => 0,
        }
    );
    $rule2 = WebGUI::Flux::Rule->new(
        $session,
        {   name          => "Test Rule: 2",
            owner_id    => $admin_user_id,
            sticky_access => 0,
        }
    );

    is( WebGUI::Flux->count_rules($session), 2, 'after adding rule1 and rule2, count is 1' );
    cmp_deeply( WebGUI::Flux->get_rules($session), [$rule1], 'rule1 and rule2 are the only rules defined' );

    $rule1->delete();
    is( WebGUI::Flux->count_rules($session), 1, 'after deleting rule1, count is 1' );
    cmp_deeply( WebGUI::Flux->get_rules($session), [$rule2], 'after deleting rule1, only rule2 defined' );
}

#----------------------------------------------------------------------------
# Cleanup
END {

    # Cleanup rules (also removes dependent expressions)
    foreach my $r ( $rule1, $rule2 ) {
        ( defined $r and ref $r eq 'WebGUI::Flux::Rule' ) and $r->delete;
    }
}
