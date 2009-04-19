package WebGUI::AssetCollateral::Sku::ThingyRecord::Record;

use strict;

use base 'WebGUI::Crud';

sub crud_definition {
	my ($class, $session) = @_;
	my $definition = $class->SUPER::crud_definition($session);
	$definition->{tableName} = 'ThingyRecord_record';
	$definition->{tableKey} = 'recordId';
    my $properties  = $definition->{properties};
    $properties->{transactionId} = {
        fieldType       => "hidden",
        defaultValue    => undef,
    };
    $properties->{assetId} = {
        fieldType       => "hidden",
        defaultValue    => undef,
    };
    $properties->{expires} = {
        fieldType       => "DateTime",
        defaultValue    => 0,
    };
    $properties->{userId} = {
        fieldType       => "hidden",
        defaultValue    => undef,
    };
    $properties->{fields} = {
        fieldType       => 'textarea',
        defaultValue    => '',
    };
    $properties->{isHidden} = {
        fieldType       => 'yesNo',
        defaultValue    => 0,
    };
    $properties->{sentExpiresNotice} = {
        fieldType       => 'yesNo',
        defaultValue    => 0,
    };
    return $definition;
}

1;
