package WebGUI::Flux::Expression;
use strict;
use warnings;

use Class::InsideOut qw{ :std };
use Readonly;
use List::MoreUtils qw(any );

=head1 NAME

Package WebGUI::Flux::Expression

=head1 DESCRIPTION

Expression to be used as a building block in Flux Rules 

As per the standard WebGUI API:

=over 4

=item * use create() to instantiate a new object and immediately persist it to the database

=item * use new() to instantiate an existing object (retrieved from the db by id)

=item * use $obj->get('field') to retrieve properties

=item * use $obj->update() to update properties (immediately persisted to db)

=item * use delete() to remove the object from persistent storage

=back

=head1 SYNOPSIS

 use WebGUI::Flux::Expression;
 
 # create new Expression
 my $expression = WebGUI::Flux::Expression->create($rule, 
    {   name => 'My Expression',
        operand1 => '..',
        operand2 => '..',
        operator => '..',
        # other properties..
    }
 );
 
 # instantiate an existing Expression
 my $expression2 = WebGUI::Flux::Expression->new($rule, $expression->getId());

=head1 METHODS

These methods are available from this class:

=cut

# InsideOut object propertioperand1es and accessors
readonly rule    => my %rule;
private property => my %property;

# Default values used in create() method
Readonly my %EXPRESSION_DEFAULTS => (
    name     => 'Undefined',
);

# Properties/db fields that can be updated via update() method
Readonly my @MUTABLE_PROPERTIES => qw(
    name
    operand1             operand1Args
    operand1AssetId
    operand1PostProcess  operand1PostProcessArgs
    operand2             operand2Args
    operand2AssetId
    operand2PostProcess  operand2PostProcessArgs
    operator
);

#-------------------------------------------------------------------

=head2 create ( rule, properties)

Constructor. Adds an Expression to a Flux Rule. Returns a reference to the Expression.

=head3 rule

A reference to a WebGUI::Flux::Rule object.

=head3 properties

A hash reference containing the properties to set in the expression. At a minimum you must provide:

=head4 operand1

The first operand in the Expression

=head4 operand2

The second operand in the Expression

=head4 operator

The operator of the Expression

=cut

sub create {
    my ( $class, $rule, $properties_ref ) = @_;

    # Check arguments..
    if ( !defined $rule || !$rule->isa('WebGUI::Flux::Rule') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Flux::Rule',
            got      => ( ref $rule ),
            error    => 'Need a Flux Rule.',
            param    => $rule
        );
    }
    if ( !defined $properties_ref || ref $properties_ref ne 'HASH' ) {
        WebGUI::Error::InvalidParam->throw(
            param => $properties_ref,
            error => 'Invalid hash reference.'
        );
    }
    if ( any { !exists $properties_ref->{$_} } qw(operand1 operand2 operator) ) {
        WebGUI::Error::InvalidParam->throw(
            param => $properties_ref,
            error => 'Missing required field in properties hash reference.'
        );
    }

    # Create a bare-minimum entry in the db..
    my $id = $rule->session->db->setRow( 'fluxExpression', 'fluxExpressionId',
        { fluxExpressionId => 'new', fluxRuleId => $rule->getId(), %EXPRESSION_DEFAULTS } );

    # (re-)retrieve entry and apply user-supplied properties..
    my $expression = $class->new( $rule, $id );
    $expression->update($properties_ref);

    return $expression;
}

#-------------------------------------------------------------------

=head2 delete ( )

Removes this expression from the Rule.

=cut

sub delete {
    my $self = shift;
    $self->rule->session->db->deleteRow( 'fluxExpression', 'fluxExpressionId', $self->getId );
    undef $self;
    return undef;
}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a duplicated hash reference of this object’s data.

=head3 property

Any field − returns the value of a field rather than the hash reference.

=cut

sub get {
    my ( $self, $name ) = @_;
    if ( defined $name ) {
        return $property{ id $self}{$name};
    }
    my %copyOfHashRef = %{ $property{ id $self} };
    return \%copyOfHashRef;
}

##-------------------------------------------------------------------
#
#=head2 getHtmlFormatted ()
#
#Returns an HTML formatted expression for display.
#
#=cut
#
#sub getHtmlFormatted {
#    my $self = shift;
#    my $expression = $self->get("name") . "<br />" . $self->get("expression1") . "<br />";
#    $expression .= $self->get("expression2") . "<br />" if ($self->get("expression2") ne "");
#    $expression .= $self->get("expression3") . "<br />" if ($self->get("expression3") ne "");
#    $expression .= $self->get("city") . ", ";
#    $expression .= $self->get("state") . " " if ($self->get("state") ne "");
#    $expression .= $self->get("code") if ($self->get("code") ne "");
#    $expression .= '<br />' . $self->get("country");
#    return $expression;
#}

#-------------------------------------------------------------------

=head2 getId () 

Returns the unique id of this item.

=cut

sub getId {
    my $self = shift;
    return $self->get('fluxExpressionId');
}

#-------------------------------------------------------------------

=head2 new ( rule, id )

Constructor.  Instantiates an existing Rule based upon a fluxExpressionId and returns it.
Refer to C<create> if you want to create a new Expression. 

=head3 rule

A reference to a WebGUI::Flux::Rule object.

=head3 id

The unique id of the expression to instantiate.

=cut

sub new {
    my ( $class, $rule, $fluxExpressionId ) = @_;

    # Check arguments..
    if ( !defined $rule || !$rule->isa('WebGUI::Flux::Rule') ) {
        WebGUI::Error::InvalidObject->throw(
            expected => 'WebGUI::Flux::Rule',
            got      => ( ref $rule ),
            error    => 'Need a Flux Rule.',
            param    => $rule
        );
    }
    if ( !defined $fluxExpressionId ) {
        WebGUI::Error::InvalidParam->throw( error => 'Need a fluxExpressionId.', param => $fluxExpressionId );
    }

    # Retreive row from db..
    my $expression = $rule->session->db->quickHashRef( 'select * from fluxExpression where fluxExpressionId=?',
        [$fluxExpressionId] );
    if ( !defined $expression->{fluxExpressionId} || $expression->{fluxExpressionId} eq q{} ) {
        WebGUI::Error::ObjectNotFound->throw( error => 'No such Flux Expression.', id => $fluxExpressionId );
    }
    if ( $expression->{fluxRuleId} ne $rule->getId ) {
        WebGUI::Error::ObjectNotFound->throw(
            error => 'Expression does not belong to Flux Rule.',
            id    => $fluxExpressionId
        );
    }

    # Register Class::InsideOut object..
    my $self = register $class;

    # Initialise object properties..
    my $id = id $self;
    $rule{$id}     = $rule;
    $property{$id} = $expression;

    return $self;
}

#-------------------------------------------------------------------

=head2 update ( properties )

Sets properties of the expression.

=head3 properties

A hash reference that contains one or more of the following:

=head4 name

The name of the Expression

=head4 fluxRuleId

The Flux Rule that this expression belongs to.

=cut

# TODO: Add other fields to POD documentation above

sub update {
    my ( $self, $newProp_ref ) = @_;
    my $id = id $self;
    foreach my $field (@MUTABLE_PROPERTIES) {
        $property{$id}{$field}
            = ( exists $newProp_ref->{$field} ) ? $newProp_ref->{$field} : $property{$id}{$field};
    }
    $property{$id}{fluxRuleId} = $self->rule->getId();
    return $self->rule->session->db->setRow( 'fluxExpression', 'fluxExpressionId', $property{$id} );
}

1;
