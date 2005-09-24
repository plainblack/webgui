package WebGUI::DateTime;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use Date::Manip;
use Exporter;
use strict;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&localtime &time &addToTime &addToDate &epochToHuman &epochToSet &humanToEpoch &setToEpoch &monthStartEnd);



=head1 NAME

Package WebGUI::DateTime

=head1 DESCRIPTION

This package provides easy to use date math functions, which are normally a complete pain.

=head1 SYNOPSIS

 use WebGUI::DateTime;
 $epoch = WebGUI::DateTime::addToDate($epoch, $years, $months, $days);
 $epoch = WebGUI::DateTime::addToTime($epoch, $hours, $minutes, $seconds);
 $epoch = WebGUI::DateTime::arrayToEpoch(@date);
 ($startEpoch, $endEpoch) = WebGUI::DateTime::dayStartEnd($epoch);
 @date = WebGUI::DateTime::epochToArray($epoch);
 $dateString = WebGUI::DateTime::epochToHuman($epoch, $formatString);
 $setString = WebGUI::DateTime::epochToSet($epoch);
 $day = WebGUI::DateTime::getDayName($dayInteger);
 $integer = WebGUI::DateTime::getDaysInMonth($epoch);
 $integer = WebGUI::DateTime::getDaysInInterval($start, $end);
 $integer = WebGUI::DateTime::getFirstDayInMonthPosition($epoch);
 $month = WebGUI::DateTime::getMonthName($monthInteger);
 $seconds = WebGUI::DateTime::getSecondsFromEpoch($seconds);
 $epoch = WebGUI::DateTime::humanToEpoch($dateString);
 $seconds = WebGUI::DateTime::intervalToSeconds($interval, $units);
 @date = WebGUI::DateTime::localtime($epoch);
 ($startEpoch, $endEpoch) = WebGUI::DateTime::monthStartEnd($epoch);
 ($interval, $units) = WebGUI::DateTime::secondsToInterval($seconds);
 $timeString = WebGUI::DateTime::secondsToTime($seconds);
 $epoch = WebGUI::DateTime::setToEpoch($setString);
 $epoch = WebGUI::DateTime::time();
 $seconds = WebGUI::DateTime::timeToSeconds($timeString);

=head1 METHODS

These functions are available from this package:

=cut

sub epochToDate {
	my $secs	= shift;
	my ($cache, $value);
	if ($session{config}{enableDateCache}) {
		$cache = WebGUI::Cache->new(["epochToDate",$secs],"DateTime");
		$value = $cache->get;
	}
	return $value if ($value);
	my $converted = &ParseDateString("epoch $secs");
	$cache->set($converted) if ($session{config}{enableDateCache});
	return $converted;
}

sub dateToEpoch {
	my $date = shift;
	my ($cache, $value);
	if ($session{config}{enableDateCache}) {
		$cache = WebGUI::Cache->new(["dateToEpoch",$date],"DateTime");
		$value = $cache->get;
	}
	return $value if ($value);
	my $converted = &UnixDate($date,"%s");
	$cache->set($converted) if ($session{config}{enableDateCache});
	return $converted;
}



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
	my ($date,$years,$months,$days,$newDate);
	$date		= &epochToDate(shift);
	$years 		= shift || 0;
	$months 	= shift || 0;
	$days	 	= shift || 0;
	$newDate 	= DateCalc($date,"+$years:$months:0:$days:0:0:0");
	return &dateToEpoch($newDate);
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
	my ($date,$hours,$mins,$secs,$newDate);
	$date		= &epochToDate(shift);
	$hours 		= shift || 0;
	$mins	 	= shift || 0;
	$secs	 	= shift || 0;
	$newDate 	= DateCalc($date,"+0:0:0:0:$hours:$mins:$secs");
	return &dateToEpoch($newDate);
}

#-------------------------------------------------------------------

=head2 arrayToEpoch ( date )

Returns an epoch date.

=head3 date

An array of the format year, month, day, hour, min, sec.

=cut

sub arrayToEpoch {
	my $year 	=  shift || '0000';
	my $month 	=  shift || '00';
	my $day		=  shift || '00';
	my $hour	=  shift || '00';
	my $min		=  shift || '00';
	my $sec		=  shift || '00';
	$min = "0$min" if (length($min) == 1);
	$sec = "0$sec" if (length($sec) == 1);
	return &dateToEpoch(&ParseDate("$year-$month-$day $hour:$min:$sec"));
}


#-------------------------------------------------------------------

=head2 dayStartEnd ( epoch )

Returns the epoch dates for the start and end of the day.

=head3 epoch

The number of seconds since January 1, 1970.

=cut

sub dayStartEnd {
        my ($year,$month,$day, $hour,$min,$sec, $start, $end);
        ($year,$month,$day, $hour,$min,$sec) = epochToArray($_[0]);
        $start = &arrayToEpoch($year,$month,$day,0,0,0);
        $end = &arrayToEpoch($year,$month,$day,23,59,59);
        return ($start, $end);
}

#-------------------------------------------------------------------

=head2 epochToArray ( epoch ) 

Returns a date array in the form of year, month, day, hour, min, sec.

=head3 epoch

An epoch date.

=cut

sub epochToArray {
	my $epoch = shift;
	my @date = &UnixDate(epochToDate($epoch),'%Y','%m','%d','%H','%M','%S');
	$date[0] = $date[0]+0;
	$date[1] = $date[1]+0;
	$date[2] = $date[2]+0;
	$date[3] = $date[3]+0;
	$date[4] = $date[4]+0;
	$date[5] = $date[5]+0;
	return @date;
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
 %C = The calendar month name abbreviated to 3 characters and represented in English.
 %d = A two digit day.
 %D = A variable digit day.
 %h = A two digit hour (on a 12 hour clock).
 %H = A variable digit hour (on a 12 hour clock).
 %j = A two digit hour (on a 24 hour clock).
 %J = A variable digit hour (on a 24 hour clock).
 %m = A two digit month.
 %M = A variable digit month.
 %n = A two digit minute.
 %o = Offset from local time represented as an integer.
 %O = Offset from GMT represented in four digit form with a sign. Example: -0600
 %p = A lower-case am/pm.
 %P = An upper-case AM/PM.
 %s = A two digit second.
 %w = Day of the week. 
 %W = Day of the week abbreviated to 3 characters and represented in English. 
 %y = A four digit year.
 %Y = A two digit year. 
 %z = The current user's date format preference.
 %Z = The current user's time format preference.

=cut

sub epochToHuman {
	my ($offset, $temp, $hour12, $value, $output);
	$offset = $session{user}{timeOffset} || 0;
	$offset = $offset*3600;
	$temp = int($_[0]) || WebGUI::DateTime::time();
	$temp = $temp+$offset;
	my $dt = epochToDate($temp);
	my ($year,$month,$day,$hour,$min,$sec) = epochToArray($temp);
	$output = $_[1] || "%z %Z";
  #---GMT Offsets
	if ($output =~ /\%O/) {
		$temp = $session{user}{timeOffset}*100;
		$temp = sprintf("%+05d",Date::Manip::UnixDate("now","%z")+$temp);
		$output =~ s/\%O/$temp/g;
	}
	$temp = $session{user}{timeOffset}+0;
	$output =~ s/\%o/$temp/g;
  #---dealing with percent symbol
	$output =~ s/\%\%/\%/g;
  #---date format preference
	$temp = $session{user}{dateFormat} || '%M/%D/%y';
	$output =~ s/\%z/$temp/g;
  #---time format preference
	$temp = $session{user}{timeFormat} || '%H:%n %p';
	$output =~ s/\%Z/$temp/g;
  #---year stuff
	$output =~ s/\%y/$year/g;
	$value = substr($year,2,2);
	$output =~ s/\%Y/$value/g;
  #---month stuff
	$value = sprintf("%02d",$month);
	$output =~ s/\%m/$value/g;
	$output =~ s/\%M/$month/g;
	if ($output =~ /\%c/) {
		$temp = getMonthName($month);
		$output =~ s/\%c/$temp/g;
	}
	if ($output =~ /\%C/) {
		$temp = &UnixDate($dt,'%b');
		$output =~ s/\%C/$temp/g;
	}
  #---day stuff
	$value = sprintf("%02d",$day);
	$output =~ s/\%d/$value/g;
	$output =~ s/\%D/$day/g;
	if ($output =~ /\%w/) {
		$temp = getDayName(&UnixDate($dt,'%w'));
		$output =~ s/\%w/$temp/g;
	}
	if ($output =~ /%W/) {
		$temp = &UnixDate($dt,'%a');
		$output =~ s/\%W/$temp/g;
	}
  #---hour stuff
	$hour12 = $hour;
	if ($hour12 > 12) {
		$hour12 = $hour12 - 12;
	}	
	if ($hour12 == 0) {
		$hour12 = 12;
	}
	$value = sprintf("%02d",$hour12);
	$output =~ s/\%h/$value/g;
	$output =~ s/\%H/$hour12/g;
	$value = sprintf("%02d",$hour);
	$output =~ s/\%j/$value/g;
	$output =~ s/\%J/$hour/g;
	if ($hour > 11) {
		$output =~ s/\%p/pm/g;
		$output =~ s/\%P/PM/g;
	} else {
		$output =~ s/\%p/am/g;
		$output =~ s/\%P/AM/g;
	}
  #---minute stuff
	$value = sprintf("%02d",$min);
	$output =~ s/\%n/$value/g;
  #---second stuff
	$value = sprintf("%02d",$sec);
	$output =~ s/\%s/$value/g;
	return $output;
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
	if ($_[1]) {
		return epochToHuman($_[0],"%y-%m-%d %j:%n:%s");
	}
	return epochToHuman($_[0],"%y-%m-%d");
}

#-------------------------------------------------------------------

=head2 getMonthName ( month )

Returns a string containing the calendar month name in the language of the current user.

=head3 month

An integer ranging from 1-12 representing the month.

=cut

sub getMonthName {
        if ($_[0] == 1) {
                return WebGUI::International::get(15);
        } elsif ($_[0] == 2) {
                return WebGUI::International::get(16);
        } elsif ($_[0] == 3) {
                return WebGUI::International::get(17);
        } elsif ($_[0] == 4) {
                return WebGUI::International::get(18);
        } elsif ($_[0] == 5) {
                return WebGUI::International::get(19);
        } elsif ($_[0] == 6) {
                return WebGUI::International::get(20);
        } elsif ($_[0] == 7) {
                return WebGUI::International::get(21);
        } elsif ($_[0] == 8) {
                return WebGUI::International::get(22);
        } elsif ($_[0] == 9) {
                return WebGUI::International::get(23);
        } elsif ($_[0] == 10) {
                return WebGUI::International::get(24);
        } elsif ($_[0] == 11) {
                return WebGUI::International::get(25);
        } elsif ($_[0] == 12) {
                return WebGUI::International::get(26);
        }
}

#-------------------------------------------------------------------

=head2 getDayName ( day )

Returns a string containing the weekday name in the language of the current user. 

=head3 day

An integer ranging from 1-7 representing the day of the week (Sunday is 1 and Saturday is 7). 

=cut

sub getDayName {
	my $day = $_[0];
        if ($day == 7) {
                return WebGUI::International::get(27);
        } elsif ($day == 1) {
                return WebGUI::International::get(28);
        } elsif ($day == 2) {
                return WebGUI::International::get(29);
        } elsif ($day == 3) {
                return WebGUI::International::get(30);
        } elsif ($day == 4) {
                return WebGUI::International::get(31);
        } elsif ($day == 5) {
                return WebGUI::International::get(32);
        } elsif ($day == 6) {
                return WebGUI::International::get(33);
        }
}

#-------------------------------------------------------------------

=head2 getDaysInMonth ( epoch )

Returns the total number of days in the month.

=head3 epoch

An epoch date.

=cut

sub getDaysInMonth {
	my $epoch = shift;
	my @date = WebGUI::DateTime::epochToArray($epoch);
	return &Date_DaysInMonth($date[1], $date[0]);
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
	my $start = &epochToDate(shift);
	my $end = &epochToDate(shift);
	my $err;
	my $delta = &DateCalc($start,$end,\$err);
	return &Delta_Format($delta,0,'%dh');
}



#-------------------------------------------------------------------

=head2 getFirstDayInMonthPosition ( epoch) {

Returns the position (1 - 7) of the first day in the month.

=head3 epoch

An epoch date.

=cut

sub getFirstDayInMonthPosition {
	my $epoch = shift;
	my @date = WebGUI::DateTime::epochToArray($epoch);
	my $firstDayInFirstWeek = &UnixDate("$date[0]-$date[1]-01",'%w');
	unless ($session{user}{firstDayOfWeek}) { #american format
        	$firstDayInFirstWeek++;
        	if ($firstDayInFirstWeek > 7) {
                	$firstDayInFirstWeek = 1;
        	}
	}
	return $firstDayInFirstWeek;
}


#-------------------------------------------------------------------

=head2 getSecondsFromEpoch ( epoch )

Calculates the number of seconds into the day of an epoch date the epoch datestamp is.

=head3 epoch

The number of seconds since January 1, 1970 00:00:00.

=cut

sub getSecondsFromEpoch {
	return timeToSeconds(epochToHuman($_[0],"%j:%n:%s"));
}



#-------------------------------------------------------------------

=head2 humanToEpoch ( date )

Returns an epoch date derived from the human date.

=head3 date

The human date string. YYYY-MM-DD HH:MM:SS 

=cut

sub humanToEpoch {
	my (@temp, $dateString, $timeString, $output, @date);
	($dateString,$timeString) = split(/ /,$_[0]);
	@temp = split(/-/,$dateString);
	$date[0] = int($temp[0]);
	$date[1] = int($temp[1]);
	$date[2] = int($temp[2]);
	@temp = split(/:/,$timeString);
	$date[3] = int($temp[0]);
	$date[4] = int($temp[1]);
	$date[5] = int($temp[2]);
	$output = arrayToEpoch(@date);
	return $output;
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
	if ($_[1] eq "years") {
		return ($_[0]*31536000);
	} elsif ($_[1] eq "months") {
		return ($_[0]*2592000);
        } elsif ($_[1] eq "weeks") {
                return ($_[0]*604800);
        } elsif ($_[1] eq "days") {
                return ($_[0]*86400);
        } elsif ($_[1] eq "hours") {
                return ($_[0]*3600);
        } elsif ($_[1] eq "minutes") {
                return ($_[0]*60);
        } else {
                return $_[0];
	} 
}

#-------------------------------------------------------------------

=head2 localtime ( epoch )

Returns an array of time elements. The elements are: years, months, days, hours, minutes, seconds, day of year, day of week, daylight savings.

=head3 epoch

The number of seconds since January 1, 1970. Defaults to now.

=cut

sub localtime {
	my $epoch = shift || &dateToEpoch(&ParseDate("today"));
	my $date  = &epochToDate($epoch);
	my ($year, $month, $day, $hour, $min, $sec) = epochToArray($epoch);
	if ($epoch) {
		($year, $month, $day, $hour, $min, $sec) = epochToArray($epoch);
	}
	my $doy = &UnixDate($date,'%j');
	my $dow = &UnixDate($date,'%w');
	my @temp = localtime($epoch);
	return ($year, $month, $day, $hour, $min, $sec, $doy, $dow, $temp[8]);
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
	my $start = &epochToDate(shift);
	my $end = &epochToDate(shift);
	my $err;
	my $delta = &DateCalc($start,$end,\$err,1);
	my $count = 1+&Delta_Format($delta,0,'%Mv')+&Delta_Format($delta,0,'%yv')*12;
	return $count;
}


#-------------------------------------------------------------------

=head2 monthStartEnd ( epoch )

Returns the epoch dates for the start and end of the month.

=head3 epoch

The number of seconds since January 1, 1970.

=cut

sub monthStartEnd {
    my ($year,$month,$day, $hour,$min,$sec, $start, $end);
    ($year,$month,$day, $hour,$min,$sec) = epochToArray($_[0]);
    $start = &arrayToEpoch($year,$month,1,0,0,0) + 0;
    $end = &UnixDate(&DateCalc(&epochToDate($start), "+1 month"),'%s')-1;
    return ($start, $end);
}

#-------------------------------------------------------------------

=head2 secondsToInterval ( seconds )

Returns an interval and units derived the number of seconds.

=head3 seconds

The number of seconds in the interval. 

=cut

sub secondsToInterval {
	my ($interval, $units);
	if ($_[0] >= 31536000) {
		$interval = round($_[0]/31536000);
		$units = "years";
	} elsif ($_[0] >= 2592000) {
                $interval = round($_[0]/2592000);
                $units = "months";
	} elsif ($_[0] >= 604800) {
                $interval = round($_[0]/604800);
                $units = "weeks";
	} elsif ($_[0] >= 86400) {
                $interval = round($_[0]/86400);
                $units = "days";
        } elsif ($_[0] >= 3600) {
                $interval = round($_[0]/3600);
                $units = "hours";
        } elsif ($_[0] >= 60) {
                $interval = round($_[0]/60);
                $units = "minutes";
        } else {
                $interval = $_[0];
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
	my $seconds = $_[0];
	my $timeString = sprintf("%02d",int($seconds / 3600)).":";
	$seconds = $seconds % 3600;	
	$timeString .= sprintf("%02d",int($seconds / 60)).":";
	$seconds = $seconds % 60;
	$timeString .= sprintf("%02d",$seconds);
	return $timeString;
}


#-------------------------------------------------------------------

=head2 setToEpoch ( set )

Returns an epoch date.

=head3 set

A string in the format of YYYY-MM-DD or YYYY-MM-DD HH:MM:SS.

=cut

sub setToEpoch {
        my $set = shift;
        my @now = epochToArray(WebGUI::DateTime::time());
        my ($date,$time) = split(/ /,$set);
        my ($year, $month, $day) = split(/\-/,$date);
        my ($hour, $minute, $second) = split(/\:/,$time);
        if (int($year) < 3000 && int($year) > 1000) {
                $year = int($year);
        } else {
                $year = $now[0];
        } 
        if (int($month) < 13 && int($month) > 0) {
                $month = int($month);
        } else {
                $month = $now[1]++;
        }
        if (int($day) < 32 && int($day) > 0) {
                $day = int($day);
        } else {
                $day = $now[2];
        }
        my $epoch = arrayToEpoch($year,$month,$day,$hour,$minute,$second);
        # in epochToSet we use epochToHuman, which includes the time
        # offset of the user, so we need to remove that here.
        my $offset = $session{user}{timeOffset} || 0;
        $epoch -= $offset*3600;
        return $epoch;
}

#-------------------------------------------------------------------

=head2 time ( )

Returns an epoch date for now.

=cut

sub time {
	#return dateToEpoch(&ParseDate("now"));
	return time;
}

#-------------------------------------------------------------------

=head2 timeToSeconds ( timeString )

Returns the seconds since 00:00:00 on a 24 hour clock.

=head3 timeString

A string that looks similar to this: 15:05:32

=cut

sub timeToSeconds {
	my ($hour,$min,$sec) = split(/:/,$_[0]);
	return ($hour*3600+$min*60+$sec);
}


1;
