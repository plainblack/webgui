package WebGUI::DateTime;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2002 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use Date::Calc;
use Exporter;
use strict;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&localtime &time &addToTime &addToDate &epochToHuman &epochToSet &humanToEpoch &setToEpoch &monthStartEnd);



=head1 NAME

 Package WebGUI::DateTime

=head1 SYNOPSIS

 use WebGUI::DateTime;
 $epoch =			WebGUI::DateTime::addToDate($epoch, $years, $months, $days);
 $epoch =			WebGUI::DateTime::addToTime($epoch, $hours, $minutes, $seconds);
 ($startEpoch, $endEpoch) = 	WebGUI::DateTime::dayStartEnd($epoch);
 $dateString = 			WebGUI::DateTime::epochToHuman($epoch, $formatString);
 $setString = 			WebGUI::DateTime::epochToSet($epoch);
 $day = 			WebGUI::DateTime::getDayName($dayInteger);
 $month =			WebGUI::DateTime::getMonthName($monthInteger);
 $epoch =			WebGUI::DateTime::humanToEpoch($dateString);
 $seconds =			WebGUI::DateTime::intervalToSeconds($interval, $units);
 @date =			WebGUI::DateTime::localtime($epoch);
 ($startEpoch, $endEpoch) = 	WebGUI::DateTime::monthStartEnd($epoch);
 ($interval, $units) =		WebGUI::DateTime::secondsToInterval($seconds);
 $epoch =			WebGUI::DateTime::setToEpoch($setString);
 $epoch =			WebGUI::DateTime::time();

=head1 DESCRIPTION

 This package provides easy to use date math functions, which are
 normally a complete pain.

=head1 METHODS

 These functions are available from this package:

=cut




#-------------------------------------------------------------------

=head2 addToDate ( epoch [ , years, months, days ] )

 Returns an epoch date with the amount of time added.

=item epoch

 The number of seconds since January 1, 1970.

=item years

 The number of years to add to the epoch.

=item months

 The number of months to add to the epoch.

=item days

 The number of days to add to the epoch. 

=cut

sub addToDate {
	my ($year,$month,$day, $hour,$min,$sec, $newDate);
	($year,$month,$day, $hour,$min,$sec) = Date::Calc::Time_to_Date($_[0]);
	($year,$month,$day) = Date::Calc::Add_Delta_YMD($year,$month,$day, $_[1],$_[2],$_[3]);
	$newDate = Date::Calc::Date_to_Time($year,$month,$day, $hour,$min,$sec);
	return $newDate;
}

#-------------------------------------------------------------------

=head2 addToTime ( epoch [ , hours, minutes, seconds ] )

 Returns an epoch date with the amount of time added.

=item epoch

 The number of seconds since January 1, 1970.

=item hours

 The number of hours to add to the epoch.

=item minutes

 The number of minutes to add to the epoch.

=item seconds

 The number of seconds to add to the epoch.

=cut

sub addToTime {
        my ($year,$month,$day, $hour,$min,$sec, $newDate);
        ($year,$month,$day, $hour,$min,$sec) = Date::Calc::Time_to_Date($_[0]);
        ($year,$month,$day, $hour,$min,$sec) = Date::Calc::Add_Delta_DHMS($year,$month,$day,$hour,$min,$sec,0,$_[1],$_[2],$_[3]);
        $newDate = Date::Calc::Date_to_Time($year,$month,$day, $hour,$min,$sec);
        return $newDate;
}

#-------------------------------------------------------------------

=head2 dayStartEnd ( epoch )

 Returns the epoch dates for the start and end of the day.

=item epoch

 The number of seconds since January 1, 1970.

=cut

sub dayStartEnd {
        my ($year,$month,$day, $hour,$min,$sec, $start, $end);
        ($year,$month,$day, $hour,$min,$sec) = Date::Calc::Time_to_Date($_[0]);
        $start = Date::Calc::Date_to_Time($year,$month,$day,0,0,0)-43200;
        $end = Date::Calc::Date_to_Time($year,$month,$day,23,59,59);
        return ($start, $end);
}

#-------------------------------------------------------------------

=head2 epochToHuman ( [ epoch, format ] )

 Returns a formated date string.

=item epoch

 The number of seconds since January 1, 1970. Defaults to NOW!

=item format 

 A string representing the output format for the date. Defaults to
 '%z %Z'. You can use the following to format your date string:

 %% = % (percent) symbol.
 %c = The calendar month name.
 %d = A two digit day.
 %D = A variable digit day.
 %h = A two digit hour (on a 12 hour clock).
 %H = A variable digit hour (on a 12 hour clock).
 %j = A two digit hour (on a 24 hour clock).
 %J = A variable digit hour (on a 24 hour clock).
 %m = A two digit month.
 %M = A variable digit month.
 %n = A two digit minute.
 %p = A lower-case am/pm.
 %P = An upper-case AM/PM.
 %s = A two digit second.
 %w = The name of the week. 
 %y = A four digit year.
 %Y = A two digit year. 
 %z = The current user's date format preference.
 %Z = The current user's time format preference.

=cut

sub epochToHuman {
	my ($offset, $temp, $hour12, $value, $output, @date, $day, $month);
	$offset = $session{user}{timeOffset} || 0;
	$offset = $offset*3600;
	$temp = int($_[0]) || time();
	$temp = $temp+$offset;
	@date = &localtime($temp);
	$output = $_[1] || "%z %Z";
  #---dealing with percent symbol
	$output =~ s/\%\%/\%/g;
  #---date format preference
	$temp = $session{user}{dateFormat} || '%M/%D/%y';
	$output =~ s/\%z/$temp/g;
  #---time format preference
	$temp = $session{user}{timeFormat} || '%H:%n %p';
	$output =~ s/\%Z/$temp/g;
  #---year stuff
	$output =~ s/\%y/$date[0]/g;
	$value = substr($date[0],2,2);
	$output =~ s/\%Y/$value/g;
  #---month stuff
	$value = sprintf("%02d",$date[1]);
	$output =~ s/\%m/$value/g;
	$output =~ s/\%M/$date[1]/g;
	if ($output =~ /\%c/) {
		$month = getMonthName($date[1]);
		$output =~ s/\%c/$month/g;
	}
  #---day stuff
	$value = sprintf("%02d",$date[2]);
	$output =~ s/\%d/$value/g;
	$output =~ s/\%D/$date[2]/g;
	if ($output =~ /\%w/) {
		$day = getDayName($date[7]);
		$output =~ s/\%w/$day/g;
	}
  #---hour stuff
	$hour12 = $date[3];
	if ($hour12 > 12) {
		$hour12 = $hour12 - 12;
		if ($hour12 == 0) {
			$hour12 = 12;
		}
	}	
	$value = sprintf("%02d",$hour12);
	$output =~ s/\%h/$value/g;
	$output =~ s/\%H/$hour12/g;
	$value = sprintf("%02d",$date[3]);
	$output =~ s/\%j/$value/g;
	$output =~ s/\%J/$date[3]/g;
	if ($date[3] > 11) {
		$output =~ s/\%p/pm/g;
		$output =~ s/\%P/PM/g;
	} else {
		$output =~ s/\%p/am/g;
		$output =~ s/\%P/AM/g;
	}
  #---minute stuff
	$value = sprintf("%02d",$date[4]);
	$output =~ s/\%n/$value/g;
  #---second stuff
	$value = sprintf("%02d",$date[5]);
	$output =~ s/\%s/$value/g;
	return $output;
}

#-------------------------------------------------------------------

=head2 epochToSet ( epoch )

 Returns a set date (used by WebGUI::HTMLForm->date) in the format
 of MM/DD/YYYY. 

=item epoch

 The number of seconds since January 1, 1970.

=cut

sub epochToSet {
	return epochToHuman($_[0],"%m/%d/%y");
}

#-------------------------------------------------------------------

=head2 getMonthName ( month )

 Returns a string containing the calendar month name in the language
 of the current user.

=item month

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

 Returns a string containing the weekday name in the language of the
 current user. 

=item day

 An integer ranging from 1-7 representing the day of the week (Sunday
 is 1 and Saturday is 7). 

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

=head2 humanToEpoch ( date )

 Returns an epoch date derived from the human date.

=item date

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
	$output = Date::Calc::Date_to_Time(@date);
	return $output;
} 

#-------------------------------------------------------------------

=head2 intervalToSeconds ( interval, units )

 Returns the number of seconds derived from the interval.

=item interval

 An integer which represents the amount of time for the interval.

=item units

 A string which represents the units of the interval. The string
 must be 'years', 'months', 'days', 'hours', 'minutes', or 'seconds'. 

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

 Returns an array of time elements. The elements are: years, months,
 days, hours, minutes, seconds, day of year, day of week, daylight
 savings time.

=item epoch

 The number of seconds since January 1, 1970.

=cut

sub localtime {
	return Date::Calc::Localtime($_[0]);
}

#-------------------------------------------------------------------
=head2 monthCount ( startEpoch, endEpoch )

 Returns the number of months between the start and end dates
 (inclusive).

=item startEpoch

 An epoch datestamp corresponding to the first month.

=item endEpoch

 An epoch datestamp corresponding to the last month.

=cut

sub monthCount {
	my ($start, $end) = @_;
	my $count = 1;
	while (addToDate($start,0,$count,0) < $end) {
		$count++;
	}
	return $count;
}


#-------------------------------------------------------------------

=head2 monthStartEnd ( epoch )

 Returns the epoch dates for the start and end of the month.

=item epoch

 The number of seconds since January 1, 1970.

=cut

sub monthStartEnd {
	my ($year,$month,$day, $hour,$min,$sec, $start, $end);
	($year,$month,$day, $hour,$min,$sec) = Date::Calc::Time_to_Date($_[0]);
	$start = Date::Calc::Date_to_Time($year,$month,1,0,0,0);
	($year,$month,$day, $hour,$min,$sec) = Date::Calc::Time_to_Date(addToDate($_[0],0,1,0));
	$end = Date::Calc::Date_to_Time($year,$month,1,0,0,0)-1;
	return ($start, $end);
}

#-------------------------------------------------------------------

=head2 secondsToInterval ( seconds )

 Returns an interval and units derived the number of seconds.

=item seconds

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

=head2 setToEpoch ( set )

 Returns an epoch date.

=item set

 A string in the format of MM/DD/YYYY.

=cut

sub setToEpoch {
	my @date = &localtime(time());
 	my ($month, $day, $year) = split(/\//,$_[0]);
	if (int($year) < 2038 && int($year) > 1900) {
		$year = int($year);
	} else {
		$year = $date[0];
	}
        if (int($month) < 13 && int($month) > 0) {
                $month = int($month);
        } else {
                $month = $date[1]++;
        }
        if (int($day) < 32 && int($day) > 0) {
                $day = int($day);
        } else {
                $day = $date[2];
        }
	return Date::Calc::Date_to_Time($year,$month,$day,12,0,0);
}

#-------------------------------------------------------------------

=head2 time ( )

 Returns an epoch date.

=cut

sub time {
	return Date::Calc::Mktime(Date::Calc::Today_and_Now());
}

1;
