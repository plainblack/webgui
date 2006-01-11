package WebGUI::Asset::Wobject::Product;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Storage::Image;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;


our @ISA = qw(WebGUI::Asset::Wobject);

#-------------------------------------------------------------------
sub _addFileTab {
	my $self = shift;
	my $tabform = $_[0];
	my $column = $_[1];
	my $internationalId = $_[2];
	unless ($self->get($column)){
		$tabform->getTab("properties")->file(
		-name=>$column,
		-label=>WebGUI::International::get($internationalId,"Asset_Product"),
		);
		return;
	}

	my $file = WebGUI::Storage->get($self->get($column));
	$tabform->getTab("properties")->readOnly(
	-value=>'<a href="'.$self->getUrl('func=deleteFileConfirm&file='.$column).'">'.WebGUI::International::get("deleteImage","Asset_Product").'</a>',
	-label=>WebGUI::International::get($internationalId,"Asset_Product"),
	);
}

#-------------------------------------------------------------------
sub _duplicateFile {
   my $self = shift;
   my $newAsset = $_[0];
   my $column = $_[1];
   if($self->get($column)){
      my $file = WebGUI::Storage->get($self->get($column));
	  my $newstore = $file->copy;
	  $newAsset->update({ $column=>$newstore->getId });
   }
}

#-------------------------------------------------------------------
sub _save {
	my $self = shift;
	my $file = WebGUI::Storage::Image->create;
	my $filename = $file->addFileFromFormPost($_[0]);
	unless ($filename) {
		$file->delete;
		return "";
	}
	$file->generateThumbnail($filename);
	$self->session->db->write("update Product set $_[0]=".$self->session->db->quote($file->getId)." where assetId=".$self->session->db->quote($self->getId)." and revisionDate=".$self->session->db->quote($self->get("revisionDate")));
}

#-------------------------------------------------------------------

=head2 addRevision

Override the default method in order to deal with attachments.

=cut

sub addRevision {
	my $self = shift;
	my $newSelf = $self->SUPER::addRevision(@_);
	foreach my $field (qw(image1 image2 image3 brochure manual warranty)) {
		if ($self->get($field)) {
			my $newStorage = WebGUI::Storage->get($self->get($field))->copy;
			$newSelf->update({$field=>$newStorage->getId});
			$self->session->db->write("update Product set $field=".$self->session->db->quote($newStorage->getId)." where assetId=".$self->session->db->quote($newSelf->getId)." and revisionDate=".$self->session->db->quote($newSelf->get("revisionDate")));
		}
	}
	return $newSelf;
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $definition = shift;
	push(@{$definition}, {
		assetName=>WebGUI::International::get('assetName',"Asset_Product"),
		icon=>'product.gif',
		tableName=>'Product',
		className=>'WebGUI::Asset::Wobject::Product',
		properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000056'
			},
			price=>{
				fieldType=>"text",
				defaultValue=>undef
			},
			productNumber=>{
				fieldType=>"text",
				defaultValue=>undef
			},
#			image1=>{
#				fieldType=>"text",
#				defaultValue=>undef
#			},
#			image2=>{
#				fieldType=>"text",
#				defaultValue=>undef
#			},
#			image3=>{
#				fieldType=>"text",
#				defaultValue=>undef
#			},
#			brochure=>{
#				fieldType=>"text",
#				defaultValue=>undef
#			},
#			manual=>{
#				fieldType=>"text",
#				defaultValue=>undef
#			},
#			warranty=>{
#				fieldType=>"text",
#				defaultValue=>undef
#			},
		}
	});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------
sub duplicate {
   my $self = shift;
   my $newAsset = $self->SUPER::duplicate(shift);
   
   my (%data, $file, $row, $sth, $newstore);
   tie %data, 'Tie::CPHash';
   
   $self->_duplicateFile($newAsset,"image1");
   $self->_duplicateFile($newAsset,"image2");
   $self->_duplicateFile($newAsset,"image3");
   $self->_duplicateFile($newAsset,"manual");
   $self->_duplicateFile($newAsset,"brochure");
   $self->_duplicateFile($newAsset,"warranty");
  
   $sth = $self->session->db->read("select * from Product_feature where assetId=".$self->session->db->quote($self->getId));
   while ($row = $sth->hashRef) {
      $row->{"Product_featureId"} = "new";
	  $row->{"assetId"} = $newAsset->getId; 
	  $newAsset->setCollateral("Product_feature","Product_featureId",$row);
   }
   $sth->finish;
   
   $sth = $self->session->db->read("select * from Product_benefit where assetId=".$self->session->db->quote($self->getId));
   while ($row = $sth->hashRef) {
      $row->{"Product_benefitId"} = "new";
	  $row->{"assetId"} = $newAsset->getId; 
      $newAsset->setCollateral("Product_benefit","Product_benefitId",$row);
   }
   $sth->finish;
   
   $sth = $self->session->db->read("select * from Product_specification where assetId=".$self->session->db->quote($self->getId));
   while ($row = $sth->hashRef) {
      $row->{"Product_specificationId"} = "new";
	  $row->{"assetId"} = $newAsset->getId; 
      $newAsset->setCollateral("Product_specification","Product_specificationId",$row);
   }
   $sth->finish;
   
   $sth = $self->session->db->read("select * from Product_accessory where assetId=".$self->session->db->quote($self->getId));
   while (%data = $sth->hash) {
      $self->session->db->write("insert into Product_accessory (assetId,accessoryAssetId,sequenceNumber) values (".$self->session->db->quote($newAsset->getId).", ".$self->session->db->quote($data{accessoryAssetId}).", $data{sequenceNumber})");
   }
   $sth->finish;

   $sth = $self->session->db->read("select * from Product_related where assetId=".$self->session->db->quote($self->getId));
   while (%data = $sth->hash) {
      $self->session->db->write("insert into Product_related (assetId,relatedAssetId,sequenceNumber) values (".$self->session->db->quote($newAsset->getId).", ".$self->session->db->quote($data{relatedAssetId}).", $data{sequenceNumber})");
   }
   $sth->finish;
   return $newAsset;
}

#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my ($file);
	my $tabform = $self->SUPER::getEditForm();
	$tabform->getTab("display")->template(
      		-value=>$self->getValue('templateId'),
      		-namespace=>"Product",
		-label=>WebGUI::International::get(62,"Asset_Product"),
		-hoverHelp=>WebGUI::International::get('62 description',"Asset_Product"),
   		);
	$tabform->getTab("properties")->text(
		-name=>"price",
		-label=>WebGUI::International::get(10,"Asset_Product"),
		-hoverHelp=>WebGUI::International::get('10 description',"Asset_Product"),
		-value=>$self->getValue("price")
		);
    $tabform->getTab("properties")->text(
		-name=>"productNumber",
		-label=>WebGUI::International::get(11,"Asset_Product"),
		-hoverHelp=>WebGUI::International::get('11 description',"Asset_Product"),
		-value=>$self->getValue("productNumber")
		);
    $self->_addFileTab($tabform,"image1",7);
	$self->_addFileTab($tabform,"image2",8);
	$self->_addFileTab($tabform,"image3",9);
	$self->_addFileTab($tabform,"brochure",13);
	$self->_addFileTab($tabform,"manual",14);
	$self->_addFileTab($tabform,"warranty",15);
	return $tabform;
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
sub getThumbnailFilename {
   my $self = shift;
   my $filestore = $_[0];
   my $files = $filestore->getFiles();
   foreach my $file (@{$files}){
      if($file =~ m/^thumb-/){
	     return $file;
	  }
   }
   return "";
}

#-------------------------------------------------------------------
sub getThumbnailUrl {
	my $self = shift;
	my $store = $_[0];
    return $store->getUrl($self->getThumbnailFilename($store));
}

#-------------------------------------------------------------------
sub purge {
   	my $self = shift;
   	my $sth = $self->session->db->read("select image1, image2, image3, brochure, manual, warranty from Product where assetId=".$self->session->db->quote($self->getId));
	while (my @array = $sth->array) {
   		foreach my $id (@array){
      			next if ($id eq "");
	  		WebGUI::Storage->get($id)->delete; 
   		}
	}
	$sth->finish;
   	$self->session->db->write("delete from Product_accessory where assetId=".$self->session->db->quote($self->getId)." or accessoryAssetId=".$self->session->db->quote($self->getId));
   	$self->session->db->write("delete from Product_related where assetId=".$self->session->db->quote($self->getId)." or relatedAssetId=".$self->session->db->quote($self->getId));
   	$self->session->db->write("delete from Product_benefit where assetId=".$self->session->db->quote($self->getId));
   	$self->session->db->write("delete from Product_feature where assetId=".$self->session->db->quote($self->getId));
   	$self->session->db->write("delete from Product_specification where assetId=".$self->session->db->quote($self->getId));
   	$self->SUPER::purge();
}

#-------------------------------------------------------------------

sub	purgeRevision	{
	my $self = shift;
	WebGUI::Storage->get($self->get("image1"))->delete if	($self->get("image1"));
	WebGUI::Storage->get($self->get("image2"))->delete if	($self->get("image2"));
	WebGUI::Storage->get($self->get("image3"))->delete if	($self->get("image3"));
	WebGUI::Storage->get($self->get("brochure"))->delete if	($self->get("brochure"));
	WebGUI::Storage->get($self->get("manual"))->delete if	($self->get("manual"));
	WebGUI::Storage->get($self->get("warranty"))->delete if	($self->get("warranty"));
	return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------
sub www_addAccessory {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   my ($f, $accessory, @usedAccessories);
   $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
   $f->hidden(
		-name => "func",
		-value => "addAccessorySave",
   );
   @usedAccessories = $self->session->db->buildArray("select accessoryAssetId from Product_accessory where assetId=".$self->session->db->quote($self->getId));
   push(@usedAccessories,$self->getId);
   $accessory = $self->session->db->buildHashRef("select asset.assetId, assetData.title from asset left join assetData on assetData.assetId=asset.assetId where asset.className='WebGUI::Asset::Wobject::Product' and asset.assetId not in (".$self->session->db->quoteAndJoin(\@usedAccessories).") and (assetData.status='approved' or assetData.tagId=".$self->session->db->quote($self->session->scratch->get("versionTag")).") group by assetData.assetId");
   $f->selectBox(
		-name => "accessoryAccessId",
		-options => $accessory,
		-label => WebGUI::International::get(17,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('17 description','Asset_Product'),
   );
   $f->yesNo(
		-name => "proceed",
		-label => WebGUI::International::get(18,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('18 description','Asset_Product'),
   );
   $f->submit;
   return $self->getAdminConsole->render($f->print, "product accessory add/edit");
}

#-------------------------------------------------------------------
sub www_addAccessorySave {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   return "" unless ($self->session->form->process("accessoryAccessId"));
   my ($seq) = $self->session->db->quickArray("select max(sequenceNumber) from Product_accessory where assetId=".$self->session->db->quote($self->getId()));
   $self->session->db->write("insert into Product_accessory (assetId,accessoryAssetId,sequenceNumber) values (".$self->session->db->quote($self->getId()).",".$self->session->db->quote($self->session->form->process("accessoryAccessId")).",".($seq+1).")");
   return "" unless($self->session->form->process("proceed"));
   return $self->www_addAccessory();
}

#-------------------------------------------------------------------
sub www_addRelated {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   my ($f, $related, @usedRelated);
   $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
   $f->hidden(
		-name => "func",
		-value => "addRelatedSave",
   );
   @usedRelated = $self->session->db->buildArray("select relatedAssetId from Product_related where assetId=".$self->session->db->quote($self->getId));
   push(@usedRelated,$self->getId);
   $related = $self->session->db->buildHashRef("select assetId,title from asset where className='WebGUI::Asset::Wobject::Product' and assetId not in (".$self->session->db->quoteAndJoin(\@usedRelated).")");
   $f->selectBox(
		-name => "relatedAssetId",
		-options => $related,
		-label => WebGUI::International::get(20,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('20 description','Asset_Product'),
   );
   $f->yesNo(
		-name => "proceed",
		-label => WebGUI::International::get(21,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('21 description','Asset_Product'),
   );
   $f->submit;
   return $self->getAdminConsole->render($f->print,"product related add/edit");
}

#-------------------------------------------------------------------
sub www_addRelatedSave {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   return "" unless ($self->session->form->process("relatedAssetId"));
   my ($seq) = $self->session->db->quickArray("select max(sequenceNumber) from Product_related where assetId=".$self->session->db->quote($self->getId));
   $self->session->db->write("insert into Product_related (assetId,relatedAssetId,sequenceNumber) values (".$self->session->db->quote($self->getId).",".$self->session->db->quote($self->session->form->process("relatedAssetId")).",".($seq+1).")");
   return "" unless($self->session->form->process("proceed"));
   return $self->www_addRelated();
}

#-------------------------------------------------------------------
sub www_deleteAccessoryConfirm {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->session->db->write("delete from Product_accessory where assetId=".$self->session->db->quote($self->getId())." and accessoryAssetId=".$self->session->db->quote($self->session->form->process("aid")));
   $self->reorderCollateral("Product_accessory","accessoryAssetId");
   return "";
}

#-------------------------------------------------------------------
sub www_deleteBenefitConfirm {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->deleteCollateral("Product_benefit","Product_benefitId",$self->session->form->process("bid"));
   $self->reorderCollateral("Product_benefit","Product_benefitId");
   return "";
}

#-------------------------------------------------------------------
sub www_deleteFeatureConfirm {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->deleteCollateral("Product_feature","Product_featureId",$self->session->form->process("fid"));
   $self->reorderCollateral("Product_feature","Product_featureId");
   return "";
}

#-------------------------------------------------------------------
sub www_deleteFileConfirm {
   my $self = shift;
   my $column = $self->session->form->process("file");
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   my $store = $self->get($column);
   my $file = WebGUI::Storage->get($store);
   $file->delete;
	$self->update({$column => ''});
   return $self->www_edit;
}

#-------------------------------------------------------------------
sub www_deleteRelatedConfirm {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->session->db->write("delete from Product_related where assetId=".$self->session->db->quote($self->getId)." and relatedAssetId=".$self->session->db->quote($self->session->form->process("rid")));
   $self->reorderCollateral("Product_related","relatedAssetId");
   return "";
}

#-------------------------------------------------------------------
sub www_deleteSpecificationConfirm {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->deleteCollateral("Product_specification","Product_specificationId",$self->session->form->process("sid"));
   $self->reorderCollateral("Product_specification","Product_specificationId");
   return "";
}

#-------------------------------------------------------------------
#sub www_edit {
#   my $self = shift;
#   return $self->session->privilege->insufficient() unless $self->canEdit;
#   $self->getAdminConsole->setHelp("product add/edit","Asset_Product");
#   return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("6","Asset_Product"));
#}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	$self->_save("image1");
	$self->_save("image2");
	$self->_save("image3");
	$self->_save("brochure");
	$self->_save("manual");
	$self->_save("warranty");
	return "";
}

#-------------------------------------------------------------------
sub www_editBenefit {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   my ($data, $f, $benefits);
   $data = $self->getCollateral("Product_benefit","Product_benefitId",$self->session->form->process("bid"));
   $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
   $f->hidden(
		-name => "bid",
		-value => $data->{Product_benefitId},
   );
   $f->hidden(
		-name => "func",
		-value => "editBenefitSave",
   );
   $benefits = $self->session->db->buildHashRef("select benefit,benefit from Product_benefit order by benefit");
   $f->combo(
		-name => "benefit",
		-options => $benefits,
		-label => WebGUI::International::get(51,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('51 description','Asset_Product'),
		-value => [$data->{benefits}],
   );
   $f->yesNo(
		-name => "proceed",
		-label => WebGUI::International::get(52,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('52 description','Asset_Product'),
   );
   $f->submit;
   return $self->getAdminConsole->render($f->print, "product benefit add/edit");
}

#-------------------------------------------------------------------
sub www_editBenefitSave {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->session->form->process("benefit") = $self->session->form->process("benefit_new") if ($self->session->form->process("benefit_new") ne "");
   $self->setCollateral("Product_benefit", "Product_benefitId", {
		                                          Product_benefitId => $self->session->form->process("bid"),
		                                          benefit => $self->session->form->process("benefit")
		                                        });
   
   return "" unless($self->session->form->process("proceed"));
   $self->session->form->process("bid") = "new";
   return $self->www_editBenefit();
}

#-------------------------------------------------------------------
sub www_editFeature {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   my ($data, $f, $features);
   $data = $self->getCollateral("Product_feature","Product_featureId",$self->session->form->process("fid"));
   $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
   $f->hidden(
		-name => "fid",
		-value => $data->{Product_featureId},
   );
   $f->hidden(
		-name => "func",
		-value => "editFeatureSave",
   );
   $features = $self->session->db->buildHashRef("select feature,feature from Product_feature order by feature");
   $f->combo(
		-name => "feature",
		-options => $features,
		-label => WebGUI::International::get(23,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('23 description','Asset_Product'),
		-value => [$data->{feature}],
   );
   $f->yesNo(
		-name => "proceed",
		-label => WebGUI::International::get(24,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('24 description','Asset_Product'),
   );
   $f->submit;
   return $self->getAdminConsole->render($f->print, "product feature add/edit");
}

#-------------------------------------------------------------------
sub www_editFeatureSave {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->session->form->process("feature") = $self->session->form->process("feature_new") if ($self->session->form->process("feature_new") ne "");
   $self->setCollateral("Product_feature", "Product_featureId", {
                                              Product_featureId => $self->session->form->process("fid"),
                                              feature => $self->session->form->process("feature")
                                             });
   return "" unless($self->session->form->process("proceed"));
   $self->session->form->process("fid") = "new";
   return $self->www_editFeature();
}

#-------------------------------------------------------------------
sub www_editSpecification {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   my ($data, $f, $hashRef);
   $data = $self->getCollateral("Product_specification","Product_specificationId",$self->session->form->process("sid"));
   $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
   $f->hidden(
		-name => "sid",
		-value => $data->{Product_specificationId},
   );
   $f->hidden(
		-name => "func",
		-value => "editSpecificationSave",
   );
   $hashRef = $self->session->db->buildHashRef("select name,name from Product_specification order by name");
   $f->combo(
		-name => "name",
		-options => $hashRef,
		-label => WebGUI::International::get(26,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('26 description','Asset_Product'),
		-value => [$data->{name}],
   );
   $f->text(
		-name => "value",
		-label => WebGUI::International::get(27,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('27 description','Asset_Product'),
		-value => $data->{value},
   );
   $hashRef = $self->session->db->buildHashRef("select units,units from Product_specification order by units");
   $f->combo(
		-name => "units",
		-options => $hashRef,
		-label => WebGUI::International::get(29,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('29 description','Asset_Product'),
		-value => [$data->{units}],
   );
   $f->yesNo(
		-name => "proceed",
		-label => WebGUI::International::get(28,'Asset_Product'),
		-hoverHelp => WebGUI::International::get('28 description','Asset_Product'),
   );
   $f->submit;
   return $self->getAdminConsole->render($f->print, "product specification add/edit");
}

#-------------------------------------------------------------------
sub www_editSpecificationSave {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit);
	$self->session->form->process("name") = $self->session->form->process("name_new") if ($self->session->form->process("name_new") ne "");
	$self->session->form->process("units") = $self->session->form->process("units_new") if ($self->session->form->process("units_new") ne "");
	$self->setCollateral("Product_specification", "Product_specificationId", {
		Product_specificationId => $self->session->form->process("sid"),
		name => $self->session->form->process("name"),
		value => $self->session->form->process("value"),
		units => $self->session->form->process("units")
	});

	return "" unless($self->session->form->process("proceed"));
	$self->session->form->process("sid") = "new";
	return $self->www_editSpecification();
}

#-------------------------------------------------------------------
sub www_moveAccessoryDown {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->moveCollateralDown("Product_accessory","accessoryAssetId",$self->session->form->process("aid"));
   return "";
}

#-------------------------------------------------------------------
sub www_moveAccessoryUp {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->moveCollateralUp("Product_accessory","accessoryAssetId",$self->session->form->process("aid"));
   return "";
}

#-------------------------------------------------------------------
sub www_moveBenefitDown {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->moveCollateralDown("Product_benefit","Product_benefitId",$self->session->form->process("bid"));
   return "";
}

#-------------------------------------------------------------------
sub www_moveBenefitUp {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->moveCollateralUp("Product_benefit","Product_benefitId",$self->session->form->process("bid"));
   return "";
}

#-------------------------------------------------------------------
sub www_moveFeatureDown {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->moveCollateralDown("Product_feature","Product_featureId",$self->session->form->process("fid"));
   return "";
}

#-------------------------------------------------------------------
sub www_moveFeatureUp {
	my $self = shift;
	return $self->session->privilege->insufficient() unless ($self->canEdit);
	$self->moveCollateralUp("Product_feature","Product_featureId",$self->session->form->process("fid"));
	return "";
}

#-------------------------------------------------------------------
sub www_moveRelatedDown {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->moveCollateralDown("Product_related","relatedAssetId",$self->session->form->process("rid"));
   return "";
}

#-------------------------------------------------------------------
sub www_moveRelatedUp {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->moveCollateralUp("Product_related","relatedAssetId",$self->session->form->process("rid"));
   return "";
}

#-------------------------------------------------------------------
sub www_moveSpecificationDown {
   my $self = shift;
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->moveCollateralDown("Product_specification","Product_specificationId",$self->session->form->process("sid"));
   return "";
}

#-------------------------------------------------------------------
sub www_moveSpecificationUp {
   my $self = shift;   
   return $self->session->privilege->insufficient() unless ($self->canEdit);
   $self->moveCollateralUp("Product_specification","Product_specificationId",$self->session->form->process("sid"));
   return "";
}

#-------------------------------------------------------------------
sub view {
   my $self = shift;
   $self->logView() if ($self->session->setting->get("passiveProfilingEnabled"));
   my (%data, $sth, $file, $segment, %var, @featureloop, @benefitloop, @specificationloop, @accessoryloop, @relatedloop);
   tie %data, 'Tie::CPHash';
	my $brochure = $self->get("brochure");
	my $manual = $self->get("manual");
	my $warranty = $self->get("warranty");
	my $image1 = $self->get("image1");
	my $image2 = $self->get("image2");
	my $image3 = $self->get("image3");
   #---brochure
   if ($brochure) {
      $file = WebGUI::Storage->get($brochure);
      $var{"brochure.icon"} = $self->getFileIconUrl($file);
	  $var{"brochure.label"} = WebGUI::International::get(13,"Asset_Product");
	  $var{"brochure.URL"} = $self->getFileUrl($file);
   }
	#---manual
   if ($manual) {
      $file = WebGUI::Storage->get($manual);
	  $var{"manual.icon"} = $self->getFileIconUrl($file);
	  $var{"manual.label"} = WebGUI::International::get(14,"Asset_Product");
      $var{"manual.URL"} = $self->getFileUrl($file);
   }
   #---warranty
   if ($warranty) {
      $file = WebGUI::Storage->get($warranty);
      $var{"warranty.icon"} = $self->getFileIconUrl($file);
	  $var{"warranty.label"} = WebGUI::International::get(15,"Asset_Product");
	  $var{"warranty.URL"} = $self->getFileUrl($file);
   }
   #---image1
   if ($image1) {
      $file = WebGUI::Storage->get($image1);
      $var{thumbnail1} = $self->getThumbnailUrl($file);
	  $var{image1} = $self->getFileUrl($file);
   }
   #---image2
   if ($image2) {
      $file = WebGUI::Storage->get($image2);
      $var{thumbnail2} = $self->getThumbnailUrl($file);
      $var{image2} = $self->getFileUrl($file);
   }
   #---image3
   if ($image3) {
      $file = WebGUI::Storage->get($image3);
      $var{thumbnail3} = $self->getThumbnailUrl($file);
      $var{image3} = $self->getFileUrl($file);
   }
   
   #---features 
   $var{"addFeature.url"} = $self->getUrl('func=editFeature&fid=new');
   $var{"addFeature.label"} = WebGUI::International::get(34,'Asset_Product');
   $sth = $self->session->db->read("select feature,Product_featureId from Product_feature where assetId=".$self->session->db->quote($self->getId)." order by sequenceNumber");
   while (%data = $sth->hash) {
      $segment = deleteIcon('func=deleteFeatureConfirm&fid='.$data{Product_featureId},$self->get("url"),WebGUI::International::get(3,'Asset_Product'))
                 .editIcon('func=editFeature&fid='.$data{Product_featureId},$self->get("url"))
                 .moveUpIcon('func=moveFeatureUp&&fid='.$data{Product_featureId},$self->get("url"))
                 .moveDownIcon('func=moveFeatureDown&&fid='.$data{Product_featureId},$self->get("url"));
	  push(@featureloop,{
			              "feature.feature"=>$data{feature},
			              "feature.controls"=>$segment
			             });
   }
   $sth->finish;
   $var{feature_loop} = \@featureloop;

   #---benefits 
   $var{"addBenefit.url"} = $self->getUrl('func=editBenefit&fid=new');
   $var{"addBenefit.label"} = WebGUI::International::get(55,'Asset_Product');
   $sth = $self->session->db->read("select benefit,Product_benefitId from Product_benefit where assetId=".$self->session->db->quote($self->getId)." order by sequenceNumber");
   while (%data = $sth->hash) {
      $segment = deleteIcon('func=deleteBenefitConfirm&bid='.$data{Product_benefitId},$self->get("url"),WebGUI::International::get(48,'Asset_Product'))
                 .editIcon('func=editBenefit&bid='.$data{Product_benefitId},$self->get("url"))
                 .moveUpIcon('func=moveBenefitUp&bid='.$data{Product_benefitId},$self->get("url"))
                 .moveDownIcon('func=moveBenefitDown&bid='.$data{Product_benefitId},$self->get("url"));
	  push(@benefitloop,{
			              "benefit.benefit"=>$data{benefit},
			              "benefit.controls"=>$segment
			             });
   }
   $sth->finish;
   $var{benefit_loop} = \@benefitloop;

   #---specifications 
   $var{"addSpecification.url"} = $self->getUrl('func=editSpecification&sid=new');
   $var{"addSpecification.label"} = WebGUI::International::get(35,'Asset_Product');
   $sth = $self->session->db->read("select name,value,units,Product_specificationId from Product_specification where assetId=".$self->session->db->quote($self->getId)." order by sequenceNumber");
   while (%data = $sth->hash) {
      $segment = deleteIcon('func=deleteSpecificationConfirm&sid='.$data{Product_specificationId},$self->get("url"),WebGUI::International::get(5,'Asset_Product'))
                 .editIcon('func=editSpecification&sid='.$data{Product_specificationId},$self->get("url"))
                 .moveUpIcon('func=moveSpecificationUp&sid='.$data{Product_specificationId},$self->get("url"))
                 .moveDownIcon('func=moveSpecificationDown&sid='.$data{Product_specificationId},$self->get("url"));
      push(@specificationloop,{
			                      "specification.controls"=>$segment,
			                      "specification.specification"=>$data{value},
			                      "specification.units"=>$data{units},
			                      "specification.label"=>$data{name}
		                       });
   }
   $sth->finish;
   $var{specification_loop} = \@specificationloop;

	#---accessories 
   $var{"addaccessory.url"} = $self->getUrl('func=addAccessory');
   $var{"addaccessory.label"} = WebGUI::International::get(36,'Asset_Product');
   $sth = $self->session->db->read("select Product_accessory.accessoryAssetId from   Product_accessory
		                     where Product_accessory.assetId=".$self->session->db->quote($self->getId)." 
		                     order by Product_accessory.sequenceNumber");
   while (my ($id) = $sth->array) {
      $segment = deleteIcon('func=deleteAccessoryConfirm&aid='.$id,$self->get("url"),WebGUI::International::get(2,'Asset_Product'))
                 .moveUpIcon('func=moveAccessoryUp&aid='.$id,$self->get("url"))
                 .moveDownIcon('func=moveAccessoryDown&aid='.$id,$self->get("url"));
		my $accessory = WebGUI::Asset->newByDynamicClass($id);
	  push(@accessoryloop,{
			               "accessory.URL"=>$accessory->getUrl,
			               "accessory.title"=>$accessory->getTitle,
			               "accessory.controls"=>$segment
			               });
   }
   $sth->finish;
   $var{accessory_loop} = \@accessoryloop;

   #---related
   $var{"addrelatedproduct.url"} = $self->getUrl('func=addRelated');
   $var{"addrelatedproduct.label"} = WebGUI::International::get(37,'Asset_Product');
   $sth = $self->session->db->read("select Product_related.relatedAssetId 
		                     from Product_related 
		                     where Product_related.assetId=".$self->session->db->quote($self->getId)." 
		                     order by Product_related.sequenceNumber");
   while (my ($id) = $sth->array) {
      $segment = deleteIcon('func=deleteRelatedConfirm&rid='.$id,$self->get("url"),WebGUI::International::get(4,'Asset_Product'))
                 .moveUpIcon('func=moveRelatedUp&rid='.$id,$self->get("url"))
                 .moveDownIcon('func=moveRelatedDown&rid='.$id,$self->get("url"));
		my $related = WebGUI::Asset->newByDynamicClass($id);
      push(@relatedloop,{
			              "relatedproduct.URL"=>$related->getUrl,
			              "relatedproduct.title"=>$related->getTitle,
                          "relatedproduct.controls"=>$segment
			            });
   }
   $sth->finish;
   $var{relatedproduct_loop} = \@relatedloop;
   return $self->processTemplate(\%var, $self->get("templateId"));
}

1;

