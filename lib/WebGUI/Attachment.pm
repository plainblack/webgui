package WebGUI::Attachment;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

my $hasImageMagick=1;

use File::Copy qw(cp);
use File::Path;
use FileHandle;

# test for ImageMagick. if it's not installed set $hasImageMagick to 0,
# if it is installed it will be set to 1
eval " use Image::Magick; "; $hasImageMagick=0 if $@;

use POSIX;
use Storable;
use strict;
use WebGUI::ErrorHandler;
use WebGUI::Node;
use WebGUI::Session;
use WebGUI::URL;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Attachment

=head1 DESCRIPTION

Package to manipulate WebGUI Attachments.

=head1 SYNOPSIS

 use WebGUI::Attachment;
 $attachment = WebGUI::Attachment->new("file.txt","100","20");

 $html = $attachment->box;
 $string = $attachment->getFilename;
 $url = $attachment->getIcon;
 $node = $attachment->getNode;
 $string = $attachment->getPath;
 $integer = $attachment->getSize;
 $url = $attachment->getThumbnail;
 $string = $attachment->getType;
 $url = $attachment->getURL;
 $boolean = $attachment->isImage;

 $attachment->copy("files","10");
 $attachment->createThumbnail;
 $attachment->delete;
 $attachment->deleteNode;
 $attachment->rename("thisfile.txt");
 $attachment->resizeImage(300);

 $filename = $attachment->save("formImage");
 $filename = $attachment->saveFromFilesystem($pathToFile);

 $filename = $attachment->saveFromHashref($hashRef);
 $hashRef = $attachment->getHashref;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 box ( )

Displays the attachment in WebGUI's standard "Attachment Box".

=cut

sub box {
        my ($output);
        $output = '<p><table cellpadding=3 cellspacing=0 border=1><tr><td class="tableHeader">'.
                '<a href="'.$_[0]->getURL.'"><img src="'.$session{config}{extrasURL}.
                '/attachment.gif" border=0 alt="'.
                $_[0]->getFilename.'"></a></td><td><a href="'.$_[0]->getURL.
                '"><img src="'.$_[0]->getIcon.
                '" align="middle" width="16" height="16" border="0" alt="'.$_[0]->getFilename
                .'">'.$_[0]->getFilename.'</a></td></tr></table>';
        return $output;
}

#-------------------------------------------------------------------

=head2 copy ( newNode [, newNodeSub ] )
 
Copies an attachment from one node to another.

=over

=item newNode

Define the node to copy the attachment to.

=item newNodeSub

If there is a subordinate element on this node define it here.

=back

=cut

sub copy {
	my ($a, $b, $newNode);
	$newNode = WebGUI::Node->new($_[1],$_[2]);
	$newNode->create;
       	$a = FileHandle->new($_[0]->getPath,"r");
	$b = FileHandle->new(">".$newNode->getPath.$session{os}{slash}.$_[0]->getFilename);
	if (defined $a) {
		binmode($a); 
		$b = FileHandle->new(">".$newNode->getPath.$session{os}{slash}.$_[0]->getFilename);
		if (defined $b) {
			binmode($b); 
       			cp($a,$b) or WebGUI::ErrorHandler::warn("Couldn't copy attachment: ".$newNode->getPath.$session{os}{slash}.$_[0]->getFilename." :".$!);
			$b->close;
		}
		$a->close;
	}
	if ($_[0]->isImage) {
        	$a = FileHandle->new($_[0]->getNode->getPath.$session{os}{slash}.'thumb-'.$_[0]->getFilename,"r");
        	$b = FileHandle->new(">".$newNode->getPath.$session{os}{slash}.'thumb-'.$_[0]->getFilename);
        	if (defined $a) {
                	binmode($a);
                	$b = FileHandle->new(">".$newNode->getPath.$session{os}{slash}.'thumb-'.$_[0]->getFilename);
                	if (defined $b) {
                        	binmode($b);
                        	cp($a,$b);
                        	$b->close;
                	}
                	$a->close;
        	}
	}
}


#-------------------------------------------------------------------

=head2 createThumbnail ( [ thumbnailSize ] )

Generates a thumbnail for this attachment.

=over

=item thumbnailSize

Defaults to the global setting for thumbnail size. However, it can be overriden with this value. Specified in pixels.

=back

=cut

sub createThumbnail {
        my ($image, $error, $x, $y, $r, $n);
        if ($hasImageMagick && $_[0]->isImage) {
                $image = Image::Magick->new;
                $error = $image->Read($_[0]->getPath);
                WebGUI::ErrorHandler::warn("Couldn't read image for thumnail creation: ".$error) if $error;
                ($x, $y) = $image->Get('width','height');
                $n = $_[1] || $session{setting}{thumbnailSize};
                if ($x > $n || $y > $n) {
                        $r = $x>$y ? $x / $n : $y / $n;
                        $image->Scale(width=>($x/$r),height=>($y/$r));
                }
                if (isIn($_[0]->getType, qw(tif tiff bmp))) {
                        $error = $image->Write($_[0]->getNode->getPath.$session{os}{slash}.'thumb-'.$_[0]->getFilename.'.png');
                } else {
                        $error = $image->Write($_[0]->getNode->getPath.$session{os}{slash}.'thumb-'.$_[0]->getFilename);
                }
                WebGUI::ErrorHandler::warn("Couldn't create thumbnail: ".$error) if $error;
        }
}


#-------------------------------------------------------------------

=head2 delete ( )

Deletes an attachment from its node.  Also deletes image thumbnail if present.

=cut

sub delete {
        unlink($_[0]->getPath);
        if ($_[0]->isImage) {
        	if (isIn($_[0]->getType, qw(tif tiff bmp))) {
        		unlink($_[0]->getNode->getPath.$session{os}{slash}.'thumb-'.$_[0]->getFilename.'.png');
        	} else {
	        	unlink($_[0]->getNode->getPath.$session{os}{slash}.'thumb-'.$_[0]->getFilename);
        	}
        }
}


#-------------------------------------------------------------------

=head2 deleteNode ( )

Deletes deletes this attachment's node (and everything in it).

=cut

sub deleteNode {
        rmtree($_[0]->getNode->getPath);
}


#-------------------------------------------------------------------

=head2 getFilename ( )

Returns the attachment's filename.

=cut

sub getFilename {
        return $_[0]->{_filename};
}

#-------------------------------------------------------------------

=head2 getHashref ( )

Returns a hash reference from the attachment. Must be used in conjunction with a file that was saved using the saveFromHashref method.

=cut

sub getHashref {
	return retrieve($_[0]->getPath);
}


#-------------------------------------------------------------------

=head2 getIcon ( )

Returns the full URL to the file icon for this attachment.

=cut

sub getIcon {
	my ($extension, $icon);
	$extension = $_[0]->getType;
	$icon = $session{config}{extrasURL}."/fileIcons/";
	if (isIn($extension, qw(doc dot wri))) {
                $icon .= "doc.gif";
        } elsif (isIn($extension, qw(txt log sql config conf pm cnf readme))) {
                $icon .= "txt.gif";
        } elsif ($extension eq "pdf") {
                $icon .= "pdf.gif";
	} elsif (isIn($extension, qw(xlt csv xls xla xlc xld))) {
                $icon .= "xls.gif";
        } elsif (isIn($extension, qw(zip arj cab))) {
                $icon .= "zip.gif";
        } elsif (isIn($extension, qw(mpeg mpg wav mp3 avi m3u))) {
                $icon .= "wav.gif";
        } elsif (isIn($extension, qw(html htm xml))) {
                $icon .= "html.gif";
        } elsif (isIn($extension, qw(exe com bat pif))) {
                $icon .= "exe.gif";
        } elsif ($extension eq "mdb") {
                $icon .= "mdb.gif";
	} elsif (isIn($extension, qw(ppt pps))) {
                $icon .= "ppt.gif";
        } elsif (isIn($extension, qw(psd eps ai ps))) {
                $icon .= "psd.gif";
        } elsif (isIn($extension, qw(tiff tif bmp psp gif jpg jpeg png))) {
                $icon .= "psp.gif";
        } elsif (isIn($extension, qw(sxi sdd sdp sti kpr))) {
                $icon .= "sxi.gif";
        } elsif (isIn($extension, qw(vsd vdx))) {
                $icon .= "vsd.gif";
        } elsif (isIn($extension, qw(sit hqx sea))) {
                $icon .= "sit.gif";
        } elsif (isIn($extension, qw(dwg dwf dxf))) {
                $icon .= "dwg.gif";
        } elsif (isIn($extension, qw(sxw sdw sxg stw abw aw kwd rtx rtf))) {
                $icon .= "sxw.gif";
        } elsif (isIn($extension, qw(sxc 123 wk1 wk3 wk4 wks sdc stc as gnumeric ksp oleo sylk slk tsv tab))) {
                $icon .= "sxc.gif";
        } elsif (isIn($extension, qw(indd p65 mif))) {
                $icon .= "indd.gif";
        } elsif (isIn($extension, qw(tgz gz tar Z))) {
                $icon .= "gz.gif";
        } elsif ($extension eq "rpm") {
                $icon .= "rpm.gif";
        } elsif (isIn($extension, qw(ra ram))) {
                $icon .= "ra.gif";
        } elsif (isIn($extension, qw(java class jar))) {
                $icon .= "java.gif";
        } elsif (isIn($extension, qw(iso cif))) {
                $icon .= "iso.gif";
        } elsif (isIn($extension, qw(rar ace))) {
                $icon .= "rar.gif";
        } elsif (isIn($extension, qw(mov pic pict))) {
                $icon .= "mov.gif";
        } elsif ($extension eq "lyx") {
                $icon .= "lyx.gif";
        } elsif ($extension eq "sxm") {
                $icon .= "sxm.gif";
        } elsif ($extension eq "sxd") {
                $icon .= "sxd.gif";
        } elsif ($extension eq "mpp") {
		$icon .= "mpp.png";
        } elsif ($extension eq "mrproject") {
                $icon .= "mrproject.gif";
        } elsif ($extension eq "css") {
                $icon .= "css.gif";
        } elsif ($extension eq "swf") {
		$icon .= "swf.gif";
        } elsif ($extension eq "dia") {
                $icon .= "dia.gif";
	} else {
		$icon .= "unknown.gif";
	}
	return $icon;
}


#-------------------------------------------------------------------

=head2 getNode ( )

Returns the node object for this attachment.

=cut

sub getNode {
	return $_[0]->{_node};	
}

#-------------------------------------------------------------------

=head2 getPath ( )

Returns a full path to an attachment.

=cut

sub getPath {
        return $_[0]->getNode->getPath.$session{os}{slash}.$_[0]->getFilename;
}


#-------------------------------------------------------------------

=head2 getSize ( )

Returns the size of this file. 

=cut

sub getSize {
	my ($size);
	my (@attributes) = stat($_[0]->getNode->getPath.$session{os}{slash}.$_[0]->getFilename);
	if ($attributes[7] > 1048576) {
		$size = round($attributes[7]/1048576);
		$size .= 'MB';
	} elsif ($attributes[7] > 1024) {
		$size = round($attributes[7]/1024);
		$size .= 'kB';
	} else {
		$size = $attributes[7]."B";
	}
	return $size;
}


#-------------------------------------------------------------------

=head2 getThumbnail ( )

Returns a full URL to the thumbnail for this attachment. Thumbnails are only created for jpg, gif, png, tif, and bmp with Image::Magick installed so getThumbnail only returns a thumbnail if the file is one of those types and Image::Magick is installed. Otherwise, it returns the full URL to the file icon for this attachment (identical to getIcon).

=cut

sub getThumbnail {
	if ($hasImageMagick && isIn($_[0]->getType, qw(jpg jpeg gif png))) {
        	return $_[0]->getNode->getURL.$session{os}{slash}.'thumb-'.$_[0]->getFilename;
	} elsif ($hasImageMagick && isIn($_[0]->getType, qw(tif tiff bmp))) {
        	return $_[0]->getNode->getURL.$session{os}{slash}.'thumb-'.$_[0]->getFilename.'.png';
	} else {
		return $_[0]->getIcon;
	}
}


#-------------------------------------------------------------------

=head2 getType ( )

Returns the extension or type of this attachment.

=cut

sub getType {
	my ($extension);
	$extension = lc($_[0]->getFilename);
	$extension =~ s/.*\.(.*?)$/$1/;
	return $extension;
}


#-------------------------------------------------------------------

=head2 getURL ( )

Returns a full URL to an attachment.

=cut

sub getURL {
	return $_[0]->getNode->getURL.'/'.$_[0]->getFilename;
}


#-------------------------------------------------------------------

=head2 isImage ( )

Returns a 1 or 0 depending on whether the file is an image or not.

=cut

sub isImage {
        return isIn($_[0]->getType, qw(gif jpeg jpg tif tiff png bmp)),;
}

#-------------------------------------------------------------------

=head2 new ( filename, node [, nodeSubordinate ] )

Constructor.

=over

=item filename

What is the filename for this attachment. If you'll be uploading the attachment using the "save" method then you may leave this field blank.

=item node

The node where this attachment is (or will be placed).

=item nodeSubordinate

The subordinate element of the node where this attachment is (or will be placed).

=back

=cut

sub new {
	my ($class, $filename, $node, $nodeSub) = @_;
	$node = WebGUI::Node->new($node, $nodeSub);
	bless {_node => $node, _filename => $filename}, $class;
}


#-------------------------------------------------------------------

=head2 rename ( newFilename )

Renames an attachment's filename.

=over

=item newFilename

Define the new filename for this attachment.

=back

=cut

sub rename {
	rename $_[0]->getPath, $_[0]->getNode->getPath.$session{os}{slash}.$_[1];
	if ($_[0]->isImage) {
		rename $_[0]->getNode->getPath.$session{os}{slash}.'thumb-'.$_[0]->getFilename, $_[0]->getNode->getPath.$session{os}{slash}."thumb-".$_[1];
	}
	$_[0]->{_filename} = $_[1];
}


#-------------------------------------------------------------------

=head2 resizeImage ( [ imageSize ] )

Resizes this attachment to the specified size. Use this method only if the attachment is an image.

=over

=item imageSize

Defaults to the max image size setting. Specify a value in pixels to resize this image to.

=back

=cut

sub resizeImage {
        my ($image, $error, $x, $y, $r, $n);
        if ($hasImageMagick && isIn($_[0]->getType, qw(jpg jpeg gif png))) {
                $image = Image::Magick->new;
                $error = $image->Read($_[0]->getPath);
                WebGUI::ErrorHandler::warn("Couldn't read image for resizing: ".$error) if $error;
                ($x, $y) = $image->Get('width','height');
                $n = $_[1] || $session{setting}{maxImageSize};
                if ($x > $n || $y > $n) {
                        $r = $x>$y ? $x / $n : $y / $n;
                        $image->Scale(width=>($x/$r),height=>($y/$r));
                        $error = $image->Write($_[0]->getPath);
                        WebGUI::ErrorHandler::warn("Couldn't resize image: ".$error) if $error;
                }
        }
}


#-------------------------------------------------------------------

=head2 save ( formVariableName [, thumbnailSize, imageSize ] )

Grabs an attachment from a form POST and saves it to a node. It then returns the filename of the attachment.

=over

=item formVariableName

Provide the form variable name to which the file being uploaded is assigned.

=item thumbnailSize

If an image is being uploaded a thumbnail will be generated automatically. By default, WebGUI will create a thumbnail of the size specified in the file settings. You can override that size by specifying one here. Size is measured in pixels of the longest side.

=item imageSize

If a web image (gif, png, jpg, jpeg) is being uploaded it will be resized if it is larger than this value. By default images are resized to stay within the contraints of the Max Image Size setting in the file settings.

=back

=cut

sub save {
	my ($type, $file, $filename, $bytesread, $buffer, $urlizedFilename, $path);
	return "" if ($session{header}{status} =~ /^413/);
	$filename = $session{cgi}->upload($_[1]);
	if (defined $filename) {
		if ($filename =~ /([^\/\\]+)$/) {
     			$_[0]->{_filename} = $1;
   		} else {
     			$_[0]->{_filename} = $filename;
   		}
		$type = $_[0]->getType();
		if (isIn($type, qw(pl perl sh cgi php asp))) {
			$_[0]->{_filename} =~ s/\./\_/g;
			$_[0]->{_filename} .= ".txt";
		}
		$_[0]->{_filename} = WebGUI::URL::makeCompliant($_[0]->getFilename);
		$_[0]->getNode->create();
		$file = FileHandle->new(">".$_[0]->getPath);
		if (defined $file) {
			binmode $file;
			while ($bytesread=read($filename,$buffer,1024)) {
        			print $file $buffer;
			}
			close($file);
			$_[0]->createThumbnail($_[2]);
			$_[0]->resizeImage($_[3]);
		} else {
			WebGUI::ErrorHandler::warn("Couldn't open file ".$_[0]->getPath." for writing due to error: ".$!);
			$_[0]->{_filename} = "";
			return "";
		}
		close $filename;
		return $_[0]->getFilename;
	} else {
		return "";
	}
}

#-------------------------------------------------------------------

=head2 saveFromFilesystem ( pathToFile [, thumbnailSize, imageSize ] )

Grabs an attachment from the server's file system and saves it to a node. It then returns the filename of the attachment.

=over

=item pathToFile 

Provide the local path to this file.

=item thumbnailSize

If an image is being grabbed a thumbnail will be generated automatically. By default, WebGUI will create a thumbnail of the size specified in the content settings. You can override that size by specifying one here. Size is measured in pixels of the longest side.

=item imageSize

If a web image (gif, png, jpg, jpeg) is being grabbed it will be resized if it is larger than this value. By default images are resized to stay within the contraints of the Max Image Size setting in the content settings.

=back

=cut

sub saveFromFilesystem {
        my ($type, $a, $b, $filename, $bytesread, $buffer, $urlizedFilename, $path);
        $filename = $_[1];
        if (defined $filename) {
                if ($filename =~ /([^\/\\]+)$/) {
                        $_[0]->{_filename} = $1;
                } else {
                        $_[0]->{_filename} = $filename;
                }
                if (isIn($_[0]->getType, qw(pl perl sh cgi php asp))) {
                        $_[0]->{_filename} =~ s/\./\_/g;
                        $_[0]->{_filename} .= ".txt";
                }
                $_[0]->{_filename} = WebGUI::URL::makeCompliant($_[0]->getFilename);
                $_[0]->getNode->create();
		$a = FileHandle->new($_[1],"r");
                if (defined $a) {
                       	binmode($a);
                	$b = FileHandle->new(">".$_[0]->getPath);
			if (defined $b) {
                        	binmode($b);
                        	cp($a,$b);
                        	$b->close;
                        	$_[0]->createThumbnail($_[2]);
                        	$_[0]->resizeImage($_[3]);
                	} else {
                        	WebGUI::ErrorHandler::warn("Couldn't open file ".$_[0]->getPath." for writing due to error: ".$!);
                        	$_[0]->{_filename} = "";
			}
                       	$a->close;
		} else {
                       	WebGUI::ErrorHandler::warn("Couldn't open file ".$_[1]." for reading due to error: ".$!);
                       	$_[0]->{_filename} = "";
                }
        } else {
                $_[0]->{_filename} = "";
        }
        return $_[0]->getFilename;
}

#-------------------------------------------------------------------

=head2 saveFromHashref ( hashref ) 

Stores a hash reference as an attachment.

=over

=item hashref

A hash reference containing the data you wish to persist to the filesystem.

=back

=cut

sub saveFromHashref {
	my ($self, $hashref) = @_;
        $self->getNode->create();
	store $hashref, $self->getPath;
	return $self->getFilename;
}

1;


