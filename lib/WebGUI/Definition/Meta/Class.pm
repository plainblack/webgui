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

=head2 get_all_attributes_list ( )

Returns an array of all attribute names across all meta classes.

=cut

sub get_all_attributes_list {
    my $self  = shift;
    my @attributes = ();
    CLASS: foreach my $meta ($self->get_all_class_metas) {
        push @attributes, $meta->get_attribute_list;
    }
    return @attributes;
}

#-------------------------------------------------------------------

=head2 get_all_class_metas ( )

Returns an array of all WebGUI::Definition::Meta::Class objects for the classes in this class,
in the order they were created in the Definition.

=cut

sub get_all_class_metas {
    my $self  = shift;
    my @metas = ();
    CLASS: foreach my $class_name (reverse $self->linearized_isa()) {
        my $meta = $self->initialize($class_name);
        next CLASS unless $meta->isa('WebGUI::Definition::Meta::Class');
        push @metas, $meta;
    }
    return @metas;
}

#-------------------------------------------------------------------

=head2 get_all_properties ( )

Returns an array of all Properties, in all classes, in the order they were
created in the Definition.

=cut

sub get_all_properties {
    my $self       = shift;
    my @properties = ();
    foreach my $meta ($self->get_all_class_metas) {
        push @properties, $meta->get_properties;
    }
    return @properties;
}

#-------------------------------------------------------------------

=head2 get_all_property_list ( )

Returns an array of the names of all Properties, in all classes, in the order they were
created in the Definition.

=cut

sub get_all_property_list {
    my $self       = shift;
    my @names = ();
    my %seen  = ();
    foreach my $meta ($self->get_all_class_metas) {
        push @names,
             grep { !$seen{$_}++ }
             $meta->get_property_list;
    }
    return @names;
}

#-------------------------------------------------------------------

=head2 get_attributes ( )

Returns an array of all attributes, but only for this class.  This is the
API-safe way of doing values %{ $self->_attribute_map };

=cut

sub get_attributes {
    my $self   = shift;
    return map { $self->find_attribute_by_name($_) } $self->get_attribute_list;
}

#-------------------------------------------------------------------

=head2 get_properties ( )

Returns an array of all properties, but only for this class.

=cut

sub get_properties {
    my $self = shift;
    return grep { $_->isa('WebGUI::Definition::Meta::Property') } $self->get_attributes;
}

#-------------------------------------------------------------------

=head2 get_property_list ( )

Returns an array of the names of all Properties, in this class, sorted by the order they
were added to the Definition.  This guarantees repeatable, reliable handling of properties.

=cut

sub get_property_list {
    my $self = shift;
    return map  { $_->name }
           sort { $a->insertion_order <=> $b->insertion_order }   # In insertion order
           $self->get_properties
}

#-------------------------------------------------------------------

=head2 get_tables ( )

Returns an array of the names of all tables in every class used by this class.

=cut

sub get_tables {
    my $self       = shift;
    my @properties = ();
    my %seen       = ();
    push @properties, 
        grep { ! $seen{$_}++ }
        map  { $_->tableName }
        $self->get_all_class_metas
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
