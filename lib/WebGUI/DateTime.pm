package WebGUI::DateTime;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Date::Calc;
use Exporter;
use strict;
use Time::Local;
use WebGUI::International;

our @ISA = qw(Exporter);
our @EXPORT = qw(&addToTime &addToDate &epochToHuman &epochToSet &humanToEpoch &setToEpoch &monthStartEnd);

#-------------------------------------------------------------------
sub _getMonth { 
	my %month = (
	1=> 	WebGUI::International::get(15),
	2=>	WebGUI::International::get(16),
	3=>	WebGUI::International::get(17),
	4=>	WebGUI::International::get(18),
	5=>	WebGUI::International::get(19),
	6=>	WebGUI::International::get(20),
	7=>	WebGUI::International::get(21),
	8=>	WebGUI::International::get(22),
	9=>	WebGUI::International::get(23),
	10=>	WebGUI::International::get(24),
	11=>	WebGUI::International::get(25),
	12=>	WebGUI::International::get(26)	
	);
	return %month;
}

#-------------------------------------------------------------------
sub _getWeekday {
	my %weekday = (
		1=>	WebGUI::International::get(27),
		2=>	WebGUI::International::get(28),
		3=>	WebGUI::International::get(29),
		4=>	WebGUI::International::get(30),
		5=>	WebGUI::International::get(31),
		6=>	WebGUI::International::get(32),
		7=> 	WebGUI::International::get(33)
		);
	return %weekday;
}

#-------------------------------------------------------------------
sub addToDate {
	my ($year,$month,$day, $hour,$min,$sec, $newDate);
	($year,$month,$day, $hour,$min,$sec) = Date::Calc::Time_to_Date($_[0]);
	($year,$month,$day) = Date::Calc::Add_Delta_YMD($year,$month,$day, $_[1],$_[2],$_[3]);
	$newDate = Date::Calc::Date_to_Time($year,$month,$day, $hour,$min,$sec);
	return $newDate;
}

#-------------------------------------------------------------------
sub addToTime {
        my ($year,$month,$day, $hour,$min,$sec, $newDate);
        ($year,$month,$day, $hour,$min,$sec) = Date::Calc::Time_to_Date($_[0]);
        ($year,$month,$day, $hour,$min,$sec) = Date::Calc::Add_Delta_DHMS($year,$month,$day,$hour,$min,$sec,0,$_[1],$_[2],$_[3]);
        $newDate = Date::Calc::Date_to_Time($year,$month,$day, $hour,$min,$sec);
        return $newDate;
}

#-------------------------------------------------------------------
sub epochToHuman {
	my ($hour12, $value, $output, @date, %weekday, %month);

      #  0    1    2     3     4    5     6     7     8
#      $sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
#                                                               localtime(time);
#
#               All list elements are numeric, and come straight
#               out of the C `struct tm'.  $sec, $min, and $hour
#               are the seconds, minutes, and hours of the
#               specified time.  $mday is the day of the month,
#               and $mon is the month itself, in the range `0..11'
#               with 0 indicating January and 11 indicating
#               December.  $year is the number of years since
#               1900.  That is, $year is `123' in year 2023.
#               $wday is the day of the week, with 0 indicating
#               Sunday and 3 indicating Wednesday.  $yday is the
#               day of the year, in the range `1..365' (or
#               `1..366' in leap years.)  $isdst is true if the
#               specified time occurs during daylight savings
#               time, false otherwise.

	@date = localtime($_[0]);
	$date[4]++; 		# offset the months starting from 0
	$date[5] += 1900;	# original value is Year-1900
	$date[6]++;		# offset for weekdays starting from 0
	$output = $_[1];
  #---dealing with percent symbol
	$output =~ s/\%\%/\%/g;
  #---year stuff
	$output =~ s/\%y/$date[5]/g;
	$value = substr($date[5],2,2);
	$output =~ s/\%Y/$value/g;
  #---month stuff
	$value = sprintf("%02d",$date[4]);
	$output =~ s/\%m/$value/g;
	$output =~ s/\%M/$date[4]/g;
	if ($output =~ /\%c/) {
		%month = _getMonth();
		$output =~ s/\%c/$month{$date[4]}/g;
	}
  #---day stuff
	$value = sprintf("%02d",$date[3]);
	$output =~ s/\%d/$value/g;
	$output =~ s/\%D/$date[3]/g;
	if ($output =~ /\%w/) {
		%weekday = _getWeekday();
		$output =~ s/\%w/$weekday{$date[6]}/g;
	}
  #---hour stuff
	$hour12 = $date[2];
	if ($hour12 > 12) {
		$hour12 = $hour12 - 12;
	}	
	$value = sprintf("%02d",$hour12);
	$output =~ s/\%h/$value/g;
	$output =~ s/\%H/$hour12/g;
	$value = sprintf("%02d",$date[2]);
	$output =~ s/\%j/$value/g;
	$output =~ s/\%J/$date[2]/g;
	if ($date[2] > 11) {
		$output =~ s/\%p/pm/g;
		$output =~ s/\%P/PM/g;
	} else {
		$output =~ s/\%p/am/g;
		$output =~ s/\%P/AM/g;
	}
  #---minute stuff
	$value = sprintf("%02d",$date[1]);
	$output =~ s/\%n/$value/g;
  #---second stuff
	$value = sprintf("%02d",$date[0]);
	$output =~ s/\%s/$value/g;
	return $output;
}

#-------------------------------------------------------------------
sub epochToSet {
	return epochToHuman($_[0],"%m/%d/%y");
}

#-------------------------------------------------------------------
# eg: humanToEpoch(YYYY-MM-DD HH:MM:SS)
sub humanToEpoch {
	my (@temp, $dateString, $timeString, $output, @date);
	($dateString,$timeString) = split(/ /,$_[0]);
	@temp = split(/-/,$dateString);
	$date[5] = $temp[0]-1900;
	$date[4] = $temp[1]-1;
	$date[3] = $temp[2]+0;
	@temp = split(/:/,$timeString);
	$date[2] = $temp[0]+0;
	$date[1] = $temp[1]+0;
	$date[0] = $temp[2]+0;
	$output = timelocal(@date);
	return $output;
} 

#-------------------------------------------------------------------
sub monthStartEnd {
	my ($year,$month,$day, $hour,$min,$sec, $start, $end);
	($year,$month,$day, $hour,$min,$sec) = Date::Calc::Time_to_Date($_[0]);
	$start = Date::Calc::Date_to_Time($year,$month,1,0,0,0);
	($year,$month,$day, $hour,$min,$sec) = Date::Calc::Time_to_Date(addToDate($_[0],0,1,0));
	$end = Date::Calc::Date_to_Time($year,$month,1,0,0,0)-1;
	return ($start, $end);
}

#-------------------------------------------------------------------
sub setToEpoch {
	my @date = localtime(time());
 	my ($month, $day, $year) = split(/\//,$_[0]);
	if (int($year) < 2038 && int($year) > 1900) {
		$year = int($year);
	} else {
		$year = $date[5]+1900;
	}
        if (int($month) < 13 && int($month) > 0) {
                $month = int($month);
        } else {
                $month = $date[4]++;
        }
        if (int($day) < 32 && int($day) > 0) {
                $day = int($day);
        } else {
                $day = $date[3];
        }
	return humanToEpoch($year.'-'.$month.'-'.$day.' 00:00:00');
}



1;
