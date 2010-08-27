package WebGUI::FormBuilder::Role::HasObjects;

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


use Moose::Role;

has 'objects' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
);

# Objects combines "fields", "fieldsets", and "tabsets"

=head1 NAME

Package WebGUI::FormBuilder::Role::HasObjects

=head1 DESCRIPTION

Role that provides an attribute for holding a set of objects.

=head1 SYNOPSIS

This method is used by several FormBuilder packages that need to nest objects.  For example, a FormBuilder object
can have multiple tabs, each of which can contain multiple form fields.  The role provides an objects attribute,
and an addObject method for pushing an object onto the list of objects.

    with 'WebGUI::FormBuilder::Role::HasObjects';

=head1 METHODS

=head2 addObject ($object)

Adds $object to the list of objects for the consumer.

=head3 $object

Some variable, or data.  It really can be anything.

=cut

sub addObject {
    my ( $self, $object ) = @_;
    push @{$self->objects}, $object;
    return $object;
}

# Handle re-ordering of objects


1;

