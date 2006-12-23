package WebGUI::Asset::Event;

$VERSION = "0.0.0";

####################################################################
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
####################################################################
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
####################################################################
# http://www.plainblack.com                     info@plainblack.com
####################################################################

use strict;
use warnings;

use Tie::IxHash;
use Storable qw(nfreeze thaw);

use WebGUI::International;
use WebGUI::Asset::Template;
use WebGUI::Form;

use base 'WebGUI::Asset';

use WebGUI::DateTime;



=head1 Name


=head1 Description


=head1 Synopsis


=head1 Methods


=cut

####################################################################

sub definition {
	my $class 	= shift;
	my $session 	= shift;
	my $definition 	= shift;
	
	my $i18n 	= WebGUI::International->new($session, 'Asset_Event');
	
	my $dt		= WebGUI::DateTime->new(time);
	
	### Set up list options ###
	
	
	
	### Build properties hash ###
	my %properties;
	tie %properties, 'Tie::IxHash';
	%properties = (
		
		##### DEFAULTS #####
		'description' => {
			fieldType	=> "HTMLArea",
			defaultValue	=> "",
		},
		'startDate' => {
			fieldType	=> "Date",
			defaultValue	=> $dt->toMysqlDate,
		},
		'endDate' => {
			fieldType	=> "Date",
			defaultValue	=> $dt->toMysqlDate,
		},
		'startTime' => {
			fieldType	=> "TimeField",
			defaultValue	=> $dt->toMysqlTime,
		},
		'endTime' => {
			fieldType	=> "TimeField",
			defaultValue	=> $dt->toMysqlTime,
		},
		
		'recurId' => {
			fieldType	=> "Text",
			defaultValue	=> undef,
		},
		
		'relatedLinks' => {
			fieldType	=> "Textarea",
			defaultValue	=> undef,
		},
		'location' => {
			fieldType	=> "Text",
			defaultValue	=> undef,
		},
		'feedId' => {
			fieldType	=> "Text",
			defaultValue	=> undef,
		},
		'feedUid' => {
			fieldType	=> "Text",
			defaultValue	=> undef,
		},
	);
	
	
	### Add user defined fields
	for my $num (1..5)
	{
		$properties{"UserDefined".$num} = {
			fieldType	=> "text",
			defaultValue	=> "",
		};
	}
	
	
	push(@{$definition}, {
		assetName	=>$i18n->get('assetName'),
		icon		=>'calendar.gif',
		tableName	=>'Event',
		className	=>'WebGUI::Asset::Event',
		properties	=>\%properties
		});
	
        return $class->SUPER::definition($session, $definition);
}




####################################################################

=head2 canAdd

Returns true if a user can add this asset.



=cut

sub canAdd
{
	my $self 	= shift;
	my $session	= shift;
	
	return $session->user->isInGroup($self->getParent->get("groupIdEventEdit"));
}






####################################################################

=head2 canEdit

Returns true if a user can edit this asset.

=cut

sub canEdit
{
	my $self	= shift;
	my $session	= $self->session;
	
	return $session->user->isInGroup($self->getParent->get("groupIdEventEdit"));
}






####################################################################

=head2 generateRecurringEvents ( [ \%recurrence_data ] )

Generate a series of events.

If given a hashref of recurrence data, will create a new recurrence row in the
database and set the event to this new recurrence pattern. Will return undef if
there is an error creating the recurrence pattern.

If not given recurrence data, will use the event's existing recurrence. This is
used for generating future occurrences of events that don't end.

=cut

sub generateRecurringEvents
{
	my $self	= shift;
	my $recur	= shift;
	my $parent	= $self->getParent;
	my $id;
	
	if ($recur)
	{
		$id	= $self->setRecurrence($recur);
		return () unless $id;
	}
	else
	{
		$id	= $self->get("recurId");
		$recur	= {$self->getRecurrence};
	}
	
	my $properties	= {%{$self->get}};
	$properties->{recurId} = $id;
	
	# Get the distance between the event startDate and endDate
	my $duration_days	= 0;
	
	my $event_start	= WebGUI::DateTime->new(delete($properties->{startDate})." 00:00:00");
	my $event_end	= WebGUI::DateTime->new(delete($properties->{endDate})." 00:00:00");
	$duration_days	= $event_end->subtract_datetime($event_start)->days;
	
	my @dates	= $self->getRecurrenceDates($recur);
	
	for my $date (@dates)
	{
		my $dt		= WebGUI::DateTime->new($date." 00:00:00");
		
		### TODO: Only generate if the recurId does not exist on this day
		$properties->{startDate}	= $dt->strftime('%F');
		$properties->{endDate}		= $dt->clone->add(days => $duration_days)->strftime('%F');
		
		
		$parent->addChild($properties);
	}
	
	return 1;
}





####################################################################

=head2 getAutoCommitWorkflowId

Gets the WebGUI::VersionTag workflow to use to automatically commit Events. 
By specifying this method, you activate this feature.

=cut

sub getAutoCommitWorkflowId {
	my $self = shift;
	return "pbworkflow000000000003"; 
}





####################################################################

=head2 getDateTimeStart

Returns a WebGUI::DateTime object based on the startDate and startTime values, 
adjusted for the current user's time zone.

If this is an all-day event, the start time is 00:00:00 and the timezone is not
adjusted.

=cut

sub getDateTimeStart
{
	my $self	= shift;
	my $date	= $self->get("startDate");
	my $time	= $self->get("startTime");
	my $tz		= $self->session->user->profileField("timeZone");
	
	#$self->session->errorHandler->warn($self->getId.":: Date: $date -- Time: $time");
	unless ($date)
	{
		$self->session->errorHandler->warn("This event (".$self->get("assetId").") has no date.");
		return;
	}
	
	
	if ($time)
	{
		my $dt	= new WebGUI::DateTime($date." ".$time);
		$dt->set_time_zone($tz);
		return $dt;
	}
	else
	{
		my $dt	= new WebGUI::DateTime($date." 00:00:00");
		return $dt;
	}
}





####################################################################

=head2 getDateTimeEnd

Returns a WebGUI::DateTime object based on the endDate and endTime values, 
adjusted for the current user's time zone.

If this is an all-day event, the end time is 23:59:59 and the timezone is not
adjusted.

=cut

sub getDateTimeEnd
{
	my $self	= shift;
	my $date	= $self->get("endDate");
	my $time	= $self->get("endTime");
	my $tz		= $self->session->user->profileField("timeZone");
	
	#$self->session->errorHandler->warn($self->getId.":: Date: $date -- Time: $time");
	unless ($date)
	{
		$self->session->errorHandler->warn("This event (".$self->get("assetId").") has no date.");
		return;
	}
	
	
	if ($time)
	{
		my $dt	= new WebGUI::DateTime($date." ".$time);
		$dt->set_time_zone($tz);
		return $dt;
	}
	else
	{
		my $dt	= new WebGUI::DateTime($date." 23:59:59");
		return $dt;
	}
}





####################################################################

=head2 getEventNext

Gets the event that occurs after this event in the calendar. Returns the 
Event object.

=cut

sub getEventNext
{
	my $self	= shift;
	my $db		= $self->session->db;
	
	my $where	= 'Event.startDate > "'.$self->get("startDate").'" || (Event.startDate = "'.$self->get("startDate").'" && ';
	
	# All day events must either look for null time or greater than 00:00:00
	if ($self->isAllDay)
	{
		$where	.= "(Event.startTime IS NULL "
			. "&& assetData.title > ".$db->quote($self->get("title")).") "
			. "|| Event.startTime >= '00:00:00'";
	}
	# Non all-day events must look for greater than time
	else
	{
		$where	.= "(Event.startTime = '".$self->get("startTime")."' "
			. "&& assetData.title > ".$db->quote($self->get("title")).")"
			. "|| Event.startTime > '".$self->get("startTime")."'";
	}
	$where	.= ")";
	
	my $events	= $self->getLineage(['siblings'],
			{
				#returnObjects		=> 1,
				includeOnlyClasses	=> ['WebGUI::Asset::Event'],
				joinClass		=> 'WebGUI::Asset::Event',
				orderByClause		=> 'Event.startDate, Event.startTime, Event.endDate, Event.endDate, assetData.title, assetData.assetId',
				whereClause		=> $where,
				limit			=> 1,
			});
	
	return WebGUI::Asset->newByDynamicClass($self->session,$events->[0]);
}






####################################################################

=head2 getEventPrev

Gets the event that occurs before this event in the calendar. Returns the Event
object.

=cut

sub getEventPrev
{
	my $self	= shift;
	my $db		= $self->session->db;
	
	my $where	= 'Event.startDate < "'.$self->get("startDate").'" || (Event.startDate = "'.$self->get("startDate").'" && ';
	
	# All day events must either look for null time or greater than 00:00:00
	if ($self->isAllDay)
	{
		$where	.= "(Event.startTime IS NULL "
			. "&& assetData.title < ".$db->quote($self->get("title")).")";
	}
	# Non all-day events must look for greater than time
	else
	{
		$where	.= "(Event.startTime = '".$self->get("startTime")."' "
			. "&& assetData.title < ".$db->quote($self->get("title")).")"
			. "|| Event.startTime < '".$self->get("startTime")."'";
	}
	$where	.= ")";
	
	my $events	= $self->getLineage(['siblings'],
			{
				#returnObjects		=> 1,
				includeOnlyClasses	=> ['WebGUI::Asset::Event'],
				joinClass		=> 'WebGUI::Asset::Event',
				orderByClause		=> 'Event.startDate DESC, Event.startTime DESC, Event.endDate DESC, Event.endDate DESC, assetData.title DESC, assetData.assetId DESC',
				whereClause		=> $where,
				limit			=> 1,
			});
	
	return WebGUI::Asset->newByDynamicClass($self->session,$events->[0]);
}





####################################################################

=head2 getIcalStart

If this event is an all-day event, gets an iCalendar (RFC 2445) Date string, not
adjusted for time zone.
.
Otherwise returns an iCalendar Date/Time string in the UTC time zone.

=cut

sub getIcalStart
{
	my $self	= shift;
	
	if ($self->isAllDay)
	{
		my $date = $self->get("startDate");
		$date =~ s/\D//g;
		return $date;
	}
	else
	{
		my $date = $self->get("startDate");
		my $time = $self->get("startTime");
		
		$date =~ s/\D//g;
		$time =~ s/\D//g;
		
		return $date."T".$time."Z";
	}
}





####################################################################

=head2 getIcalEnd

If this event is an all-day event, gets an iCalendar (RFC 2445) Date string, not
adjusted for time zone.
.
Otherwise returns an iCalendar Date/Time string in the UTC time zone.

=cut

sub getIcalEnd
{
	my $self	= shift;
	
	if ($self->isAllDay)
	{
		my $date = $self->get("endDate");
		$date =~ s/\D//g;
		return $date;
	}
	else
	{
		my $date = $self->get("endDate");
		my $time = $self->get("endTime");
		
		$date =~ s/\D//g;
		$time =~ s/\D//g;
		
		return $date."T".$time."Z";
	}
}





####################################################################

=head2 getRecurrence

Returns a hash of recurrence information. Some of the keys are only relevant
to certain recurrence types.

B<NOTE: This hash IS GOING TO CHANGE after iCalendar recurrence patterns are 
implemented using DateTime::Event::ICal, so DO NOT RELY ON THEM. This holds 
true for getRecurrenceFromForm() and setRecurrence().>

=over 8

=item recurType

The recurrence type (daily, weekdays, weekly, monthDay, monthWeek, yearDay, 
yearWeek)

=item startDate

The MySQL date to start creating recurring events

=item endDate

The MySQL date to end creating recurring events. If either this or endAfter does
not exist, the event recurs forever.

=item endAfter

The number of occurences this event ends after. If neither this nor endDate
exists, the event recurs forever.

=item every

The number of (days, weeks, months, years) between each recurrence.

=item dayNames

A list of day names that this event recurs on. 

 u	- Sunday
 m	- Monday
 t	- Tuesday
 w	- Wednesday
 r	- Thursday
 f	- Friday
 s	- Saturday

=item dayNumber

The day number that this event recurs on

=item weeks

A list of weeks that this event recurs on

 first
 second
 third
 fourth
 last

=item months

A list of months that this event recurs on

 jan	- January
 feb	- February
 mar	- March
 apr	- April
 may	- May
 jun	- June
 jul	- July
 aug	- August
 sep	- September
 oct	- October
 nov	- November
 dec	- December

=back

=cut

sub getRecurrence
{
	my $self	= shift;
	use Data::Dumper;
	#$self->session->errorHandler->warn("recurId: ".$self->get("recurId"));
	return () unless $self->get("recurId");
	
	my %data	= $self->session->db->quickHash("select * from Event_recur where recurId=?",[$self->get("recurId")]);
	my %recurrence	= (
			recurType	=> $data{recurType},
			);
	
	
	# We do not need the recurId, and in fact will screw up our later comparisons
	delete $data{"recurId"};
	
	my $type		= lc $data{"recurType"};
	if ($type eq "daily" || $type eq "weekday")
	{
		$recurrence{every} 	= $data{pattern};
	}
	elsif ($type eq "weekly")
	{
		#(\d+) ([umtwrfs]+)
		$data{pattern}		=~ /(\d+) ([umtwrfs]+)/;
		$recurrence{every}	= $1;
		$recurrence{dayNames}	= [split //, $2];
	}
	elsif ($type eq "monthweek")
	{
		#(\d+) (first,second,third,fourth,last) ([umtwrfs]+)
		$data{pattern}		=~ /(\d+) ([a-z,]+) ([umtwrfs]+)/;
		$recurrence{every}	= $1;
		$recurrence{weeks}	= [split /,/, $2];
		$recurrence{dayNames}	= [split //, $3];
	}
	elsif ($type eq "monthday")
	{
		#(\d+) on (\d+)
		$data{pattern}		=~ /(\d+) (\d+)/;
		$recurrence{every}	= $1;
		$recurrence{dayNumber}	= $2;
	}
	elsif ($type eq "yearweek")
	{
		#(\d+) (first,second,third,fourth,last) ([umtwrfs]+)? (jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec)
		$data{pattern}		=~ /(\d+) ([a-z,]+) ([umtwrfs]+) ([a-z,]+)/;
		$recurrence{every}	= $1;
		$recurrence{weeks}	= [split /,/, $2];
		$recurrence{dayNames}	= [split //, $3];
		$recurrence{months}	= [split /,/, $4];
	}
	elsif ($type eq "yearday")
	{
		#(\d+) on (\d+) (jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec)
		$data{pattern}		=~ /(\d+) (\d+) ([a-z,]+)/;
		$recurrence{every}	= $1;
		$recurrence{dayNumber}	= $2;
		$recurrence{months}	= [split /,/, $3];
	}
	
	$recurrence{startDate} = $data{startDate};
	if ($data{endDate} && $data{endDate} =~ /^after (\d+)/i)
	{
		$recurrence{endAfter} 	= $1;
	}
	elsif ($data{endDate})
	{
		$recurrence{endDate}	= $data{endDate};
	}
	
	return %recurrence;
}





####################################################################

=head2 getRecurrenceDates

Gets a series of dates in the specified recurrence pattern.

This is quite possibly the worst algorithm I've ever created. We should be using
DateTime::Event::ICal instead.

=cut

sub getRecurrenceDates
{
	my $self	= shift;
	my $recur	= shift;
	
	my %date;
	
	return undef unless $recur->{recurType};
	
	my %dayNames	= (
		monday		=> "m",
		tuesday		=> "t",
		wednesday	=> "w",
		thursday	=> "r",
		friday		=> "f",
		saturday	=> "s",
		sunday		=> "u",
		);
	my %weeks	= (
		0		=> "first",
		1		=> "second",
		2		=> "third",
		3		=> "fourth",
		4		=> "fifth",
		);
	
	
	my $dt		= WebGUI::DateTime->new($recur->{startDate}." 00:00:00");
	my $dt_start	= $dt->clone; # Keep track of the initial start date
	my $dt_end	= WebGUI::DateTime->new($recur->{endDate}." 00:00:00")
			if $recur->{endDate};
	# Set an end for events with no end
	#!!! TODO !!! - Get the appropriate configuration
	$dt_end		= $dt->clone->add(years=>2)
			if (!$recur->{endDate} && !$recur->{endAfter});
	
	
	RECURRENCE: while (1)
	{
		####### daily
		if ($recur->{recurType} eq "daily")
		{
			### Add date
			$date{$dt->strftime('%F')}++;
			
			# Add interval
			$dt->add(days => $recur->{every});
			
			# Test for quit
			if (($recur->{endAfter} && keys %date >= $recur->{endAfter}) || ($dt_end && $dt > $dt_end))
			{
				last RECURRENCE;
			}
			
			# Next
			next RECURRENCE;
		}
		####### weekday
		elsif ($recur->{recurType} eq "weekday")
		{
			my $today	= $dt->day_name;
			
			# If today is not a weekday
			unless (grep /$today/i,qw(monday tuesday wednesday thursday friday))
			{
				# Add a day
				$dt->add(days => 1);
				
				# Test for quit
				if (($recur->{endAfter} && keys %date >= $recur->{endAfter}) || ($dt_end && $dt > $dt_end))
				{
					last RECURRENCE;
				}
				
				# next
				next RECURRENCE;
			}
			else
			{
				### Add date
				$date{$dt->strftime('%F')}++;
				
				$dt->add(days => $recur->{every});
				
				# Test for quit
				if (($recur->{endAfter} && keys %date >= $recur->{endAfter}) || ($dt_end && $dt > $dt_end))
				{
					last RECURRENCE;
				}
				
				# Next
				next RECURRENCE;
			}
		}
		####### weekly
		elsif ($recur->{recurType} eq "weekly")
		{
			for (0..6)	# Work through the week
			{
				my $dt_day	= $dt->clone->add(days => $_);
				
				# If today is past the endDate, quit.
				last RECURRENCE
					if ($recur->{endDate} && $dt_day > $dt_end);
				
				my $today	= $dayNames{lc $dt_day->day_name};
				
				if (grep /$today/i, @{$recur->{dayNames}})
				{
					### Add date
					$date{$dt_day->strftime('%F')}++;
				}
				
				# If occurrences is past the endAfter, quit
				last RECURRENCE
					if ($recur->{endAfter} && keys %date >= $recur->{endAfter});
			}
			
			# Add interval
			$dt->add(weeks => $recur->{every});
			
			# Test for quit
			if (($recur->{endAfter} && keys %date >= $recur->{endAfter}) || ($dt_end && $dt > $dt_end))
			{
				last RECURRENCE;
			}
			
			# Next
			next RECURRENCE;
		
		}
		####### monthday
		elsif ($recur->{recurType} eq "monthDay")
		{
			# Pick out the correct day
			my $startDate	= $dt->year."-".$dt->month."-".$recur->{dayNumber};
			
			my $dt_day	= WebGUI::DateTime->new($startDate." 00:00:00");
			
			# Only if today is not before the recurrence start
			if ($dt_day->clone->truncate(to => "day") >= $dt_start->clone->truncate(to=>"day"))
			{
				# If today is past the endDate, quit.
				last RECURRENCE
					if ($recur->{endDate} && $dt_day > $dt_end);
				
				### Add date
				$date{$dt_day->strftime('%F')}++;
			}
			
			# Add interval
			$dt->add(months => $recur->{every})->truncate(to => "month");
			
			# Test for quit
			if (($recur->{endAfter} && keys %date >= $recur->{endAfter}) || ($dt_end && $dt > $dt_end))
			{
				last RECURRENCE;
			}
			
			# Next
			next RECURRENCE;
		}
		###### monthweek
		elsif ($recur->{recurType} eq "monthWeek")
		{
			# For each week remaining in this month
			my $dt_week	= $dt->clone;
			while ($dt->month eq $dt_week->month)
			{
				my $week	= int($dt_week->day_of_month / 7);
				
				if (grep /$weeks{$week}/i, @{$recur->{weeks}})
				{
					# Pick out the correct days
					for (0..6)	# Work through the week
					{
						my $dt_day	= $dt_week->clone->add(days => $_);
						
						# If today is past the endDate, quit.
						last RECURRENCE
							if ($recur->{endDate} && $dt_day > $dt_end);
						
						# If today isn't in the month, stop looking
						last if ($dt_day->month ne $dt->month);
						
						my $today	= $dayNames{lc $dt_day->day_name};
						
						if (grep /$today/i, @{$recur->{dayNames}})
						{
							### Add date
							$date{$dt_day->strftime('%F')}++;
						}
						
						# If occurrences is past the endAfter, quit
						last RECURRENCE
							if ($recur->{endAfter} && keys %date >= $recur->{endAfter});
					}
				}
				
				# Add a week
				$dt_week->add(days => 7);
			}
			
			### If last is selected
			if (grep /last/, @{$recur->{weeks}})
			{
				my $dt_last	= $dt->clone->truncate(to => "month")
						->add(months => 1)->subtract(days => 1);
				
				for (0..6)
				{
					my $dt_day	= $dt_last->clone->subtract(days => $_);
					
					# If today is before the startDate, don't even bother
					last if ($dt_day < $dt_start);
					# If today is past the endDate, try the next one
					next if ($recur->{endDate} && $dt_day > $dt_end);
					
					my $today	= $dayNames{lc $dt_day->day_name};
					
					if (grep /$today/i, @{$recur->{dayNames}})
					{
						### Add date
						$date{$dt_day->strftime('%F')}++;
					
					}
					
					# If occurrences is past the endAfter, quit
					last RECURRENCE
						if ($recur->{endAfter} && keys %date >= $recur->{endAfter});
				}
			}
			
			
			# Add interval
			$dt->add(months => $recur->{every})->truncate(to => "month");
			
			# Test for quit
			if (($recur->{endAfter} && keys %date >= $recur->{endAfter}) || ($dt_end && $dt > $dt_end))
			{
				last RECURRENCE;
			}
			
			# Next
			next RECURRENCE;
		}
		####### yearday
		elsif ($recur->{recurType} eq "yearDay")
		{
			# For each month
			my $dt_month	= $dt->clone;
			while ($dt->year eq $dt_month->year)
			{
				my $mon		= $dt_month->month_abbr;
				if (grep /$mon/i, @{$recur->{months}})
				{
					# Pick out the correct day
					my $startDate	= $dt_month->year."-".$dt_month->month."-".$recur->{dayNumber};
					
					my $dt_day	= WebGUI::DateTime->new($startDate." 00:00:00");
					
					# Only if today is not before the recurrence start
					if ($dt_day->clone->truncate(to => "day") >= $dt_start->clone->truncate(to=>"day"))
					{
						# If today is past the endDate, quit.
						last RECURRENCE
							if ($recur->{endDate} && $dt_day > $dt_end);
						
						### Add date
						$date{$dt_day->strftime('%F')}++;
					
					}
					
					# If occurrences is past the endAfter, quit
					last RECURRENCE
						if ($recur->{endAfter} && keys %date >= $recur->{endAfter});
				}
				
				$dt_month->add(months=>1);
			}
			
			# Add interval
			$dt->add(years => $recur->{every})->truncate(to => "year");
			
			# Test for quit
			if (($recur->{endAfter} && keys %date >= $recur->{endAfter}) || ($dt_end && $dt > $dt_end))
			{
				last RECURRENCE;
			}
			
			# Next
			next RECURRENCE;
		}
		####### yearweek
		elsif ($recur->{recurType} eq "yearWeek")
		{
			# For each month
			my $dt_month	= $dt->clone;
			while ($dt->year eq $dt_month->year)
			{
				my $mon		= $dt_month->month_abbr;
				if (grep /$mon/i, @{$recur->{months}})
				{
					# For each week remaining in this month
					my $dt_week	= $dt_month->clone;
					while ($dt_month->month eq $dt_week->month)
					{
						my $week	= int($dt_week->day_of_month / 7);
						
						if (grep /$weeks{$week}/i, @{$recur->{weeks}})
						{
							for (0..6)	# Work through the week
							{
								my $dt_day	= $dt_week->clone->add(days => $_);
								
								# If today is past the endDate, quit.
								last RECURRENCE
									if ($recur->{endDate} && $dt_day > $dt_end);
								
								# If today isn't in the month, stop looking
								last if ($dt_day->month ne $dt_month->month);
								
								my $today	= $dayNames{lc $dt_day->day_name};
								
								if (grep /$today/i, @{$recur->{dayNames}})
								{
									### Add date
									$date{$dt_day->strftime('%F')}++;
								}
								
								# If occurrences is past the endAfter, quit
								last RECURRENCE
									if ($recur->{endAfter} && keys %date >= $recur->{endAfter});
							}
						}
						
						# Next week
						$dt_week->add(days => 7);
					}
					
					### If last is selected
					if (grep /last/, @{$recur->{weeks}})
					{
						my $dt_last	= $dt_month->clone->add(months => 1)->subtract(days => 1);
						
						for (0..6)
						{
							my $dt_day	= $dt_last->clone->subtract(days => $_);
							
							# If today is past the endDate, try the next one
							next
								if ($recur->{endDate} && $dt_day > $dt_end);
							
							my $today	= $dayNames{lc $dt_day->day_name};
							
							if (grep /$today/i, @{$recur->{dayNames}})
							{
								### Add date
								$date{$dt_day->strftime('%F')}++;
							
							}
							
							# If occurrences is past the endAfter, quit
							last RECURRENCE
								if ($recur->{endAfter} && keys %date >= $recur->{endAfter});
						}
					}
					
				}
				
				# Next month
				$dt_month->add(months=>1);
			}
			
			# Add interval
			$dt->add(years => $recur->{every})->truncate(to => "year");
			
			# Test for quit
			if (($recur->{endAfter} && keys %date >= $recur->{endAfter}) || ($dt_end && $dt > $dt_end))
			{
				last RECURRENCE;
			}
			
			# Next
			next RECURRENCE;
		}
	}
	
	
	return sort keys %date;
}





####################################################################

=head2 getRecurrenceFromForm

Returns a recurrence hash based on the form parameters.

The hash keys are the same as getRecurrence.

=cut

sub getRecurrenceFromForm
{
	my $self	= shift;
	my $form	= $self->session->form;
	
	my %recurrence		= ();
	my $type		= lc $form->param("recurType");
	
	return () unless ($type && $type !~ /none/i);
	
	if ($type eq "daily")
	{
		if (lc($form->param("recurSubType")) eq "weekday")
		{
			$recurrence{recurType}	= "weekday";
		}
		else
		{
			$recurrence{recurType}	= "daily";
		}
		
		$recurrence{every} = $form->param("recurDay");
	}
	elsif ($type eq "weekly")
	{
		$recurrence{recurType} = "weekly";
		$recurrence{dayNames} = [$form->param("recurWeekDay")];
		$recurrence{every} = $form->param("recurWeek");
	}
	elsif ($type eq "monthly")
	{
		if (lc($form->param("recurSubType")) eq "monthweek")
		{
			$recurrence{recurType} = "monthWeek";
			$recurrence{weeks} = [$form->param("recurMonthWeekNumber")];
			$recurrence{dayNames} = [$form->param("recurMonthWeekDay")];
		}
		elsif (lc($form->param("recurSubType")) eq "monthday")
		{
			$recurrence{recurType} = "monthDay";
			$recurrence{dayNumber} = $form->param("recurMonthDay");
		}
		
		$recurrence{every} = $form->param("recurMonth");
	}
	elsif ($type eq "yearly")
	{
		if (lc($form->param("recurSubType")) eq "yearweek")
		{
			$recurrence{recurType} = "yearWeek";
			$recurrence{weeks} = [$form->param("recurYearWeekNumber")];
			$recurrence{dayNames} = [$form->param("recurYearWeekDay")];
			$recurrence{months} = [$form->param("recurYearWeekMonth")];
		}
		elsif (lc($form->param("recurSubType")) eq "yearday")
		{
			$recurrence{recurType} = "yearDay";
			$recurrence{dayNumber} = $form->param("recurYearDay");
			$recurrence{months} = [$form->param("recurYearDayMonth")];
		}
		
		$recurrence{every} = $form->param("recurYear");
	}
	
	$recurrence{every} ||= 1;
	$recurrence{startDate} = $form->param("recurStart");
	
	if (lc $form->param("recurEndType") eq "date")
	{
		$recurrence{endDate} = $form->param("recurEndDate");
	}
	elsif (lc $form->param("recurEndType") eq "after")
	{
		$recurrence{endAfter} = $form->param("recurEndAfter");
	}
	
	return %recurrence;
}





####################################################################

=head2 getRelatedLinks

Gets the related links.

=cut

sub getRelatedLinks
{
	my $self	= shift;
	return () unless $self->get("relatedLinks");
	return split /\n+/, $self->get("relatedLinks");
}





####################################################################

=head2 getTemplateVars

Returns a hash of additional parameters to be used in templates, beyond the 
standard definition.

Uses the current user's locale and timezone.

=cut

sub getTemplateVars
{
	my $self	= shift;
	my $i18n	= WebGUI::International->new($self->session,"Asset_Event");
	my %var;
	
	# Some miscellaneous stuff
	$var{"isPublic"}	= 1
		if $self->get("groupIdView") eq "7";
	$var{"groupToView"}	= $self->get("groupIdView");	# Todo: Remove this? 
	
	# Start date/time
	my $dtStart	= $self->getDateTimeStart;
	$dtStart->set_locale($i18n->get("locale") || "en_US");
	
	$var{"startDateSecond"}		= sprintf "%02d", $dtStart->second;
	$var{"startDateMinute"}		= sprintf "%02d", $dtStart->minute;
	$var{"startDateHour24"}		= $dtStart->hour;
	$var{"startDateHour"}		= $dtStart->hour_12;
	$var{"startDateM"}		= ( $dtStart->hour < 12 ? "AM" : "PM" );
	$var{"startDateDayName"}	= $dtStart->day_name;
	$var{"startDateDayAbbr"}	= $dtStart->day_abbr;
	$var{"startDateDayOfMonth"}	= $dtStart->day_of_month;
	$var{"startDateDayOfWeek"}	= $dtStart->day_of_week;
	$var{"startDateMonthName"}	= $dtStart->month_name;
	$var{"startDateMonthAbbr"}	= $dtStart->month_abbr;
	$var{"startDateYear"}		= $dtStart->year;
	$var{"startDateYmd"}		= $dtStart->ymd;
	$var{"startDateMdy"}		= $dtStart->mdy;
	$var{"startDateDmy"}		= $dtStart->dmy;
	$var{"startDateHms"}		= $dtStart->hms;
	$var{"startDateEpoch"}		= $dtStart->epoch;
	
	# End date/time
	my $dtEnd	= $self->getDateTimeEnd;
	$dtEnd->set_locale($i18n->get("locale") || "en_US");
	
	$var{"endDateSecond"}		= sprintf "%02d", $dtEnd->second;
	$var{"endDateMinute"}		= sprintf "%02d", $dtEnd->minute;
	$var{"endDateHour24"}		= $dtEnd->hour;
	$var{"endDateHour"}		= $dtEnd->hour_12;
	$var{"endDateM"}		= ( $dtEnd->hour < 12 ? "AM" : "PM" );
	$var{"endDateDayName"}		= $dtEnd->day_name;
	$var{"endDateDayAbbr"}		= $dtEnd->day_abbr;
	$var{"endDateDayOfMonth"}	= $dtEnd->day_of_month;
	$var{"endDateDayOfWeek"}	= $dtEnd->day_of_week;
	$var{"endDateMonthName"}	= $dtEnd->month_name;
	$var{"endDateMonthAbbr"}	= $dtEnd->month_abbr;
	$var{"endDateYear"}		= $dtEnd->year;
	$var{"endDateYmd"}		= $dtEnd->ymd;
	$var{"endDateMdy"}		= $dtEnd->mdy;
	$var{"endDateDmy"}		= $dtEnd->dmy;
	$var{"endDateHms"}		= $dtEnd->hms;
	$var{"endDateEpoch"}		= $dtEnd->epoch;
	
	
	
	$var{isAllDay}		= $self->isAllDay;
	$var{isOneDay}		= 1 if ($var{isAllDay} && $var{startDateDmy} eq $var{endDateDmy});
	
	
	# Make a Friendly date span
	$var{dateSpan}		= $var{startDateDayName}.", "
				. $var{startDateMonthName}." "
				. $var{startDateDayOfMonth}." "
				. ( !$var{isAllDay} ? $var{startDateHour}.":".$var{startDateMinute}." ".$var{startDateM} : "" )
				. ( !$var{isOneDay} ? 
					' &bull; '
					. $var{endDateDayName}.", "
					.$var{endDateMonthName}." "
					.$var{endDateDayOfMonth}." "
					. ( !$var{isAllDay} ? $var{endDateHour}.":".$var{endDateMinute}." ".$var{endDateM} : "")
					: "");
	
	# Make some friendly URLs
	$dtStart->truncate(to=>"day");
	$var{"urlDay"}		= $self->getParent->getUrl("type=day;start=".$dtStart->toMysql);
	$var{"urlWeek"}		= $self->getParent->getUrl("type=week;start=".$dtStart->toMysql);
	$var{"urlMonth"}	= $self->getParent->getUrl("type=month;start=".$dtStart->toMysql);
	$var{"urlParent"}	= $self->getParent->getUrl;		
	
	
	# Related links
	$var{"relatedLinks"}	= [];
	push @{$var{"relatedLinks"}}, { "linkUrl" => $_ }
		for ($self->getRelatedLinks);
	
	
	return %var;
}





####################################################################

=head2 isAllDay

Returns true if this event is an all day event.

=cut

sub isAllDay
{
	return 1 unless ($_[0]->get("startTime") || $_[0]->get("endTime"));
	return 0;
}





####################################################################

=head2 prepareView

Prepares the view template to be used later. The template to be used is found 
from this asset's parent (Usually a Calendar).

If the "print" form parameter is set, will prepare the print template.

=cut

sub prepareView
{
	my $self	= shift;
	my $parent	= $self->getParent;
	my $templateId;
	
	if ($parent)
	{
		if ($self->session->form->param("print"))
		{
			$templateId	= $parent->get("templateIdPrintEvent");
			$self->session->style->makePrintable(1);
		}
		else
		{
			$templateId	= $parent->get("templateIdEvent");
		}
	}
	else
	{
		$templateId	= "CalendarEvent000000001";
	}
	
	my $template		= WebGUI::Asset::Template->new($self->session,$templateId);
	$template->prepare;
	
	$self->{_viewTemplate}	= $template;
}





####################################################################

=head2 processPropertiesFromFormPost

Processes the Event Edit form.

Makes the event hide from navigation (since there could be possibly thousands of
events across dozens of years. How would we even go about sorting such a list?)

If "allday" is "yes", sets the startTime and endTime to NULL.

If there's a time, convert from the user's timezone to UTC.

Updates the Event_recur table if necessary (creates a new recurId, points the
saved event to the new recurId, creates all the events under this new
recurId, and then deletes all the events under the old recurId).

Requests that the events be committed

=cut

sub processPropertiesFromFormPost
{
	my $self	= shift;
	$self->SUPER::processPropertiesFromFormPost;	# Updates the event
	my $session	= $self->session;
	my $form	= $self->session->form;
	
	### Verify the form was filled out correctly...
	# The end must be after the start
	if (!$form->param("allday") 
		&& $self->get("startDate") gt $self->get("endDate") 
		|| ($self->get("startDate") eq $self->get("endDate") && $self->get("startTime") gt $self->get("endTime")))
	{
		return ["The event end must be after the event start."];
	}
	
	
	### Form is verified
	# Events are always hidden from navigation
	$self->update({ isHidden => 1 });
	
	# Fix times according to input (allday, timezone)
	if ($self->session->form->param("allday"))
	{
		$self->update({	startTime	=> undef,
				endTime		=> undef,
				});
	}
	else
	{
		# Convert timezone
		my $tz	= $self->session->user->profileField("timeZone");
		
		my ($startDate,$startTime) = split / /, WebGUI::DateTime->new(mysql => $self->get("startDate")." ".$self->get("startTime"), time_zone => $tz)
					->set_time_zone("UTC")->toMysql;
		
		my ($endDate,$endTime) = split / /, WebGUI::DateTime->new(mysql => $self->get("endDate")." ".$self->get("endTime"), time_zone => $tz)
					->set_time_zone("UTC")->toMysql;
		
		$self->update({	startDate	=> $startDate,
				startTime	=> $startTime,
				endDate		=> $endDate,
				endTime		=> $endTime,
				});
	}
	
	
	# Determine if the pattern has changed
	if ($form->param("recurType"))
	{
		# Create the new recurrence hash
		my %recurrence_new	= $self->getRecurrenceFromForm;
		# Get the old recurrence hash and range
		my %recurrence_old 	= $self->getRecurrence;
		
		
		# Set storable to canonical so that we can compare data structures
		$Storable::canonical = 1;
		
		# Pattern keys
		if (nfreeze(\%recurrence_new) ne nfreeze(\%recurrence_old))
		{
			# Delete all old events and create new ones
			my $old_id	= $self->get("recurId");
	
			return ["There's something wrong with your recurrence pattern."] 
				unless $self->generateRecurringEvents(\%recurrence_new);
			
			
			## Delete old events
			my $events = $self->getLineage(["siblings"], 
				{
					returnObjects		=> 1,
					includeOnlyClasses	=> ['WebGUI::Asset::Event'],
					joinClass		=> 'WebGUI::Asset::Event',
					whereClause		=> 'Event.recurId = "'.$old_id.'"',
				});
			
			$_->purge for @$events;
		}
		# Include / exclude keys
		#elsif ()
		#{
		#	# Delete / create necessary events
		#	
		#}
		# No change
		else
		{
			# Just update related events			
			my $properties	= $self->get;
			delete $properties->{startDate};
			delete $properties->{endDate};
			
			my $events = $self->getLineage(["siblings"], 
				{
					returnObjects		=> 1,
					includeOnlyClasses	=> ['WebGUI::Asset::Event'],
					joinClass		=> 'WebGUI::Asset::Event',
					whereClause		=> 'Event.recurId = "'.$self->get("recurId").'"',
				});
			
			for my $event (@$events)
			{
				# Add a revision
				$properties->{startDate}	= $event->get("startDate");
				$properties->{endDate}		= $event->get("endDate");
				
				$event->addRevision($self->get);
			}
		}
	}
}




####################################################################

=head2 setRecurrence ( hashref )

Sets a hash of recurrence information to the database. The hash keys are the 
same as the ones in getRecurrence()

This will always create a new row in the recurrence table.

Returns the ID of the row if success, otherwise returns 0.

=cut

sub setRecurrence
{
	my $self	= shift;
	my $vars	= shift;
	
	my $type	= $vars->{recurType} || return;
	my $pattern;
	
	if ($type eq "daily" || $type eq "weekday")
	{
		return 0 unless ($vars->{every});
		#(\d+)
		$pattern = $vars->{every};
	}
	elsif ($type eq "weekly")
	{
		return 0 unless ($vars->{every} && $vars->{dayNames});
		#(\d+) ([umtwrfs]+)
		$pattern = $vars->{every}." ".join("",@{$vars->{dayNames}});
	}
	elsif ($type eq "monthWeek")
	{
		return 0 unless ($vars->{every} && $vars->{weeks} && $vars->{dayNames});
		#(\d+) (first,second,third,fourth,last) ([umtwrfs]+)
		$pattern = $vars->{every}." ".join(",",@{$vars->{weeks}})." ".join("",@{$vars->{dayNames}});
	}
	elsif ($type eq "monthDay")
	{
		return 0 unless ($vars->{every} && $vars->{dayNumber});
		#(\d+) on (\d+)
		$pattern = $vars->{every}." ".$vars->{dayNumber};
	}
	elsif ($type eq "yearWeek")
	{
		return 0 unless ($vars->{every} && $vars->{weeks} && $vars->{dayNames} && $vars->{months});
		#(\d+) (first,second,third,fourth,last) ([umtwrfs]+)? (jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec)
		$pattern = $vars->{every}." ".join(",",@{$vars->{weeks}})." ".join("",@{$vars->{dayNames}})." ".join(",",@{$vars->{months}});
	}
	elsif ($type eq "yearDay")
	{
		return 0 unless ($vars->{every} && $vars->{dayNumber} && $vars->{months});
		#(\d+) on (\d+) (jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec)
		$pattern = $vars->{every}." ".$vars->{dayNumber}." ".join(",",@{$vars->{months}});
	}
	
	
	my $end	= undef;
	if ($vars->{endAfter})
	{
		$end	= "after ".$vars->{endAfter};
	}
	elsif ($vars->{endDate})
	{
		$end	= $vars->{endDate};
	}
	
	
	my $data	= {
		recurId		=> "new",
		recurType	=> $type,
		pattern		=> $pattern,
		startDate	=> $vars->{startDate},
		endDate		=> $end,
		};
	
	## Set to the database
	## Return the new recurId
	return $self->session->db->setRow("Event_recur","recurId",$data);
}





####################################################################

=head2 setRelatedLinks ( @links )

Sets the event's related links.

=cut

sub setRelatedLinks
{
	my $self	= shift;
	my @links	= @_;
	
	$self->update({
		relatedLinks	=> join("\n", @links),
		});
}





####################################################################

=head2 view

Returns the template to be viewed.

=cut

sub view 
{
	my $self	= shift;
	my $session	= $self->session;
	
	# Get, of course, the event data
	my $var		= $self->get;
	
	
	
	# Get some more template vars
	my %dates	= $self->getTemplateVars;
	$var->{$_}	= $dates{$_}	for keys %dates;
	
	# Next and previous events
	my $next	= $self->getEventNext;
	$var->{"nextUrl"}	= $next->getUrl
		if ($next);
	
	my $prev	= $self->getEventPrev;
	$var->{"prevUrl"}	= $prev->getUrl
		if ($prev);
	
	
	return $self->processTemplate($var, undef, $self->{_viewTemplate});
}





####################################################################

=head2 www_edit

Edit the event.

=cut

sub www_edit
{
	my $self	= shift;
	my $session	= $self->session;
	my $form	= $self->session->form;
	my $tz		= $session->user->profileField("timeZone");
	my $func	= lc $session->form->param("func");
	my $var		= {};

	return $self->session->privilege->noAccess() unless $self->getParent->canAddEvent();	
	
	if ($func eq "add" || $form->param("assetId") eq "new")
	{
		$var->{"formHeader"}	= WebGUI::Form::formHeader($session,
					{
						action	=> $self->getParent->getUrl,
					})
					. WebGUI::Form::hidden($self->session, 
					{
						name	=>"assetId",
						value	=>"new",
					})
					. WebGUI::Form::hidden($self->session, 
					{
						name	=>"class",
						value	=>$self->session->form->process("class","className")
					});
	}
	else
	{
		$var->{"formHeader"}	= WebGUI::Form::formHeader($session,
					{
						action	=> $self->getUrl,
					});
	}
	
	$var->{"formHeader"}	.= WebGUI::Form::hidden($self->session, 
				{
					name	=> "func",
					value	=> "editSave"
				})
				. WebGUI::Form::hidden($self->session,
				{
					name	=> "recurId",
					value	=> $self->get("recurId"),
				});
	
	$var->{"formFooter"}	= WebGUI::Form::formFooter($session);
	
	
	###### Event Tab
	# title AS long title
	$var->{"formTitle"}	= WebGUI::Form::text($session,
				{
					name	=> "title",
					value	=> $form->process("title") || $self->get("title"),
				});
	
	# menu title AS short title
	$var->{"formMenuTitle"}	= WebGUI::Form::text($session,
				{
					name	=> "menuTitle",
					value	=> $form->process("menuTitle") || $self->get("menuTitle"),
					maxlength => 15,
					size	=> 16,
				});
	
	# location
	$var->{"formLocation"}	= WebGUI::Form::text($session,
				{
					name	=> "location",
					value	=> $form->process("location") || $self->get("location"),
				});
	
	# description
	$var->{"formDescription"}= WebGUI::Form::HTMLArea($session,
				{
					name	=> "description",
					value	=> $form->process("description") || $self->get("description"),
				});
	
	# start date
	my $default_start	= WebGUI::DateTime->new($session->form->param("start") || time)
				->set_time_zone($tz);
	my ($startDate,$startTime) = split / /, $self->getDateTimeStart->toMysql
		unless $func eq "add" || $self->get("assetId") eq "new";
	
	$var->{"formStartDate"}= WebGUI::Form::date($session,
			{
				name		=> "startDate",
				value		=> $form->process("startDate") || $startDate,
				defaultValue	=> $default_start->toMysqlDate,
			});
	$var->{"formStartTime"} = WebGUI::Form::timeField($session,
			{
				name		=> "startTime",
				value		=> $form->process("startTime") || $startTime,
				defaultValue	=> $default_start->toMysqlTime,
			});
	
	# end date
	$default_start->add(hours => 1);
	my ($endDate,$endTime) = split / /, $self->getDateTimeEnd->toMysql
		unless $func eq "add" || $self->get("assetId") eq "new";
	$var->{"formEndDate"}	= WebGUI::Form::date($session,
			{
				name		=> "endDate",
				value		=> $form->process("endDate") || $endDate,
				defaultValue	=> $default_start->toMysqlDate,
			});
	$var->{"formEndTime"} = WebGUI::Form::timeField($session,
			{
				name		=> "endTime",
				value		=> $form->process("endTime") || $endTime,
				defaultValue	=> $default_start->toMysqlTime,
			});
	
	# time
	my $allday	= ($form->param("allday") eq "yes" ? 1 : $self->isAllDay);
	$var->{"formTime"}	= 
		q|<input id="allday_yes" type="radio" name="allday" value="yes" |
		.($allday ? 'checked="checked"' : '')
		.q| />
		<label for="allday_yes">No specific time (All day event)</label>
		<br/>
		<input id="allday_no" type="radio" name="allday" value="" |
		.(!$allday ? 'checked="checked"' : '')
		.q| />
		<label for="allday_no">Specific start/end time</label>
		<br />
		<div id="times">|
		.q|Start: |.$var->{"formStartTime"}
		.q|<br/>End: |.$var->{"formEndTime"}
		.q|</div>|;
	
	# related links
	$var->{"formRelatedLinks"}	= WebGUI::Form::textarea($session,
						{
							name	=> "relatedLinks",
							value	=> $form->process("relatedLinks") || $self->get("relatedLinks"),
						});
	
	
	
	###### Recurrence tab
	# Pattern
	my %recur	= $self->getRecurrenceFromForm || $self->getRecurrence;
	$recur{every}	||= 1;
	
	$var->{"formRecurPattern"}	= 
		q|
		<div id="recurPattern">
		<p><input type="radio" name="recurType" id="recurType_none" value="none" onclick="toggleRecur()" />
		<label for="recurType_none">None</label></p>
		
		
		<p><input type="radio" name="recurType" id="recurType_daily" value="daily" onclick="toggleRecur()"  |.($recur{recurType} =~ /^(daily|weekday)$/ ? q|checked="checked"| : q||).q|/>
		<label for="recurType_daily">Daily</label></p>
		<div style="margin-left: 4em;" id="recurPattern_daily">
			Every <input type="text" name="recurDay" size="3" value="|.$recur{every}.q|" /><br/>
			<input type="radio" name="recurSubType" id="recurSubType_daily" value="daily" |.($recur{recurType} eq "daily" ? q|checked="checked"| : q||).q|/>
			<label for="recurSubType_daily">Day(s)</label><br />
			<input type="radio" name="recurSubType" id="recurSubType_weekday" value="weekday" |.($recur{recurType} eq "weekday" ? q|checked="checked"| : q||).q|/>
			<label for="recurSubType_weekday">Weekday(s)</label>
		</div>
		
		
		<p><input type="radio" name="recurType" id="recurType_weekly" value="weekly" onclick="toggleRecur()" |.($recur{recurType} eq "weekly" ? q|checked="checked"| : q||).q|/>
		<label for="recurType_weekly">Weekly</label></p>
		<div style="margin-left: 4em;" id="recurPattern_weekly">
			Every <input type="text" name="recurWeek" size="3" value="|.$recur{every}.q|" /> week(s) on<br/>
			<input type="checkbox" name="recurWeekDay" value="u" id="recurWeekDay_U" |.(grep(/u/,@{$recur{dayNames}}) ? 'checked="checked"' : '' ).q|/>
			<label for="recurWeekDay_U">Sunday</label><br/>
			<input type="checkbox" name="recurWeekDay" value="m" id="recurWeekDay_M" |.(grep(/m/,@{$recur{dayNames}}) ? 'checked="checked"' : '' ).q|/>
			<label for="recurWeekDay_M">Monday</label><br/>
			<input type="checkbox" name="recurWeekDay" value="t" id="recurWeekDay_T" |.(grep(/t/,@{$recur{dayNames}}) ? 'checked="checked"' : '' ).q|/>
			<label for="recurWeekDay_T">Tuesday</label><br/>
			<input type="checkbox" name="recurWeekDay" value="w" id="recurWeekDay_W" |.(grep(/w/,@{$recur{dayNames}}) ? 'checked="checked"' : '' ).q|/>
			<label for="recurWeekDay_W">Wednesday</label><br/>
			<input type="checkbox" name="recurWeekDay" value="r" id="recurWeekDay_R" |.(grep(/r/,@{$recur{dayNames}}) ? 'checked="checked"' : '' ).q|/>
			<label for="recurWeekDay_R">Thursday</label><br/>
			<input type="checkbox" name="recurWeekDay" value="f" id="recurWeekDay_F" |.(grep(/f/,@{$recur{dayNames}}) ? 'checked="checked"' : '' ).q|/>
			<label for="recurWeekDay_F">Friday</label><br/>
			<input type="checkbox" name="recurWeekDay" value="s" id="recurWeekDay_S" |.(grep(/s/,@{$recur{dayNames}}) ? 'checked="checked"' : '' ).q|/>
			<label for="recurWeekDay_S">Saturday</label><br/>
		</div>
		
		
		<p><input type="radio" name="recurType" id="recurType_monthly" value="monthly" onclick="toggleRecur()" |.($recur{recurType} =~ /^month/ ? q|checked="checked"| : q||).q|/>
		<label for="recurType_monthly">Monthly</label></p>
		<div style="margin-left: 4em;" id="recurPattern_monthly">
			<p>Every <input type="text" name="recurMonth" size="3" value="|.$recur{every}.q|" /> month(s) on</p>
			<p><input type="radio" name="recurSubType" id="recurSubType_monthDay" value="monthDay" |.($recur{recurType} eq "monthDay" ? q|checked="checked"| : q||).q|/>
			<label for="recurSubType_monthDay">day </label>
			<input type="text" name="recurMonthDay" size="3" value="|.$recur{dayNumber}.q|"></p>
			
			<p>
			<input style="vertical-align: top;" type="radio" name="recurSubType" id="recurSubType_monthWeek" value="monthWeek" |.($recur{recurType} eq "monthWeek" ? q|checked="checked"| : q||).q|/>
			<select style="vertical-align: top;" name="recurMonthWeekNumber">
				<option |.(grep(/first/, @{$recur{weeks}}) ? 'selected="selected"' : '').q|>first</option>
				<option |.(grep(/second/, @{$recur{weeks}}) ? 'selected="selected"' : '').q|>second</option>
				<option |.(grep(/third/, @{$recur{weeks}}) ? 'selected="selected"' : '').q|>third</option>
				<option |.(grep(/fourth/, @{$recur{weeks}}) ? 'selected="selected"' : '').q|>fourth</option>
				<option |.(grep(/fifth/, @{$recur{weeks}}) ? 'selected="selected"' : '').q|>last</option>
			</select> week on
			<select style="vertical-align: top;" name="recurMonthWeekDay">
				<option value="u" |.(grep(/u/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Sunday</option>
				<option value="m" |.(grep(/m/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Monday</option>
				<option value="t" |.(grep(/t/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Tuesday</option>
				<option value="w" |.(grep(/w/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Wednesday</option>
				<option value="r" |.(grep(/r/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Thursday</option>
				<option value="f" |.(grep(/f/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Friday</option>
				<option value="s" |.(grep(/s/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Saturday</option>
			</select>
			</p>
		</div>
		
		
		<p><input type="radio" name="recurType" id="recurType_yearly" value="yearly" onclick="toggleRecur()" |.($recur{recurType} =~ /^year/ ? q|checked="checked"| : q||).q|/>
		<label for="recurType_yearly">Yearly</label></p>
		<div style="margin-left: 4em;" id="recurPattern_yearly">
			<p>Every <input type="text" name="recurYear" size="3" value="|.$recur{every}.q|" /> years(s) on</p>
			<p>
			<input type="radio" name="recurSubType" id="recurSubType_yearDay" value="yearDay" |.($recur{recurType} eq "yearDay" ? q|checked="checked"| : q||).q|/>
			<select name="recurYearDayMonth">
				<option value="jan" |.(grep(/jan/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>January</option>
				<option value="feb" |.(grep(/feb/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>February</option>
				<option value="mar" |.(grep(/mar/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>March</option>
				<option value="apr" |.(grep(/apr/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>April</option>
				<option value="may" |.(grep(/may/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>May</option>
				<option value="jun" |.(grep(/jun/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>June</option>
				<option value="jul" |.(grep(/jul/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>July</option>
				<option value="aug" |.(grep(/aug/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>August</option>
				<option value="sep" |.(grep(/sep/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>September</option>
				<option value="oct" |.(grep(/oct/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>October</option>
				<option value="nov" |.(grep(/nov/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>November</option>
				<option value="dec" |.(grep(/dec/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>December</option>
			</select>
			<input type="text" name="recurYearDay" size="3" value="|.$recur{dayNumber}.q|"/>
			</p>
			
			<p>
			<input style="vertical-align: top;" type="radio" name="recurSubType" id="recurSubType_yearWeek" value="yearWeek" |.($recur{recurType} eq "yearWeek" ? q|checked="checked"| : q||).q|/>
			<select style="vertical-align: top;" name="recurYearWeekNumber">
				<option |.(grep(/first/, @{$recur{weeks}}) ? 'selected="selected"' : '').q|>first</option>
				<option |.(grep(/second/, @{$recur{weeks}}) ? 'selected="selected"' : '').q|>second</option>
				<option |.(grep(/third/, @{$recur{weeks}}) ? 'selected="selected"' : '').q|>third</option>
				<option |.(grep(/fourth/, @{$recur{weeks}}) ? 'selected="selected"' : '').q|>fourth</option>
				<option |.(grep(/fifth/, @{$recur{weeks}}) ? 'selected="selected"' : '').q|>last</option>
			</select> 
			<select style="vertical-align: top;" name="recurYearWeekDay">
				<option value="u" |.(grep(/u/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Sunday</option>
				<option value="m" |.(grep(/m/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Monday</option>
				<option value="t" |.(grep(/t/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Tuesday</option>
				<option value="w" |.(grep(/w/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Wednesday</option>
				<option value="r" |.(grep(/r/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Thursday</option>
				<option value="f" |.(grep(/f/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Friday</option>
				<option value="s" |.(grep(/s/,@{$recur{dayNames}}) ? 'selected="selected"' : '' ).q|>Saturday</option>
			</select> of 
			<select name="recurYearWeekMonth">
				<option value="jan" |.(grep(/jan/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>January</option>
				<option value="feb" |.(grep(/feb/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>February</option>
				<option value="mar" |.(grep(/mar/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>March</option>
				<option value="apr" |.(grep(/apr/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>April</option>
				<option value="may" |.(grep(/may/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>May</option>
				<option value="jun" |.(grep(/jun/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>June</option>
				<option value="jul" |.(grep(/jul/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>July</option>
				<option value="aug" |.(grep(/aug/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>August</option>
				<option value="sep" |.(grep(/sep/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>September</option>
				<option value="oct" |.(grep(/oct/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>October</option>
				<option value="nov" |.(grep(/nov/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>November</option>
				<option value="dec" |.(grep(/dec/,@{$recur{months}}) ? 'selected="selected"' : '' ).q|>December</option>
			</select>
			</p>
		</div>
		</div>
		|;
	
	
	# Start
	$var->{"formRecurStart"}	= WebGUI::Form::date($session,
				{
					name		=> "recurStart",
					value		=> $recur{startDate},
					defaultValue	=> $self->get("startDate"),
				});
	
	# End
	$var->{"formRecurEnd"}		= q|
		<div><input type="radio" name="recurEndType" id="recurEndType_none" value="none" |.(!$recur{endDate} && !$recur{endAfter} ? 'checked="checked"' : '').q|/>
		<label for="recurEndType_none">No end</label><br />
		
		<input type="radio" name="recurEndType" id="recurEndType_date" value="date" |.($recur{endDate} ? 'checked="checked"' : '' ).q| />
		<label for="recurEndType_date">By date </label>|
		. WebGUI::Form::date($session,{ name => "recurEndDate", value => $recur{endDate}, defaultValue => $recur{endDate} })
		. q|
		<br />
		
		<input type="radio" name="recurEndType" id="recurEndType_after" value="after" |.($recur{endAfter} ? 'checked="checked"' : '' ).q| />
		<label for="recurEndType_after">After </label>
		<input type="text" size="3" name="recurEndAfter" value="|.$recur{endAfter}.q|" /> 
		occurences.
		</div>
	|;
	
	
	# Include
	
	# Exclude
	
	
	
	
	# Add button
	$var->{"formSave"}	= WebGUI::Form::submit($session,
				{
					name	=> "save",
					value	=> "save",
				});
	# Cancel button
	$var->{"formCancel"}	= WebGUI::Form::button($session,
				{
					name	=> "cancel",
					value	=> "cancel",
					extras	=> 'onClick="window.history.go(-1)"',
				});
	
	
	$var->{"formFooter"}	.= <<'ENDJS';
		<script type="text/javascript">
		function toggleTimes()
		{
			if (document.getElementById("allday_no").checked)
			{
				document.getElementById("times").style.display = "block";
			}
			else
			{
				document.getElementById("times").style.display = "none";
			}
		}
		
		YAHOO.util.Event.onContentReady("times",function(e) { toggleTimes(); });
		YAHOO.util.Event.on("allday_no",'click',function(e) { toggleTimes(); });
		YAHOO.util.Event.on("allday_yes",'click',function(e) { toggleTimes(); });
		

		function toggleRecur()
		{
			document.getElementById("recurPattern_daily").style.display = "none";
			document.getElementById("recurPattern_weekly").style.display = "none";
			document.getElementById("recurPattern_monthly").style.display = "none";
			document.getElementById("recurPattern_yearly").style.display = "none";
			
			if (document.getElementById("recurType_daily").checked)
			{
				document.getElementById("recurPattern_daily").style.display = "block";
			}
			else if (document.getElementById("recurType_weekly").checked)
			{
				document.getElementById("recurPattern_weekly").style.display = "block";
			}
			else if (document.getElementById("recurType_monthly").checked)
			{
				document.getElementById("recurPattern_monthly").style.display = "block";
			}
			else if (document.getElementById("recurType_yearly").checked)
			{
				document.getElementById("recurPattern_yearly").style.display = "block";
			}
		}
		YAHOO.util.Event.onAvailable("recurPattern",function(e) { toggleRecur(); });
		</script>
ENDJS
	
	
		
	### Show any errors if necessary
	if ($self->session->stow->get("editFormErrors"))
	{
		my $errors		= $self->session->stow->get("editFormErrors");
		push @{$var->{"formErrors"}}, { message => $_ }
			for @{$errors};
	}
	
	
	
	### Load the template
	my $parent		= $self->getParent;
	my $template;
	if ($parent)
	{
		$template	= WebGUI::Asset::Template->new($session,$parent->get("templateIdEventEdit"));
	}
	else
	{
		$template	= WebGUI::Asset::Template->new($session,"CalendarEventEdit00001");
	}
	
	
	
	### Show the processed template
	$session->http->sendHeader;
	my $style = $session->style->process("~~~",$self->getParent->get("styleTemplateId"));
	my ($head, $foot) = split("~~~",$style);
	$self->session->output->print($head, 1);
	$self->session->output->print($self->processTemplate($var, undef, $template));
	$self->session->output->print($foot, 1);
	return "chunked";
}





####################################################################

=head2 www_view

Shows the event based on the parent asset's style and Event Details template

=head3 URL Parameters

=over 8

=item print

If true, will show the printable version of the event

=back

=cut

sub www_view {
        my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
	my $check = $self->checkView;
	return $check if (defined $check);
	$self->session->http->setCacheControl($self->get("visitorCacheTimeout")) if ($self->session->user->userId eq "1");
        $self->session->http->sendHeader;    
        $self->prepareView;
        my $style = $self->getParent->processStyle("~~~");
        my ($head, $foot) = split("~~~",$style);
        $self->session->output->print($head,1);
        $self->session->output->print($self->view);
        $self->session->output->print($foot,1);
        return "chunked";
}




=head1 Todo

Pages for Next Occurence >> and Prev Occurrence << on the Event Details page

Shared package global to set how many user defined fields there are. 

Fix the Recurrence form. Use WebGUI::Form elements and combine them to create
the form.recurPattern field. If users want to create their own way to make the 
pattern, let them.

Fix the Recurrence storage. Add DateTime::Event::ICal and dependencies to WebGUI
and use ICal recurrence rules. Why did I not do this before? 

When sending ICalendar feeds, send the Recurrence Rule. Currently I'm not going
to be able to do that.

Recurring events should be created by the commit process, so that it's done 
asynchronously with Spectre rather than making the browser wait for a long time
(to make many many events).

Related links need to be implemented using a separate table.

Optimizations!!!

BUG: Events with the same menuTitle, date, and time will not get their Next or
Previous event correctly because of the title. We must check if the title is
equal and then choose by assetId.

=cut

1;
