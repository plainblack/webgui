package WebGUI::Flux::Operand;
use strict;
use warnings;

use WebGUI::Pluggable;
use English qw( -no_match_vars );
use WebGUI::Exception::Flux;
use Class::InsideOut qw{ :std };

=head1 NAME

Package WebGUI::Flux::Operand

=head1 DESCRIPTION

Base class for Flux Operands. 

Operands implement a subroutine called evaluate() that returns the Operand value.

Operands are instantiated as sub-classes of this module before being evaluated,
thus they can access all the Class::InsideOut object properties set on this module,
e.g. $self->rule(), $self->args(), $self->user(), $self->session(), $self->assetId() etc..

Operands should implement a subroutine called definition() that returns a hash reference
describing the Operand.

=head1 SYNOPSIS

This module is not intended to be used directly. It is used by WebGUI::Flux::Rule->evaluate()
on a Rule containing Expressions.

=head1 METHODS

These methods are available from this class:

=cut

# InsideOut object properties (available to Operand instances)
readonly session => my %session;    # WebGUI::Session object
readonly rule    => my %rule;       # WebGUI::Flux::Rule
readonly user    => my %user;       # WebGUI::User object
readonly assetId => my %assetId;    # Asset Id
readonly args    => my %args;       # Operand args

#-------------------------------------------------------------------

=head2 new ( arg_ref )

Constructor. Not intended to be used directly. This method is called
by evaluateUsing() to dynamically instantiate and evaluate an Operand

=head3 arg_ref

The following options are supported:

=head4 rule

The WebGUI::Flux::Rule being evaluated (required)

=head4 args

The args being passed to this Operand (required)

=cut

sub new {
    my ( $class, $arg_ref ) = @_;

    # Check arguments..
    if ( !defined $arg_ref || ref $arg_ref ne 'HASH' ) {
        WebGUI::Error::InvalidNamedParamHashRef->throw(
            param => $arg_ref,
            error => 'invalid named param hash ref.',
        );
    }
    foreach my $field qw(rule args) {
        if ( !exists $arg_ref->{$field} ) {
            WebGUI::Error::NamedParamMissing->throw( param => $field, error => 'named param missing.' );
        }
    }
    if ( ref $arg_ref->{rule} ne 'WebGUI::Flux::Rule' ) {
        WebGUI::Error::InvalidObject->throw(
            param    => $arg_ref->{rule},
            error    => 'need a rule.',
            expected => 'WebGUI::Flux::Rule',
            got      => ref $arg_ref->{rule},
        );
    }
    if ( ref $arg_ref->{args} ne 'HASH' ) {
        WebGUI::Error::InvalidObject->throw(
            param    => $arg_ref->{args},
            error    => 'need an args hash ref.',
            expected => 'HASH',
            got      => ref $arg_ref->{args},
        );
    }

    # Register Class::InsideOut object..
    my $self = register $class;

    # Initialise object properties that will be available to Operands
    # via the $self object..
    my $id = id $self;
    my $rule = $arg_ref->{rule};
    $rule{$id}    = $rule;
    $args{$id}    = $arg_ref->{args};
    $user{$id}    = $rule->evaluatingForUser();
    $session{$id} = $rule->session();
    if ( exists $arg_ref->{assetId} ) {
        $assetId{$id} = $arg_ref->{assetId};
    }
    
    $self->_checkDefinition();

    return $self;
}

#-------------------------------------------------------------------

=head2 evaluateUsing( operand, arg_ref )

Instantiates an instance of the operand (a sub-class of this module) and
calls the evaluate() subroutine.

=head3 operand

WebGUI::Flux::Operand::<operand> to use (e.g. 'TextValue')

=head3 arg_ref

The following options are supported:

=head4 rule

The WebGUI::Flux::Rule being evaluated (required)

=head4 args

The args being passed to this Operand (required)

=cut

sub evaluateUsing {
    my ( $class, $operand, $arg_ref ) = @_;

    # Check arguments..
    if ( @_ != 3 ) {
        WebGUI::Error::InvalidParamCount->throw(
            got      => scalar(@_),
            expected => 3,
            error    => 'invalid param count.',
        );
    }
    if ( !defined $arg_ref || ref $arg_ref ne 'HASH' ) {
        WebGUI::Error::InvalidNamedParamHashRef->throw(
            param => $arg_ref,
            error => 'invalid named param hash ref.'
        );
    }
    foreach my $field qw(rule args) {
        if ( !exists $arg_ref->{$field} ) {
            WebGUI::Error::NamedParamMissing->throw( param => $field, error => 'named param missing.' );
        }
    }
    if ( ref $arg_ref->{rule} ne 'WebGUI::Flux::Rule' ) {
        WebGUI::Error::InvalidObject->throw(
            param    => $arg_ref->{rule},
            error    => 'need a rule.',
            expected => 'WebGUI::Flux::Rule',
            got      => ref $arg_ref->{rule},
        );
    }
    if ( ref $arg_ref->{args} ne 'HASH' ) {
        WebGUI::Error::InvalidObject->throw(
            param    => $arg_ref->{args},
            error    => 'need an args hash ref.',
            expected => 'HASH',
            got      => ref $arg_ref->{args},
        );
    }
    
    # The Operand module we are going to dynamically instantiate and evaluate
    my $operandModule = "WebGUI::Flux::Operand::$operand";

    # Try loading the Operand..
    eval { WebGUI::Pluggable::load($operandModule); };
    if ($EVAL_ERROR) {
        WebGUI::Error::Pluggable::LoadFailed->throw(
            error  => $EVAL_ERROR,
            module => $operandModule,
        );
    }
    
    # Instantiate the Operand module..
    my $operandObj = eval { WebGUI::Pluggable::run( $operandModule, 'new', [$operandModule, $arg_ref] ); };
    if ( my $e = Exception::Class->caught() ) {
        $e->rethrow() if ref $e;    # Re-throw Exception::Class errors for other code to catch
    }
    if ($EVAL_ERROR) {
        WebGUI::Error::Pluggable::RunFailed->throw(
            error      => $EVAL_ERROR,
            module     => $operandModule,
            subroutine => 'new',
            params     => [$arg_ref],
        );
    }

    # Good to go. Evaluate the Operand..
    my $result = eval { $operandObj->evaluate(); };
    if ( my $e = Exception::Class->caught() ) {
        $e->rethrow() if ref $e;    # Re-throw Exception::Class errors for other code to catch
    }
    if ($EVAL_ERROR) {
        WebGUI::Error::Flux::Operand::EvaluateFailed->throw(
            error      => $EVAL_ERROR,
            module     => $operandModule,
        );
    }

    return $result;
}

#-------------------------------------------------------------------

=head2 _checkDefinition( )

Called by new() during Operand instantiation. Checks that the Operand has a valid
definition, that all requested Operand args are present etc.. 

=cut

sub _checkDefinition {
    my $self = shift;
    
    # Get the Operand's definition..
    my $operandDefn_ref = eval { $self->definition() };
    if ($EVAL_ERROR) {
        WebGUI::Error::Flux::Operand::DefinitionError->throw(
            error      => $EVAL_ERROR,
            module     => $self,
        );
    }
    if (!defined $operandDefn_ref || ref $operandDefn_ref ne 'HASH') {
        WebGUI::Error::Flux::Operand::DefinitionError->throw(
            error      => 'Invalid Operand definition',
            module     => $self,
        );
    }
    foreach my $field qw(args) {
        if ( !exists $operandDefn_ref->{$field} ) {
            WebGUI::Error::Flux::Operand::DefinitionError->throw(
                error      => "Missing field from Operand definition: $field",
                module     => $self,
            );
        }
    }
    
    # Make sure that all of the Operand's defined Args have been supplied..
    my $operandDefnArgs_ref =  $operandDefn_ref->{args};
    my $args_ref = $args{id $self};
    foreach my $field ( keys %{$operandDefnArgs_ref} ) {
        if ( !exists $args_ref->{$field} ) {
            WebGUI::Error::InvalidParam->throw(
                param => $field,
                error => 'Missing required Operand arg.',
            );
        }
    }
}
1;
