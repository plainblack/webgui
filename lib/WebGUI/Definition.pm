package WebGUI::Definition;

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
use Moose::Exporter;
use namespace::autoclean;
use WebGUI::Definition::Meta::Class;
use WebGUI::Definition::Meta::Property;
no warnings qw(uninitialized);

our $VERSION = '0.0.1';

=head1 NAME

Package WebGUI::Definition

=head1 DESCRIPTION

Moose-based meta class for all definitions in WebGUI.

=head1 SYNOPSIS

A definition contains all the information needed to build an object.
Information required to build forms are added as optional roles and
sub metaclasses.  Database persistance is handled similarly.

=head1 METHODS

These methods are available from this class:

=cut

my ($import, $unimport, $init_meta) = Moose::Exporter->build_import_methods(
    install         => [ 'unimport' ],
    with_meta       => [ 'property', 'attribute' ],
    also            => 'Moose',
    roles           => [ 'WebGUI::Definition::Role::Object' ],
);

#-------------------------------------------------------------------

=head2 import ( )

A custom import method is provided so that uninitialized properties do not
generate warnings.

=cut

sub import {
    my $class = shift;
    my $caller = caller;
    $class->$import({ into_level => 1 });
    warnings->unimport('uninitialized');
    namespace::autoclean->import( -cleanee => $caller );
    return 1;
}

#-------------------------------------------------------------------

=head2 init_meta ( )

Sets the metaclass to WebGUI::Definition::Meta::Class.

=cut

sub init_meta {
    my $class = shift;
    my %options = @_; 
    $options{metaclass} = 'WebGUI::Definition::Meta::Class';
    return Moose->init_meta(%options);
}

#-------------------------------------------------------------------

=head2 attribute ( )

An attribute of the definition is typically static data which is never processed from a form
or persisted to the database.  In an Asset-style definition, an attribute would
be the table name, the asset's name, or the path to the asset's icon.

=cut

sub attribute {
    my ($meta, $name, $value) = @_;
    if ($meta->can($name)) {
        $meta->$name($value);
        $meta->add_method( $name, sub { $meta->$name } );
    }
    else {
        $meta->add_method( $name, sub { $value } );
    }
    return 1;
}

#-------------------------------------------------------------------

=head2 property ( $name, %options )

A property is a special object attribute with it's type constraints set by
HTML form properties, such as base type (Text, Integer, Float, SelectList),
default value, value, etc.

=head3 $name

The name of the property.

=head3 %options

An options hashref [need list of base options].  Any option which belongs to a form
is relegated to the form attribute of the property and removed from the list of
regular attributes.

=cut

sub property {
    my ($meta, $name, %options) = @_;
    my %form_options;
    my $prop_meta = 
    $meta->property_meta;
    #'WebGUI::Definition::Meta::Property';
    for my $key ( keys %options ) {
        if ( ! $prop_meta->meta->find_attribute_by_name($key) ) {
            $form_options{$key} = delete $options{$key};
        }
    }
    $meta->add_attribute(
        $name,
        is => 'rw',
        metaclass => $prop_meta,
        form => \%form_options,
        %options,
    );
    return 1;
}

1;

