package WebGUI::Macro::SI_scaledImage;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Collateral;
use WebGUI::Macro;
use WebGUI::ErrorHandler;
use WebGUI::Session;
use WebGUI::Utility;

# test for Image::Magick

# (Would be nice if the results of this test were availiable somewhere 
# central)

my $hasImageMagick=1;
eval " use Image::Magick; "; $hasImageMagick=0 if $@;

#-------------------------------------------------------------------
sub _getImage {
  my ($collateral) = @_;
  return undef unless ($hasImageMagick);
  my $image = Image::Magick->new();
  if (my $error = $image->Read($collateral->getPath)) {
    WebGUI::ErrorHandler::warn("Couldn't read image for resizing: ".$error);
    return undef;
  }
  return $image;
}

#-------------------------------------------------------------------
sub process {
        my ($collateralIdent,$width,$height,$parameters) = WebGUI::Macro::getParams($_[0]);
        my ($collateral,$url);
       
        if ($collateralIdent =~ /^\d+$/) {
          $collateral = WebGUI::Collateral->new($collateralIdent);
        }
        else {
          $collateral = WebGUI::Collateral->find($collateralIdent);
        }

        unless ($collateral) {
          WebGUI::ErrorHandler::warn("collateral not found: $collateralIdent");
          return '';
        }

        unless ($collateral->isImage()) {
          WebGUI::ErrorHandler::warn("Bad image type: $collateralIdent");
          return '';
        }

        if ($width || $height) {
          $url = scaleImage(
            collateral => $collateral,
            width => $width,
            height => $height
          );
        }
        else {
          WebGUI::ErrorHandler::warn("width or heigth must be specified");
        }
        
        $url ||= $collateral->getURL;

	return qq!<img src="$url" $parameters/>!; 
}

#-------------------------------------------------------------------
sub scaleImage {
  my (%p) = @_;
  
  my ($collateral,$width,$height) = @p{qw(collateral width height)};
  
  # paranoia
  return undef unless ($height || $width);
  
  my $filename = "SIThumb_".($width || 'r')."x".($height || 'r')."_".$collateral->getFilename();
  $filename .= '.png' if (isIn($collateral->getType(), qw(tif tiff bmp)));
  
  my $pathName = $collateral->{_node}->getPath().$session{os}{slash}.$filename;
  unless (-e $pathName) {
    my $image = _getImage($collateral);
    return undef unless $image;
    my ($newWidth,$newHeight);
    
    if ($width && $height) {
      ($newWidth,$newHeight) = ($width,$height);
    }
    else {
      my ($x, $y) = $image->Get('width','height');  
      my $ratio = $x / $y;
      $newWidth  = $width ? $width : $height * $ratio;
      $newHeight = $height ? $height : $width / $ratio;
    }
    
    my $max = $session{setting}{maxImageSize};
    if ($newHeight > $max || $newWidth > $max) {
      WebGUI::ErrorHandler::warn(
        "Image too large ($newWidth,$newHeight) :".$collateral->get('name')
      );
      return undef;
    }
    
    $image->Scale(width => $newWidth, height => $newHeight);
    if (my $error = $image->Write($pathName)) {
      WebGUI::ErrorHandler::warn("Couldn't resize image: ".$error);
    }
  }
  
  return $collateral->{_node}->getURL."/$filename";
}

1;


