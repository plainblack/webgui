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

our @ISA = qw(Exporter);
our @EXPORT = qw(&sortHashDescending &sortHash &paginate &appendToUrl &randint &round &urlize);

#-------------------------------------------------------------------
sub appendToUrl {
	my ($url);
	$url = $_[0];
	if ($url =~ /\?/) {
		$url .= '&'.$_[1];
	} else {
		$url .= '?'.$_[1];
	}
	return $url;
}

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
	$prevNextBar = '<div class="pagination">';
	if ($pn > 0) {
		$prevNextBar .= '<a href="'.appendToUrl($url,('pn='.($pn-1))).'">&laquo;'.WebGUI::International::get(91).'</a>';
	} else {
		$prevNextBar .= '&laquo;'.WebGUI::International::get(91);
	}
	$prevNextBar .= ' &middot; ';
	if (($pn+1) < (($#row+1)/$itemsPerPage)) {
		$prevNextBar .= '<a href="'.appendToUrl($url,('pn='.($pn+1))).'">'.WebGUI::International::get(92).'&raquo;</a>';
	} else {
		$prevNextBar .= WebGUI::International::get(92).'&raquo;';
	}
	$prevNextBar .= '</div>';
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

#-------------------------------------------------------------------
sub urlize {
	my ($title);
        $title = lc($_[0]);
        $title =~ s/ /_/g;
        $title =~ s/[^a-z0-9\-\.\_]//g;
        return $title;
}


1;
