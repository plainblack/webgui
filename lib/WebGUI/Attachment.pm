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
use WebGUI::URL;
use WebGUI::Utility;

#-------------------------------------------------------------------
# eg: copy(filename,oldWidgetId,newWidgetId,oldSubId,newSubId);
sub copy {
	my ($a, $b, $newFile, $oldFile);
	if ($_[0] ne "") {
		$oldFile = $session{setting}{attachmentDirectoryLocal}.'/'.$_[1];
		if ($_[3] ne "") {
			$oldFile .= '/'.$_[3];
		}
		$oldFile .= '/'.$_[0];
        	$newFile = $session{setting}{attachmentDirectoryLocal}.'/'.$_[2];
		mkdir ($newFile,0755);
        	if ($_[4] ne "") {
                	$newFile .= '/'.$_[4];
			mkdir ($newFile,0755);
        	}	
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
sub deleteSubmission {
        my ($dir);
        $dir = $session{setting}{attachmentDirectoryLocal}.'/'.$_[0].'/'.$_[1];
        rmtree($dir);
}

#-------------------------------------------------------------------
sub getType {
	my ($extension, $icon, %type);
	$extension = lc($_[0]);
	$extension =~ s/.*?\.(.*?)$/$1/;
	if ($extension eq "doc" || $extension eq "dot" || $extension eq "wri") {
                $icon = $session{setting}{lib}."/fileIcons/doc.gif";
        } elsif ($extension eq "txt" || $extension eq "log" || $extension eq "config" || $extension eq "conf") {
                $icon = $session{setting}{lib}."/fileIcons/txt.gif";
	} elsif ($extension eq "xls" || $extension eq "xlt" || $extension eq "csv") {
                $icon = $session{setting}{lib}."/fileIcons/xls.gif";
        } elsif ($extension eq "html" || $extension eq "htm" || $extension eq "xml") {
                $icon = $session{setting}{lib}."/fileIcons/html.gif";
        } elsif ($extension eq "ram" || $extension eq "mpeg" || $extension eq "mpg" || 
		$extension eq "wav" || $extension eq "mp3" || $extension eq "avi") {
                $icon = $session{setting}{lib}."/fileIcons/html.gif";
        } elsif ($extension eq "html" || $extension eq "htm" || $extension eq "xml") {
                $icon = $session{setting}{lib}."/fileIcons/html.gif";
        } elsif ($extension eq "rar" || $extension eq "tgz" || $extension eq "tar.gz" || 
		$extension eq "tar" || $extension eq "gz" || $extension eq "Z") {
                $icon = $session{setting}{lib}."/fileIcons/rar.gif";
        } elsif ($extension eq "mdb") {
                $icon = $session{setting}{lib}."/fileIcons/mdb.gif";
        } elsif ($extension eq "ppt") {
                $icon = $session{setting}{lib}."/fileIcons/ppt.gif";
        } elsif ($extension eq "tiff" || $extension eq "tif" || $extension eq "bmp" || 
		$extension eq "psd" ||$extension eq "psp" || $extension eq "gif" || 
		$extension eq "jpg" || $extension eq "jpeg") {
                $icon = $session{setting}{lib}."/fileIcons/psp.gif";
        } elsif ($extension eq "zip") {
                $icon = $session{setting}{lib}."/fileIcons/zip.gif";
        } elsif ($extension eq "mov") {
                $icon = $session{setting}{lib}."/fileIcons/mov.gif";
        } elsif ($extension eq "pdf") {
                $icon = $session{setting}{lib}."/fileIcons/pdf.gif";
	} else {
		$icon = $session{setting}{lib}."/fileIcons/unknown.gif";
	}
	%type = (extension => $extension, icon => $icon);
	return %type;
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
	my (%type, $file, $filename, $bytesread, $buffer, $urlizedFilename, $path);
	$filename = $session{cgi}->upload($_[0]);
	if (defined $filename) {
		if ($filename =~ /([^\/\\]+)$/) {
     			$urlizedFilename = $1;
   		} else {
     			$urlizedFilename = $filename;
   		}
		%type = getType($urlizedFilename);
		if ($type{extension} eq "pl" || $type{extension} eq "perl" || $type{extension} eq "sh" || 
			$type{extension} eq "cgi" || $type{extension} eq "php" || $type{extension} eq "asp") {
			$urlizedFilename =~ s/\./\_/g;
			$urlizedFilename .= ".txt";
		}
		$urlizedFilename = WebGUI::URL::urlize($urlizedFilename);
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


