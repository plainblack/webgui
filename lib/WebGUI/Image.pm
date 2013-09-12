package WebGUI::Image;

use strict;
use WebGUI::Image::Palette;
# use Image::Magick;

=head1 NAME

Package WebGUI::Image

=head1 DESCRIPTION

Base class for image manipulations.

=head1 SYNOPSIS

This package purpous for now is to serve the basic needs of the graphing engine
built on top of this class. However, in the future this can be extended to allow
for all kinds of image manipulations within the WebGUI framework.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 getBackgroundColor ( )

Returns the background color triplet. Defaults to #ffffff (white).

=cut

sub getBackgroundColor {
	my $self = shift;

	return $self->{_properties}->{backgroundColorTriplet} || '#ffffff';
}

#-------------------------------------------------------------------

=head2 getFilename ( )

Returns the filename that has been set for this Image.  If no filename
has been set, then it throws a fatal error.

=cut

sub getFilename {
	my $self = shift;
	if (exists $self->{_properties}->{filename}) {
		return $self->{_properties}->{filename};
	}
	$self->session->log->fatal('Attempted to retrieve filename before one was set');
	return '';
}

#-------------------------------------------------------------------

=head2 getImageHeight ( )

Returns the height of the image in pixels.

=cut

sub getImageHeight {
	my $self = shift;

	return $self->{_properties}->{height} || 300;
}

#-------------------------------------------------------------------

=head2 getImageWidth ( )

Returns the width in pixels of the image.

=cut

sub getImageWidth {
	my $self = shift;

	return $self->{_properties}->{width} || 300;
}

#-------------------------------------------------------------------

=head2 getPalette ( )

Returns the palette object this image is set to. Defaults to the default palette.

=cut

sub getPalette {
	my $self = shift;

	if (!defined $self->{_palette}) {
		$self->{_palette} = WebGUI::Image::Palette->new($self->session, 'defaultPalette');
	}
	
	return $self->{_palette};
}

#-------------------------------------------------------------------

=head2 getXOffset ( )

Returns the horizontal offset of the center, relative to which the image is drawn.
Defaults to the physical center of the image.

=cut

sub getXOffset {
	my $self = shift;

	return $self->getImageWidth / 2; #$self->{_properties}->{xOffset} || $self->getWidth / 2;
}

#-------------------------------------------------------------------

=head2 getYOffset ( )

Returns the vertical offset of the center, relative to which the image is drawn.
Defaults to the physical center of the image.

=cut

sub getYOffset {
	my $self = shift;

	return $self->getImageHeight / 2; #$self->{_properties}->{yOffset} || $self->getHeight / 2;
}

#-------------------------------------------------------------------

=head2 image ( )

Returns the imagemagick object containing this image.

=cut

sub image {
	my $self = shift;
	
	return $self->{_image};
}

#-------------------------------------------------------------------

=head2 new ( session, [ width, height ] )

Constructor for an image. Optionally you can pass the size of the image.

=head3 session

The webgui session object.

=head3 width

The width of the image in pixels. Defaults to 300.

=head3 height

The height of the image in pixels. Defaults to 300.

=cut

sub new {
	my $class = shift;
	my $session = shift;
	
	my $width = shift || 300;
	my $height = shift || 300;

	my $img = Image::Magick->new(
		size => $width.'x'.$height,
	);

	$img->ReadImage('xc:white');
	
	bless {_image => $img, _session => $session, _properties => {
		width	=> $width,
		height	=> $height,
		}
	}, $class;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
	my $self  = shift;

	return $self->{_session};
}

#-------------------------------------------------------------------

=head2 setBackgroundColor ( colorTriplet )

Sets the backgroundcolor. Using this method will erase everything that is
already on the image.

=head3 colorTriplet

The color for the background. Supply as a html color triplet of the form
#ffffff.

=cut

sub setBackgroundColor {
	my $self = shift;
	my $colorTriplet = shift;

	$self->image->Colorize(fill => $colorTriplet);
	$self->{_properties}->{backgroundColorTriplet} = $colorTriplet;
}

#-------------------------------------------------------------------

=head2 setFilename ($filename)

Set the default filename to be used for this image.  Returns the filename.

=cut

sub setFilename {
	my ($self,$filename) = shift;
	$self->{_properties}->{filename} = $filename;
}

#-------------------------------------------------------------------

=head2 setImageHeight ( height )

Set the height of the image.

=head3 height

The height of the image in pixels.

=cut

sub setImageHeight {
	my $self = shift;
	my $height = shift;
        die "Must have a height" unless $height;
	$self->image->Extent(height => $height);
	$self->image->Colorize(fill => $self->getBackgroundColor);
	$self->{_properties}->{height} = $height;
}

#-------------------------------------------------------------------

=head2 setImageWidth ( width )

Set the width of the image.

=head3 width

Teh width of the image in pixels.

=cut

sub setImageWidth {
	my $self = shift;
	my $width = shift;
        die "Must have a width" unless $width;
	$self->image->Extent(width => $width);
	$self->image->Colorize(fill => $self->getBackgroundColor);
	$self->{_properties}->{width} = $width;
}

#-------------------------------------------------------------------

=head2 setPalette ( palette )

Set the palette object this image will use.

=head3 palette

An instanciated WebGUI::Image::Palette object.

=cut

sub setPalette {
	my $self = shift;
	my $palette = shift;

	$self->{_palette} = $palette;
}

#-------------------------------------------------------------------

=head2 saveToFileSystem ( path, [ filename ] )

Saves the image to the specified path and filename.

=head3 path

The directory where the image should be saved.

=head3 filename

The filename the image should get. If not passed it will default to the name set
by the setFilename method.

=cut

sub saveToFileSystem {
	my $self = shift;
	my $path = shift;
	my $filename = shift || $self->getFilename;
	
	$self->image->Write($path.'/'.$filename);
}

# This doesn't seem to work...
#-------------------------------------------------------------------

=head2 saveToScalar ( )

Returns a scalar containing the image contents.

NOTE: This method does not work properly at the moment!

=cut

sub saveToScalar {
	my $imageContents;
	my $self = shift;

	open my $fh, ">:scalar",  \$imageContents or die;
	$self->image->Write(file => $fh, filename => 'image.png');
	close($fh);
	
	return $imageContents;
}

#-------------------------------------------------------------------

=head2 saveToStorageLocation ( storage, [ filename ] )

Save the image to the specified storage location.

=head3 storage

An instanciated WebGUI::Storage object.

=head3 filename

The filename the image should get. If not passed it will default to the name set
by the setFilename method.

=cut

sub saveToStorageLocation {
	my $self = shift;
	my $storage = shift;
	my $filename = shift || $self->getFilename;
	
	$self->image->Write($storage->getPath($filename));
}

#-------------------------------------------------------------------

=head2 text ( properties )

Extend the imagemagick Annotate method so alignment can be controlled better.

=head3 properties

A hash containing the imagemagick Annotate properties of your choice.
Additionally you can specify:

	alignHorizontal : The horizontal alignment for the text. Valid values
		are: 'left', 'center' and 'right'. Defaults to 'left'.
	alignVertical : The vertical alignment for the text. Valid values are:
		'top', 'center' and 'bottom'. Defaults to 'top'.

You can use the align property to set the text justification.

=cut

sub text {
	my $self = shift;
	my %properties = @_;

	my $anchorX = $properties{x};
	my $anchorY = $properties{y};

    my ($x_ppem, $y_ppem, $ascender, $descender, $width, $height, $max_advance) = $self->image->QueryMultilineFontMetrics(%properties);

	# Process horizontal alignment
	if ($properties{alignHorizontal} eq 'center') {
		$properties{x} -= ($width / 2);
	}
	elsif ($properties{alignHorizontal} eq 'right') {
		$properties{x} -= $width;
	}

	# Process vertical alignment
	if ($properties{alignVertical} eq 'center') {
		$properties{y} -= ($height / 2);
	}
	elsif ($properties{alignVertical} eq 'bottom') {
		$properties{y} -= $height;
	}

	# Compensate for ImageMagicks 'ignore gravity when align is set' behaviour...
	if ($properties{align} eq 'Center') {
		$properties{x} += ($width / 2);
	}
	elsif ($properties{align} eq 'Right') {
		$properties{x} += $width;
	}

	# Compensate for ImageMagick's 'put all text a line up when align is set' behaviour...
	$properties{y} += $y_ppem;

	# We must delete these keys or else placement can go wrong for some reason...
	delete($properties{alignHorizontal});
	delete($properties{alignVertical});

	$self->image->Annotate(
		#Leave align => 'Left' here as a default or all text will be overcompensated.
		align		=> 'Left',
		%properties,
		gravity		=> 'NorthWest',
		antialias	=> 'true',
	);
}
	
1;

