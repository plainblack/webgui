package WebGUI::DateTime;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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
use WebGUI::International;
use WebGUI::Session;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&localtime &time &addToTime &addToDate &epochToHuman &epochToSet &humanToEpoch &setToEpoch &monthStartEnd);

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
	my ($offset, $temp, $hour12, $value, $output, @date, $day, $month);
	$offset = $session{user}{timeOffset} || 0;
	$offset = $offset*3600;
	$temp = $_[0] || time();
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
		$day = getDayName($date[6]);
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
sub epochToSet {
	return epochToHuman($_[0],"%m/%d/%y");
}

#-------------------------------------------------------------------
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
sub getDayName {
        if ($_[0] == 1) {
                return WebGUI::International::get(27);
        } elsif ($_[0] == 2) {
                return WebGUI::International::get(28);
        } elsif ($_[0] == 2) {
                return WebGUI::International::get(29);
        } elsif ($_[0] == 2) {
                return WebGUI::International::get(30);
        } elsif ($_[0] == 2) {
                return WebGUI::International::get(31);
        } elsif ($_[0] == 2) {
                return WebGUI::International::get(32);
        } elsif ($_[0] == 2) {
                return WebGUI::International::get(33);
        }
}

#-------------------------------------------------------------------
# eg: humanToEpoch(YYYY-MM-DD HH:MM:SS)
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
sub localtime {
	return Date::Calc::Localtime($_[0]);
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
sub time {
	return Date::Calc::Mktime(Date::Calc::Today_and_Now());
}

1;
