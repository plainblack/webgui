package WebGUI::Widget::LinkList;

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
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _reorderLinks {
        my ($sth, $i, $lid);
        $sth = WebGUI::SQL->read("select linkId from link where widgetId=$_[0] order by sequenceNumber",$session{dbh});
        while (($lid) = $sth->array) {
                WebGUI::SQL->write("update link set sequenceNumber='$i' where linkId=$lid",$session{dbh});
                $i++;
        }
        $sth->finish;
}

#-------------------------------------------------------------------
sub widgetName {
	return "Link List";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<h1>Add Link List</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","LinkList");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle","1").'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
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
		return "";
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_addLink {
        my ($output, $today);
        if (WebGUI::Privilege::canEditPage()) {
		($today) = WebGUI::SQL->quickArray("select date_format(date_add(now(), interval 1 day),'%m/%d/%Y')",$session{dbh});
                $output = '<h1>Add Link</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addLinkSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Name</td><td>'.WebGUI::Form::text("name",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">URL</td><td>'.WebGUI::Form::text("url",20,1024).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",'',50,10).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
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
		($nextSeq) = WebGUI::SQL->quickArray("select max(sequenceNumber)+1 from link where widgetId=$session{form}{wid}",$session{dbh});
                $linkId = getNextId("linkId");
                WebGUI::SQL->write("insert into link set widgetId=$session{form}{wid}, linkId=$linkId, name=".quote($session{form}{name}).", sequenceNumber='$nextSeq', url=".quote($session{form}{url}).", description=".quote($session{form}{description}),$session{dbh});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteLink {
	my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		$output = '<h1>Please Confirm</h1>';
		$output = 'Are you certain that you want to delete this link?<p><div align="center"><a href="'.$session{page}{url}.'?func=deleteLinkConfirm&wid='.$session{form}{wid}.'&lid='.$session{form}{lid}.'">Yes, I\'m sure.</a> &nbsp; <a href="'.$session{page}{url}.'?func=edit&wid='.$session{form}{wid}.'">No, I made a mistake.</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteLinkConfirm {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("delete from link where linkId=$session{form}{lid}",$session{dbh});
		_reorderLinks($session{form}{wid});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data, @link, $sth);
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select widget.title, widget.displayTitle from widget where widget.widgetId=$session{form}{wid}",$session{dbh});
                $output = '<h1>Edit Link List</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle","1",$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                $output .= '<p><a href="'.$session{page}{url}.'?func=addLink&wid='.$session{form}{wid}.'">Add New Link</a><p>';
                $output .= '<table border=1 cellpadding=3 cellspacing=0>';
		$sth = WebGUI::SQL->read("select linkId, name from link where widgetId='$session{form}{wid}' order by sequenceNumber",$session{dbh});
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
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_editLink {
        my ($output, %link);
        if (WebGUI::Privilege::canEditPage()) {
                %link = WebGUI::SQL->quickHash("select name, url, description from link where linkId='$session{form}{lid}'",$session{dbh});
                $output = '<h1>Edit Link</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("lid",$session{form}{lid});
                $output .= WebGUI::Form::hidden("func","editEventSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Name</td><td>'.WebGUI::Form::text("name",20,30,$link{name}).'</td></tr>';
                $output .= '<tr><td class="formDescription">URL</td><td>'.WebGUI::Form::text("url",20,2048,$link{url}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",$link{description},50,10).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
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
                WebGUI::SQL->write("update link set name=".quote($session{form}{name}).", url=".quote($session{form}{url}).", description=".quote($session{form}{description})." where linkId=$session{form}{lid}",$session{dbh});
                return "";
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_moveLinkDown {
        my (@data, $thisSeq);
        if (WebGUI::Privilege::canEditPage()) {
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from link where linkId=$session{form}{lid}",$session{dbh});
                @data = WebGUI::SQL->quickArray("select linkId, min(sequenceNumber) from link where widgetId=$session{form}{wid} and sequenceNumber>$thisSeq group by widgetId",$session{dbh});
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update link set sequenceNumber=sequenceNumber+1 where linkId=$session{form}{lid}",$session{dbh});
                        WebGUI::SQL->write("update link set sequenceNumber=sequenceNumber-1 where linkId=$data[0]",$session{dbh});
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
                ($thisSeq) = WebGUI::SQL->quickArray("select sequenceNumber from link where linkId=$session{form}{lid}",$session{dbh});
                @data = WebGUI::SQL->quickArray("select linkId, max(sequenceNumber) from link where widgetId=$session{form}{wid} and sequenceNumber<$thisSeq group by widgetId",$session{dbh});
                if ($data[0] ne "") {
                        WebGUI::SQL->write("update link set sequenceNumber=sequenceNumber-1 where linkId=$session{form}{lid}",$session{dbh});
                        WebGUI::SQL->write("update link set sequenceNumber=sequenceNumber+1 where linkId=$data[0]",$session{dbh});
                }
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @link, $output, $widgetId, $sth);
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select widget.title, widget.displayTitle from widget where widget.widgetId='$widgetId'",$session{dbh});
	if (defined %data) {
		if ($data{displayTitle} == 1) {
			$output = "<h2>".$data{title}."</h2>";
		}
		$sth = WebGUI::SQL->read("select name, url, description from link where widgetId='$widgetId' order by sequenceNumber",$session{dbh});
		while (@link = $sth->array) {
			$output .= '<li><b><a href="'.$link[1].'">'.$link[0].'</a></b>';
			if ($link[2] ne "") {
				$output .= ' - '.$link[2];
			}
			$output .= '<br>';
		}
		$sth->finish;
	}
	return $output;
}







1;
