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
use feature ();

use Moose ();
use Moose::Exporter;
use Moose::Util::MetaRole;

use namespace::autoclean;
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
    with_meta       => [ 'property', 'define' ],
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
    feature->import(':5.10');
    namespace::autoclean->import( -cleanee => $caller );
    return 1;
}

sub init_meta {
    my $class = shift;
    my %args = @_;

    Moose->init_meta(%args);

    Moose::Util::MetaRole::apply_base_class_roles(
        for     => $args{for_class},
        roles   => [ 'WebGUI::Definition::Role::Object' ],
    );
    Moose::Util::MetaRole::apply_metaroles(
        for              => $args{for_class},
        class_metaroles  => {
            class           => ['WebGUI::Definition::Meta::Class'],
        },
    );
    return $args{for_class}->meta;
}

#-------------------------------------------------------------------

=head2 define ( )

Defines a piece static data for the class which is never processed from a form
or persisted to the database.  In an Asset-style definition, this would be
used for the table name, the asset's name, or the path to the asset's icon.

=cut

sub define {
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

By default, the Moose option C<is => 'rw'> is added to all properties to make
sure the accessors are generated.  If you want to prevent that from happening,
pass an explicit C<is => 'ro'> along with %options.

=head3 $name

The name of the property.

=head3 %options

An options hashref [need list of base options].  Any option which belongs to a form
is relegated to the form attribute of the property and removed from the list of
regular attributes.

=head4 fieldType

The type of field to be created by the form builder.  This is required, and should be the name of
a WebGUI::Form plugin, with the initial letter lowercased.

=head4 noFormPost, label

Either or both of these must be passed in.

=cut

sub property {
    my ($meta, $name, %options) = @_;
    $meta->add_property($name, %options);
    return 1;
}

1;
