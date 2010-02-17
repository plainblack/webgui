package WebGUI::FormBuilder::Role::HasObjects;

use Moose::Role;

has 'objects' => (
    traits  => [qw{ Array }],
    is      => 'rw',
    isa     => 'ArrayRef[Object]',
    default => sub { [] },
    handles => { 
        addObject => 'push',
    },
);

# Objects combines "fields", "fieldsets", and "tabsets"
# Handle re-ordering of objects

1;

