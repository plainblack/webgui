package WebGUI::Widget::EventsCalendar;

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
use WebGUI::Macro;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from event where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1]);
}

#-------------------------------------------------------------------
sub widgetName {
	return "Events Calendar";
}

#-------------------------------------------------------------------
sub www_add {
        my ($output);
      	if (WebGUI::Privilege::canEditPage()) {
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=38"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Add Events Calendar</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("widget","EventsCalendar");
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,'Events Calendar').'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle",1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Process macros?</td><td>'.WebGUI::Form::checkbox("processMacros",1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description").'</td></tr>';
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
sub www_addEvent {
        my ($output, $today);
        if (WebGUI::Privilege::canEditPage()) {
		($today) = WebGUI::SQL->quickArray("select date_format(date_add(now(), interval 1 day),'%m/%d/%Y')",$session{dbh});
                $output = '<h1>Add Event</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addEventSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Name</td><td>'.WebGUI::Form::text("name",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",'',50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Start Date</td><td>'.WebGUI::Form::text("startDate",20,30,$today,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">End Date</td><td>'.WebGUI::Form::text("endDate",20,30,$today,1).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_addEventSave {
        my ($eventId);
        if (WebGUI::Privilege::canEditPage()) {
                $eventId = getNextId("eventId");
                WebGUI::SQL->write("insert into event set widgetId=$session{form}{wid}, eventId=$eventId, name=".quote($session{form}{name}).", description=".quote($session{form}{description}).", startDate='".humanToMysqlDate($session{form}{startDate})."', endDate='".humanToMysqlDate($session{form}{endDate})."'",$session{dbh});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteEvent {
	my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		$output = '<h1>Please Confirm</h1>';
		$output = 'Are you certain that you want to delete this event?<p><div align="center"><a href="'.$session{page}{url}.'?func=deleteEventConfirm&wid='.$session{form}{wid}.'&eid='.$session{form}{eid}.'">Yes, I\'m sure.</a> &nbsp; <a href="'.$session{page}{url}.'?func=edit&wid='.$session{form}{wid}.'">No, I made a mistake.</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteEventConfirm {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		WebGUI::SQL->write("delete from event where eventId=$session{form}{eid}",$session{dbh});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data, @event, $sth);
        if (WebGUI::Privilege::canEditPage()) {
		%data = WebGUI::SQL->quickHash("select * from widget where widget.widgetId=$session{form}{wid}",$session{dbh});
                $output = '<a href="'.$session{page}{url}.'?op=viewHelp&hid=39"><img src="'.$session{setting}{lib}.'/help.gif" border="0" align="right"></a><h1>Edit Events Calendar</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Title</td><td>'.WebGUI::Form::text("title",20,30,$data{title}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Display the title?</td><td>'.WebGUI::Form::checkbox("displayTitle",1,$data{displayTitle}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Process macros?</td><td>'.WebGUI::Form::checkbox("processMacros",1,$data{processMacros}).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",$data{description}).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                $output .= '<p><a href="'.$session{page}{url}.'?func=addEvent&wid='.$session{form}{wid}.'">Add New Event</a><p>';
                $output .= '<table border=1 cellpadding=3 cellspacing=0>';
		$sth = WebGUI::SQL->read("select eventId, name from event where widgetId='$session{form}{wid}' order by startDate",$session{dbh});
		while (@event = $sth->array) {
                	$output .= '<tr><td><a href="'.$session{page}{url}.'?func=editEvent&wid='.$session{form}{wid}.'&eid='.$event[0].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a><a href="'.$session{page}{url}.'?func=deleteEvent&wid='.$session{form}{wid}.'&eid='.$event[0].'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a></td><td>'.$event[1].'</td></tr>';
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
sub www_editEvent {
        my ($output, %event);
        if (WebGUI::Privilege::canEditPage()) {
                %event = WebGUI::SQL->quickHash("select name, description, date_format(startDate,'%m/%d/%Y') as start, date_format(endDate,'%m/%d/%Y') as end from event where eventId='$session{form}{eid}'",$session{dbh});
                $output = '<h1>Edit Event</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("eid",$session{form}{eid});
                $output .= WebGUI::Form::hidden("func","editEventSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Name</td><td>'.WebGUI::Form::text("name",20,30,$event{name}).'</td></tr>'
;
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",$event{description},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Start Date</td><td>'.WebGUI::Form::text("startDate",20,30,$event{start},1).'</td></tr>';
                $output .= '<tr><td class="formDescription">End Date</td><td>'.WebGUI::Form::text("endDate",20,30,$event{end},1).'</td></tr>';
                $output .= '<tr><td></td><td>'.WebGUI::Form::submit("save").'</td></tr>';
                $output .= '</table></form>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
        return $output;
}

#-------------------------------------------------------------------
sub www_editEventSave {
        my ($eventId);
        if (WebGUI::Privilege::canEditPage()) {
                WebGUI::SQL->write("update event set name=".quote($session{form}{name}).", description=".quote($session{form}{description}).", startDate='".humanToMysqlDate($session{form}{startDate})."', endDate='".humanToMysqlDate($session{form}{endDate})."' where eventId=$session{form}{eid}",$session{dbh});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @event, $output, $widgetId, $sth);
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from widget where widget.widgetId='$widgetId'",$session{dbh});
	if (defined %data) {
		if ($data{displayTitle}) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description}.'<p>';
		}
		$sth = WebGUI::SQL->read("select name, description, date_format(startDate,'%M'), date_format(startDate,'%e'), date_format(startDate,'%Y'), date_format(endDate,'%e') from event where widgetId='$widgetId' and to_days(startDate)>(to_days(now())-1) order by startDate",$session{dbh});
		while (@event = $sth->array) {
			$output .= "<b>$event[2] $event[3]";
			if ($event[3] ne $event[5]) {
				$output .= "-$event[5]";
			}
			$output .= ", $event[4]</b>";
			$output .= "<hr size=1>";
			$output .= '<span class="eventTitle">'.$event[0].'</span>';
			if ($event[1] ne "") {
				$output .= ' - ';
				$output .= ''.$event[1];
			}
			$output .= '<p>';
		}
		$sth->finish;
		if ($data{processMacros}) {
			$output = WebGUI::Macro::process($output);
		}
	}
	return $output;
}







1;
