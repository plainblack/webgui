package WebGUI::Wobject::Product;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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
our $namespace = "Product";
our $name = WebGUI::International::get(1,$namespace);


#-------------------------------------------------------------------
sub _fileProperty {
	my ($filename, $f, $labelId, $name);
	$name = shift;
	$labelId = shift;
	$filename = shift;
	$f = WebGUI::HTMLForm->new;
	if ($filename ne "") {
                $f->readOnly('<a href="'.WebGUI::URL::page('func=deleteFile&file='.$name.'&wid='.$session{form}{wid}).'">'.
                                WebGUI::International::get(391).'</a>',WebGUI::International::get($labelId,$namespace));
        } else {
                $f->file($name,WebGUI::International::get($labelId,$namespace));
        }
	return $f->printRowsOnly;
}

#-------------------------------------------------------------------
sub _reorderAccessories {
        my ($sth, $i, $id);
        $sth = WebGUI::SQL->read("select accessoryWobjectId from
                Product_accessory where wobjectId=$_[0] order by sequenceNumber");
        while (($id) = $sth->array) {
                WebGUI::SQL->write("update Product_accessory set sequenceNumber='$i' 
		where wobjectId=$_[0] and accessoryWobjectId=$id");
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub _reorderBenefits {
        my ($sth, $i, $id);
        $sth = WebGUI::SQL->read("select productBenefitId from
                Product_benefit where wobjectId=$_[0] order by sequenceNumber");
        while (($id) = $sth->array) {
                WebGUI::SQL->write("update Product_benefit set sequenceNumber='$i' where productBenefitId=$id");
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub _reorderFeatures {
        my ($sth, $i, $id);
        $sth = WebGUI::SQL->read("select productFeatureId from 
		Product_feature where wobjectId=$_[0] order by sequenceNumber");
        while (($id) = $sth->array) {
                WebGUI::SQL->write("update Product_feature set sequenceNumber='$i' where productFeatureId=$id");
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub _reorderRelated {
        my ($sth, $i, $id);
        $sth = WebGUI::SQL->read("select relatedWobjectId from
                Product_related where wobjectId=$_[0] order by sequenceNumber");
        while (($id) = $sth->array) {
                WebGUI::SQL->write("update Product_related set sequenceNumber='$i'
                where wobjectId=$_[0] and relatedWobjectId=$id");
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub _reorderSpecifications {
        my ($sth, $i, $id);
        $sth = WebGUI::SQL->read("select productSpecificationId from
                Product_specification where wobjectId=$_[0] order by sequenceNumber");
        while (($id) = $sth->array) {
                WebGUI::SQL->write("update Product_specification set sequenceNumber='$i' where productSpecificationId=$id");
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($w, $file, %data, $newId, $sth);
	tie %data, 'Tie::CPHash';
        $w = $_[0]->SUPER::duplicate($_[1]);
	$w = WebGUI::Wobject::Product->new({wobjectId=>$w,namespace=>$namespace});
	$w->set({
		image1=>$_[0]->get("image1"),
		image2=>$_[0]->get("image2"),
		image3=>$_[0]->get("image3"),
		warranty=>$_[0]->get("warranty"),
		manual=>$_[0]->get("manual"),
		brochure=>$_[0]->get("brochure"),
		price=>$_[0]->get("price"),
		productTemplateId=>$_[0]->get("productTemplateId"),
		productNumber=>$_[0]->get("productNumber")
		});
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
        while (%data = $sth->hash) {
                $newId = getNextId("productFeatureId");
                WebGUI::SQL->write("insert into Product_feature values (".$w->get("wobjectId").", $newId, "
			.quote($data{feature}).", $data{sequenceNumber})");
        }
        $sth->finish;
        $sth = WebGUI::SQL->read("select * from Product_benefit where wobjectId=".$_[0]->get("wobjectId"));
        while (%data = $sth->hash) {
                $newId = getNextId("productBenefitId");
                WebGUI::SQL->write("insert into Product_benefit values (".$w->get("wobjectId").", $newId, "
                        .quote($data{benefit}).", $data{sequenceNumber})");
        }
        $sth->finish;
        $sth = WebGUI::SQL->read("select * from Product_specification where wobjectId=".$_[0]->get("wobjectId"));
        while (%data = $sth->hash) {
                $newId = getNextId("productSpecificationId");
                WebGUI::SQL->write("insert into Product_specification values (".$w->get("wobjectId").", $newId, "
                        .quote($data{name}).", ".quote($data{value}).", ".quote($data{units}).", $data{sequenceNumber})");
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
sub new {
        my ($self, $class, $property);
        $class = shift;
        $property = shift;
        $self = WebGUI::Wobject->new($property);
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
sub set {
        $_[0]->SUPER::set($_[1],[qw(price productTemplateId productNumber image1 image2 image3 manual brochure warranty)]);
}

#-------------------------------------------------------------------
sub www_addAccessory {
        my ($output, $f, $accessory, @usedAccessories);
        if (WebGUI::Privilege::canEditPage()) {
		$output = helpIcon(4,$namespace);
                $output .= '<h1>'.WebGUI::International::get(16,$namespace).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->hidden("wid",$_[0]->get("wobjectId"));
                $f->hidden("func","addAccessorySave");
                @usedAccessories = WebGUI::SQL->quickArray("select accessoryWobjectId from Product_accessory
                        where wobjectId=".$session{form}{wid});
                push(@usedAccessories,$session{form}{wid});
                $accessory = WebGUI::SQL->buildHashRef("select wobjectId,title from wobject where namespace='Product'
                        and wobjectId not in (".join(",",@usedAccessories).")");
                $f->select("accessoryWobjectId",$accessory,WebGUI::International::get(17,$namespace));
                $f->yesNo("proceed",WebGUI::International::get(18,$namespace));
                $f->submit;
                $output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addAccessorySave {
        my ($seq);
        if (WebGUI::Privilege::canEditPage()) {
                ($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from Product_accessory
                        where wobjectId=".$_[0]->get("wobjectId"));
                WebGUI::SQL->write("insert into Product_accessory (wobjectId,accessoryWobjectId,sequenceNumber) values
                                (".$_[0]->get("wobjectId").",$session{form}{accessoryWobjectId},".($seq+1).")");
                if ($session{form}{proceed}) {
                        return $_[0]->www_addAccessory();
                } else {
                        return "";
                }
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_addRelated {
        my ($output, $f, $related, @usedRelated);
        if (WebGUI::Privilege::canEditPage()) {
		$output = helpIcon(5,$namespace);
                $output .= '<h1>'.WebGUI::International::get(19,$namespace).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->hidden("wid",$_[0]->get("wobjectId"));
                $f->hidden("func","addRelatedSave");
                @usedRelated = WebGUI::SQL->quickArray("select relatedWobjectId from Product_related
                        where wobjectId=".$session{form}{wid});
                push(@usedRelated,$session{form}{wid});
                $related = WebGUI::SQL->buildHashRef("select wobjectId,title from wobject where namespace='Product'
                        and wobjectId not in (".join(",",@usedRelated).")");
                $f->select("relatedWobjectId",$related,WebGUI::International::get(20,$namespace));
                $f->yesNo("proceed",WebGUI::International::get(21,$namespace));
                $f->submit;
                $output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addRelatedSave {
        my ($seq);
        if (WebGUI::Privilege::canEditPage()) {
                ($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from Product_related
                        where wobjectId=".$_[0]->get("wobjectId"));
                WebGUI::SQL->write("insert into Product_related (wobjectId,relatedWobjectId,sequenceNumber) values
                                (".$_[0]->get("wobjectId").",$session{form}{relatedWobjectId},".($seq+1).")");
                if ($session{form}{proceed}) {
                        return $_[0]->www_addRelated();
                } else {
                        return "";
                }
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
                $_[0]->duplicate;
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_copyTemplate {
	my (%data);
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from Product_template where productTemplateId=".$session{form}{tid});
		WebGUI::SQL->write("insert into Product_template values (".getNextId("productTemplateId").","
			.quote("Copy of ".$data{name}).",".quote($data{template}).")");
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteAccessory {
        $_[0]->confirm(
                WebGUI::International::get(2,$namespace),
		WebGUI::URL::page('func=deleteAccessoryConfirm&wid='.$_[0]->get("wobjectId").'&aid='.$session{form}{aid})
                );
}

#-------------------------------------------------------------------
sub www_deleteAccessoryConfirm {
        if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("delete from Product_accessory where wobjectId=$session{form}{wid} 
			and accessoryWobjectId=$session{form}{aid}");
		_reorderAccessories($_[0]->get("wobjectId"));
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteBenefit {
        $_[0]->confirm(
                WebGUI::International::get(48,$namespace),
		WebGUI::URL::page('func=deleteBenefitConfirm&wid='.$_[0]->get("wobjectId").'&bid='.$session{form}{bid})
                );
}

#-------------------------------------------------------------------
sub www_deleteBenefitConfirm {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("delete from Product_benefit where productBenefitId=$session{form}{bid}");
                _reorderBenefits($_[0]->get("wobjectId"));
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteFeature {
	$_[0]->confirm(
		WebGUI::International::get(3,$namespace),
		WebGUI::URL::page('func=deleteFeatureConfirm&wid='.$_[0]->get("wobjectId").'&fid='.$session{form}{fid})
		);
}

#-------------------------------------------------------------------
sub www_deleteFeatureConfirm {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("delete from Product_feature where productFeatureId=$session{form}{fid}");
                _reorderFeatures($_[0]->get("wobjectId"));
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteFile {
        $_[0]->confirm(
                WebGUI::International::get(12,$namespace),
		WebGUI::URL::page('func=deleteFileConfirm&wid='.$_[0]->get("wobjectId").'&file='.$session{form}{file}),
		WebGUI::URL::page('func=edit&wid='.$_[0]->get("wobjectId"))
                );
}

#-------------------------------------------------------------------
sub www_deleteFileConfirm {
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->set({$session{form}{file}=>''});
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteRelated {
        $_[0]->confirm(
                WebGUI::International::get(4,$namespace),
		WebGUI::URL::page('func=deleteRelatedConfirm&wid='.$_[0]->get("wobjectId").'&rid='.$session{form}{rid})
                );
}

#-------------------------------------------------------------------
sub www_deleteRelatedConfirm {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("delete from Product_related where wobjectId=$session{form}{wid}
                        and relatedWobjectId=$session{form}{rid}");
                _reorderRelated($_[0]->get("wobjectId"));
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteSpecification {
        $_[0]->confirm(
                WebGUI::International::get(5,$namespace),
		WebGUI::URL::page('func=deleteSpecificationConfirm&wid='.$_[0]->get("wobjectId").'&sid='.$session{form}{sid})
                );
}

#-------------------------------------------------------------------
sub www_deleteSpecificationConfirm {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("delete from Product_specification where productSpecificationId=$session{form}{sid}");
                _reorderSpecifications($_[0]->get("wobjectId"));
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteTemplate {
        $_[0]->confirm(
                WebGUI::International::get(57,$namespace),
		WebGUI::URL::page('func=deleteTemplateConfirm&wid='.$_[0]->get("wobjectId").'&tid='.$session{form}{tid}),
		'',
		($session{form}{tid} < 1000)
                );
}

#-------------------------------------------------------------------
sub www_deleteTemplateConfirm {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("delete from Product_template where productTemplateId=$session{form}{tid}");
                WebGUI::SQL->write("update Product set productTemplateId=1 where productTemplateId=$session{form}{tid}");
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($f, $output, $proceed, %data, $sth, $templates, $template);
        if (WebGUI::Privilege::canEditPage()) {
		$output = helpIcon(1,$namespace);
                $output .= '<h1>'.WebGUI::International::get(6,$namespace).'</h1>';
		if ($_[0]->get("wobjectId") eq "new") {
			$template = 1;
		} else {
			$template = $_[0]->get("productTemplateId");
		}
		$f = WebGUI::HTMLForm->new;
		$f->text("price",WebGUI::International::get(10,$namespace),$_[0]->get("price"));
		$f->text("productNumber",WebGUI::International::get(11,$namespace),$_[0]->get("productNumber"));
		$f->raw(_fileProperty("image1",7,$_[0]->get("image1")));
		$f->raw(_fileProperty("image2",8,$_[0]->get("image2")));
		$f->raw(_fileProperty("image3",9,$_[0]->get("image3")));
		$f->raw(_fileProperty("brochure",13,$_[0]->get("brochure")));
		$f->raw(_fileProperty("manual",14,$_[0]->get("manual")));
		$f->raw(_fileProperty("warranty",15,$_[0]->get("warranty")));
		$templates = WebGUI::SQL->buildHashRef("select productTemplateId,name from Product_template order by name");
		$f->select("productTemplateId",$templates,WebGUI::International::get(61,$namespace),[$template]);
		$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
		unless ($_[0]->get("wobjectId") eq "new") {
			$output .= '<hr size="1" /><p>';
			$output .= '<a href="'.WebGUI::URL::page('func=editTemplate&tid=new&wid='.$_[0]->get("wobjectId")).'">'
				.WebGUI::International::get(56,$namespace).'</a><p>';
			tie %data, 'Tie::CPHash';
			$sth = WebGUI::SQL->read("select productTemplateId,name from Product_template order by name");
			while (%data = $sth->hash) {
				$output .= deleteIcon('func=deleteTemplate&wid='.$_[0]->get("wobjectId").'&tid='.$data{productTemplateId})
					.editIcon('func=editTemplate&wid='.$_[0]->get("wobjectId").'&tid='.$data{productTemplateId})
					.copyIcon('func=copyTemplate&wid='.$_[0]->get("wobjectId").'&tid='.$data{productTemplateId})
					.' '.$data{name}.'<br>';
			}
			$sth->finish;
		}
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
	my ($file, %property);
        if (WebGUI::Privilege::canEditPage()) {
		$_[0]->SUPER::www_editSave();
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
		$property{productTemplateId}=$session{form}{productTemplateId};
		$property{price}=$session{form}{price};
		$property{productNumber}=$session{form}{productNumber};
		$_[0]->set(\%property);
		return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editBenefit {
        my ($output, $data, $f, $benefits);
        if (WebGUI::Privilege::canEditPage()) {
		$data = $_[0]->getCollateral("Product_benefit","productBenefitId",$session{form}{bid});
                $output = helpIcon(6,$namespace);
                $output .= '<h1>'.WebGUI::International::get(53,$namespace).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->hidden("wid",$_[0]->get("wobjectId"));
                $session{form}{bid} = "new" if ($session{form}{bid} eq "");
                $f->hidden("bid",$session{form}{bid});
                $f->hidden("func","editBenefitSave");
                $benefits = WebGUI::SQL->buildHashRef("select benefit,benefit from Product_benefit order by benefit");
                $f->combo("benefit",$benefits,WebGUI::International::get(51,$namespace),[$data->{benefits}]);
                $f->yesNo("proceed",WebGUI::International::get(52,$namespace));
                $f->submit;
                $output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editBenefitSave {
        if (WebGUI::Privilege::canEditPage()) {
                $session{form}{benefit} = $session{form}{benefit_new} if ($session{form}{benefit_new} ne "");
		$_[0]->setCollateral("Product_benefit", "productBenefitId", {
			productBenefitId => $session{form}{bid},
			benefit => $session{form}{benefit}
			});
                if ($session{form}{proceed}) {
                        $session{form}{bid} = "new";
                        return $_[0]->www_editBenefit();
                } else {
                        return "";
                }
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editFeature {
        my ($output, $data, $f, $features);
        if (WebGUI::Privilege::canEditPage()) {
		$data = $_[0]->getCollateral("Product_feature","productFeatureId",$session{form}{fid});
		$output = helpIcon(2,$namespace);
                $output .= '<h1>'.WebGUI::International::get(22,$namespace).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->hidden("wid",$_[0]->get("wobjectId"));
                $session{form}{fid} = "new" if ($session{form}{fid} eq "");
                $f->hidden("fid",$session{form}{fid});
                $f->hidden("func","editFeatureSave");
		$features = WebGUI::SQL->buildHashRef("select feature,feature from Product_feature order by feature");
                $f->combo("feature",$features,WebGUI::International::get(23,$namespace),[$data->{feature}]);
                $f->yesNo("proceed",WebGUI::International::get(24,$namespace));
                $f->submit;
                $output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editFeatureSave {
        if (WebGUI::Privilege::canEditPage()) {
		$session{form}{feature} = $session{form}{feature_new} if ($session{form}{feature_new} ne "");
                $_[0]->setCollateral("Product_feature", "productFeatureId", {
                        productFeatureId => $session{form}{fid},
                        feature => $session{form}{feature}
                        });
                if ($session{form}{proceed}) {
                        $session{form}{fid} = "new";
                        return $_[0]->www_editFeature();
                } else {
                        return "";
                }
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSpecification {
        my ($output, $data, $f, $hashRef);
        if (WebGUI::Privilege::canEditPage()) {
		$data = $_[0]->getCollateral("Product_specification","productSpecificationId",$session{form}{sid});
		$output = helpIcon(3,$namespace);
                $output .= '<h1>'.WebGUI::International::get(25,$namespace).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->hidden("wid",$_[0]->get("wobjectId"));
                $session{form}{sid} = "new" if ($session{form}{sid} eq "");
                $f->hidden("sid",$session{form}{sid});
                $f->hidden("func","editSpecificationSave");
                $hashRef = WebGUI::SQL->buildHashRef("select name,name from Product_specification order by name");
                $f->combo("name",$hashRef,WebGUI::International::get(26,$namespace),[$data->{name}]);
                $f->text("value",WebGUI::International::get(27,$namespace),$data->{value});
                $hashRef = WebGUI::SQL->buildHashRef("select units,units from Product_specification order by units");
                $f->combo("units",$hashRef,WebGUI::International::get(29,$namespace),[$data->{units}]);
                $f->yesNo("proceed",WebGUI::International::get(28,$namespace));
                $f->submit;
                $output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editSpecificationSave {
        if (WebGUI::Privilege::canEditPage()) {
                $session{form}{name} = $session{form}{name_new} if ($session{form}{name_new} ne "");
                $session{form}{units} = $session{form}{units_new} if ($session{form}{units_new} ne "");
                $_[0]->setCollateral("Product_specification", "productSpecificationId", {
                        productSpecificationId => $session{form}{sid},
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
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editTemplate {
        my ($output, $data, $f);
        if (WebGUI::Privilege::canEditPage()) {
		$data = $_[0]->getCollateral("Product_template","productTemplateId",$session{form}{tid});
                $output = helpIcon(7,$namespace);
                $output .= '<h1>'.WebGUI::International::get(58,$namespace).'</h1>';
                $f = WebGUI::HTMLForm->new;
                $f->hidden("wid",$_[0]->get("wobjectId"));
                $session{form}{tid} = "new" if ($session{form}{tid} eq "");
                $f->hidden("tid",$session{form}{tid});
                $f->hidden("func","editTemplateSave");
		$f->text("name",WebGUI::International::get(59,$namespace),$data->{name});
		$f->HTMLArea("template",WebGUI::International::get(60,$namespace),$data->{template},'','','',($session{setting}{textAreaRows}+10));
                $f->submit;
                $output .= $f->print;
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editTemplateSave {
        if (WebGUI::Privilege::canEditPage()) {
                $_[0]->setCollateral("Product_template", "productTemplateId", {
                        productTemplateId => $session{form}{tid},
                        name => $session{form}{name},
                        template => $session{form}{template}
                        }, 0, 0);
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveAccessoryDown {
        $_[0]->moveCollateralDown("Product_related","accessoryWobjectId",$session{form}{aid});
}

#-------------------------------------------------------------------
sub www_moveAccessoryUp {
        $_[0]->moveCollateralUp("Product_accessory","accessoryWobjectId",$session{form}{aid});
}

#-------------------------------------------------------------------
sub www_moveBenefitDown {
        $_[0]->moveCollateralDown("Product_benefit","productBenefitId",$session{form}{bid});
}

#-------------------------------------------------------------------
sub www_moveBenefitUp {
        $_[0]->moveCollateralUp("Product_benefit","productBenefitId",$session{form}{bid});
}

#-------------------------------------------------------------------
sub www_moveFeatureDown {
        $_[0]->moveCollateralDown("Product_feature","productFeatureId",$session{form}{fid});
}

#-------------------------------------------------------------------
sub www_moveFeatureUp {
	$_[0]->moveCollateralUp("Product_feature","productFeatureId",$session{form}{fid});
}

#-------------------------------------------------------------------
sub www_moveRelatedDown {
        $_[0]->moveCollateralDown("Product_related","relatedWobjectId",$session{form}{rid});
}

#-------------------------------------------------------------------
sub www_moveRelatedUp {
        $_[0]->moveCollateralUp("Product_related","relatedWobjectId",$session{form}{rid});
}

#-------------------------------------------------------------------
sub www_moveSpecificationDown {
        $_[0]->moveCollateralDown("Product_specification","productSpecificationId",$session{form}{sid});
}

#-------------------------------------------------------------------
sub www_moveSpecificationUp {
        $_[0]->moveCollateralUp("Product_specification","productSpecificationId",$session{form}{sid});
}

#-------------------------------------------------------------------
sub www_view {
        my ($output, %data, $sth, $file, $segment, $template);
        tie %data, 'Tie::CPHash';
        $output = $_[0]->displayTitle;
	($template) = WebGUI::SQL->quickArray("select template from Product_template where productTemplateId=".$_[0]->get("productTemplateId"));
        #---product title 
        $segment = $_[0]->get("title");
        $template =~ s/\^Product_Title\;/$segment/;
	#---product description
        $segment = $_[0]->description;
	$template =~ s/\^Product_Description\;/$segment/;
	#---product price
        $segment = $_[0]->get("price");
	$template =~ s/\^Product_Price\;/$segment/;
	#---product number
        $segment = $_[0]->get("productNumber");
	$template =~ s/\^Product_Number\;/$segment/;
	#---product brochure
	$segment = "";
        if ($_[0]->get("brochure")) {
                $file = WebGUI::Attachment->new($_[0]->get("brochure"),$_[0]->get("wobjectId"));
                $segment = '<a href="'.$file->getURL.'"><img src="'.$file->getIcon.'" border=0 align="absmiddle"> '
			.WebGUI::International::get(13,$namespace).'</a>';
        }
	$template =~ s/\^Product_Brochure\;/$segment/;
	#---product manual
	$segment = "";
        if ($_[0]->get("manual")) {
                $file = WebGUI::Attachment->new($_[0]->get("manual"),$_[0]->get("wobjectId"));
                $segment = '<a href="'.$file->getURL.'"><img src="'.$file->getIcon.'" border=0 align="absmiddle"> '
			.WebGUI::International::get(14,$namespace).'</a>';
        }
	$template =~ s/\^Product_Manual\;/$segment/;
	#---product warranty
	$segment = "";
        if ($_[0]->get("warranty")) {
                $file = WebGUI::Attachment->new($_[0]->get("warranty"),$_[0]->get("wobjectId"));
                $segment = '<a href="'.$file->getURL.'"><img src="'.$file->getIcon.'" border=0 align="absmiddle"> '
			.WebGUI::International::get(15,$namespace).'</a>';
        }
	$template =~ s/\^Product_Warranty\;/$segment/;
	#---product thumbnail1
	$segment = "";
        if ($_[0]->get("image1")) {
                $file = WebGUI::Attachment->new($_[0]->get("image1"),$_[0]->get("wobjectId"));
                $segment = '<a href="'.$file->getURL.'"><img src="'.$file->getThumbnail.'" border=0></a>';
        }
	$template =~ s/\^Product_Thumbnail1\;/$segment/;
	#---product thumbnail2
	$segment = "";
        if ($_[0]->get("image2")) {
                $file = WebGUI::Attachment->new($_[0]->get("image2"),$_[0]->get("wobjectId"));
                $segment = '<a href="'.$file->getURL.'"><img src="'.$file->getThumbnail.'" border=0></a>';
        }
	$template =~ s/\^Product_Thumbnail2\;/$segment/;
	#---product thumbnail3
	$segment = "";
        if ($_[0]->get("image3")) {
                $file = WebGUI::Attachment->new($_[0]->get("image3"),$_[0]->get("wobjectId"));
                $segment = '<a href="'.$file->getURL.'"><img src="'.$file->getThumbnail.'" border=0></a>';
        }
	$template =~ s/\^Product_Thumbnail3\;/$segment/;
        #---product image1
	$segment = "";
        if ($_[0]->get("image1")) {
                $file = WebGUI::Attachment->new($_[0]->get("image1"),$_[0]->get("wobjectId"));
                $segment = '<img src="'.$file->getURL.'" border=0>';
        }
        $template =~ s/\^Product_Image1\;/$segment/;
        #---product image2
	$segment = "";
        if ($_[0]->get("image2")) {
                $file = WebGUI::Attachment->new($_[0]->get("image2"),$_[0]->get("wobjectId"));
                $segment = '<img src="'.$file->getURL.'" border=0>';
        }
        $template =~ s/\^Product_Image2\;/$segment/;
        #---product image3
	$segment = "";
        if ($_[0]->get("image3")) {
                $file = WebGUI::Attachment->new($_[0]->get("image3"),$_[0]->get("wobjectId"));
                $segment = '<img src="'.$file->getURL.'" border=0>';
        }
        $template =~ s/\^Product_Image3\;/$segment/;
	#---product features 
	$segment = "";
        $sth = WebGUI::SQL->read("select feature,productFeatureId from Product_feature where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
        if ($session{var}{adminOn}) {
        	$segment .= '<a href="'.WebGUI::URL::page('func=editFeature&fid=new&wid='
                	.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(34,$namespace).'</a><p/>';
        }
        while (%data = $sth->hash) {
                if ($session{var}{adminOn}) {
                        $segment .= deleteIcon('func=deleteFeature&wid='.$_[0]->get("wobjectId").'&fid='.$data{productFeatureId})
                                .editIcon('func=editFeature&wid='.$_[0]->get("wobjectId").'&fid='.$data{productFeatureId})
                                .moveUpIcon('func=moveFeatureUp&wid='.$_[0]->get("wobjectId").'&fid='.$data{productFeatureId})
                                .moveDownIcon('func=moveFeatureDown&wid='.$_[0]->get("wobjectId").'&fid='.$data{productFeatureId});
                }
                $segment .= '&middot;'.$data{feature}.'<br>';
        }
        $sth->finish;
	$template =~ s/\^Product_Features\;/$segment/;
	#---product benefits 
	$segment = "";
        $sth = WebGUI::SQL->read("select benefit,productBenefitId from Product_benefit where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
        if ($session{var}{adminOn}) {
        	$segment .= '<a href="'.WebGUI::URL::page('func=editBenefit&fid=new&wid='
                	.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(55,$namespace).'</a><p/>';
        }
        while (%data = $sth->hash) {
                if ($session{var}{adminOn}) {
                        $segment .= deleteIcon('func=deleteBenefit&wid='.$_[0]->get("wobjectId").'&bid='.$data{productBenefitId})
                                .editIcon('func=editBenefit&wid='.$_[0]->get("wobjectId").'&bid='.$data{productBenefitId})
                                .moveUpIcon('func=moveBenefitUp&wid='.$_[0]->get("wobjectId").'&bid='.$data{productBenefitId})
                                .moveDownIcon('func=moveBenefitDown&wid='.$_[0]->get("wobjectId").'&bid='.$data{productBenefitId});
                }
                $segment.= '&middot;'.$data{benefit}.'<br>';
        }
        $sth->finish;
	$template =~ s/\^Product_Benefits\;/$segment/;
	#---product specifications 
	$segment = "";
        $sth = WebGUI::SQL->read("select name,value,units,productSpecificationId from Product_specification
                where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
        if ($session{var}{adminOn}) {
        	$segment .= '<a href="'.WebGUI::URL::page('func=editSpecification&sid=new&wid='
                	.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(35,$namespace).'</a><p/>';
        }
        while (%data = $sth->hash) {
                if ($session{var}{adminOn}) {
                        $segment .= deleteIcon('func=deleteSpecification&wid='.$_[0]->get("wobjectId").'&sid='.$data{productSpecificationId})
                                .editIcon('func=editSpecification&wid='.$_[0]->get("wobjectId").'&sid='.$data{productSpecificationId})
                                .moveUpIcon('func=moveSpecificationUp&wid='.$_[0]->get("wobjectId").'&sid='.$data{productSpecificationId})
                                .moveDownIcon('func=moveSpecificationDown&wid='.$_[0]->get("wobjectId").'&sid='.$data{productSpecificationId});
                }
                $segment .= '&middot;<b>'.$data{name}.':</b> '.$data{value}.' '.$data{units}.'<br>';
        }
        $sth->finish;
	$template =~ s/\^Product_Specifications\;/$segment/;
	#---product accessories 
	$segment = "";
        $sth = WebGUI::SQL->read("select wobject.title,page.urlizedTitle,Product_accessory.accessoryWobjectId from Product_accessory,wobject,page
                where Product_accessory.wobjectId=".$_[0]->get("wobjectId")."
                and Product_accessory.accessoryWobjectId=wobject.wobjectId and wobject.pageId=page.pageId order by Product_accessory.sequenceNumber");
        if ($session{var}{adminOn}) {
        	$segment .= '<a href="'.WebGUI::URL::page('func=addAccessory&wid='
                	.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(36,$namespace).'</a><p/>';
        }
        while (%data = $sth->hash) {
                if ($session{var}{adminOn}) {
                        $segment .= deleteIcon('func=deleteAccessory&wid='.$_[0]->get("wobjectId").'&aid='.$data{accessoryWobjectId})
                                .moveUpIcon('func=moveAccessoryUp&wid='.$_[0]->get("wobjectId").'&aid='.$data{accessoryWobjectId})
                                .moveDownIcon('func=moveAccessoryDown&wid='.$_[0]->get("wobjectId").'&aid='.$data{accessoryWobjectId});
                }
                $segment .= '&middot;<a href="'.WebGUI::URL::gateway($data{urlizedTitle}).'">'.$data{title}.'</a><br>';
        }
        $sth->finish;
	$template =~ s/\^Product_Accessories\;/$segment/;
	#---product related
	$segment = "";
        $sth = WebGUI::SQL->read("select wobject.title,page.urlizedTitle,Product_related.relatedWobjectId from Product_related,wobject,page
                where Product_related.wobjectId=".$_[0]->get("wobjectId")."
                and Product_related.relatedWobjectId=wobject.wobjectId and wobject.pageId=page.pageId order by Product_related.sequenceNumber");
        if ($session{var}{adminOn}) {
        	$segment .= '<a href="'.WebGUI::URL::page('func=addRelated&wid='
			.$_[0]->get("wobjectId")).'">'.WebGUI::International::get(37,$namespace).'</a><p/>';
        }
        while (%data = $sth->hash) {
                if ($session{var}{adminOn}) {
                        $segment .= deleteIcon('func=deleteRelated&wid='.$_[0]->get("wobjectId").'&rid='.$data{relatedWobjectId})
                                .moveUpIcon('func=moveRelatedUp&wid='.$_[0]->get("wobjectId").'&rid='.$data{relatedWobjectId})
                                .moveDownIcon('func=moveRelatedDown&wid='.$_[0]->get("wobjectId").'&rid='.$data{relatedWobjectId});
                }
                $segment .= '&middot;<a href="'.WebGUI::URL::gateway($data{urlizedTitle}).'">'.$data{title}.'</a><br>';
        }
        $sth->finish;
	$template =~ s/\^Product_Related\;/$segment/;
	$output .= $template;
        return $_[0]->processMacros($output);
}




1;

