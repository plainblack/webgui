package WebGUI::Wobject::EventsCalendar;

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
use HTML::CalendarMonthSimple;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "EventsCalendar";
our $name = WebGUI::International::get(2,$namespace);

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
	$calendar->mondayisfirstday($session{user}{firstDayOfWeek});
	$calendar->sunday(WebGUI::International::get(27));
        $calendar->weekdays(WebGUI::International::get(28),
		WebGUI::International::get(29),
		WebGUI::International::get(30),
		WebGUI::International::get(31),
		WebGUI::International::get(32));
        $calendar->saturday(WebGUI::International::get(33));
	$calendar->monthname(WebGUI::DateTime::getMonthName($calendar->month));
	$calendar->header('<h2 align="center">'.$calendar->monthname.' '.$calendar->year.'</h2>');
        ($start,$end) = monthStartEnd($_[1]);
        $sth = WebGUI::SQL->read("select * from EventsCalendar_event where wobjectId="
		.$_[0]->get("wobjectId")." order by startDate,endDate");
        while (%event = $sth->hash) {
        	if (epochToHuman($event{startDate},"%M %y") eq $thisMonth 
			|| epochToHuman($event{endDate},"%M %y") eq $thisMonth) {
			$message = "";
                        if ($session{var}{adminOn}) {
                                $message = deleteIcon('func=deleteEvent&wid='.$_[0]->get("wobjectId").'&eid='.$event{EventsCalendar_eventId}
                                        .'&rid='.$event{EventsCalendar_recurringEventId})
                                        .editIcon('func=editEvent&wid='.$_[0]->get("wobjectId").'&eid='.$event{EventsCalendar_eventId})
                                        .' ';
                        }
			$message .= '<a href="'.WebGUI::URL::page('wid='.$_[0]->get("wobjectId")
				.'&func=viewEvent&eid='.$event{EventsCalendar_eventId}).'">'.$event{name}.'</a>';
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
        my ($sth, $w, @row, $newEventId, $previousRecurringEventId);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::EventsCalendar->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
		calendarLayout=>$_[0]->get("calendarLayout"),
		paginateAfter=>$_[0]->get("paginateAfter")
		});
	$sth = WebGUI::SQL->read("select * from EventsCalendar_event where wobjectId="
		.$_[0]->get("wobjectId")." order by EventsCalendar_recurringEventId");
	while (@row = $sth->array) {
		$newEventId = getNextId("EventsCalendar_eventId");
		if ($row[6] > 0 && $row[6] != $previousRecurringEventId) {
			$row[6] = getNextId("EventsCalendar_recurringEventId");
			$previousRecurringEventId = $row[6];
		}
               	WebGUI::SQL->write("insert into EventsCalendar_event values ($newEventId, ".$w->get("wobjectId").", ".
			quote($row[2]).", ".quote($row[3]).", '".$row[4]."', '".$row[5]."', $row[6])");
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from EventsCalendar_event where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub set {
        $_[0]->SUPER::set($_[1],[qw(calendarLayout paginateAfter)]);
}

#-------------------------------------------------------------------
sub www_deleteEvent {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	my ($output);
	$output = '<h1>'.WebGUI::International::get(42).'</h1>';
	$output .= WebGUI::International::get(75,$namespace).'<p><blockquote>';
	$output .= '<a href="'.WebGUI::URL::page('func=deleteEventConfirm&wid='.$session{form}{wid}.'&eid='
		.$session{form}{eid}).'">'.WebGUI::International::get(76,$namespace).'</a><p>';
	$output .= '<a href="'.WebGUI::URL::page('func=deleteEventConfirm&wid='.$session{form}{wid}.'&eid='
		.$session{form}{eid}.'&rid='.$session{form}{rid}).'">'
		.WebGUI::International::get(77,$namespace).'</a><p>'; 
	$output .= '<a href="'.WebGUI::URL::page('func=edit&wid='.$session{form}{wid}).'">'
		.WebGUI::International::get(78,$namespace).'</a>';
	$output .= '</blockquote>';
        return $output;
}

#-------------------------------------------------------------------
sub www_deleteEventConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	if ($session{form}{rid} > 0) {
		$_[0]->deleteCollateral("EventsCalendar_event","EventsCalendar_recurringEventId",$session{form}{rid});
	} else {
		$_[0]->deleteCollateral("EventsCalendar_event","EventsCalendar_eventId",$session{form}{eid});
	}
        return "";
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, %hash, $f, $paginateAfter, $proceed);
	tie %hash, 'Tie::IxHash';
	if ($_[0]->get("wobjectId") eq "new") {
		$proceed = 1;
	}
	$paginateAfter = $_[0]->get("paginateAfter") || 50;
        $output = helpIcon(1,$namespace);
	$output .= '<h1>'.WebGUI::International::get(12,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
        %hash = (list => WebGUI::International::get(17,$namespace),
                calendarMonth => WebGUI::International::get(18,$namespace));
	#	calendarMonthSmall => WebGUI::International::get(74,$namespace));
	$f->select("calendarLayout",\%hash,WebGUI::International::get(16,$namespace),[$_[0]->get("calendarLayout")]);
	$f->integer("paginateAfter",WebGUI::International::get(19,$namespace),$paginateAfter);
	$f->yesNo("proceed",WebGUI::International::get(21,$namespace),$proceed);
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->SUPER::www_editSave();
        $_[0]->set({
		calendarLayout=>$session{form}{calendarLayout},
		paginateAfter=>$session{form}{paginateAfter}
		});
	if ($session{form}{proceed}) {
		$session{form}{eid} = "new";
		return $_[0]->www_editEvent;
	} else {
               	return "";
	}
}

#-------------------------------------------------------------------
sub www_editEvent {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my (%recursEvery, $special, $output, $f, %event);
	tie %event, 'Tie::CPHash';
	tie %recursEvery, 'Tie::IxHash';
	if ($session{form}{eid} eq "new") {
        	%recursEvery = ('never'=>WebGUI::International::get(4,$namespace),
               		'day'=>WebGUI::International::get(700),
               		'week'=>WebGUI::International::get(701),
               		'month'=>WebGUI::International::get(702),
               		'year'=>WebGUI::International::get(703)
               		);
		$event{endDate} = $event{endDate};
		$f = WebGUI::HTMLForm->new(1);
		$f->raw('<tr><td class="formdescription" valign="top">'.WebGUI::International::get(8,$namespace).'</td><td class="tableData">');
		$f->integer("interval","",1,"","","",3);
		$f->select("recursEvery",\%recursEvery);
		$f->raw(' '.WebGUI::International::get(9,$namespace).' ');
		$f->date("until");
		$f->raw("</td><tr>");
		$special = $f->printRowsOnly;
	} else {
               	%event = WebGUI::SQL->quickHash("select * from EventsCalendar_event where EventsCalendar_eventId='$session{form}{eid}'");
		$f = WebGUI::HTMLForm->new;
		$f->hidden("until");
		$special = $f->printRowsOnly;
	}
	$output = helpIcon(2,$namespace);
        $output .= '<h1>'.WebGUI::International::get(13,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("eid",$session{form}{eid});
        $f->hidden("func","editEventSave");
        $f->text("name",WebGUI::International::get(99),$event{name});
        $f->HTMLArea("description",WebGUI::International::get(85),$event{description});
        $f->date("startDate",WebGUI::International::get(14,$namespace),$event{startDate},
		'onBlur="this.form.endDate.value=this.form.startDate.value;this.form.until.value=this.form.startDate.value;"');
        $f->date("endDate",WebGUI::International::get(15,$namespace),$event{endDate});
	$f->raw($special);
	$f->yesNo("proceed",WebGUI::International::get(21,$namespace));
	$f->submit;
	$output .= $f->print;
        return $output;
}

#-------------------------------------------------------------------
sub www_editEventSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	my (@startDate, @endDate, $until, @eventId, $i, $recurringEventId);
	if ($session{form}{eid} eq "new") {
		$session{form}{eid} = getNextId("EventsCalendar_eventId");
       		$startDate[0] = setToEpoch($session{form}{startDate});
               	$endDate[0] = setToEpoch($session{form}{endDate});
               	$until = setToEpoch($session{form}{until});
               	$eventId[0] = getNextId("EventsCalendar_eventId");
		$session{form}{interval} = 1 if ($session{form}{interval} < 1);
               	if ($session{form}{recursEvery} eq "never") {
                       	$recurringEventId = 0;
               	} else {
                       	$recurringEventId = getNextId("EventsCalendar_recurringEventId");
                       	while ($startDate[$i] < $until) {
                               	$i++;
                               	$eventId[$i] = getNextId("EventsCalendar_eventId");
				if ($session{form}{recursEvery} eq "day") {
                               		$startDate[$i] = addToDate($startDate[0],0,0,($i*$session{form}{interval}));
                               		$endDate[$i] = addToDate($endDate[0],0,0,($i*$session{form}{interval}));
				} elsif ($session{form}{recursEvery} eq "week") {
                               		$startDate[$i] = addToDate($startDate[0],0,0,(7*$i*$session{form}{interval}));
                               		$endDate[$i] = addToDate($endDate[0],0,0,(7*$i*$session{form}{interval}));
                                } elsif ($session{form}{recursEvery} eq "month") {
                                        $startDate[$i] = addToDate($startDate[0],0,($i*$session{form}{interval}),0);
                                        $endDate[$i] = addToDate($endDate[0],0,($i*$session{form}{interval}),0);
                                } elsif ($session{form}{recursEvery} eq "year") {
                                        $startDate[$i] = addToDate($startDate[0],($i*$session{form}{interval}),0,0);
                                        $endDate[$i] = addToDate($endDate[0],($i*$session{form}{interval}),0,0);
				}
                       	}
               	}
               	$i = 0;
               	while ($eventId[$i] > 0) {
                       	WebGUI::SQL->write("insert into EventsCalendar_event values ($eventId[$i], 
				".$_[0]->get("wobjectId").", 
				".quote($session{form}{name}).", 
				".quote($session{form}{description}).", 
				$startDate[$i], $endDate[$i], $recurringEventId)");
                       	$i++;
               	}
	} else {
               	WebGUI::SQL->write("update EventsCalendar_event set name=".quote($session{form}{name}).", 
			description=".quote($session{form}{description}).", startDate='".setToEpoch($session{form}{startDate})."', 
			endDate='".setToEpoch($session{form}{endDate})."' where EventsCalendar_eventId=$session{form}{eid}");
	}
	if ($session{form}{proceed}) {
		$session{form}{eid} = "new";
		return $_[0]->www_editEvent;
	} else {
               	return "";
	}
}

#-------------------------------------------------------------------
sub www_view {
	my (%event, $p, $output, $sth, $flag, %previous, $junk, @row, $i, $maxDate, $minDate, $nextDate, $first, $last);
	tie %event, 'Tie::CPHash';
	tie %previous, 'Tie::CPHash';
	$output = $_[0]->displayTitle;
        $output .= $_[0]->description;
	if ($session{var}{adminOn}) {
        	$output .= '<p><a href="'.WebGUI::URL::page('func=editEvent&eid=new&wid='.$_[0]->get("wobjectId")).'">'
			.WebGUI::International::get(20,$namespace).'</a><p>';
	}
	($minDate) = WebGUI::SQL->quickArray("select min(startDate) from EventsCalendar_event where wobjectId=".$_[0]->get("wobjectId"));
	($maxDate) = WebGUI::SQL->quickArray("select max(endDate) from EventsCalendar_event where wobjectId=".$_[0]->get("wobjectId"));	
	($junk, $maxDate) = WebGUI::DateTime::monthStartEnd($maxDate);
	unless ($minDate && $maxDate) {
		$minDate = time();
		$maxDate = time()+86400;
	}
	if ($_[0]->get("calendarLayout") eq "calendarMonth") {
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
		$sth = WebGUI::SQL->read("select * from EventsCalendar_event 
			where wobjectId=".$_[0]->get("wobjectId")." and endDate>".(time()-86400)." order by startDate,endDate");
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
				$row[$i] .= "<br>";
			}
			%previous = %event;
			if ($session{var}{adminOn}) {
				$row[$i] .= deleteIcon('func=deleteEvent&wid='.$_[0]->get("wobjectId").'&eid='.$event{EventsCalendar_eventId}
					.'&rid='.$event{EventsCalendar_recurringEventId})
					.editIcon('func=editEvent&wid='.$_[0]->get("wobjectId").'&eid='.$event{EventsCalendar_eventId})
					.' ';
			}
			$row[$i] .= '<span class="eventTitle">'.$event{name}.'</span>';
				if ($event{description} ne "") {
				$row[$i] .= ' - ';
				$row[$i] .= ''.$event{description};
			}
			$row[$i] .= '<p>';
			$i++;
		}
		$sth->finish;
		$p = WebGUI::Paginator->new(WebGUI::URL::page(),\@row,$_[0]->get("paginateAfter"));
                $output .= $p->getPage($session{form}{pn}).$p->getBarSimple($session{form}{pn});		
	}
	return $_[0]->processMacros($output);
}

#-------------------------------------------------------------------
sub www_viewEvent {
	my ($output, %event);
	tie %event, 'Tie::CPHash';
	%event = WebGUI::SQL->quickHash("select * from EventsCalendar_event where EventsCalendar_eventId=$session{form}{eid}");
	$output = '<h1>'.$event{name}.'</h1>';
	$output .= '<table width="100%" cellspacing="0" cellpadding="5" border="0">';
	$output .= '<tr>';
	$output .= '<td valign="top" class="tableHeader" width="100%">';
	$output .= '<b>'.WebGUI::International::get(14,$namespace).':</b> '.epochToHuman($event{startDate},"%z").'<br>';
	$output .= '<b>'.WebGUI::International::get(15,$namespace).':</b> '.epochToHuman($event{endDate},"%z").'<br>';
	$output .= '</td><td valign="top" class="tableMenu" nowrap="1">';
	if (WebGUI::Privilege::canEditPage()) {
        	$output .= '<a href="'.WebGUI::URL::page('func=editEvent&eid='.$session{form}{eid}.'&wid='
			.$session{form}{wid}).'">'.WebGUI::International::get(575).'</a><br>';
                $output .= '<a href="'.WebGUI::URL::page('func=deleteEvent&eid='.$session{form}{eid}.
                        '&wid='.$session{form}{wid}.'&rid='.$event{EventsCalendar_recurringEventId}).'">'
                        .WebGUI::International::get(576).'</a><br>';
        }
	$output .= '</td></tr>';
	$output .= '</table>';
	$output .= $event{description};
	return WebGUI::Macro::process($output);
}

1;

