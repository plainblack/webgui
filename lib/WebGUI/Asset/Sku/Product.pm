package WebGUI::Asset::Sku::Product;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::Cache;
use WebGUI::HTMLForm;
use WebGUI::Storage::Image;
use WebGUI::SQL;
use WebGUI::Utility;
use JSON;

use base 'WebGUI::Asset::Sku';

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

=head2 addToCart ( variant )

Override/extend Sku's addToCart method to handle inventory control.

=head3 variant

A hashref of variant information for the variant of the Product
that is being added to the cart.  Adding the variant to the
cart decrements the quantity by 1.

=cut

sub addToCart {
    my $self     = shift;
    my $variant  = shift;
    $variant->{quantity} -= 1;
    $self->setCollateral('variantsJSON', 'variantId', $variant);
    $self->SUPER::addToCart($variant);
}

#-------------------------------------------------------------------
sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my $i18n = WebGUI::International->new($session,"Asset_Product");
    my %properties;
    tie %properties, 'Tie::IxHash';
    %properties = (
        cacheTimeout => {
            tab => "display",
            fieldType => "interval",
            defaultValue => 3600,
            uiLevel => 8,
            label => $i18n->get("cache timeout"),
            hoverHelp => $i18n->get("cache timeout help")
        },
        templateId =>{
            fieldType=>"template",
            tab => "display",
                  namespace=>"Product",
            label=>$i18n->get(62),
            hoverHelp=>$i18n->get('62 description'),
            defaultValue=>'PBtmpl0000000000000056'
        },
        image1=>{
            tab => "properties",
            fieldType=>"image",
            defaultValue=>undef,
            maxAttachments=>1,
            label=>$i18n->get(7),
            deleteFileUrl=>$session->url->page("func=deleteFileConfirm;file=image1;filename=")
        },
        image2=>{
            tab => "properties",
            fieldType=>"image",
            maxAttachments=>1,
            label=>$i18n->get(8),
            deleteFileUrl=>$session->url->page("func=deleteFileConfirm;file=image2;filename="),
            defaultValue=>undef
        },
        image3=>{
            tab => "properties",
            fieldType=>"image",
            maxAttachments=>1,
            label=>$i18n->get(9),
            deleteFileUrl=>$session->url->page("func=deleteFileConfirm;file=image3;filename="),
            defaultValue=>undef
        },
        brochure=>{
            tab => "properties",
            fieldType=>"file",
            maxAttachments=>1,
            label=>$i18n->get(13),
            deleteFileUrl=>$session->url->page("func=deleteFileConfirm;file=brochure;filename="),
            defaultValue=>undef
        },
        manual=>{
            tab => "properties",
            fieldType=>"file",
            maxAttachments=>1,
            label=>$i18n->get(14),
            deleteFileUrl=>$session->url->page("func=deleteFileConfirm;file=manual;filename="),
            defaultValue=>undef
        },
        warranty=>{
            tab => "properties",
            fieldType=>"file",
            maxAttachments=>1,
            label=>$i18n->get(15),
            deleteFileUrl=>$session->url->page("func=deleteFileConfirm;file=warranty;filename="),
            defaultValue=>undef
        },
        variantsJSON => {
            ##Collateral data is stored as JSON in here
            autoGenerate => 0,
            defaultValue => '[]',
        },
        accessoryJSON => {
            ##Collateral data is stored as JSON in here
            autoGenerate => 0,
            defaultValue => '[]',
        },
        relatedJSON => {
            ##Collateral data is stored as JSON in here
            autoGenerate => 0,
            defaultValue => '[]',
        },
        specificationJSON => {
            ##Collateral data is stored as JSON in here
            autoGenerate => 0,
            defaultValue => '[]',
        },
        featureJSON => {
            ##Collateral data is stored as JSON in here
            autoGenerate => 0,
            defaultValue => '[]',
        },
        benefitJSON => {
            ##Collateral data is stored as JSON in here
            autoGenerate => 0,
            defaultValue => '[]',
        },
    );
    push(@{$definition}, {
        assetName=>$i18n->get('assetName'),
        autoGenerateForms=>1,
        icon=>'product.gif',
        tableName=>'Product',
        className=>'WebGUI::Asset::Sku::Product',
        properties=>\%properties
        }
    );
    return $class->SUPER::definition($session, $definition);
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
sub duplicate {
    my $self = shift;
    my $newAsset = $self->SUPER::duplicate(@_);

    foreach my $file ('image1', 'image2', 'image3', 'manual', 'brochure', 'warranty') {
        $self->_duplicateFile($newAsset, $file);
    }

    return $newAsset;

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
    return $table->[$index];
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
    return $self->getOptions->{shortdesc};
}


#-------------------------------------------------------------------
sub getFileIconUrl {
    my $self = shift;
    my $store = $_[0];
    return $store->getFileIconUrl($self->getFilename($store));
}

#-------------------------------------------------------------------
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
sub getFileUrl {
    my $self = shift;
    my $store = $_[0];
    return $store->getUrl($self->getFilename($store));
}

#-------------------------------------------------------------------

=head2 getPrice ( )

Only returns a price after options from a variant have been applied to this
Product.

=cut

sub getPrice {
    my $self = shift;
    return $self->getOptions->{price};
}

#-------------------------------------------------------------------

=head2 getQuantityAvailable ( )

Returns the amount of a variant that are available.

=cut

sub getQuantityAvailable {
    my $self = shift;
    return $self->getOptions->{quantity};
}

#-------------------------------------------------------------------
sub getThumbnailUrl {
    my $self = shift;
    my $store = shift || WebGUI::Storage::Image->get($self->session, $self->get('image1'));
    return $store->getThumbnailUrl($store->getFiles->[0]);
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

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
    $template->prepare;
    $self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------
sub purge {
    my $self = shift;
    my $sth = $self->session->db->read("select image1, image2, image3, brochure, manual, warranty from Product where assetId=".$self->session->db->quote($self->getId));
    while (my @array = $sth->array) {
        foreach my $id (@array){
            next if ($id eq "");
            WebGUI::Storage->get($self->session,$id)->delete; 
        }
    }
    $sth->finish;
    $self->SUPER::purge();
}

#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
    my $self = shift;
    WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
    $self->SUPER::purgeCache;
}

#-------------------------------------------------------------------

sub purgeRevision    {
    my $self = shift;
    WebGUI::Storage->get($self->session,$self->get("image1"))->delete if    ($self->get("image1"));
    WebGUI::Storage->get($self->session,$self->get("image2"))->delete if    ($self->get("image2"));
    WebGUI::Storage->get($self->session,$self->get("image3"))->delete if    ($self->get("image3"));
    WebGUI::Storage->get($self->session,$self->get("brochure"))->delete if    ($self->get("brochure"));
    WebGUI::Storage->get($self->session,$self->get("manual"))->delete if    ($self->get("manual"));
    WebGUI::Storage->get($self->session,$self->get("warranty"))->delete if    ($self->get("warranty"));
    return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------

=head2 reorderCollateral ( tableName,keyName [,setName,setValue] )

Resequences collateral data. Typically useful after deleting a collateral item to remove the gap created by the deletion.

=head3 tableName

The name of the table to resequence.

=head3 keyName

The key column name used to determine which data needs sorting within the table.

=head3 setName

Defaults to "assetId". This is used to define which data set to reorder.

=head3 setValue

Used to define which data set to reorder. Defaults to the value of setName (default "assetId", see above) in the wobject properties.

=cut

sub reorderCollateral {
    my $self = shift;
    my $table = shift;
    my $keyName = shift;
    my $setName = shift || "assetId";
    my $setValue = shift || $self->get($setName);
    my $i = 1;
    my $sth = $self->session->db->read("select $keyName from $table where $setName=? order by sequenceNumber", [$setValue]);
    my $sth2 = $self->session->db->prepare("update $table set sequenceNumber=? where $setName=? and $keyName=?");
    while (my ($id) = $sth->array) {
        $sth2->execute([$i, $setValue, $id]);
        $i++;
    }
    $sth2->finish;
    $sth->finish;
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
    return '';
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
sub www_deleteBenefitConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->deleteCollateral("benefitJSON", 'benefitId', $self->session->form->process("bid"));
    return "";
}

#-------------------------------------------------------------------
sub www_deleteFeatureConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->deleteCollateral('featureJSON', 'featureId', $self->session->form->process('fid'));
    return '';
}

#-------------------------------------------------------------------
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
sub www_deleteRelatedConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->deleteCollateral('relatedJSON', 'relatedAssetId', $self->session->form->process('rid'));
    return '';
}

#-------------------------------------------------------------------
sub www_deleteVariantConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->deleteCollateral('variantsJSON', 'variantId', $self->session->form->process('vid'));
    return '';
}

#-------------------------------------------------------------------
sub www_deleteSpecificationConfirm {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->deleteCollateral('specificationJSON', 'specificationId', $self->session->form->process('sid'));
    return '';
}


#-------------------------------------------------------------------
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
sub www_moveAccessoryDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown('accessoryJSON', 'accessoryAssetId', $self->session->form->process('aid'));
    return '';
}

#-------------------------------------------------------------------
sub www_moveAccessoryUp {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp('accessoryJSON', 'accessoryAssetId', $self->session->form->process('aid'));
    return '';
}

#-------------------------------------------------------------------
sub www_moveBenefitDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown("benefitJSON", 'benefitId', $self->session->form->process("bid"));
    return "";
}

#-------------------------------------------------------------------
sub www_moveBenefitUp {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp("benefitJSON", 'benefitId', $self->session->form->process("bid"));
    return "";
}

#-------------------------------------------------------------------
sub www_moveFeatureDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown('featureJSON', 'featureId', $self->session->form->process('fid'));
    return '';
}

#-------------------------------------------------------------------
sub www_moveFeatureUp {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp('featureJSON', 'featureId', $self->session->form->process('fid'));
    return '';
}

#-------------------------------------------------------------------
sub www_moveRelatedDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown('relatedJSON', 'relatedAssetId', $self->session->form->process('rid'));
    return '';
}

#-------------------------------------------------------------------
sub www_moveRelatedUp {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp('relatedJSON', 'relatedAssetId', $self->session->form->process('rid'));
    return '';
}

#-------------------------------------------------------------------
sub www_moveSpecificationDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown('specificationJSON', 'specificationId', $self->session->form->process('sid'));
    return '';
}

#-------------------------------------------------------------------
sub www_moveSpecificationUp {
    my $self = shift;   
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp('specificationJSON', 'specificationId', $self->session->form->process('sid'));
    return '';
}

#-------------------------------------------------------------------
sub www_moveVariantDown {
    my $self = shift;
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralDown('variantsJSON', 'variantId', $self->session->form->process('vid'));
    return '';
}

#-------------------------------------------------------------------
sub www_moveVariantUp {
    my $self = shift;   
    return $self->session->privilege->insufficient() unless ($self->canEdit);
    $self->moveCollateralUp('variantsJSON', 'variantId', $self->session->form->process('vid'));
    return '';
}

#-------------------------------------------------------------------
sub view {
    my $self = shift;
    my $session = $self->session;
    if (!$session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
        my $out = WebGUI::Cache->new($self->session,"view_".$self->getId)->get;
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
        $var{"brochure.icon"}  = $self->getFileIconUrl($file);
        $var{"brochure.label"} = $i18n->get(13);
        $var{"brochure.URL"}   = $self->getFileUrl($file);
    }
    #---manual
    if ($manual) {
        my $file = WebGUI::Storage->get($session,$manual);
        $var{"manual.icon"}  = $self->getFileIconUrl($file);
        $var{"manual.label"} = $i18n->get(14);
        $var{"manual.URL"}   = $self->getFileUrl($file);
    }
    #---warranty
    if ($warranty) {
        my $file = WebGUI::Storage->get($session,$warranty);
        $var{"warranty.icon"}  = $self->getFileIconUrl($file);
        $var{"warranty.label"} = $i18n->get(15);
        $var{"warranty.URL"}   = $self->getFileUrl($file);
    }
    #---image1
    if ($image1) {
        my $file = WebGUI::Storage::Image->get($session,$image1);
        $var{thumbnail1} = $self->getThumbnailUrl($file);
        $var{image1}     = $self->getFileUrl($file);
    }
    #---image2
    if ($image2) {
        my $file = WebGUI::Storage::Image->get($session,$image2);
        $var{thumbnail2} = $self->getThumbnailUrl($file);
        $var{image2}     = $self->getFileUrl($file);
    }
    #---image3
    if ($image3) {
        my $file = WebGUI::Storage::Image->get($session,$image3);
        $var{thumbnail3} = $self->getThumbnailUrl($file);
        $var{image3}     = $self->getFileUrl($file);
   }
   
    #---features 
    $var{'addFeature.url'} = $self->getUrl('func=editFeature&fid=new');
    $var{'addFeature.label'} = $i18n->get(34);
    foreach my $collateral ( @{ $self->getAllCollateral('featureJSON') } ) {
        my $id = $collateral->{featureId};
        $segment = $self->session->icon->delete('func=deleteFeatureConfirm&fid='.$id,$self->get('url'),$i18n->get(3))
                 . $self->session->icon->edit('func=editFeature&fid='.$id,$self->get('url'))
                 . $self->session->icon->moveUp('func=moveFeatureUp&fid='.$id,$self->get('url'))
                 . $self->session->icon->moveDown('func=moveFeatureDown&fid='.$id,$self->get('url'));
        push(@featureloop,{
                          'feature.feature'  => $collateral->{feature},
                          'feature.controls' => $segment
                         });
    }
    $var{feature_loop} = \@featureloop;

    #---benefits 
    $var{"addBenefit.url"} = $self->getUrl('func=editBenefit&bid=new');
    $var{"addBenefit.label"} = $i18n->get(55);
    foreach my $collateral ( @{ $self->getAllCollateral('benefitJSON') } ) {
        my $id = $collateral->{benefitId};
        $segment = $self->session->icon->delete('func=deleteBenefitConfirm&bid='.$id,$self->get("url"),$i18n->get(48))
                 . $self->session->icon->edit('func=editBenefit&bid='.$id,$self->get("url"))
                 . $self->session->icon->moveUp('func=moveBenefitUp&bid='.$id,$self->get("url"))
                 . $self->session->icon->moveDown('func=moveBenefitDown&bid='.$id,$self->get("url"));
        push(@benefitloop,{
                          "benefit.benefit"=>$collateral->{benefit},
                          "benefit.controls"=>$segment
        });
    }
    $var{benefit_loop} = \@benefitloop;

    #---specifications 
    $var{'addSpecification.url'} = $self->getUrl('func=editSpecification&sid=new');
    $var{'addSpecification.label'} = $i18n->get(35);
    foreach my $collateral ( @{ $self->getAllCollateral('specificationJSON') } ) {
        my $id = $collateral->{specificationId};
        $segment = $self->session->icon->delete('func=deleteSpecificationConfirm&sid='.$id,$self->get('url'),$i18n->get(5))
                 . $self->session->icon->edit('func=editSpecification&sid='.$id,$self->get('url'))
                 . $self->session->icon->moveUp('func=moveSpecificationUp&sid='.$id,$self->get('url'))
                 . $self->session->icon->moveDown('func=moveSpecificationDown&sid='.$id,$self->get('url'));
        push(@specificationloop,{
                                   'specification.controls'      => $segment,
                                   'specification.specification' => $collateral->{value},
                                   'specification.units'         => $collateral->{units},
                                   'specification.label'         => $collateral->{name},
                                });
    }
    $var{specification_loop} = \@specificationloop;

    #---accessories 
    $var{'addaccessory.url'}   = $self->getUrl('func=addAccessory');
    $var{'addaccessory.label'} = $i18n->get(36);
    ##Need an id for collateral operations, and an assetId for asset instantiation.
    foreach my $collateral ( @{ $self->getAllCollateral('accessoryJSON') } ) {
        my $id = $collateral->{accessoryAssetId};
        $segment = $self->session->icon->delete('func=deleteAccessoryConfirm&aid='.$id,$self->get('url'),$i18n->get(2))
                 . $self->session->icon->moveUp('func=moveAccessoryUp&aid='.$id,$self->get('url'))
                 . $self->session->icon->moveDown('func=moveAccessoryDown&aid='.$id,$self->get('url'));
        my $accessory = WebGUI::Asset->newByDynamicClass($session, $collateral->{accessoryAssetId});
        push(@accessoryloop,{
                           'accessory.URL'      => $accessory->getUrl,
                           'accessory.title'    => $accessory->getTitle,
                           'accessory.controls' => $segment,
                           });
    }
    $var{accessory_loop} = \@accessoryloop;

    #---related
    $var{'addrelatedproduct.url'}   = $self->getUrl('func=addRelated');
    $var{'addrelatedproduct.label'} = $i18n->get(37);
    foreach my $collateral ( @{ $self->getAllCollateral('relatedJSON')} ) {
        my $id = $collateral->{relatedAssetId};
        $segment = $self->session->icon->delete('func=deleteRelatedConfirm&rid='.$id, $self->get('url'),$i18n->get(4))
                 . $self->session->icon->moveUp('func=moveRelatedUp&rid='.$id, $self->get('url'))
                 . $self->session->icon->moveDown('func=moveRelatedDown&rid='.$id, $self->get('url'));
        my $related = WebGUI::Asset->newByDynamicClass($session, $collateral->{relatedAssetId});
        push(@relatedloop,{
                          'relatedproduct.URL'      => $related->getUrl,
                          'relatedproduct.title'    => $related->getTitle,
                          'relatedproduct.controls' => $segment,
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
        push(@variantLoop,{
                                   'variant.controls' => $segment,
                                   'variant.sku'      => $collateral->{varSku},
                                   'variant.title'    => $collateral->{shortdesc},
                                   'variant.price'    => $collateral->{price},
                                   'variant.weight'   => $collateral->{weight},
                                   'variant.quantity' => $collateral->{quantity},
                                });
        $variants{$id} = $collateral->{shortdesc};
    }
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
    $var{buy_button}      = WebGUI::Form::submit($session, { value => $i18n->get('add to cart') } );
    if ($self->canEdit) {
        $var{'addvariant.url'}   = $self->getUrl('func=editVariant');
        $var{'addvariant.label'} = $i18n->get('add a variant');
        $var{variant_loop} = \@variantLoop;
    }
    else {
        $var{variant_loop} = [];
    }

    my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
    if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
        WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("cacheTimeout"));
    }
    return $out;
}

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Sku::www_view() for details.

=cut

sub www_view {
    my $self = shift;
    $self->session->http->setCacheControl($self->get("cacheTimeout"));
    $self->SUPER::www_view(@_);
}

1;

