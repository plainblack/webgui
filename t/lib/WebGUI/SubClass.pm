package WebGUI::Crud::Subclass;

use strict;

use base 'WebGUI::Crud';

sub crud_definition {
    my ($class, $session) = @_;
    my $definition = $class->SUPER::crud_definition($session);
    $definition->{tableName}   = 'crudSubclass';
    $definition->{tableKey}    = 'crudSubclassId';
    $definition->{sequenceKey} = '';
    my $properties = $definition->{properties};
    $properties->{field1} = {
        fieldType    => 'integer',
        defaultValue => 5,
    };    
    return $definition;
}

1;
