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

our @ISA = qw(Exporter);
our @EXPORT = qw(&localtime &time &addToTime &addToDate &epochToHuman &epochToSet &humanToEpoch &setToEpoch &monthStartEnd);

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
	my ($offset, $temp, $hour12, $value, $output, @date, %weekday, %month);
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
		%month = _getMonth();
		$output =~ s/\%c/$month{$date[1]}/g;
	}
  #---day stuff
	$value = sprintf("%02d",$date[2]);
	$output =~ s/\%d/$value/g;
	$output =~ s/\%D/$date[2]/g;
	if ($output =~ /\%w/) {
		%weekday = _getWeekday();
		$output =~ s/\%w/$weekday{$date[6]}/g;
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
sub setToEpoch {
	my @date = &localtime(time());
 	my ($month, $day, $year) = split(/\//,$_[0]);
	if (int($year) < 2038 && int($year) > 1900) {
		$year = int($year);
	} else {
		$year = $date[5];
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
	return Date::Calc::Date_to_Time($year,$month,$day,0,0,0);
}

#-------------------------------------------------------------------
sub time {
	return Date::Calc::Mktime(Date::Calc::Today_and_Now());
}

1;
