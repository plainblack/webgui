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

has 'get_property_list' => (
    is => 'ro',
    default => sub {
        my $self   = shift;
        my @properties =
            map { $_->name }
            sort { $a->insertion_order <=> $b->insertion_order }
            grep { $_->meta->isa('WebGUI::Definition::Meta::Property') }
            $self->meta->get_all_attributes;
        return \@properties;
    },
);

sub property_meta {
    return 'WebGUI::Definition::Meta::Property';
}

1;

