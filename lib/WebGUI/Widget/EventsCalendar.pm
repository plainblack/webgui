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
use Tie::CPHash;
use WebGUI::DateTime;
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
        my ($output, $today, %recursEvery);
	tie %recursEvery, 'Tie::IxHash';
	%recursEvery = ('never'=>'Happens Only Once','day'=>'Day','week'=>'Week');
        if (WebGUI::Privilege::canEditPage()) {
		($today) = epochToSet(time());
                $output = '<h1>Add Event</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addEventSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Name</td><td>'.WebGUI::Form::text("name",20,30).'</td></tr>';
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",'',50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Start Date</td><td>'.WebGUI::Form::text("startDate",20,30,$today,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">End Date</td><td>'.WebGUI::Form::text("endDate",20,30,$today,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Recurs every</td><td>'.WebGUI::Form::selectList("recursEvery",\%recursEvery).' until '.WebGUI::Form::text("until",20,30,$today,1).'</td></tr>';
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
        my ($i, $recurringEventId, @startDate, @endDate, @eventId, $until);
        if (WebGUI::Privilege::canEditPage()) {
		$startDate[0] = setToEpoch($session{form}{startDate});
		$endDate[0] = setToEpoch($session{form}{endDate});
		$until = setToEpoch($session{form}{until});
                $eventId[0] = getNextId("eventId");
		if ($session{form}{recursEvery} eq "never") {
			$recurringEventId = 0;
		} elsif ($session{form}{recursEvery} eq "day") {
			$recurringEventId = getNextId("recurringEventId");
			while ($startDate[$i] < $until) {
				$i++;
				$eventId[$i] = getNextId("eventId");
				$startDate[$i] = $startDate[0] + (86400 * $i);
				$endDate[$i] = $endDate[0] + (86400 * $i);
			}
		} elsif ($session{form}{recursEvery} eq "week") {
			$recurringEventId = getNextId("recurringEventId");
                        while ($startDate[$i] < $until) {
                                $i++;
                                $eventId[$i] = getNextId("eventId");
                                $startDate[$i] = $startDate[0] + (604800 * $i);
                                $endDate[$i] = $endDate[0] + (604800 * $i);
                        }
		}
		$i = 0;
		while ($eventId[$i] > 0) {
                	WebGUI::SQL->write("insert into event values ($eventId[$i], $session{form}{wid}, ".quote($session{form}{name}).", ".quote($session{form}{description}).", '".$startDate[$i]."', '".$endDate[$i]."', $recurringEventId)",$session{dbh});
			$i++;
		}
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
		$output .= 'Are you certain that you want to delete this event';
		if ($session{form}{rid} > 0) {
			$output .= ' <b>and</b> all of its recurring events';
		}
		$output .= '?<p><div align="center"><a href="'.$session{page}{url}.'?func=deleteEventConfirm&wid='.$session{form}{wid}.'&eid='.$session{form}{eid}.'&rid='.$session{form}{rid}.'">Yes, I\'m sure.</a> &nbsp; <a href="'.$session{page}{url}.'?func=edit&wid='.$session{form}{wid}.'">No, I made a mistake.</a></div>';
                return $output;
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_deleteEventConfirm {
        my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		if ($session{form}{rid} > 0) {
			WebGUI::SQL->write("delete from event where recurringEventId=$session{form}{rid}",$session{dbh});
		} else {
			WebGUI::SQL->write("delete from event where eventId=$session{form}{eid}",$session{dbh});
		}
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data, @event, $sth);
	tie %data, 'Tie::CPHash';
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
		$sth = WebGUI::SQL->read("select eventId, name, recurringEventId from event where widgetId='$session{form}{wid}' order by startDate",$session{dbh});
		while (@event = $sth->array) {
                	$output .= '<tr><td><a href="'.$session{page}{url}.'?func=editEvent&wid='.$session{form}{wid}.'&eid='.$event[0].'"><img src="'.$session{setting}{lib}.'/edit.gif" border=0></a><a href="'.$session{page}{url}.'?func=deleteEvent&wid='.$session{form}{wid}.'&eid='.$event[0].'&rid='.$event[2].'"><img src="'.$session{setting}{lib}.'/delete.gif" border=0></a></td><td>'.$event[1].'</td></tr>';
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
	tie %event, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
                %event = WebGUI::SQL->quickHash("select * from event where eventId='$session{form}{eid}'",$session{dbh});
                $output = '<h1>Edit Event</h1><form method="post" enctype="multipart/form-data" action="'.$session{page}{url}.'">';
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("eid",$session{form}{eid});
                $output .= WebGUI::Form::hidden("func","editEventSave");
                $output .= '<table>';
                $output .= '<tr><td class="formDescription">Name</td><td>'.WebGUI::Form::text("name",20,30,$event{name}).'</td></tr>'
;
                $output .= '<tr><td class="formDescription">Description</td><td>'.WebGUI::Form::textArea("description",$event{description},50,10,1).'</td></tr>';
                $output .= '<tr><td class="formDescription">Start Date</td><td>'.WebGUI::Form::text("startDate",20,30,epochToSet($event{startDate}),1).'</td></tr>';
                $output .= '<tr><td class="formDescription">End Date</td><td>'.WebGUI::Form::text("endDate",20,30,epochToSet($event{endDate}),1).'</td></tr>';
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
                WebGUI::SQL->write("update event set name=".quote($session{form}{name}).", description=".quote($session{form}{description}).", startDate='".setToEpoch($session{form}{startDate})."', endDate='".setToEpoch($session{form}{endDate})."' where eventId=$session{form}{eid}",$session{dbh});
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, @event, $output, $widgetId, $sth);
	tie %data, 'Tie::CPHash';
	$widgetId = shift;
	%data = WebGUI::SQL->quickHash("select * from widget where widget.widgetId='$widgetId'",$session{dbh});
	if (defined %data) {
		if ($data{displayTitle}) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description}.'<p>';
		}
		$sth = WebGUI::SQL->read("select name, description, startDate, endDate from event where widgetId='$widgetId' and startDate>".(time()-86400)." order by startDate",$session{dbh});
		while (@event = $sth->array) {
			$output .= "<b>".epochToHuman($event[2],"%c")." ".epochToHuman($event[2],"%D");
			if (epochToHuman($event[2],"%D") ne epochToHuman($event[3],"%D")) {
				$output .= "-".epochToHuman($event[3],"%D");
			}
			$output .= ", ".epochToHuman($event[2],"%y")."</b>";
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
