## Tests access-related WebGUI::Flux::Rule methods
##
##
#
#use strict;
#use warnings;
#use FindBin;
#use lib "$FindBin::Bin/../lib";
#use Test::More;
#use Test::Deep;
#use Data::Dumper;
#use Readonly;
#use WebGUI::Test;    # Must use this before any other WebGUI modules
#use WebGUI::Session;
#
##----------------------------------------------------------------------------
## Init
#my $session = WebGUI::Test->session;
#
##----------------------------------------------------------------------------
## Tests
#my $tests = 1;
#plan tests => $tests;
#
##----------------------------------------------------------------------------
## put your tests here
#
#Readonly my $admin_user_id                  => 3;
#Readonly my $user_profile_birthday_field_id => 1;
#Readonly my $test_user                      => WebGUI::User->new( $session, "new" );
#my $rule1;
#
#use_ok('WebGUI::Flux::Rule');
#
## Expression-related methods
#{
#    $rule1 = WebGUI::Flux::Rule->new(
#        $session,
#        {   name     => 'Test Rule #1',
#            owner_id => $admin_user_id
#        }
#    );
#    isa_ok( $rule1, 'WebGUI::Flux::Rule', 'test rule created' );
#
#}
#
#TODO: {
#    local $TODO = 'Not implemented yet';
#
#    is( $rule->count_expressions(), 0, 'new rule has no expressions' );
#    cmp_deeply( $rule->get_expressions(), [], 'new rule has no expressions' );
#    is( $rule->get_combined_expression(), undef, 'new rule has empty combined expression' );
#
#    # Evaluate empty rule (check default behaviour)
#    ok( $rule->is_false_for($test_user), 'empty rule refuses all access by default' );
#
#    # Rule has now been checked for user, so entry should exist in fluxRuleUserData table
#    is( $rule->get_rule_first_true_date_for($test_user), undef, 'rule has never been true for user' );
#    my $rule_first_checked_date = $rule->get_rule_first_checked_date_for($test_user);
#    my $rule_first_false_date   = $rule->get_rule_first_false_date_for($test_user);
#    is( $rule_first_checked_date, $rule_first_false_date, 'rule first check same as rule first false' );
#    isa_ok( $rule_first_checked_date, 'WebGUI::DateTime', 'rule has been false for user' );
#    is( $rule_first_checked_date->subtract_datetime( DateTime->new() )->minutes(),
#        0, 'rule was checked less than 1 minute ago' );
#
#    # Create first expression
#    my $first_expression = WebGUI::Flux::Expression->build_from_json(
#        $session,
#        qq|{   
#                    operand1: {
#                        xtype: 'UserProfile',
#                        args: {
#                            field_id: $user_profile_birthday_field_id
#                        },
#                        post_processor: {
#                            xtype: 'WhenComparedToNowInUnitsOf',
#                            args: {
#                                units: 'd',
#                                timezone: 'user'
#                            }
#                        }
#                    },
#                    operator: {
#                        xtype: 'IsEqualTo'
#                    },
#                    operand2: {
#                        xtype: 'NumericalValue',
#                        args: {
#                            value: 0
#                        }
#                    }
#                }|
#    );
#    isa_ok($first_expression, 'WebGUI::Flux::Expression', 'expression built ok');
#    ok( $first_expression->is_fully_defined(), 'expression fully defined' );
#
#    # Add expression to rule and check side-effects..
#    $rule->add_expression($first_expression);
#    is( $first_expression->get_sequence_number(), 1, 'first expression now has sequence number 1' );
#
#    # TODO: Check other fluxExpression table fields: createdBy, dateCreated
#
#    is( $rule->count_expressions(), 1, 'rule now has 1 expression' );
#    cmp_deeply( $rule->get_expressions(), [$first_expression], 'rule now has 1 expression' );
#    is( $rule->get_combined_expression(), 'E1', 'default combined expression is E1' );
#
#    # TODO: modify/delete first expression
#
#    # Evaluate rule
#    ok( $rule->is_true_for($test_user), 'rule passes for our test user' );
#
#    # TODO: Check fluxRuleUserDate table entry now that rule passes
#
#    # Create second expression (semantically same as first expression)
#    my $second_expression
#        = WebGUI::Flux::Expression->build_from_json( $session, $first_expression->serialise_to_json() );
#    ok( $second_expression->is_fully_defined(), 'expression fully defined' );
#    is( $second_expression->get_sequence_number(),
#        undef, 'sequence number undefined until expression added to a rule' );
#    $rule->add_expression($second_expression);
#    is( $second_expression->get_sequence_number(), 2, 'second expression added has sequence number 2' );
#    is( $rule->count_expressions(),                2, 'rule now has 2 expression2' );
#    cmp_deeply( $rule->get_expressions(), [ $first_expression, $second_expression ],
#        'rule now has 2 expressions' );
#    is( $rule->get_combined_expression(), 'E1 && E2', 'default combined expression is E1 && E2' );
#
#    # TODO: modify/delete second expression
#
#    # Evaluate rule
#    ok( $rule->get_result_for($test_user), 'rule passes for our test user' );
#    $rule->set_combined_expression('E1 && !E2');
#    not_ok( $rule->get_result_for($test_user), 'rule with modified combined expression fails for our test user' );
#
#    # TODO: Rule Workflow triggers
#
#    # TODO: Simulate Wobject access
#    # Create test wobject, assign to Rule, then call $rule->attempt_access_for($user, $wobject)
#    # Then check fluxRuleUserDate table entry
#
#}
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
#    foreach my $r ($rule1) {
#        ( defined $r and ref $r eq 'WebGUI::Flux::Rule' ) and $r->delete;
#    }
#}
