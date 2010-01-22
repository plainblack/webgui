package WebGUI::Definition::Role::Object;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use 5.010;
use Moose::Role;
use namespace::autoclean;
no warnings qw(uninitialized);

our $VERSION = '0.0.1';

=head1 NAME

Package WebGUI::Role::Object

=head1 DESCRIPTION

Moose-based role for providing classic WebGUI get/set style methods for objects.
This role is automatically included in all Definition objects.

=head1 SYNOPSIS

$obj->get('someProperty');
$obj->set({ someProperty => 'someValue' });

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 get ( [ $name ] )

Generic accessor for this object's properties.

=head3 $name

If $name is defined, and is an attribute of the object, it returns the
value of the attribute.  If $name is not an attribute, then it returns
undef.

If $name is not defined, it returns a hashref of all attributes.

=cut

sub get {
    my $self = shift;
    if (@_) {
        my $property = shift;
        if ($self->meta->find_attribute_by_name($property)) {
            return $self->$property;
        }
        return undef;
    }
    my %properties = map { $_ => scalar $self->$_ } $self->meta->get_property_list;
    return \%properties;
}

#-------------------------------------------------------------------

=head2 set ( dataSpec )

Generic setter for this object's properties.

=head3 dataSpec

Accepts either a hash, or a hash reference, of data to set in the object.  If the key
is not an attribute of the object, then it is silently ignored.

=cut

sub set {
    my $self = shift;
    my $properties = @_ % 2 ? shift : { @_ };
    my @orderedProperties = $self->getProperties;
    KEY: for my $property ( @orderedProperties ) {
        next KEY unless exists $properties->{$property};
        $self->$property($properties->{$property});
    }
    return 1;
}

#-------------------------------------------------------------------

=head2 update ( dataSpec )

Combines the actions of setting data in the object and writing the data.

=head3 dataSpec

See L<set>.

=cut


sub update {
    my $self = shift;
    $self->set(@_);
    if ($self->can('write')) {
        $self->write;
    }
    return 1;
}

#-------------------------------------------------------------------

=head2 getFormProperties ( $name )

Returns the form properties for the requested property.  Handles resolving i18n and
calling subroutines for values.

Each subroutine is invoked as a method of the object, and is passed the entire set of
form properties and the name of the property.

=head3 $name

The name of the property to return.

=cut

sub getFormProperties {
    my $self     = shift;
    my $property = $self->meta->find_attribute_by_name(@_);
    my $form     = $property->form;
    PROPERTY: while (my ($property_name, $property) = each %{ $form }) {
        next PROPERTY unless ref $property;
        if (($property_name eq 'label' || $property_name eq 'hoverHelp') and ref $property eq 'ARRAY') {
            $form->{$property_name} = WebGUI::International->new($self->session)->get(@{$property});
        }
        elsif (ref $property eq 'CODE') {
            $form->{$property_name} = $self->$property($form, $property_name);
        }
    }
    return $form;
}

#-------------------------------------------------------------------

=head2 getProperties ( )

Returns a list of the names of all properties of the object, as set by the Definition.

=cut

sub getProperties {
    my $self = shift;
    return $self->meta->get_all_property_list;
}

1;

