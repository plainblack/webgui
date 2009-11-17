package WebGUI::FormBuilder::Role::HasObjects;

use Moose::Role;

has 'objects' => (
    is => 'rw',
    isa => 'ArrayRef[Object]',
    default => sub { [] },
);

# Objects combines "fields", "fieldsets", and "tabsets"

1;

