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

sub get {
    my $self = shift;
    if (@_) {
        my $property = shift;
        if ($self->can($property)) {
            return $self->$property;
        }
        return undef;
    }
    my %properties = map { $_ => scalar $self->$_ } $self->meta->get_all_properties;
    return \%properties;
}

sub set {
    my $self = shift;
    my $properties = @_ % 2 ? shift : { @_ };
    for my $key ( keys %$properties ) {
        return undef
            unless $self->can($key);
        $self->$key($properties->{$key});
    }
    return 1;
}

sub update {
    my $self = shift;
    $self->set(@_);
    if ($self->can('write')) {
        $self->write;
    }
    return 1;
}

sub getProperty {
    my $self = shift;
    return $self->meta->find_attribute_by_name(@_);
}

sub getProperties {
    my $self = shift;
    return $self->meta->get_all_properties;
}

1;

