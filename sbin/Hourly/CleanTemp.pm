package Hourly::CleanTemp;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use File::Path;
use File::stat;
use strict;
use WebGUI::Session;

#-----------------------------------------
# _checkFileAge(filenameWithPath,ageToCheck)
# return: true/false
# checks age of file against specified age and reports true/false
sub _checkFileAge {
  	my ($filestat, $flag);
  	$filestat = stat($_[0]) or print "No $_[0]: $!";
  	if ((time()-$filestat->mtime) > $_[1]) {
    		$flag = 1;
  	} else {
    		$flag = 0;
  	}
  	return $flag;
}

#-----------------------------------------
# _recurseFileSystem(path, ageOfFilesToDelete)
# recurses the filesystem looking for files to delete
sub _recurseFileSystem {
  	my (@filelist, $file);
  	if (opendir(DIR,$_[0])) {
    		@filelist = readdir(DIR);
    		closedir(DIR);
    		foreach $file (@filelist) {
      			unless ($file eq "." || $file eq "..") {
        			_recurseFileSystem($_[0].$session{os}{slash}.$file,$_[1]);
        			if (_checkFileAge($_[0].$session{os}{slash}.$file,$_[1])) {
          				rmtree($_[0].$session{os}{slash}.$file);
        			}
      			}
    		}
  	}
}



#-----------------------------------------
sub process {
	my $pathToClean = $session{config}{uploadsPath}.$session{os}{slash}."temp";
	my $timeToDie = 86400;
	_recurseFileSystem($pathToClean,$timeToDie);
}

1;

