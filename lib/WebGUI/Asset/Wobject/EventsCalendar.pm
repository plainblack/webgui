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
use WebGUI::Macro;
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
				fieldType=>"selectList",
				defaultValue=>'0'
			},
		#	type =>{
		#		fieldType=>"selectList",
		#		defaultValue=>'0'
		#	},
		#	groupIdManage =>{
		#		fieldType=>"group",
		#		defaultValue=>'4'
		#	},
			startMonth=>{
				fieldType=>"selectList",
				defaultValue=>"current"
			},
			endMonth=>{
				fieldType=>"selectList",
				defaultValue=>"after12"
			},
			defaultMonth=>{
				fieldType=>"selectList",
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
sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	#	$tabform->getTab("properties")->selectList(
	#		-name=>"type",
	#		-label=>WebGUI::International::get(501,"Asset_EventsCalendar"),
	#		-value=>[$self->getValue("type")],
	#		-options=>{
	#			0=>WebGUI::International::get(502,"Asset_EventsCalendar"),
	#			1=>WebGUI::International::get(503,"Asset_EventsCalendar"),
	#			2=>WebGUI::International::get(504,"Asset_EventsCalendar"),
	#			3=>WebGUI::International::get(505,"Asset_EventsCalendar"),
	#			4=>WebGUI::International::get(506,"Asset_EventsCalendar")
	#		},
	#	);
		$tabform->getTab("properties")->selectList(
			-name=>"scope",
			-label=>WebGUI::International::get(507,"Asset_EventsCalendar"),
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
			-value=>$self->getValue('templateId'),
			-namespace=>"EventsCalendar"
		);
   	$tabform->getTab("display")->template(
   		-name=>"eventTemplateId",
			-label=>WebGUI::International::get(80,"Asset_EventsCalendar"),
			-value=>$self->getValue('eventTemplateId'),
			-namespace=>"EventsCalendar/Event",
			-afterEdit=>'func=edit&wid='.$self->get("wobjectId")
		);
		$tabform->getTab("display")->selectList(
			-name=>"startMonth",
			-options=>{
				"january"=>WebGUI::International::get('january','Asset_EventsCalendar'),
				"now"=>WebGUI::International::get(98,"Asset_EventsCalendar"),
				"current"=>WebGUI::International::get(82,"Asset_EventsCalendar"),
				"first"=>WebGUI::International::get(83,"Asset_EventsCalendar")
			},
			-label=>WebGUI::International::get(81,"Asset_EventsCalendar"),
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
		$tabform->getTab("display")->selectList(
			-name=>"endMonth",
			-options=>\%options,
			-label=>WebGUI::International::get(84,"Asset_EventsCalendar"),
			-value=>[$self->getValue("endMonth")]
		);
		$tabform->getTab("display")->selectList(
			-name=>"defaultMonth",
			-options=>{
				"current"=>WebGUI::International::get(82,"Asset_EventsCalendar"),
				"last"=>WebGUI::International::get(85,"Asset_EventsCalendar"),
				"first"=>WebGUI::International::get(83,"Asset_EventsCalendar")
			},
			-label=>WebGUI::International::get(90,"Asset_EventsCalendar"),
			-value=>[$self->getValue("defaultMonth")]
		);
		$tabform->getTab("display")->integer(
			-name=>"paginateAfter",
			-label=>WebGUI::International::get(19,"Asset_EventsCalendar"),
			-value=>$self->getValue("paginateAfter")
		);
	#	$tabform->getTab("security")->group(
	#		-name=>"groupIdManage",
	#		-label=>WebGUI::International::get(500,"Asset_EventsCalendar"),
	#		-value=>[$self->getValue("groupIdManage")],
	#		-uiLevel=>6
	#	);
	return $tabform;
}

#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/calendar.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/calendar.gif';
}

#-------------------------------------------------------------------
sub getName {
        return WebGUI::International::get(2,"Asset_EventsCalendar");
}


#-------------------------------------------------------------------
sub getUiLevel {
	return 9;
}


#-------------------------------------------------------------------
sub view {
	
	#  All of this really needs to be redone like the old 
	#  EventsCalendar... except this time using getLineage to 
	#  filter instead of doing all sorts of pruning.  Also, caching
	#  needs to be re-enabled.  Also, see the note below at line
	#  407 - each dayloop event array needs to be sorted by startTime.
	
	
	my $self = shift;  
	#define default view month range.  Note that this could be different from 
	#the range a user is allowed to view - set by the events calendar limitations.
	my $monthRangeLength = int($self->getValue("paginateAfter"));
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

	#had to disable caching because each event can have its own security. 
	# It can be re-added, of course.

	my $scope = $self->getValue("scope");
	my $children;
	# get All My Children.
	if ($scope == 0) { #calendar's scope is regular (immediate descendants)
		$children = $self->getLineage(["children"],{returnObjects=>1,
			includeOnlyClasses=>["WebGUI::Asset::Event","WebGUI::Asset::Relation"]});
	} elsif ($scope == 2) { #calendar is master
		$children = $self->getLineage(["descendants"],{returnObjects=>1,
			includeOnlyClasses=>["WebGUI::Asset::Event","WebGUI::Asset::Relation"]});
	} elsif ($scope == 1) { #calendar is global
		$children = WebGUI::Asset::getRoot()->getLineage(["descendants"],{returnObjects=>1,
			includeOnlyClasses=>["WebGUI::Asset::Event","WebGUI::Asset::Relation"]}); 
	}
	# get Type of Calendar
#	my $calType = $self->getValue("type");

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

	my @now = WebGUI::DateTime::epochToArray(WebGUI::DateTime::time());
	my $calHasEvent = 0;
	#monthcount minus i is the number of months remaining to be processed.
	for (my $i=$calMonthStart;$i<=$calMonthEnd;$i++) {
		#for each month, do the following....
		my $monthHasEvent = 0;
		my $thisMonth = WebGUI::DateTime::addToDate($minDate,0,($i-1),0);
		my ($monthStart, $monthEnd) = WebGUI::DateTime::monthStartEnd($thisMonth);
		my @thisMonthDate = WebGUI::DateTime::epochToArray($thisMonth);
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
				# only display events for this person's Personal Calendar, if it's so set.
	#			next unless (($calType != 1) || ($event->isMyEvent()));
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
					my @date = WebGUI::DateTime::epochToArray(WebGUI::DateTime::addToDate($eventStartDate,0,0,$i));
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
#			} elsif (ref $event eq "WebGUI::Asset::Relation") {
#				print "\n";
			}
		}
		if (($startsNow || ($startMonth eq "first")) && ($calHasEvent == 0)) {
			#Let's process an extra month if this month had no events, 
			#and if we're at the beginning of the calendar, and if 
			#the calendar is supposed to start with the first event or now.
			$calMonthEnd++ unless $monthHasEvent;
			next unless $monthHasEvent;
		}
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
				#----------------------------------------------------------------------------
				#sort each day's events here - still needs to be done!
				#----------------------------------------------------------------------------
				push(@dayloop, {
					dayOfWeek => $dayOfWeekCounter,
					day=>$dayCounter,
					isStartOfWeek=>($dayOfWeekCounter==1),
					isEndOfWeek=>($dayOfWeekCounter==7),
					isToday=>($date[0]."-".$date[1]."-".$dayCounter eq $now[0]."-".$now[1]."-".$now[2]),
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
#	$var{"canManage"} = $self->canManage;
	$var{"addevent.url"} = $self->getUrl().'?func=addStyledEvent&class=WebGUI::Asset::Event';
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
	$var{'pagination.previousPage'} = '<form method="GET" style="inline;" action="'.
		$self->getUrl.'?calMonthStart='.$calMonthStart.
		'&reload='.WebGUI::Id::Generate.'"><a href="'.$self->getUrl.
		'?calMonthStart='.$prevCalMonthStart.'&calMonthEnd='.$prevCalMonthEnd.'">'.
		WebGUI::International::get(558,"Asset_EventsCalendar")." ".$monthRangeLength." ".
		$monthLabel.'</a>';
	$var{'pagination.nextPage'} = '<a href="'.$self->getUrl.
		'?calMonthStart='.$nextCalMonthStart.'&calMonthEnd='.$nextCalMonthEnd.'">'.
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

=head2 www_addStyledEvent ( )

Adds an event.

=cut

sub www_addStyledEvent {
	my $self = shift;
	my %properties = (
		groupIdView => $self->get("groupIdView"),
		groupIdEdit => $self->get("groupIdEdit"),
		ownerUserId => $self->get("ownerUserId"),
		encryptPage => $self->get("encryptPage"),
		templateId => $self->get("eventTemplateId"),
		styleTemplateId => $self->get("styleTemplateId"),
		printableStyleTemplateId => $self->get("printableStyleTemplateId"),
		isHidden => $self->get("isHidden"),
		startDate => $self->get("startDate"),
		endDate => $self->get("endDate")
		);
	$properties{isHidden} = 1 unless (WebGUI::Utility::isIn(ref $session{form}{class}, @{$session{config}{assetContainers}}));
	my $newAsset = WebGUI::Asset->newByDynamicClass("new","WebGUI::Asset::Event",\%properties);
	$newAsset->{_parent} = $self;
		#get parent so we can get the parent's style.  Hopefully the parent is an EventsCalendar.  If not, oh well.
#	return "You must add an Event as a child of an EventsCalendar." unless ($self->getValue("className") = "WebGUI::Asset::Wobject::EventsCalendar");
	return WebGUI::Privilege::noAccess() unless ($self->canEdit);
	return WebGUI::Style::process($newAsset->getEditForm->print,$self->getValue("styleTemplateId"));
}



#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless $self->canEdit;
	$self->getAdminConsole->setHelp("events calendar add/edit","EventsCalendar");
	return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get("12","Asset_EventsCalendar"));
}


1;

