package WebGUI::FormBuilder::Role::HasObjects;

use Moose::Role;

has 'objects' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
);

# Objects combines "fields", "fieldsets", and "tabsets"

sub addObject {
    my ( $self, $object ) = @_;
    push @{$self->objects}, $object;
    return $object;
}

# Handle re-ordering of objects


1;

