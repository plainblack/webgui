package WebGUI::Asset::File::Image;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::Asset::File;
use WebGUI::HTTP;
use WebGUI::Session;
use WebGUI::Storage;

# do a check to see if they've installed Image::Magick
my  $hasImageMagick = 1;
eval " use Image::Magick; "; $hasImageMagick=0 if $@;

our @ISA = qw(WebGUI::Asset::File);


=head1 NAME

Package WebGUI::Asset::File::Image

=head1 DESCRIPTION

Extends WebGUI::Asset::File to add image manipulation operations.

=head1 SYNOPSIS

use WebGUI::Asset::File::Image;


=head1 METHODS

These methods are available from this class:

=cut



#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
        my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'ImageAsset',
                className=>'WebGUI::Asset::File::Image',
                properties=>{
                                thumbnailSize=>{
                                        fieldType=>'integer',
                                        defaultValue=>$session{setting}{thumbnailSize}
                                        }
                        }
                });
        return $class->SUPER::definition($definition);
}



#-------------------------------------------------------------------

=head2 generateThumbnail ( [ thumbnailSize ] ) 

Generates a thumbnail for this image.

=head3 thumbnailSize

A size, in pixels, of the maximum height or width of a thumbnail. If specified this will change the thumbnail size of the image. If unspecified the thumbnail size set in the properties of this asset will be used.

=cut

sub generateThumbnail {
	my $self = shift;
	my $thumbnailSize = shift;
	if (defined $thumbnailSize) {
		$self->update({thumbnailSize=>$thumbnailSize});
	}
	if ($self->getValue("filename") && $hasImageMagick) {
		my $storage = WebGUI::Storage->new($self->get("storageId"));
                my $image = Image::Magick->new;
                my $error = $image->Read($storage->getPath($storage->get("filename")));
		if ($error) {
			$self->_addError("Couldn't read image for thumnail creation: ".$error);
			return 0;
		}
                my ($x, $y) = $image->Get('width','height');
                my $n = $self->get("thumbnailSize");
                if ($x > $n || $y > $n) {
                        my $r = $x>$y ? $x / $n : $y / $n;
                        $image->Scale(width=>($x/$r),height=>($y/$r));
                }
                if (isIn($storage->getFileExtension($self->get("filename")), qw(tif tiff bmp))) {
                        $error = $image->Write($storage->getPath.$session{os}{slash}.'thumb-'.$self->get("filename").'.png');
                } else {
                        $error = $image->Write($storage->getPath.$session{os}{slash}.'thumb-'.$self->get("filename"));
                }
		if ($error) {
			$self->_addError("Couldn't create thumbnail: ".$error);
			return 0;
		}
		return 1;
	}
	$self->_addError("Can't generate a thumbnail when you haven't uploaded a file.");
	return 0; # couldn't generate thumbnail
}


#-------------------------------------------------------------------

=head2 getEditForm ()

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
        $tabform->getTab("properties")->integer(
               	-name=>"thumbnailSize",
               	-label=>"Thumbnail Size",
		-value=>$self->getValue("thumbnailSize")
               	);
	if ($self->get("filename") ne "") {
		my $storage = WebGUI::Storage->new($self->get("storageId"));
		$tabform->getTab("properties")->readOnly(
			-label=>"Thumbnail",
			-value=>'<img src="'.$storage->getUrl($self->get("filename")).'" alt="thumbnail" />'
			);
	}
}


#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/image.gif' unless ($small);
	$self->SUPER::getIcon(1);
}


#-------------------------------------------------------------------

=head2 getName 

Returns the displayable name of this asset.

=cut

sub getName {
	return "Image";
} 


#-------------------------------------------------------------------

=head2 www_editSave

Gathers data from www_edit and persists it.

=cut

sub www_editSave {
	my $self = shift;
	$self->SUPER::www_editSave();
	$self->generateThumbnail;
	return "";
}


#-------------------------------------------------------------------

=head2 www_view

A web executable method that redirects the user to the specified page, or displays the edit interface when admin mode is enabled.

=cut

sub www_view {
	my $self = shift;
	if ($session{var}{adminOn}) {
		return $self->www_edit;
	}
	my $storage = WebGUI::Storage->new($self->get("storageId"));
	WebGUI::HTTP::setRedirect($storage->getUrl($self->get("filename")));
	return "";
}


1;

