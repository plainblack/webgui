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

=cut


use strict;
use base 'WebGUI::Crud';

#------------------------------------------------

=head1  crud_definition

defines the field this crud will contain

userID = the id of the user that purchased the ad
transactionItemid = the id if the transaction item that completes this purchase
adId = th id if the ad purchased
clicksPurchased = the number of clicks the user purchased
impressionsPurchased = the number of impressions the user purchased
dateOfPurchase = the date of purchase
storedImage = storage for the image
isDeleted = boolean that indicates whether the ad has been deleted from the system

=cut

sub crud_definition {
	my ($class, $session) = @_;
	my $definition = $class->SUPER::crud_definition($session);
	$definition->{tableName} = 'adSkuPurchase';
	$definition->{tableKey} = 'adSkuPurchaseId';
	$definition->{properties} = {
            userId => {
	        fieldType	=> 'user',
		defaultValue	=> undef,
	    },
	    transactionItemId => {
		fieldType	=> 'guid',
		defaultValue	=> undef,
	    },
	    adId => {
		fieldType	=> 'guid',
		defaultValue	=> undef,
	    },
	    clicksPurchased => {
		fieldType	=> 'integer',
		defaultValue	=> undef,
	    },
	    impressionsPurchased => {
		fieldType	=> 'integer',
		defaultValue	=> undef,
	    },
	    dateOfPurchase => {
		fieldType	=> 'date',
		defaultValue	=> undef,
	    },
	    storedImage => {
		fieldType	=> 'guid',
		defaultValue	=> undef,
	    },
	    isDeleted => {
		fieldType	=> 'yesNo',
		defaultValue	=> 0,
	    },
	};
	return $definition;
}

1;

