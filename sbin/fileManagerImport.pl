#!/usr/bin/perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot, @nailable);

BEGIN { 
	$webguiRoot = "..";
	@nailable = qw(jpg jpeg png gif tif tiff bmp);
	unshift (@INC, $webguiRoot."/lib"); 
}


$| = 1;

use File::Path;
use File::stat;
use FileHandle;
use Getopt::Long;
use Image::Magick;
use POSIX;
use strict;
use WebGUI::Attachment;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;


my $configFile;
my $groupToView = 2;
my $help;
my $pathToFiles;
my $override;
my $quiet;
my $webUser = 'apache';
my $wobjectId;

GetOptions(
	'configFile=s'=>\$configFile,
	'groupToView=i'=>\$groupToView,
        'help'=>\$help,
	'override'=>$override,
	'pathToFiles=s'=>\$pathToFiles,
        'quiet'=>\$quiet,
	'webUser=s'=>\$webUser,
	'wobjectId=i'=>\$wobjectId
);


if ($help || $configFile eq "" || $pathToFiles eq "" || $wobjectId eq ""){
        print <<STOP;


Usage: perl $0 --pathToFiles=<pathToImportFiles> --configfile=<webguiConfig> --wobjectId=<fileManagerWobjectId>

        --configFile	WebGUI config file.

        --pathToFiles	Folder containing files to import.

	--wobjectId	The wobject ID of the file manager you
			wish to import these files to.


Options:

	--groupToView	The group ID of the group that should
			have the privileges to view these
			files. Defaults to '2'.

        --help		Display this help message and exit.

	--override	This utility is designed to be run as
			a privileged user on Linux style systems.
			If you wish to run this utility without
			being the super user, then use this flag,
			but note that it may not work as
			intended.

	--quiet		Disable output unless there's an error.

	--webUser	The user that your web server runs as.
			Defaults to 'apache'.

STOP
	exit;
}


if (!($^O =~ /^Win/i) && $> != 0 && !$override) {
        print "You must be the super user to use this utility.\n";
        exit;
}


print "Starting..." unless ($quiet);
WebGUI::Session::open($webguiRoot,$ARGV[1]);
WebGUI::Session::refreshUserInfo(3);
print "OK\n" unless ($quiet);

addFiles(buildFileList($pathToFiles));
setPrivileges();

print "Cleaning up..." unless ($quiet);
WebGUI::Session::end($session{var}{sessionId});
WebGUI::Session::close();
print "OK\n" unless ($quiet);

#-----------------------------------------
# addFiles(dbHandler, filelistHashRef, webguiSettingsHashRef, pathToCopyFrom)
#-----------------------------------------
sub addFiles {
  	my ($exists, @files, $filename, $ext, $id, $i, $file1, $file2, $file3, $seq);
  	print "Adding files...\n" unless ($quiet);
    	($exists) = WebGUI::SQL->quickArray("select count(*) from FileManager where wobjectId='$wobjectId'");
    	if ($exists) {
		my $w = WebGUI::Wobject::FileManager->new({wobjectId=>$wobjectId,namespace=>"FileManager"});
      		foreach $filename (keys %{$_[0]}) {
        		print "Processing $filename.\n" unless ($quiet);
        		$i = 0;
        		@files = [];
        		print "\tAdding $filename to the database.\n" unless ($quiet);
			my $fileId = $w->setCollateral("FileManager_file","FileManager_fileId",{
				FileManager_fileId=>"new",
				groupToView=>$groupToView,
				dateUploaded=>time(),
				fileTitle=>$filename
				});
			my $attachment = WebGUI::Attachment->new("new",$w->get("wobjectId"),$fileId);
        		foreach $ext (keys %{${$_[0]}{$filename}}) {
          			print "\tCopying ".${$_[0]}{$filename}{$ext}.".\n" unless ($quiet);
				$attachment->saveFromFilesystem($pathToFiles.$session{os}{slash}.${$_[0]}{$filename}{$ext});
          			$files[$i] = ${$_[0]}{$filename}{$ext};
          			$i++;
	       		}
			my @files = sort {isIn(getType($b),@nailable) cmp isIn(getType($a),@nailable)} @files;
			$w->setCollateral("FileManager_file","FileManager_fileId",{
                                FileManager_fileId=>$fileId,
				downloadFile=>$files[0],
				alternateVersion1=>$files[1],
				alternateVersion2=>$files[2]
				});
		}
    	} else {
      		print "Warning: File Manager '".$wobjectId."' does not exist. Cannot import files.\n";
  	}
  	print "Finished adding.\n" unless ($quiet);
}

#-----------------------------------------
# setPrivileges()
#-----------------------------------------
sub setPrivileges {
  	print "Setting filesystem privileges.\n" unless ($quiet);
	if ($session{os}{type} = "Linuxish") {
		unless (system("chown -R ".$webUser." ".$session{config}{uploadsPath})) {
  			print "Privileges set.\n" unless ($quiet);
		} else {
			print "Could not set privileges.\n";
		}
	} else {
		print "Cannot set privileges on this platform.\n" unless ($quiet)
	}
}

#-----------------------------------------
# buildFileList(pathToImportFiles)
#-----------------------------------------
sub buildFileList {
        print "Building file list.\n" unless ($quiet);
        my (%filelist, @files, $file, $filename, $ext);
        if (opendir(FILES,$_[0])) {
                @files = readdir(FILES);
                foreach $file (@files) {
                        unless ($file eq "." || $file eq "..") {
                                $file =~ /(.*?)\.(.*?)$/;
                                $filename = $1;
                                $ext = $2;
                                $filelist{$filename}{$ext} = $file;
                                print "Found file $file.\n" unless ($quiet);
                        }
                }
                closedir(FILES);
                print "File list complete.\n" unless ($quiet);
                return \%filelist;
        } else {
                print "Error: Could not open folder.\n";
                exit;
        }
}


#-----------------------------------------
# getType(filename)
#-----------------------------------------
sub getType {
  	my ($extension);
  	$extension = $_[0];
  	$extension =~ s/.*\.(.*?)$/$1/;
  	return $extension;
}





