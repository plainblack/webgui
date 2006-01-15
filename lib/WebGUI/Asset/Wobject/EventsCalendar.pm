package WebGUI::Asset::Wobject::EventsCalendar;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::SQL;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
#sub canManage {
#	my $self = shift;
#	my $userId = shift || $self->session->user->userId;
#	if ($userId eq $self->getValue("ownerUserId")) {
#		return 1;
#	}
#	return 0 unless $self->canView($userId);
#	return $self->session->user->isInGroup($self->getValue("groupIdManage"),$userId);
#}


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session,"Asset_EventsCalendar");
	push(@{$definition}, {
		assetName=>$i18n->get('assetName'),
		uiLevel => 9,
		icon=>'calendar.gif',
		tableName=>'EventsCalendar',
		className=>'WebGUI::Asset::Wobject::EventsCalendar',
		properties=>{
			templateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000022'
			},
			eventTemplateId =>{
				fieldType=>"template",
				defaultValue=>'PBtmpl0000000000000023'
			},
			scope =>{
				fieldType=>"selectBox",
				defaultValue=>'0'
			},
			startMonth=>{
				fieldType=>"selectBox",
				defaultValue=>"current"
			},
			endMonth=>{
				fieldType=>"selectBox",
				defaultValue=>"after12"
			},
			defaultMonth=>{
				fieldType=>"selectBox",
				defaultValue=>"current"
			},
			paginateAfter=>{
				fieldType=>"integer",
				defaultValue=>1
			}
		}
	});
        return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 epochToArray ( epoch )

Returns an array date. 

=head3 epoch

The number of seconds since January 1, 1970.

=cut

sub epochToArray {
	my $self = shift;
	my $timeZone = $self->session->user->profileField("timeZone") || "America/Chicago";
	use DateTime;
	return map {$_ += 0} split / /, DateTime->from_epoch( epoch =>shift, time_zone=>$timeZone)->strftime("%Y %m %d %H %M %S");
}



#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session,"Asset_EventsCalendar");
	$tabform->getTab("properties")->selectBox(
		-name=>"scope",
		-label=>$i18n->get(507),
		-hoverHelp=>$i18n->get('507 description'),
		-value=>[$self->getValue("scope")],
		-options=>{
			0=>$i18n->get(508),
			1=>$i18n->get(510),
			2=>$i18n->get(509),
		}
	);
 	$tabform->getTab("display")->template(
 		-name=>"templateId",
		-label=>$i18n->get(94),
		-hoverHelp=>$i18n->get('94 description'),
		-value=>$self->getValue('templateId'),
		-namespace=>"EventsCalendar"
	);
 	$tabform->getTab("display")->template(
 		-name=>"eventTemplateId",
		-label=>$i18n->get(80),
		-hoverHelp=>$i18n->get('80 description'),
		-value=>$self->getValue('eventTemplateId'),
		-namespace=>"EventsCalendar/Event",
	);
	$tabform->getTab("display")->selectBox(
		-name=>"startMonth",
		-options=>{
			"january"=>$i18n->get('january'),
			"now"=>$i18n->get(98),
			"current"=>$i18n->get(82),
			"first"=>$i18n->get(83)
		},
		-label=>$i18n->get(81),
		-hoverHelp=>$i18n->get('81 description'),
		-value=>[$self->getValue("startMonth")]
	);
	my %options;
	tie %options, 'Tie::IxHash';
	%options = (
		"last"=>$i18n->get(85),
		"after12"=>$i18n->get(86),
		"after9"=$i18n->get(87),
		"after6"=>$i18n->get(88),
		"after3"=>$i18n->get(89),
		"current"=>$i18n->get(82)
	);
	$tabform->getTab("display")->selectBox(
		-name=>"endMonth",
		-options=>\%options,
		-label=>$i18n->get(84),
		-hoverHelp=>$i18n->get('84 description'),
		-value=>[$self->getValue("endMonth")]
	);
	$tabform->getTab("display")->selectBox(
		-name=>"defaultMonth",
		-options=>{
			"current"=>$i18n->get(82),
			"last"=>$i18n->get(85),
			"first"=>$i18n->get(83)
		},
		-label=>$i18n->get(90),
		-hoverHelp=>$i18n->get('90 description'),
		-value=>[$self->getValue("defaultMonth")]
	);
	$tabform->getTab("display")->integer(
		-name=>"paginateAfter",
		-label=>$i18n->get(19),
		-hoverHelp=>$i18n->get('19 description'),
		-value=>$self->getValue("paginateAfter")
	);
	return $tabform;
}



#-------------------------------------------------------------------
sub view {
	my $self = shift;  
	my $i18n = WebGUI::International->new($self->session,"Asset_EventsCalendar");
	#define default view month range.  Note that this could be different from 
	#the range a user is allowed to view - set by the events calendar limitations.
	my $monthRangeLength = int($self->get("paginateAfter"));
	# Let's limit the range to 72 for now; later we can make it definable in the calendar itself.
	$monthRangeLength = 1 if ($monthRangeLength < 0);
	$monthRangeLength = 72 if ($monthRangeLength > 72);
	#monthRangeLength is the number of months the user wishes to view
	# or the default number of the months per page the wobject is set to display.
	my $calMonthStart = $self->session->form->process("calMonthStart") || 1;
	$calMonthStart = int($calMonthStart);
	my $calMonthEnd = $self->session->form->process("calMonthEnd") || ($calMonthStart + $monthRangeLength - 1);
	$calMonthEnd = int($calMonthEnd);
	$calMonthEnd =  ($calMonthStart + 72) if ($calMonthStart < $calMonthEnd - 72);
	$calMonthEnd = $calMonthStart if ($calMonthEnd < $calMonthStart);
	#used for pagination
	$monthRangeLength = $calMonthEnd - $calMonthStart + 1;

	my ( $junk, $sameDate, $p, @list, $date, $flag, %previous, $maxDate, $minDate);  
	my $monthloop;
	my $scope = $self->getValue("scope");
	my $children;
	if ($scope == 0) { #calendar's scope is regular (immediate descendants)
		$children = $self->getLineage(["children"],{returnObjects=>1,
			includeOnlyClasses=>["WebGUI::Asset::Event"]});
	} elsif ($scope == 2) { #calendar is master
		$children = $self->getLineage(["descendants"],{returnObjects=>1,
			includeOnlyClasses=>["WebGUI::Asset::Event"]});
	} elsif ($scope == 1) { #calendar is global
		$children = WebGUI::Asset::getRoot()->getLineage(["descendants"],{returnObjects=>1,
			includeOnlyClasses=>["WebGUI::Asset::Event"]}); 
	}

	my $startMonth = $self->getValue("startMonth");
	#define range of allowed months from the wobject settings.
	if ($startMonth eq "first") {
		#Don't really do anything - leading months will not be pushed if there are no events.
		$minDate = $self->session->datetime->time();
	} elsif ($startMonth eq "january") {
		$minDate = $self->session->datetime->humanToEpoch($self->session->datetime->epochToHuman("","%y")."-01-01 00:00:00");
	} else {
		$minDate = $self->session->datetime->time();
	}
	my $startsNow = 0;
	unless ($self->get("startMonth") eq "now") {
		($minDate,$junk) = $self->session->datetime->monthStartEnd($minDate);
	} else { $startsNow = 1;}
	tie %previous, 'Tie::CPHash'; 
	#This merely limits the months to publish.  Month's processing is skipped if 
	#the month is after the maxDate.
	my $endMonth = $self->getValue("endMonth");
	if ($endMonth eq "last") {
		$maxDate = $self->session->datetime->addToDate($minDate,99,0,0);
	} elsif ($endMonth eq "after12") {
		$maxDate = $self->session->datetime->addToDate($minDate,1,0,0); 
	} elsif ($endMonth eq "after9") {
		$maxDate = $self->session->datetime->addToDate($minDate,0,9,0); 
	} elsif ($endMonth eq "after6") {
		$maxDate = $self->session->datetime->addToDate($minDate,0,6,0); 
	} elsif ($endMonth eq "after3") {
		$maxDate = $self->session->datetime->addToDate($minDate,0,3,0);
	} elsif ($endMonth eq "current") {
		$maxDate = $self->session->datetime->addToDate($minDate,0,1,0);
	}
	#$self->session->errorHandler->warn("calMonthStart:".$calMonthStart." calMonthEnd:".$calMonthEnd);
	my @now = $self->epochToArray($self->session->datetime->time());
	my $calHasEvent = 0;
	#monthcount minus i is the number of months remaining to be processed.
	for (my $i=$calMonthStart;$i<=$calMonthEnd;$i++) {
		#for each month, do the following....
		my $monthHasEvent = 0;
		my $thisMonth = $self->session->datetime->addToDate($minDate,0,($i-1),0);
		my ($monthStart, $monthEnd) = $self->session->datetime->monthStartEnd($thisMonth);
		my @thisMonthDate = $self->epochToArray($thisMonth);
		#Check month to see if it is in the allowed month range. End loop if it's not.
		if ($thisMonth > $maxDate) {
			$i = $calMonthEnd;
			next;
		}
		
		my %events;
		my %previous;

		foreach my $event (@{$children}) {
			if (ref $event eq "WebGUI::Asset::Event") {
				my $eventStartDate = $event->get("eventStartDate");
				my $eventEndDate = $event->get("eventEndDate");
				if ($eventStartDate > $eventEndDate) {
					#Fix bad data.  Everything that has a beginning must have an end [no earlier than its beginning].
					$event->update({ "eventEndDate"=>$eventStartDate });
				}
				#Prune events that don't appear in this month.
				next if (($eventStartDate > $monthEnd) || ($eventEndDate < $monthStart));
				#Prune events that have already ended if $startsNow
				next if (($eventEndDate < $minDate) && $startsNow);
				#Hide this event unless we are allowed to see it.  Funny that each event has 4 date/time pairs.
				next unless $event->canView; 
				my $eventLength = $self->session->datetime->getDaysInInterval($eventStartDate,$eventEndDate);
				my ($startYear, $startMonth, $startDay, $startDate, $startTime, $startAmPm, $startDayOfWeek) = split " ", 
					$self->session->datetime->epochToHuman($eventStartDate, "%y %c %D %z %Z %w");
				my ($endYear, $endMonth, $endDay, $endDate, $endTime, $endAmPm, $endDayOfWeek) = split " ", 
					$self->session->datetime->epochToHuman($eventEndDate, "%y %c %D %z %Z %w");
				my $eventCycleStart = 0;
				# Fast-Forward Event Cycle to this month (for events spanning multiple months)
				$eventCycleStart = ($self->session->datetime->getDaysInInterval($eventStartDate,$monthStart) - 1) if ($eventStartDate < $monthStart);
				# also, skip leading days of this event if $startsNow is true.  Doesn't work in Events List.  Oh well.
		#		$eventCycleStart = ($self->session->datetime->getDaysInInterval($eventStartDate,time)) if (($eventStartDate < time) && ($startsNow));
				# by default, stop processing this event at the end of its length.
				my $eventCycleStop = ($eventLength);
				#cycle through each day in the event, pushing the event's day listing into the proper day.
				for (my $i=$eventCycleStart; $i<=$eventCycleStop; $i++) {
					#create an array for the specific day in the event.
					my @date = $self->epochToArray($self->session->datetime->addToDate($eventStartDate,0,0,$i));
					# if the event goes past the end of this month, halt the loop.  
					# No need to continue processing days that aren't in this month.
					if ($monthEnd < ($self->session->datetime->addToDate($eventStartDate,0,0,$i) - 1)) {
						$i = ($eventCycleStop + 2);
						next;
					}
					#this conditional used to only test if we are in the proper month... 
					#Now also test to see if we're at the maxDate yet and after the minDate.
					if (($date[1] == $thisMonthDate[1])  && ($self->session->datetime->addToDate($eventStartDate,0,0,$i) <= ($maxDate + 2678400))){
						push(@{$events{$date[2]}}, {
							description=>$event->get("description"),
							name=>$event->get("title"),
							'start.date.human'=>$startDate,
							'start.time.human'=>$startTime." ".$startAmPm,
							'start.date.epoch'=>$eventStartDate,
							'start.year'=>$startYear,
							'start.month'=>$startMonth,
							'start.day'=>$startDay,
							'start.day.dayOfWeek'=>$startDayOfWeek,
							'end.date.human'=>$endDate,
							'end.time.human'=>$endTime." ".$endAmPm,
							'end.date.epoch'=>$eventEndDate,
							'end.year'=>$endYear,
							'end.month'=>$endMonth,
							'end.day'=>$endDay,
							'end.day.dayOfWeek'=>$endDayOfWeek,
							'startEndYearMatch'=>($startYear eq $endYear),
							'startEndMonthMatch'=>($startMonth eq $endMonth),
							'startEndDayMatch'=>($startDay eq $endDay),
							isFirstDayOfEvent=>($i == 0),
							dateIsSameAsPrevious=>($startYear."-".$startMonth."-".$startDay eq $previous{start} 
								&& $endYear."-".$endMonth."-".$endDay eq $previous{end}),
							daysInEvent=>($eventLength+1),
							url=>$event->getUrl()
						});
						$monthHasEvent = 1;
						$calHasEvent = 1;
					}
				}

				$previous{start} = $startYear."-".$startMonth."-".$startDay;
				$previous{end} = $endYear."-".$endMonth."-".$endDay;
			}
		}
	#	if (($startsNow || ($startMonth eq "first")) && ($calHasEvent == 0)) {
			#Let's process an extra month if this month had no events, 
			#and if we're at the beginning of the calendar, and if 
			#the calendar is supposed to start with the first event or now.
	#		$calMonthEnd++ unless $monthHasEvent;
	#		next unless $monthHasEvent;
	#	}
		my $dayOfWeekCounter = 1;
		my $firstDayInFirstWeek = $self->session->datetime->getFirstDayInMonthPosition($thisMonth);
		my $daysInMonth = $self->session->datetime->getDaysInMonth($thisMonth);
		my @prepad;
		while (($dayOfWeekCounter <= $firstDayInFirstWeek) and $firstDayInFirstWeek != 7) {
			push(@prepad,{
				count => $dayOfWeekCounter
			});
			$dayOfWeekCounter++;
		}
		my @date = $self->epochToArray($thisMonth);
		my @dayloop;
		for (my $dayCounter=1; $dayCounter <= $daysInMonth; $dayCounter++) {
			#----------------------------------------------------------------------------
			#sort each day's events here - still needs to be done!
			#----------------------------------------------------------------------------
			push(@dayloop, {
				dayOfWeek => $dayOfWeekCounter,
				day=>$dayCounter,
				isStartOfWeek=>($dayOfWeekCounter==1),
				isEndOfWeek=>($dayOfWeekCounter==7),
				isToday=>($date[0]."-".$date[1]."-".$dayCounter eq $now[0]."-".$now[1]."-".$now[2]),
				hasEvents=>(exists $events{$dayCounter}),
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
		push(@$monthloop, {
			'daysInMonth'=>$daysInMonth,
			'day_loop'=>\@dayloop,
			'prepad_loop'=>\@prepad,
			'postpad_loop'=>\@postpad,
			'month'=>$self->session->datetime->getMonthName($date[1]),
			'year'=>$date[0]
		});
	}
	my %var;
	$var{month_loop} = \@$monthloop;
	$var{"addevent.url"} = $self->getUrl().'?func=add;class=WebGUI::Asset::Event';
	$var{"addevent.label"} = $i18n->get(20);
	$var{'sunday.label'} = $self->session->datetime->getDayName(7);
	$var{'monday.label'} = $self->session->datetime->getDayName(1);
	$var{'tuesday.label'} = $self->session->datetime->getDayName(2);
	$var{'wednesday.label'} = $self->session->datetime->getDayName(3);
	$var{'thursday.label'} = $self->session->datetime->getDayName(4);
	$var{'friday.label'} = $self->session->datetime->getDayName(5);
	$var{'saturday.label'} = $self->session->datetime->getDayName(6);
	$var{'sunday.label.short'} = substr($self->session->datetime->getDayName(7),0,1);
	$var{'monday.label.short'} = substr($self->session->datetime->getDayName(1),0,1);
	$var{'tuesday.label.short'} = substr($self->session->datetime->getDayName(2),0,1);
	$var{'wednesday.label.short'} = substr($self->session->datetime->getDayName(3),0,1);
	$var{'thursday.label.short'} = substr($self->session->datetime->getDayName(4),0,1);
	$var{'friday.label.short'} = substr($self->session->datetime->getDayName(5),0,1);
	$var{'saturday.label.short'} = substr($self->session->datetime->getDayName(6),0,1);
	# Create pagination variables.
	$var{'pagination.pageCount.isMultiple'} = 1 if (($calMonthStart > 1) || ($maxDate > $self->session->datetime->addToDate($minDate,0,($monthRangeLength-1),0)));
	my $prevCalMonthStart = $calMonthStart - $monthRangeLength;
	my $nextCalMonthStart = $calMonthStart + $monthRangeLength;
	my $prevCalMonthEnd = $calMonthEnd - $monthRangeLength;
	my $nextCalMonthEnd = $calMonthEnd + $monthRangeLength;
	my $monthLabel;
	if ($monthRangeLength == 1) {
		$monthLabel = $i18n->get(560);
	} else {
		$monthLabel = $i18n->get(561);
	}
	$var{'pagination.previousPageUrl'} = 
		$self->getUrl.'?calMonthStart='.$prevCalMonthStart.';calMonthEnd='.$prevCalMonthEnd;
	$var{'pagination.previousPage'} = '<form method="GET" style="inline;" action="'.
		$self->getUrl.'?calMonthStart='.$calMonthStart.
		';reload='.$self->session->id->generate().'"><a href="'.$self->getUrl.
		'?calMonthStart='.$prevCalMonthStart.';calMonthEnd='.$prevCalMonthEnd.'">'.
		$i18n->get(558)." ".$monthRangeLength." ".
		$monthLabel.'</a>';
	$var{'pagination.nextPageUrl'} = $self->getUrl.
		'?calMonthStart='.$nextCalMonthStart.';calMonthEnd='.$nextCalMonthEnd;
	$var{'pagination.nextPage'} = '<a href="'.$self->getUrl.
		'?calMonthStart='.$nextCalMonthStart.';calMonthEnd='.$nextCalMonthEnd.'">'.
		$i18n->get(559)." ".$monthRangeLength." ".
		$monthLabel.'</a></form>';
	$var{'pagination.pageList.upTo20'} = '<select size="1" name="calMonthEnd">
		<option value="'.($calMonthStart).'">1 '.$i18n->get(560).'</option>
		<option value="'.(1+$calMonthStart).'">2 '.$i18n->get(561).'</option>
		<option value="'.(2+$calMonthStart).'">3 '.$i18n->get(561).'</option>
		<option value="'.(3+$calMonthStart).'">4 '.$i18n->get(561).'</option>
		<option value="'.(5+$calMonthStart).'">6 '.$i18n->get(561).'</option>
		<option value="'.(8+$calMonthStart).'">9 '.$i18n->get(561).'</option>
		<option value="'.(11+$calMonthStart).'">12 '.$i18n->get(561).'</option></select>
		<input type="submit" value="Go" name="Go" />';
	#use Data::Dumper; return '<pre>'.Dumper(\%var).'</pre>';
	my $vars = \%var;
	return $self->processTemplate($vars,$self->get("templateId"));
	
}


#-------------------------------------------------------------------
=head2 www_view ( )

Overwrite www_view method and call the superclass object, passing in a 1 to disable cache

=cut

sub www_view {
	my $self = shift;
	$self->SUPER::www_view(1);
	
}

1;

