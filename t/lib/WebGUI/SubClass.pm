package WebGUI::Crud::Subclass;

use strict;

use Moose;
use WebGUI::Definition::Crud;
extends 'WebGUI::Crud';
define tableName   => 'crudSubclass';
define tableKey    => 'crudSubclassId';
has crudSubclassId => (
    required => 1,
    is       => 'ro',
);

property field1 => (
    label        => 'field1',
    fieldType    => 'integer',
    defaultValue => 5,
);

1;
