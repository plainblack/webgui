package WebGUI::FormBuilder::Role::HasFields;

use strict;
use Moose::Role;

requires 'session', 'pack', 'unpack';

has 'fields' => (
    is      => 'rw',
    isa     => 'ArrayRef[WebGUI::Form::Control]',
    default => sub { [] },
);


=head1 METHODS

#----------------------------------------------------------------------------

=head2 addField ( WebGUI::Form::Control )

Add a field. Any WebGUI::Form::Control object.

=head2 addField ( type, properties )

Add a field. C<type> is a class name, optionally without 'WebGUI::Form::'. 
C<properties> is a list of name => value pairs.

Returns the field object

=over 4

=item name

Required. The name of the field in the form.

=back

=cut

sub addField {
    my ( $self, $type, @properties ) = @_;
    my $field;

    if ( blessed( $type ) ) {
        $field = $type;
    }
    else {
        # Is $type a class name?
        eval { WebGUI::Pluggable::load( $type ) };
        if ( $@ ) {
            eval { WebGUI::Pluggable::load( "WebGUI::Form::$type" ) };
            if ( $@ ) {
                $self->session->error("Could not load field type '$type'. Try loading it manually." );
                confess "Could not load field type '$type'. Try loading it manually.";
            }
            $type = "WebGUI::Form::$type";
        }
        $field = $type->new( $self->session, { @properties } );
    }

    push @{$self->fields}, $field;
    $self->{_fieldsByName}{ $field->get('name') } = $field; # TODO: Must allow multiple fields per name
    return $field;
}

#----------------------------------------------------------------------------

=head2 getField ( name )

Get a field by name. Returns the field object.

=cut

sub getField {
    my ( $self, $name ) = @_;
    return $self->{_fieldsByName}{$name};
}

#----------------------------------------------------------------------------

=head2 getFieldsRecursive ( )

Get all the fields in this section, including fieldsets and tabs.

=cut

sub getFieldsRecursive {
    my ( $self ) = @_;
    
    my $fields  = [ @{$self->fields} ]; # New arrayref, but same field objects

    if ( $self->DOES('WebGUI::FormBuilder::Role::HasFieldsets') ) {
        # Add $self->{_fieldsets} fields
    }
    if ( $self->DOES('WebGUI::FormBuilder::Role::HasTabs') ) {
        # Add $self->{_tabs} fields
    }
    
    return $fields;
}

#----------------------------------------------------------------------------

=head2 toHtml ( )

Render the fields in this part of the form.

=cut

sub toHtml {
    my ( $self ) = @_;

    # This will always be the first one called, so no maybe::next::method
    my $html    = '';
    for my $field ( @{$self->fields} ) {
        $html .= $field->toHtmlWithWrapper;
    }

    return $html;
}

1;
