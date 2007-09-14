package WebGUI::Storage::Image;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Storage;
use WebGUI::Utility;
use Carp qw(croak);
eval 'use Graphics::Magick';
my $graphicsMagickAvailable = ($@) ? 0 : 1;
eval 'use Image::Magick';
my $imageMagickAvailable = ($@) ? 0 : 1;
my $graphicsPackage = '';
if ($imageMagickAvailable) {
    $graphicsPackage = "Image::Magick";
}
elsif ($graphicsMagickAvailable) {
    $graphicsPackage = "Graphics::Magick";
}
else {
    croak "You must have either Graphics::Magick or Image::Magick installed to run WebGUI.\n";
}


our @ISA = qw(WebGUI::Storage);


=head1 NAME

Package WebGUI::Storage::Image

=head1 DESCRIPTION

Extends WebGUI::Storage to add image manipulation operations.

=head1 SYNOPSIS

use WebGUI::Storage::Image;


=head1 METHODS

These methods are available from this class:

my $boolean = $self->generateThumbnail($filename);
my $url = $self->getThumbnailUrl($filename);
my $boolean = $self->isImage($filename);
my ($captchaFile, $challenge) = $self->addFileFromCaptcha;
$self->resize($imageFile, $width, $height);

=cut


#-------------------------------------------------------------------

=head2 addFileFromCaptcha ( )

Generates a captcha image (105px x 26px) and returns the filename and challenge string (6 random characters). For more information about captcha, consult the Wikipedia here: http://en.wikipedia.org/wiki/Captcha

=cut 

sub addFileFromCaptcha {
	my $self = shift;
    my $error = "";
	my $challenge;
    srand;
	$challenge.= ('A'..'Z')[rand(26)] foreach (1..6);
	my $filename = "captcha.".$self->session->id->generate().".gif";
	my $image = $graphicsPackage->new();
	$error = $image->Set(size=>'105x26');
	if($error) {
        $self->session->errorHandler->warn("Error setting captcha image size: $error");
    }
    $error = $image->ReadImage('xc:white');
	if($error) {
        $self->session->errorHandler->warn("Error initializing image: $error");
    }
    $error = $image->AddNoise(noise=>"Multiplicative");
	if($error) {
        $self->session->errorHandler->warn("Error adding noise: $error");
    }
    $error = $image->Annotate(font=>$self->session->config->getWebguiRoot."/lib/default.ttf", pointsize=>30, skewY=>0, skewX=>0, gravity=>'center', fill=>'#666666', antialias=>'true', text=>$challenge);
	if($error) {
        $self->session->errorHandler->warn("Error Annotating image: $error");
    }
    $error = $image->Draw(primitive=>"line", points=>"0,5 105,21", stroke=>'#666666', antialias=>'true', strokewidth=>2);
	if($error) {
        $self->session->errorHandler->warn("Error drawing line: $error");
    }
    $error = $image->Blur(geometry=>"9");
	if($error) {
        $self->session->errorHandler->warn("Error blurring image: $error");
    }
    $error = $image->Set(type=>"Grayscale");
	if($error) {
        $self->session->errorHandler->warn("Error setting grayscale: $error");
    }
    $error = $image->Border(fill=>'black', width=>1, height=>1);
	if($error) {
        $self->session->errorHandler->warn("Error setting border: $error");
    }
    $error = $image->Write($self->getPath($filename));
	if($error) {
        $self->session->errorHandler->warn("Error writing image: $error");
    }
    return ($filename, $challenge);
}

#-------------------------------------------------------------------

=head2 copy ( [ storage ] )

Overriding the copy method so that thumbnail files are copied along with other image files

=head3 storage

Optionally pass a storage object to copy the files to.

=cut

sub copy {
	my $self = shift;
	my $newStorage = shift || WebGUI::Storage::Image->create($self->session);
	# Storage::Image->getFiles excludes thumbnails from the filelist and we want to copy the thumbnails
	my $filelist = $self->SUPER::getFiles(1);
	
	return $self->SUPER::copy($newStorage, $filelist);
}

#-------------------------------------------------------------------

=head2 deleteFile ( filename )

Deletes the thumbnail for a file and the file from its storage location

=head3 filename

The name of the file to delete.

=cut

sub deleteFile {
    my $self = shift;
    my $filename = shift;
    $self->SUPER::deleteFile('thumb-'.$filename);
    $self->SUPER::deleteFile($filename);
}



#-------------------------------------------------------------------

=head2 generateThumbnail ( filename, [ thumbnailSize ] ) 

Generates a thumbnail for this image.

=head3 filename

The file to generate a thumbnail for.

=head3 thumbnailSize

The size in pixels of the thumbnail to be generated. If not specified the thumbnail size in the global settings will be used.

=cut

sub generateThumbnail {
	my $self = shift;
	my $filename = shift;
	my $thumbnailSize = shift || $self->session->setting->get("thumbnailSize") || 100;
	unless (defined $filename) {
		$self->session->errorHandler->error("Can't generate a thumbnail when you haven't specified a file.");
		return 0;
	}
	unless ($self->isImage($filename)) {
		$self->session->errorHandler->warn("Can't generate a thumbnail for something that's not an image.");
		return 0;
	}
        my $image = $graphicsPackage->new;
        my $error = $image->Read($self->getPath($filename));
	if ($error) {
		$self->session->errorHandler->error("Couldn't read image for thumbnail creation: ".$error);
		return 0;
	}
        my ($x, $y) = $image->Get('width','height');
        my $n = $thumbnailSize;
        if ($x > $n || $y > $n) {
                my $r = $x>$y ? $x / $n : $y / $n;
                $x /= $r;
                $y /= $r;
                if($x < 1) { $x = 1 } # Dimentions < 1 cause Scale to fail
                if($y < 1) { $y = 1 }
                $image->Scale(width=>$x,height=>$y);
		$image->Sharpen('0.0x1.0');
        }
        $error = $image->Write($self->getPath.'/'.'thumb-'.$filename);
	if ($error) {
		$self->session->errorHandler->error("Couldn't create thumbnail: ".$error);
		return 0;
	}
	return 1;
}

#-------------------------------------------------------------------

=head2 getFiles ( )

Returns an array reference of the files in this storage location.

=cut

sub getFiles {
	my $self = shift;
	my $files = $self->SUPER::getFiles(@_);
	my @newFiles;
	foreach my $file (@{$files}) {
		next if $file =~ /^thumb-/;
		push (@newFiles,$file);
	}
	return \@newFiles;
}

#-------------------------------------------------------------------

=head2 getSizeInPixels ( filename )

Returns the width and height in pixels of the specified file.

=head3 filename

The name of the file to get the size of.

=cut

sub getSizeInPixels {
	my $self = shift;
	my $filename = shift;
	unless (defined $filename) {
		$self->session->errorHandler->error("Can't check the size when you haven't specified a file.");
		return 0;
	}
	unless ($self->isImage($filename)) {
		$self->session->errorHandler->error("Can't check the size of something that's not an image.");
		return 0;
	}
        my $image = $graphicsPackage->new;
        my $error = $image->Read($self->getPath($filename));
	if ($error) {
		$self->session->errorHandler->error("Couldn't read image to check the size of it: ".$error);
		return 0;
	}
        return $image->Get('width','height');
}

#-------------------------------------------------------------------

=head2 getThumbnailUrl ( filename ) 

Returns the URL to a thumbnail for a given image.

=head3 filename

The file to retrieve the thumbnail for.

=cut

sub getThumbnailUrl {
	my $self = shift;
	my $filename = shift;
	if (! defined $filename) {
		$self->session->errorHandler->error("Can't make a thumbnail url without a filename.");
		return '';
	}
    if (! isIn($filename, @{ $self->getFiles() })) {
        $self->session->errorHandler->error("Can't make a thumbnail for a file that is not in my storage location.");
        return '';
    }
	return $self->getUrl("thumb-".$filename);
}


#-------------------------------------------------------------------

=head2 isImage ( filename ) 

Checks to see that the file specified is an image. Returns a 1 or 0 depending upon the result.

=head3 filename

The file to check.

=cut

sub isImage {
	my $self = shift;
	my $filename = shift;
	return isIn($self->getFileExtension($filename), qw(jpeg jpg gif png))
}


#-------------------------------------------------------------------

=head2 resize ( filename [, width, height ] )

Resizes the specified image by the specified height and width. If either is omitted the iamge will be scaleed proportionately to the non-omitted one.

=head3 filename

The name of the file to resize.

=head3 width

The new width of the image in pixels.

=head3 height

The new height of the image in pixels.

=cut

sub resize { 
	my $self = shift;
	my $filename = shift;
	my $width = shift;
	my $height = shift;
	unless (defined $filename) {
		$self->session->errorHandler->error("Can't resize when you haven't specified a file.");
		return 0;
	}
	unless ($self->isImage($filename)) {
		$self->session->errorHandler->error("Can't resize something that's not an image.");
		return 0;
	}
	unless ($width || $height) {
		$self->session->errorHandler->error("Can't resize with no resizing parameters.");
		return 0;
	}
        my $image = $graphicsPackage->new;
        my $error = $image->Read($self->getPath($filename));
	if ($error) {
		$self->session->errorHandler->error("Couldn't read image for resizing: ".$error);
		return 0;
	}
        my ($x, $y) = $image->Get('width','height');
	if ($width && !$height) { # proportional scale by width
		$height = $width / $x * $y;
	} elsif (!$width && $height) { # proportional scale by height
		$width = $height * $x / $y;
	}
        $image->Scale(width=>$width, height=>$height);
        $error = $image->Write($self->getPath($filename));
	if ($error) {
		$self->session->errorHandler->error("Couldn't create thumbnail: ".$error);
		return 0;
	}
	return 1;
}


1;

