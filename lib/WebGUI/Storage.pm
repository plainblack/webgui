package WebGUI::Storage;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use Archive::Tar;
use File::Copy qw(cp);
use FileHandle;
use File::Find;
use File::Path;
use POSIX;
use Storable qw(nstore retrieve);
use strict;
use warnings;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Storage

=head1 DESCRIPTION

This package provides a mechanism for storing and retrieving files that are not put into the database directly.

=head1 SYNOPSIS

 use WebGUI::Storage;
 $store = WebGUI::Storage->create($self->session);
 $store = WebGUI::Storage->createTemp($self->session);
 $store = WebGUI::Storage->get($self->session,$id);

 $filename = $store->addFileFromFilesystem($pathToFile);
 $filename = $store->addFileFromFormPost($formVarName);
 $filename = $store->addFileFromHashref($filename,$hashref);
 $filename = $store->addFileFromScalar($filename,$content);

 $arrayref = $store->getErrors;
 $integer = $store->getErrorCount;
 $hashref = $store->getFileContentsAsHashref($filename);
 $string = $store->getFileContentsAsScalar($filename);
 $string = $store->getFileExtension($filename);
 $url = $store->getFileIconUrl($filename);
 $arrayref = $store->getFiles;
 $string = $store->getFileSize($filename);
 $guid = $store->getId;
 $string = $store->getLastError;
 $string = $store->getPath($filename);
 $string = $store->getUrl($filename);

 $newstore = $store->copy;
 $newstore = $store->tar($filename);
 $newstore = $store->untar($filename);


 $store->delete;
 $store->deleteFile($filename);
 $store->rename($filename, $newFilename);
 $store->setPrivileges($userId, $groupIdView, $groupIdEdit);

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 _addError ( errorMessage )

Adds an error message to the object.

NOTE: This is a private method and should never be called except internally to this package.

=head3 errorMessage

The error message to add to the object.

=cut

sub _addError {
	my $self = shift;
	my $errorMessage = shift;
	push(@{$self->{_errors}},$errorMessage);
	$self->session->errorHandler->error($errorMessage);
}


#-------------------------------------------------------------------

=head2 _makePath ( )

Creates the filesystem folders for a storage location.

NOTE: This is a private method and should never be called except internally to this package.

=cut

sub _makePath {
	my $self = shift;
	my $node = $self->session->config->get("uploadsPath");
	foreach my $folder ($self->{_part1}, $self->{_part2}, $self->{_id}) {
		$node .= '/'.$folder;
		unless (-e $node) { # check to see if it already exists
			unless (mkdir($node)) { # check to see if there was an error during creation
				$self->_addError("Couldn't create storage location: $node : $!");
			}
		}
	}
}

#-------------------------------------------------------------------

=head2 addFileFromFilesystem( pathToFile )

Grabs a file from the server's file system and saves it to a storage location and returns a URL compliant filename.  If there are errors encountered during the add, then it will return undef instead.

=head3 pathToFile

Provide the local path to this file.

=cut

sub addFileFromFilesystem {
	my $self = shift;
	my $pathToFile = shift;
	my $filename;
        if (defined $pathToFile) {
                if ($pathToFile =~ /([^\/\\]+)$/) {
                        $filename = $1;
                } else {
                        $pathToFile = $filename;
                }
                if (isIn($self->getFileExtension, qw(pl perl sh cgi php asp))) {
                        $filename =~ s/\./\_/g;
                        $filename .= ".txt";
                }
                $filename = $self->session->url->makeCompliant($filename);
                if (-d $pathToFile) {
                        $self->session->errorHandler->error($pathToFile." is a directory, not a file.");
                } else {
                        my $source = FileHandle->new($pathToFile,"r");
                        if (defined $source) {
                                binmode($source);
                                my $dest = FileHandle->new(">".$self->getPath($filename));
                                if (defined $dest) {
                                        binmode($dest);
                                        cp($source,$dest) or $self->_addError("Couldn't copy $pathToFile to ".$self->getPath($filename).": $!");
                                        $dest->close;
                                } else {
                                        $self->_addError("Couldn't open file ".$self->getPath($filename)." for writing due to error: ".$!);
                                        $filename = undef;
                                }
                                $source->close;
                        } else {
                                $self->_addError("Couldn't open file ".$pathToFile." for reading due to error: ".$!);
                                $filename = undef;
                        }
                }
        } else {
                $filename = undef;
        }
        return $filename;
}


#-------------------------------------------------------------------

=head2 addFileFromFormPost ( formVariableName, attachmentLimit )

Grabs an attachment from a form POST and saves it to this storage location.

=head3 formVariableName

Provide the form variable name to which the file being uploaded is assigned. Note that if multiple files are uploaded with the same formVariableName then they'll all be stored in the storage location, but only the last filename will be returned. Use the getFiles() method on the storage location to get all the filenames stored.

=head3 attachmentLimit

Limit the number of files that will be uploaded.  If null, undef or 0, 99999 will be used as a default.

=cut

sub addFileFromFormPost {
	my $self = shift;
	my $formVariableName = shift;
	my $attachmentLimit = shift || 99999;
	return "" if ($self->session->http->getStatus() =~ /^413/);
	require Apache2::Request;
    require Apache2::Upload;
	my $filename;
	my $attachmentCount = 1;
	foreach my $upload ($self->session->request->upload($formVariableName)) {
		return $filename if $attachmentCount > $attachmentLimit;
		my $tempFilename = $upload->filename();
		next unless $tempFilename;
		next unless $upload->size > 0;
		next if ($upload->size > 1024 * $self->session->setting->get("maxAttachmentSize"));
		if ($tempFilename =~ /([^\/\\]+)$/) { $tempFilename = $1; }
		my $type = $self->getFileExtension($tempFilename);
		if (isIn($type, qw(pl perl sh cgi php asp))) { # make us safe from malicious uploads
			$tempFilename =~ s/\./\_/g;
			$tempFilename .= ".txt";
		}
		$filename = $self->session->url->makeCompliant($tempFilename);
		my $bytesread;
		my $file = FileHandle->new(">".$self->getPath($filename));
		$attachmentCount++;
		if (defined $file) {
			my $buffer;
			my $sourcefh = $upload->fh;
			binmode $file;
			while ($bytesread=read($sourcefh,$buffer,1024)) {
				print $file $buffer;
			}
			close($file);
		} else {
			$self->_addError("Couldn't open file ".$self->getPath($filename)." for writing due to error: ".$!);
			return undef;
		}
	}
	return $filename if $filename;
	return undef;
}


#-------------------------------------------------------------------

=head2 addFileFromHashref ( filename, hashref )

Stores a hash reference as a file and returns a URL compliant filename. Retrieve the data with getFileContentsAsHashref.

=head3 filename

The name of the file to create.

=head3 hashref

A hash reference containing the data you wish to persist to the filesystem.

=cut

sub addFileFromHashref {
	my $self = shift;
	my $filename = $self->session->url->makeCompliant(shift);
	my $hashref = shift;
        nstore $hashref, $self->getPath($filename) or $self->_addError("Couldn't create file ".$self->getPath($filename)." because ".$!);
	return $filename;
}

#-------------------------------------------------------------------

=head2 addFileFromScalar ( filename, content )

Adds a file to this storage location and returns a URL compliant filename.

=head3 filename

The filename to create.

=head3 content

The content to write to the file.

=cut

sub addFileFromScalar {
	my $self = shift;
	my $filename = $self->session->url->makeCompliant(shift);
	my $content = shift;
	if (open(my $FILE,">",$self->getPath($filename))) {
		print $FILE $content;
		close($FILE);
	} else {
        	$self->_addError("Couldn't create file ".$self->getPath($filename)." because ".$!);
	}
	return $filename;
}


#-------------------------------------------------------------------

=head2 copy ( [ storage, filelist ] )

Copies a storage location and it's contents. Returns a new storage location object. Note that this does not copy privileges or other special filesystem properties.

=head3 storage

Optionally pass in a storage object to copy the data to.

=head3 filelist

Optionally pass in the list of filenames to copy from the specified storage location

=cut

sub copy {
	my $self = shift;
	my $newStorage = shift || WebGUI::Storage->create($self->session);
	my $filelist = shift || $self->getFiles(1);
	foreach my $file (@{$filelist}) {	
        	my $source = FileHandle->new($self->getPath($file),"r");
        	if (defined $source) {
                	binmode($source);
                	my $dest = FileHandle->new(">".$newStorage->getPath($file));
                	if (defined $dest) {
                        	binmode($dest);
                        	cp($source,$dest) or $self->_addError("Couldn't copy file ".$self->getPath($file)." to ".$newStorage->getPath($file)." because ".$!);
                        	$dest->close;
                	}
                	$source->close;
        	}
	}
	return $newStorage;
}

#-------------------------------------------------------------------

=head2 create ( session )

Creates a new storage location on the file system.

=head3 session

A reference to the current session;

=cut

sub create {
	my $class = shift;
	my $session = shift;
	my $id = $session->id->generate();
	my $self = $class->get($session,$id);
	$self->_makePath;
	return $self;
}


#-------------------------------------------------------------------

=head2 createTemp ( session )

Creates a temporary storage location on the file system.

=head3 session

A reference to the current session.

=cut

sub createTemp {
	my $class = shift;
	my $session = shift;
	my $id = $session->id->generate();
	$id =~ m/^(.{2})/;
	my $self = {_session=>$session, _id => $id, _part1 => 'temp', _part2 => $1};
	bless $self, ref($class)||$class;
	$self->_makePath;
	return $self;
}

#-------------------------------------------------------------------

=head2 delete ( )

Deletes this storage location and its contents (if any) from the filesystem.

=cut

sub delete {
	my $self = shift;
	my $path = $self->getPath;
	if ($path) {
		rmtree($path) if ($path);
		foreach my $subDir ($self->{_part1}.'/'.$self->{_part2}, $self->{_part1}) {
			my $uDir = $self->session->config->get('uploadsPath') . '/' . $subDir;
			my $DH;
			opendir $DH, $uDir;
			if (defined $DH) {
				my @dirs = grep { !/^\.+$/ } readdir($DH);
				if (scalar @dirs == 0) {
					rmtree($uDir);
				}
				close $DH;
			} else {
				$self->session->errorHandler->warn("Unable to open $uDir for directory reading");
			}
		}
	}
	return;
}

#-------------------------------------------------------------------

=head2 deleteFile ( filename )

Deletes a file from it's storage location.

=head3 filename

The name of the file to delete.

=cut

sub deleteFile {
	my $self = shift;
	my $filename = shift;
        unlink($self->getPath($filename));
}


#-------------------------------------------------------------------

=head2 get ( session, id )

Returns a WebGUI::Storage object.

=head3 session

A reference to the current sesion.

=head3 id

The unique identifier for this file system storage location.

=cut

sub get {
	my $class = shift;
	my $session = shift;
	my $id = shift;
	return undef unless $id;
	my $self;
	$self = {_session=>$session, _id => $id, _errors => []};
	bless $self, ref($class)||$class;
	if (my ($part1, $part2) = $id =~ m/^(.{2})(.{2})/) {
		$self->{_part1} = $part1;
		$self->{_part2} = $part2;
		$self->_makePath unless (-e $self->getPath); # create the folder in case it got deleted somehow
	}
	else {
		$self->_addError("Illegal ID: $id");
	}
	return $self;
}

#-------------------------------------------------------------------

=head2 getErrorCount ( )

Returns the number of errors that have been generated on this object instance.

=cut

sub getErrorCount {
	my $self = shift;
	my $count = scalar(@{$self->{_errors}});
	return $count;
}


#-------------------------------------------------------------------

=head2 getErrors ( )

Returns an arrayref with all errors for this object

=cut

sub getErrors {
	my $self = shift;
	return $self->{_errors};
}


#-------------------------------------------------------------------

=head2 getFileContentsAsHashref ( filename )

Returns a hash reference from the file. Must be used in conjunction with a file that was saved using the addFileFromHashref method.

=head3 filename

The file to retrieve the data from.

=cut

sub getFileContentsAsHashref {
	my $self = shift;
	my $filename = shift;
        return retrieve($self->getPath($filename));
}


#-------------------------------------------------------------------

=head2 getFileContentsAsScalar ( filename )

Reads the contents of a file into a scalar variable and returns the scalar.

=head3 filename

The name of the file to read from.

=cut

sub getFileContentsAsScalar {
	my $self = shift;
	my $filename = shift;
	my $content;
	open (my $FILE,"<",$self->getPath($filename));
	while (<$FILE>) {
		$content .= $_;
	}
	close($FILE);
	return $content;
}


#-------------------------------------------------------------------

=head2 getFileExtension ( filename )

Returns the extension or type of this file.  If there's no extension, will either return
undef or the empty string, dependent on the absence or presence of a dot.

=head3 filename

The filename of the file you wish to find out the type for.

=cut

sub getFileExtension {
	my $self = shift;
	my $filename = shift;
	$filename = lc $filename;
        my ($extension) = $filename =~ /\.([^.]*)$/;
        return $extension;
}


#-------------------------------------------------------------------

=head2 getFileIconUrl ( filename )

Returns the icon associated with this type of file.

=head3 filename

The name of the file to get the icon for.

=cut

sub getFileIconUrl {
	my $self = shift;
	my $filename = shift;
	my $extension = $self->getFileExtension($filename);	
	my $path = $self->session->config->get("extrasPath").'/fileIcons/'.$extension.".gif";
	if (-e $path && $extension) {
		return $self->session->url->extras("fileIcons/".$extension.".gif");
	}
	return $self->session->url->extras("fileIcons/unknown.gif");
}


#-------------------------------------------------------------------

=head2 getFileSize ( filename )

Returns the size of this file.

=cut

sub getFileSize {
	my $self = shift;
	my $filename = shift;
        my (@attributes) = stat($self->getPath($filename));
        return $attributes[7];
}


#-------------------------------------------------------------------

=head2 getFiles ( showAll )

Returns an array reference of the files in this storage location.

=head3 showAll

Whether or not to return all files, including ones with initial periods.

=cut

sub getFiles {
	my $self = shift;
	my $showAll = shift;
	my @list;
	if (opendir (DIR,$self->getPath)) {
        	my @files = readdir(DIR);
        	closedir(DIR);
        	foreach my $file (@files) {
                	if ($showAll || $file !~ m/^\./) { # don't show files starting with a dot, unless we're supposed to show all files.
				push(@list,$file);
			}
                }
		return \@list;
        }
	return [];
}




#-------------------------------------------------------------------

=head2 getId ( )

Returns the unique identifier of this storage location.

=cut

sub getId {
	my $self = shift;
	return $self->{_id};
}

#-------------------------------------------------------------------

=head2 getLastError ( )

Returns the most recently generated error message.

=cut

sub getLastError {
	my $self = shift;
	my $count = $self->getErrorCount;
	return $self->{_errors}[$count-1];
}


#-------------------------------------------------------------------

=head2 getPath ( [ file ] )

Returns a full path to this storage location.

=head3 file

If specified, we'll return a path to the file rather than the storage location.

=cut

sub getPath {
	my $self = shift;	
	my $file = shift;
	unless ($self->session->config->get("uploadsPath") && $self->{_part1} && $self->{_part2} && $self->getId) {
		$self->_addError("storage object malformed");
		return undef;
	}
        my $path = $self->session->config->get("uploadsPath")
		.'/'.$self->{_part1}
		.'/'.$self->{_part2}
		.'/'.$self->getId;
        if (defined $file) {
                $path .= '/'.$file;
        }
        return $path;
}


#-------------------------------------------------------------------

=head2 getUrl ( [ file ] )

Returns a URL to this storage location.

=head3 file

If specified, we'll return a URL to the file rather than the storage location.

=cut

sub getUrl {
	my $self = shift;
	my $file = shift;
	my $url = $self->session->config->get("uploadsURL").'/'.$self->{_part1}.'/'.$self->{_part2}.'/'.$self->getId;
	if (defined $file) {
		$url .= '/'.$file;
	}
	return $url;
}

#-------------------------------------------------------------------

=head2 renameFile ( filename, newFilename )

Renames an file's filename.  Returns true if the rename succeeded and false
if it didn't.

=head3 filename

The name of the file you wish to rename.

=head3 newFilename

Define the new filename a specified file.

=cut

sub renameFile {
	my $self = shift;
	my $filename = shift;
	my $newFilename = shift;
        rename $self->getPath($filename), $self->getPath($newFilename);
}


#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
}


#-------------------------------------------------------------------

=head2 setPrivileges ( ownerUserId, groupIdView, groupIdEdit )

Set filesystem level privileges for this file. Used with the uploads access handler.

=head3 ownerUserId

The userId of the owner of this storage location.

=head3 groupIdView

The groupId that is allowed to view the files in this storage location.

=head3 groupIdEdit

The groupId that is allowed to edit the files in this storage location.

=cut

sub setPrivileges {
	my $self = shift;
	my $owner = shift;
	my $viewGroup = shift;
	my $editGroup = shift;
	$self->addFileFromScalar(".wgaccess",$owner."\n".$viewGroup."\n".$editGroup);
}



#-------------------------------------------------------------------

=head2 tar ( filename [, storage ] )

Archives this storage location into a tar file and then compresses it with a zlib algorithm. It then returns a new WebGUI::Storage object for the archive.

=head3 filename

The name of the tar file to be created. Should ideally end with ".tar.gz".

=head3 storage

Pass in a storage location object to create the tar file in, instead of having a temporary one be created. Note that it cannot be the same location that's being tarred.

=cut

sub tar {
	my $self = shift;
	my $filename = shift;
	my $temp = shift || WebGUI::Storage->createTemp($self->session);
	chdir $self->getPath;
	my @files = ();
	find(sub { push(@files, $File::Find::name)}, ".");
	if ($Archive::Tar::VERSION eq '0.072') {
		my $tar = Archive::Tar->new();
		$tar->add_files(@files);
		$tar->write($temp->getPath($filename),1);
		
	} else {
		Archive::Tar->create_archive($temp->getPath($filename),1,@files);
	}
	return $temp;
}

#-------------------------------------------------------------------

=head2 untar ( filename [, storage ] )

Unarchives a file into a new storage location. Returns the new WebGUI::Storage object.

=head3 filename

The name of the tar file to be untarred.

=head3 storage

Pass in a storage location object to extract the contents to, instead of having a temporary one be created.

=cut

sub untar {
        my $self = shift;
	my $filename = shift;
	my $temp = shift || WebGUI::Storage->createTemp($self->session);
        chdir $temp->getPath;
	Archive::Tar->extract_archive($self->getPath($filename),1);
	$self->_addError(Archive::Tar->error) if (Archive::Tar->error);
	return $temp;
}


1;
