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
use WebGUI::Utility;


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
                                        },
				parameters=>{
					fieldType=>'textarea',
					defaultValue=>'border="0"'
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
	if (defined $self->get("filename") && $hasImageMagick) {
		my $storage = $self->getStorageLocation;
                my $image = Image::Magick->new;
                my $error = $image->Read($storage->getPath($self->get("filename")));
		if ($error) {
			WebGUI::ErrorHandler::warn("Couldn't read image for thumbnail creation: ".$error);
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
			WebGUI::ErrorHandler::warn("Couldn't create thumbnail: ".$error);
			return 0;
		}
		return 1;
	}
	WebGUI::ErrorHandler::warn("Can't generate a thumbnail when you haven't uploaded a file.");
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
	$tabform->getTab("properties")->textarea(
		-name=>"parameters",
		-label=>"Parameters",
		-value=>$self->getValue("parameters")
		);
	if ($self->get("filename") ne "") {
		$tabform->getTab("properties")->readOnly(
			-label=>"Thumbnail",
			-value=>'<a href="'.$self->getFileUrl.'"><img src="'.$self->getThumbnailUrl.'?noCache='.time().'" alt="thumbnail" /></a>'
			);
	}
	return $tabform;
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


sub getThumbnailUrl {
	my $self = shift;
	return $self->getStorageLocation->getUrl("thumb-".$self->get("filename"));
}


sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my $parameters = $self->get("parameters");
	unless ($parameters =~ /alt\=/) {
		$self->update({parameters=>$parameters.' alt="'.$self->get("title").'"'});
	}
	$self->generateThumbnail;
}

sub view {
	my $self = shift;
	my %var = %{$self->get};
	$var{controls} = $self->getToolbar;
	$var{fileUrl} = $self->getFileUrl;
	$var{fileIcon} = $self->getFileIconUrl;
	$var{thumbnail} = $self->getThumbnailUrl;
	return $self->processTemplate(\%var,"PBtmpl0000000000000088");
}



#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return WebGUI::Privilege::insufficient() unless $self->canEdit;
        return $self->getAdminConsole->render($self->getEditForm->print,"Edit Image");
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
	my $storage = $self->getStorageLocation;
	WebGUI::HTTP::setRedirect($storage->getUrl($self->get("filename")));
	return "";
}


1;

