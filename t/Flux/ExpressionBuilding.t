# Tests WebGUI::Flux::Expression Build methods
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

# Fully defined Expression
{
    my $expression = WebGUI::Flux::Expression->build_from_json(
        $session,
        qq|{   
                    operand1: {
                        xtype: 'UserProfile',
                        args: {
                            field_id: $user_profile_birthday_field_id
                        },
                        post_processor: {
                            xtype: 'WhenComparedToNowInUnitsOf',
                            args: {
                                units: 'd',
                                timezone: 'user'
                            }
                        }
                    },
                    operator: {
                        xtype: 'IsEqualTo'
                    },
                    operand2: {
                        xtype: 'NumericalValue',
                        args: {
                            value: 0
                        }
                    }
                }|
    );
    ok( $expression->is_fully_defined(), 'expression fully defined' );

    # Check first expression
    my $first_operand = $expression->get_first_operand();
    isa_ok( $first_operand, 'WebGUI::Flux::Operand::UserProfile', 'first operand' );
    is( $expression->get_sequence_number(),
        undef, 'sequence number undefined until expression added to a rule' );

    # TODO: Properly unpack operands/operator and test
    # TODO: test with partial expressions, bad expressions etc..

}

#----------------------------------------------------------------------------
# Cleanup
END {

}
