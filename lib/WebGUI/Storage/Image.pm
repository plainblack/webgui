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

use strict;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::Utility;


# do a check to see if they've installed Image::Magick
my  $hasImageMagick = 1;
eval " use Image::Magick; "; $hasImageMagick=0 if $@;

our @ISA = qw(WebGUI::Storage);


=head1 NAME

Package WebGUI::Storage::Image

=head1 DESCRIPTION

Extends WebGUI::Storageto add image manipulation operations.

=head1 SYNOPSIS

use WebGUI::Storage::Image;


=head1 METHODS

These methods are available from this class:

my $boolean = $self->generateThumbnail($filename);
my $url = $self->getThumbnailUrl;
my $boolean = $self->isImage;

=cut



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
	unless ($hasImageMagick) {
		WebGUI::ErrorHandler::warn("Can't generate a thumbnail if you don't have Image Magick.");
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

