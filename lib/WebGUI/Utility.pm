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
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(Exporter);
our @EXPORT = qw(&randint &getNextId &saveAttachment &round &urlizeTitle &quote);

#-------------------------------------------------------------------
sub getNextId {
	my ($id);
	($id) = WebGUI::SQL->quickArray("select nextValue from incrementer where incrementerId='$_[0]'",$session{dbh});
	WebGUI::SQL->write("update incrementer set nextValue=nextValue+1 where incrementerId='$_[0]'",$session{dbh});
        return $id;
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
	#$filename = $session{form}{$_[0]};
	#$filename = $session{cgi}->param($_[0]);
	if (defined $filename) {
		$urlizedFilename = urlizeTitle($filename);
		$path = $session{setting}{attachmentDirectoryLocal}."/".$_[1]."/";
		mkdir ($path,0755);
		if ($_[2] ne "") {
			$path = $path.$_[2].'/';
			mkdir ($path,0755);
		}
		$file = FileHandle->new(">".$path.$urlizedFilename);
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
sub urlizeTitle {
	my ($title);
        $title = lc($_[0]);
        $title =~ s/ /_/g;
        $title =~ s/[^a-z0-9\-\.\_]//g;
        return $title;
}


1;
