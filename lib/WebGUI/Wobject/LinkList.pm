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
        my ($w, $sth, @row, $newLinkId);
	$w = $_[0]->SUPER::duplicate($_[1]);
	$w = WebGUI::Wobject::LinkList->new({wobjectId=>$w,namespace=>$namespace});
	$w->set({
		indent=>$_[0]->get("indent"),
		bullet=>$_[0]->get("bullet"),
		lineSpacing=>$_[0]->get("lineSpacing")
		});
        $sth = WebGUI::SQL->read("select * from LinkList_link where wobjectId=".$_[0]->get("wobjectId"));
        while (@row = $sth->array) {
                $newLinkId = getNextId("LinkList_linkId");
                WebGUI::SQL->write("insert into LinkList_link values (".$w->get("wobjectId").", $newLinkId, "
			.quote($row[2]).", ".quote($row[3]).", ".quote($row[4]).", '$row[5]', '$row[6]')");
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
        $_[0]->SUPER::set($_[1],[qw(indent bullet lineSpacing)]);
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
        $f->integer("indent",WebGUI::International::get(1,$namespace),$indent);
        $f->integer("lineSpacing",WebGUI::International::get(2,$namespace),$lineSpacing);
        $f->text("bullet",WebGUI::International::get(4,$namespace),$bullet);
	$f->yesNo("proceed",WebGUI::International::get(5,$namespace),$proceed);
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        $_[0]->SUPER::www_editSave();
	$_[0]->set({
		indent=>$session{form}{indent},
		bullet=>$session{form}{bullet},
		lineSpacing=>$session{form}{lineSpacing}
		});
        if ($session{form}{proceed}) {
                $_[0]->www_editLink();
        } else {
                return "";
        }
}

#-------------------------------------------------------------------
sub www_editLink {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, %link, $f, $linkId, $newWindow);
	tie %link, 'Tie::CPHash';
	$linkId = $session{form}{lid} || "new";
        %link = WebGUI::SQL->quickHash("select * from LinkList_link where LinkList_linkId='$session{form}{lid}'");
        if ($linkId eq "new") {
       	        $newWindow = 1;
        } else {
       	        $newWindow = $link{newWindow};
       	}
	$output = helpIcon(2,$namespace);
        $output .= '<h1>'.WebGUI::International::get(12,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
	$f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("lid",$linkId);
        $f->hidden("func","editLinkSave");
	$f->text("name",WebGUI::International::get(99),$link{name});
        $f->url("url",WebGUI::International::get(8,$namespace),$link{url});
        $f->yesNo("newWindow",WebGUI::International::get(3,$namespace),$newWindow);
        $f->textarea("description",WebGUI::International::get(85),$link{description});
	$f->yesNo("proceed",WebGUI::International::get(5,$namespace));
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
                name => $session{form}{name}
                });
        if ($session{form}{proceed}) {
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
	my ($i, $indent, $lineSpacing, %link, $output, $sth);
	tie %link,'Tie::CPHash';
        $output = $_[0]->displayTitle;
        $output .= $_[0]->description;
	if ($session{var}{adminOn}) {
		$output .= '<p><a href="'.WebGUI::URL::page('func=editLink&lid=new&wid='.$_[0]->get("wobjectId"))
			.'">'.WebGUI::International::get(13,$namespace).'</a><p>';
	}
	for ($i=0;$i<$_[0]->get("indent");$i++) {
		$indent .= "&nbsp;";
	}
        for ($i=0;$i<$_[0]->get("lineSpacing");$i++) {
                $lineSpacing .= "<br>";
        }
	$sth = WebGUI::SQL->read("select * from LinkList_link where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
	while (%link = $sth->hash) {
		if ($session{var}{adminOn}) {
			$output .= deleteIcon('func=deleteLink&wid='.$_[0]->get("wobjectId").'&lid='.$link{LinkList_linkId})
			.editIcon('func=editLink&wid='.$_[0]->get("wobjectId").'&lid='.$link{LinkList_linkId})
			.moveUpIcon('func=moveLinkUp&wid='.$_[0]->get("wobjectId").'&lid='.$link{LinkList_linkId})
			.moveDownIcon('func=moveLinkDown&wid='.$_[0]->get("wobjectId").'&lid='.$link{LinkList_linkId})
			.' ';
		} else {
			$output .= $indent.$_[0]->get("bullet");
		}
		$output .= '<a href="'.$link{url}.'"';
		if ($link{newWindow}) {
			$output .= ' target="_blank"';
		}
		$output .= '><span class="linkTitle">'.$link{name}.'</span></a>';
		if ($link{description} ne "") {
			$output .= ' - '.$link{description};
		}
		$output .= $lineSpacing;
	}
	$sth->finish;
	return $_[0]->processMacros($output);
}


1;

