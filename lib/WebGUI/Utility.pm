package WebGUI::Utility;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use Exporter;
use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&sortByColumn &sortHashDescending &sortHash 
	&paginate &randint &round);

#-------------------------------------------------------------------
sub paginate {
	my ($pn, $i, $dataRows, $prevNextBar, $itemsPerPage, @row, $url);
	$itemsPerPage = $_[0];
	$url = $_[1];
	@row = @{$_[2]};
	if ($session{form}{pn} < 1) {
		$pn = 0;
	} else {
		$pn = $session{form}{pn};
	}
	for ($i=($itemsPerPage*$pn); $i<($itemsPerPage*($pn+1));$i++) {
		$dataRows .= $row[$i];
	}
	if ($#row+1 > $itemsPerPage) {
		$prevNextBar = '<div class="pagination">';
		if ($pn > 0) {
			$prevNextBar .= '<a href="'.WebGUI::URL::append($url,('pn='.($pn-1))).'">&laquo;'.
				WebGUI::International::get(91).'</a>';
		} else {
			$prevNextBar .= '&laquo;'.WebGUI::International::get(91);
		}
		$prevNextBar .= ' &middot; ';
		if (($pn+1) < (($#row+1)/$itemsPerPage)) {
			$prevNextBar .= '<a href="'.WebGUI::URL::append($url,('pn='.($pn+1))).'">'.
				WebGUI::International::get(92).'&raquo;</a>';
		} else {
			$prevNextBar .= WebGUI::International::get(92).'&raquo;';
		}
		$prevNextBar .= '</div>';
	}
	return ($dataRows, $prevNextBar);
}

#-------------------------------------------------------------------
sub randint {
	my ($low, $high) = @_;
	$low = 0 unless defined $low;
	$high = 1 unless defined $high;
	($low, $high) = ($high,$low) if $low > $high;
	return $low + int( rand( $high - $low + 1 ) );
}

#-------------------------------------------------------------------
sub round {
        return sprintf("%.0f", $_[0]);
}

#-------------------------------------------------------------------
# example: sortByColumn(columnToSort,columnLabel);
sub sortByColumn {
        my ($output);
	$output = '<a href="'.WebGUI::URL::page('sort='.$_[0].'&sortDirection=');
	if ($session{form}{sortDirection} eq "asc") {
		$output .= "desc";
	} else {
		$output .= "asc";
	}
	$output .= '">'.$_[1].'</a>';
        if ($session{form}{sort} eq $_[0]) {
		if ($session{form}{sortDirection} eq "desc") {
                	$output .= ' <img src="'.$session{setting}{lib}.'/desc.gif">';
		} else {
                	$output .= ' <img src="'.$session{setting}{lib}.'/asc.gif">';
		}
        }
        return $output;
}

#-------------------------------------------------------------------
sub sortHash {
	my (%hash, %reversedHash, %newHash, $key);
	tie %hash, "Tie::IxHash";
	tie %reversedHash, "Tie::IxHash";
	tie %newHash, "Tie::IxHash";
        %hash = @_;
	%reversedHash = reverse %hash;
	foreach $key (sort {$b cmp $a} keys %reversedHash) {
        	$newHash{$key}=$reversedHash{$key};
	}
	%reversedHash = reverse %newHash;
        return %reversedHash;
}

#-------------------------------------------------------------------
sub sortHashDescending {
        my (%hash, %reversedHash, %newHash, $key);
        tie %hash, "Tie::IxHash";
        tie %reversedHash, "Tie::IxHash";
        tie %newHash, "Tie::IxHash";
        %hash = @_;
        %reversedHash = reverse %hash;
        foreach $key (sort {$a cmp $b} keys %reversedHash) {
                $newHash{$key}=$reversedHash{$key};
        }
        %reversedHash = reverse %newHash;
        return %reversedHash;
}



1;
