package WebGUI::Widget::LinkList;

our $namespace = "LinkList";

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
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _reorderLinks {
        my ($sth, $i, $lid);
        $sth = WebGUI::SQL->read("select linkId from LinkList_link where widgetId=$_[0] order by sequenceNumber");
        while (($lid) = $sth->array) {
                WebGUI::SQL->write("update LinkList_link set sequenceNumber='$i' where linkId=$lid");
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($sth, %data, $newWidgetId, $pageId, @row, $newLinkId);
        tie %data, 'Tie::CPHash';
        %data = getProperties($namespace,$_[0]);
	$pageId = $_[1] || $data{pageId};
        $newWidgetId = create($pageId,$namespace,$data{title},$data{displayTitle},$data{description},$data{processMacros},$data{position});
	WebGUI::SQL->write("insert into LinkList values ($newWidgetId, '$data{indent}', '$data{lineSpacing}', ".quote($data{bullet}).")");
        $sth = WebGUI::SQL->read("select * from LinkList_link");
        while (@row = $sth->array) {
                $newLinkId = getNextId("linkId");
                WebGUI::SQL->write("insert into LinkList_link values ($newWidgetId, $newLinkId, ".quote($row[2]).", ".quote($row[3]).", ".quote($row[4]).", '$row[5]', '$row[6]')");
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from LinkList_link where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1],$namespace);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(6,$namespace);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
	tie %hash, 'Tie::IxHash';
      	if (WebGUI::Privilege::canEditPage()) {
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(11,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,128,'Link List'));
                $output .= tableFormRow(WebGUI::International::get(174),WebGUI::Form::checkbox("displayTitle",1,1));
                $output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros",1));
		%hash = WebGUI::Widget::getPositions();
                $output .= tableFormRow(WebGUI::International::get(363),WebGUI::Form::selectList("position",\%hash));
                $output .= tableFormRow(WebGUI::International::get(85),WebGUI::Form::textArea("description",'',50,5,1));
                $output .= tableFormRow(WebGUI::International::get(1,$namespace),WebGUI::Form::text("indent",20,2,0));
                $output .= tableFormRow(WebGUI::International::get(2,$namespace),WebGUI::Form::text("lineSpacing",20,1,1));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),WebGUI::Form::text("bullet",20,255,'&middot;'));
                $output .= tableFormRow(WebGUI::International::get(5,$namespace),WebGUI::Form::checkbox("proceed",1,1));
                $output .= formSave();
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
	return $output;
}

#-------------------------------------------------------------------
sub www_addSave {
	my ($widgetId);
	if (WebGUI::Privilege::canEditPage()) {
		$widgetId = create($session{page}{pageId},$session{form}{widget},$session{form}{title},$session{form}{displayTitle},$session{form}{description},$session{form}{processMacros},$session{form}{position});
		WebGUI::SQL->write("insert into LinkList values ($widgetId, '$session{form}{indent}', '$session{form}{lineSpacing}', ".quote($session{form}{bullet}).")");
                if ($session{form}{proceed} == 1) {
                        $session{form}{wid} = $widgetId;
                        return www_addLink();
                } else {
                        return "";
                }
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_addLink {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
                $output = '<h1>'.WebGUI::International::get(7,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addLinkSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("name",20,128));
                $output .= tableFormRow(WebGUI::International::get(8,$namespace),WebGUI::Form::text("url",20,1024));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),WebGUI::Form::checkbox("newWindow",1,1));
                $output .= tableFormRow(WebGUI::International::get(85),WebGUI::Form::textArea("description",'',50,10));
                $output .= formSave();
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addLinkSave {
        my ($linkId, $nextSeq);
        if (WebGUI::Privilege::canEditPage()) {
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from LinkList_link where widgetId=$session{form}{wid}");
                $linkId = getNextId("linkId");
                WebGUI::SQL->write("insert into LinkList_link values ($session{form}{wid}, $linkId, ".quote($session{form}{name}).", ".quote($session{form}{url}).", ".quote($session{form}{description}).", '$nextSeq', '$session{form}{newWindow}')");
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_copy {
        if (WebGUI::Privilege::canEditPage()) {
                duplicate($session{form}{wid});
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
		$output .= '<div align="center"><a href="'.$session{page}{url}.'?func=deleteLinkConfirm&wid='.$session{form}{wid}.'&lid='.$session{form}{lid}.'">'.WebGUI::International::get(44).'</a>';
		$output .= ' &nbsp; <a href="'.$session{page}{url}.'?func=edit&wid='.$session{form}{wid}.'">'.WebGUI::International::get(45).'</a></div>';
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
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %hash, @array, %data, @link, $sth);
	tie %data, 'Tie::CPHash';
	tie %hash, 'Tie::IxHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = getProperties($namespace,$session{form}{wid});
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(10,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,128,$data{title}));
                $output .= tableFormRow(WebGUI::International::get(174),WebGUI::Form::checkbox("displayTitle",1,$data{displayTitle}));
                $output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros",1,$data{processMacros}));
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{position};
                $output .= tableFormRow(WebGUI::International::get(363),WebGUI::Form::selectList("position",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(85),WebGUI::Form::textArea("description",$data{description},50,5,1));
                $output .= tableFormRow(WebGUI::International::get(1,$namespace),WebGUI::Form::text("indent",20,2,$data{indent}));
                $output .= tableFormRow(WebGUI::International::get(2,$namespace),WebGUI::Form::text("lineSpacing",20,1,$data{lineSpacing}));
                $output .= tableFormRow(WebGUI::International::get(4,$namespace),WebGUI::Form::text("bullet",20,255,$data{bullet}));
                $output .= formSave();
                $output .= '</table></form>';
                $output .= '<p><a href="'.$session{page}{url}.'?func=addLink&wid='.$session{form}{wid}.'">'.WebGUI::International::get(13,$namespace).'</a><p>';
                $output .= '<table border=1 cellpadding=3 cellspacing=0>';
		$sth = WebGUI::SQL->read("select linkId, name from LinkList_link where widgetId='$session{form}{wid}' order by sequenceNumber");
		while (@link = $sth->array) {
                	$output .= '<tr><td><a href="'.$session{page}{url}.'?func=editLink&wid='.$session{form}{wid}.'&lid='.$link[0].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a><a href="'.$session{page}{url}.'?func=deleteLink&wid='.$session{form}{wid}.'&lid='.$link[0].'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a><a href="'.$session{page}{url}.'?func=moveLinkUp&wid='.$session{form}{wid}.'&lid='.$link[0].'"><img src="'.$session{setting}{lib}.'/upArrow.gif" border=0></a><a href="'.$session{page}{url}.'?func=moveLinkDown&wid='.$session{form}{wid}.'&lid='.$link[0].'"><img src="'.$session{setting}{lib}.'/downArrow.gif" border=0></a></td><td>'.$link[1].'</td></tr>';
		}
		$sth->finish;
                $output .= '</table>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editSave {
        if (WebGUI::Privilege::canEditPage()) {
		update();
		WebGUI::SQL->write("update LinkList set indent='$session{form}{indent}', lineSpacing='$session{form}{lineSpacing}', bullet=".quote($session{form}{bullet})." where widgetId=$session{form}{wid}");
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editLink {
        my ($output, %link);
	tie %link, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
                %link = WebGUI::SQL->quickHash("select * from LinkList_link where linkId='$session{form}{lid}'");
                $output = '<h1>'.WebGUI::International::get(12,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("lid",$session{form}{lid});
                $output .= WebGUI::Form::hidden("func","editLinkSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("name",20,128,$link{name}));
                $output .= tableFormRow(WebGUI::International::get(8,$namespace),WebGUI::Form::text("url",20,2048,$link{url}));
                $output .= tableFormRow(WebGUI::International::get(3,$namespace),WebGUI::Form::checkbox("newWindow",1,$link{newWindow}));
                $output .= tableFormRow(WebGUI::International::get(85),WebGUI::Form::textArea("description",$link{description},50,10));
                $output .= formSave();
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editLinkSave {
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update LinkList_link set name=".quote($session{form}{name}).", url=".quote($session{form}{url}).", description=".quote($session{form}{description}).", newWindow='$session{form}{newWindow}' where linkId=$session{form}{lid}");
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveLinkDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from LinkList_link where linkId=$session{form}{lid}");
                @data = WebGUI::SQL->quickArray("select linkId from LinkList_link where widgetId=$session{form}{wid} and sequenceNumber=$thisSeq+1 group by widgetId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber+1 where linkId=$session{form}{lid}");
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber-1 where linkId=$data[0]");
                }
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveLinkUp {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from LinkList_link where linkId=$session{form}{lid}");
                @data = WebGUI::SQL->quickArray("select linkId from LinkList_link where widgetId=$session{form}{wid} and sequenceNumber=$thisSeq-1 group by widgetId");
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber-1 where linkId=$session{form}{lid}");
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber+1 where linkId=$data[0]");
                }
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, $i, $indent, $lineSpacing, @link, $output, $sth);
	tie %data, 'Tie::CPHash';
	%data = getProperties($namespace,$_[0]);
	if (defined %data) {
		if ($data{displayTitle}) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description}.'<p>';
		}
		for ($i=0;$i<$data{indent};$i++) {
			$indent .= "&nbsp;";
		}
                for ($i=0;$i<$data{lineSpacing};$i++) {
                        $lineSpacing .= "<br>";
                }
		$sth = WebGUI::SQL->read("select name, url, description, newWindow from LinkList_link where widgetId='$_[0]' order by sequenceNumber");
		while (@link = $sth->array) {
			$output .= $indent.$data{bullet}.'<a href="'.$link[1].'"';
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
                if ($data{processMacros}) {
                        $output = WebGUI::Macro::process($output);
                }
	}
	return $output;
}







1;
