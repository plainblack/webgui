package WebGUI::DateTime;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use Time::Local;
use WebGUI::International;

our @ISA = qw(Exporter);
our @EXPORT = qw(&epochToHuman &epochToSet &humanToEpoch &setToEpoch);

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
sub epochToHuman {
	my ($hour12, $value, $output, @date, %weekday, %month);
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
	$hour12 = $date[2]+1;
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
sub setToEpoch {
 	my ($month, $day, $year) = split(/\//,$_[0]);
	return humanToEpoch($year.'-'.$month.'-'.$day.' 00:00:00');
}



1;
