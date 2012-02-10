package WebGUI::Serialize;

use Moose;
use WebGUI::Definition::Crud;
extends qw/WebGUI::Crud/;

define tableName   => 'crudSerialize';
define tableKey    => 'serializeId';
has    serializeId => (
    required => 1,
    is       => 'ro',
);
property someName => (
    label        => 'someName',
    fieldType    => 'text',
    default      => 'someName',
);
property jsonField => (
    label        => 'jsonField',
    fieldType    => 'textarea',
    default      => sub { return []; },
    isa          => 'WebGUI::Type::JSONArray',
    coerce       => 1,
    traits       => ['Array', 'WebGUI::Definition::Meta::Property::Serialize',],
);

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
return $definition;
}


1;
