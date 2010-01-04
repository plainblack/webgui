package WebGUI::Definition::Meta::Asset;

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
use WebGUI::Definition::Meta::Property::Asset;
no warnings qw(uninitialized);

extends 'WebGUI::Definition::Meta::Class';

our $VERSION = '0.0.1';

=head1 NAME

Package WebGUI::Definition::Meta::Property::Asset

=head1 DESCRIPTION

Extends WebGUI::Definition::Meta::Class to provide

=head1 SYNOPSIS

Extends 'WebGUI::Definition::Meta::Class' to provide attributes specific to Assets.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 property_meta ( )

Asset Definitions use WebGUI::Definition::Meta::Property::Asset as the base class
for properties.

=cut

sub property_meta {
    return 'WebGUI::Definition::Meta::Property::Asset';
}

has [ qw{tableName icon assetName} ] => (
    is       => 'rw',
);

#-------------------------------------------------------------------

=head2 tableName ( )

The table that this asset stores its properties in.

=cut

#-------------------------------------------------------------------

=head2 icon ( )

The filename of the icon for this Asset.  Icons are stored in
www/extras/assets and are 48 x 48 pixels in size.  A smaller version of
the icon, 16x16, is found in www/extras/assets/small.

=cut

#-------------------------------------------------------------------

=head2 assetName ( )

An array reference containing two items.  The first is the i18n key for the asset's name.
The second is the i18n namespace to find the asset's name.

=cut

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

1;
