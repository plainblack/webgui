package WebGUI::Flux::Modifier;
use strict;

use WebGUI::Pluggable;
use English qw( -no_match_vars );
use WebGUI::Exception::Flux;
use Class::InsideOut qw{ :std };
use Params::Validate qw(:all);
Params::Validate::validation_options( on_fail => sub {WebGUI::Error::InvalidParam->throw( error => shift)} );

=head1 NAME

Package WebGUI::Flux::Modifier

=head1 DESCRIPTION

Base class for Flux Modifiers. 

Modifiers implement a subroutine called evaluate() that returns the modified Operand value.

Modifiers are instantiated as sub-classes of this module before being evaluated,
thus they can access all the Class::InsideOut object properties set on this module,
e.g. $self->rule(), $self->args(), $self->user(), $self->session(), $self->assetId() etc..

Modifiers should implement a subroutine called definition() that returns a hash reference
describing the Modifier.

=head1 SYNOPSIS

This module is not intended to be used directly. It is used by WebGUI::Flux::Rule->evaluate()
on a Rule containing Expressions.

=head1 METHODS

These methods are available from this class:

=cut

# InsideOut object properties (available to Modifier instances)
readonly session => my %session;    # WebGUI::Session object
readonly rule    => my %rule;       # WebGUI::Flux::Rule
readonly user    => my %user;       # WebGUI::User object
readonly assetId => my %assetId;    # Asset Id
readonly operand => my %operand;    # pre-modified operand value
readonly args    => my %args;       # Modifier args

#-------------------------------------------------------------------

=head2 new ( arg_ref )

Constructor. Not intended to be used directly. This method is called
by evaluateUsing() to dynamically instantiate and evaluate a Modifier

=head3 arg_ref

The following options are supported:

=head4 rule

The WebGUI::Flux::Rule being evaluated (required)

=head4 operand

The Operand being passed to this Modifier (required)

=head4 args

The args being passed to this Modifier (required)

=cut

sub new {
    my $class = shift;
    my %props = validate(@_, { rule => { isa => 'WebGUI::Flux::Rule' }, operand => 1, args => { type => HASHREF } });

    # Register Class::InsideOut object..
    my $self = register $class;

    # Initialise object properties that will be available to Modifiers
    # via the $self object..
    my $id = id $self;
    my $rule = $props{rule};
    $rule{$id}    = $rule;
    $operand{$id}    = $props{operand};
    $args{$id}    = $props{args};
    $user{$id}    = $rule->evaluatingForUser();
    $session{$id} = $rule->session();
    if ( exists $props{assetId} ) {
        $assetId{$id} = $props{assetId};
    }
    
    $self->_checkDefinition();

    return $self;
}

#-------------------------------------------------------------------

=head2 evaluateUsing( modifier, arg_ref )

Instantiates an instance of the Modifier (a sub-class of this module) and
calls the evaluate() subroutine.

=head3 modifier

WebGUI::Flux::Modifier::<modifier> to use (e.g. 'TextValue')

=head3 arg_ref

The following options are supported:

=head4 rule

The WebGUI::Flux::Rule being evaluated (required)

=head4 operand

The Operand being passed to this Modifier (required)

=head4 args

The args being passed to this Modifier (required)

=cut

sub evaluateUsing {
    my $class = shift;
    my ($modifier, $arg_ref) = validate_pos(@_, 1, { type => HASHREF });
    
    # Validate $arg_ref
    my @args = (%{$arg_ref});
    validate(@args, {
         rule => {isa => 'WebGUI::Flux::Rule'},
         args => {type => HASHREF },
         operand => 1,
    });
    
    # Return empty string if Operand is undefined
    return q{} if !defined $arg_ref->{operand};
    
    # The Modifier module we are going to dynamically instantiate and evaluate
    my $modifierModule = "WebGUI::Flux::Modifier::$modifier";

    # Try loading the Modifier..
    eval { WebGUI::Pluggable::load($modifierModule); };
    if ($EVAL_ERROR) {
        WebGUI::Error::Pluggable::LoadFailed->throw(
            error  => $EVAL_ERROR,
            module => $modifierModule,
        );
    }
    
    # Instantiate the Modifier module..
    my $modifierObj = eval { WebGUI::Pluggable::run( $modifierModule, 'new', [$modifierModule, $arg_ref] ); };
    if ( my $e = Exception::Class->caught() ) {
        $e->rethrow() if ref $e;    # Re-throw Exception::Class errors for other code to catch
    }
    if ($EVAL_ERROR) {
        WebGUI::Error::Pluggable::RunFailed->throw(
            error      => $EVAL_ERROR,
            module     => $modifierModule,
            subroutine => 'new',
            params     => [$arg_ref],
        );
    }

    # Good to go. Evaluate the Modifier..
    my $result = eval { $modifierObj->evaluate(); };
    if ( my $e = Exception::Class->caught() ) {
        $e->rethrow() if ref $e;    # Re-throw Exception::Class errors for other code to catch
    }
    if ($EVAL_ERROR) {
        WebGUI::Error::Flux::Modifier::EvaluateFailed->throw(
            error      => $EVAL_ERROR,
            module     => $modifierModule,
        );
    }

    return $result;
}

#-------------------------------------------------------------------

=head2 _checkDefinition( )

Called by new() during Modifier instantiation. Checks that the Modifier has a valid
definition, that all requested Modifier args are present etc.. 

=cut

sub _checkDefinition {
    my $self = shift;
    
    # Get the Modifier's definition..
    my $modifierDefn_ref = eval { $self->definition() };
    if ($EVAL_ERROR) {
        WebGUI::Error::Flux::Modifier::DefinitionError->throw(
            error      => $EVAL_ERROR,
            module     => $self,
        );
    }
    if (!defined $modifierDefn_ref || ref $modifierDefn_ref ne 'HASH') {
        WebGUI::Error::Flux::Modifier::DefinitionError->throw(
            error      => 'Invalid Modifier definition',
            module     => $self,
        );
    }
    foreach my $field qw(args) {
        if ( !exists $modifierDefn_ref->{$field} ) {
            WebGUI::Error::Flux::Modifier::DefinitionError->throw(
                error      => "Missing field from Modifier definition: $field",
                module     => $self,
            );
        }
    }
    
    # Make sure that all of the Modifier's defined Args have been supplied..
    my $modifierDefnArgs_ref =  $modifierDefn_ref->{args};
    my $args_ref = $args{id $self};
    foreach my $field ( keys %{$modifierDefnArgs_ref} ) {
        if ( !exists $args_ref->{$field} ) {
            WebGUI::Error::InvalidParam->throw(
                param => $field,
                error => 'Missing required Modifier arg.',
            );
        }
    }
}
1;
