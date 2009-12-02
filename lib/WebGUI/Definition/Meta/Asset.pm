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

sub property_meta {
    return 'WebGUI::Definition::Meta::Property::Asset';
}

has 'table' => (
    is  => 'rw',
);

has 'icon' => (
    is => 'rw',
);

has 'assetName' => (
    is => 'rw',
);

1;

