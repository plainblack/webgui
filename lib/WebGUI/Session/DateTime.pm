package WebGUI::Session::DateTime;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut
use strict;

use DateTime;
use DateTime::Format::Strptime;
use DateTime::Format::Mail;
use DateTime::TimeZone;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;




=head1 NAME

Package WebGUI::Session::DateTime

=head1 DESCRIPTION

This package provides easy to use date math functions, which are normally a complete pain.

=head1 SYNOPSIS

 use WebGUI::Session::DateTime;

 $dt = $session->datetime;
 $dt = WebGUI::Session::DateTime->new($session);
 $session = $dt->session;

 $epoch = $dt-$self->session->datetime->addToDate($epoch, $years, $months, $days);
 $epoch = $dt-$self->session->datetime->addToTime($epoch, $hours, $minutes, $seconds);
 ($startEpoch, $endEpoch) = $dt->dayStartEnd($epoch);
 $dateString = $dt-$self->session->datetime->epochToHuman($epoch, $formatString);
 $setString = $dt-$self->session->datetime->epochToSet($epoch);
 $day = $dt->getDayName($dayInteger);
 $integer = $dt->getDaysInMonth($epoch);
 $integer = $dt->getDaysInInterval($start, $end);
 $integer = $dt->monthCount($start, $end);
 $integer = $dt->getFirstDayInMonthPosition($epoch);
 $month = $dt->getMonthName($monthInteger);
 $seconds = $dt->getSecondsFromEpoch($seconds);
 $zones = $dt->getTimeZones();
 $epoch = $dt-$self->session->datetime->humanToEpoch($dateString);
 $seconds = $dt->intervalToSeconds($interval, $units);
 @date = $dt-$self->session->datetime->loca$self->session->datetime->time($epoch);
 ($startEpoch, $endEpoch) = $dt-$self->session->datetime->monthStartEnd($epoch);
 ($interval, $units) = $dt->secondsToInterval($seconds);
 $timeString = $dt->secondsToTime($seconds);
 $epoch = $dt-$self->session->datetime->setToEpoch($setString);
 $epoch = $dt-$self->time();
 $seconds = $dt->timeToSeconds($timeString);

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addToDate ( epoch [ , years, months, days ] )

Returns an epoch date with the amount of time added.

=head3 epoch

The number of seconds since January 1, 1970.

=head3 years

The number of years to add to the epoch.

=head3 months

The number of months to add to the epoch.

=head3 days

The number of days to add to the epoch. 

=cut

sub addToDate {
	my $self = shift;
	my $date		= DateTime->from_epoch( epoch =>shift);
	my $years 		= shift || 0;
	my $months 	= shift || 0;
	my $days	 	= shift || 0;
	my $currentTimeZone = $date->time_zone->name;
	$date->set_time_zone('UTC'); # do this to prevent date math errors due to daylight savings time shifts
	$date->add(years=>$years, months=>$months, days=>$days);
	$date->set_time_zone($currentTimeZone);
	return $date->epoch;
}

#-------------------------------------------------------------------

=head2 addToTime ( epoch [ , hours, minutes, seconds ] )

Returns an epoch date with the amount of time added.

=head3 epoch

The number of seconds since January 1, 1970.

=head3 hours

The number of hours to add to the epoch.

=head3 minutes

The number of minutes to add to the epoch.

=head3 seconds

The number of seconds to add to the epoch.

=cut

sub addToTime {
	my $self = shift;
	my $epoch = shift;
	return undef unless $epoch;
	my $date		= DateTime->from_epoch( epoch =>$epoch);
	my $hours 		= shift || 0;
	my $mins	 	= shift || 0;
	my $secs	 	= shift || 0;
	$date->add(hours=>$hours, minutes=>$mins, seconds=>$secs);
	return $date->epoch;
}

#-------------------------------------------------------------------

=head2 dayStartEnd ( epoch )

Returns the epoch dates for the start and end of the day.

=head3 epoch

The number of seconds since January 1, 1970.

=cut

sub dayStartEnd {
	my $self = shift;
	my $dt = DateTime->from_epoch( epoch => shift);
	my $end = $dt->clone;	
	$dt->set_hour(0);
	$dt->set_minute(0);
	$dt->set_second(0);
	$end->set_hour(23);
	$end->set_minute(59);
	$end->set_second(59);
        return ($dt->epoch, $end->epoch);
}

#-------------------------------------------------------------------

=head2 DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
        my $self = shift;
        undef $self;
}


#-------------------------------------------------------------------

=head2 epochToHuman ( [ epoch, format ] )

Returns a formated date string.

=head3 epoch

The number of seconds since January 1, 1970. Defaults to NOW!

=head3 format 

A string representing the output format for the date. Defaults to '%z %Z'. You can use the following to format your date string:

 %% = % (percent) symbol.
 %c = The calendar month name.
 %C = The calendar month name abbreviated.
 %d = A two digit day.
 %D = A variable digit day.
 %h = A two digit hour (on a 12 hour clock).
 %H = A variable digit hour (on a 12 hour clock).
 %j = A two digit hour (on a 24 hour clock).
 %J = A variable digit hour (on a 24 hour clock).
 %m = A two digit month.
 %M = A variable digit month.
 %n = A two digit minute.
 %O = Offset from GMT/UTC represented in four digit form with a sign. Example: -0600
 %p = A lower-case am/pm.
 %P = An upper-case AM/PM.
 %s = A two digit second.
 %t = Time zone name.
 %w = Day of the week. 
 %W = Day of the week abbreviated. 
 %y = A four digit year.
 %Y = A two digit year. 
 %z = The current user's date format preference.
 %Z = The current user's time format preference.

=cut

sub epochToHuman {
	my $self = shift;
	my $epoch = shift || $self->time();
	my $i18n = WebGUI::International->new($self->session);
	my $language = $i18n->getLanguage($self->session->user->profileField("language"));
	my $locale = $language->{languageAbbreviation} || "en";
	$locale .= "_".$language->{locale} if ($language->{locale});
	my $timeZone = $self->session->user->profileField("timeZone") || "America/Chicago";
	my $dt = DateTime->from_epoch( epoch=>$epoch, time_zone=>$timeZone, locale=>$locale );
	my $output = shift || "%z %Z";
	my $temp;
  #---date format preference
	$temp = $self->session->user->profileField("dateFormat") || '%M/%D/%y';
	$output =~ s/\%z/$temp/g;
  #---time format preference
	$temp = $self->session->user->profileField("timeFormat") || '%H:%n %p';
	$output =~ s/\%Z/$temp/g;
  #--- convert WebGUI date formats to DateTime formats
	my %conversion = (
		"c" => "B",
		"C" => "b",
		"d" => "d",
		"D" => "e",
		"h" => "I",
		"H" => "l",
		"j" => "H",
		"J" => "k",
		"m" => "m",
		"M" => "_varmonth_",
		"n" => "M",
		"t" => "Z",
		"O" => "z",
		"p" => "P",
		"P" => "p",
		"s" => "S",
		"w" => "A",
		"W" => "a",
		"y" => "Y",
		"Y" => "y"
		);
	$output =~ s/\%(\w)/\~$1/g;
	foreach my $key (keys %conversion) {
		my $replacement = $conversion{$key};
		$output =~ s/\~$key/\%$replacement/g;
	}
  #--- %M
	$output = $dt->strftime($output);
	$temp = int($dt->month);
	$output =~ s/\%_varmonth_/$temp/g;
  #--- return
	return $output;
}

#-------------------------------------------------------------------

=head2 epochToMail ( [ epoch ] )

Formats an epoch date as an RFC2822/822 date, which is what is used in SMTP emails.

=head3 epoch

The date to format. Defaults to now.

=cut

sub epochToMail {
	my $self = shift;
	my $epoch = shift || time();
	my $timeZone = $self->session->user->profileField("timeZone") || "America/Chicago";
	my $dt = DateTime->from_epoch( epoch =>$epoch, time_zone=>$timeZone);
	return DateTime::Format::Mail->format_datetime($dt);
}

#-------------------------------------------------------------------

=head2 epochToSet ( epoch, withTime )

Returns a set date (used by WebGUI::HTMLForm->date) in the format of YYYY-MM-DD. 

=head3 epoch

The number of seconds since January 1, 1970.

=head3 withTime

A boolean indicating that the time should be added to the output, thust turning the format into YYYY-MM-DD HH:MM:SS.

=cut

sub epochToSet {
	my $self = shift;
	my $timeZone = $self->session->user->profileField("timeZone") || "America/Chicago";
	my $dt = DateTime->from_epoch( epoch =>shift, time_zone=>$timeZone);
	my $withTime = shift;
	if ($withTime) {
		return $dt->strftime("%Y-%m-%d %H:%M:%S");
	}
	return $dt->strftime("%Y-%m-%d");
}

#-------------------------------------------------------------------

=head2 getDayName ( day )

Returns a string containing the weekday name in the language of the current user. 

=head3 day

An integer ranging from 1-7 representing the day of the week (Sunday is 1 and Saturday is 7). 

=cut

sub getDayName {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session,'DateTime');
	my $day = $_[0];
        if ($day == 7) {
                return $i18n->get('sunday');
        } elsif ($day == 1) {
                return $i18n->get('monday');
        } elsif ($day == 2) {
                return $i18n->get('tuesday');
        } elsif ($day == 3) {
                return $i18n->get('wednesday');
        } elsif ($day == 4) {
                return $i18n->get('thursday');
        } elsif ($day == 5) {
                return $i18n->get('friday');
        } elsif ($day == 6) {
                return $i18n->get('saturday');
        }
}

#-------------------------------------------------------------------

=head2 getDaysInMonth ( epoch )

Returns the total number of days in the month.

=head3 epoch

An epoch date.

=cut

sub getDaysInMonth {
	my $self = shift;
	my $dt = DateTime->from_epoch( epoch =>shift);
	my $last = DateTime->last_day_of_month(year=>$dt->year, month=>$dt->month);
	return $last->day;
}


#-------------------------------------------------------------------

=head2 getDaysInInterval ( start, end )

Returns the number of days between two epoch dates.

=head3 start

An epoch date.

=head3 end

An epoch date.

=cut

sub getDaysInInterval {
	my $self = shift;
	my $start = DateTime->from_epoch( epoch =>shift);
	my $end = DateTime->from_epoch( epoch =>shift);
	my $duration = $end - $start;
	return $duration->delta_days;
}


#-------------------------------------------------------------------

=head2 getFirstDayInMonthPosition ( epoch) {

Returns the position (1 - 7) of the first day in the month. 1 is Monday.

=head3 epoch

An epoch date.

=cut

sub getFirstDayInMonthPosition {
	my $self = shift;
	my $dt = DateTime->from_epoch( epoch => shift );
	$dt->set_day(1);
	return $dt->day_of_week;
}


#-------------------------------------------------------------------

=head2 getMonthName ( month )

Returns a string containing the calendar month name in the language of the current user.

=head3 month

An integer ranging from 1-12 representing the month.

=cut

sub getMonthName {
	my $self = shift;
	my $i18n = WebGUI::International->new($self->session,'DateTime');
        if ($_[0] == 1) {
                return $i18n->get('january');
        } elsif ($_[0] == 2) {
                return $i18n->get('february');
        } elsif ($_[0] == 3) {
                return $i18n->get('march');
        } elsif ($_[0] == 4) {
                return $i18n->get('april');
        } elsif ($_[0] == 5) {
                return $i18n->get('may');
        } elsif ($_[0] == 6) {
                return $i18n->get('june');
        } elsif ($_[0] == 7) {
                return $i18n->get('july');
        } elsif ($_[0] == 8) {
                return $i18n->get('august');
        } elsif ($_[0] == 9) {
                return $i18n->get('september');
        } elsif ($_[0] == 10) {
                return $i18n->get('october');
        } elsif ($_[0] == 11) {
                return $i18n->get('november');
        } elsif ($_[0] == 12) {
                return $i18n->get('december');
        }
}

#-------------------------------------------------------------------

=head2 getSecondsFromEpoch ( epoch )

Calculates the number of seconds into the day of an epoch date the epoch datestamp is.

=head3 epoch

The number of seconds since January 1, 1970 00:00:00.

=cut

sub getSecondsFromEpoch {
	my $self = shift;
	my $timeZone = $self->session->user->profileField("timeZone") || "America/Chicago";
	my $dt = DateTime->from_epoch( epoch => shift, time_zone => $timeZone );
	my $start = $dt->clone;
	$start->set_hour(0);
        $start->set_minute(0);
        $start->set_second(0);	
	my $duration = $dt - $start;
	return $duration->delta_seconds + 60 * $duration->delta_minutes;
}


#-------------------------------------------------------------------

=head2 getTimeZones ( ) 

Returns a hash reference containing name/value pairs both with the list of time zones.

=cut

sub getTimeZones {
	my $self = shift;
	my %zones;
	tie %zones, 'Tie::IxHash';
	foreach my $zone (@{DateTime::TimeZone::all_names()}) {
		my $zoneLabel = $zone;
		$zoneLabel =~ s/\_/ /g;
		$zones{$zone} = $zoneLabel;	
	}
	return \%zones;
}


#-------------------------------------------------------------------

=head2 humanToEpoch ( date )

Returns an epoch date derived from the human date.

=head3 date

The human date string. YYYY-MM-DD HH:MM:SS 

=cut

sub humanToEpoch {
	my $self = shift;
	my $timeZone = $self->session->user->profileField("timeZone") || "America/Chicago";
	my ($dateString,$timeString) = split(/ /,shift);
	my @date = split(/-/,$dateString);
	my @time = split(/:/,$timeString);
	$time[0] = 0 if $time[0] == 24;
	my $dt = DateTime->new(year => $date[0], month=> $date[1], day=> $date[2], hour=> $time[0], minute => $time[1], second => $time[2], time_zone => $timeZone);
	return $dt->epoch;
} 

#-------------------------------------------------------------------

=head2 intervalToSeconds ( interval, units )

Returns the number of seconds derived from the interval.

=head3 interval

An integer which represents the amount of time for the interval.

=head3 units

A string which represents the units of the interval. The string must be 'years', 'months', 'weeks', 'days', 'hours', 'minutes', or 'seconds'. 

=cut

sub intervalToSeconds {
	my $self = shift;
	my $interval = shift;
	my $units = shift;
	if ($units eq "years") {
		return ($interval*31536000);
	} elsif ($units eq "months") {
		return ($interval*2592000);
        } elsif ($units eq "weeks") {
                return ($interval*604800);
        } elsif ($units eq "days") {
                return ($interval*86400);
        } elsif ($units eq "hours") {
                return ($interval*3600);
        } elsif ($units eq "minutes") {
                return ($interval*60);
        } else {
                return $interval;
	} 
}

#-------------------------------------------------------------------

=head2 localtime ( epoch )

Returns an array of time elements. The elements are: years, months, days, hours, minutes, seconds, day of year, day of week, daylight savings.

=head3 epoch

The number of seconds since January 1, 1970. Defaults to now.

=cut

sub localtime {
	my $self = shift;
	my $dt = DateTime->from_epoch( epoch => shift ||$self->time() );
	$dt->set_time_zone($self->session->user->profileField("timeZone")|| "America/Chicago"); # assign the user's timezone
	return ( $dt->year, $dt->month, $dt->day, $dt->hour, $dt->minute, $dt->second, $dt->day_of_year, $dt->day_of_week, $dt->is_dst );
}

#-------------------------------------------------------------------

=head2 mailToEpoch ( [ date ] )

Converts a mail formatted date into an epoch.

=head3 date

A date formatted according to RFC2822/822.

=cut

sub mailToEpoch {
	my $self = shift;
	my $mail = shift;
	my $parser = DateTime::Format::Mail->new->loose;
	my $dt =  eval { $parser->parse_datetime($mail)};
	if ($@) {
		$self->session->errorHandler->warn($mail." is not a vaild date for email, and is so poorly formatted, we can't even guess what it is.");
		return undef;
	}
	return $dt->epoch;
}

#-------------------------------------------------------------------

=head2 monthCount ( startEpoch, endEpoch )

Returns the number of months between the start and end dates (inclusive).

=head3 startEpoch

An epoch datestamp corresponding to the first month.

=head3 endEpoch

An epoch datestamp corresponding to the last month.

=cut

sub monthCount {
	my $self = shift;
	my $start = DateTime->from_epoch( epoch => shift );
	my $end = DateTime->from_epoch( epoch => shift );
	my $duration = $end - $start;
	return $duration->delta_months;
}


#-------------------------------------------------------------------

=head2 monthStartEnd ( epoch )

Returns the epoch dates for the start and end of the month.

=head3 epoch

The number of seconds since January 1, 1970.

=cut

sub monthStartEnd {
	my $self = shift;
	my $epoch = shift;
	my $dt = DateTime->from_epoch( epoch => $epoch);
	my $end = DateTime->last_day_of_month(year=>$dt->year, month=>$dt->month);
	$dt->set_time_zone($self->session->user->profileField("timeZone")|| "America/Chicago"); # assign the user's timezone
	$end->set_time_zone($self->session->user->profileField("timeZone")|| "America/Chicago"); # assign the user's timezone
	
	$dt->set_day(1);
	$dt->set_hour(0);
	$dt->set_minute(0);
	$dt->set_second(0);
	$end->set_hour(23);
	$end->set_minute(59);
	$end->set_second(59);
    
	return ($dt->epoch, $end->epoch);
}

#-------------------------------------------------------------------

=head2 new ( session )

Constructor.

=head3 session

A reference to the current session.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	bless {_session=>$session}, $class;
}

#-------------------------------------------------------------------

=head2 secondsToInterval ( seconds )

Returns an interval and units derived the number of seconds.

=head3 seconds

The number of seconds in the interval. 

=cut

sub secondsToInterval {
	my $self = shift;
	my $seconds = shift;
	my ($interval, $units);
	if ($seconds >= 31536000) {
		$interval = round($seconds/31536000);
		$units = "years";
	} elsif ($seconds >= 2592000) {
                $interval = round($seconds/2592000);
                $units = "months";
	} elsif ($seconds >= 604800) {
                $interval = round($seconds/604800);
                $units = "weeks";
	} elsif ($seconds >= 86400) {
                $interval = round($seconds/86400);
                $units = "days";
        } elsif ($seconds >= 3600) {
                $interval = round($seconds/3600);
                $units = "hours";
        } elsif ($seconds >= 60) {
                $interval = round($seconds/60);
                $units = "minutes";
        } else {
                $interval = $seconds;
                $units = "seconds";
	}
	return ($interval, $units);
}

#-------------------------------------------------------------------

=head2 secondsToTime ( seconds )

Returns a time string of the format HH::MM::SS on a 24 hour clock. See also timeToSeconds().

=head3 seconds

A number of seconds. 

=cut

sub secondsToTime {
	my $self = shift;
	my $seconds = shift;
	my $timeString = sprintf("%02d",int($seconds / 3600)).":";
	$seconds = $seconds % 3600;	
	$timeString .= sprintf("%02d",int($seconds / 60)).":";
	$seconds = $seconds % 60;
	$timeString .= sprintf("%02d",$seconds);
	return $timeString;
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setToEpoch ( set )

Returns an epoch date.

=head3 set

A string in the format of YYYY-MM-DD or YYYY-MM-DD HH:MM:SS.

=cut

sub setToEpoch {
	my $self = shift;
        my $set = shift;
        return undef unless $set;
	my $parser = DateTime::Format::Strptime->new( pattern => '%Y-%m-%d %H:%M:%S' );
	my $dt = $parser->parse_datetime($set);
	unless ($dt) {
		$parser = DateTime::Format::Strptime->new( pattern => '%Y-%m-%d' );
		$dt = $parser->parse_datetime($set);
	}
	# in epochToSet we apply the user's time zone, so now we have to remove it.
	$dt->set_time_zone($self->session->user->profileField("timeZone")|| "America/Chicago"); # assign the user's timezone
	return $dt->epoch;
}

#-------------------------------------------------------------------

=head2 time ( )

Returns an epoch date for now.

=cut

sub time {
	return time();
}

#-------------------------------------------------------------------

=head2 timeToSeconds ( timeString )

Returns the seconds since 00:00:00 on a 24 hour clock.

=head3 timeString

A string that looks similar to this: 15:05:32

=cut

sub timeToSeconds {
	my $self = shift;
	my ($hour,$min,$sec) = split(/:/,$_[0]);
	return ($hour*60*60+$min*60+$sec);
}


1;
