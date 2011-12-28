#!/usr/bin/env perl

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use File::Path;
use File::stat;
use FileHandle;
use Getopt::Long;
use POSIX;
use Pod::Usage;
use WebGUI::Paths -inc;
use WebGUI::Asset::File;
use WebGUI::Asset::File::Image;
use WebGUI::Session;
use WebGUI::Storage;

$| = 1;

my @nailable = qw(jpg jpeg png gif);

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

pod2usage( verbose => 2 ) if $help;
pod2usage( exitval => 4)
  if ($configFile eq "" || $pathToFiles eq "" || $parentAssetId eq "");

my $slash = ($^O =~ /^Win/i) ? "\\" : "/";

if (!($^O =~ /^Win/i) && $> != 0 && !$override) {
	print "You must be the super user to use this utility.\n";
	exit 1;
}


my %ListAssetExists;
my %filelisthash;

print "Starting..." unless ($quiet);
my $session = WebGUI::Session->open($configFile);
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
		if (lc($file->{ext}) ~~ @nailable) {
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
	
    if ($^O ne 'MSWin32') {
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

                my $filename = $session->url->urlize($file);
				push(@filelist, {
					ext=>$ext, 
					filename=>$filename, 
					fullPathFile => $fullpathfile,
				});

				$filelisthash{$filename} = $fullpathfile;
				print "Found file $file as $filename.\n" unless ($quiet);
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

__END__

=head1 NAME

fileImport - Import files into WebGUI's Asset Manager.

=head1 SYNOPSIS

 fileImport --configFile config.conf --pathToFiles path
            --parentAssetID id
            [--groupToEdit group]
            [--groupToView group]
            [--owner id]
            [--findByExt ext1,ext2,...]
            [--ignoreExtInName]
            [--webUser username]
            [--recursive]
            [--overwrite]
            [--override]
            [--quiet]

 fileImport --help

=head1 DESCRIPTION

This WebGUI utility script imports files into WebGUI's Asset Manager
attached to a specified parent Asset, helping bulk uploads of content.

This utility is designed to be run as a superuser on Linux systems,
since it needs to be able to put files into WebGUI's data directories
and change ownership of files. If you want to run this utility without
superuser privileges, use the B<--override> option described below.

=over

=item B<--configFile config.conf>

The WebGUI config file to use. Only the file name needs to be specified,
since it will be looked up inside WebGUI's configuration directory.
This parameter is required.

=item B<--pathToFiles path>

Path to a folder containing the files to import. This parameter is required.

=item B<--parentAssetId id>

Attach the imported files to the Asset B<id> in WebGUI's Asset Manager.
This parameter is required.

=item B<--groupToEdit id>

Make members of WebGUI's group identified by B<id> be able to edit
the uploaded files. If left unspecified, it defaults to Group ID 4,
(Content Managers).

=item B<--groupToView id>

Make members of WebGUI's group identified by B<id> be able to view
the uploaded files. If left unspecified, it defaults to Group ID 7,
(Everybody).

=item B<--owner id>

Make WebGUI's user identified by B<id> own the uploaded files. If
left unspecified, it defaults to User ID 3 (Admin).

=item B<--webUser username>

The system user that your web server runs as. If left unspecified
it will default to B<www-data>.

=item B<--override>

This flag will allow you to run this utility without being the super user,
but note that it may not work as intended.

=item B<--skipOlderThan interval>

Skip files older than B<interval> seconds. If left unspecified, it
will default to skip no files.

=item B<--findByExt patterns>

Import only those files with matching file extensions. B<patterns>
is a list of comma-separated extensions to match. If left unspecified,
it will default to import all files.

=item B<--recursive>

Import files recursively. If left unspecified, only files in the
folder will be imported, without following subfolders.

=item B<--overwrite>

Overwrite any matching file URL with the new file rather than
creating a new Asset for the file. Instantiate the existing asset
and replace the file.

=item B<--ignoreExtInName>

Do not include the filename extension in the Title and menuTitle
database fields.

=item B<--quiet>

Disable all output unless there's an error.

=item B<--help>

Shows this documentation, then exits.

=back

=head1 EXIT VALUES

The following exit values are returned upon completion:

  0  Successful execution.
  1  Stop the script if not super user.
  2  A folder can't be opened for reading.
  3  Two files had the same name and were selected to be imported
     during recursive mode.
  4  Missing required parameter.
  5  Specified parent AssetId does not exist.

=head1 AUTHOR

Copyright 2001-2012 Plain Black Corporation.

=cut
