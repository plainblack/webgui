package WebGUI::Serialize;

use base qw/WebGUI::Crud/;

#-------------------------------------------------------------------

=head2 crud_definition

WebGUI::Crud definition for this class.

=head3 tableName

crudSerialize

=head3 tableKey

serializeId

=head3 sequenceKey

None.  Bundles have no sequence amongst themselves.

=head3 properties

=head4 someName

The name of a crud.

=head4 jsonField

JSON blob text field.

=cut

sub crud_definition {
    my ($class, $session) = @_;
    my $definition = $class->SUPER::crud_definition($session);
    $definition->{tableName}   = 'crudSerialize';
    $definition->{tableKey}    = 'serializeId';
    $definition->{sequenceKey} = '';
    my $properties = $definition->{properties};
    $properties->{someName} = {
        fieldType    => 'text',
        defaultValue => 'someName',
    };
    $properties->{jsonField} = {
        fieldType    => 'textarea',
        defaultValue => [],
        serialize    => 1,
    };
    return $definition;
}


1;
