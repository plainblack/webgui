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

our ($webguiRoot, $webUser, @nailable);

BEGIN {
	$webguiRoot = "..";
	@nailable = qw(jpg jpeg png gif);
	unshift (@INC, $webguiRoot."/lib"); 
}


$| = 1;

use Getopt::Long;
use strict;
use WebGUI::Collateral;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;


my $configFile;
my $folderId;
my $help;
my $override;
my $pathToFiles;
my $quiet;
my $thumbnailSize;
my $webUser = 'apache';

GetOptions(
        'configFile=s'=>\$configFile,
	'folderId=i'=>\$folderId,
        'help'=>\$help,
        'override'=>$override,
        'pathToFiles=s'=>\$pathToFiles,
        'quiet'=>\$quiet,
        'thumbnailSize=i'=>\$thumbnailSize,
        'webUser=s'=>\$webUser
);


if ($help || $configFile eq "" || $pathToFiles eq ""){
        print <<STOP;


Usage: perl $0 --pathToFiles=<pathToImportFiles> --configfile=<webguiConfig>

        --configFile    WebGUI config file.

        --pathToFiles   Folder containing files to import.


Options:

	--folderId	The unique identifier for the collateral
			folder that the imported files should
			be organized under. Defaults to '0' (Root).

        --help          Display this help message and exit.

        --override      This utility is designed to be run as
                        a privileged user on Linux style systems.
                        If you wish to run this utility without
                        being the super user, then use this flag,
                        but note that it may not work as
                        intended.

        --quiet         Disable output unless there's an error.

	--thumbnailSize	The size (in pixels) of the thumbnails
			that will be generated if you import
			images. Defaults to the Thumbnail Size
			setting in the site's content settings.

        --webUser       The user that your web server runs as.
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

addFiles(buildFileList($pathToFiles), ($thumbnailSize||$session{setting}{thumbnailSize}));
setPrivileges();

print "Cleaning up..." unless ($quiet);
WebGUI::Session::end($session{var}{sessionId});
WebGUI::Session::close();
print "OK\n" unless ($quiet);


#-----------------------------------------
# addFiles(dbHandler, filelistHashRef, webguiSettingsHashRef, pathToCopyFrom)
#-----------------------------------------
sub addFiles {
  	my ($type, $parameters);
	my ($filelist, $thumbnailSize) = @_;
  	print "Adding files...\n" unless ($quiet);
      	foreach my $filename (keys %{$filelist}) {
       		print "Processing $filename.\n" unless ($quiet);
       		foreach my $ext (keys %{${$filelist}{$filename}}) {
			my $collateral = WebGUI::Collateral->new("new");
       			print "\tCopying ".${$filelist}{$filename}{$ext}.".\n" unless ($quiet);
			$collateral->saveFromFilesystem($pathToFiles.$session{os}{slash}.${$filelist}{$filename}{$ext},$thumbnailSize);
       			print "\tAdding $filename to the database.\n" unless ($quiet);
			if (isIn($ext, @nailable)) {
				$type = "image";
				$parameters = 'border="0"';
			} else {
				$type = "file";
				$parameters = '';
			}
			$collateral->set({
				collateralType=>$type,
				name=>$filelist->{$filename}{$ext},
				username=>"Imported",
				thumbnailSize=>$thumbnailSize,
				collateralFolderId=>$folderId,
				parameters=>$parameters
				});
	       	}
	}
  	print "Finished adding.\n";
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



