package WebGUI::Flux::Modifier;
use strict;
use warnings;

use WebGUI::Pluggable;
use English qw( -no_match_vars );
use WebGUI::Exception::Flux;
use List::MoreUtils qw(any );

=head1 NAME

Package WebGUI::Flux::Modifier

=head1 DESCRIPTION

Base class for Flux Modifiers. 

Modifiers implement a single boolean subroutine called compare()
that accepts exactly two arguemtns: modifier1 and modifier2.

=head1 SYNOPSIS

use WebGUI::Flux::Modifier;

my $result 
    = WebGUI::Flux::Modifier->compareUsing('IsEqualTo', 'aaa', 'bbb'); 
    # calls WebGUI::Flux::Modifier::IsEqualTo->compare('aaa', 'bbb')
 
=head1 METHODS

These methods are available from this class:

=head2 compare( modifier1, modifier2 ) 

Implemented by inherited classes. Returns boolean value based on comparison of
modifier1 and modifier2.

=head3 modifier1

First modifier

=head3 modifier2

Second modifier

=cut

#-------------------------------------------------------------------

=head2 compareUsing( modifier, modifier1, modifier2 ) 

Calls the compare() subroutine on the requested WebGUI::Flux::Modifier 
subclass, e.g. 'IsEqualTo'. The compare() sub is passed modifier1 and modifier2
as its arguments. 

=head3 modifier

WebGUI::Flux::Modifier::<modifier> to use (e.g. 'IsEqualTo')

=head3 modifier1

First modifier

=head3 modifier2

Second modifier

=cut

sub applyUsing {
    my ( $class, $modifier, $arg_ref ) = @_;

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
    foreach my $field qw(user rule args operand) {
        if ( !exists $arg_ref->{$field} ) {
            WebGUI::Error::NamedParamMissing->throw( param => $field, error => 'named param missing.' );
        }
    }

    # Try loading the Modifier..
    eval { WebGUI::Pluggable::load("WebGUI::Flux::Modifier::$modifier"); };
    if ($EVAL_ERROR) {
        WebGUI::Error::Pluggable::LoadFailed->throw(
            error  => $EVAL_ERROR,
            module => "WebGUI::Flux::Modifier::$modifier",
        );
    }

    # Get the Modifier's Args definition..
    my $modifier_args_ref = eval { WebGUI::Pluggable::run( "WebGUI::Flux::Modifier::$modifier", 'getArgs' ); };
    if ($EVAL_ERROR) {
        WebGUI::Error::Pluggable::RunFailed->throw(
            error      => $EVAL_ERROR,
            module     => "WebGUI::Flux::Modifier::$modifier",
            subroutine => 'getArgs',
        );
    }

    # Make sure that all of the Modifier's defined Args have been supplied..
    foreach my $field (keys %{$modifier_args_ref}) {
        if ( !exists $arg_ref->{args}{$field} ) {
             WebGUI::Error::InvalidParam->throw(
                param => $field,
                error => 'Missing required Modifier arg.',
            );
        }
    }
    
    # Good to go. Execute the Modifier..
    my $result = eval { WebGUI::Pluggable::run( "WebGUI::Flux::Modifier::$modifier", 'execute', [$arg_ref] ); };
    if ($EVAL_ERROR) {
        WebGUI::Error::Pluggable::RunFailed->throw(
            error      => $EVAL_ERROR,
            module     => "WebGUI::Flux::Modifier::$modifier",
            subroutine => 'execute',
            params     => [$arg_ref],
        );
    }

    return $result;
}

1;
