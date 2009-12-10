package WebGUI::Definition::Meta::Class;

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
use Moose;
use namespace::autoclean;
use WebGUI::Definition::Meta::Property;
no warnings qw(uninitialized);

extends 'Moose::Meta::Class';

our $VERSION = '0.0.1';

=head1 NAME

Package WebGUI::Definition::Meta::Class

=head1 DESCRIPTION

Moose-based meta class for all definitions in WebGUI.

=head1 SYNOPSIS

A definition contains all the information needed to build an object.
Information required to build forms are added as optional roles and
sub metaclasses.  Database persistance is handled similarly.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 get_property_list ( )

Returns the name of all properties, in the order they were created in the Definition.

=cut

sub get_property_list {
    my $self   = shift;
    my @properties =
        map { $_->name }
        sort { $a->insertion_order <=> $b->insertion_order }
        grep { $_->meta->isa('WebGUI::Definition::Meta::Property') }
        $self->meta->get_all_attributes;
    return \@properties;
}

#-------------------------------------------------------------------

=head2 property_meta ( )

Returns the name of the class for properties.

=cut

sub property_meta {
    return 'WebGUI::Definition::Meta::Property';
}

1;
