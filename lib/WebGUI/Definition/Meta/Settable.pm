package WebGUI::Definition::Meta::Settable;

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

=head1 NAME

Package WebGUI::Definition::Meta::Settable

=head1 DESCRIPTION

Role to tag properties as being settable, or not.

=head1 SYNOPSIS

WebGUI::Definition::Meta::Settable.
a read-only form method, that provides the form properties for the attribute.

=cut

1;
