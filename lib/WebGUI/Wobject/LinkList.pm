package WebGUI::Wobject::LinkList;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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
sub _reorderLinks {
        my ($sth, $i, $lid);
        $sth = WebGUI::SQL->read("select linkId from LinkList_link where wobjectId=$_[0] order by sequenceNumber");
        while (($lid) = $sth->array) {
                WebGUI::SQL->write("update LinkList_link set sequenceNumber='$i' where linkId=$lid");
                $i++;
        }
        $sth->finish;
}

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
                $newLinkId = getNextId("linkId");
                WebGUI::SQL->write("insert into LinkList_link values (".$w->get("wobjectId").", $newLinkId, "
			.quote($row[2]).", ".quote($row[3]).", ".quote($row[4]).", '$row[5]', '$row[6]')");
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
        WebGUI::SQL->write("delete from LinkList_link where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(indent bullet lineSpacing)]);
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
sub www_deleteLink {
	my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		$output = '<h1>'.WebGUI::International::get(42).'</h1>';
		$output .= WebGUI::International::get(9,$namespace).'<p>';
		$output .= '<div align="center"><a href="'.
			WebGUI::URL::page('func=deleteLinkConfirm&wid='.$session{form}{wid}.'&lid='.$session{form}{lid})
			.'">'.WebGUI::International::get(44).'</a>';
		$output .= ' &nbsp; <a href="'.WebGUI::URL::page('func=edit&wid='.$session{form}{wid})
			.'">'.WebGUI::International::get(45).'</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteLinkConfirm {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("delete from LinkList_link where linkId=$session{form}{lid}");
		_reorderLinks($session{form}{wid});
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($proceed, $f, $output, @link, $sth, $indent, $lineSpacing, $bullet);
        if (WebGUI::Privilege::canEditPage()) {
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
		unless ($_[0]->get("wobjectId") eq "new") {
                	$output .= '<p><a href="'.WebGUI::URL::page('func=editLink&lid=new&wid='.$_[0]->get("wobjectId"))
				.'">'.WebGUI::International::get(13,$namespace).'</a><p>';
			$sth = WebGUI::SQL->read("select linkId, name from LinkList_link where wobjectId='$session{form}{wid}' order by sequenceNumber");
			while (@link = $sth->array) {
                		$output .= '<p>'
					.deleteIcon('func=deleteLink&wid='.$session{form}{wid}.'&lid='.$link[0])
					.editIcon('func=editLink&wid='.$session{form}{wid}.'&lid='.$link[0])
					.moveUpIcon('func=moveLinkUp&wid='.$session{form}{wid}.'&lid='.$link[0])
					.moveDownIcon('func=moveLinkDown&wid='.$session{form}{wid}.'&lid='.$link[0])
					.' '.$link[1].'<br>';
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
        if (WebGUI::Privilege::canEditPage()) {
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
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editLink {
        my ($output, %link, $f, $linkId, $newWindow);
	tie %link, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		$linkId = $session{form}{lid} || "new";
                %link = WebGUI::SQL->quickHash("select * from LinkList_link where linkId='$session{form}{lid}'");
	        if ($linkId eq "new") {
        	        $newWindow = 1;
	        } else {
        	        $newWindow = $link{newWindow};
        	}
                $output = '<h1>'.WebGUI::International::get(12,$namespace).'</h1>';
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
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editLinkSave {
	my ($seq);
        if (WebGUI::Privilege::canEditPage()) {
		if ($session{form}{lid} eq "new") {
			($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from LinkList_link where wobjectId=".$_[0]->get("wobjectId"));
			$session{form}{lid} = getNextId("linkId");
                	WebGUI::SQL->write("insert into LinkList_link (wobjectId,linkId,sequenceNumber) values (".$_[0]->get("wobjectId")
				.",$session{form}{lid},".($seq+1).")");
		}
                WebGUI::SQL->write("update LinkList_link set name=".quote($session{form}{name}).",
			url=".quote($session{form}{url}).",description=".quote($session{form}{description}).",
			newWindow='$session{form}{newWindow}' where linkId=$session{form}{lid}");
                if ($session{form}{proceed}) {
			$session{form}{lid} = "new";
                        $_[0]->www_editLink();
                } else {
                        return $_[0]->www_edit();
                }
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveLinkDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from LinkList_link where linkId=$session{form}{lid}");
                @data = WebGUI::SQL->quickArray("select linkId from LinkList_link where wobjectId=$session{form}{wid} and sequenceNumber=$thisSeq+1 group by wobjectId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber+1 where linkId=$session{form}{lid}");
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber-1 where linkId=$data[0]");
                }
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveLinkUp {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from LinkList_link where linkId=$session{form}{lid}");
                @data = WebGUI::SQL->quickArray("select linkId from LinkList_link where wobjectId=$session{form}{wid} and sequenceNumber=$thisSeq-1 group by wobjectId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber-1 where linkId=$session{form}{lid}");
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber+1 where linkId=$data[0]");
                }
                return $_[0]->www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my ($i, $indent, $lineSpacing, @link, $output, $sth);
        $output = $_[0]->displayTitle;
        $output .= $_[0]->description;
	for ($i=0;$i<$_[0]->get("indent");$i++) {
		$indent .= "&nbsp;";
	}
        for ($i=0;$i<$_[0]->get("lineSpacing");$i++) {
                $lineSpacing .= "<br>";
        }
	$sth = WebGUI::SQL->read("select name, url, description, newWindow from LinkList_link where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
	while (@link = $sth->array) {
		$output .= $indent.$_[0]->get("bullet").'<a href="'.$link[1].'"';
		if ($link[3]) {
			$output .= ' target="_blank"';
		}
		$output .= '><span class="linkTitle">'.$link[0].'</span></a>';
		if ($link[2] ne "") {
			$output .= ' - '.$link[2];
		}
		$output .= $lineSpacing;
	}
	$sth->finish;
	return $_[0]->processMacros($output);
}




1;

