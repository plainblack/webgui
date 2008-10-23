package WebGUI::Exception::Flux;

use strict;
use WebGUI::Exception;
use Exception::Class (
    'WebGUI::Error::NotImplemented' => {
        isa         => 'WebGUI::Error',
        description => 'Feature not implemented yet.',
        fields      => ['module'],
    },
    'WebGUI::Error::InvalidNamedParamHashRef' => {
        isa         => 'WebGUI::Error::InvalidParam',
        description => 'Expected to get a hash reference of named subroutine parameters.',
        fields      => ['param'],
    },
    'WebGUI::Error::NamedParamMissing' => {
        isa         => 'WebGUI::Error::InvalidParam',
        description => 'A named subroutine parameter was missing.',
        fields      => ['param'],
    },
    'WebGUI::Error::InvalidParamCount' => {
        isa         => 'WebGUI::Error',
        description => 'Wrong number of subroutine parameters supplied.',
        fields      => [ 'expected', 'got' ],
    },
    'WebGUI::Error::Flux::InvalidCombinedExpression' => {
        isa         => 'WebGUI::Error',
        description => 'Invalid Flux Rule Combined Expression.',
        fields      => [ 'combinedExpression', 'parsedCombinedExpression' ],
    },
    'WebGUI::Error::Flux::CircularRuleLoopDetected' => {
        isa         => 'WebGUI::Error',
        description => 'Circular Rule loop detected (infinite loops not allowed).',
        fields      => [ 'sourceFluxRuleId', 'targetFluxRuleId' ],
    },
    'WebGUI::Error::Flux::Operand::DefinitionError' => {
        isa         => 'WebGUI::Error',
        description => 'A problem was detected with the definition of the WebGUI::Flux::Operand).',
        fields => ['module'],
    },
    'WebGUI::Error::Flux::Operand::EvaluateFailed' => {
        isa         => 'WebGUI::Error',
        description => 'A problem was detected when attempting to evaluate the WebGUI::Flux::Operand).',
        fields => ['module'],
    },
    'WebGUI::Error::Flux::Operator::DefinitionError' => {
        isa         => 'WebGUI::Error',
        description => 'A problem was detected with the definition of the WebGUI::Flux::Operator).',
        fields => ['module'],
    },
    'WebGUI::Error::Flux::Operator::EvaluateFailed' => {
        isa         => 'WebGUI::Error',
        description => 'A problem was detected when attempting to evaluate the WebGUI::Flux::Operator).',
        fields => ['module'],
    },
    'WebGUI::Error::Flux::Modifier::DefinitionError' => {
        isa         => 'WebGUI::Error',
        description => 'A problem was detected with the definition of the WebGUI::Flux::Modifier).',
        fields => ['module'],
    },
    'WebGUI::Error::Flux::Modifier::EvaluateFailed' => {
        isa         => 'WebGUI::Error',
        description => 'A problem was detected when attempting to evaluate the WebGUI::Flux::Modifier).',
        fields => ['module'],
    },

);

=head1 NAME

Package WebGUI::Exception::Flux

=head1 DESCRIPTION

Exceptions which apply only to Flux.

=head1 SYNOPSIS

 use WebGUI::Exception::Flux;

 # throw
 WebGUI::Error::Flux::OperandExecutionFailed->throw(error=>"Too many in cart.");

 # try
 eval { $cart->addItem($ku) };

 # catch
 if (my $e = WebGUI::Error->caught("WebGUI::Error::Flux::MaxOfItemInCartReached")) {
    # do something
 }

=head1 EXCEPTION TYPES

These exception classes are defined in this class:


=head2 WebGUI::Error::Flux::MaxOfItemInCartReached

Throw this when there are too many items of a given type added to the cart so that the user can be notified. ISA WebGUI::Error.

=cut

1;

