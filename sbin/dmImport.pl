#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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
	@nailable = qw(jpg jpeg png gif tif tiff bmp);
	unshift (@INC, $webguiRoot."/lib"); 
}

#-----------------------------------------
# NO NEED TO MODIFY BELOW THIS LINE



$| = 1;

use File::stat;
use Image::Magick;
use DBI;
use Mysql;
use Data::Config;
use WebGUI::SQL;
use File::Copy qw(cp);
use File::Path;
use FileHandle;
use POSIX;
use strict;

my ($filelist, $dbh, $settings, $config);

if ($ARGV[0] ne "" && $ARGV[1] ne ""){
  	print "Starting...\n";
  	$filelist = buildFileList($ARGV[0]);
	$config = getConfig($ARGV[1]);
  	$dbh = connectToDb($config);
  	$settings = getSettings($dbh,$ARGV[3]);
  	addFiles($dbh, $filelist, $settings, $ARGV[0], $ARGV[2], $config);
  	setPrivileges($config) unless ($^O =~ /Win/i);
  	print "Cleaning up...\n";
  	$dbh->disconnect;
  	print "Finished!\n";
} else {
  	print "Usage: $0 <pathToFiles> <webguiConfigFile> <wobjectId> [<thumbnailSize>]\n";
}

#-----------------------------------------
# addFiles(dbHandler, filelistHashRef, webguiSettingsHashRef, pathToCopyFrom)
#-----------------------------------------
sub addFiles {
  	my ($exists, @files, $filename, $ext, $id, $i, $file1, $file2, $file3, $seq);
  	print "Adding files...\n";
    	($exists) = WebGUI::SQL->quickArray("select count(*) from DownloadManager where wobjectId='$_[4]'",$_[0]);
    	if ($exists) {
	       	mkdir($_[5]->{uploadsPath}."/".$_[4]);
      		foreach $filename (keys %{$_[1]}) {
        		print "Processing $filename.\n";
        		$id = getId($_[0]);
          		mkdir($_[5]->{uploadsPath}."/".$_[4]."/".$id);
        		($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from DownloadManager_file where wobjectId='$_[4]'",$_[0]);
        		$i = 0;
        		@files = [];
        		foreach $ext (keys %{${$_[1]}{$filename}}) {
          			print "Copying ".${$_[1]}{$filename}{$ext}.".\n";
        			$a = FileHandle->new($_[3]."/".${$_[1]}{$filename}{$ext},"r");
          			binmode($a);
          			$b = FileHandle->new(">".$_[5]->{uploadsPath}."/".$_[4]."/".$id."/".${$_[1]}{$filename}{$ext});
	       			binmode($b);
          			cp($a,$b);
        			$a->close;
          			$b->close;
          			createThumbnail(${$_[1]}{$filename}{$ext},$_[5]->{uploadsPath}."/".$_[4]."/".$id,$_[2]->{thumbnailSize});
          			$files[$i] = ${$_[1]}{$filename}{$ext};
          			$i++;
	       		}
			my @files = sort {isIn(getType($b),@nailable) cmp isIn(getType($a),@nailable)} @files;
        		print "Adding $filename to the database.\n";
        		WebGUI::SQL->write("insert into DownloadManager_file (downloadId,wobjectId,fileTitle,downloadFile,
          			groupToView,dateUploaded,alternateVersion1,alternateVersion2,sequenceNumber) values (
          			$id,$_[4],'$filename','$files[0]',2,".time().",'$files[1]','$files[2]',".($seq+1).")",$_[0]);
		}
    	} else {
      		print "Warning: Download Manager '$_[4]' does not exist. Cannot import files.\n";
  	}
  	print "Finished adding.\n";
}

#-----------------------------------------
# setPrivileges(webguiSettingsHashRef)
#-----------------------------------------
sub setPrivileges {
  	print "Setting filesystem privileges.\n";
  	system("chown -R ".$webUser." ".$_[0]->{uploadsPath});
  	print "Privileges set.\n";
}

#-----------------------------------------
# getSettings(dbHandler)
#-----------------------------------------
sub getSettings {
  	my (%settings);
  	print "Retrieving settings from WebGUI.\n";
  	%settings = WebGUI::SQL->buildHash("select * from settings",$_[0]);
    	print "Settings retrieved.\n";
	$settings{thumbnailSize} = $_[1] if ($_[1] ne "");
    	return \%settings;
}

#-----------------------------------------
# getConfig(configFilename)
#-----------------------------------------
sub getConfig {
        my ($config, $error, %config);
	print "Getting site config.\n";
        $config = new Data::Config $webguiRoot.'/etc/'.$_[0] or $error=1;
	if ($error) {
		print "Couldn't open config file.\n";
		exit;
	} else {
		foreach ($config->param) {
                	$config{$_} = $config->param($_);
        	}
		print "Config retrieved.\n";
		return \%config;
	}
}

#-----------------------------------------
# connectToDb()
#-----------------------------------------
sub connectToDb {
  	my ($dbh, $error);
  	print "Connecting to database ".${$_[0]}{dsn}." as user ".${$_[0]}{dbuser}.".\n";
  	$dbh = DBI->connect(${$_[0]}{dsn}, ${$_[0]}{dbuser}, ${$_[0]}{dbpass}, { RaiseError => 0, AutoCommit => 1 }) or $error=1;
  	unless ($error) {
    		print "Connection established.\n";
    		return $dbh;
  	} else {
    		print "Error: Could not connect to the database.\n";
    		exit;
  	}
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
                                $filelist{$filename}{$ext} = $file;
                                print "Found file $file.\n";
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

#-----------------------------------------
# isIn(keyvalue, arrayOfValues)
#-----------------------------------------
sub isIn {
  	my ($i, @a, @b, @isect, %union, %isect, $e);
  	foreach $e (@_) {
    		if ($a[0] eq "") {
     	 		$a[0] = $e;
    		} else {
      			$b[$i] = $e;
      			$i++;
    		}
  	}
  	foreach $e (@a, @b) { $union{$e}++ && $isect{$e}++ }
  	@isect = keys %isect;
  	if (defined @isect) {
    		undef @isect;
    		return 1;
  	} else {
    		return 0;
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

#-----------------------------------------
# createThumbnail(filename,path,thumnailSize)
#-----------------------------------------
sub createThumbnail {
  	my ($image, $x, $y, $r, $n, $type);
  	$type = getType($_[0]);
  	if (isIn($type, @nailable) && !($_[0] =~ m/thumb-/)) {
    		print "Nailing: $_[1]/$_[0]\n";
    		$image = Image::Magick->new;
    		$image->Read($_[1].'/'.$_[0]);
    		($x, $y) = $image->Get('width','height');
    		$n = $_[2] || 50;
    		$r = $x>$y ? $x / $n : $y / $n;
    		$image->Scale(width=>($x/$r),height=>($y/$r)) if ($r > 0);
    		if (isIn($type, qw(tif tiff bmp))) {
      			$image->Write($_[1].'/thumb-'.$_[0].'.png');
    		} else {
      			$image->Write($_[1].'/thumb-'.$_[0]);
    		}
  	}
}

#-----------------------------------------
# getId(dbHandler)
#-----------------------------------------
sub getId {
  	my ($id);
  	($id) = WebGUI::SQL->quickArray("select nextValue from incrementer where incrementerId='downloadId'",$_[0]);
  	WebGUI::SQL->write("update incrementer set nextValue=nextValue+1 where incrementerId='downloadId'",$_[0]);
  	return $id;
}




