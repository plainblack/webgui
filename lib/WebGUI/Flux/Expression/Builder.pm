package WebGUI::Flux::Expression::Builder;
use strict;
use warnings;

use Class::InsideOut qw{ :std };
use Readonly;
use List::MoreUtils qw(any );

=head1 NAME

Package WebGUI::Flux::Expression::Builder

=head1 DESCRIPTION

Expression::Builder:
• parse() when receiving JSON request from browser
• getOperand1(), opeand1Complete() etc.. to check stages of completion
• getNextStep() to figure out what to ask from the browser next
• www_nextStep() to serialise response into JSON
• if user requests "Save"
∘ use parse() to check that Exp is complete
∘ call Expression->create() with fully-formed request:
‣  Flux::Expression->create($session, {op1=>'..'})

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

=head1 SYNOPSIS

=head1 METHODS

These methods are available from this class:

=cut

1;
