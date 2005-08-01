#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
	@nailable = qw(jpg jpeg png gif);
	unshift (@INC, $webguiRoot."/lib"); 
}


$| = 1;

use File::Path;
use File::stat;
use FileHandle;
use Getopt::Long;
use POSIX;
use strict;
use WebGUI::Asset::File;
use WebGUI::Asset::File::Image;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Utility;



my $configFile;
my $owner = 3;
my $groupToView = 7;
my $groupToEdit = 4;
my $help;
my $pathToFiles;
my $override;
my $quiet;
my $webUser = 'apache';
my $assetId;
my $parentAssetId;

GetOptions(
	'configFile=s'=>\$configFile,
	'owner=s'=>\$owner,
	'groupToView=s'=>\$groupToView,
	'groupToEdit=s'=>\$groupToEdit,
        'help'=>\$help,
	'override'=>$override,
	'pathToFiles=s'=>\$pathToFiles,
        'quiet'=>\$quiet,
	'webUser=s'=>\$webUser,
	'parentAssetId=s'=>\$parentAssetId
);


if ($help || $configFile eq "" || $pathToFiles eq "" || $parentAssetId eq ""){
        print <<STOP;


Usage: perl $0 --pathToFiles=<pathToImportFiles> --configfile=<webguiConfig> --parentAssetId=<assetId>

        --configFile	WebGUI config file.

        --pathToFiles	Folder containing files to import.

	--parentAssetId	The asset ID of the asset you wish
			to attach these files to.


Options:

	--groupToEdit	The group ID of the group that should
			have the privileges to edit these
			files. Defaults to '4' (Content Managers).

	--groupToView	The group ID of the group that should
			have the privileges to view these
			files. Defaults to '7' (Everybody).

        --help		Display this help message and exit.

	--owner		The user ID of the user that should
			have the privileges to modify these
			files. Defaults to '3' (Admin).

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
WebGUI::Session::open($webguiRoot,$configFile);
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
	my $filelist = shift;
  	print "Adding files...\n" unless ($quiet);
	my $parent = WebGUI::Asset::File->newByDynamicClass($parentAssetId);
    	if (defined $parent) {
		foreach my $file (@{$filelist}) {
        		print "\tAdding ".$file->{filename}." to the database.\n" unless ($quiet);
			my $class = 'WebGUI::Asset::File';
			my $templateId = 'PBtmpl0000000000000024';
			if (isIn($file->{ext},@nailable)) {
				$class = 'WebGUI::Asset::File::Image';
				$templateId = 'PBtmpl0000000000000088'
			}
			my $url = $parent->getUrl.'/'.$file->{filename};
			my $storage = WebGUI::Storage->create;
			my $filename = $storage->addFileFromFilesystem($pathToFiles.$session{os}{slash}.$file->{filename});
			my $newAsset = $parent->addChild({
				className=>$class,
				title=>$filename,
				menuTitle=>$filename,
				filename=>$filename,
				storageId=>$storage->getId,
				isHidden=>1,
				url=>$url,
				groupIdView=>$groupToView,
				groupIdEdit=>$groupToEdit,
				templateId=>$templateId,
				endDate=>32472169200,
				ownerUserId=>$owner
				});
			$newAsset->generateThumbnail if ($class eq 'WebGUI::Asset::File::Image');
			$newAsset->setSize($storage->getFileSize($filename));
		}
    	} else {
      		print "Warning: Parent asset '".$parentAssetId."' does not exist. Cannot import files.\n";
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
        my (@filelist, @files, $file, $filename, $ext);
        if (opendir(FILES,$_[0])) {
                @files = readdir(FILES);
                foreach $file (@files) {
                        unless ($file eq "." || $file eq "..") {
                                $file =~ /(.*?)\.(.*?)$/;
                                $filename = $1;
                                $ext = $2;
				push(@filelist,{ext=>$ext, filename=>$file});
                                print "Found file $file.\n" unless ($quiet);
                        }
                }
                closedir(FILES);
                print "File list complete.\n" unless ($quiet);
                return \@filelist;
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





