package WebGUI::Wobject::EventsCalendar;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
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
use WebGUI::FormProcessor;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::Id;
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
sub duplicate {
        my ($sth, $w, @row, $newEventId, $previousRecurringEventId);
	$w = $_[0]->SUPER::duplicate($_[1]);
	$sth = WebGUI::SQL->read("select * from EventsCalendar_event where wobjectId="
		.quote($_[0]->get("wobjectId"))." order by EventsCalendar_recurringId");
	while (@row = $sth->array) {
		$newEventId = WebGUI::Id::generate();
		if ($row[6] > 0 && $row[6] != $previousRecurringEventId) {
			$row[6] = WebGUI::Id::generate();
			$previousRecurringEventId = $row[6];
		}
               	WebGUI::SQL->write("insert into EventsCalendar_event values (".quote($newEventId).", ".quote($w).", ".
			quote($row[2]).", ".quote($row[3]).", ".quote($row[4]).", ".quote($row[5]).", ".quote($row[6]).")");
	}
	$sth->finish;
}

#-------------------------------------------------------------------
sub getIndexerParams {
	my $self = shift;        
	my $now = shift;
	return {
		EventsCalendar => {
                        sql => "select EventsCalendar_event.EventsCalendar_eventId as eid,
                                        EventsCalendar_event.wobjectId as wid,
                                        EventsCalendar_event.name as name,
                                        EventsCalendar_event.description as description,
                                        wobject.namespace as namespace,
                                        wobject.addedBy as ownerId,
                                        page.urlizedTitle as urlizedTitle,
                                        page.languageId as languageId,
                                        page.pageId as pageId,
                                        page.groupIdView as page_groupIdView,
                                        wobject.groupIdView as wobject_groupIdView,
                                        7 as wobject_special_groupIdView
                                        from EventsCalendar_event, wobject, page
                                        where EventsCalendar_event.wobjectId = wobject.wobjectId
                                        and wobject.pageId = page.pageId
                                        and wobject.startDate < $now 
                                        and wobject.endDate > $now
                                        and page.startDate < $now
                                        and page.endDate > $now",
                        fieldsToIndex => ["description", "name"],
                        contentType => 'wobjectDetail',
                        url => 'WebGUI::URL::append($data{urlizedTitle},"func=viewEvent&wid=$data{wid}&eid=$data{eid}")',
                        headerShortcut => 'select name from EventsCalendar_event where EventsCalendar_eventId=$data{eid}',
                        bodyShortcut => 'select description from EventsCalendar_event where EventsCalendar_eventId=$data{eid}',
                }
	};
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
                        	defaultValue=>1
                        	},
			isMaster=>{
				defaultValue=>0,
				}
			},
		-useTemplate=>1,
		-useMetaData=>1
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
	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
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
	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
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
		-helpId=>"events calendar add/edit",
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
	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $session{page}{useAdminStyle} = 1;
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
		$f->selectList("recursEvery",\%recursEvery);
		$f->raw(' '.WebGUI::International::get(9,$_[0]->get("namespace")).' ');
		$f->date("until");
		$f->raw("</td><tr>");
		$special = $f->printRowsOnly;
	} else {
               	%event = WebGUI::SQL->quickHash("select * from EventsCalendar_event where EventsCalendar_eventId=".quote($session{form}{eid}));
		$f = WebGUI::HTMLForm->new;
		$f->hidden("until");
		$special = $f->printRowsOnly;
	}
	$output = helpIcon("event add/edit",$_[0]->get("namespace"));
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
		-extras=>'onBlur="this.form.endDate.value=this.form.startDate.value;this.form.until.value=this.form.startDate.value;"',
		);
        $f->dateTime(
		-name=>"endDate",
		-label=>WebGUI::International::get(15,$_[0]->get("namespace")),
		-value=>$event{endDate},
		-extras=>'onBlur="this.form.until.value=this.form.endDate.value;"'
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
	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
	my (@startDate, @endDate, $until, @eventId, $i, $recurringEventId);
        $startDate[0] = WebGUI::FormProcessor::dateTime("startDate");
	$startDate[0] = time() unless ($startDate[0] > 0);
        $endDate[0] = WebGUI::FormProcessor::dateTime("endDate");
	$endDate[0] = $startDate[0] unless ($endDate[0] >= $startDate[0]);
	if ($session{form}{eid} eq "new") {
		$session{form}{name} = $session{form}{name} || "unnamed";
		$session{form}{eid} = WebGUI::Id::generate();
               	$until = WebGUI::FormProcessor::date("until");
		$until = $endDate[0] unless ($until >= $endDate[0]);
               	$eventId[0] = WebGUI::Id::generate();
		$session{form}{interval} = 1 if ($session{form}{interval} < 1);
               	if ($session{form}{recursEvery} eq "never") {
                       	$recurringEventId = 0;
               	} else {
                       	$recurringEventId = WebGUI::Id::generate();
                       	while ($startDate[$i] < $until) {
                               	$i++;
                               	$eventId[$i] = WebGUI::Id::generate();
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
               	while ($eventId[$i] ne "") {
                       	WebGUI::SQL->write("insert into EventsCalendar_event values (".quote($eventId[$i]).", 
				".quote($_[0]->get("wobjectId")).", 
				".quote($session{form}{name}).", 
				".quote($session{form}{description}).", 
				$startDate[$i], $endDate[$i], ".quote($recurringEventId).")");
                       	$i++;
               	}
	} else {
               	WebGUI::SQL->write("update EventsCalendar_event set name=".quote($session{form}{name}).", 
			description=".quote($session{form}{description}).", startDate=".$startDate[0].", 
			endDate=".$endDate[0]." where EventsCalendar_eventId=".quote($session{form}{eid}));
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
	$_[0]->logView() if ($session{setting}{passiveProfilingEnabled});
	my ( $junk, $sameDate, $p, @list, $date, $flag, %previous, $maxDate, $minDate);
	# figure out the date range
	tie %previous, 'Tie::CPHash';
	if ($_[0]->get("startMonth") eq "first") {
		my $query = "select min(startDate) from EventsCalendar_event";
		$query .= " where wobjectId=".$_[0]->get("wobjectId") unless ($_[0]->get("isMaster"));
		($minDate) = WebGUI::SQL->quickArray($query,WebGUI::SQL->getSlave);
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
		($maxDate) = WebGUI::SQL->quickArray($query,WebGUI::SQL->getSlave);	
	} elsif ($_[0]->get("endMonth") eq "after12") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,1,0,0); 
	} elsif ($_[0]->get("endMonth") eq "after9") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,0,9,0); 
	} elsif ($_[0]->get("endMonth") eq "after6") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,0,6,0); 
	} elsif ($_[0]->get("endMonth") eq "after3") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,0,3,0); 
	}
	$maxDate = $maxDate || WebGUI::DateTime::time();
	($junk,$maxDate) = WebGUI::DateTime::dayStartEnd($maxDate);
	my $monthCount = WebGUI::DateTime::monthCount($minDate,$maxDate);
	unless ($session{form}{calPn}) {
		$flag = 1;
		if ($_[0]->get("defaultMonth") eq "current") {
			$session{form}{calPn} = round(WebGUI::DateTime::monthCount($minDate,WebGUI::DateTime::time())/$_[0]->getValue("paginateAfter"));
		} elsif ($_[0]->get("defaultMonth") eq "last") {
			$session{form}{calPn} = WebGUI::DateTime::monthCount($minDate,$maxDate);
		} else {
			$session{form}{calPn} = 1;
		}
	}

	# create template variables
	my %var;
	$var{"addevent.url"} = WebGUI::URL::page('func=editEvent&eid=new&wid='.$_[0]->get("wobjectId"));
	$var{"addevent.label"} = WebGUI::International::get(20,$_[0]->get("namespace"));
	my @monthloop;
	for (my $i=1;$i<=$monthCount;$i++) {
	#	if ($session{form}{calPn} == ($i)) {
			my $thisMonth = WebGUI::DateTime::addToDate($minDate,0,($i-1),0);
			my ($monthStart, $monthEnd) = WebGUI::DateTime::monthStartEnd($thisMonth);
			my @thisMonthDate = WebGUI::DateTime::epochToArray($thisMonth);
			# get event information
			my $query = "select * from EventsCalendar_event where ";
			$query .= " wobjectId=".quote($_[0]->get("wobjectId"))." and " unless ($_[0]->get("isMaster"));
			$query .= " (endDate>=$monthStart and endDate<=$monthEnd) and (startDate>=$monthStart and startDate<=$monthEnd) order by startDate,endDate";
			my %events;
			my %previous;
			my $sth = WebGUI::SQL->read($query,WebGUI::SQL->getSlave);
			while (my $event = $sth->hashRef) {
				my $eventLength = WebGUI::DateTime::getDaysInInterval($event->{startDate},$event->{endDate});
				my $startYear = epochToHuman($event->{startDate},"%y");
				my $startMonth = epochToHuman($event->{startDate},"%c");
				my $startDay = epochToHuman($event->{startDate},"%D");
				my $endYear = epochToHuman($event->{endDate},"%y");
				my $endMonth = epochToHuman($event->{endDate},"%c");
				my $endDay = epochToHuman($event->{endDate},"%D");
				for (my $i=0; $i<=$eventLength; $i++) {	
					my @date = WebGUI::DateTime::epochToArray(WebGUI::DateTime::addToDate($event->{startDate},0,0,$i));
					if ($date[1] == $thisMonthDate[1]) {
						push(@{$events{$date[2]}}, {
							description=>$event->{description},
							name=>$event->{name},
							'start.date.human'=>WebGUI::DateTime::epochToHuman($event->{startDate},"%z"),
							'start.time.human'=>WebGUI::DateTime::epochToHuman($event->{startDate},"%Z"),
							'start.date.epoch'=>$event->{startDate},
							'start.year'=>$startYear,
							'start.month'=>$startMonth,
							'start.day'=>$startDay,
							'end.date.human'=>WebGUI::DateTime::epochToHuman($event->{endDate},"%z"),
							'end.time.human'=>WebGUI::DateTime::epochToHuman($event->{endDate},"%Z"),
							'end.date.epoch'=>$event->{endDate},
							'end.year'=>$endYear,
							'end.month'=>$endMonth,
							'end.day'=>$endDay,
							'startEndYearMatch'=>($startYear eq $endYear),
							'startEndMonthMatch'=>($startMonth eq $endMonth),
							'startEndDayMatch'=>($startDay eq $endDay),
							isFirstDayOfEvent=>($i == 0),
							dateIsSameAsPrevious=>($startYear."-".$startMonth."-".$startDay eq $previous{start} 
								&& $endYear."-".$endMonth."-".$endDay eq $previous{end}),
							daysInEvent=>($eventLength+1),
							url=>WebGUI::URL::page('wid='.$_[0]->get("wobjectId").'&func=viewEvent&eid='.$event->{EventsCalendar_eventId})
							});
					}
				}
				$previous{start} = $startYear."-".$startMonth."-".$startDay;
				$previous{end} = $endYear."-".$endMonth."-".$endDay;
			}
			$sth->finish;

			my $dayOfWeekCounter = 1;
			my $firstDayInFirstWeek = WebGUI::DateTime::getFirstDayInMonthPosition($thisMonth);
			my $daysInMonth = WebGUI::DateTime::getDaysInMonth($thisMonth);
			my @prepad;
			while ($dayOfWeekCounter < $firstDayInFirstWeek) {
				push(@prepad,{
					count => $dayOfWeekCounter
					});
        			$dayOfWeekCounter++;
			} 
			my @date = WebGUI::DateTime::epochToArray($thisMonth);
			my @dayloop;
			for (my $dayCounter=1; $dayCounter <= $daysInMonth; $dayCounter++) {
				push(@dayloop, {
					dayOfWeek => $dayOfWeekCounter,
					day=>$dayCounter,
					isStartOfWeek=>($dayOfWeekCounter==1),
					isEndOfWeek=>($dayOfWeekCounter==7),
					isToday=>(WebGUI::DateTime::getDaysInInterval(
						WebGUI::DateTime::setToEpoch($date[0]."-".$date[1]."-".$dayCounter),
						WebGUI::DateTime::time()) == 0),
					event_loop=>\@{$events{$dayCounter}},
					url=>$events{$dayCounter}->[0]->{url}
					});
        			if ($dayOfWeekCounter == 7) {
                			$dayOfWeekCounter = 1;
       		 		} else {
                			$dayOfWeekCounter++;
        			}
			}
			my @postpad;
			while ($dayOfWeekCounter <= 7 && $dayOfWeekCounter > 1) {
				push(@postpad,{
					count => $dayOfWeekCounter
					});
        			$dayOfWeekCounter++;
			}
			push(@monthloop, {
				'daysInMonth'=>$daysInMonth,
				'day_loop'=>\@dayloop,
				'prepad_loop'=>\@prepad,
				'postpad_loop'=>\@postpad,
				'month'=>WebGUI::DateTime::getMonthName($date[1]),
				'year'=>$date[0]
				});
	#	}
	#	$row[$i-1] = "page";
	}
	$p = WebGUI::Paginator->new(WebGUI::URL::page("func=view&wid=".$_[0]->get("wobjectId")),$_[0]->get("paginateAfter"),"calPn");
	$p->setDataByArrayRef(\@monthloop);
	$var{month_loop} = $p->getPageData;
	$p->appendTemplateVars(\%var);
	$var{'sunday.label'} = WebGUI::DateTime::getDayName(7);
	$var{'monday.label'} = WebGUI::DateTime::getDayName(1);
	$var{'tuesday.label'} = WebGUI::DateTime::getDayName(2);
	$var{'wednesday.label'} = WebGUI::DateTime::getDayName(3);
	$var{'thursday.label'} = WebGUI::DateTime::getDayName(4);
	$var{'friday.label'} = WebGUI::DateTime::getDayName(5);
	$var{'saturday.label'} = WebGUI::DateTime::getDayName(6);
	$var{'sunday.label.short'} = substr(WebGUI::DateTime::getDayName(7),0,1);
	$var{'monday.label.short'} = substr(WebGUI::DateTime::getDayName(1),0,1);
	$var{'tuesday.label.short'} = substr(WebGUI::DateTime::getDayName(2),0,1);
	$var{'wednesday.label.short'} = substr(WebGUI::DateTime::getDayName(3),0,1);
	$var{'thursday.label.short'} = substr(WebGUI::DateTime::getDayName(4),0,1);
	$var{'friday.label.short'} = substr(WebGUI::DateTime::getDayName(5),0,1);
	$var{'saturday.label.short'} = substr(WebGUI::DateTime::getDayName(6),0,1);
	return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
}

#-------------------------------------------------------------------
sub www_viewEvent {
	$_[0]->logView() if ($session{setting}{passiveProfilingEnabled});
	my ($output, %event, %var, $id);
	tie %event, 'Tie::CPHash';
	%event = WebGUI::SQL->quickHash("select * from EventsCalendar_event where EventsCalendar_eventId=$session{form}{eid}",WebGUI::SQL->getSlave);
	$var{title} = $event{name};
	$var{"start.label"} =  WebGUI::International::get(14,$_[0]->get("namespace"));
	$var{"start.date"} = epochToHuman($event{startDate},"%z");
	$var{"start.time"} = epochToHuman($event{startDate},"%Z");
	$var{"end.label"} = WebGUI::International::get(15,$_[0]->get("namespace"));
	$var{"end.date"} = epochToHuman($event{endDate},"%z");
	$var{"end.time"} = epochToHuman($event{endDate},"%Z");
	$var{canEdit} = $_[0]->canEdit;
        $var{"edit.url"} = WebGUI::URL::page('func=editEvent&eid='.$session{form}{eid}.'&wid='.$session{form}{wid});
	$var{"edit.label"} = WebGUI::International::get(575);
        $var{"delete.url"} = WebGUI::URL::page('func=deleteEvent&eid='.$session{form}{eid}.'&wid='
		.$session{form}{wid}.'&rid='.$event{EventsCalendar_recurringId});
	$var{"delete.label"} = WebGUI::International::get(576);
	my $query = "select EventsCalendar_eventId from EventsCalendar_event where EventsCalendar_eventId<>$event{EventsCalendar_eventId}";
	$query .= " and wobjectId=".$_[0]->get("wobjectId") unless ($_[0]->get("isMaster"));
	$query .= " and startDate<=$event{startDate} order by startDate desc, endDate desc";
	($id) = WebGUI::SQL->quickArray($query,WebGUI::SQL->getSlave);
	$var{"previous.label"} = '&laquo;'.WebGUI::International::get(92,$_[0]->get("namespace"));
	$var{"previous.url"} = WebGUI::URL::page("func=viewEvent&wid=".$_[0]->get("wobjectId")."&eid=".$id) if ($id);
	$query = "select EventsCalendar_eventId from EventsCalendar_event where EventsCalendar_eventId<>$event{EventsCalendar_eventId}";
	$query .= " and wobjectId=".$_[0]->get("wobjectId") unless ($_[0]->get("isMaster"));
	$query .= " and startDate>=$event{startDate} order by startDate, endDate";
        ($id) = WebGUI::SQL->quickArray($query,WebGUI::SQL->getSlave);
        $var{"next.label"} = WebGUI::International::get(93,$_[0]->get("namespace")).'&raquo;';
        $var{"next.url"} = WebGUI::URL::page("func=viewEvent&wid=".$_[0]->get("wobjectId")."&eid=".$id) if ($id);
	$var{description} = $event{description};
	return $_[0]->processTemplate($_[0]->get("eventTemplateId"),\%var, "EventsCalendar/Event");
}

1;

