package WebGUI::Exception::Flux;

use strict;
use warnings;
use WebGUI::Exception;
use Exception::Class (
    'WebGUI::Error::NotImplemented' => {
        isa             => 'WebGUI::Error',
        description     => 'Feature not implemented yet.',
        fields          => ['module'],
        },
     'WebGUI::Error::Pluggable::LoadFailed' => {
        isa             => 'WebGUI::Error',
        description     => 'WebGUI::Pluggable failed to load module.',
        fields          => ['module'],
        },
    'WebGUI::Error::Pluggable::RunFailed' => {
        isa             => 'WebGUI::Error',
        description     => 'WebGUI::Pluggable failed to run subroutine.',
        fields          => ['module', 'subroutine', 'params'],
        },
    'WebGUI::Error::InvalidNamedParamHashRef' => {
        isa             => 'WebGUI::Error::InvalidParam',
        description     => 'Expected to get a hash reference of named subroutine parameters.',
        fields          => ['param'],
        },
    'WebGUI::Error::NamedParamMissing' => {
        isa             => 'WebGUI::Error::InvalidParam',
        description     => 'A named subroutine parameter was missing.',
        fields          => ['param'],
        },
    'WebGUI::Error::InvalidParamCount' => {
        isa             => 'WebGUI::Error',
        description     => 'Wrong number of subroutine parameters supplied.',
        fields          => ['expected','got'],
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

