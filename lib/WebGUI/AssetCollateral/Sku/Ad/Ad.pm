package WebGUI::AssetCollateral::Sku::Ad::Ad;

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

=head1 NAME

Package WebGUI::AssetCollateral::Sku::Ad::Ad

=head1 DESCRIPTION

Package to manipulate collateral for WebGUI::Asset::Sku::Ad.

=head1 METHODS

This packages is a subclass of L<WebGUI::Crud>.  Please refer to that module
for a list of base methods that are available.

=head1 properties

Defines the fields this CRUD will contain.

userID = the id of the user that purchased the ad
transactionItemid = the id if the transaction item that completes this purchase
adId = th id if the ad purchased
clicksPurchased = the number of clicks the user purchased
impressionsPurchased = the number of impressions the user purchased
dateOfPurchase = the date of purchase
storedImage = storage for the image
isDeleted = boolean that indicates whether the ad has been deleted from the system

=cut

use strict;
use Moose;
use WebGUI::Definition::Crud;
extends 'WebGUI::Crud';
define tableName    => 'adSkuPurchase';
define tableKey     => 'adSkuPurchaseId';
has adSkuPurchaseId => (
    required => 1,
    is       => 'ro',
);
property userId => (
    label     => 'userId',
    fieldType => 'user',
);
property transactionItemId => (
    label     => 'transactionItemId',
    fieldType => 'guid',
);
property adId => (
    label     => 'adId',
    fieldType => 'guid',
);
property clicksPurchased => (
    label     => 'clicksPurchased',
    fieldType => 'integer',
);
property impressionsPurchased => (
    label     => 'impressionsPurchased',
    fieldType => 'integer',
);
property dateOfPurchase => (
    label     => 'dateOfPurchase',
    fieldType => 'date',
);
property storedImage => (
    label     => 'storedImage',
    fieldType => 'guid',
);
property isDeleted => (
    label     => 'isDeleted',
    fieldType => 'yesNo',
    default   => 0,
);

1;
