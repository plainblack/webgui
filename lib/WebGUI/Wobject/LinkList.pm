package WebGUI::Wobject::LinkList;

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
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "LinkList";
our $name = WebGUI::International::get(6,$namespace);


#-------------------------------------------------------------------
sub duplicate {
        my ($w, $sth, $row);
	$w = $_[0]->SUPER::duplicate($_[1]);
	$w = WebGUI::Wobject::LinkList->new({wobjectId=>$w,namespace=>$namespace});
	$w->set({
		templateId=>$_[0]->get("templateId")
		});
        $sth = WebGUI::SQL->read("select * from LinkList_link where wobjectId=".$_[0]->get("wobjectId")
		." order by sequenceNumber");
        while ($row = $sth->hashRef) {
		$row->{LinkList_linkId} = "new";
		$w->setCollateral("LinkList_link","LinkList_linkId",$row);
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from LinkList_link where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(templateId)]);
}

#-------------------------------------------------------------------
sub www_deleteLink {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	return $_[0]->confirm(WebGUI::International::get(9,$namespace),
		WebGUI::URL::page('func=deleteLinkConfirm&wid='.$session{form}{wid}.'&lid='.$session{form}{lid}));
}

#-------------------------------------------------------------------
sub www_deleteLinkConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->deleteCollateral("LinkList_link","LinkList_linkId",$session{form}{lid});
	$_[0]->reorderCollateral("LinkList_link","LinkList_linkId");
        return "";
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($proceed, $f, $output, $indent, $lineSpacing, $bullet);
        if ($_[0]->get("wobjectId") eq "new") {
                $proceed = 1;
        }
	$bullet = $_[0]->get("bullet") || '&middot;';
	$lineSpacing = $_[0]->get("lineSpacing") || 1;
	$indent = $_[0]->get("indent") || 5;
        $output = helpIcon(1,$namespace);
	$output .= '<h1>'.WebGUI::International::get(10,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->template(
                -name=>"templateId",
                -value=>$_[0]->get("templateId"),
                -namespace=>$namespace,
                -afterEdit=>'func=edit&wid='.$_[0]->get("wobjectId")
                );
        if ($_[0]->get("wobjectId") eq "new") {
                $f->whatNext(
                        -options=>{
                                addLink=>WebGUI::International::get(13,$namespace),
                                backToPage=>WebGUI::International::get(745)
                                },
                        -value=>"addLink"
                        );
        }
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        $_[0]->SUPER::www_editSave({
		templateId=>$session{form}{templateId}
		});
        if ($session{form}{proceed} eq "addLink") {
		$session{form}{lid} = "new";
                $_[0]->www_editLink();
        } else {
                return "";
        }
}

#-------------------------------------------------------------------
sub www_editLink {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $link, $f, $linkId, $newWindow);
        $link = $_[0]->getCollateral("LinkList_link", "LinkList_linkId",$session{form}{lid});
        if ($link->{LinkList_linkId} eq "new") {
       	        $newWindow = 1;
        } else {
       	        $newWindow = $link->{newWindow};
       	}
	$output = helpIcon(2,$namespace);
        $output .= '<h1>'.WebGUI::International::get(12,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("lid",$link->{LinkList_linkId});
        $f->hidden("func","editLinkSave");
	$f->text("name",WebGUI::International::get(99),$link->{name});
        $f->url("url",WebGUI::International::get(8,$namespace),$link->{url});
        $f->yesNo("newWindow",WebGUI::International::get(3,$namespace),$newWindow);
        $f->textarea("description",WebGUI::International::get(85),$link->{description});
        if ($link->{LinkList_linkId} eq "new") {
		$f->hidden("sequenceNumber",-1);
                $f->whatNext(
                        -options=>{
                                addLink=>WebGUI::International::get(13,$namespace),
                                backToPage=>WebGUI::International::get(745)
                                },
                        -value=>"backToPage"
                        );
        }
	$f->submit;
	$output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_editLinkSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->setCollateral("LinkList_link", "LinkList_linkId", {
                LinkList_linkId => $session{form}{lid},
                description => $session{form}{description},
                newWindow => $session{form}{newWindow},
                url => $session{form}{url},
                name => $session{form}{name},
		sequenceNumber=>$session{form}{sequenceNumber}
                });
        if ($session{form}{proceed} eq "addLink") {
		$session{form}{lid} = "new";
                return $_[0]->www_editLink();
        } else {
                return "";
        }
}

#-------------------------------------------------------------------
sub www_moveLinkDown {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        $_[0]->moveCollateralDown("LinkList_link","LinkList_linkId",$session{form}{lid});
	return "";
}

#-------------------------------------------------------------------
sub www_moveLinkUp {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        $_[0]->moveCollateralUp("LinkList_link","LinkList_linkId",$session{form}{lid});
	return "";
}

#-------------------------------------------------------------------
sub www_view {
	my (%var, @linkloop, $controls, $link, $sth);
	$var{"addlink.url"} = WebGUI::URL::page('func=editLink&lid=new&wid='.$_[0]->get("wobjectId"));
	$var{"addlink.label"} = WebGUI::International::get(13,$namespace);
	$sth = WebGUI::SQL->read("select * from LinkList_link where wobjectId=".$_[0]->get("wobjectId")." 
		order by sequenceNumber");
	while ($link = $sth->hashRef) {
		$controls = deleteIcon('func=deleteLink&wid='.$_[0]->get("wobjectId").'&lid='.$link->{LinkList_linkId})
			.editIcon('func=editLink&wid='.$_[0]->get("wobjectId").'&lid='.$link->{LinkList_linkId})
			.moveUpIcon('func=moveLinkUp&wid='.$_[0]->get("wobjectId").'&lid='.$link->{LinkList_linkId})
			.moveDownIcon('func=moveLinkDown&wid='.$_[0]->get("wobjectId").'&lid='.$link->{LinkList_linkId});
		push(@linkloop, {
			"link.url"=>$link->{url},
			"link.controls"=>$controls,
			"link.newWindow"=>$link->{newWindow},
			"link.name"=>$link->{name},
			"link.description"=>$link->{description}
			});
	}
	$sth->finish;
	$var{link_loop} = \@linkloop;
	return $_[0]->processMacros($_[0]->processTemplate($_[0]->get("templateId"),\%var));
}


1;

