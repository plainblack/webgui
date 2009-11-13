package WebGUI::FormBuilder::Role::HasFieldsets;

use strict;
use Moose::Role;

has 'fieldsets' => (
    is      => 'rw',
    isa     => 'ArrayRef[WebGUI::FormBuilder::Fieldset]',
    default => sub { [] },
);

=head1 METHODS

=cut

#----------------------------------------------------------------------------

=head2 addFieldset( properties )

Add a fieldset. C<properties> is a list of name => value pairs. Returns the
new WebGUI::FormBuilder::Fieldset object.

=over 4 

=item name

Required. The name of the fieldset.

=item legend

The label for the fieldset.

=back

=head2 addFieldset( object, overrideProperties )

Add a fieldset. C<object> is any object that implements the C<WebGUI::FormBuilder::Role::HasFields>
class. Any fieldsets or tabs in the C<object> will also be added. C<overrideProperties> is a list
of name => value pairs to override properties in the C<object> (such as name and label).

=cut

sub addFieldset {
    if ( blessed( $_[1] ) ) {
        my ( $self, $object, %properties ) = @_;
        $properties{ name   } ||= $object->can('name')      ? $object->name     : "";
        $properties{ label  } ||= $object->can('label')     ? $object->label    : "";
        my $fieldset = WebGUI::FormBuilder::Fieldset->new( $self->session, %properties );
        push @{$self->fieldsets}, $fieldset;
        if ( $object->DOES('WebGUI::FormBuilder::Role::HasTabs') ) {
            for my $objectTab ( @{$object->tabs} ) {
                $fieldset->addTab( $objectTab );
            }
        }
        if ( $object->DOES('WebGUI::FormBuilder::Role::HasFieldsets') ) {
            for my $objectFieldset ( @{$object->fieldsets} ) {
                $fieldset->addFieldset( $objectFieldset );
            }
        }
        if ( $object->DOES('WebGUI::FormBuilder::Role::HasFields') ) {
            for my $objectField ( @{$object->fields} ) {
                $fieldset->addField( $objectField );
            }
        }
        return $fieldset;
    }
    else {
        my ( $self, @properties ) = @_;
        my $fieldset = WebGUI::FormBuilder::Fieldset->new( $self->session, @properties );
        push @{$self->fieldsets}, $fieldset;
        $self->{_fieldsetsByName}{ $fieldset->name } = $fieldset;
        return $fieldset;
    }
}

#----------------------------------------------------------------------------

=head2 addFromHashRef( hashRef )

Add the fieldsets from the given serialized hashRef. See C<toHashRef> for more
information.

=cut

sub addFromHashRef {
    my ( $self, $hashref ) = @_;

    for my $fieldset ( @{$hashref->{fieldsets}} ) {
        my $fs  = WebGUI::FormBuilder::Fieldset->newFromHashref( $self->session, $fieldset );
        $self->addFieldset( $fs );
    }

    $self->maybe::next::method;
}

#----------------------------------------------------------------------------

=head2 deleteFieldset ( name )

Delete a fieldset by name. Returns the fieldset deleted.

=cut

sub deleteFieldset {
    my ( $self, $name ) = @_;
    my $fieldset    = delete $self->{_fieldsetsByName}{$name};
    for ( my $i = 0; $i < scalar @{$self->fieldsets}; $i++ ) {
        my $testFieldset    = $self->fieldsets->[$i];
        if ( $testFieldset->name eq $name ) {
            splice @{$self->fieldsets}, $i, 1;
        }
    }
    return $fieldset;
}

#----------------------------------------------------------------------------

=head2 getFieldset ( name )

Get a fieldset object by name

=cut

sub getFieldset {
    my ( $self, $name ) = @_;
    return $self->{_fieldsetsByName}{$name};
}

#----------------------------------------------------------------------------

=head2 toHtml ( ) 

Render the fieldsets in this part of the form

=cut

sub toHtml {
    my ( $self ) = @_;
    my $html    = $self->maybe::next::method;
    for my $fieldset ( @{$self->fieldsets} ) {
        $html .= $fieldset->toHtml;
    }
    return $html;
}

1;
