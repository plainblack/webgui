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

our @ISA = qw(Exporter);
our @EXPORT = qw(&epochToHuman &epochToSet &humanToEpoch &setToEpoch);
our %month = (
	1=>	"January",
	2=>	"February",
	3=>	"March",
	4=>	"April",
	5=>	"May",
	6=>	"June",
	7=>	"July",
	8=>	"August",
	9=>	"September",
	10=>	"October",
	11=>	"November",
	12=>	"December"
	);
our %weekday = (
	1=>	"Sunday",
	2=>	"Monday",
	3=>	"Tuesday",
	4=>	"Wednesday",
	5=>	"Thursday",
	6=>	"Friday",
	7=>	"Saturday"
	);

#-------------------------------------------------------------------
sub epochToHuman {
	my ($hour12, $value, $output, @date);
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
	$output =~ s/\%c/$month{$date[4]}/g;
  #---day stuff
	$value = sprintf("%02d",$date[3]);
	$output =~ s/\%d/$value/g;
	$output =~ s/\%D/$date[3]/g;
	$output =~ s/\%w/$weekday{$date[6]}/g;
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
