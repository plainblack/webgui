package WebGUI::AssetCollateral::Sku::ThingyRecord::Record;

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

use strict;

=head1 NAME

Package WebGUI::AssetCollateral::Sku::ThingyRecord::Record

=head1 DESCRIPTION

Package to manipulate collateral for WebGUI::Asset::Sku::ThingyRecord.

There should be a list of data that this module uses and a description of how
they relate and function.

=head1 METHODS

This packages is a subclass of L<WebGUI::Crud>.  Please refer to that module
for a list of base methods that are available.

=cut

use base 'WebGUI::Crud';

#----------------------------------------------------------------

=head2 crud_definition ($session)

Defintion subroutine to set up CRUD.

=cut

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
