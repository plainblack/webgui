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
	$webUser = "apache";
	@nailable = qw(jpg jpeg png gif);
	unshift (@INC, $webguiRoot."/lib"); 
}

#-----------------------------------------
# NO NEED TO MODIFY BELOW THIS LINE


$| = 1;

use strict;
use WebGUI::Attachment;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

if ($ARGV[0] ne "" && $ARGV[1] ne ""){
  	print "Starting...\n";
  	print "Establishing WebGUI Session...\n";
	WebGUI::Session::open($webguiRoot,$ARGV[1]);
        WebGUI::Session::refreshUserInfo(3);
  	addFiles(buildFileList($ARGV[0]), $ARGV[0],($ARGV[2]||$session{setting}{thumbnailSize}));
  	setPrivileges() unless ($session{os}{type} eq "Windowsish");
  	print "Cleaning up...\n";
	WebGUI::Session::close();
  	print "Finished!\n";
} else {
  	print "Usage: $0 <pathToNewImages> <webguiConfigFile> [<thumbnailSize>]\n";
}

#-----------------------------------------
# addFiles(dbHandler, filelistHashRef, webguiSettingsHashRef, pathToCopyFrom)
#-----------------------------------------
sub addFiles {
  	my ($filename, $ext, $id, $a, $b);
	my ($filelist, $pathToImages, $thumbnailSize) = @_;
  	print "Adding files...\n";
      	foreach $filename (keys %{$filelist}) {
       		print "Processing $filename.\n";
       		foreach $ext (keys %{${$filelist}{$filename}}) {
       			$id = getNextId("collateralId");
       			print "Copying ".${$filelist}{$filename}{$ext}.".\n";
			my $file = WebGUI::Attachment->new(${$filelist}{$filename}{$ext},"images",$id);
			$file->saveFromFilesystem($pathToImages."/".${$filelist}{$filename}{$ext},$thumbnailSize);
       			print "Adding $filename to the database.\n";
			WebGUI::SQL->write("insert into collateral (collateralId,name,filename,userId,username,
				dateUploaded,collateralType,thumbnailsize) values
				($id,".quote($filename).",".quote($filename.".".$ext).",3,'Imported',".time().",
				'image',$thumbnailSize)");
	       	}
	}
  	print "Finished adding.\n";
}

#-----------------------------------------
# setPrivileges(webguiSettingsHashRef)
#-----------------------------------------
sub setPrivileges {
  	print "Setting filesystem privileges.\n";
  	system("chown -R ".$webUser." ".$session{config}{uploadsPath});
  	print "Privileges set.\n";
}

#-----------------------------------------
# buildFileList(pathToImportFiles)
#-----------------------------------------
sub buildFileList {
  	print "Building file list.\n";
  	my (%filelist, @files, $file, $filename, $ext);
        if (opendir(FILES,$_[0])) {
        	@files = readdir(FILES);
          	foreach $file (@files) {
            		unless ($file eq "." || $file eq "..") {
              			$file =~ /(.*?)\.(.*?)$/;
              			$filename = $1;
              			$ext = $2;
				if (isIn($ext, @nailable)) {
              				$filelist{$filename}{$ext} = $file; 
              				print "Found file $file.\n";
				}
            		}
          	}
        	closedir(FILES);
    		print "File list complete.\n";
    		return \%filelist;
  	} else {	
    		print "Error: Could not open folder.\n";
    		exit;
  	}
}



