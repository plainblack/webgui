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
use WebGUI::FormProcessor;
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
	my $canEdit = ($session{var}{adminOn} && WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	my $query = "select * from EventsCalendar_event";
	$query .= " where wobjectId=".$_[0]->get("wobjectId") unless ($_[0]->get("isMaster"));
	$query .= " order by startDate,endDate";
        $sth = WebGUI::SQL->read($query);
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
	my $query = "select * from EventsCalendar_event";
	$query .= " where wobjectId=".$_[0]->get("wobjectId") unless ($_[0]->get("isMaster"));
	$query .= " order by startDate,endDate";
        $sth = WebGUI::SQL->read($query);
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
	$sth = WebGUI::SQL->read("select * from EventsCalendar_event where wobjectId="
		.$_[0]->get("wobjectId")." order by EventsCalendar_recurringId");
	while (@row = $sth->array) {
		$newEventId = getNextId("EventsCalendar_eventId");
		if ($row[6] > 0 && $row[6] != $previousRecurringEventId) {
			$row[6] = getNextId("EventsCalendar_recurringId");
			$previousRecurringEventId = $row[6];
		}
               	WebGUI::SQL->write("insert into EventsCalendar_event values ($newEventId, ".$w.", ".
			quote($row[2]).", ".quote($row[3]).", '".$row[4]."', '".$row[5]."', $row[6])");
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(2,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
                -extendedProperties=>{
                	eventTemplateId=>{
                        	defaultValue=>1
                        	},
                	startMonth=>{
                        	defaultValue=>"current"
                        	},
                	endMonth=>{
                        	defaultValue=>"after12"
                        	},
                	defaultMonth=>{
                        	defaultValue=>"current"
                        	},
                	paginateAfter=>{
                        	defaultValue=>50
                        	},
			isMaster=>{
				defaultValue=>0,
				}
			},
		-useTemplate=>1
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
        WebGUI::SQL->write("delete from EventsCalendar_event where wobjectId=".$_[0]->get("wobjectId"));
	$_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub www_deleteEvent {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	my ($output);
	$output = '<h1>'.WebGUI::International::get(42).'</h1>';
	$output .= WebGUI::International::get(75,$_[0]->get("namespace")).'<p><blockquote>';
	$output .= '<a href="'.WebGUI::URL::page('func=deleteEventConfirm&wid='.$session{form}{wid}.'&eid='
		.$session{form}{eid}).'">'.WebGUI::International::get(76,$_[0]->get("namespace")).'</a><p>';
	$output .= '<a href="'.WebGUI::URL::page('func=deleteEventConfirm&wid='.$session{form}{wid}.'&eid='
		.$session{form}{eid}.'&rid='.$session{form}{rid}).'">'
		.WebGUI::International::get(77,$_[0]->get("namespace")).'</a><p>'; 
	$output .= '<a href="'.WebGUI::URL::page('func=edit&wid='.$session{form}{wid}).'">'
		.WebGUI::International::get(78,$_[0]->get("namespace")).'</a>';
	$output .= '</blockquote>';
        return $output;
}

#-------------------------------------------------------------------
sub www_deleteEventConfirm {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	if ($session{form}{rid} > 0) {
		$_[0]->deleteCollateral("EventsCalendar_event","EventsCalendar_recurringId",$session{form}{rid});
	} else {
		$_[0]->deleteCollateral("EventsCalendar_event","EventsCalendar_eventId",$session{form}{eid});
	}
        return "";
}

#-------------------------------------------------------------------
sub www_edit {
	my $afterEdit = 'func=edit&wid='.$_[0]->get("wobjectId") if ($_[0]->get("wobjectId") ne "new");
	my $layout = WebGUI::HTMLForm->new;
	my $properties = WebGUI::HTMLForm->new;
        $layout->template(
                -name=>"eventTemplateId",
                -value=>$_[0]->getValue("eventTemplateId"),
                -namespace=>$_[0]->get("namespace")."/Event",
                -label=>WebGUI::International::get(80,$_[0]->get("namespace")),
                -afterEdit=>$afterEdit
                );
	$properties->selectList(
		-name=>"startMonth",
		-options=>{
			"january"=>WebGUI::International::get(15),
			"now"=>WebGUI::International::get(98,$_[0]->get("namespace")),
			"current"=>WebGUI::International::get(82,$_[0]->get("namespace")),
			"first"=>WebGUI::International::get(83,$_[0]->get("namespace"))
			},
		-label=>WebGUI::International::get(81,$_[0]->get("namespace")),
		-value=>[$_[0]->getValue("startMonth")]
		);
	my %options;
	tie %options, 'Tie::IxHash';
	%options = (
		"last"=>WebGUI::International::get(85,$_[0]->get("namespace")),
                "after12"=>WebGUI::International::get(86,$_[0]->get("namespace")),
                "after9"=>WebGUI::International::get(87,$_[0]->get("namespace")),
                "after6"=>WebGUI::International::get(88,$_[0]->get("namespace")),
                "after3"=>WebGUI::International::get(89,$_[0]->get("namespace")),
                "current"=>WebGUI::International::get(82,$_[0]->get("namespace"))
		);
        $properties->selectList(
                -name=>"endMonth",
                -options=>\%options,
                -label=>WebGUI::International::get(84,$_[0]->get("namespace")),
                -value=>[$_[0]->getValue("endMonth")]
                );
        $properties->selectList(
                -name=>"defaultMonth",
                -options=>{
                        "current"=>WebGUI::International::get(82,$_[0]->get("namespace")),
                        "last"=>WebGUI::International::get(85,$_[0]->get("namespace")),
                        "first"=>WebGUI::International::get(83,$_[0]->get("namespace"))
                        },
                -label=>WebGUI::International::get(90,$_[0]->get("namespace")),
                -value=>[$_[0]->getValue("defaultMonth")]
                );
	$properties->yesNo(
		-name=>"isMaster",
		-value=>$_[0]->getValue("isMaster"),
		-label=>WebGUI::International::get(99,$_[0]->get("namespace"))
		);
	$layout->integer(
		-name=>"paginateAfter",
		-label=>WebGUI::International::get(19,$_[0]->get("namespace")),
		-value=>$_[0]->getValue("paginateAfter")
		);
	if ($_[0]->get("wobjectId") eq "new") {
		$properties->whatNext(
			-options=>{
				addEvent=>WebGUI::International::get(91,$_[0]->get("namespace")),
				backToPage=>WebGUI::International::get(745)
				},
			-value=>"backToPage"
			);
	}
	return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-layout=>$layout->printRowsOnly,
		-helpId=>1,
		-headingId=>12
		);
}

#-------------------------------------------------------------------
sub www_editSave {
	$_[0]->SUPER::www_editSave();
	if ($session{form}{proceed} eq "addEvent") {
		$session{form}{eid} = "new";
		return $_[0]->www_editEvent;
	} else {
               	return "";
	}
}

#-------------------------------------------------------------------
sub www_editEvent {
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        my (%recursEvery, $special, $output, $f, %event);
	tie %event, 'Tie::CPHash';
	tie %recursEvery, 'Tie::IxHash';
	if ($session{form}{eid} eq "new") {
        	%recursEvery = ('never'=>WebGUI::International::get(4,$_[0]->get("namespace")),
               		'day'=>WebGUI::International::get(700),
               		'week'=>WebGUI::International::get(701),
               		'month'=>WebGUI::International::get(702),
               		'year'=>WebGUI::International::get(703)
               		);
		$event{endDate} = $event{endDate};
		$f = WebGUI::HTMLForm->new(1);
		$f->raw('<tr><td class="formdescription" valign="top">'.WebGUI::International::get(8,$_[0]->get("namespace")).'</td><td class="tableData">');
		$f->integer("interval","",1,"","","",3);
		$f->select("recursEvery",\%recursEvery);
		$f->raw(' '.WebGUI::International::get(9,$_[0]->get("namespace")).' ');
		$f->date("until");
		$f->raw("</td><tr>");
		$special = $f->printRowsOnly;
	} else {
               	%event = WebGUI::SQL->quickHash("select * from EventsCalendar_event where EventsCalendar_eventId='$session{form}{eid}'");
		$f = WebGUI::HTMLForm->new;
		$f->hidden("until");
		$special = $f->printRowsOnly;
	}
	$output = helpIcon(2,$_[0]->get("namespace"));
        $output .= '<h1>'.WebGUI::International::get(13,$_[0]->get("namespace")).'</h1>';
	$f = WebGUI::HTMLForm->new;
        $f->hidden("wid",$_[0]->get("wobjectId"));
        $f->hidden("eid",$session{form}{eid});
        $f->hidden("func","editEventSave");
        $f->text("name",WebGUI::International::get(99),$event{name});
        $f->HTMLArea("description",WebGUI::International::get(85),$event{description});
        $f->dateTime(
		-name=>"startDate",
		-label=>WebGUI::International::get(14,$_[0]->get("namespace")),
		-value=>$event{startDate},
		-dateExtras=>'onBlur="this.form.endDate_date.value=this.form.startDate_date.value;this.form.until.value=this.form.startDate_date.value;"',
		-timeExtras=>'onBlur="this.form.endDate_time.value=this.form.startDate_time.value"'
		);
        $f->dateTime(
		-name=>"endDate",
		-label=>WebGUI::International::get(15,$_[0]->get("namespace")),
		-value=>$event{endDate},
		-dateExtras=>'onBlur="this.form.until.value=this.form.endDate_date.value;"'
		);
	$f->raw($special);
	if ($session{form}{eid} eq "new") {
                $f->whatNext(
                        -options=>{
                                addEvent=>WebGUI::International::get(91,$_[0]->get("namespace")),
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
	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	my (@startDate, @endDate, $until, @eventId, $i, $recurringEventId);
        $startDate[0] = WebGUI::FormProcessor::dateTime("startDate");
	$startDate[0] = time() unless ($startDate[0] > 0);
        $endDate[0] = WebGUI::FormProcessor::dateTime("endDate");
	$endDate[0] = $startDate[0] unless ($endDate[0] >= $startDate[0]);
	if ($session{form}{eid} eq "new") {
		$session{form}{name} = $session{form}{name} || "unnamed";
		$session{form}{eid} = getNextId("EventsCalendar_eventId");
               	$until = WebGUI::FormProcessor::date($session{form}{until});
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
	$var{"addevent.label"} = WebGUI::International::get(20,$_[0]->get("namespace"));
	if ($_[0]->get("startMonth") eq "first") {
		my $query = "select min(startDate) from EventsCalendar_event";
		$query .= " where wobjectId=".$_[0]->get("wobjectId") unless ($_[0]->get("isMaster"));
		($minDate) = WebGUI::SQL->quickArray($query);
	} elsif ($_[0]->get("startMonth") eq "january") {
		$minDate = WebGUI::DateTime::humanToEpoch(WebGUI::DateTime::epochToHuman("","%y")."-01-01 00:00:00");
	} else {
		$minDate = WebGUI::DateTime::time();
	}
	unless ($_[0]->get("startMonth") eq "now") {
		($minDate,$junk) = WebGUI::DateTime::monthStartEnd($minDate);
	}
	if ($_[0]->get("endMonth") eq "last") {
		my $query = "select max(endDate) from EventsCalendar_event";
		$query .= " where wobjectId=".$_[0]->get("wobjectId") unless ($_[0]->get("isMaster"));
		($maxDate) = WebGUI::SQL->quickArray($query);	
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
	my $query = "select * from EventsCalendar_event where ";
	$query .= " wobjectId=".$_[0]->get("wobjectId")." and " unless ($_[0]->get("isMaster"));
	$query .= " endDate>=$minDate and startDate<=$maxDate order by startDate,endDate";
	$p->setDataByQuery($query);
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
	return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}

#-------------------------------------------------------------------
sub www_viewEvent {
	my ($output, %event, %var, $id);
	tie %event, 'Tie::CPHash';
	%event = WebGUI::SQL->quickHash("select * from EventsCalendar_event where EventsCalendar_eventId=$session{form}{eid}");
	$var{title} = $event{name};
	$var{"start.label"} =  WebGUI::International::get(14,$_[0]->get("namespace"));
	$var{"start.date"} = epochToHuman($event{startDate},"%z");
	$var{"start.time"} = epochToHuman($event{startDate},"%Z");
	$var{"end.label"} = WebGUI::International::get(15,$_[0]->get("namespace"));
	$var{"end.date"} = epochToHuman($event{endDate},"%z");
	$var{"end.time"} = epochToHuman($event{endDate},"%Z");
	$var{canEdit} = WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId"));
        $var{"edit.url"} = WebGUI::URL::page('func=editEvent&eid='.$session{form}{eid}.'&wid='.$session{form}{wid});
	$var{"edit.label"} = WebGUI::International::get(575);
        $var{"delete.url"} = WebGUI::URL::page('func=deleteEvent&eid='.$session{form}{eid}.'&wid='
		.$session{form}{wid}.'&rid='.$event{EventsCalendar_recurringId});
	$var{"delete.label"} = WebGUI::International::get(576);
	my $query = "select EventsCalendar_eventId from EventsCalendar_event where EventsCalendar_eventId<>$event{EventsCalendar_eventId}";
	$query .= " and wobjectId=".$_[0]->get("wobjectId") unless ($_[0]->get("isMaster"));
	$query .= " and startDate<=$event{startDate} order by startDate desc, endDate desc";
	($id) = WebGUI::SQL->quickArray($query);
	$var{"previous.label"} = '&laquo;'.WebGUI::International::get(92,$_[0]->get("namespace"));
	$var{"previous.url"} = WebGUI::URL::page("func=viewEvent&wid=".$_[0]->get("wobjectId")."&eid=".$id) if ($id);
	$query = "select EventsCalendar_eventId from EventsCalendar_event where EventsCalendar_eventId<>$event{EventsCalendar_eventId}";
	$query .= " and wobjectId=".$_[0]->get("wobjectId") unless ($_[0]->get("isMaster"));
	$query .= " and startDate>=$event{startDate} order by startDate, endDate";
        ($id) = WebGUI::SQL->quickArray($query);
        $var{"next.label"} = WebGUI::International::get(93,$_[0]->get("namespace")).'&raquo;';
        $var{"next.url"} = WebGUI::URL::page("func=viewEvent&wid=".$_[0]->get("wobjectId")."&eid=".$id) if ($id);
	$var{description} = $event{description};
	return WebGUI::Template::process( WebGUI::Template::get( $_[0]->get("eventTemplateId"), "EventsCalendar/Event"), \%var);
}

1;

