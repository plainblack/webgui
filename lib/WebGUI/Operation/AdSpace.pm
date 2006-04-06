package WebGUI::Operation::AdSpace;

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
use WebGUI::AdSpace;
use WebGUI::AdSpace::Ad;
use WebGUI::AdminConsole;
use WebGUI::International;
use WebGUI::HTMLForm;

=head1 NAME

Package WebGUI::Operation::AdSpace

=head1 DESCRIPTION

Operation handler for advertising functions.

=cut

#-------------------------------------------------------------------

=head2 www_clickAd ( )

Handles a click on an advertisement.

=cut

sub www_clickAd {
	my $session = shift;
	my $id = $session->form->param("adId");
	return undef unless $id;
	my $url = WebGUI::AdSpace->countClick($session, $id);
	$session->http->setRedirect($url);
	return "Redirecting to $url";
}

#-------------------------------------------------------------------

=head2 www_editAd ( )

Displays form for editing an ad.

=cut

sub www_editAd {
	my $session = shift;
	return $session->privilege->insufficient unless ($session->user->isInGroup("pbgroup000000000000017"));
	my $id = $session->form->param("adId") || "new";
	my $ac = WebGUI::AdminConsole->new($session,"adSpace");
	my $i18n = WebGUI::International->new($session,"AdSpace");
	my $ad = WebGUI::AdSpace::Ad->new($session,$id);
	$ac->addSubmenuItem($session->url->page("op=editAdSpace;adSpace=".$session->form->param("adSpace")), $i18n->get("edit this ad space"));
	$ac->addSubmenuItem($session->url->page("op=editAdSpace"), $i18n->get("add ad space"));
	$ac->addSubmenuItem($session->url->page("op=manageAdSpaces"), $i18n->get("manage ad spaces"));
	my $f = WebGUI::HTMLForm->new($session);
	$f->submit;
	$f->hidden(name=>"adId", value=>$id);
	$f->hidden(name=>"adSpaceId", value=> $session->form->param("adSpaceId"));
	$f->readOnly(label=>$i18n->get("ad id"), value=>$id);
	$f->hidden(name=>"op", value=>"editAdSpaceSave");
	my $value = $ad->get("isActive") if defined $ad;
	$f->yesNo(
		name=>"isActive",
		value=>$value,
		hoverHelp => $i18n->get("is active help"),
		label=>$i18n->get("is active")
		);
	my $value = $ad->get("title") if defined $ad;
	$f->text(
		name=>"title",
		value=>$value,
		hoverHelp => $i18n->get("title help"),
		label=>$i18n->get("title")
		);
	my $value = $ad->get("impressionsBought") if defined $ad;
	$f->integer(
		name=>"impressionsBought",
		value=>$value,
		hoverHelp => $i18n->get("impressions bought help"),
		label=>$i18n->get("impressions bought"),
		subtext=> defined $ad ? $i18n->get("used").": ".$ad->get("impressions") : undef
		);
	my $value = $ad->get("clicksBought") if defined $ad;
	$f->integer(
		name=>"clicksBought",
		value=>$value,
		hoverHelp => $i18n->get("clicks bought help"),
		label=>$i18n->get("clicks bought"),
		subtext=> defined $ad ? $i18n->get("used").": ".$ad->get("clicks") : undef
		);
	my $value = $ad->get("type") if defined $ad;
	$f->selectBox(
		name=>"type",
		value=>$value,
		options=>{
			text=>$i18n->get("text"),
			image=>$i18n->get("image"),
			rich=>$i18n->get("rich"),
			},
		defaultValue=>"text",
		hoverHelp => $i18n->get("top help"),
		label=>$i18n->get("title")
		);
	$f->fieldSetStart($i18n->get("text"));
	my $value = $ad->get("adText") if defined $ad;
	$f->text(
		name=>"adText",
		value=>$value,
		hoverHelp => $i18n->get("ad text help"),
		label=>$i18n->get("ad text")
		);
	my $value = $ad->get("borderColor") if defined $ad;
	$f->color(
		name=>"borderColor",
		value=>$value,
		defaultValue=>"#000000",
		hoverHelp => $i18n->get("border color help"),
		label=>$i18n->get("border color text")
		);
	my $value = $ad->get("textColor") if defined $ad;
	$f->color(
		name=>"textColor",
		value=>$value,
		defaultValue=>"#000000",
		hoverHelp => $i18n->get("text color help"),
		label=>$i18n->get("text color text")
		);
	my $value = $ad->get("backgroundColor") if defined $ad;
	$f->color(
		name=>"backgroundColor",
		value=>$value,
		defaultValue=>"#ffffff",
		hoverHelp => $i18n->get("background color help"),
		label=>$i18n->get("background color text")
		);
	$f->fieldSetEnd;
	$f->fieldSetStart($i18n->get("image"));
	$f->image(
		label=>$i18n->get("image")
		);
	$f->fieldSetEnd;
	$f->fieldSetStart($i18n->get("rich"));
	my $value = $ad->get("richMedia") if defined $ad;
	$f->codearea(
		name=>"richMedia",
		label=>$i18n->get("rich"),
		value=>$value,
		hoverHelp=>$i18n->get("rich help")
		);
	$f->fieldSetEnd;
	$f->submit;
	$ac->render($f->print, $i18n->get("edit advertisement"));
}

#-------------------------------------------------------------------

=head2 www_editAdSpace ( )

Edit or add an ad space form.

=cut

sub www_editAdSpace {
	my $session = shift;
	return $session->privilege->insufficient unless ($session->user->isInGroup("pbgroup000000000000017"));
	my $id = $session->form->param("adSpaceId") || "new";
	my $ac = WebGUI::AdminConsole->new($session,"adSpace");
	my $i18n = WebGUI::International->new($session,"AdSpace");
	my $adSpace = WebGUI::AdSpace->new($session, $id);
	$ac->addSubmenuItem($session->url->page("op=editAd"), $i18n->get("add an ad")) if defined $adSpace;
	$ac->addSubmenuItem($session->url->page("op=manageAdSpaces"), $i18n->get("manage ad spaces"));
	my $f = WebGUI::HTMLForm->new($session);
	$f->hidden(name=>"adSpaceId", value=>$id);
	$f->readOnly(label=>$i18n->get("ad space id"), value=>$id);
	$f->hidden(name=>"op", value=>"editAdSpaceSave");
	my $value = $adSpace->get("name") if defined $adSpace;
	$f->text(
		name=>"name",
		value=>$value,
		hoverHelp => $i18n->get("name help"),
		label=>$i18n->get("name")
		);
	my $value = $adSpace->get("title") if defined $adSpace;
	$f->text(
		name=>"title",
		value=>$value,
		hoverHelp => $i18n->get("title help"),
		label=>$i18n->get("title")
		);
	my $value = $adSpace->get("description") if defined $adSpace;
	$f->textarea(
		name=>"description",
		value=>$value,
		hoverHelp => $i18n->get("description help"),
		label=>$i18n->get("description")
		);
	my $value = $adSpace->get("width") if defined $adSpace;
	$f->integer(
		name=>"width",
		value=>$value,
		defaultValue=>468,
		hoverHelp => $i18n->get("width help"),
		label=>$i18n->get("width")
		);
	my $value = $adSpace->get("height") if defined $adSpace;
	$f->integer(
		name=>"height",
		value=>$value,
		defaultValue=>60,
		hoverHelp => $i18n->get("height help"),
		label=>$i18n->get("height")
		);
	$f->submit;
	my $ads = "";
	if (defined $adSpace) {
		my $rs = $session->db->read("select adId, title from advertisement where adId=?",[$id]);
		while (my ($adId, $title) = $rs->array) {
			$ads .= $session->icon->delete("op=deleteAd;adSpaceId=".$id.";adId=".$adId, undef, $i18n->get("confirm ad delete"))
				.$session->icon->edit("op=editAd;adSpaceId=".$id.";adId=".$adId)
				.' '.$title.'<br />';
		}
	}
	$ac->render($f->print.$ads, $i18n->get("edit ad space"));
}


#-------------------------------------------------------------------

=head2 www_editAdSpaceSave ()

Save the www_editAdSpace method.

=cut

sub www_editAdSpaceSave {
	my $session = shift;
	return $session->privilege->insufficient unless ($session->user->isInGroup("pbgroup000000000000017"));
	my %properties = (
		name=>$session->form->process("name", "text"),	
		title=>$session->form->process("title", "text"),	
		description=>$session->form->process("description", "textarea"),	
		width=>$session->form->process("width", "integer"),	
		height=>$session->form->process("height", "integer"),	
		);
	if ($session->form->param("adSpaceId") eq "new") {
		WebGUI::AdSpace->create($session, \%properties);
	} else {
		my $adSpace = WebGUI::AdSpace->new($session, $session->form->param("adSpaceId"));
		$adSpace->set(\%properties);
	}
	return www_manageAdSpaces($session);
}

#-------------------------------------------------------------------

=head2 www_manageAdSpaces ( )

Manage ad spaces.

=cut

sub www_manageAdSpaces {
	my $session = shift;
	return $session->privilege->insufficient unless ($session->user->isInGroup("pbgroup000000000000017"));
	my $ac = WebGUI::AdminConsole->new($session,"adSpace");
	my $i18n = WebGUI::International->new($session,"AdSpace");
	my $output = "";
	my $rs = $session->db->read("select adSpaceId, title from adSpace order by title");
	while (my ($id, $title) = $rs->array) {
		$output .= $session->icon->delete("op=deleteAdSpace;adSpaceId=".$id, undef, $i18n->get("confirm ad space delete"))
			.$session->icon->edit("op=editAdSpace;adSpaceId=".$id)
			.' '.$title.'<br />';
	}	
	$ac->addSubmenuItem($session->url->page("op=editAdSpace"), $i18n->get("add ad space"));
	return $ac->render($output);
}


1;
