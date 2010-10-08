package WebGUI::Definition::Meta::Shop;

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
use WebGUI::Definition::Meta::Property;
use WebGUI::Definition::Meta::Property::Asset;
no warnings qw(uninitialized);

with 'WebGUI::Definition::Meta::Class';

our $VERSION = '0.0.1';

=head1 NAME

Package WebGUI::Definition::Meta::Shop

=head1 DESCRIPTION

Extends 'WebGUI::Definition::Meta::Class' to provide attributes specific to Assets.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

has [ qw{tableName pluginName} ] => (
    is       => 'rw',
);

#-------------------------------------------------------------------

=head2 tableName ( )

The table that this plugin stores its properties in.

=cut

#-------------------------------------------------------------------

=head2 pluginName ( )

An array reference containing two items.  The first is the i18n key for the plugin's name.
The second is the i18n namespace to find the plugin's name.

=cut

1;
