package WebGUI::Attachment;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use File::Copy cp;
use File::Path;
use FileHandle;
use POSIX;
use strict;
use WebGUI::Session;
use WebGUI::Utility;

#-------------------------------------------------------------------
# eg: copy(filename,oldWidgetId,newWidgetId,oldSubId,newSubId);
sub copy {
	my ($a, $b, $newFile, $oldFile);
	if ($_[0] ne "") {
		$oldFile = $session{setting}{attachmentDirectoryLocal}.'/'.$_[1];
		if ($_[3] ne "") {
			$oldFile .= '/'.$_[3]
		}
		$oldFile .= '/'.$_[0];
        	$newFile = $session{setting}{attachmentDirectoryLocal}.'/'.$_[2];
        	if ($_[4] ne "") {
                	$newFile .= '/'.$_[4]
        	}	
		mkdir ($newFile,0755);
        	$newFile .= '/'.$_[0];
        	$a = FileHandle->new($oldFile,"r");
		$b = FileHandle->new(">".$newFile);
		binmode($a); 
		binmode($b); 
        	cp($a,$b);
		$a->close;
		$b->close;
	}
}

#-------------------------------------------------------------------
sub purgeWidget {
	my ($dir);
	$dir = $session{setting}{attachmentDirectoryLocal}.'/'.$_[0];
	rmtree($dir);
}

#-------------------------------------------------------------------
# eg: save(formVarName,widgetId,optionallySubmissionId);
sub save {
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
		if (defined $file) {
			binmode $file;
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


1;


