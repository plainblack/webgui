package WebGUI::Flux::Operand;
use strict;
use warnings;

use WebGUI::Pluggable;
use English qw( -no_match_vars );
use List::MoreUtils qw(any );
use WebGUI::Exception::Flux;

=head1 NAME

Package WebGUI::Flux::Operand

=head1 DESCRIPTION

Base class for Flux Operands. 

Operands implement a single boolean subroutine called compare()
that accepts exactly two arguemtns: operand1 and operand2.

=head1 SYNOPSIS

use WebGUI::Flux::Operand;

my $result 
    = WebGUI::Flux::Operand->compareUsing('IsEqualTo', 'aaa', 'bbb'); 
    # calls WebGUI::Flux::Operand::IsEqualTo->compare('aaa', 'bbb')
 
=head1 METHODS

These methods are available from this class:

=head2 compare( operand1, operand2 ) 

Implemented by inherited classes. Returns boolean value based on comparison of
operand1 and operand2.

=head3 operand1

First operand

=head3 operand2

Second operand

=cut

#-------------------------------------------------------------------

=head2 compareUsing( operand, operand1, operand2 ) 

Calls the compare() subroutine on the requested WebGUI::Flux::Operand 
subclass, e.g. 'IsEqualTo'. The compare() sub is passed operand1 and operand2
as its arguments. 

=head3 operand

WebGUI::Flux::Operand::<operand> to use (e.g. 'IsEqualTo')

=head3 operand1

First operand

=head3 operand2

Second operand

=cut

sub executeUsing {
    my ( $class, $operand, $arg_ref) = @_;

    # Check arguments..
    if ( @_ != 3 ) {
        WebGUI::Error::InvalidParamCount->throw(
            got      => scalar(@_),
            expected => 3,
            error => 'invalid param count',
        );
    }    
    if ( !defined $arg_ref || ref $arg_ref ne 'HASH' ) {
        WebGUI::Error::InvalidNamedParamHashRef->throw( param => $arg_ref, error => 'invalid named param hash ref.'  );
    }
    foreach my $field qw(user rule args) {
        if ( !exists $arg_ref->{$field} ) {
            WebGUI::Error::NamedParamMissing->throw( param => $field, error => 'named param missing.' );
        }
    }
    
    # Try loading the Operand..
    eval { WebGUI::Pluggable::load("WebGUI::Flux::Operand::$operand"); };
    if ($EVAL_ERROR) {
         WebGUI::Error::Pluggable::LoadFailed->throw(
            error => $EVAL_ERROR,
            module => "WebGUI::Flux::Operand::$operand",
        );
    }
    
    # Get the Operand's Args definition..
    my $operand_args_ref = eval { WebGUI::Pluggable::run("WebGUI::Flux::Operand::$operand", 'getArgs'); };
    if ($EVAL_ERROR) {
         WebGUI::Error::Pluggable::RunFailed->throw(
            error => $EVAL_ERROR,
            module => "WebGUI::Flux::Operand::$operand",
            subroutine => 'getArgs',
        );
    }
    
    # Make sure that all of the Operand's defined Args have been supplied..
    foreach my $field (keys %{$operand_args_ref}) {
        if ( !exists $arg_ref->{args}{$field} ) {
             WebGUI::Error::InvalidParam->throw(
                param => $field,
                error => 'Missing required Operand arg.',
            );
        }
    }
    
    # Good to go. Execute the Operand..
    my $result = eval { WebGUI::Pluggable::run("WebGUI::Flux::Operand::$operand", 'execute', [$arg_ref]); };
    if ($EVAL_ERROR) {
         WebGUI::Error::Pluggable::RunFailed->throw(
            error => $EVAL_ERROR,
            module => "WebGUI::Flux::Operand::$operand",
            subroutine => 'execute',
            params => [$arg_ref],
        );
    }
    
    return $result;
}

1;
