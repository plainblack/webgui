package WebGUI::Definition::Meta::Property;

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

with 'WebGUI::Definition::Meta::Settable';

=head1 NAME

Package WebGUI::Definition::Meta::Property

=head1 DESCRIPTION

Moose-based meta class for all properties in WebGUI::Definition.

=head1 SYNOPSIS

WebGUI::Definition::Meta::Property extends Moose::Meta::Attribute to include
a read-only form method, that provides the form properties for the attribute.

=cut

has 'form' => (
    is  => 'ro',
);

#-------------------------------------------------------------------

=head2 form ( )

Returns a hashref of propertes that are specific to WebGUI::Forms.

=cut

1;
