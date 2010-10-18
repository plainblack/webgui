package WebGUI::Session::DateTime;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use Scalar::Util qw( weaken );
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

 $epoch = $dt->addToDate($epoch, $years, $months, $days);
 $epoch = $dt->addToDateTime($epoch, $years, $months, $days, $hours, $minutes, $seconds);
 $epoch = $dt->addToTime($epoch, $hours, $minutes, $seconds);
 ($startEpoch, $endEpoch) = $dt->dayStartEnd($epoch);
 $dateString = $dt->epochToHttp($epoch);
 $dateString = $dt->epochToHuman($epoch, $formatString);
 $dateString = $dt->epochToMail($epoch);
 $setString = $dt->epochToSet($epoch);
 $day = $dt->getDayName($dayInteger);
 $integer = $dt->getDayOfWeek($epoch);
 $integer = $dt->getDaysInMonth($epoch);
 $integer = $dt->getDaysInInterval($start, $end);
 $integer = $dt->getFirstDayInMonthPosition($epoch);
 $integer = $dt->getMonthDiff($epoch);
 $month = $dt->getMonthName($monthInteger);
 $seconds = $dt->getSecondsFromEpoch($seconds);
 $zone = $dt->getTimeZone();
 $zones = $dt->getTimeZones();
 $epoch = $dt->humanToEpoch($dateString);
 $seconds = $dt->intervalToSeconds($interval, $units);
 ($year, $month, $day, $hour, $minute, $second, $day_of_year, $day_of_week, $is_dst) = $dt->localtime($epoch);
 $epoch = $dt->mailToEpoch($date);
 $integer = $dt->monthCount($start, $end);
 ($startEpoch, $endEpoch) = $dt->monthStartEnd($epoch);
 ($interval, $units) = $dt->secondsToInterval($seconds);
 $timeString = $dt->secondsToTime($seconds);
 $epoch = $dt->setToEpoch($setString);
 $epoch = $dt->time();
 $seconds = $dt->timeToSeconds($timeString);

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 addToDate ( epoch [ , years, months, days ] )

Returns an epoch date with the amount of time added.

=head3 epoch

The number of seconds since January 1, 1970.  Defaults to current date/time.

=head3 years

The number of years to add to the epoch.

=head3 months

The number of months to add to the epoch.

=head3 days

The number of days to add to the epoch. 

=cut

sub addToDate {
	my $self = shift;
	my $epoch = shift || time();
	my $years = shift || 0;
	my $months = shift || 0;
	my $days = shift || 0;
	my $date = DateTime->from_epoch(epoch=>$epoch);
	$date->add(years=>$years, months=>$months, days=>$days);
	return $date->epoch;
}

#-------------------------------------------------------------------

=head2 addToDateTime ( epoch [ , years, months, days, hours, minutes, seconds ] )

Returns an epoch date with the amount of time added.

=head3 epoch

The number of seconds since January 1, 1970. Defaults to current date/time.

=head3 years

The number of years to add to the epoch.

=head3 months

The number of months to add to the epoch.

=head3 days

The number of days to add to the epoch. 

=head3 hours

The number of hours to add to the epoch.

=head3 minutes

The number of minutes to add to the epoch.

=head3 seconds

The number of seconds to add to the epoch.

=cut

sub addToDateTime {
	my $self = shift;
	my $epoch = shift || time();
	my $years = shift || 0;
	my $months = shift || 0;
	my $days = shift || 0;
	my $hours = shift || 0;
	my $mins = shift || 0;
	my $secs = shift || 0;
	my $date = DateTime->from_epoch(epoch=>$epoch);
	$date->add(years=>$years, months=>$months, days=>$days, hours=>$hours, minutes=>$mins, seconds=>$secs);
	return $date->epoch;
}

#-------------------------------------------------------------------

=head2 addToTime ( epoch [ , hours, minutes, seconds ] )

Returns an epoch date with the amount of time added.

=head3 epoch

The number of seconds since January 1, 1970. Defaults to current date/time.

=head3 hours

The number of hours to add to the epoch.

=head3 minutes

The number of minutes to add to the epoch.

=head3 seconds

The number of seconds to add to the epoch.

=cut

sub addToTime {
	my $self = shift;
	my $epoch = shift || time();
	my $hours = shift || 0;
	my $mins = shift || 0;
	my $secs = shift || 0;
	my $date = DateTime->from_epoch(epoch=>$epoch);
	$date->add(hours=>$hours, minutes=>$mins, seconds=>$secs);
	return $date->epoch;
}

#-------------------------------------------------------------------

=head2 dayStartEnd ( [ epoch ] )

Returns the epoch dates for the start and end of the day.

=head3 epoch

The number of seconds since January 1, 1970.

=cut

sub dayStartEnd {
	my $self = shift;
	my $epoch = shift || time();
	my $time_zone = $self->getTimeZone();
	my $dt = DateTime->from_epoch(epoch=>$epoch, time_zone=>$time_zone);
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

=head2 epochToHttp ( [ epoch ] ) 

Converts and epoch date into an HTTP formatted date.

=head3 epoch

An epoch date. Defaults to now.

=cut

sub epochToHttp {
	my $self = shift;
	my $epoch = shift || time();
	my $dt = DateTime->from_epoch(epoch=>$epoch);
	return $dt->strftime('%a, %d %b %Y %H:%M:%S GMT');
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
 %V = week number.
 %w = Day of the week. 
 %W = Day of the week abbreviated. 
 %y = A four digit year.
 %Y = A two digit year. 
 %z = The current user's date format preference.
 %Z = The current user's time format preference.

=cut

sub epochToHuman {
	my $self  = shift;
	my $epoch = shift;
    if (!defined $epoch || $epoch eq '') {
        $epoch = time();
    }
	my $i18n = WebGUI::International->new($self->session);
	my $language = $i18n->getLanguage($self->session->user->profileField('language'));
	my $locale = $language->{languageAbbreviation} || 'en';
	$locale .= "_".$language->{locale} if ($language->{locale});
	my $time_zone = $self->getTimeZone();
	my $dt = DateTime->from_epoch(epoch=>$epoch, time_zone=>$time_zone, locale=>$locale);
	my $output = shift || "%z %Z";
	my $temp;
  #---date format preference
	$temp = $self->session->user->profileField('dateFormat') || '%M/%D/%y';
	$output =~ s/\%z/$temp/g;
  #---time format preference
	$temp = $self->session->user->profileField('timeFormat') || '%H:%n %p';
	$output =~ s/\%Z/$temp/g;
  #--- convert WebGUI date formats to DateTime formats
	my %conversion = (
		"c" => "B",
		"C" => "b",
		"d" => "d",
		"D" => "_varday_",
		"h" => "I",
		"H" => "_varhour_",
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
		"V" => "V",
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
	
	$output = $dt->strftime($output);
	
  #--- %M
	$temp = $dt->month;
	$output =~ s/\%_varmonth_/$temp/g;
  #-- %D
	$temp = $dt->day;
	$output =~ s/\%_varday_/$temp/g;
  #-- %H, variable digit hour, 12 hour clock
	$temp = $dt->hour;
    $temp -= 12 if ($temp > 12); 
	$output =~ s/\%_varhour_/$temp/g;
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
	my $time_zone = $self->getTimeZone();
	my $dt = DateTime->from_epoch(epoch =>$epoch, time_zone=>$time_zone);
	return DateTime::Format::Mail->format_datetime($dt);
}

#-------------------------------------------------------------------

=head2 epochToSet ( [ epoch, withTime ] )

Returns a set date (used by WebGUI::HTMLForm->date) in the format of YYYY-MM-DD. 

=head3 epoch

The number of seconds since January 1, 1970.

=head3 withTime

A boolean indicating that the time should be added to the output, thust turning the format into YYYY-MM-DD HH:MM:SS.

=cut

sub epochToSet {
	my $self = shift;
	my $epoch = shift || time();
	my $withTime = shift;
	my $time_zone = $self->getTimeZone();
	my $dt = DateTime->from_epoch(epoch=>$epoch, time_zone=>$time_zone);
	if ($withTime) {
		return $dt->strftime('%Y-%m-%d %H:%M:%S');
	}
	return $dt->strftime('%Y-%m-%d');
}

#-------------------------------------------------------------------

=head2 getDayName ( day )

Returns a string containing the weekday name in the language of the current user. 

=head3 day

An integer ranging from 1-7 representing the day of the week (Sunday is 1 and Saturday is 7). 

=cut

sub getDayName {
	my $self = shift;
	my $day = shift;
	return undef unless ($day >= 1 && $day <= 7);

	my $i18n = WebGUI::International->new($self->session,'DateTime');
	return $i18n->get((qw/monday tuesday wednesday thursday friday saturday sunday/)[$day-1]);
}

#-------------------------------------------------------------------

=head2 getDayOfWeek ( [ epoch ] ) {

Returns the position (1 - 7) of the day of the week of the epoch passed in. 1 is Monday, 2 is Tuesday, etc

=head3 epoch

An epoch date.

=cut

sub getDayOfWeek {
	my $self = shift;
	my $epoch = shift || time();
	my $time_zone = $self->getTimeZone();
	my $dt = DateTime->from_epoch(epoch=>$epoch, time_zone=>$time_zone);
	return $dt->day_of_week;
}

#-------------------------------------------------------------------

=head2 getDaysInMonth ( [ epoch ] )

Returns the total number of days in the month.

=head3 epoch

An epoch date.

=cut

sub getDaysInMonth {
	my $self = shift;
	my $epoch = shift || time();
	my $time_zone = $self->getTimeZone();
	my $dt = DateTime->from_epoch(epoch=>$epoch, time_zone=>$time_zone);
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
	my $start = shift;
	my $end = shift;
	my $time_zone = $self->getTimeZone();
	$start = DateTime->from_epoch(epoch=>$start, time_zone=>$time_zone);
	$end = DateTime->from_epoch(epoch=>$end, time_zone=>$time_zone);
	return $end->delta_days($start)->delta_days;
}

#-------------------------------------------------------------------

=head2 getFirstDayInMonthPosition ( [ epoch ] )

Returns the position (1 - 7) of the first day in the month. 1 is Monday.

=head3 epoch

An epoch date.

=cut

sub getFirstDayInMonthPosition {
	my $self = shift;
	my $epoch = shift || time();
	my $time_zone = $self->getTimeZone();
	my $dt = DateTime->from_epoch(epoch=>$epoch, time_zone=>$time_zone);
	$dt->set_day(1);
	return $dt->day_of_week;
}

#-------------------------------------------------------------------

=head2 getMonthDiff ( epoch1, epoch2 )

Returns the difference in months between two dates. Days are ignored, so if the two dates are in the same month the result is 0. If epoch1 is in January and epoch2 in February of the same year, the results is 1. Negative numbers are also possible if epoch1 is greater than epoch2.

=head3 epoch1, epoch2

The number of seconds since January 1, 1970.

=cut

sub getMonthDiff {
	my $self = shift;
	my $epoch1 = shift;
	my $epoch2 = shift;
	my ($year1, $month1) = split(' ', $self->epochToHuman($epoch1, '%y %M'));
	my ($year2, $month2) = split(' ', $self->epochToHuman($epoch2, '%y %M'));
	return 12 * ($year2 - $year1) + ($month2 - $month1);
}

#-------------------------------------------------------------------

=head2 getMonthName ( month )

Returns a string containing the calendar month name in the language of the current user.

=head3 month

An integer ranging from 1-12 representing the month.

=cut

sub getMonthName {
	my $self = shift;
	my $month = shift;
	return undef unless ($month >= 1 && $month <= 12);

	my $i18n = WebGUI::International->new($self->session,'DateTime');
	return $i18n->get((qw/january february march april may june
			      july august september october november december/)[$month-1]);
}

#-------------------------------------------------------------------

=head2 getSecondsFromEpoch ( [ epoch ] )

Calculates the number of seconds into the day of an epoch date the epoch datestamp is.

=head3 epoch

The number of seconds since January 1, 1970 00:00:00.

=cut

sub getSecondsFromEpoch {
	my $self = shift;
	my $epoch = shift || time();
	my $time_zone = $self->getTimeZone();
	my $dt = DateTime->from_epoch(epoch=>$epoch, time_zone=>$time_zone);
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

=head2 getTimeZone ( ) 

Returns the timezone for this user, in DateTime::TimeZone format.  Checks to make sure we are sending DateTime::TimeZone a valid one!

=cut

sub getTimeZone {
	my $self = shift;
	return 'America/Chicago' unless defined $self->session->db(1);
	return $self->session->user->{_timeZone} if $self->session->user->{_timeZone};
	my @zones = @{DateTime::TimeZone::all_names()};
	my $zone = $self->session->user->profileField('timeZone');
	$zone =~ s/ /\_/g;
	if ($zone) {
        if (isIn($zone, @zones)) {
				$self->session->user->{_timeZone} = $zone;
				return $zone;
		}
	}
	$self->session->user->{_timeZone} = 'America/Chicago';
	return $self->session->user->{_timeZone};
}

#-------------------------------------------------------------------

=head2 humanToEpoch ( date )

Returns an epoch date derived from the human date.

=head3 date

The human date string. YYYY-MM-DD HH:MM:SS 

=cut

sub humanToEpoch {
	my $self = shift;
	my ($dateString,$timeString) = split(/ /,shift);
	my $time_zone = $self->getTimeZone();
	my @date = split(/-/,$dateString);
	my @time = split(/:/,$timeString);
	$time[0] = 0 if $time[0] == 24;
	my $dt = DateTime->new(year=>$date[0], month=>$date[1], day=>$date[2], hour=>$time[0], minute=>$time[1], second=>$time[2], time_zone=>$time_zone);
	return $dt->epoch;
} 

#-------------------------------------------------------------------

=head2 intervalToSeconds ( interval, units )

Returns the number of seconds derived from the interval.

=head3 interval

An integer which represents the amount of time for the interval.

=head3 units

A string which represents the units of the interval. The string must be (case-insensitive) 'years', 'months', 'weeks', 'days', 'hours', 'minutes', or 'seconds'. 

=cut

sub intervalToSeconds {
	my $self = shift;
	my $interval = shift;
	my $units = shift;
	if (lc $units eq "years") {
		return ($interval*31536000);
	}
    elsif (lc $units eq "months") {
		return ($interval*2592000);
    }
    elsif (lc $units eq "weeks") {
        return ($interval*604800);
    }
    elsif (lc $units eq "days") {
        return ($interval*86400);
    }
    elsif (lc $units eq "hours") {
        return ($interval*3600);
    }
    elsif (lc $units eq "minutes") {
        return ($interval*60);
    }
    else { # seconds
        return $interval;
	} 
}

#-------------------------------------------------------------------

=head2 localtime ( [ epoch ] )

Returns an array of time elements. The elements are: years, months, days, hours, minutes, seconds, day of year, day of week, daylight savings.

=head3 epoch

The number of seconds since January 1, 1970. Defaults to now.

=cut

sub localtime {
	my $self = shift;
	my $epoch = shift || time();
	my $time_zone = $self->getTimeZone();
	my $dt = DateTime->from_epoch(epoch=>$epoch, time_zone=>$time_zone);
	return ($dt->year, $dt->month, $dt->day, $dt->hour, $dt->minute, $dt->second, $dt->day_of_year, $dt->day_of_week, $dt->is_dst);
}

#-------------------------------------------------------------------

=head2 mailToEpoch ( [ date ] )

Converts a mail formatted date into an epoch.

=head3 date

A date formatted according to RFC2822/822.

=cut

sub mailToEpoch {
	my $self = shift;
	my $date = shift;
	my $parser = DateTime::Format::Mail->new->loose;
	my $dt = eval {$parser->parse_datetime($date)};
	if ($@) {
		$self->session->errorHandler->warn($date." is not a valid date for email, and is so poorly formatted, we can't even guess what it is.");
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
	my $startEpoch = shift;
	my $endEpoch = shift;
	my $start = DateTime->from_epoch(epoch=>$startEpoch);
	my $end = DateTime->from_epoch(epoch=>$endEpoch);
	my $duration = $end - $start;
	return $duration->delta_months;
}

#-------------------------------------------------------------------

=head2 monthStartEnd ( [ epoch ] )

Returns the epoch dates for the start and end of the month.

=head3 epoch

The number of seconds since January 1, 1970.

=cut

sub monthStartEnd {
	my $self = shift;
	my $epoch = shift || time();
	my $time_zone = $self->getTimeZone();
	my $dt = DateTime->from_epoch(epoch=>$epoch, time_zone=>$time_zone);
	my $end = DateTime->last_day_of_month(year=>$dt->year, month=>$dt->month, time_zone=>$time_zone);	
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
	my $self = bless {_session=>$session}, $class;
        weaken( $self->{_session} );
        return $self;
}

#-------------------------------------------------------------------

=head2 secondsToInterval ( seconds )

Returns an interval and internationalized units derived the number
of seconds, rounding to the closest unit smaller than the interval.

=head3 seconds

The number of seconds in the interval. 

=cut

sub secondsToInterval {
	my $self = shift;
	my $seconds = shift;
    my $i18n = WebGUI::International->new($self->session, 'WebGUI');
	my ($interval, $units);
	if ($seconds >= 31536000) {
		$interval = round($seconds/31536000);
		$units = $i18n->get("703");
	}
    elsif ($seconds >= 2592000) {
        $interval = round($seconds/2592000);
        $units = $i18n->get("702");
	}
    elsif ($seconds >= 604800) {
        $interval = round($seconds/604800);
        $units = $i18n->get("701");
	}
    elsif ($seconds >= 86400) {
        $interval = round($seconds/86400);
        $units = $i18n->get("700");
    }
    elsif ($seconds >= 3600) {
        $interval = round($seconds/3600);
        $units = $i18n->get("706");
    }
    elsif ($seconds >= 60) {
        $interval = round($seconds/60);
        $units = $i18n->get("705");
    }
    else {
        $interval = $seconds;
        $units = $i18n->get("704");
	}
	return ($interval, $units);
}

#-------------------------------------------------------------------

=head2 secondsToExactInterval ( seconds )

Returns an interval and internationalized units derived the number of seconds.

=head3 seconds

The number of seconds in the interval. 

=cut

sub secondsToExactInterval {
    my $self = shift;
    my $seconds = shift;
    my $i18n = WebGUI::International->new($self->session, 'WebGUI');
    my %units = (
        31536000    => "703", # years
        2592000     => "702", # months
        604800      => "701", # weeks
        86400       => "700", # days
        3600        => "706", # hours
        60          => "705", # minutes
    );
    for my $unit (sort { $b <=> $a } keys %units) {
        if ($seconds % $unit == 0) {
            return ($seconds / $unit, $i18n->get($units{$unit}));
        }
    }
    return ($seconds, $i18n->get("704")); # seconds
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
	my $time_zone = $self->getTimeZone();
	my $parser = DateTime::Format::Strptime->new(pattern=>'%Y-%m-%d %H:%M:%S', time_zone=>$time_zone);
	my $dt = $parser->parse_datetime($set);
	unless ($dt) {
		$parser = DateTime::Format::Strptime->new(pattern=>'%Y-%m-%d', time_zone=>$time_zone);
		$dt = $parser->parse_datetime($set);
	}
	unless ($dt) {
		$self->session->errorHandler->warn("Could not format date $set for epoch.  Returning current time");
		return time();
	}
	return $dt->epoch;
}

#-------------------------------------------------------------------

=head2 time ( )

DEPRECATED - This method is deprecated, and should not be used in new code.  Use
the perl built in function time().

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
