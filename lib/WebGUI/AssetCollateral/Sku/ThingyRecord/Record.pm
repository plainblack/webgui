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

use Moose;
use WebGUI::Definition::Crud;
extends 'WebGUI::Crud';
define tableName => 'ThingyRecord_record';
define tableKey  => 'recordId';
has recordId => (
    required => 1,
    is       => 'ro',
);
property transactionId => (
    label           => 'transactionId', 
    fieldType       => "hidden",
);
property assetId => (
    label           => 'assetId', 
    fieldType       => "hidden",
);
property expires => (
    label           => 'expires', 
    fieldType       => "DateTime",
);
property userId => (
    label           => 'userId', 
    fieldType       => "hidden",
);
property fields => (
    label           => 'fields', 
    fieldType       => 'textarea',
    default         => '',
);
property isHidden => (
    label           => 'isHidden', 
    fieldType       => 'yesNo',
    default         => 0,
);
property sentExpiresNotice => (
    label           => 'sentExpiresNotice', 
    fieldType       => 'yesNo',
    default         => 0,
);

1;
