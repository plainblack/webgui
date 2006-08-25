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
use WebGUI::Cache;
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
			visitorCacheTimeout => {
				tab => "display",
				fieldType => "interval",
				defaultValue => 3600,
				uiLevel => 8,
				label => $i18n->get("visitor cache timeout"),
				hoverHelp => $i18n->get("visitor cache timeout help")
				},
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
#
#=head2 epochToArray ( epoch )
#
#Returns an array date. 
#
#=head3 epoch
#
#The number of seconds since January 1, 1970.
#
#=cut
#
#sub epochToArray {
#	my $self = shift;
#	my $timeZone = $self->session->user->profileField("timeZone") || "America/Chicago";
#	use DateTime;
#	return map {$_ += 0} split / /, DateTime->from_epoch( epoch =>shift, time_zone=>$timeZone)->strftime("%Y %m %d %H %M %S");
#}
#


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
 	$tabform->getTab("display")->interval(
 		-name=>"visitorCacheTimeout",
		-label=>$i18n->get('visitor cache timeout'),
		-hoverHelp=>$i18n->get('visitor cache timeout help'),
		-value=>$self->getValue('visitorCacheTimeout'),
		-uiLevel=>8,
		-defaultValue=>3600
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
			"today"=>$i18n->get('today'),
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
		"after9"=>$i18n->get(87),
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

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}


#-------------------------------------------------------------------

=head2 purgeCache ( )

See WebGUI::Asset::purgeCache() for details.

=cut

sub purgeCache {
	my $self = shift;
	WebGUI::Cache->new($self->session,"view_".$self->getId)->delete;
	$self->SUPER::purgeCache;
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my $session = $self->session;

	# Cache lookup for visitors with default view only
	my $t_calMonthStart = $session->form->process('calMonthStart');
	my $t_calMonthEnd = $session->form->process('calMonthEnd');
	if ($session->user->userId eq '1' && !$t_calMonthStart && !$t_calMonthEnd) {
		my $out = WebGUI::Cache->new($session, 'view_'.$self->getId)->get;
		return $out if $out;
	}

	my $i18n = WebGUI::International->new($session, 'Asset_EventsCalendar');
	my $dt = $session->datetime;
	my $now = $dt->time();
	my ($startOfDay, $dummy) = $dt->dayStartEnd($now);
	my ($startOfMonth, $endOfMonth) = $dt->monthStartEnd($now);

	# Get events
	my $scope = $self->get('scope');
	my $events;
	if ($scope == 0) { # Calendar Scope is Regular
		$events = $self->getLineage(['children'],
			{returnObjects=>1,includeOnlyClasses=>['WebGUI::Asset::Event']});
	} elsif ($scope == 2) { # Calendar Scope is Master
		$events = $self->getLineage(['descendants'],
			{returnObjects=>1,includeOnlyClasses=>['WebGUI::Asset::Event']});
	} elsif ($scope == 1) { # Calendar Scope is Global
		$events = WebGUI::Asset->getRoot($session)->getLineage(['descendants'],
			{returnObjects=>1,includeOnlyClasses=>['WebGUI::Asset::Event']});
	}
	# Sort events by startDate, then endDate
	my @sortedEvents = sort {
		my $x = int($a->get('eventStartDate'));
		my $y = int($b->get('eventStartDate'));
		if ($x == $y) {
			$x = int($a->get('eventEndDate'));
			$y = int($b->get('eventEndDate'));
		}
		return $x cmp $y;
	} @{$events};

	# Get first/last event date
	my $firstEventDate = 2147483647; # far into the future (~2038)
	my $lastEventDate = 0;           # far into the past (~1970)
	foreach my $event (@sortedEvents) {
		# ignore events we can't view
		next unless $event->canView;

		my $eventStartDate = $event->get('eventStartDate');
		my $eventEndDate = $event->get('eventEndDate');

		# update first and last event date
		$firstEventDate = $eventStartDate if ($eventStartDate < $firstEventDate);
		$lastEventDate = $eventEndDate if ($eventEndDate > $lastEventDate);
	}
	# Check if no events were found
	if ($lastEventDate == 0) {
		# set first and last event date to now, to prevent an
		# empty calendar to start at somewhere in 2038
		$firstEventDate = $now;
		$lastEventDate = $now;
	}

	# Set limits for event filter (minDate/maxDate)
	my $t_startMonth = $self->get('startMonth');
	my $minDate;
	if ($t_startMonth eq 'first') {
		# choose start of day, to make comparisons later on easier
		($minDate, $dummy) = $dt->dayStartEnd($firstEventDate);
	} elsif ($t_startMonth eq 'now') {
		$minDate = $now;
	} elsif ($t_startMonth eq 'today') {
		$minDate = $startOfDay;
	} elsif ($t_startMonth eq 'current') {
		$minDate = $startOfMonth;
	} elsif ($t_startMonth eq 'january') {
		$minDate = $dt->humanToEpoch($dt->epochToHuman($now, '%y-01-01 00:00:00'));
	}

	my $t_endMonth = $self->get('endMonth');
	my $maxDate;
	if ($t_endMonth eq 'last') {
		# choose end of day, to make comparisons later on easier
		($dummy, $maxDate) = $dt->dayStartEnd($lastEventDate);
	} elsif ($t_endMonth eq 'after12') {
		$maxDate = $dt->addToDate($minDate, 0, 12, 0) - 1;
	} elsif ($t_endMonth eq 'after9') {
		$maxDate = $dt->addToDate($minDate, 0, 9, 0) - 1;
	} elsif ($t_endMonth eq 'after6') {
		$maxDate = $dt->addToDate($minDate, 0, 6, 0) - 1;
	} elsif ($t_endMonth eq 'after3') {
		$maxDate = $dt->addToDate($minDate, 0, 3, 0) - 1;
	} elsif ($t_endMonth eq 'current') {
		$maxDate = $endOfMonth;
	}

	# Filter events
	my %filteredEvents;
	my %userNames;
	my $previousDate;
	foreach my $event (@sortedEvents) {
		# ignore events we're not allowed to see
		next unless $event->canView;
		# get and check start date
		my $eventStartDate = $event->get('eventStartDate');
		next if ($eventStartDate > $maxDate);
		# get and check end date
		my $eventEndDate = $event->get('eventEndDate');
		next if ($eventEndDate < $minDate);

		# get date/time info
		my ($startYear, $startMonth, $startDay, $startDateHuman, $startTimeHuman, $startDayOfWeek, $startM) =
				split '_', $dt->epochToHuman($eventStartDate, '%y_%c_%D_%z_%Z_%w_%M');
		my ($endYear, $endMonth, $endDay, $endDateHuman, $endTimeHuman, $endDayOfWeek) =
				split '_', $dt->epochToHuman($eventEndDate, '%y_%c_%D_%z_%Z_%w');

		# set first and last day to start of those days (to make comparison of days easier)
		my ($firstDay, $lastDay);
		($firstDay, $dummy) = $dt->dayStartEnd($eventStartDate);
		($lastDay, $dummy) = $dt->dayStartEnd($eventEndDate);

		# quick & dirty way to count number of days in the interval
		my $daysInEvent = 0;
		for (my $day = $firstDay; $day <= $lastDay; $day = $dt->addToDate($day, 0, 0, 1)) {
			$daysInEvent++;
		}
		# add event to each day it takes place
		my $firstViewableDay = $firstDay;
		my $lastViewableDay = $lastDay;
		($firstViewableDay, $dummy) = $dt->dayStartEnd($minDate) if ($firstViewableDay < $minDate);
		($lastViewableDay, $dummy) = $dt->dayStartEnd($maxDate) if ($lastViewableDay > $maxDate);
		my $ownerUserId = $event->get('ownerUserId');
		unless ($userNames{$ownerUserId}) {
			my $owner = WebGUI::User->new($session, $ownerUserId);
			$userNames{$ownerUserId} = $owner->username();
		}
		my $ownerName = $userNames{$ownerUserId};
		for (my $day = $firstViewableDay; $day <= $lastViewableDay; $day = $dt->addToDate($day, 0, 0, 1)) {
			push (@{$filteredEvents{$day}}, {
				'description'          => $event->get('description'),
				'name'                 => $event->get('title'),
				'start.date.human'     => $startDateHuman,
				'start.time.human'     => $startTimeHuman,
				'start.date.epoch'     => $eventStartDate,
				'start.year'           => $startYear,
				'start.month'          => $startMonth,
				'start.day'            => $startDay,
				'start.day.dayOfWeek'  => $startDayOfWeek,
				'end.date.human'       => $endDateHuman,
				'end.time.human'       => $endTimeHuman,
				'end.date.epoch'       => $eventEndDate,
				'end.year'             => $endYear,
				'end.month'            => $endMonth,
				'end.day'              => $endDay,
				'end.day.dayOfWeek'    => $endDayOfWeek,
				'startEndYearMatch'    => ($startYear eq $endYear),
				'startEndMonthMatch'   => ($startYear eq $endYear) && ($startMonth eq $endMonth),
				'startEndDayMatch'     => ($firstDay eq $lastDay),
				'isFirstDayOfEvent'    => $day == $firstDay,
				'dateIsSameAsPrevious' => "$firstDay-$lastDay" eq $previousDate,
				'daysInEvent'          => $daysInEvent,
				'url'                  => $event->getUrl(),
				'owner'                => $ownerName
			});
		}
		$previousDate = "$firstDay-$lastDay";
	}

	# Set view range
	my $firstMonth;
	if (defined $t_calMonthStart) {
		$firstMonth = $dt->addToDate($startOfMonth, 0, int($t_calMonthStart), 0);
	} else {
		my $t_defaultMonth = $self->get('defaultMonth');
		if ($t_defaultMonth eq 'first') {
			($firstMonth, $dummy) = $dt->monthStartEnd($firstEventDate);
		} elsif ($t_defaultMonth eq 'last') {
			($firstMonth, $dummy) = $dt->monthStartEnd($lastEventDate);
		} else { # 'current'
			$firstMonth = $startOfMonth; # $dt->monthStartEnd($now);
		}
	}

	my $lastMonth;
	if (defined $t_calMonthEnd) {
		$lastMonth = $dt->addToDate($startOfMonth, 0, int($t_calMonthEnd), 0);
	} else {
		$lastMonth = $dt->addToDate($firstMonth, 0, int($self->get('paginateAfter'))-1, 0);
	}

	# Sanity checks
	$lastMonth = $firstMonth if ($lastMonth < $firstMonth);
	$lastMonth = $dt->addToDate($firstMonth, 3, 0, 0) if $dt->monthCount($firstMonth, $lastMonth) > 72;

	# Set first/last day of week, depending on user profile
	my ($userFirstDayOfWeek, $userLastDayOfWeek);
	if ($session->user->profileField('firstDayOfWeek')) {
		$userFirstDayOfWeek = 1;
		$userLastDayOfWeek = 7;
	} else {
		$userFirstDayOfWeek = 7;
		$userLastDayOfWeek = 6;
	}
	# Process the months that will be displayed
	my $monthloop;
	for (my $month = $firstMonth; $month <= $lastMonth; $month = $dt->addToDate($month, 0, 1, 0)) {
		my $daysInMonth = $dt->getDaysInMonth($month);
		my ($year, $monthName) = split(' ', $dt->epochToHuman($month, '%y %c'));

		# Generate prepad
		my @prepad;
		my $firstDayInMonthPosition = $dt->getFirstDayInMonthPosition($month);
		my $dayOfWeek = $userFirstDayOfWeek;
		while ($dayOfWeek != $firstDayInMonthPosition) {
			push(@prepad, { 'count' => $dayOfWeek });
			if ($dayOfWeek < 7) {
				$dayOfWeek++;
			} else {
				$dayOfWeek = 1;
			}
		}

		# Generate dayloop
		my @dayloop;
		for (my $d = 1; $d <= $daysInMonth; $d++) {
			my $day = $dt->addToDate($month, 0, 0, $d-1);

			push(@dayloop, {
				'dayOfWeek'     => $dayOfWeek,
				'day'           => $d,
				'isStartOfWeek' => ($dayOfWeek == $userFirstDayOfWeek),
				'isEndOfWeek'   => ($dayOfWeek == $userLastDayOfWeek),
				'isToday'       => ($day == $startOfDay),
				'hasEvents'     => scalar($filteredEvents{$day}) > 0,
				'event_loop'    => \@{$filteredEvents{$day}},
				'url'           => $filteredEvents{$day}->[0]->{url}
			});

			if ($dayOfWeek < 7) {
				$dayOfWeek++;
			} else {
				$dayOfWeek = 1;
			}
		}

		# Generate postpad
		my @postpad;
		while ($dayOfWeek != $userFirstDayOfWeek) {
			push(@postpad, { 'count' => $dayOfWeek});
			if ($dayOfWeek < 7) {
				$dayOfWeek++;
			} else {
				$dayOfWeek = 1;
			}
		}

		push(@$monthloop, {
			'daysInMonth'  => $daysInMonth,
			'day_loop'     => \@dayloop,
			'prepad_loop'  => \@prepad,
			'postpad_loop' => \@postpad,
			'month'        => $monthName,
			'year'         => $year
		});
	}

	# Set all template variables
	my %var;
	$var{"addevent.url"} = $self->getUrl('func=add;class=WebGUI::Asset::Event');
	$var{"addevent.label"} = $i18n->get(20);
	$var{'sunday.label'} = $dt->getDayName(7);
	$var{'monday.label'} = $dt->getDayName(1);
	$var{'tuesday.label'} = $dt->getDayName(2);
	$var{'wednesday.label'} = $dt->getDayName(3);
	$var{'thursday.label'} = $dt->getDayName(4);
	$var{'friday.label'} = $dt->getDayName(5);
	$var{'saturday.label'} = $dt->getDayName(6);
	$var{'sunday.label.short'} = substr($dt->getDayName(7),0,1);
	$var{'monday.label.short'} = substr($dt->getDayName(1),0,1);
	$var{'tuesday.label.short'} = substr($dt->getDayName(2),0,1);
	$var{'wednesday.label.short'} = substr($dt->getDayName(3),0,1);
	$var{'thursday.label.short'} = substr($dt->getDayName(4),0,1);
	$var{'friday.label.short'} = substr($dt->getDayName(5),0,1);
	$var{'saturday.label.short'} = substr($dt->getDayName(6),0,1);
	$var{month_loop} = \@$monthloop;
	# Create pagination variables.
	my $calMonthStart = $dt->getMonthDiff($startOfMonth, $firstMonth);
	my $calMonthEnd = $dt->getMonthDiff($startOfMonth, $lastMonth);
	my $monthRangeLength = $calMonthEnd - $calMonthStart + 1;
	my $monthLabel;
	if ($monthRangeLength == 1) {
		$monthLabel = $i18n->get(560);
	} else {
		$monthLabel = $i18n->get(561);
	}
	$var{'pagination.pageCount.isMultiple'} = 1;
	$var{'pagination.previousPageUrl'} = $self->getUrl.'?calMonthStart='.$calMonthStart-$monthRangeLength.';calMonthEnd='.$calMonthEnd-$monthRangeLength;
	$var{'pagination.previousPage'} = '<a href="'.$self->getUrl.'?calMonthStart='.($calMonthStart-$monthRangeLength).';calMonthEnd='.($calMonthEnd-$monthRangeLength).'">'.$i18n->get(558).' '.$monthRangeLength.' '.$monthLabel.'</a>';
	$var{'pagination.nextPageUrl'} = $self->getUrl.'?calMonthEnd='.$calMonthStart+$monthRangeLength.';calMonthEnd='.$calMonthEnd+$monthRangeLength;
	$var{'pagination.nextPage'} = '<a href="'.$self->getUrl.'?calMonthStart='.($calMonthStart+$monthRangeLength).';calMonthEnd='.($calMonthEnd+$monthRangeLength).'">'.$i18n->get(559).' '.$monthRangeLength.' '.$monthLabel.'</a>';
	$var{'pagination.pageList.upTo20'} = '
	<form method="get" style="display: inline;" action="'.$self->getUrl.'">
	<input type="hidden" name="calMonthStart" value="'.$calMonthStart.'" />
	<select size="1" name="calMonthEnd">
	<option value="'.($calMonthStart).'">1 '.$i18n->get(560).'</option>
	<option value="'.(1+$calMonthStart).'">2 '.$i18n->get(561).'</option>
	<option value="'.(2+$calMonthStart).'">3 '.$i18n->get(561).'</option>
	<option value="'.(3+$calMonthStart).'">4 '.$i18n->get(561).'</option>
	<option value="'.(5+$calMonthStart).'">6 '.$i18n->get(561).'</option>
	<option value="'.(8+$calMonthStart).'">9 '.$i18n->get(561).'</option>
	<option value="'.(11+$calMonthStart).'">12 '.$i18n->get(561).'</option>
	</select>
	<input type="submit" value="Go" name="Go" /></form>';

	# Process template
	my $out = $self->processTemplate(\%var, undef, $self->{_viewTemplate});

	# Store in cache (only if visitor and default view)
	if ($session->user->userId eq '1' && !$t_calMonthStart && !$t_calMonthEnd) {
		my $visitorCacheTimeout = $self->get('visitorCacheTimeout');
		my $timeTillEndOfMonth = $endOfMonth - $now;
		# Never cache longer than till the end of the month
		my $ttl = ($visitorCacheTimeout < $timeTillEndOfMonth) ? $visitorCacheTimeout : $timeTillEndOfMonth;
		WebGUI::Cache->new($session, 'view_'.$self->getId)->set($out, $ttl);
	}

	return $out;
}

#-------------------------------------------------------------------

=head2 www_view ( )

See WebGUI::Asset::Wobject::www_view() for details.

=cut

sub www_view {
	my $self = shift;
	$self->session->http->setCacheControl($self->get("visitorCacheTimeout")) if ($self->session->user->userId eq "1");
	$self->SUPER::www_view(@_);
}



1;

