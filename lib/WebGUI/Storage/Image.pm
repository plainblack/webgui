package WebGUI::Storage::Image;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use Image::Magick;
use strict;
use WebGUI::Id;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Utility;

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
my $url = $self->getThumbnailUrl;
my $boolean = $self->isImage;

=cut


#-------------------------------------------------------------------

=head2 addFileFromCaptcha ( )

Generates a captcha image (105px x 26px) and returns the filename and challenge string (6 random characters). For more information about captcha, consult the Wikipedia here: http://en.wikipedia.org/wiki/Captcha

=cut 

sub addFileFromCaptcha {
	my $challenge;
	$challenge.= ('A'..'Z')[26*rand] foreach (1..6);
	my $filename = "captcha.".WebGUI::Id::generate().".png";
	my $image = Image::Magick->new;
	$image->Set(size=>'105x26');
	$image->ReadImage('xc:white');
	$image->Annotate(pointsize=>20, skewY=>5, skewX=>11, gravity=>'center', fill=>'black', antialias=>'true', text=>$challenge);
	$image->Swirl(degrees=>10);
	$image->AddNoise(noise=>'Multiplicative');
	$image->Border(fill=>'black', width=>1, height=>1);
	$image->Write($self->getPath($filename));
	return ($filename, $challenge);
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
	my $thumbnailSize = shift || $session{setting}{thumbnailSize};
	unless (defined $filename) {
		WebGUI::ErrorHandler::warn("Can't generate a thumbnail when you haven't specified a file.");
		return 0;
	}
	unless ($self->isImage($filename)) {
		WebGUI::ErrorHandler::warn("Can't generate a thumbnail for something that's not an image.");
		return 0;
	}
        my $image = Image::Magick->new;
        my $error = $image->Read($self->getPath($filename));
	if ($error) {
		WebGUI::ErrorHandler::warn("Couldn't read image for thumbnail creation: ".$error);
		return 0;
	}
        my ($x, $y) = $image->Get('width','height');
        my $n = $thumbnailSize;
        if ($x > $n || $y > $n) {
                my $r = $x>$y ? $x / $n : $y / $n;
                $image->Scale(width=>($x/$r),height=>($y/$r));
        }
        $error = $image->Write($self->getPath.$session{os}{slash}.'thumb-'.$filename);
	if ($error) {
		WebGUI::ErrorHandler::warn("Couldn't create thumbnail: ".$error);
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
	my $files = $self->SUPER::getFiles;
	my @newFiles;
	foreach my $file (@{$files}) {
		next if $file =~ /^thumb-/;
		push (@newFiles,$file);
	}
	return \@newFiles;
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


1;

