#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Utility;

# TB : Get the time as soon as possible. Use $now as global variable.
# $now is used for skipOlderThan feature.
my $now = time;

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
my $skipOlderThan = 999999999;
my $findByExt = "";
my $recursive = '';
my $overwrite = '';
my $ignoreExtInName = '';

GetOptions(
	'configFile=s'     => \$configFile,
	'owner=s'          => \$owner,
	'groupToView=s'    => \$groupToView,
	'groupToEdit=s'    => \$groupToEdit,
	'help'             => \$help,
	'override'         => \$override,
	'pathToFiles=s'    => \$pathToFiles,
	'quiet'            => \$quiet,
	'webUser=s'        => \$webUser,
	'parentAssetId=s'  => \$parentAssetId,
	'skipOlderThan=i'  => \$skipOlderThan,
	'findByExt=s'      => \$findByExt,
	'recursive'        => \$recursive,
	'overwrite'        => \$overwrite,
	'ignoreExtInName'  => \$ignoreExtInName
);


if ($configFile eq "" || $pathToFiles eq "" || $parentAssetId eq "") {
	printHelp();
	exit 4;
};

if ($help) {
	printHelp();
	exit 1;
}

sub printHelp {
	print <<STOP;


Usage: perl $0 --pathToFiles=<pathToImportFiles> --configfile=<webguiConfig> --parentAssetId=<assetId>

	--configFile		WebGUI config file.

	--pathToFiles		Folder containing files to import.

	--parentAssetId		The asset ID of the asset you wish
				to attach these files to.


Options:

	--groupToEdit		The group ID of the group that should
				have the privileges to edit these
				files. Defaults to '4' (Content Managers).

	--groupToView		The group ID of the group that should
				have the privileges to view these
				files. Defaults to '7' (Everybody).

	--help			Display this help message and exit.

	--owner			The user ID of the user that should
				have the privileges to modify these
				files. Defaults to '3' (Admin).

	--override		This utility is designed to be run as
				a privileged user on Linux style systems.
				If you wish to run this utility without
				being the super user, then use this flag,
				but note that it may not work as
				intended.

	--quiet			Disable output unless there's an error.

	--webUser		The user that your web server runs as.
				Defaults to 'apache'.

	--skipOlderThan		An interval defined in second to skip file older than.
				Defaults "nothing skip".

	--findByExt		Import only files files with an extension matching 
				one of the exensions.
				Defaults "import all files".

	--recursive		Import the files recursivelly from the folder --pathToFiles
				Defaults "don't run recursivelly"

	--overwrite		Overwrite any matching file URL with the new file rather
				than creating a new Asset for the file.
				Instanciate the existing asset and replace the file.

	--ignoreExtInName	Title and menuTitle database fields should not contain the
				extension of the filename.


EXIT STATUS

  The following exit values are returned:

  0
	Successful execution.

  1
	For Windows User, stop the script if not super user.

  2
	A folder can't be open for reading.

  3
	In recursive mode, if two files has the same name and are selected to be imported. Return this error.

  4
	Error during invocation of the command.

  5
	The parent Asset Id doesn't exists.



STOP
}

my $slash = ($^O =~ /^Win/i) ? "\\" : "/";

if (!($^O =~ /^Win/i) && $> != 0 && !$override) {
	print "You must be the super user to use this utility.\n";
	exit 1;
}


my %ListAssetExists;
my %filelisthash;

print "Starting..." unless ($quiet);
my $session = WebGUI::Session->open($webguiRoot,$configFile);
$session->user({userId=>3});
print "OK\n" unless ($quiet);

my $parent = WebGUI::Asset::File->newByDynamicClass($session, $parentAssetId);
unless (defined $parent) {
	print "Warning: Parent asset '".$parentAssetId."' does not exist. Cannot import files.\n";
	exit 5;
}
print "End of the childs detection\n" unless ($quiet);

# TB : wrap buildFileList in buildFileListWrap function for recursive search.
addFiles(buildFileListWrap($pathToFiles));

print "Committing version tag..." unless ($quiet);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->commit;
print "Done.\n" unless ($quiet);

print "Cleaning up..." unless ($quiet);
$session->var->end();
$session->close();

print "OK\n" unless ($quiet);
exit 0;

#-----------------------------------------
# addFiles(dbHandler, filelistHashRef, webguiSettingsHashRef, pathToCopyFrom)
#-----------------------------------------
sub addFiles {
	my ($class, $templateId, $url, $newAsset);
	my $filelist = shift;

	print "Adding files...\n" unless ($quiet);
	foreach my $file (@{$filelist}) {
		print "\tAdding ".$file->{fullPathFile}." to the database.\n" unless ($quiet);	

		# Figure out whether the file is an image or not by its extension.
		if (isIn(lc($file->{ext}),@nailable)) {
			$class = 'WebGUI::Asset::File::Image';
			$templateId = 'PBtmpl0000000000000088';
		}
		else {
			$class = 'WebGUI::Asset::File';
			$templateId = 'PBtmpl0000000000000024';
		}

		$url = $parent->getUrl.'/'.$file->{filename};
		$url =~ s{^/}{};

		# Create a new storage location and add the file to it.
		my $storage = WebGUI::Storage->create($session);
		my $filename = $storage->addFileFromFilesystem($file->{fullPathFile});

		# TB : possibly remove the extension if the ignoreExtInName feature enabled.
		my $filenameTitle = $filename;
		$filenameTitle =~ s/\.$file->{ext}// if ($ignoreExtInName);

		# Set up the properties of the file to be added.
		my $assetProperties = {
			className    => $class,
			title        => $filenameTitle,
			menuTitle    => $filenameTitle,
			filename     => $filename,
			storageId    => $storage->getId,
			isHidden     => 1,
			url          => $url,
			groupIdView  => $groupToView,
			groupIdEdit  => $groupToEdit,
			templateId   => $templateId,
			endDate      => 32472169200,
			ownerUserId  => $owner,
		};

		if (WebGUI::Asset->urlExists($session, $url) && $overwrite) {
			print "\t\tAsset exists already. Replace the file.\n" unless ($quiet);

			# Add a new revision.
			my $originalAsset = WebGUI::Asset->newByUrl($session, $url);
			$newAsset = $originalAsset->addRevision($assetProperties);
		}
		else {
			print "\t\tCreate the new asset.\n" unless ($quiet);
			
			# Add a new asset.
			$newAsset = $parent->addChild($assetProperties);
		}

		# Create thumbnail, scale and set size.
		if ($class eq 'WebGUI::Asset::File::Image') {
			# Generate thumbnail
			$newAsset->generateThumbnail($session->setting->get('thumbnailSize'));

			# Resize image to maxImageSize if necessary.
			my ($imgWidth, $imgHeight) = $newAsset->getStorageLocation->getSizeInPixels($filename);
			my $maxImageSize = $session->setting->get('maxImageSize');

			if (($imgWidth > $imgHeight) && ($imgWidth > $maxImageSize)) {
				$newAsset->getStorageLocation->resize($filename, $maxImageSize);
			}
			elsif ($imgHeight > $maxImageSize) {
				$newAsset->getStorageLocation->resize($filename, undef, $maxImageSize);
			}
		}
		$newAsset->setSize($storage->getFileSize($filename));
		
		setPrivilege($storage->getPath());
	}

	print "Finished adding.\n" unless ($quiet);
}

#-----------------------------------------
# setPrivilege(path)
#-----------------------------------------
sub setPrivilege {
	my $path = shift;
	print "\t\tSetting filesystem privilege. " unless ($quiet);
	
	if ($session->os->get("type") eq "Linuxish") {
		unless (system("chown -R ".$webUser." ". $path)) {
			print "Privileges set.\n" unless ($quiet);
		}
		else {
			print "Could not set privileges.\n";
		}
	}
	else {
		print "Cannot set privileges on this platform.\n" unless ($quiet)
	}
}

#-----------------------------------------
# buildFileListWrap(pathToImportFiles)
#-----------------------------------------
sub buildFileListWrap {
	my ($path) = @_;
	my (@filelist);

	print "Building file list." unless ($quiet);
	@filelist = buildFileList($now,$path);
	print "File list complete.\n" unless ($quiet);

	return \@filelist;
}

#-----------------------------------------
# buildFileList(time,pathToImportFiles)
#-----------------------------------------
sub buildFileList {
	my ($now,$path) = @_;
	my (@filelist, @files, $file, $filename, $ext);

	if (opendir(FILES,$path)) {
		@files = readdir(FILES);

		foreach $file (@files) {
			next if ($file eq "." || $file eq "..");
			my $fullpathfile = "$path$slash$file";
			if (-f "$fullpathfile") {
				$file =~ /(.*?)\.([^.]*?)$/;
				$filename = $1;
				$ext = $2;
				
				# TB : filter process : skip files due to options : skipOlderThan and findByExt
				next if (skipFilter($fullpathfile,$ext,$now));
				
				# TB : check is the filelist doesn't contains two times the same file (file with the same name)
				# due to recursive call, this can happen.
				if (exists $filelisthash{$file}) {
					print "Error: file \"$file\" exists at several locations. "
						. "Both \"$filelisthash{$file}\" and \"$fullpathfile\" contain it. "
						. "Exit at the first error of this type.\n" unless ($quiet);
				
					exit 2;
				}

				push(@filelist, {
					ext=>$ext, 
					filename=>$file, 
					fullPathFile => $fullpathfile,
				});

				$filelisthash{$file} = $fullpathfile;
				print "Found file $file.\n" unless ($quiet);
			}
			# TB : the recursive call
			push(@filelist, buildFileList($now,"$fullpathfile")) if ((-d "$fullpathfile") && $recursive);
		}

		closedir(FILES);
		return @filelist;
	}
	else {
		print "Error: Could not open folder $path.\n" unless ($quiet);
		exit 2;
	}
}

#-----------------------------------------
# skipFilter(file,ext,time)
#-----------------------------------------
sub skipFilter {
	my ($file,$ext,$now) = @_;

	# TB : stat in Windows has a strange behaviour relativelly to Unix
	# the output of stat si an array of array.
	# to be check on Unix if this work correctly.
	my @dev = stat "$file";

	# TB : option skipOlderThan
	if ($now - $dev[0][9] > $skipOlderThan) {
		print "Found file $file.\n\tBut older than $skipOlderThan. Skip it.\n" unless ($quiet);
		return 1;
	}

	# TB : option findByExt
	if (($findByExt ne "") && ($findByExt !~ /(^|,)$ext(,|$)/)) {
		print "Found file in $file.\n\tBut Extension doesn't match findByExt tag. Skip it.\n" unless ($quiet);
		return 1;
	}

	return 0;
}

