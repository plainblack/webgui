package WebGUI::Exception::Flux;

use strict;
use warnings;
use WebGUI::Exception;
#use Exception::Class (
#
#    'WebGUI::Error::Flux::OperandEvalFailed' => {
#        isa         => 'WebGUI::Error',
#        description => "Eval of Flux Operand failed.",
#        fields      => ["operand"],
#    },
#    
#    'WebGUI::Error::Flux::OperatorEvalFailed' => {
#        isa         => 'WebGUI::Error',
#        description => "Eval of Flux Operator failed.",
#        fields      => ["operator"],
#    },
#);

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

