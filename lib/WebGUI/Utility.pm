package WebGUI::Utility;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use CGI;
use Exporter;
use FileHandle;
use strict;
use WebGUI::International;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&paginate &appendToUrl &randint &getNextId &saveAttachment &round &urlize &quote);

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
sub getNextId {
	my ($id);
	($id) = WebGUI::SQL->quickArray("select nextValue from incrementer where incrementerId='$_[0]'",$session{dbh});
	WebGUI::SQL->write("update incrementer set nextValue=nextValue+1 where incrementerId='$_[0]'",$session{dbh});
        return $id;
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
# This is here simply to make typing shorter, cuz I'm lazy.
sub quote {
	my $value = $_[0]; #had to add this here cuz Tie::CPHash variables cause problems otherwise.
	return $session{dbh}->quote($value);
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
# eg: saveAttachment(formVarName,widgetId,optionallySubmissionId);
sub saveAttachment {
	my ($file, $filename, $bytesread, $buffer, $urlizedFilename, $path);
	$filename = $session{cgi}->upload($_[0]);
	if (defined $filename) {
		if ($filename =~ /([^\/\\]+)$/) {
     			$urlizedFilename = $1;
   		} else {
     			$urlizedFilename = $filename;
   		}
		$urlizedFilename = urlize($urlizedFilename);
		$path = $session{setting}{attachmentDirectoryLocal}."/".$_[1]."/";
		mkdir ($path,0755);
		if ($_[2] ne "") {
			$path = $path.$_[2].'/';
			mkdir ($path,0755);
		}
		$file = FileHandle->new(">".$path.$urlizedFilename);
		binmode $file;
		if (defined $file) {
			while ($bytesread=read($filename,$buffer,1024)) {
        			print $file $buffer;
			}
			close($file);
		} else {
			return "";
		}
		return $urlizedFilename;
	} else {
		return "";
	}
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
