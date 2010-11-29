package WebGUI::FormBuilder::Role::HasFields;

use strict;
use Moose::Role;
use Try::Tiny;
use Carp qw(confess);

requires 'session', 'pack', 'unpack';

has 'fields' => (
    is      => 'rw',
    isa     => 'ArrayRef',
    default => sub { [] },
);

with 'WebGUI::FormBuilder::Role::HasObjects';

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
        my $file    = $type;
        $file =~ s{::}{/}g;
        $file .= ".pm";

        # Load the class
        # Try to load the WebGUI Field first in case we conveniently overlap with a common name
        # (like Readonly)
        if ( $INC{'WebGUI/Form/'. ucfirst $file} || try { require 'WebGUI/Form/' . ucfirst $file } ) {
            $type = 'WebGUI::Form::' . ucfirst $type;
        }
        elsif ( !$INC{$file} && !try { require $file; } ) {
            confess sprintf "Could not load form control class %s", $type;
        }
        $field = $type->new( $self->session, { @properties } );
    }

    push @{$self->fields}, $field;
    $self->addObject( $field );
    $self->{_fieldsByName}{ $field->get('name') } = $field; # TODO: Must allow multiple fields per name
    return $field;
}

#----------------------------------------------------------------------------

=head2 deleteField ( name )

Delete a field by name. Returns the field deleted.

=cut

sub deleteField {
    my ( $self, $name ) = @_;
    my $field    = delete $self->{_fieldsByName}{$name};
    FIELD: for ( my $i = 0; $i < scalar @{$self->fields}; $i++ ) {
        my $testField    = $self->fields->[$i];
        if ( $testField->get('name') eq $name ) {
            splice @{$self->fields}, $i, 1;
            last FIELD;
        }
    }
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
        for my $fs ( @{$self->fieldsets} ) {
            push @$fields, $fs->getFieldsRecursive;
        }
    }
    if ( $self->DOES('WebGUI::FormBuilder::Role::HasTabs') ) {
        # Add $self->{_tabs} fields
        for my $tabset ( @{$self->tabsets} ) {
            for my $tab ( @{$tabset->tabs} ) {
                push @$fields, $tab->getFieldsRecursive;
            }
        }
    }
    
    return $fields;
}


1;
