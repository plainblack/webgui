package WebGUI::Widget::LinkList;

our $namespace = "LinkList";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
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
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _reorderLinks {
        my ($sth, $i, $lid);
        $sth = WebGUI::SQL->read("select linkId from LinkList_link where widgetId=$_[0] order by sequenceNumber",$session{dbh});
        while (($lid) = $sth->array) {
                WebGUI::SQL->write("update LinkList_link set sequenceNumber='$i' where linkId=$lid",$session{dbh});
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from LinkList where widgetId=$_[0]",$_[1]);
        WebGUI::SQL->write("delete from LinkList_link where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(214);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
	tie %hash, 'Tie::IxHash';
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(219).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128,'Link List').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",'',50,5,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(1,$namespace).'</td><td>'.WebGUI::Form::text("indent",20,2,0).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(2,$namespace).'</td><td>'.WebGUI::Form::text("lineSpacing",20,1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(4,$namespace).'</td><td>'.WebGUI::Form::text("bullet",20,255,'&middot;').'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(5,$namespace).'</td><td>'.WebGUI::Form::checkbox("proceed",1,1).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
		$widgetId = create();
		WebGUI::SQL->write("insert into LinkList values ($widgetId, '$session{form}{indent}', '$session{form}{lineSpacing}', ".quote($session{form}{bullet}).")",$session{dbh});
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
                $output = '<h1>'.WebGUI::International::get(215).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addLinkSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("name",20,128).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(216).'</td><td>'.WebGUI::Form::text("url",20,1024).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(3,$namespace).'</td><td>'.WebGUI::Form::checkbox("newWindow",1,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",'',50,10).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from LinkList_link where widgetId=$session{form}{wid}",$session{dbh});
                $linkId = getNextId("linkId");
                WebGUI::SQL->write("insert into LinkList_link values ($session{form}{wid}, $linkId, ".quote($session{form}{name}).", ".quote($session{form}{url}).", ".quote($session{form}{description}).", '$nextSeq', '$session{form}{newWindow}')",$session{dbh});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteLink {
	my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		$output = '<h1>'.WebGUI::International::get(42).'</h1>';
		$output .= WebGUI::International::get(217).'<p>';
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
		WebGUI::SQL->write("delete from LinkList_link where linkId=$session{form}{lid}",$session{dbh});
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
		%data = WebGUI::SQL->quickHash("select * from widget,LinkList where widget.widgetId=$session{form}{wid} and widget.widgetId=LinkList.widgetId",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=1&namespace='.$namespace.'"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a>';
		$output .= '<h1>'.WebGUI::International::get(218).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("title",20,128,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(174).'</td><td>'.WebGUI::Form::checkbox("displayTitle",1,$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(175).'</td><td>'.WebGUI::Form::checkbox("processMacros",1,$data{processMacros}).'</td></tr>';
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{position};
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(363).'</td><td>'.WebGUI::Form::selectList("position",\%hash,\@array).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",$data{description},50,5,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(1,$namespace).'</td><td>'.WebGUI::Form::text("indent",20,2,$data{indent}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(2,$namespace).'</td><td>'.WebGUI::Form::text("lineSpacing",20,1,$data{lineSpacing}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(4,$namespace).'</td><td>'.WebGUI::Form::text("bullet",20,255,$data{bullet}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
                $output .= '</table></form>';
                $output .= '<p><a href="'.$session{page}{url}.'?func=addLink&wid='.$session{form}{wid}.'">'.WebGUI::International::get(221).'</a><p>';
                $output .= '<table border=1 cellpadding=3 cellspacing=0>';
		$sth = WebGUI::SQL->read("select linkId, name from LinkList_link where widgetId='$session{form}{wid}' order by sequenceNumber",$session{dbh});
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
		WebGUI::SQL->write("update LinkList set indent='$session{form}{indent}', lineSpacing='$session{form}{lineSpacing}', bullet=".quote($session{form}{bullet})." where widgetId=$session{form}{wid}",$session{dbh});
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
                %link = WebGUI::SQL->quickHash("select * from LinkList_link where linkId='$session{form}{lid}'",$session{dbh});
                $output = '<h1>'.WebGUI::International::get(220).'</h1>';
		$output .= '<form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("lid",$session{form}{lid});
                $output .= WebGUI::Form::hidden("func","editLinkSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(99).'</td><td>'.WebGUI::Form::text("name",20,128,$link{name}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(216).'</td><td>'.WebGUI::Form::text("url",20,2048,$link{url}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(3,$namespace).'</td><td>'.WebGUI::Form::checkbox("newWindow",1,$link{newWindow}).'</td></tr>';
                $output .= '<tr><td class="formDescription">'.WebGUI::International::get(85).'</td><td>'.WebGUI::Form::textArea("description",$link{description},50,10).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit(WebGUI::International::get(62)).'</td></tr>';
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
                WebGUI::SQL->write("update LinkList_link set name=".quote($session{form}{name}).", url=".quote($session{form}{url}).", description=".quote($session{form}{description}).", newWindow='$session{form}{newWindow}' where linkId=$session{form}{lid}",$session{dbh});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveLinkDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from LinkList_link where linkId=$session{form}{lid}",$session{dbh});
                @data = WebGUI::SQL->quickArray("select linkId from LinkList_link where widgetId=$session{form}{wid} and sequenceNumber=$thisSeq+1 group by widgetId",$session{dbh});
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber+1 where linkId=$session{form}{lid}",$session{dbh});
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber-1 where linkId=$data[0]",$session{dbh});
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
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from LinkList_link where linkId=$session{form}{lid}",$session{dbh});
                @data = WebGUI::SQL->quickArray("select linkId from LinkList_link where widgetId=$session{form}{wid} and sequenceNumber=$thisSeq-1 group by widgetId",$session{dbh});
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber-1 where linkId=$session{form}{lid}",$session{dbh});
                        WebGUI::SQL->write("update LinkList_link set sequenceNumber=sequenceNumber+1 where linkId=$data[0]",$session{dbh});
                }
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, $i, $indent, $lineSpacing, @link, $output, $widgetId, $sth);
	tie %data, 'Tie::CPHash';
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from widget,LinkList where widget.widgetId='$widgetId' and widget.widgetId=LinkList.widgetId",$session{dbh});
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
		$sth = WebGUI::SQL->read("select name, url, description, newWindow from LinkList_link where widgetId='$widgetId' order by sequenceNumber",$session{dbh});
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
