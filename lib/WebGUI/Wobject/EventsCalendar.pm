package WebGUI::Wobject::EventsCalendar;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::Template;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);
our $namespace = "EventsCalendar";
our $name = WebGUI::International::get(2,$namespace);

#-------------------------------------------------------------------
sub _drawBigCalendar {
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
	my $canEdit = ($session{var}{adminOn} && WebGUI::Privilege::canEditPage());
        $sth = WebGUI::SQL->read("select * from EventsCalendar_event where wobjectId="
		.$_[0]->get("wobjectId")." order by startDate,endDate");
        while (%event = $sth->hash) {
        	if (epochToHuman($event{startDate},"%M %y") eq $thisMonth 
			|| epochToHuman($event{endDate},"%M %y") eq $thisMonth) {
			$message = "";
                        if ($canEdit) {
                                $message = deleteIcon('func=deleteEvent&wid='.$_[0]->get("wobjectId").'&eid='.$event{EventsCalendar_eventId}
                                        .'&rid='.$event{EventsCalendar_recurringId})
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
        return $calendar->as_HTML;
}

#-------------------------------------------------------------------
sub _drawSmallCalendar {
        my ($thisMonth, $calendar, $message, $start, $end, $sth, %event, $nextDate);
        tie %event, 'Tie::CPHash';
        $thisMonth = epochToHuman($_[1],"%M %y");
        $calendar = new HTML::CalendarMonthSimple('year'=>epochToHuman($_[1],"%y"),'month'=>epochToHuman($_[1],"%M"));
        $calendar->width(200);
        $calendar->border(0);
        $calendar->cellclass("tableData");
        $calendar->todaycellclass("tableHeader");
        $calendar->headerclass("tableHeader");
        $calendar->mondayisfirstday($session{user}{firstDayOfWeek});
        $calendar->sunday(substr(WebGUI::International::get(27),0,1));
	#$calendar->showweekdayheaders(0);
        $calendar->weekdays(
		substr(WebGUI::International::get(28),0,1),
                substr(WebGUI::International::get(29),0,1),
                substr(WebGUI::International::get(30),0,1),
                substr(WebGUI::International::get(31),0,1),
                substr(WebGUI::International::get(32),0,1)
		);
        $calendar->saturday(substr(WebGUI::International::get(33),0,1));
        $calendar->monthname(WebGUI::DateTime::getMonthName($calendar->month));
        $calendar->header('<b>'.$calendar->monthname.' '.$calendar->year.'</b>');
        ($start,$end) = monthStartEnd($_[1]);
        $sth = WebGUI::SQL->read("select * from EventsCalendar_event where wobjectId="
                .$_[0]->get("wobjectId")." order by startDate,endDate");
        while (%event = $sth->hash) {
                if (epochToHuman($event{startDate},"%M %y") eq $thisMonth || epochToHuman($event{endDate},"%M %y") eq $thisMonth) {
                        if ($event{startDate} == $event{endDate}) {
                                $calendar->setdatehref(epochToHuman($event{startDate},"%D"),
					WebGUI::URL::page('wid='.$_[0]->get("wobjectId")
					.'&func=viewEvent&eid='.$event{EventsCalendar_eventId}));
				#$calendar->datecellclass(epochToHuman($nextDate,"%D"),"highlight");
                        } else {
                                $nextDate = $event{startDate};
                                while($nextDate <= $event{endDate}) {
                                        if (epochToHuman($nextDate,"%M %y") eq $thisMonth) {
                                                $calendar->setdatehref(epochToHuman($nextDate,"%D"),
							WebGUI::URL::page('wid='.$_[0]->get("wobjectId")
							.'&func=viewEvent&eid='.$event{EventsCalendar_eventId}));
						#$calendar->datecellclass(epochToHuman($nextDate,"%D"),"highlight");
                                        }
                                        $nextDate = addToDate($nextDate,0,0,1);
                                }
                        }
                }
        }
        $sth->finish;
        return $calendar->as_HTML;
}

#-------------------------------------------------------------------
sub duplicate {
        my ($sth, $w, @row, $newEventId, $previousRecurringEventId);
	$w = $_[0]->SUPER::duplicate($_[1]);
        $w = WebGUI::Wobject::EventsCalendar->new({wobjectId=>$w,namespace=>$namespace});
        $w->set({
		templateId=>$_[0]->get("templateId"),
		eventTemplateId=>$_[0]->get("eventTemplateId"),
		startMonth=>$_[0]->get("startMonth"),
		endMonth=>$_[0]->get("endMonth"),
		defaultMonth=>$_[0]->get("defaultMonth"),
		paginateAfter=>$_[0]->get("paginateAfter")
		});
	$sth = WebGUI::SQL->read("select * from EventsCalendar_event where wobjectId="
		.$_[0]->get("wobjectId")." order by EventsCalendar_recurringId");
	while (@row = $sth->array) {
		$newEventId = getNextId("EventsCalendar_eventId");
		if ($row[6] > 0 && $row[6] != $previousRecurringEventId) {
			$row[6] = getNextId("EventsCalendar_recurringId");
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
        $_[0]->SUPER::set($_[1],[qw(templateId eventTemplateId startMonth endMonth defaultMonth paginateAfter)]);
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
		$_[0]->deleteCollateral("EventsCalendar_event","EventsCalendar_recurringId",$session{form}{rid});
	} else {
		$_[0]->deleteCollateral("EventsCalendar_event","EventsCalendar_eventId",$session{form}{eid});
	}
        return "";
}

#-------------------------------------------------------------------
sub www_edit {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
        my ($output, $startMonth, $endMonth, $afterEdit, $defaultMonth, $f, $paginateAfter);
	$paginateAfter = $_[0]->get("paginateAfter") || 50;
	$startMonth = $_[0]->get("startMonth") || "current";
	$endMonth = $_[0]->get("endMonth") || "after12";
	$defaultMonth = $_[0]->get("defaultMonth") || "current";
	$afterEdit = 'func=edit&wid='.$_[0]->get("wobjectId") if ($_[0]->get("wobjectId") ne "new");
        $output = helpIcon(1,$namespace);
	$output .= '<h1>'.WebGUI::International::get(12,$namespace).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->template(
                -name=>"templateId",
                -value=>$_[0]->get("templateId"),
                -namespace=>$namespace,
                -label=>WebGUI::International::get(79,$namespace),
                -afterEdit=>$afterEdit
                );
        $f->template(
                -name=>"eventTemplateId",
                -value=>$_[0]->get("eventTemplateId"),
                -namespace=>$namespace."/Event",
                -label=>WebGUI::International::get(80,$namespace),
                -afterEdit=>$afterEdit
                );
	$f->select(
		-name=>"startMonth",
		-options=>{
			"current"=>WebGUI::International::get(82,$namespace),
			"first"=>WebGUI::International::get(83,$namespace)
			},
		-label=>WebGUI::International::get(81,$namespace),
		-value=>[$startMonth]
		);
        $f->select(
                -name=>"endMonth",
                -options=>{
                        "last"=>WebGUI::International::get(85,$namespace),
			"after12"=>WebGUI::International::get(86,$namespace),
			"after9"=>WebGUI::International::get(87,$namespace),
			"after6"=>WebGUI::International::get(88,$namespace),
			"after3"=>WebGUI::International::get(89,$namespace),
			"current"=>WebGUI::International::get(82,$namespace),
                        },
                -label=>WebGUI::International::get(84,$namespace),
                -value=>[$endMonth]
                );
        $f->select(
                -name=>"defaultMonth",
                -options=>{
                        "current"=>WebGUI::International::get(82,$namespace),
                        "last"=>WebGUI::International::get(85,$namespace),
                        "first"=>WebGUI::International::get(83,$namespace)
                        },
                -label=>WebGUI::International::get(90,$namespace),
                -value=>[$defaultMonth]
                );
	$f->integer("paginateAfter",WebGUI::International::get(19,$namespace),$paginateAfter);
	if ($_[0]->get("wobjectId") eq "new") {
		$f->whatNext(
			-options=>{
				addEvent=>WebGUI::International::get(91,$namespace),
				backToPage=>WebGUI::International::get(745)
				},
			-value=>"backToPage"
			);
	}
	$output .= $_[0]->SUPER::www_edit($f->printRowsOnly);
        return $output;
}

#-------------------------------------------------------------------
sub www_editSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	$_[0]->SUPER::www_editSave({
		templateId=>$session{form}{templateId},
		eventTemplateId=>$session{form}{eventTemplateId},
		startMonth=>$session{form}{startMonth},
		endMonth=>$session{form}{endMonth},
		defaultMonth=>$session{form}{defaultMonth},
		paginateAfter=>$session{form}{paginateAfter}
		});
	if ($session{form}{proceed} eq "addEvent") {
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
        $f->date(
		-name=>"endDate",
		-label=>WebGUI::International::get(15,$namespace),
		-value=>$event{endDate},
		-extras=>'onBlur="this.form.until.value=this.form.endDate.value;"'
		);
	$f->raw($special);
	if ($session{form}{eid} eq "new") {
                $f->whatNext(
                        -options=>{
                                addEvent=>WebGUI::International::get(91,$namespace),
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
sub www_editEventSave {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditPage());
	my (@startDate, @endDate, $until, @eventId, $i, $recurringEventId);
        $startDate[0] = setToEpoch($session{form}{startDate});
	$startDate[0] = time() unless ($startDate[0] > 0);
        $endDate[0] = setToEpoch($session{form}{endDate});
	$endDate[0] = $startDate[0] unless ($endDate[0] >= $startDate[0]);
	if ($session{form}{eid} eq "new") {
		$session{form}{name} = $session{form}{name} || "unnamed";
		$session{form}{eid} = getNextId("EventsCalendar_eventId");
               	$until = setToEpoch($session{form}{until});
		$until = $endDate[0] unless ($until >= $endDate[0]);
               	$eventId[0] = getNextId("EventsCalendar_eventId");
		$session{form}{interval} = 1 if ($session{form}{interval} < 1);
               	if ($session{form}{recursEvery} eq "never") {
                       	$recurringEventId = 0;
               	} else {
                       	$recurringEventId = getNextId("EventsCalendar_recurringId");
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
			description=".quote($session{form}{description}).", startDate=".$startDate[0].", 
			endDate=".$endDate[0]." where EventsCalendar_eventId=$session{form}{eid}");
	}
	if ($session{form}{proceed} eq "addEvent") {
		$session{form}{eid} = "new";
		return $_[0]->www_editEvent;
	} else {
               	return "";
	}
}

#-------------------------------------------------------------------
sub www_view {
	my (%var, $junk, $sameDate, $p, @list, $date, $flag, %previous, @row, $i, $maxDate, $minDate);
	tie %previous, 'Tie::CPHash';
	$var{"addevent.url"} = WebGUI::URL::page('func=editEvent&eid=new&wid='.$_[0]->get("wobjectId"));
	$var{"addevent.label"} = WebGUI::International::get(20,$namespace);
	if ($_[0]->get("startMonth") eq "first") {
		($minDate) = WebGUI::SQL->quickArray("select min(startDate) from EventsCalendar_event 
			where wobjectId=".$_[0]->get("wobjectId"));
	}
	$minDate = $minDate || WebGUI::DateTime::time();
	($minDate,$junk) = WebGUI::DateTime::monthStartEnd($minDate);
	if ($_[0]->get("endMonth") eq "last") {
		($maxDate) = WebGUI::SQL->quickArray("select max(endDate) from EventsCalendar_event where 
			wobjectId=".$_[0]->get("wobjectId"));	
	} elsif ($_[0]->get("endMonth") eq "after12") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,0,11,0); 
	} elsif ($_[0]->get("endMonth") eq "after9") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,0,8,0); 
	} elsif ($_[0]->get("endMonth") eq "after6") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,0,5,0); 
	} elsif ($_[0]->get("endMonth") eq "after3") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,0,2,0); 
	}
	$maxDate = $maxDate || WebGUI::DateTime::time();
	($junk,$maxDate) = WebGUI::DateTime::dayStartEnd($maxDate);
	my $monthCount = WebGUI::DateTime::monthCount($minDate,$maxDate);
	unless ($session{form}{pn}) {
		$flag = 1;
		if ($_[0]->get("defaultMonth") eq "current") {
			$session{form}{pn} = WebGUI::DateTime::monthCount($minDate,WebGUI::DateTime::time());
		} elsif ($_[0]->get("defaultMonth") eq "last") {
			$session{form}{pn} = WebGUI::DateTime::monthCount($minDate,$maxDate);
		} else {
			$session{form}{pn} = 1;
		}
	}
	for ($i=1;$i<=$monthCount;$i++) {
		if ($session{form}{pn} == ($i)) {
			my $thisMonth = WebGUI::DateTime::addToDate($minDate,0,($i-1),0);
			$var{"calendar.big"} = $_[0]->_drawBigCalendar($thisMonth);
			$var{"calendar.small"} = $_[0]->_drawSmallCalendar($thisMonth);
		}
		$row[$i-1] = "page";
	}
	$p = WebGUI::Paginator->new(WebGUI::URL::page("func=view&wid=".$_[0]->get("wobjectId")),\@row,1);
        $var{"calendar.firstPage"} = $p->getFirstPageLink;
        $var{"calendar.lastPage"} = $p->getLastPageLink;
        $var{"calendar.nextPage"} = $p->getNextPageLink;
        $var{"calendar.pageList"} = $p->getPageLinks;
        $var{"calendar.previousPage"} = $p->getPreviousPageLink;
        $var{"calendar.multiplePages"} = ($p->getNumberOfPages > 1);
	if ($flag) {
		$flag = 0;
		$session{form}{pn} = "";
	}
	$p = WebGUI::Paginator->new(WebGUI::URL::page("func=view&wid=".$_[0]->get("wobjectId")),[],$_[0]->get("paginateAfter"));
	$p->setDataByQuery("select * from EventsCalendar_event where wobjectId=".$_[0]->get("wobjectId")
		." and endDate>=$minDate and startDate<=$maxDate order by startDate,endDate");
	my $events = $p->getPageData;
	foreach my $event (@$events) {
		if ($event->{startDate} == $previous{startDate} && $event->{endDate} == $previous{endDate}) {
			$sameDate = 1;
		} else {
			$sameDate = 0;
		}
		$date = epochToHuman($event->{startDate},"%c %D");
		if (epochToHuman($event->{startDate},"%y") ne epochToHuman($event->{endDate},"%y")) {
			$date .= ", ".epochToHuman($event->{startDate},"%y");
			$flag = 1;
		}
		if ($flag || epochToHuman($event->{startDate},"%c") ne epochToHuman($event->{endDate},"%c")) {
			$date .= " - ".epochToHuman($event->{endDate},"%c %D");
		} elsif (epochToHuman($event->{startDate},"%D") ne epochToHuman($event->{endDate},"%D")) {
			$date .= " - ".epochToHuman($event->{endDate},"%D");
		}
		$flag = 0;
		$date .= ", ".epochToHuman($event->{endDate},"%y");
		%previous = %{$event};
		push(@list, {
			"list.date"=>$date,
			"list.title"=>$event->{name},
			"list.description"=>$event->{description},
			"list.sameAsPrevious"=>$sameDate,
			"list.url"=>WebGUI::URL::page('func=viewEvent&wid='.$_[0]->get("wobjectId").'&eid='
				.$event->{EventsCalendar_eventId}),
			"list.controls"=>deleteIcon('func=deleteEvent&wid='.$_[0]->get("wobjectId").'&eid='
				.$event->{EventsCalendar_eventId}.'&rid='.$event->{EventsCalendar_recurringId})
				.editIcon('func=editEvent&wid='.$_[0]->get("wobjectId").'&eid='.$event->{EventsCalendar_eventId})
			});
	}
	$var{list_loop} = \@list;
	$var{"list.firstPage"} = $p->getFirstPageLink;
        $var{"list.lastPage"} = $p->getLastPageLink;
        $var{"list.nextPage"} = $p->getNextPageLink;
        $var{"list.pageList"} = $p->getPageLinks;
        $var{"list.previousPage"} = $p->getPreviousPageLink;
        $var{"list.multiplePages"} = ($p->getNumberOfPages > 1);
	return $_[0]->processMacros($_[0]->processTemplate($_[0]->get("templateId"),\%var));
}

#-------------------------------------------------------------------
sub www_viewEvent {
	my ($output, %event, %var, $id);
	tie %event, 'Tie::CPHash';
	%event = WebGUI::SQL->quickHash("select * from EventsCalendar_event where EventsCalendar_eventId=$session{form}{eid}");
	$var{title} = $event{name};
	$var{"start.label"} =  WebGUI::International::get(14,$namespace);
	$var{"start.date"} = epochToHuman($event{startDate},"%z");
	$var{"end.label"} = WebGUI::International::get(15,$namespace);
	$var{"end.date"} = epochToHuman($event{endDate},"%z");
	$var{canEdit} = WebGUI::Privilege::canEditPage();
        $var{"edit.url"} = WebGUI::URL::page('func=editEvent&eid='.$session{form}{eid}.'&wid='.$session{form}{wid});
	$var{"edit.label"} = WebGUI::International::get(575);
        $var{"delete.url"} = WebGUI::URL::page('func=deleteEvent&eid='.$session{form}{eid}.'&wid='
		.$session{form}{wid}.'&rid='.$event{EventsCalendar_recurringId});
	$var{"delete.label"} = WebGUI::International::get(576);
	($id) = WebGUI::SQL->quickArray("select EventsCalendar_eventId from EventsCalendar_event 
		where EventsCalendar_eventId<>$event{EventsCalendar_eventId} and
		startDate<=$event{startDate} order by startDate desc, endDate desc");
	$var{"previous.label"} = '&laquo;'.WebGUI::International::get(92,$namespace);
	$var{"previous.url"} = WebGUI::URL::page("func=viewEvent&wid=".$_[0]->get("wobjectId")."&eid=".$id) if ($id);
        ($id) = WebGUI::SQL->quickArray("select EventsCalendar_eventId from EventsCalendar_event
                where EventsCalendar_eventId<>$event{EventsCalendar_eventId} and 
		startDate>=$event{startDate} order by startDate, endDate");
        $var{"next.label"} = WebGUI::International::get(93,$namespace).'&raquo;';
        $var{"next.url"} = WebGUI::URL::page("func=viewEvent&wid=".$_[0]->get("wobjectId")."&eid=".$id) if ($id);
	$var{description} = $event{description};
	return WebGUI::Macro::process(
		WebGUI::Template::process(
			WebGUI::Template::get(
				$_[0]->get("eventTemplateId"),
				"EventsCalendar/Event"
				), 
			\%var)
		);
}

1;

