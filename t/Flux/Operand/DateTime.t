# Tests WebGUI::Flux::Operand::DateTime
#
#

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Data::Dumper;
use Readonly;
use WebGUI::Test;    # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Flux::Rule;
use WebGUI::DateTime;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests
plan tests => 5;

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Flux::Operand::DateTime');
$session->user( { userId => 1 } );
my $user = $session->user();

# Create a sample DateTime string, usually this would come from the db
# and hence always be in UTC
my $dt = DateTime->new(
    year      => 1984,
    month     => 10,
    day       => 16,
    hour      => 16,
    minute    => 12,
    second    => 47,
    time_zone => 'UTC',
);
my $dbDateTime = WebGUI::DateTime->new( $dt->epoch() )->toDatabase();

{

    # Test the raw output of this Operand via Operand->evaluateUsing
    my $rule = WebGUI::Flux::Rule->create($session);

    is( WebGUI::Flux::Operand->evaluateUsing(
            'DateTime',
            {   rule => $rule,
                args => { value => $dbDateTime }
            }
        ),
        $dt,
        'Original UTC DateTime object is returned'
    );
}

{

    # Test through higher-level rule->evaluateFor()
    my $rule = WebGUI::Flux::Rule->create($session);
    $rule->addExpression(
        {   operand1     => 'DateTime',
            operand1Args => qq[{"value":  "$dbDateTime"}],
            operand2     => 'DateTime',
            operand2Args => qq[{"value":  "$dbDateTime"}],
            operator     => 'IsEqualTo',
        }
    );
    ok( $rule->evaluateFor( { user => $user, } ), q{"$dbDateTime" == "$dbDateTime"} );
}

{
    # Repeat with a few different modifiers
    my $rule = WebGUI::Flux::Rule->create($session);
    $rule->addExpression(
        {   operand1     => 'DateTime',
            operand1Args => qq[{"value":  "$dbDateTime"}],
            operand1Modifier => 'DateTimeFormat',
            operand1ModifierArgs => qq[{"pattern": "%x %X", "time_zone": "UTC"}],
            operand2     => 'TextValue',
            operand2Args => '{"value":  "Oct 16, 1984 4:12:47 PM"}',
            operator     => 'IsEqualTo',
        }
    );
    ok( $rule->evaluateFor( { user => $user, } ), 'Got the same UTC time back, formatted differently' );
    $rule->addExpression(
        {   operand1     => 'DateTime',
            operand1Args => qq[{"value":  "$dbDateTime"}],
            operand1Modifier => 'DateTimeFormat',
            operand1ModifierArgs => qq[{"pattern": "%x %X", "time_zone": "Australia/Melbourne"}],
            operand2     => 'TextValue',
            operand2Args => '{"value":  "Oct 17, 1984 2:12:47 AM"}',
            operator     => 'IsEqualTo',
        }
    );
    ok( $rule->evaluateFor( { user => $user, } ), 'Australia/Melbourne 10hrs ahead of UTC' );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from fluxRule');
    $session->db->write('delete from fluxExpression');
    $session->db->write('delete from fluxRuleUserData');
}
