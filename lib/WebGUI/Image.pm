package WebGUI::Image;

use strict;
use Image::Magick;
use WebGUI::Image::Palette;

#-------------------------------------------------------------------
sub getBackgroundColor {
	my $self = shift;

	return $self->{_properties}->{backgroundColorTriplet} || '#ffffff';
}

#-------------------------------------------------------------------
sub getImageHeight {
	my $self = shift;

	return $self->{_properties}->{height} || 300;
}

#-------------------------------------------------------------------
sub getImageWidth {
	my $self = shift;

	return $self->{_properties}->{width} || 300;
}

#-------------------------------------------------------------------
sub getPalette {
	my $self = shift;

	if (!defined $self->{_palette}) {
		$self->{_palette} = WebGUI::Image::Palette->new($self->session, 'defaultPalette');
	}
	
	return $self->{_palette};
}

#-------------------------------------------------------------------
sub getXOffset {
	my $self = shift;

	return $self->getImageWidth / 2; #$self->{_properties}->{xOffset} || $self->getWidth / 2;
}

#-------------------------------------------------------------------
sub getYOffset {
	my $self = shift;

	return $self->getImageHeight / 2; #$self->{_properties}->{yOffset} || $self->getHeight / 2;
}

#-------------------------------------------------------------------
sub image {
	my $self = shift;
	
	return $self->{_image};
}

#-------------------------------------------------------------------
sub new {
	my $class = shift;
	my $session = shift;
	
	my $width = shift || 300;
	my $height = shift || 300;

	my $img = Image::Magick->new;
	$img->Read(filename => 'xc:white');
	
	bless {_image => $img, _session => $session, _properties => {
		width	=> $width,
		height	=> $height,
		}
	}, $class;
}

#-------------------------------------------------------------------
sub session {
	my $self  = shift;

	return $self->{_session};
}

#-------------------------------------------------------------------
sub setBackgroundColor {
	my $self = shift;
	my $colorTriplet = shift;

	$self->image->Colorize(fill => $colorTriplet);
	$self->{_properties}->{backgroundColorTriplet} = $colorTriplet;
}

#-------------------------------------------------------------------
sub setImageHeight {
	my $self = shift;
	my $height = shift;
	
	#$self->image->set(size => $self->getImageWidth.'x'.$height);
	$self->image->Extent(height => $height);
	$self->image->Colorize(fill => $self->getBackgroundColor);
	$self->{_properties}->{height} = $height;
}

#-------------------------------------------------------------------
sub setImageWidth {
	my $self = shift;
	my $width = shift;
	
	#$self->image->set(size => $width.'x'.$self->getImageHeight);
	$self->image->Extent(width => $width);
	$self->image->Colorize(fill => $self->getBackgroundColor);
	$self->{_properties}->{width} = $width;
}

#-------------------------------------------------------------------
sub setPalette {
	my $self = shift;
	my $palette = shift;

	$self->{_palette} = $palette;
}

#-------------------------------------------------------------------
sub saveToFileSystem {
	my $self = shift;
	my $path = shift;
	my $filename = shift || $self->getFilename;
	
	$self->image->Write($path.'/'.$filename);
}

# This doesn't seem to work...
#-------------------------------------------------------------------
sub saveToScalar {
	my $imageContents;
	my $self = shift;

	open my $fh, ">:scalar",  \$imageContents or die;
	$self->image->Write(file => $fh, filename => 'image.png');
	close($fh);
	
	return $imageContents;
}

#-------------------------------------------------------------------
sub saveToStorageLocation {
	my $self = shift;
	my $storage = shift;
	my $filename = shift || $self->getFilename;
	
	$self->image->Write($storage->getPath($filename));
}


#-------------------------------------------------------------------
sub text {
	my $self = shift;
	my %props = @_;

	my $anchorX = $props{x};
	my $anchorY = $props{y};


	my ($x_ppem, $y_ppem, $ascender, $descender, $width, $height, $max_advance) = $self->image->QueryMultilineFontMetrics(%props);

	# Process horizontal alignment
	if ($props{alignHorizontal} eq 'center') {
		$props{x} -= ($width / 2);
	}
	elsif ($props{alignHorizontal} eq 'right') {
		$props{x} -= $width;
	}

	# Process vertical alignment
	if ($props{alignVertical} eq 'center') {
		$props{y} -= ($height / 2);
	}
	elsif ($props{alignVertical} eq 'bottom') {
		$props{y} -= $height;
	}

	# Compensate for ImageMagicks 'ignore gravity when align is set' behaviour...
	if ($props{align} eq 'Center') {
		$props{x} += ($width / 2);
	}
	elsif ($props{align} eq 'Right') {
		$props{x} += $width;
	}

	# Compensate for ImageMagick's 'put all text a line up when align is set' behaviour...
	$props{y} += $y_ppem;

	# We must delete these keys or else placement can go wrong for some reason...
	delete($props{alignHorizontal});
	delete($props{alignVertical});

	$self->image->Annotate(
		#Leave align => 'Left' here as a default or all text will be overcompensated.
		align		=> 'Left',
		%props,
		gravity		=> 'NorthWest',
		antialias	=> 'true',
	);
}
	
1;

