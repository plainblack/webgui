package WebGUI::Widget::EventsCalendar;

our $namespace = "EventsCalendar";

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
use HTML::CalendarMonthSimple;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::Macro;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::Shortcut;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Widget;

#-------------------------------------------------------------------
sub _calendarLayout {
	my ($thisMonth, $calendar, $message, $start, $end, $sth, %event, $nextDate); 
	tie %event, 'Tie::CPHash';
        $thisMonth = epochToHuman($_[1],"%M %y");
        $calendar = new HTML::CalendarMonthSimple('year'=>epochToHuman($_[1],"%y"),'month'=>epochToHuman($_[1],"%M"));
        $calendar->width("100%");
        $calendar->border(1);
        $calendar->cellclass("tableData");
        $calendar->todaycellclass("tableHeader");
        $calendar->headerclass("tableHeader");
        ($start,$end) = monthStartEnd($_[1]);
        $sth = WebGUI::SQL->read("select name, description, startDate, endDate from EventsCalendar_event where widgetId='$_[0]' order by startDate,endDate");
        while (%event = $sth->hash) {
        	if (epochToHuman($event{startDate},"%M %y") eq $thisMonth ||
                	epochToHuman($event{endDate},"%M %y") eq $thisMonth) {
			$message = $event{name};
			if ($event{description}) {
				$message = '<a href=\'javascript:popUp("'.$event{description}.'");\'>'.
					$message.'</a>';
			}
			$message .= '<br>';
                        if ($event{startDate} == $event{endDate}) {
                        	$calendar->addcontent(epochToHuman($event{startDate},"%D"),$message);
                        } else {
                                $nextDate = $event{startDate};
                                while($nextDate <= $event{endDate}) {
                                	if (epochToHuman($nextDate,"%M %y") eq $thisMonth) {
                                        	$calendar->addcontent(epochToHuman($nextDate,"%D"),$message);
                                        }
                                        $nextDate = addToDate($nextDate,0,0,1);
				}
                        }
                }
        }
        $sth->finish;
        return '<script language="JavaScript">function popUp(message) { alert(message); }</script>'.$calendar->as_HTML;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($sth, %data, $newWidgetId, $pageId, @row, $newEventId, $previousRecurringEventId);
        tie %data, 'Tie::CPHash';
        %data = getProperties($namespace,$_[0]);
	$pageId = $_[1] || $data{pageId};
        $newWidgetId = create($pageId,$namespace,$data{title},
		$data{displayTitle},$data{description},$data{processMacros},$data{templatePosition});
        WebGUI::SQL->write("insert into EventsCalendar values ($newWidgetId, '$data{calendarLayout}', '$data{paginateAfter}')");
	$sth = WebGUI::SQL->read("select * from EventsCalendar_event where widgetId=$_[0] order by recurringEventId");
	while (@row = $sth->array) {
		$newEventId = getNextId("eventId");
		if ($row[6] > 0 && $row[6] != $previousRecurringEventId) {
			$row[6] = getNextId("recurringEventId");
			$previousRecurringEventId = $row[6];
		}
               	WebGUI::SQL->write("insert into EventsCalendar_event values ($newEventId, $newWidgetId, ".
			quote($row[2]).", ".quote($row[3]).", '".$row[4].
			"', '".$row[5]."', $row[6])");
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from EventsCalendar_event where widgetId=$_[0]",$_[1]);
        purgeWidget($_[0],$_[1],$namespace);
}

#-------------------------------------------------------------------
sub widgetName {
	return WebGUI::International::get(2,$namespace);
}

#-------------------------------------------------------------------
sub www_add {
        my ($output, %hash);
	tie %hash, "Tie::IxHash";
      	if (WebGUI::Privilege::canEditPage()) {
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(3,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("widget",$namespace);
                $output .= WebGUI::Form::hidden("func","addSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),
			WebGUI::Form::text("title",20,128,'Events Calendar'));
                $output .= tableFormRow(WebGUI::International::get(174),WebGUI::Form::checkbox("displayTitle",1,1));
                $output .= tableFormRow(WebGUI::International::get(175),WebGUI::Form::checkbox("processMacros",1));
		%hash = WebGUI::Widget::getPositions();
                $output .= tableFormRow(WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash));
                $output .= tableFormRow(WebGUI::International::get(85),WebGUI::Form::textArea("description",'',50,5,1));
		%hash = (list => WebGUI::International::get(17,$namespace),
			calendar => WebGUI::International::get(18,$namespace));
                $output .= tableFormRow(WebGUI::International::get(16,$namespace),
			WebGUI::Form::selectList("calendarLayout",\%hash));
                $output .= tableFormRow(WebGUI::International::get(19,$namespace),
			WebGUI::Form::text("paginateAfter",20,30,50));
                $output .= tableFormRow(WebGUI::International::get(1,$namespace),WebGUI::Form::checkbox("proceed",1,1));
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
		$widgetId = create($session{page}{pageId},$session{form}{widget},
			$session{form}{title},$session{form}{displayTitle},$session{form}{description},
			$session{form}{processMacros},$session{form}{templatePosition});	
                WebGUI::SQL->write("insert into EventsCalendar values ($widgetId, '$session{form}{calendarLayout}', '$session{form}{paginateAfter}')");
                if ($session{form}{proceed} == 1) {
                        $session{form}{wid} = $widgetId;
                        return www_addEvent();
                } else {
                        return "";
                }
	} else {
		return WebGUI::Privilege::insufficient();
	}
}

#-------------------------------------------------------------------
sub www_addEvent {
        my ($output, $today, %recursEvery);
	tie %recursEvery, 'Tie::IxHash';
	%recursEvery = ('never'=>WebGUI::International::get(4,$namespace),
		'day'=>WebGUI::International::get(5,$namespace),
		'week'=>WebGUI::International::get(6,$namespace)
		);
        if (WebGUI::Privilege::canEditPage()) {
		($today) = epochToSet(time());
                $output = '<h1>'.WebGUI::International::get(7,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","addEventSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("name",20,128));
                $output .= tableFormRow(WebGUI::International::get(85),
			WebGUI::Form::textArea("description",'',50,10,1));
                $output .= tableFormRow(WebGUI::International::get(14,$namespace),
			WebGUI::Form::text("startDate",20,30,$today,1,'onBlur="this.form.endDate.value=this.form.startDate.value;this.form.until.value=this.form.startDate.value;"'));
                $output .= tableFormRow(WebGUI::International::get(15,$namespace),
			WebGUI::Form::text("endDate",20,30,$today,1));
                $output .= tableFormRow(WebGUI::International::get(8,$namespace),WebGUI::Form::selectList("recursEvery",\%recursEvery).' '.WebGUI::International::get(9,$namespace).' '.WebGUI::Form::text("until",20,30,$today,1));
                $output .= formSave();
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
                	WebGUI::SQL->write("insert into EventsCalendar_event values ($eventId[$i], $session{form}{wid}, ".quote($session{form}{name}).", ".quote($session{form}{description}).", '".$startDate[$i]."', '".$endDate[$i]."', $recurringEventId)");
			$i++;
		}
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
sub www_deleteEvent {
	my ($output);
        if (WebGUI::Privilege::canEditPage()) {
		$output = '<h1>'.WebGUI::International::get(42).'</h1>';
		$output .= WebGUI::International::get(10,$namespace);
		if ($session{form}{rid} > 0) {
			$output .= ' '.WebGUI::International::get(11,$namespace);
		}
		$output .= '?<p><div align="center"><a href="'.
			WebGUI::URL::page('func=deleteEventConfirm&wid='.$session{form}{wid}.
			'&eid='.$session{form}{eid}.'&rid='.$session{form}{rid}).'">'.
			WebGUI::International::get(44).'</a> &nbsp; <a href="'.
			WebGUI::URL::page('func=edit&wid='.$session{form}{wid}).'">'.
			WebGUI::International::get(45).'</a></div>';
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
			WebGUI::SQL->write("delete from EventsCalendar_event where recurringEventId=$session{form}{rid}");
		} else {
			WebGUI::SQL->write("delete from EventsCalendar_event where eventId=$session{form}{eid}");
		}
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_edit {
        my ($output, %data, @event, $sth, %hash, @array);
	tie %hash, 'Tie::IxHash';
	tie %data, 'Tie::CPHash';
        if (WebGUI::Privilege::canEditPage()) {
		%data = getProperties($namespace,$session{form}{wid});;
                $output = helpLink(1,$namespace);
		$output .= '<h1>'.WebGUI::International::get(12,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("func","editSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),WebGUI::Form::text("title",20,128,$data{title}));
                $output .= tableFormRow(WebGUI::International::get(174),
			WebGUI::Form::checkbox("displayTitle",1,$data{displayTitle}));
                $output .= tableFormRow(WebGUI::International::get(175),
			WebGUI::Form::checkbox("processMacros",1,$data{processMacros}));
                $output .= tableFormRow(WebGUI::International::get(85),
			WebGUI::Form::textArea("description",$data{description},50,5,1));
		%hash = WebGUI::Widget::getPositions();
                $array[0] = $data{templatePosition};
                $output .= tableFormRow(WebGUI::International::get(363),
			WebGUI::Form::selectList("templatePosition",\%hash,\@array));
                %hash = (list => WebGUI::International::get(17,$namespace),
                        calendar => WebGUI::International::get(18,$namespace));
		$array[0] = $data{calendarLayout};
                $output .= tableFormRow(WebGUI::International::get(16,$namespace),
                        WebGUI::Form::selectList("calendarLayout",\%hash,\@array));
                $output .= tableFormRow(WebGUI::International::get(19,$namespace),
                        WebGUI::Form::text("paginateAfter",20,30,$data{paginateAfter}));
                $output .= formSave();
                $output .= '</table></form>';
                $output .= '<p><a href="'.WebGUI::URL::page('func=addEvent&wid='.$session{form}{wid})
			.'">Add New Event</a><p>';
                $output .= '<table border=1 cellpadding=3 cellspacing=0>';
		$sth = WebGUI::SQL->read("select eventId, name, recurringEventId, startDate from EventsCalendar_event where widgetId='$session{form}{wid}' order by startDate");
		while (@event = $sth->array) {
                	$output .= '<tr><td><a href="'.WebGUI::URL::page('func=editEvent&wid='.$session{form}{wid}.
				'&eid='.$event[0]).'"><img src="'.$session{setting}{lib}.
				'/edit.gif" border=0></a><a href="'.WebGUI::URL::page('func=deleteEvent&wid='.
				$session{form}{wid}.'&eid='.$event[0].'&rid='.$event[2]).'"><img src="'.
				$session{setting}{lib}.'/delete.gif" border=0></a></td><td>'.
				epochToHuman($event[3],'%m/%d/%y').'</td><td>'.$event[1].'</td></td>';
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
		WebGUI::SQL->write("update EventsCalendar set calendarLayout='$session{form}{calendarLayout}', paginateAfter='$session{form}{paginateAfter}' where widgetId=$session{form}{wid}");
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
                %event = WebGUI::SQL->quickHash("select * from EventsCalendar_event where eventId='$session{form}{eid}'");
                $output = '<h1>'.WebGUI::International::get(13,$namespace).'</h1>';
		$output .= formHeader();
                $output .= WebGUI::Form::hidden("wid",$session{form}{wid});
                $output .= WebGUI::Form::hidden("eid",$session{form}{eid});
                $output .= WebGUI::Form::hidden("func","editEventSave");
                $output .= '<table>';
                $output .= tableFormRow(WebGUI::International::get(99),
			WebGUI::Form::text("name",20,128,$event{name}));
                $output .= tableFormRow(WebGUI::International::get(85),
			WebGUI::Form::textArea("description",$event{description},50,10,1));
                $output .= tableFormRow(WebGUI::International::get(14,$namespace),
			WebGUI::Form::text("startDate",20,30,epochToSet($event{startDate}),1));
                $output .= tableFormRow(WebGUI::International::get(15,$namespace),
			WebGUI::Form::text("endDate",20,30,epochToSet($event{endDate}),1));
                $output .= formSave();
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
                WebGUI::SQL->write("update EventsCalendar_event set name=".quote($session{form}{name}).", description=".quote($session{form}{description}).", startDate='".setToEpoch($session{form}{startDate})."', endDate='".setToEpoch($session{form}{endDate})."' where eventId=$session{form}{eid}");
                return www_edit();
        } else {
                return WebGUI::Privilege::insufficient();
        }
}

#-------------------------------------------------------------------
sub www_view {
	my (%data, %event, $p, $output, $sth, $flag, %previous, $junk,
		@row, $i, $maxDate, $minDate, $nextDate, $first, $last);
	tie %data, 'Tie::CPHash';
	tie %event, 'Tie::CPHash';
	tie %previous, 'Tie::CPHash';
	%data = getProperties($namespace,$_[0]);
	if (defined %data) {
		if ($data{displayTitle}) {
			$output = "<h1>".$data{title}."</h1>";
		}
		if ($data{description} ne "") {
			$output .= $data{description}.'<p>';
		}
		($minDate) = WebGUI::SQL->quickArray("select min(startDate) from EventsCalendar_event where widgetId=$_[0]");
		($maxDate) = WebGUI::SQL->quickArray("select max(endDate) from EventsCalendar_event where widgetId=$_[0]");	
		($junk, $maxDate) = WebGUI::DateTime::monthStartEnd($maxDate);
		unless ($minDate && $maxDate) {
			$minDate = time();
			$maxDate = time()+86400;
		}
		if ($data{calendarLayout} eq "calendar") {
			$nextDate = $minDate;
			while ($nextDate <= $maxDate) {
				$row[$i] = _calendarLayout($_[0],$nextDate);
				($first,$last) = WebGUI::DateTime::monthStartEnd($nextDate);
				if ($session{form}{pn} eq "" && $first <= time() && $last >= time()) {
					$session{form}{pn} = $i+1;
				}
				$i++;
				$nextDate = addToDate($nextDate,0,1,0);
			}
			$p = WebGUI::Paginator->new(WebGUI::URL::page(),\@row,1);
                	$output .= $p->getBar($session{form}{pn}).
				$p->getPage($session{form}{pn}).
				$p->getBarTraditional($session{form}{pn});
			$session{form}{pn} = "";
		} else {
			$sth = WebGUI::SQL->read("select name, description, startDate, endDate from EventsCalendar_event where widgetId='$_[0]' and endDate>".(time()-86400)." order by startDate,endDate");
			while (%event = $sth->hash) {
				unless ($event{startDate} == $previous{startDate} 
					&& $event{endDate} == $previous{endDate}) {
					$row[$i] = "<b>".epochToHuman($event{startDate},"%c %D");
					if (epochToHuman($event{startDate},"%y") ne epochToHuman($event{endDate},"%y")) {
						$row[$i] .= ", ".epochToHuman($event{startDate},"%y");
						$flag = 1;
					}
					if ($flag || epochToHuman($event{startDate},"%c") ne epochToHuman($event{endDate},"%c")) {
						$row[$i] .= " - ".epochToHuman($event{endDate},"%c %D");
					} elsif (epochToHuman($event{startDate},"%D") ne epochToHuman($event{endDate},"%D")) {
						$row[$i] .= " - ".epochToHuman($event{endDate},"%D");
					}
					$flag = 0;
					$row[$i] .= ", ".epochToHuman($event{endDate},"%y");
					$row[$i] .= "</b>";
					$row[$i] .= "<hr size=1>";
				}
				%previous = %event;
				$row[$i] .= '<span class="eventTitle">'.$event{name}.'</span>';
					if ($event{description} ne "") {
					$row[$i] .= ' - ';
					$row[$i] .= ''.$event{description};
				}
				$row[$i] .= '<p>';
				$i++;
			}
			$sth->finish;
			$p = WebGUI::Paginator->new(WebGUI::URL::page(),\@row,$data{paginateAfter});
                        $output .= $p->getPage($session{form}{pn}).$p->getBarSimple($session{form}{pn});		
		}
		if ($data{processMacros}) {
			$output = WebGUI::Macro::process($output);
		}
	}
	return $output;
}


1;

