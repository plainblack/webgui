package WebGUI::Asset::Sku::Product;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use Tie::IxHash;
use WebGUI::HTMLForm;
use WebGUI::Storage;
use WebGUI::SQL;
use WebGUI::Utility;
use JSON;

use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Sku';

define assetName  => ['assetName', 'Asset_Product'];
define icon       => 'product.gif';
define tableName  => 'Product';

property cacheTimeout => (
            tab          => "display",
            fieldType    => "interval",
            default      => 3600,
            uiLevel      => 8,
            label        => ["cache timeout"],
            hoverHelp    => ["cache timeout help"],
        );
property templateId => (
            fieldType    => "template",
            tab          => "display",
            namespace    => "Product",
            label        => ['62', 'Asset_Product'],
            hoverHelp    => ['62 description', 'Asset_Product'],
            default      => 'PBtmpl0000000000000056'
        );
property thankYouMessage => (
            tab             => "properties",
            default         => '_default_thankYouMessage',
            fieldType       => "HTMLArea",
            label           => ["thank you message", 'Asset_Product'],
            hoverHelp       => ["thank you message help", 'Asset_Product'],
            lazy            => 1,
        );
sub _default_thankYouMessage {
    my $self = shift;
    my $i18n = WebGUI::International->new($self->session, 'Asset_Product');
    return $i18n->get("default thank you message");
}
property image1 => (
            tab            => "properties",
            fieldType      => "image",
            default        => undef,
            maxAttachments => 1,
            label          => ['7', 'Asset_Product'],
            deleteFileUrl  => \&_product_delete_file_url,
            persist        =>  1,
        );
sub _product_delete_file_url {
    my ($self, $property) = @_;
    return $self->session->url->page(sprintf "func=deleteFileConfirm;file=%s;filename=", $property->name);
}
property image2 => (
            tab            => "properties",
            fieldType      => "image",
            maxAttachments => 1,
            label          => ['8', 'Asset_Product'],
            deleteFileUrl  => \&_product_delete_file_url,
            default        => undef,
            persist        => 1,
        );
property image3 => (
            tab            => "properties",
            fieldType      => "image",
            maxAttachments => 1,
            label          => ['9', 'Asset_Product'],
            deleteFileUrl  => \&_product_delete_file_url,
            default        => undef,
            persist        => 1,
        );
property brochure => (
            tab            => "properties",
            fieldType      => "file",
            maxAttachments => 1,
            label          => ['13', 'Asset_Product'],
            deleteFileUrl  => \&_product_delete_file_url,
            default        => undef,
            persist        => 1,
        );
property manual => (
            tab            => "properties",
            fieldType      => "file",
            maxAttachments => 1,
            label          => ['14', 'Asset_Product'],
            deleteFileUrl  => \&_product_delete_file_url,
            default        => undef,
            persist        => 1,
        );
property isShippingRequired => (
            tab          => "shop",
            fieldType    => "yesNo",
            label        => ['isShippingRequired', 'Asset_Product'],
            hoverHelp    => ['isShippingRequired help', 'Asset_Product'],
            default      => 0,
        );
property warranty => (
            tab            => "properties",
            fieldType      => "file",
            maxAttachments => 1,
            label          => ['15', 'Asset_Product'],
            deleteFileUrl  => \&_product_delete_file_url,
            default        => undef,
            persist        => 1,
        );
property variantsJSON => (
            ##Collateral data is stored as JSON in here
            noFormPost   => 0,
            default      => '[]',
            fieldType    => "textarea",
        );
property accessoryJSON => (
            ##Collateral data is stored as JSON in here
            noFormPost   => 0,
            default      => '[]',
            fieldType    => "textarea",
        );
property relatedJSON => (
            ##Collateral data is stored as JSON in here
            noFormPost   => 0,
            default      => '[]',
            fieldType    => "textarea",
        );
property specificationJSON => (
            ##Collateral data is stored as JSON in here
            noFormPost   => 0,
            default      => '[]',
            fieldType    => "textarea",
        );
property featureJSON => (
            ##Collateral data is stored as JSON in here
            noFormPost   => 0,
            default      => '[]',
            fieldType    => "textarea",
        );
property benefitJSON => (
            ##Collateral data is stored as JSON in here
            noFormPost   => 0,
            default      => '[]',
            fieldType    => "textarea",
        );

#-------------------------------------------------------------------
sub _duplicateFile {
    my $self = shift;
    my $newAsset = $_[0];
    my $column = $_[1];
    if($self->get($column)){
        my $file = WebGUI::Storage->get($self->session,$self->get($column));
        my $newstore = $file->copy;
        $newAsset->update({ $column=>$newstore->getId });
    }
}

#-------------------------------------------------------------------

=head2 addRevision

Override the default method in order to deal with attachments.

=cut

sub addRevision {
    my $self = shift;
    my $newSelf = $self->SUPER::addRevision(@_);
    if ($newSelf->getRevisionCount > 1) {
        foreach my $field (qw(image1 image2 image3 brochure manual warranty)) {
            if ($self->get($field)) {
                my $newStorage = WebGUI::Storage->get($self->session,$self->get($field))->copy;
                $newSelf->update({$field=>$newStorage->getId});
            }
        }
    }
    return $newSelf;
}

#-------------------------------------------------------------------

=head2 deleteCollateral ( tableName, keyName, keyValue )

Deletes a row of collateral data.

=head3 tableName

The name of the table you wish to delete the data from.

=head3 keyName

The name of a key in the collateral hash.  Typically a unique identifier for a given
"row" of collateral data.

=head3 keyValue

Along with keyName, determines which "row" of collateral data to delete.

=cut

sub deleteCollateral {
    my $self      = shift;
    my $tableName = shift;
    my $keyName   = shift;
    my $keyValue  = shift;
    my $table = $self->getAllCollateral($tableName);
    my $index = $self->getCollateralDataIndex($table, $keyName, $keyValue);
    return if $index == -1;
    splice @{ $table }, $index, 1;
    $self->setAllCollateral($tableName);
}

#-------------------------------------------------------------------

=head2 duplicate

Override the duplicate method so uploaded files and images also get copied.

=cut

sub duplicate {
    my $self = shift;
    my $newAsset = $self->SUPER::duplicate(@_);

    foreach my $file ('image1', 'image2', 'image3', 'manual', 'brochure', 'warranty') {
        $self->_duplicateFile($newAsset, $file);
    }

    return $newAsset;

}


#-------------------------------------------------------------------

=head2 getAddToCartForm ( )

Returns a form to add this Sku to the cart.  Used when this Sku is part of
a shelf.  Overrode master class to add variant dropdown.

=cut

sub getAddToCartForm {
    my $self    = shift;
    my $session = $self->session;
    my $i18n = WebGUI::International->new($session, 'Asset_Product');
    my %variants = ();
    tie %variants, 'Tie::IxHash';
    COLLATERAL: foreach my $collateral ( @{ $self->getAllCollateral('variantsJSON')} ) {
        next COLLATERAL unless $collateral->{quantity} > 0;
        $variants{$collateral->{variantId}} = join ", ", $collateral->{shortdesc}, sprintf('%.2f',$collateral->{price});
    }
    return
        WebGUI::Form::formHeader($session, {action => $self->getUrl})
      . WebGUI::Form::hidden(    $session, {name => 'func',  value => 'buy'})
      . WebGUI::Form::selectBox( $session, {
                name    => 'vid',
                options => \%variants,
                value   => [0],
        })
      . WebGUI::Form::submit(    $session, {value => $i18n->get('add to cart')})
      . WebGUI::Form::formFooter($session)
      ;
}

#-------------------------------------------------------------------

=head2 getAllCollateral ( tableName )

Returns an array reference to the translated JSON data for the
requested collateral table.

=head3 tableName

The name of the table you wish to retrieve the data from.

=cut

sub getAllCollateral {
    my $self      = shift;
    my $tableName = shift;
    return $self->{_collateral}->{$tableName} if exists $self->{_collateral}->{$tableName};
    my $json = $self->get($tableName);
    my $table;
    if ($json) {
        $table = from_json($json);
    }
    else {
        $table = [];
    }
    $self->{_collateral}->{$tableName} = $table;
    return $table;
}


#-------------------------------------------------------------------

=head2 getCollateral ( tableName, keyName, keyValue )

Returns a hash reference containing one row of collateral data from a particular
table.

=head3 tableName

The name of the table you wish to retrieve the data from.

=head3 keyName

The name of a key in the collateral hash.  Typically a unique identifier for a given
"row" of collateral data.

=head3 keyValue

Along with keyName, determines which "row" of collateral data to delete.
If this is equal to "new", then an empty hashRef will be returned to avoid
strict errors in the caller.  If the requested data does not exist in the
collateral array, it also returns an empty hashRef.

=cut

sub getCollateral {
    my $self      = shift;
    my $tableName = shift;
    my $keyName   = shift;
    my $keyValue  = shift;
    if ($keyValue eq "new" || $keyValue eq "") {
        return {};
    }
    my $table = $self->getAllCollateral($tableName);
    my $index = $self->getCollateralDataIndex($table, $keyName, $keyValue);
    return {} if $index == -1;
    my %copy = %{ $table->[$index] };
    return \%copy;
}


#-------------------------------------------------------------------

=head2 getCollateralDataIndex ( table, keyName, keyValue )

Returns the index in a set of collateral where an element of the
data (keyName) has a certain value (keyValue).  If the criteria
are not found, returns -1.

=head3 table

The collateral data to search

=head3 keyName

The name of a key in the collateral hash.

=head3 keyValue

The value that keyName should have to meet the criteria.

=cut

sub getCollateralDataIndex {
    my $self     = shift;
    my $table    = shift;
    my $keyName  = shift;
    my $keyValue = shift;
    for (my $index=0; $index <= $#{ $table }; $index++) {
        return $index
            if (exists $table->[$index]->{$keyName} and $table->[$index]->{$keyName} eq $keyValue );
    }
    return -1;
}


#-------------------------------------------------------------------

=head2 getConfiguredTitle ( )

Returns the shortdesc of a variant that has been applied (applyOptions) to this
Product.

=cut

sub getConfiguredTitle {
    my $self = shift;
    return join ' - ', $self->getTitle, $self->getOptions->{shortdesc};
}


#-------------------------------------------------------------------

=head2 getFileIconUrl ( $store )

Return a file icon URL for file collateral.

=head3 $store

A WebGUI::Storage object.  The returned icon will be for the first file in the storage object.

=cut

sub getFileIconUrl {
    my $self = shift;
    my $store = $_[0];
    return $store->getFileIconUrl($self->getFilename($store));
}

#-------------------------------------------------------------------

=head2 getFilename ( $store )

Return a filename from a WebGUI::Storage object.

=head3 $store

The WebGUI::Storage object to look up the file.

=cut

sub getFilename {
    my $self = shift;
    my $store = $_[0];
    my $files = $store->getFiles();
    foreach my $file (@{$files}){
        unless($file =~ m/^thumb-/){
            return $file;
        }
    }
    return "";
}

#-------------------------------------------------------------------

=head2 getFileUrl ( $store )

Return a URL for file collateral.

=head3 $store

A WebGUI::Storage object.  The returned URL will be for the first file in the storage object.

=cut

sub getFileUrl {
    my $self = shift;
    my $store = $_[0];
    return $store->getUrl($self->getFilename($store));
}

#-------------------------------------------------------------------

=head2 getMaxAllowedInCart ( )

Returns the quantity available after options from a variant have been applied to this
Product via applyOptions.  For WebGUI::Shop::CartItem, this is handled by
getSku automatically.

=cut

sub getMaxAllowedInCart {
    my $self = shift;
    return $self->getQuantityAvailable;
}

#-------------------------------------------------------------------

=head2 getPrice ( )

Only returns a price after options from a variant have been applied to this
Product.

=cut

sub getPrice {
    my $self = shift;
    if (! keys %{ $self->getOptions} ) {
        my $variants = $self->getAllCollateral('variantsJSON');
        return '' unless @{ $variants };
        return $variants->[0]->{price};
    }
    else {
        return $self->getOptions->{price};
    }
}


#-------------------------------------------------------------------

=head2 getQuantityAvailable ( )

Returns the quantity of a variant that are available.

=cut

sub getQuantityAvailable {
    my $self = shift;
    return $self->getOptions->{quantity};
}

#-------------------------------------------------------------------

=head2 getThumbnailUrl ( [$store] )

Return a URL to the thumbnail for an image stored in this Product by creating
a WebGUI::Storage object and calling its getThumbnailUrl method.

=head3 $store

This should be a WebGUI::Storage object.  If it is not defined,
then by default getThumbnailUrl will attempt to look up the URL for
the 'image1' property.

If image1 is not defined for this Product and a separate storage object is not
sent in, it will return the empty string.

=cut

sub getThumbnailUrl {
    my $self = shift;
    my $store = shift;
    if (defined $store) {
        return $store->getThumbnailUrl($store->getFiles->[0]); 
    }
    elsif ($self->get('image1')) {
        $store = WebGUI::Storage->get($self->session, $self->get('image1'));
        return $store->getThumbnailUrl($store->getFiles->[0]); 
    }
    else {
        return '';
    }
}

#-------------------------------------------------------------------

=head2 getWeight ( )

Only returns a weight after options from a variant have been applied to this
Product.

=cut

sub getWeight {
    my $self = shift;
    return $self->getOptions->{weight};
}

#-------------------------------------------------------------------

=head2 moveCollateralDown ( tableName, keyName, keyValue )

Moves a collateral data item down one position.  If called on the last element of the
collateral array then it does nothing.

=head3 tableName

A string indicating the table that contains the collateral data.

=head3 keyName

The name of a key in the collateral hash.  Typically a unique identifier for a given
"row" of collateral data.

=head3 keyValue

Along with keyName, determines which "row" of collateral data to move.

=cut

sub moveCollateralDown {
    my $self      = shift;
    my $tableName = shift;
    my $keyName   = shift;
    my $keyValue  = shift;

    my $table = $self->getAllCollateral($tableName);
    my $index = $self->getCollateralDataIndex($table, $keyName, $keyValue);
    return if $index == -1;
    return unless (abs($index) < $#{$table});
    @{ $table }[$index,$index+1] = @{ $table }[$index+1,$index];
    $self->setAllCollateral($tableName);
}


#-------------------------------------------------------------------

=head2 moveCollateralUp ( tableName, keyName, keyValue )

Moves a collateral data item up one position.  If called on the first element of the
collateral array then it does nothing.

=head3 tableName

A string indicating the table that contains the collateral data.

=head3 keyName

The name of a key in the collateral hash.  Typically a unique identifier for a given
"row" of collateral data.

=head3 keyValue

Along with keyName, determines which "row" of collateral data to move.

=cut

sub moveCollateralUp {
    my $self      = shift;
    my $tableName = shift;
    my $keyName   = shift;
    my $keyValue  = shift;

    my $table = $self->getAllCollateral($tableName);
    my $index = $self->getCollateralDataIndex($table, $keyName, $keyValue);
    return if $index == -1;
    return unless $index && (abs($index) <= $#{$table});
    @{ $table }[$index-1,$index] = @{ $table }[$index,$index-1];
    $self->setAllCollateral($tableName);
}


#-------------------------------------------------------------------

=head2 onRefund ( item )

Override the default Sku method to return items to inventory.  Note that this method
requires that options from a variant have been applied to it via applyOptions.
Updates both the options and the collateral.

This method calls the same method from the parent.

=head3 item

The WebGUI::Shop::CartItem that will be refunded.

=cut

sub onRefund {
    my $self   = shift;
    my $item   = shift;
    $self->SUPER::onRefund($item);
    my $amount = $item->get('quantity');
    ##Update myself, as options
    $self->getOptions->{quantity} += $amount;
    ##Update my collateral
    my $vid = $self->getOptions->{variantId};
    my $collateral = $self->getCollateral('variantsJSON', 'variantId', $vid);
    $collateral->{quantity} += $amount;
    $self->setCollateral('variantsJSON', 'variantId', $vid, $collateral);
}


#-------------------------------------------------------------------

=head2 onAdjustQuantityInCart ( item, amount )

Override the default Sku method to handle checking inventory.  Note that this method
requires that options from a variant have been applied to it via applyOptions.
Updates both the options and the collateral.

=head3 item

The WebGUI::Shop::CartItem that is having its quantity adjusted.

=head3 amount

The amount adjusted.  Could be positive or negative.

=cut

sub onAdjustQuantityInCart {
    my $self   = shift;
    my $item   = shift;
    my $amount = shift;
    ##Update myself, as options
    $self->getOptions->{quantity} -= $amount;
    ##Update my collateral
    my $vid = $self->getOptions->{variantId};
    my $collateral = $self->getCollateral('variantsJSON', 'variantId', $vid);
    $collateral->{quantity} -= $amount;
    $self->setCollateral('variantsJSON', 'variantId', $vid, $collateral);
}


#-------------------------------------------------------------------

=head2 onRemoveFromCart ( item )

Override the default Sku method to return items to inventory.  Note that this method
requires that options from a variant have been applied to it via applyOptions.
Updates both the options and the collateral.

=head3 item

The WebGUI::Shop::CartItem that was removed from the cart.

=cut

sub onRemoveFromCart {
    my $self   = shift;
    my $item   = shift;
    my $amount = $item->get('quantity');
    ##Update myself, as options
    $self->getOptions->{quantity} += $amount;
    ##Update my collateral
    my $vid = $self->getOptions->{variantId};
    my $collateral = $self->getCollateral('variantsJSON', 'variantId', $vid);
    $collateral->{quantity} += $amount;
    $self->setCollateral('variantsJSON', 'variantId', $vid, $collateral);
}


#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->newById($self->session, $self->get("templateId"));
    $template->prepare($self->getMetaDataAsTemplateVariables);
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 purge 

Extend the base class to handle all file collateral.

=cut

sub purge {
    my $self = shift;
    my $sth = $self->session->db->read("select image1, image2, image3, brochure, manual, warranty from Product where assetId=?", [$self->getId]);
    while (my @array = $sth->array) {
        ID: foreach my $id (@array){
            next ID if ($id eq "");
            WebGUI::Storage->get($self->session,$id)->delete; 
        }
    }
    $sth->finish;
    $self->SUPER::purge();
}

#-------------------------------------------------------------------

=head2 purgeCache ( )

Extends the base class to handle cleaning up the cache for this asset.

=cut

sub purgeCache {
    my $self = shift;
    $self->session->cache->delete("view_".$self->getId);
    $self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

=head2 purgeRevision ( )

Extend the base method to handle deleting file collateral.

=cut

sub purgeRevision {
    my $self = shift;
    WebGUI::Storage->get($self->session, $self->get("image1"))->delete   if ($self->get("image1"));
    WebGUI::Storage->get($self->session, $self->get("image2"))->delete   if ($self->get("image2"));
    WebGUI::Storage->get($self->session, $self->get("image3"))->delete   if ($self->get("image3"));
    WebGUI::Storage->get($self->session, $self->get("brochure"))->delete if ($self->get("brochure"));
    WebGUI::Storage->get($self->session, $self->get("manual"))->delete   if ($self->get("manual"));
    WebGUI::Storage->get($self->session, $self->get("warranty"))->delete if ($self->get("warranty"));
    return $self->SUPER::purgeRevision;
}

#-----------------------------------------------------------------

=head2 setAllCollateral ( tableName )

Update the db from the object cache.

=head3 tableName

The name of the table to insert the data.

=cut

sub setAllCollateral {
    my $self       = shift;
    my $tableName  = shift;
    my $json = to_json($self->{_collateral}->{$tableName});
    $self->update({ $tableName => $json });
    return;
}

#-----------------------------------------------------------------

=head2 setCollateral ( tableName, keyName, keyValue, properties )

Performs and insert/update of collateral data for any wobject's collateral data.
Returns the id of the data that was set, even if a new row was added to the
data.

=head3 tableName

The name of the table to insert the data.

=head3 keyName

The name of a key in the collateral hash.  Typically a unique identifier for a given
"row" of collateral data.

=head3 keyValue

Along with keyName, determines which "row" of collateral data to set.
The index of the collateral data to set.  If the keyValue = "new", then a
new entry will be appended to the end of the collateral array.  Otherwise,
the appropriate entry will be overwritten with the new data.

=head3 properties

A hash reference containing the name/value pairs to be inserted into the collateral, using
the criteria mentioned above.

=cut

sub setCollateral {
    my $self       = shift;
    my $tableName  = shift;
    my $keyName    = shift;
    my $keyValue   = shift;
    my $properties = shift;
    ##Note, since this returns a reference, it is actually updating
    ##the object cache directly.
    my $table = $self->getAllCollateral($tableName);
    if ($keyValue eq 'new' || $keyValue eq '') {
        if (! exists $properties->{$keyName}
           or $properties->{$keyName} eq 'new'
           or $properties->{$keyName} eq '') {
            $properties->{$keyName} = $self->session->id->generate;
        }
        push @{ $table }, $properties;
        $self->setAllCollateral($tableName);
        return $properties->{$keyName};
    }
    my $index = $self->getCollateralDataIndex($table, $keyName, $keyValue);
    return if $index == -1;
    $table->[$index] = $properties;
    $self->setAllCollateral($tableName);
    return $keyValue;
}

#-------------------------------------------------------------------

=head2 www_addAccessory 

Builds a form that lists other Products that could be accessories for this one, and allows
the user to select them.

=cut

sub www_addAccessory {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
    $f->hidden(
        -name => "func",
        -value => "addAccessorySave",
    );
    ##Accessories are other Products.  Give the user a list of Accessories that
    ##are not already used, nor itself.
    ##Accessories can not be edited, only added or deleted.
    my $table = $self->getAllCollateral('accessoryJSON');
    my @usedAccessories = map { $_->{accessoryAssetId} } @{ $table };
    push(@usedAccessories,$self->getId);

    my $accessory = $self->session->db->buildHashRef(
"select asset.assetId, assetData.title
    from asset left join assetData
        on assetData.assetId=asset.assetId
    where
        asset.className='WebGUI::Asset::Sku::Product'
    and asset.assetId not in (".$self->session->db->quoteAndJoin(\@usedAccessories).")
    and revisionDate=(select max(revisionDate) from assetData where asset.assetId=assetData.assetId)
    and   (
           assetData.status='approved'
        or assetData.tagId=".$self->session->db->quote($self->session->scratch->get('versionTag')).
         ") group by assetData.assetId"
    );

    my $i18n = WebGUI::International->new($self->session,"Asset_Product");
    $f->selectBox(
        -name => "accessoryAccessId",
        -options => $accessory,
        -label => $i18n->get(17),
        -hoverHelp => $i18n->get('17 description'),
    );
    $f->yesNo(
        -name => "proceed",
        -label => $i18n->get(18),
        -hoverHelp => $i18n->get('18 description'),
    );
    $f->submit;

    return $self->getAdminConsole->render($f->print, "product accessory add/edit");
}

#-------------------------------------------------------------------

=head2 www_addAccessorySave 

Process the addAccessory form.

=cut

sub www_addAccessorySave {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);

    my $accessoryAssetId = $self->session->form->process('accessoryAccessId');
    return "" unless $accessoryAssetId;
    $self->setCollateral(
        'accessoryJSON',
        'accessoryAssetId',
        'new',
        {
            accessoryAssetId =>  $accessoryAssetId
        },
    );
    return '' unless($self->session->form->process('proceed'));
    return $self->www_addAccessory();
}

#-------------------------------------------------------------------

=head2 www_addRelated 

Provides a form for the user to pick Products related to this one.

=cut

sub www_addRelated {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
    $f->hidden(
        -name => 'func',
        -value => 'addRelatedSave',
    );
    ##Relateds are other Products.  Give the user a list of Related products that
    ##are not already used, nor itself.
    ##Accessories can not be edited, only added or deleted.
    my $table = $self->getAllCollateral('relatedJSON');
    my @usedRelated = map { $_->{relatedAssetId} } @{ $table };
    push(@usedRelated, $self->getId);

    ##Note, hashref takes care of making things unique across revisionDate
    my $related = $self->session->db->buildHashRef(
"select asset.assetId, assetData.title
    from asset left join assetData
        on assetData.assetId=asset.assetId
    where
        asset.className='WebGUI::Asset::Sku::Product'
    and asset.assetId not in (".$self->session->db->quoteAndJoin(\@usedRelated).")
    and revisionDate=(select max(revisionDate) from assetData where asset.assetId=assetData.assetId)
    and   (
           assetData.status='approved'
        or assetData.tagId=".$self->session->db->quote($self->session->scratch->get('versionTag')).
         ") group by assetData.assetId"
    );


    my $i18n = WebGUI::International->new($self->session,'Asset_Product');
    $f->selectBox(
        -name => 'relatedAssetId',
        -options => $related,
        -label => $i18n->get(20),
        -hoverHelp => $i18n->get('20 description'),
    );
    $f->yesNo(
        -name => 'proceed',
        -label => $i18n->get(21),
        -hoverHelp => $i18n->get('21 description'),
    );
    $f->submit;
    return $self->getAdminConsole->render($f->print,'product related add/edit');
}

#-------------------------------------------------------------------

=head2 www_addRelatedSave 

Process the addRelated form.

=cut

sub www_addRelatedSave {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $relatedAssetId = $self->session->form->process('relatedAssetId');
    return '' unless $relatedAssetId;
    $self->setCollateral(
        'relatedJSON',
        'relatedAssetId',
        'new',
        {
            relatedAssetId =>  $relatedAssetId,
        },
    );
    return '' unless($self->session->form->process('proceed'));
    return $self->www_addRelated();
}

#-------------------------------------------------------------------

=head2 www_buy

Method to add a variant from this Product to the cart.  The variant is in the form
variable vid.

=cut

sub www_buy {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canView;
    ##Need to validate the index
    my $vid = $self->session->form->process('vid');
    my $variant = $self->getCollateral('variantsJSON', 'variantId', $vid);
    return '' unless keys %{ $variant };
    $self->addToCart($variant);
    $self->{_hasAddedToCart} = 1;
    return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_deleteAccessoryConfirm 

Delete an asset from the accessory list, by id.

=cut

sub www_deleteAccessoryConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->deleteCollateral('accessoryJSON', 'accessoryAssetId', $self->session->form->process('aid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_deleteBenefitConfirm 

Delete a benefit from the Product, given the form variable C<bid>.

=cut

sub www_deleteBenefitConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->deleteCollateral("benefitJSON", 'benefitId', $self->session->form->process("bid"));
    return "";
}

#-------------------------------------------------------------------

=head2 www_deleteFeatureConfirm 

Delete a feature from the Product, given the form variable C<fid>.

=cut

sub www_deleteFeatureConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->deleteCollateral('featureJSON', 'featureId', $self->session->form->process('fid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_deleteFileConfirm 

Delete a piece of file collateral, as given by the form variable C<file>.

=cut

sub www_deleteFileConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $column = $self->session->form->process("file");
    return $self->www_edit  unless (isIn($column, qw(image1 image2 image3 manual warranty brochure)));
    my $store = $self->get($column);
    my $file = WebGUI::Storage->get($self->session,$store);
    $file->delete if defined $file;
    $self->update({$column=>''});
    return $self->www_edit;
}

#-------------------------------------------------------------------

=head2 www_deleteRelatedConfirm 

Remove a Product from the list of related products, as given by the form variable C<rid>.

=cut

sub www_deleteRelatedConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->deleteCollateral('relatedJSON', 'relatedAssetId', $self->session->form->process('rid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_deleteVariantConfirm 

Remove a variant from this Product, as given by the form variable C<vid>.

=cut

sub www_deleteVariantConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->deleteCollateral('variantsJSON', 'variantId', $self->session->form->process('vid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_deleteSpecificationConfirm 

Remove a specification from this Product, as given by the form variable C<sid>.

=cut

sub www_deleteSpecificationConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->deleteCollateral('specificationJSON', 'specificationId', $self->session->form->process('sid'));
    return '';
}


#-------------------------------------------------------------------

=head2 www_editBenefit 

Form to edit, or add benefits to this Product.

=cut

sub www_editBenefit {
    my $self = shift;
    my $bid = shift || $self->session->form->process('bid');
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $data = $self->getCollateral('benefitJSON', 'benefitId', $bid);
    my $i18n = WebGUI::International->new($self->session,'Asset_Product');
    my $f    = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
    $f->hidden(
        -name => 'bid',
        -value => $bid,
    );
    $f->hidden(
        -name => 'func',
        -value => 'editBenefitSave',
    );
    $f->text(
        -name => 'benefit',
        -label => $i18n->get(51),
        -hoverHelp => $i18n->get('51 description'),
        -value => $data->{benefit},
    );
    $f->yesNo(
        -name => 'proceed',
        -label => $i18n->get(52),
        -hoverHelp => $i18n->get('52 description'),
    );
    $f->submit;
    return $self->getAdminConsole->render($f->print, 'product benefit add/edit');
}

#-------------------------------------------------------------------

=head2 www_editBenefitSave 

Process the editBenefit form.

=cut

sub www_editBenefitSave {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $bid = $self->session->form->process('bid', 'text');
    $self->setCollateral(
        'benefitJSON',
        'benefitId',
        $bid,
        {
            benefit   => $self->session->form->process('benefit','text'),
            benefitId => $bid,
        },
    );
    return '' unless($self->session->form->process('proceed'));
    return $self->www_editBenefit('new');
}

#-------------------------------------------------------------------

=head2 www_editFeature 

Form to add or edit features to thie Product.

=cut

sub www_editFeature {
    my $self = shift;
    my $fid = shift || $self->session->form->process('fid');
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $data = $self->getCollateral('featureJSON', 'featureId', $fid);
    my $i18n = WebGUI::International->new($self->session,'Asset_Product');
    my $f    = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
    $f->hidden(
        -name  => 'fid',
        -value => $fid,
    );
    $f->hidden(
        -name  => 'func',
        -value => 'editFeatureSave',
    );
    $f->text(
        -name      => 'feature',
        -label     => $i18n->get(23),
        -hoverHelp => $i18n->get('23 description'),
        -value     => $data->{feature},
    );
    $f->yesNo(
        -name      => 'proceed',
        -label     => $i18n->get(24),
        -hoverHelp => $i18n->get('24 description'),
    );
    $f->submit;
    return $self->getAdminConsole->render($f->print, 'product feature add/edit');
}

#-------------------------------------------------------------------

=head2 www_editFeatureSave 

Process the editFeature form.

=cut

sub www_editFeatureSave {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $fid = $self->session->form->process('fid', 'text');
    my $newFid = $self->setCollateral(
        'featureJSON',
        'featureId',
        $fid,
        {
            feature   => $self->session->form->process('feature','text'),
            featureId => $fid,
        },
    );
    return '' unless($self->session->form->process('proceed'));
    return $self->www_editFeature('new');
}

#-------------------------------------------------------------------

=head2 www_editSpecification 

Form to add or edit a specification.

=cut

sub www_editSpecification {
    my $self = shift;
    my $sid = shift || $self->session->form->process('sid');
    return $self->session->privilege->insufficient() unless ($self->canEdit);

    my $i18n = WebGUI::International->new($self->session,'Asset_Product');
    my $data = $self->getCollateral('specificationJSON', 'specificationId', $sid);
    my $f    = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);

    $f->hidden(
        -name => 'sid',
        -value => $sid,
    );
    $f->hidden(
        -name => 'func',
        -value => 'editSpecificationSave',
    );
    $f->text(
        -name => 'name',
        -label => $i18n->get(26),
        -hoverHelp => $i18n->get('26 description'),
        -value => $data->{name},
    );
    $f->text(
        -name => 'value',
        -label => $i18n->get(27),
        -hoverHelp => $i18n->get('27 description'),
        -value => $data->{value},
    );
    $f->text(
        -name => 'units',
        -label => $i18n->get(29),
        -hoverHelp => $i18n->get('29 description'),
        -value => $data->{units},
    );
    $f->yesNo(
        -name => 'proceed',
        -label => $i18n->get(28),
        -hoverHelp => $i18n->get('28 description'),
    );
    $f->submit;
    return $self->getAdminConsole->render($f->print, 'product specification add/edit');
}

#-------------------------------------------------------------------

=head2 www_editSpecificationSave 

Process the editSpecification form.

=cut

sub www_editSpecificationSave {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $sid = $self->session->form->process('sid'); 
    $self->setCollateral(
        'specificationJSON',
        'specificationId',
        $sid,
        {
            specificationId => $sid,
            name            => $self->session->form->process('name',  'text'),
            value           => $self->session->form->process('value', 'text'),
            units           => $self->session->form->process('units', 'text'),
        },
    );

    return '' unless($self->session->form->process('proceed'));
    return $self->www_editSpecification('new');
}

#-------------------------------------------------------------------

=head2 www_editVariant 

Form to add or edit a variant.

=cut

sub www_editVariant {
    my $self = shift;
    my $vid  = shift || $self->session->form->process("vid");
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $i18n = WebGUI::International->new($self->session,'Asset_Product');
    my $data = $self->getCollateral("variantsJSON", 'variantId', $vid);
    my $f    = WebGUI::HTMLForm->new($self->session, -action=>$self->getUrl);
    $f->hidden(
        -name => 'func',
        -value => 'editVariantSave',
    );
    $f->hidden(
        -name => 'vid',
        -value => $vid,
    );
    $f->text(
        -name      => 'varSku',
        -label     => $i18n->get('variant sku'),
        -hoverHelp => $i18n->get('variant sku description'),
        -value     => $data->{varSku},
    );
    $f->text(
        -name      => 'shortdesc',
        -maxlength => 30,
        -label     => $i18n->get('shortdesc'),
        -hoverHelp => $i18n->get('shortdesc description'),
        -value     => $data->{shortdesc},
    );
    $f->float(
        -name      => 'price',
        -label     => $i18n->get(10),
        -hoverHelp => $i18n->get('10 description'),
        -value     => $data->{price},
    );
    $f->float(
        -name      => 'weight',
        -label     => $i18n->get('weight'),
        -hoverHelp => $i18n->get('weight description'),
        -value     => $data->{weight},
    );
    $f->integer(
        -name      => 'quantity',
        -label     => $i18n->get('quantity'),
        -hoverHelp => $i18n->get('quantity description'),
        -value     => $data->{quantity},
    );
    $f->yesNo(
        -name      => "proceed",
        -label     => $i18n->get('add another variant'),
        -hoverHelp => $i18n->get('add another variant description'),
    );
    $f->submit;
    return $self->getAdminConsole->render($f->print, 'add variant');
}

#-------------------------------------------------------------------

=head2 www_editVariantSave 

Process the editVariant form.

=cut

sub www_editVariantSave {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    my $vid = $self->session->form->process('vid', 'text');
    $self->setCollateral(
        'variantsJSON',
        'variantId',
        $vid,
        {
            variantId => $vid,
            varSku    => $self->session->form->process('varSku',    'text'),
            shortdesc => $self->session->form->process('shortdesc', 'text'),
            price     => $self->session->form->process('price',     'float'),
            weight    => $self->session->form->process('weight',    'float'),
            quantity  => $self->session->form->process('quantity',  'integer'),
        }
    );

    return $self->www_view unless($self->session->form->process('proceed'));
    return $self->www_editVariant('new');
}

#-------------------------------------------------------------------

=head2 www_moveAccessoryDown 

Move an accessory, given by C<aid>, down one place.

=cut

sub www_moveAccessoryDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown('accessoryJSON', 'accessoryAssetId', $self->session->form->process('aid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_moveAccessoryUp 

Move an accessory, given by C<aid>, up one place.

=cut

sub www_moveAccessoryUp {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp('accessoryJSON', 'accessoryAssetId', $self->session->form->process('aid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_moveBenefitDown 

Move an benefit, given by C<bid>, down one place.

=cut

sub www_moveBenefitDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown("benefitJSON", 'benefitId', $self->session->form->process("bid"));
    return "";
}

#-------------------------------------------------------------------

=head2 www_moveBenefitUp 

Move an benefit, given by C<bid>, up one place.

=cut

sub www_moveBenefitUp {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp("benefitJSON", 'benefitId', $self->session->form->process("bid"));
    return "";
}

#-------------------------------------------------------------------

=head2 www_moveFeatureDown 

Move an feature, given by C<fid>, down one place.

=cut

sub www_moveFeatureDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown('featureJSON', 'featureId', $self->session->form->process('fid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_moveFeatureUp 

Move an feature, given by C<fid>, up one place.

=cut

sub www_moveFeatureUp {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp('featureJSON', 'featureId', $self->session->form->process('fid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_moveRelatedDown 

Move a related asset, given by C<rid>, down one place.

=cut

sub www_moveRelatedDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown('relatedJSON', 'relatedAssetId', $self->session->form->process('rid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_moveRelatedUp 

Move a related asset, given by C<rid>, up one place.

=cut

sub www_moveRelatedUp {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp('relatedJSON', 'relatedAssetId', $self->session->form->process('rid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_moveSpecificationDown 

Move an specification, given by C<sid>, down one place.

=cut

sub www_moveSpecificationDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown('specificationJSON', 'specificationId', $self->session->form->process('sid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_moveSpecificationUp 

Move an specification, given by C<sid>, up one place.

=cut

sub www_moveSpecificationUp {
    my $self = shift;   
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp('specificationJSON', 'specificationId', $self->session->form->process('sid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_moveVariantDown 

Move an variant, given by C<vid>, down one place.

=cut

sub www_moveVariantDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown('variantsJSON', 'variantId', $self->session->form->process('vid'));
    return '';
}

#-------------------------------------------------------------------

=head2 www_moveVariantUp 

Move an variant, given by C<vid>, up one place.

=cut

sub www_moveVariantUp {
    my $self = shift;   
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp('variantsJSON', 'variantId', $self->session->form->process('vid'));
    return '';
}

#-------------------------------------------------------------------

=head2 view 

Render the view screen for the Product, with variants, specification, related products,
file collateral, and everything else.

=cut

sub view {
    my $self = shift;
    my $error = shift;
    my $session = $self->session;
    my $cache = $session->cache;
    if (!$session->var->isAdminOn && $self->get("cacheTimeout") > 10){
        my $out = $cache->get("view_".$self->getId);
        return $out if $out;
    }
    my (%data, $segment, %var, @featureloop, @benefitloop, @specificationloop, @accessoryloop, @relatedloop);
    tie %data, 'Tie::CPHash';
    my $brochure = $self->get("brochure");
    my $manual   = $self->get("manual");
    my $warranty = $self->get("warranty");

    my $image1 = $self->get("image1");
    my $image2 = $self->get("image2");
    my $image3 = $self->get("image3");

    #---brochure
    my $i18n = WebGUI::International->new($session,'Asset_Product');
    if ($brochure) {
        my $file = WebGUI::Storage->get($session,$brochure);
        if ($self->getFilename($file)) {
            $var{"brochure_icon"}  = $self->getFileIconUrl($file);
            $var{"brochure_label"} = $i18n->get(13);
            $var{"brochure_URL"}   = $self->getFileUrl($file);
        }
    }
    #---manual
    if ($manual) {
        my $file = WebGUI::Storage->get($session,$manual);
        if ($self->getFilename($file)) {
            $var{"manual_icon"}  = $self->getFileIconUrl($file);
            $var{"manual_label"} = $i18n->get(14);
            $var{"manual_URL"}   = $self->getFileUrl($file);
        }
    }
    #---warranty
    if ($warranty) {
        my $file = WebGUI::Storage->get($session,$warranty);
        if ($self->getFilename($file)) {
            $var{"warranty_icon"}  = $self->getFileIconUrl($file);
            $var{"warranty_label"} = $i18n->get(15);
            $var{"warranty_URL"}   = $self->getFileUrl($file);
        }
    }
    #---image1
    if ($image1) {
        my $file = WebGUI::Storage->get($session,$image1);
        $var{thumbnail1} = $self->getThumbnailUrl($file);
        $var{image1}     = $self->getFileUrl($file);
    }
    #---image2
    if ($image2) {
        my $file = WebGUI::Storage->get($session,$image2);
        $var{thumbnail2} = $self->getThumbnailUrl($file);
        $var{image2}     = $self->getFileUrl($file);
    }
    #---image3
    if ($image3) {
        my $file = WebGUI::Storage->get($session,$image3);
        $var{thumbnail3} = $self->getThumbnailUrl($file);
        $var{image3}     = $self->getFileUrl($file);
   }
   
    #---features 
    $var{'addFeature_url'} = $self->getUrl('func=editFeature&fid=new');
    $var{'addFeature_label'} = $i18n->get(34);
    foreach my $collateral ( @{ $self->getAllCollateral('featureJSON') } ) {
        my $id = $collateral->{featureId};
        $segment = $self->session->icon->delete('func=deleteFeatureConfirm&fid='.$id,$self->get('url'),$i18n->get(3))
                 . $self->session->icon->edit('func=editFeature&fid='.$id,$self->get('url'))
                 . $self->session->icon->moveUp('func=moveFeatureUp&fid='.$id,$self->get('url'))
                 . $self->session->icon->moveDown('func=moveFeatureDown&fid='.$id,$self->get('url'));
        push(@featureloop,{
                          'feature_feature'  => $collateral->{feature},
                          'feature_controls' => $segment
                         });
    }
    $var{feature_loop} = \@featureloop;

    #---benefits 
    $var{"addBenefit_url"} = $self->getUrl('func=editBenefit&bid=new');
    $var{"addBenefit_label"} = $i18n->get(55);
    foreach my $collateral ( @{ $self->getAllCollateral('benefitJSON') } ) {
        my $id = $collateral->{benefitId};
        $segment = $self->session->icon->delete('func=deleteBenefitConfirm&bid='.$id,$self->get("url"),$i18n->get(48))
                 . $self->session->icon->edit('func=editBenefit&bid='.$id,$self->get("url"))
                 . $self->session->icon->moveUp('func=moveBenefitUp&bid='.$id,$self->get("url"))
                 . $self->session->icon->moveDown('func=moveBenefitDown&bid='.$id,$self->get("url"));
        push(@benefitloop,{
                          "benefit_benefit"=>$collateral->{benefit},
                          "benefit_controls"=>$segment
        });
    }
    $var{benefit_loop} = \@benefitloop;

    #---specifications 
    $var{'addSpecification_url'} = $self->getUrl('func=editSpecification&sid=new');
    $var{'addSpecification_label'} = $i18n->get(35);
    foreach my $collateral ( @{ $self->getAllCollateral('specificationJSON') } ) {
        my $id = $collateral->{specificationId};
        $segment = $self->session->icon->delete('func=deleteSpecificationConfirm&sid='.$id,$self->get('url'),$i18n->get(5))
                 . $self->session->icon->edit('func=editSpecification&sid='.$id,$self->get('url'))
                 . $self->session->icon->moveUp('func=moveSpecificationUp&sid='.$id,$self->get('url'))
                 . $self->session->icon->moveDown('func=moveSpecificationDown&sid='.$id,$self->get('url'));
        push(@specificationloop,{
                                   'specification_controls'      => $segment,
                                   'specification_specification' => $collateral->{value},
                                   'specification_units'         => $collateral->{units},
                                   'specification_label'         => $collateral->{name},
                                });
    }
    $var{specification_loop} = \@specificationloop;

    #---accessories 
    $var{'addaccessory_url'}   = $self->getUrl('func=addAccessory');
    $var{'addaccessory_label'} = $i18n->get(36);
    ##Need an id for collateral operations, and an assetId for asset instantiation.
    foreach my $collateral ( @{ $self->getAllCollateral('accessoryJSON') } ) {
        my $id = $collateral->{accessoryAssetId};
        $segment = $self->session->icon->delete('func=deleteAccessoryConfirm&aid='.$id,$self->get('url'),$i18n->get(2))
                 . $self->session->icon->moveUp('func=moveAccessoryUp&aid='.$id,$self->get('url'))
                 . $self->session->icon->moveDown('func=moveAccessoryDown&aid='.$id,$self->get('url'));
        my $accessory = WebGUI::Asset->newById($session, $collateral->{accessoryAssetId});
        push(@accessoryloop,{
                           'accessory_URL'      => $accessory->getUrl,
                           'accessory_title'    => $accessory->getTitle,
                           'accessory_controls' => $segment,
                           });
    }
    $var{accessory_loop} = \@accessoryloop;

    #---related
    $var{'addrelatedproduct_url'}   = $self->getUrl('func=addRelated');
    $var{'addrelatedproduct_label'} = $i18n->get(37);
    foreach my $collateral ( @{ $self->getAllCollateral('relatedJSON')} ) {
        my $id = $collateral->{relatedAssetId};
        $segment = $self->session->icon->delete('func=deleteRelatedConfirm&rid='.$id, $self->get('url'),$i18n->get(4))
                 . $self->session->icon->moveUp('func=moveRelatedUp&rid='.$id, $self->get('url'))
                 . $self->session->icon->moveDown('func=moveRelatedDown&rid='.$id, $self->get('url'));
        my $related = WebGUI::Asset->newById($session, $collateral->{relatedAssetId});
        push(@relatedloop,{
                          'relatedproduct_URL'      => $related->getUrl,
                          'relatedproduct_title'    => $related->getTitle,
                          'relatedproduct_controls' => $segment,
                          });
    }
    $var{relatedproduct_loop} = \@relatedloop;

    #---variants
    my @variantLoop;
    my %variants = ();
    tie %variants, 'Tie::IxHash';
    foreach my $collateral ( @{ $self->getAllCollateral('variantsJSON')} ) {
        my $id = $collateral->{variantId};
        $segment = $self->session->icon->delete('func=deleteVariantConfirm&vid='.$id,$self->get('url'),$i18n->get('delete variant confirm'))
                 . $self->session->icon->edit('func=editVariant&vid='.$id,$self->get('url'))
                 . $self->session->icon->moveUp('func=moveVariantUp&vid='.$id,$self->get('url'))
                 . $self->session->icon->moveDown('func=moveVariantDown&vid='.$id,$self->get('url'));
        my $price = sprintf('%.2f', $collateral->{price});
        my $desc  = $collateral->{shortdesc};
        push(@variantLoop,{
                                   'variant_id'       => $id,
                                   'variant_controls' => $segment,
                                   'variant_sku'      => $collateral->{varSku},
                                   'variant_title'    => $desc,
                                   'variant_price'    => $price,
                                   'variant_weight'   => $collateral->{weight},
                                   'variant_quantity' => $collateral->{quantity},
                                });
        if ($collateral->{quantity} > 0) {
            $variants{$id} = join ", ", $desc, $price;
        }
    }

    if (scalar keys %variants) {
        ##Don't display the form unless you have available variants to sell.
        $var{buy_form_header} = WebGUI::Form::formHeader($session, { action => $self->getUrl} )
                              . WebGUI::Form::hidden($session, { name=>'func', value=>'buy', } );
        $var{buy_form_footer} = WebGUI::Form::formFooter($session);
        $var{buy_options}     = WebGUI::Form::selectBox($session,
            {
                name    => 'vid',
                label   => $i18n->get('add to cart'),
                options => \%variants,
                value   => [0],
            },
        );
        $var{buy_button} = WebGUI::Form::submit($session, { value => $i18n->get('add to cart') } );
        $var{in_stock} = 1;
    }
    else {
        $var{in_stock} = 0;
        $var{no_stock_message} = $i18n->get('out of stock');
    }

    if ($self->canEdit) {
        $var{'addvariant_url'}   = $self->getUrl('func=editVariant');
        $var{'addvariant_label'} = $i18n->get('add a variant');
        $var{'canEdit'}          = 1;
    }
    $var{variant_loop}        = \@variantLoop;
    $var{hasAddedToCart}      = $self->{_hasAddedToCart};
    $var{continueShoppingUrl} = $self->getUrl;

    my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
    if (!$self->session->var->isAdminOn && $self->cacheTimeout > 10 && $self->{_hasAddedToCart} != 1){
        $cache->set("view_".$self->getId, $out, $self->cacheTimeout);
    }
    return $out;
}

#-------------------------------------------------------------------

=head2 www_view ( )

Extend the base method to handle caching.

=cut

sub www_view {
    my $self = shift;
    $self->session->http->setCacheControl($self->cacheTimeout);
    $self->SUPER::www_view(@_);
}

1;

