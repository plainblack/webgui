package WebGUI::Wobject::Product;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Attachment;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);

#-------------------------------------------------------------------
sub duplicate {
        my ($w, %data, $file, $row, $sth);
	tie %data, 'Tie::CPHash';
        $w = $_[0]->SUPER::duplicate($_[1]);
	$w = WebGUI::Wobject::Product->new({wobjectId=>$w,namespace=>$_[0]->get("namespace")});
	$file = WebGUI::Attachment->new($_[0]->get("image1"),$_[0]->get("wobjectId"));
        $file->copy($w->get("wobjectId"));
        $file = WebGUI::Attachment->new($_[0]->get("image2"),$_[0]->get("wobjectId"));
        $file->copy($w->get("wobjectId"));
        $file = WebGUI::Attachment->new($_[0]->get("image3"),$_[0]->get("wobjectId"));
        $file->copy($w->get("wobjectId"));
        $file = WebGUI::Attachment->new($_[0]->get("manual"),$_[0]->get("wobjectId"));
        $file->copy($w->get("wobjectId"));
        $file = WebGUI::Attachment->new($_[0]->get("brochure"),$_[0]->get("wobjectId"));
        $file->copy($w->get("wobjectId"));
        $file = WebGUI::Attachment->new($_[0]->get("warranty"),$_[0]->get("wobjectId"));
        $file->copy($w->get("wobjectId"));
        $sth = WebGUI::SQL->read("select * from Product_feature where wobjectId=".$_[0]->get("wobjectId"));
        while ($row = $sth->hashRef) {
		$row->{"Product_featureId"} = "new";
		$w->setCollateral("Product_feature","Product_featureId",$row);
        }
        $sth->finish;
        $sth = WebGUI::SQL->read("select * from Product_benefit where wobjectId=".$_[0]->get("wobjectId"));
        while ($row = $sth->hashRef) {
		$row->{"Product_benefitId"} = "new";
                $w->setCollateral("Product_benefit","Product_benefitId",$row);
        }
        $sth->finish;
        $sth = WebGUI::SQL->read("select * from Product_specification where wobjectId=".$_[0]->get("wobjectId"));
        while ($row = $sth->hashRef) {
		$row->{"Product_specificationId"} = "new";
                $w->setCollateral("Product_specification","Product_specificationId",$row);
        }
        $sth->finish;
        $sth = WebGUI::SQL->read("select * from Product_accessory where wobjectId=".$_[0]->get("wobjectId"));
        while (%data = $sth->hash) {
                WebGUI::SQL->write("insert into Product_accessory values (".$w->get("wobjectId").", 
			$data{accessoryWobjectId}, $data{sequenceNumber})");
        }
        $sth->finish;
        $sth = WebGUI::SQL->read("select * from Product_related where wobjectId=".$_[0]->get("wobjectId"));
        while (%data = $sth->hash) {
                WebGUI::SQL->write("insert into Product_related values (".$w->get("wobjectId").", 
			$data{relatedWobjectId}, $data{sequenceNumber})");
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub getIndexerParams {
	my $self = shift;        
	my $now = shift;
	return {
		Product => {
                        sql => "select Product.wobjectId as wid,
                                        Product.image1 as image1,
                                        Product.image2 as image2,
                                        Product.image3 as image3,
                                        Product.brochure as brochure,
                                        Product.manual as manual,
                                        Product.warranty as warranty,
                                        Product.price as price,
                                        Product.productNumber as productNumber,
                                        Product_benefit.benefit as benefit,
                                        Product_feature.feature as feature,
                                        Product_specification.name as name,
                                        Product_specification.value as value,
                                        Product_specification.units as units,
                                        wobject.namespace as namespace,
                                        wobject.addedBy as ownerId,
                                        page.urlizedTitle as urlizedTitle,
                                        page.languageId as languageId,
                                        page.pageId as pageId,
                                        page.groupIdView as page_groupIdView,
                                        wobject.groupIdView as wobject_groupIdView,
                                        7 as wobject_special_groupIdView
                                        from Product, wobject, page
                                        left join Product_benefit on Product_benefit.wobjectId=Product.wobjectId
                                        left join Product_feature on Product_feature.wobjectId=Product.wobjectId
                                        left join Product_specification on Product_specification.wobjectId=Product.wobjectId
                                        where Product.wobjectId = wobject.wobjectId
                                        and wobject.pageId = page.pageId
                                        and wobject.startDate < $now 
                                        and wobject.endDate > $now
                                        and page.startDate < $now
                                        and page.endDate > $now",
                        fieldsToIndex => ["image1", "image2", "image3", "brochure", "manual", "warranty", "price", 
                                          "productNumber", "benefit", "feature", "name", "value", "units"],
                        contentType => 'wobjectDetail',
                        url => 'WebGUI::URL::append($data{urlizedTitle}, "func=view&wid=$data{wid}")',
                        headerShortcut => 'select title from wobject where wobjectId = $data{wid}',
                        bodyShortcut => 'select description from wobject where wobjectId = $data{wid}',
                }
	};
}

#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(1,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
			price=>{}, 
			productNumber=>{}, 
			image1=>{}, 
			image2=>{}, 
			image3=>{}, 
			manual=>{}, 
			brochure=>{}, 
			warranty=>{}
			},
		-useTemplate=>1
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from Product_accessory where wobjectId=".$_[0]->get("wobjectId")." 
		or accessoryWobjectId=".$_[0]->get("wobjectId"));
        WebGUI::SQL->write("delete from Product_related where wobjectId=".$_[0]->get("wobjectId")."
		or relatedWobjectId=".$_[0]->get("wobjectId"));
        WebGUI::SQL->write("delete from Product_benefit where wobjectId=".$_[0]->get("wobjectId"));
        WebGUI::SQL->write("delete from Product_feature where wobjectId=".$_[0]->get("wobjectId"));
        WebGUI::SQL->write("delete from Product_specification where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}


#-------------------------------------------------------------------
sub www_addAccessory {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $session{page}{useAdminStyle} = 1;
        my ($output, $f, $accessory, @usedAccessories);
	$output = helpIcon(4,$_[0]->get("namespace"));
        $output .= '<h1>'.WebGUI::International::get(16,$_[0]->get("namespace")).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("func","addAccessorySave");
        @usedAccessories = WebGUI::SQL->quickArray("select accessoryWobjectId from Product_accessory
                where wobjectId=".$session{form}{wid});
        push(@usedAccessories,$session{form}{wid});
        $accessory = WebGUI::SQL->buildHashRef("select wobjectId,title from wobject where namespace='Product'
                and wobjectId not in (".join(",",@usedAccessories).")");
        $f->select("accessoryWobjectId",$accessory,WebGUI::International::get(17,$_[0]->get("namespace")));
        $f->yesNo("proceed",WebGUI::International::get(18,$_[0]->get("namespace")));
        $f->submit;
        $output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_addAccessorySave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $session{page}{useAdminStyle} = 1;
        my ($seq);
        ($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from Product_accessory
                where wobjectId=".$_[0]->get("wobjectId"));
        WebGUI::SQL->write("insert into Product_accessory (wobjectId,accessoryWobjectId,sequenceNumber) values
                (".$_[0]->get("wobjectId").",$session{form}{accessoryWobjectId},".($seq+1).")");
        if ($session{form}{proceed}) {
                return $_[0]->www_addAccessory();
        } else {
                return "";
        }
}

#-------------------------------------------------------------------
sub www_addRelated {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        my ($output, $f, $related, @usedRelated);
	$output = helpIcon(5,$_[0]->get("namespace"));
        $output .= '<h1>'.WebGUI::International::get(19,$_[0]->get("namespace")).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("func","addRelatedSave");
        @usedRelated = WebGUI::SQL->quickArray("select relatedWobjectId from Product_related
                where wobjectId=".$session{form}{wid});
        push(@usedRelated,$session{form}{wid});
        $related = WebGUI::SQL->buildHashRef("select wobjectId,title from wobject where namespace='Product'
                and wobjectId not in (".join(",",@usedRelated).")");
        $f->select("relatedWobjectId",$related,WebGUI::International::get(20,$_[0]->get("namespace")));
        $f->yesNo("proceed",WebGUI::International::get(21,$_[0]->get("namespace")));
        $f->submit;
        $output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_addRelatedSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        my ($seq);
        ($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from Product_related
     		where wobjectId=".$_[0]->get("wobjectId"));
        WebGUI::SQL->write("insert into Product_related (wobjectId,relatedWobjectId,sequenceNumber) values
                (".$_[0]->get("wobjectId").",$session{form}{relatedWobjectId},".($seq+1).")");
        if ($session{form}{proceed}) {
                return $_[0]->www_addRelated();
        } else {
                return "";
        }
}

#-------------------------------------------------------------------
sub www_deleteAccessory {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        return $_[0]->confirm(
                WebGUI::International::get(2,$_[0]->get("namespace")),
		WebGUI::URL::page('func=deleteAccessoryConfirm&wid='.$_[0]->get("wobjectId").'&aid='.$session{form}{aid})
                );
}

#-------------------------------------------------------------------
sub www_deleteAccessoryConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	WebGUI::SQL->write("delete from Product_accessory where wobjectId=$session{form}{wid} and accessoryWobjectId=$session{form}{aid}");
	$_[0]->reorderCollateral("Product_accessory","accessoryWobjectId");
        return "";
}

#-------------------------------------------------------------------
sub www_deleteBenefit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        return $_[0]->confirm(
                WebGUI::International::get(48,$_[0]->get("namespace")),
		WebGUI::URL::page('func=deleteBenefitConfirm&wid='.$_[0]->get("wobjectId").'&bid='.$session{form}{bid})
                );
}

#-------------------------------------------------------------------
sub www_deleteBenefitConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->deleteCollateral("Product_benefit","Product_benefitId",$session{form}{bid});
	$_[0]->reorderCollateral("Product_benefit","Product_benefitId");
        return "";
}

#-------------------------------------------------------------------
sub www_deleteFeature {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	return $_[0]->confirm(
		WebGUI::International::get(3,$_[0]->get("namespace")),
		WebGUI::URL::page('func=deleteFeatureConfirm&wid='.$_[0]->get("wobjectId").'&fid='.$session{form}{fid})
		);
}

#-------------------------------------------------------------------
sub www_deleteFeatureConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->deleteCollateral("Product_feature","Product_featureId",$session{form}{fid});
	$_[0]->reorderCollateral("Product_feature","Product_featureId");
        return "";
}

#-------------------------------------------------------------------
sub www_deleteRelated {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        return $_[0]->confirm(
                WebGUI::International::get(4,$_[0]->get("namespace")),
		WebGUI::URL::page('func=deleteRelatedConfirm&wid='.$_[0]->get("wobjectId").'&rid='.$session{form}{rid})
                );
}

#-------------------------------------------------------------------
sub www_deleteRelatedConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        WebGUI::SQL->write("delete from Product_related where wobjectId=$session{form}{wid} and relatedWobjectId=$session{form}{rid}");
	$_[0]->reorderCollateral("Product_related","relatedWobjectId");
        return "";
}

#-------------------------------------------------------------------
sub www_deleteSpecification {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        return $_[0]->confirm(
                WebGUI::International::get(5,$_[0]->get("namespace")),
		WebGUI::URL::page('func=deleteSpecificationConfirm&wid='.$_[0]->get("wobjectId").'&sid='.$session{form}{sid})
                );
}

#-------------------------------------------------------------------
sub www_deleteSpecificationConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->deleteCollateral("Product_specification","Product_specificationId",$session{form}{sid});
	$_[0]->reorderCollateral("Product_specification","Product_specificationId");
        return "";
}

#-------------------------------------------------------------------
sub www_edit {
	my $properties = WebGUI::HTMLForm->new;
	$properties->text(
		-name=>"price",
		-label=>WebGUI::International::get(10,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("price")
		);
	$properties->text(
		-name=>"productNumber",
		-label=>WebGUI::International::get(11,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("productNumber")
		);
	$properties->raw($_[0]->fileProperty("image1",7));
	$properties->raw($_[0]->fileProperty("image2",8));
	$properties->raw($_[0]->fileProperty("image3",9));
	$properties->raw($_[0]->fileProperty("brochure",13));
	$properties->raw($_[0]->fileProperty("manual",14));
	$properties->raw($_[0]->fileProperty("warranty",15));
	return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-helpId=>1,
		-headingId=>6
		);
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	my ($file, %property);
	$_[0]->SUPER::www_editSave() if ($_[0]->get("wobjectId") eq "new");
	$file = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
        $file->save("image1");
	$property{image1}=$file->getFilename("image1") if ($file->getFilename("image1") ne "");
        $file = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
        $file->save("image2");
        $property{image2}=$file->getFilename("image2") if ($file->getFilename("image2") ne "");
        $file = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
        $file->save("image3");
        $property{image3}=$file->getFilename("image3") if ($file->getFilename("image3") ne "");
        $file = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
        $file->save("manual");
        $property{manual}=$file->getFilename("manual") if ($file->getFilename("manual") ne "");
        $file = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
        $file->save("brochure");
        $property{brochure}=$file->getFilename("brochure") if ($file->getFilename("brochure") ne "");
        $file = WebGUI::Attachment->new("",$_[0]->get("wobjectId"));
        $file->save("warranty");
        $property{warranty}=$file->getFilename("warranty") if ($file->getFilename("warranty") ne "");
	$_[0]->SUPER::www_editSave(\%property);
	return "";
}

#-------------------------------------------------------------------
sub www_editBenefit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $session{page}{useAdminStyle} = 1;
        my ($output, $data, $f, $benefits);
	$data = $_[0]->getCollateral("Product_benefit","Product_benefitId",$session{form}{bid});
        $output = helpIcon(6,$_[0]->get("namespace"));
        $output .= '<h1>'.WebGUI::International::get(53,$_[0]->get("namespace")).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("bid",$data->{Product_benefitId});
        $f->hidden("func","editBenefitSave");
        $benefits = WebGUI::SQL->buildHashRef("select benefit,benefit from Product_benefit order by benefit");
        $f->combo("benefit",$benefits,WebGUI::International::get(51,$_[0]->get("namespace")),[$data->{benefits}]);
        $f->yesNo("proceed",WebGUI::International::get(52,$_[0]->get("namespace")));
        $f->submit;
        $output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_editBenefitSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $session{form}{benefit} = $session{form}{benefit_new} if ($session{form}{benefit_new} ne "");
	$_[0]->setCollateral("Product_benefit", "Product_benefitId", {
		Product_benefitId => $session{form}{bid},
		benefit => $session{form}{benefit}
		});
        if ($session{form}{proceed}) {
                $session{form}{bid} = "new";
                return $_[0]->www_editBenefit();
        } else {
                return "";
        }
}

#-------------------------------------------------------------------
sub www_editFeature {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $session{page}{useAdminStyle} = 1;
        my ($output, $data, $f, $features);
	$data = $_[0]->getCollateral("Product_feature","Product_featureId",$session{form}{fid});
	$output = helpIcon(2,$_[0]->get("namespace"));
        $output .= '<h1>'.WebGUI::International::get(22,$_[0]->get("namespace")).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("fid",$data->{Product_featureId});
        $f->hidden("func","editFeatureSave");
	$features = WebGUI::SQL->buildHashRef("select feature,feature from Product_feature order by feature");
        $f->combo("feature",$features,WebGUI::International::get(23,$_[0]->get("namespace")),[$data->{feature}]);
        $f->yesNo("proceed",WebGUI::International::get(24,$_[0]->get("namespace")));
        $f->submit;
        $output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_editFeatureSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$session{form}{feature} = $session{form}{feature_new} if ($session{form}{feature_new} ne "");
        $_[0]->setCollateral("Product_feature", "Product_featureId", {
                Product_featureId => $session{form}{fid},
                feature => $session{form}{feature}
                });
        if ($session{form}{proceed}) {
                $session{form}{fid} = "new";
                return $_[0]->www_editFeature();
        } else {
                return "";
        }
}

#-------------------------------------------------------------------
sub www_editSpecification {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $session{page}{useAdminStyle} = 1;
        my ($output, $data, $f, $hashRef);
	$data = $_[0]->getCollateral("Product_specification","Product_specificationId",$session{form}{sid});
	$output = helpIcon(3,$_[0]->get("namespace"));
        $output .= '<h1>'.WebGUI::International::get(25,$_[0]->get("namespace")).'</h1>';
        $f = WebGUI::HTMLForm->new;
        $f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("sid",$data->{Product_specificationId});
        $f->hidden("func","editSpecificationSave");
        $hashRef = WebGUI::SQL->buildHashRef("select name,name from Product_specification order by name");
        $f->combo("name",$hashRef,WebGUI::International::get(26,$_[0]->get("namespace")),[$data->{name}]);
        $f->text("value",WebGUI::International::get(27,$_[0]->get("namespace")),$data->{value});
        $hashRef = WebGUI::SQL->buildHashRef("select units,units from Product_specification order by units");
        $f->combo("units",$hashRef,WebGUI::International::get(29,$_[0]->get("namespace")),[$data->{units}]);
        $f->yesNo("proceed",WebGUI::International::get(28,$_[0]->get("namespace")));
        $f->submit;
        $output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_editSpecificationSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $session{form}{name} = $session{form}{name_new} if ($session{form}{name_new} ne "");
        $session{form}{units} = $session{form}{units_new} if ($session{form}{units_new} ne "");
        $_[0]->setCollateral("Product_specification", "Product_specificationId", {
                Product_specificationId => $session{form}{sid},
                name => $session{form}{name},
                value => $session{form}{value},
                units => $session{form}{units}
                });
        if ($session{form}{proceed}) {
                $session{form}{sid} = "new";
                return $_[0]->www_editSpecification();
        } else {
                return "";
        }
}

#-------------------------------------------------------------------
sub www_moveAccessoryDown {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralDown("Product_related","accessoryWobjectId",$session{form}{aid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveAccessoryUp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralUp("Product_accessory","accessoryWobjectId",$session{form}{aid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveBenefitDown {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralDown("Product_benefit","Product_benefitId",$session{form}{bid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveBenefitUp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralUp("Product_benefit","Product_benefitId",$session{form}{bid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveFeatureDown {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralDown("Product_feature","Product_featureId",$session{form}{fid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveFeatureUp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	$_[0]->moveCollateralUp("Product_feature","Product_featureId",$session{form}{fid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveRelatedDown {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralDown("Product_related","relatedWobjectId",$session{form}{rid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveRelatedUp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralUp("Product_related","relatedWobjectId",$session{form}{rid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveSpecificationDown {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralDown("Product_specification","Product_specificationId",$session{form}{sid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveSpecificationUp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralUp("Product_specification","Product_specificationId",$session{form}{sid});
	return "";
}

#-------------------------------------------------------------------
sub www_view {
        my (%data, $sth, $file, $segment, %var, @featureloop, @benefitloop, @specificationloop, @accessoryloop, @relatedloop);
        tie %data, 'Tie::CPHash';
	#---brochure
        if ($_[0]->get("brochure")) {
                $file = WebGUI::Attachment->new($_[0]->get("brochure"),$_[0]->get("wobjectId"));
                $var{"brochure.icon"} = $file->getIcon;
		$var{"brochure.label"} = WebGUI::International::get(13,$_[0]->get("namespace"));
		$var{"brochure.URL"} = $file->getURL;
        }
	#---manual
        if ($_[0]->get("manual")) {
                $file = WebGUI::Attachment->new($_[0]->get("manual"),$_[0]->get("wobjectId"));
                $var{"manual.icon"} = $file->getIcon;
		$var{"manual.label"} = WebGUI::International::get(14,$_[0]->get("namespace"));
		$var{"manual.URL"} = $file->getURL;
        }
	#---warranty
        if ($_[0]->get("warranty")) {
                $file = WebGUI::Attachment->new($_[0]->get("warranty"),$_[0]->get("wobjectId"));
                $var{"warranty.icon"} = $file->getIcon;
		$var{"warranty.label"} = WebGUI::International::get(15,$_[0]->get("namespace"));
		$var{"warranty.URL"} = $file->getURL;
        }
	#---image1
        if ($_[0]->get("image1")) {
                $file = WebGUI::Attachment->new($_[0]->get("image1"),$_[0]->get("wobjectId"));
                $var{thumbnail1} = $file->getThumbnail;
		$var{image1} = $file->getURL;
        }
	#---image2
        if ($_[0]->get("image2")) {
                $file = WebGUI::Attachment->new($_[0]->get("image2"),$_[0]->get("wobjectId"));
                $var{thumbnail2} = $file->getThumbnail;
		$var{image2} = $file->getURL;
        }
	#---image3
        if ($_[0]->get("image3")) {
                $file = WebGUI::Attachment->new($_[0]->get("image3"),$_[0]->get("wobjectId"));
                $var{thumbnail3} = $file->getThumbnail;
                $var{image3} = $file->getURL;
        }

	#---features 
        $var{"addFeature.url"} = WebGUI::URL::page('func=editFeature&fid=new&wid='.$_[0]->get("wobjectId"));
	$var{"addFeature.label"} = WebGUI::International::get(34,$_[0]->get("namespace"));
        $sth = WebGUI::SQL->read("select feature,Product_featureId from Product_feature where wobjectId="
		.$_[0]->get("wobjectId")." order by sequenceNumber");
        while (%data = $sth->hash) {
                $segment = deleteIcon('func=deleteFeature&wid='.$_[0]->get("wobjectId").'&fid='.$data{Product_featureId})
                        .editIcon('func=editFeature&wid='.$_[0]->get("wobjectId").'&fid='.$data{Product_featureId})
                        .moveUpIcon('func=moveFeatureUp&wid='.$_[0]->get("wobjectId").'&fid='.$data{Product_featureId})
                        .moveDownIcon('func=moveFeatureDown&wid='.$_[0]->get("wobjectId").'&fid='.$data{Product_featureId});
		push(@featureloop,{
			"feature.feature"=>$data{feature},
			"feature.controls"=>$segment
			});
        }
        $sth->finish;
	$var{feature_loop} = \@featureloop;

	#---benefits 
        $var{"addBenefit.url"} = WebGUI::URL::page('func=editBenefit&fid=new&wid='.$_[0]->get("wobjectId"));
	$var{"addBenefit.label"} = WebGUI::International::get(55,$_[0]->get("namespace"));
        $sth = WebGUI::SQL->read("select benefit,Product_benefitId from Product_benefit where wobjectId="
		.$_[0]->get("wobjectId")." order by sequenceNumber");
        while (%data = $sth->hash) {
                $segment = deleteIcon('func=deleteBenefit&wid='.$_[0]->get("wobjectId").'&bid='.$data{Product_benefitId})
                        .editIcon('func=editBenefit&wid='.$_[0]->get("wobjectId").'&bid='.$data{Product_benefitId})
                        .moveUpIcon('func=moveBenefitUp&wid='.$_[0]->get("wobjectId").'&bid='.$data{Product_benefitId})
                        .moveDownIcon('func=moveBenefitDown&wid='.$_[0]->get("wobjectId").'&bid='.$data{Product_benefitId});
		push(@benefitloop,{
			"benefit.benefit"=>$data{benefit},
			"benefit.controls"=>$segment
			});
        }
        $sth->finish;
	$var{benefit_loop} = \@benefitloop;

	#---specifications 
        $var{"addSpecification.url"} = WebGUI::URL::page('func=editSpecification&sid=new&wid='.$_[0]->get("wobjectId"));
	$var{"addSpecification.label"} = WebGUI::International::get(35,$_[0]->get("namespace"));
        $sth = WebGUI::SQL->read("select name,value,units,Product_specificationId from Product_specification 
		where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
        while (%data = $sth->hash) {
                $segment = deleteIcon('func=deleteSpecification&wid='.$_[0]->get("wobjectId").'&sid='.$data{Product_specificationId})
                        .editIcon('func=editSpecification&wid='.$_[0]->get("wobjectId").'&sid='.$data{Product_specificationId})
                        .moveUpIcon('func=moveSpecificationUp&wid='.$_[0]->get("wobjectId").'&sid='.$data{Product_specificationId})
                        .moveDownIcon('func=moveSpecificationDown&wid='.$_[0]->get("wobjectId").'&sid='.$data{Product_specificationId});
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
        $var{"addaccessory.url"} = WebGUI::URL::page('func=addAccessory&wid='.$_[0]->get("wobjectId"));
	$var{"addaccessory.label"} = WebGUI::International::get(36,$_[0]->get("namespace"));
        $sth = WebGUI::SQL->read("select wobject.title,page.urlizedTitle,Product_accessory.accessoryWobjectId 
		from Product_accessory,wobject,page 
		where Product_accessory.wobjectId=".$_[0]->get("wobjectId")." 
		and Product_accessory.accessoryWobjectId=wobject.wobjectId 
		and wobject.pageId=page.pageId order by Product_accessory.sequenceNumber");
        while (%data = $sth->hash) {
                $segment = deleteIcon('func=deleteAccessory&wid='.$_[0]->get("wobjectId").'&aid='.$data{accessoryWobjectId})
                        .moveUpIcon('func=moveAccessoryUp&wid='.$_[0]->get("wobjectId").'&aid='.$data{accessoryWobjectId})
                        .moveDownIcon('func=moveAccessoryDown&wid='.$_[0]->get("wobjectId").'&aid='.$data{accessoryWobjectId});
		push(@accessoryloop,{
			"accessory.URL"=>WebGUI::URL::gateway($data{urlizedTitle}),
			"accessory.title"=>$data{title},
			"accessory.controls"=>$segment
			});
        }
        $sth->finish;
	$var{accessory_loop} = \@accessoryloop;

	#---related
        $var{"addrelatedproduct.url"} = WebGUI::URL::page('func=addRelated&wid='.$_[0]->get("wobjectId"));
	$var{"addrelatedproduct.label"} = WebGUI::International::get(37,$_[0]->get("namespace"));
	$sth = WebGUI::SQL->read("select wobject.title,page.urlizedTitle,Product_related.relatedWobjectId 
		from Product_related,wobject,page 
		where Product_related.wobjectId=".$_[0]->get("wobjectId")." 
		and Product_related.relatedWobjectId=wobject.wobjectId 
		and wobject.pageId=page.pageId order by Product_related.sequenceNumber");
        while (%data = $sth->hash) {
                $segment = deleteIcon('func=deleteRelated&wid='.$_[0]->get("wobjectId").'&rid='.$data{relatedWobjectId})
                        .moveUpIcon('func=moveRelatedUp&wid='.$_[0]->get("wobjectId").'&rid='.$data{relatedWobjectId})
                        .moveDownIcon('func=moveRelatedDown&wid='.$_[0]->get("wobjectId").'&rid='.$data{relatedWobjectId});
                push(@relatedloop,{
			"relatedproduct.URL"=>WebGUI::URL::gateway($data{urlizedTitle}),
			"relatedproduct.title"=>$data{title},
                        "relatedproduct.controls"=>$segment
			});
        }
        $sth->finish;
	$var{relatedproduct_loop} = \@relatedloop;
        return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}




1;

