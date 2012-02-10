package WebGUI::Definition::Meta::Property::Serialize;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
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

Package WebGUI::Definition::Meta::Property::Serialize

=head1 DESCRIPTION

Extends WebGUI::Definition::Meta::Property to provide serialization for attribute
values.  Currently just a marker, but eventually should provide per-attribute
serialization via handles.

=head1 METHODS

The following methods are added.

=cut

1;
