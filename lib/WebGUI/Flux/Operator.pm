package WebGUI::Flux::Operator;
use strict;

use WebGUI::Pluggable;
use English qw( -no_match_vars );
use WebGUI::Exception::Flux;
use Class::InsideOut qw{ :std };

=head1 NAME

Package WebGUI::Flux::Operator

=head1 DESCRIPTION

Base class for Flux Operators. 

Operators implement a single boolean subroutine called compare()
that accepts exactly two arguemtns: operand1 and operand2.

=head1 SYNOPSIS

use WebGUI::Flux::Operator;

my $result 
    = WebGUI::Flux::Operator->evaluateUsing('IsEqualTo', 'aaa', 'bbb'); 
    # calls WebGUI::Flux::Operator::IsEqualTo->compare('aaa', 'bbb')
 
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

# InsideOut object properties (available to Operator instances)
readonly session => my %session;    # WebGUI::Session object
readonly rule    => my %rule;       # WebGUI::Flux::Rule
readonly user    => my %user;       # WebGUI::User object
readonly assetId => my %assetId;    # Asset Id
readonly operand1    => my %operand1; # first operand value
readonly operand2    => my %operand2; # second operand value

#-------------------------------------------------------------------

=head2 new ( arg_ref )

Constructor. Not intended to be used directly. This method is called
by evaluateUsing() to dynamically instantiate and evaluate an Operator

=head3 arg_ref

The following options are supported:

=head4 rule

The WebGUI::Flux::Rule being evaluated (required)

=head4 operand1

The first operand1 being passed to this Operator (required)

=head4 operand2

The second operand1 being passed to this Operator (required)

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
    foreach my $field qw(rule operand1 operand2) {
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

    # Register Class::InsideOut object..
    my $self = register $class;

    # Initialise object properties that will be available to Operators
    # via the $self object..
    my $id = id $self;
    my $rule = $arg_ref->{rule};
    $rule{$id}    = $rule;
    $operand1{$id}    = $arg_ref->{operand1};
    $operand2{$id}    = $arg_ref->{operand2};
    $user{$id}    = $rule->evaluatingForUser();
    $session{$id} = $rule->session();
    if ( exists $arg_ref->{assetId} ) {
        $assetId{$id} = $arg_ref->{assetId};
    }
    
    $self->_checkDefinition();

    return $self;
}

#-------------------------------------------------------------------

=head2 evaluateUsing( operator, arg_ref )

Instantiates an instance of the operator (a sub-class of this module) and
calls the evaluate() subroutine.

=head3 operator

WebGUI::Flux::Operator::<operator> to use (e.g. 'IsEqualTo')

=head3 arg_ref

The following options are supported:

=head3 operand1

First operand

=head3 operand2

Second operand

=cut

sub evaluateUsing {
    my ( $class, $operator, $arg_ref ) = @_;

    # Check arguments..
    if ( @_ != 3 ) {
        WebGUI::Error::InvalidParamCount->throw(
            got      => scalar(@_),
            expected => 3,
            error => 'invalid param count',
        );
    }
    if ( !defined $arg_ref || ref $arg_ref ne 'HASH' ) {
        WebGUI::Error::InvalidNamedParamHashRef->throw(
            param => $arg_ref,
            error => 'invalid named param hash ref.'
        );
    }
    foreach my $field qw(operand1 operand2 rule) {
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
    
    # Do a little bit of pre-processing on the operands
    foreach my $operand qw(operand1 operand2) {
        
        # Stringify undefs (to shut up warnings about unitialized strings)
        if (!defined $arg_ref->{$operand}) {
            $arg_ref->{$operand} = q{};
        }
        
        # Trim whitespace
        $arg_ref->{$operand} =~ s/^\s+|\s+$//g;
    }
    

     # The Operator module we are going to dynamically instantiate and evaluate
    my $operatorModule = "WebGUI::Flux::Operator::$operator";
    
    # Try loading the Operator..
    eval { WebGUI::Pluggable::load($operatorModule); };
    if ($EVAL_ERROR) {
         WebGUI::Error::Pluggable::LoadFailed->throw(
            error => $EVAL_ERROR,
            module => $operatorModule,
        );
    }
    
    # Instantiate the Operator module..
    my $operatorObj = eval { WebGUI::Pluggable::run( $operatorModule, 'new', [$operatorModule, $arg_ref] ); };
    if ( my $e = Exception::Class->caught() ) {
        $e->rethrow() if ref $e;    # Re-throw Exception::Class errors for other code to catch
    }
    if ($EVAL_ERROR) {
        WebGUI::Error::Pluggable::RunFailed->throw(
            error      => $EVAL_ERROR,
            module     => $operatorModule,
            subroutine => 'new',
            params     => [$arg_ref],
        );
    }
    
    # Good to go. Evaluate the Operator..
    my $result = eval { $operatorObj->evaluate(); };
    if ( my $e = Exception::Class->caught() ) {
        $e->rethrow() if ref $e;    # Re-throw Exception::Class errors for other code to catch
    }
    if ($EVAL_ERROR) {
        WebGUI::Error::Flux::Operator::EvaluateFailed->throw(
            error      => $EVAL_ERROR,
            module     => $operatorModule,
        );
    }

    return $result;
}


#-------------------------------------------------------------------

=head2 _checkDefinition( )

Called by new() during Operator instantiation. Checks that the Operator has a valid
definition. 

=cut

sub _checkDefinition {
    my $self = shift;
    
    # Operator definition not used yet
}

1;
