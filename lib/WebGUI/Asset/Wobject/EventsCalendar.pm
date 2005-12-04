package WebGUI::Asset::Wobject::EventsCalendar;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::ErrorHandler;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Id;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Asset::Wobject;

our @ISA = qw(WebGUI::Asset::Wobject);


#-------------------------------------------------------------------
#sub canManage {
#	my $self = shift;
#	my $userId = shift || $session{user}{userId};
#	if ($userId eq $self->getValue("ownerUserId")) {
#		return 1;
#	}
#	return 0 unless $self->canView($userId);
#	return WebGUI::Grouping::isInGroup($self->getValue("groupIdManage"),$userId);
#}


#-------------------------------------------------------------------
sub definition {
	my $class = shift;
	my $definition = shift;
	push(@{$definition}, {
		assetName=>WebGUI::International::get('assetName',"Asset_EventsCalendar"),
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
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 epochToArray ( epoch )

Returns an array date. 

=head3 epoch

The number of seconds since January 1, 1970.

=cut

sub epochToArray {
	my $timeZone = $session{user}{timeZone} || "America/Chicago";
	use DateTime;
	my $dt = DateTime->from_epoch( epoch =>shift, time_zone=>$timeZone);
	my @date = split / /, $dt->strftime("%Y %m %d %H %M %S");
	@date = map {$_ += 0} @date;
	return @date;
}



#-------------------------------------------------------------------
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	$tabform->getTab("properties")->selectBox(
		-name=>"scope",
		-label=>WebGUI::International::get(507,"Asset_EventsCalendar"),
		-hoverHelp=>WebGUI::International::get('507 description',"Asset_EventsCalendar"),
		-value=>[$self->getValue("scope")],
		-options=>{
			0=>WebGUI::International::get(508,"Asset_EventsCalendar"),
			1=>WebGUI::International::get(510,"Asset_EventsCalendar"),
			2=>WebGUI::International::get(509,"Asset_EventsCalendar"),
		}
	);
 	$tabform->getTab("display")->template(
 		-name=>"templateId",
		-label=>WebGUI::International::get(94,"Asset_EventsCalendar"),
		-hoverHelp=>WebGUI::International::get('94 description',"Asset_EventsCalendar"),
		-value=>$self->getValue('templateId'),
		-namespace=>"EventsCalendar"
	);
 	$tabform->getTab("display")->template(
 		-name=>"eventTemplateId",
		-label=>WebGUI::International::get(80,"Asset_EventsCalendar"),
		-hoverHelp=>WebGUI::International::get('80 description',"Asset_EventsCalendar"),
		-value=>$self->getValue('eventTemplateId'),
		-namespace=>"EventsCalendar/Event",
	);
	$tabform->getTab("display")->selectBox(
		-name=>"startMonth",
		-options=>{
			"january"=>WebGUI::International::get('january','DateTime'),
			"now"=>WebGUI::International::get(98,"Asset_EventsCalendar"),
			"current"=>WebGUI::International::get(82,"Asset_EventsCalendar"),
			"first"=>WebGUI::International::get(83,"Asset_EventsCalendar")
		},
		-label=>WebGUI::International::get(81,"Asset_EventsCalendar"),
		-hoverHelp=>WebGUI::International::get('81 description',"Asset_EventsCalendar"),
		-value=>[$self->getValue("startMonth")]
	);
	my %options;
	tie %options, 'Tie::IxHash';
	%options = (
		"last"=>WebGUI::International::get(85,"Asset_EventsCalendar"),
		"after12"=>WebGUI::International::get(86,"Asset_EventsCalendar"),
		"after9"=>WebGUI::International::get(87,"Asset_EventsCalendar"),
		"after6"=>WebGUI::International::get(88,"Asset_EventsCalendar"),
		"after3"=>WebGUI::International::get(89,"Asset_EventsCalendar"),
		"current"=>WebGUI::International::get(82,"Asset_EventsCalendar")
	);
	$tabform->getTab("display")->selectBox(
		-name=>"endMonth",
		-options=>\%options,
		-label=>WebGUI::International::get(84,"Asset_EventsCalendar"),
		-hoverHelp=>WebGUI::International::get('84 description',"Asset_EventsCalendar"),
		-value=>[$self->getValue("endMonth")]
	);
	$tabform->getTab("display")->selectBox(
		-name=>"defaultMonth",
		-options=>{
			"current"=>WebGUI::International::get(82,"Asset_EventsCalendar"),
			"last"=>WebGUI::International::get(85,"Asset_EventsCalendar"),
			"first"=>WebGUI::International::get(83,"Asset_EventsCalendar")
		},
		-label=>WebGUI::International::get(90,"Asset_EventsCalendar"),
		-hoverHelp=>WebGUI::International::get('90 description',"Asset_EventsCalendar"),
		-value=>[$self->getValue("defaultMonth")]
	);
	$tabform->getTab("display")->integer(
		-name=>"paginateAfter",
		-label=>WebGUI::International::get(19,"Asset_EventsCalendar"),
		-hoverHelp=>WebGUI::International::get('19 description',"Asset_EventsCalendar"),
		-value=>$self->getValue("paginateAfter")
	);
	return $tabform;
}



#-------------------------------------------------------------------
sub view {
	my $self = shift;  
	#define default view month range.  Note that this could be different from 
	#the range a user is allowed to view - set by the events calendar limitations.
	my $monthRangeLength = int($self->get("paginateAfter"));
	# Let's limit the range to 72 for now; later we can make it definable in the calendar itself.
	$monthRangeLength = 1 if ($monthRangeLength < 0);
	$monthRangeLength = 72 if ($monthRangeLength > 72);
	#monthRangeLength is the number of months the user wishes to view
	# or the default number of the months per page the wobject is set to display.
	my $calMonthStart = $session{form}{calMonthStart} || 1;
	$calMonthStart = int($calMonthStart);
	my $calMonthEnd = $session{form}{calMonthEnd} || ($calMonthStart + $monthRangeLength - 1);
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
		$minDate = WebGUI::DateTime::time();
	} elsif ($startMonth eq "january") {
		$minDate = WebGUI::DateTime::humanToEpoch(WebGUI::DateTime::epochToHuman("","%y")."-01-01 00:00:00");
	} else {
		$minDate = WebGUI::DateTime::time();
	}
	my $startsNow = 0;
	unless ($self->get("startMonth") eq "now") {
		($minDate,$junk) = WebGUI::DateTime::monthStartEnd($minDate);
	} else { $startsNow = 1;}
	tie %previous, 'Tie::CPHash'; 
	#This merely limits the months to publish.  Month's processing is skipped if 
	#the month is after the maxDate.
	my $endMonth = $self->getValue("endMonth");
	if ($endMonth eq "last") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,99,0,0);
	} elsif ($endMonth eq "after12") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,1,0,0); 
	} elsif ($endMonth eq "after9") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,0,9,0); 
	} elsif ($endMonth eq "after6") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,0,6,0); 
	} elsif ($endMonth eq "after3") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,0,3,0);
	} elsif ($endMonth eq "current") {
		$maxDate = WebGUI::DateTime::addToDate($minDate,0,1,0);
	}
	#WebGUI::ErrorHandler::warn("calMonthStart:".$calMonthStart." calMonthEnd:".$calMonthEnd);
	my @now = epochToArray(WebGUI::DateTime::time());
	my $calHasEvent = 0;
	#monthcount minus i is the number of months remaining to be processed.
	for (my $i=$calMonthStart;$i<=$calMonthEnd;$i++) {
		#for each month, do the following....
		my $monthHasEvent = 0;
		my $thisMonth = WebGUI::DateTime::addToDate($minDate,0,($i-1),0);
		my ($monthStart, $monthEnd) = WebGUI::DateTime::monthStartEnd($thisMonth);
		my @thisMonthDate = epochToArray($thisMonth);
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
				my $eventLength = WebGUI::DateTime::getDaysInInterval($eventStartDate,$eventEndDate);
				my ($startYear, $startMonth, $startDay, $startDate, $startTime, $startAmPm, $startDayOfWeek) = split " ", 
					WebGUI::DateTime::epochToHuman($eventStartDate, "%y %c %D %z %Z %w");
				my ($endYear, $endMonth, $endDay, $endDate, $endTime, $endAmPm, $endDayOfWeek) = split " ", 
					WebGUI::DateTime::epochToHuman($eventEndDate, "%y %c %D %z %Z %w");
				my $eventCycleStart = 0;
				# Fast-Forward Event Cycle to this month (for events spanning multiple months)
				$eventCycleStart = (WebGUI::DateTime::getDaysInInterval($eventStartDate,$monthStart) - 1) if ($eventStartDate < $monthStart);
				# also, skip leading days of this event if $startsNow is true.  Doesn't work in Events List.  Oh well.
		#		$eventCycleStart = (WebGUI::DateTime::getDaysInInterval($eventStartDate,time)) if (($eventStartDate < time) && ($startsNow));
				# by default, stop processing this event at the end of its length.
				my $eventCycleStop = ($eventLength);
				#cycle through each day in the event, pushing the event's day listing into the proper day.
				for (my $i=$eventCycleStart; $i<=$eventCycleStop; $i++) {
					#create an array for the specific day in the event.
					my @date = epochToArray(WebGUI::DateTime::addToDate($eventStartDate,0,0,$i));
					# if the event goes past the end of this month, halt the loop.  
					# No need to continue processing days that aren't in this month.
					if ($monthEnd < (WebGUI::DateTime::addToDate($eventStartDate,0,0,$i) - 1)) {
						$i = ($eventCycleStop + 2);
						next;
					}
					#this conditional used to only test if we are in the proper month... 
					#Now also test to see if we're at the maxDate yet and after the minDate.
					if (($date[1] == $thisMonthDate[1])  && (WebGUI::DateTime::addToDate($eventStartDate,0,0,$i) <= ($maxDate + 2678400))){
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
		my $firstDayInFirstWeek = WebGUI::DateTime::getFirstDayInMonthPosition($thisMonth);
		my $daysInMonth = WebGUI::DateTime::getDaysInMonth($thisMonth);
		my @prepad;
		while ($dayOfWeekCounter < $firstDayInFirstWeek) {
			push(@prepad,{
				count => $dayOfWeekCounter
			});
			$dayOfWeekCounter++;
		}
		my @date = epochToArray($thisMonth);
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
			'month'=>WebGUI::DateTime::getMonthName($date[1]),
			'year'=>$date[0]
		});
	}
	my %var;
	$var{month_loop} = \@$monthloop;
	$var{"addevent.url"} = $self->getUrl().'?func=add;class=WebGUI::Asset::Event';
	$var{"addevent.label"} = WebGUI::International::get(20,"Asset_EventsCalendar");
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
	# Create pagination variables.
	$var{'pagination.pageCount.isMultiple'} = 1 if (($calMonthStart > 1) || ($maxDate > WebGUI::DateTime::addToDate($minDate,0,($monthRangeLength-1),0)));
	my $prevCalMonthStart = $calMonthStart - $monthRangeLength;
	my $nextCalMonthStart = $calMonthStart + $monthRangeLength;
	my $prevCalMonthEnd = $calMonthEnd - $monthRangeLength;
	my $nextCalMonthEnd = $calMonthEnd + $monthRangeLength;
	my $monthLabel;
	if ($monthRangeLength == 1) {
		$monthLabel = WebGUI::International::get(560,"Asset_EventsCalendar");
	} else {
		$monthLabel = WebGUI::International::get(561,"Asset_EventsCalendar");
	}
	$var{'pagination.previousPageUrl'} = 
		$self->getUrl.'?calMonthStart='.$prevCalMonthStart.';calMonthEnd='.$prevCalMonthEnd;
	$var{'pagination.previousPage'} = '<form method="GET" style="inline;" action="'.
		$self->getUrl.'?calMonthStart='.$calMonthStart.
		';reload='.WebGUI::Id::generate().'"><a href="'.$self->getUrl.
		'?calMonthStart='.$prevCalMonthStart.';calMonthEnd='.$prevCalMonthEnd.'">'.
		WebGUI::International::get(558,"Asset_EventsCalendar")." ".$monthRangeLength." ".
		$monthLabel.'</a>';
	$var{'pagination.nextPageUrl'} = $self->getUrl.
		'?calMonthStart='.$nextCalMonthStart.';calMonthEnd='.$nextCalMonthEnd;
	$var{'pagination.nextPage'} = '<a href="'.$self->getUrl.
		'?calMonthStart='.$nextCalMonthStart.';calMonthEnd='.$nextCalMonthEnd.'">'.
		WebGUI::International::get(559,"Asset_EventsCalendar")." ".$monthRangeLength." ".
		$monthLabel.'</a></form>';
	$var{'pagination.pageList.upTo20'} = '<select size="1" name="calMonthEnd">
		<option value="'.($calMonthStart).'">1 '.WebGUI::International::get(560,"Asset_EventsCalendar").'</option>
		<option value="'.(1+$calMonthStart).'">2 '.WebGUI::International::get(561,"Asset_EventsCalendar").'</option>
		<option value="'.(2+$calMonthStart).'">3 '.WebGUI::International::get(561,"Asset_EventsCalendar").'</option>
		<option value="'.(3+$calMonthStart).'">4 '.WebGUI::International::get(561,"Asset_EventsCalendar").'</option>
		<option value="'.(5+$calMonthStart).'">6 '.WebGUI::International::get(561,"Asset_EventsCalendar").'</option>
		<option value="'.(8+$calMonthStart).'">9 '.WebGUI::International::get(561,"Asset_EventsCalendar").'</option>
		<option value="'.(11+$calMonthStart).'">12 '.WebGUI::International::get(561,"Asset_EventsCalendar").'</option></select>
		<input type="submit" value="Go" name="Go" />';
	#use Data::Dumper; return '<pre>'.Dumper(\%var).'</pre>';
	my $vars = \%var;
	return $self->processTemplate($vars,$self->get("templateId"));
	
}

#-------------------------------------------------------------------
#sub www_edit {
#	my $self = shift;
#	return WebGUI::Privilege::insufficient() unless $self->canEdit;
#	$self->getAdminConsole->setHelp("events calendar add/edit","Asset_EventsCalendar");
#	return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("12","Asset_EventsCalendar"));
#}


#-------------------------------------------------------------------
=head2 www_view ( )

Overwrite www_view method and call the superclass object, passing in a 1 to disable cache

=cut

sub www_view {
	my $self = shift;
	$self->SUPER::www_view(1);
	
}

1;

