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

=head2 get_all_properties ( )

Returns an array of all Properties, in all classes, in the order they were
created in the Definition.

=cut

sub get_all_properties {
    my $self       = shift;
    my @properties = ();
    CLASS: foreach my $className (reverse $self->linearized_isa()) {
        my $meta = $self->initialize($className);
        next CLASS unless $meta->isa('WebGUI::Definition::Meta::Class');
        push @properties, 
            sort { $a->insertion_order <=> $b->insertion_order }   # In insertion order
            grep { $_->isa('WebGUI::Definition::Meta::Property') } # that are Meta::Properties
            $meta->get_attributes                                  # All attributes
        ;
    }
    return @properties;
}

#-------------------------------------------------------------------

=head2 get_attributes ( )

Returns an array of all attributes, but only for this class.  This is the
API-safe way of doing $self->_attribute_map;

=cut

sub get_attributes {
    my $self   = shift;
    return map { $self->find_attribute_by_name($_) } $self->get_attribute_list;
}

#-------------------------------------------------------------------

=head2 get_property_list ( )

Returns an array of the names of all Properties, in all classes, in the
order they were created in the Definition.  Duplicate names are filtered
out.

=cut

sub get_property_list {
    my $self       = shift;
    my @properties = ();
    my %seen       = ();
    push @properties, 
        grep { ! $seen{$_}++ }                                 # Uniqueness check
        map  { $_->name }                                      # Just the name
        $self->get_all_properties
    ;
    return @properties;
}

#-------------------------------------------------------------------

=head2 get_tables ( )

Returns an array of the names of all tables in every class used by
this Class.

=cut

sub get_tables {
    my $self       = shift;
    my @properties = ();
    my %seen       = ();
    push @properties, 
        grep { ! $seen{$_}++ }
        map  { $_->tableName }
        $self->get_all_properties
    ;
    return @properties;
}

#-------------------------------------------------------------------

=head2 property_meta ( )

Returns the name of the class for properties.

=cut

sub property_meta {
    return 'WebGUI::Definition::Meta::Property';
}

1;
