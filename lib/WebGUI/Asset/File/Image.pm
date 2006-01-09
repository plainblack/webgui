package WebGUI::Asset::File::Image;

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

use strict;
use WebGUI::Asset::File;
use WebGUI::Storage::Image;
use WebGUI::HTMLForm;
use WebGUI::HTTP;
use WebGUI::Session;
use WebGUI::Utility;



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
		assetName=>WebGUI::International::get('assetName',"Asset_Image"),
                tableName=>'ImageAsset',
                className=>'WebGUI::Asset::File::Image',
                properties=>{
                                thumbnailSize=>{
                                        fieldType=>'integer',
                                        defaultValue=>$self->session->setting->get("thumbnailSize")
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
	$self->getStorageLocation->generateThumbnail($self->get("filename"),$self->get("thumbnailSize"));
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
		-label=>WebGUI::International::get('thumbnail size', 'Asset_Image'),
		-hoverHelp=>WebGUI::International::get('Thumbnail size description', 'Asset_Image'),
		-value=>$self->getValue("thumbnailSize")
               	);
	$tabform->getTab("properties")->textarea(
		-name=>"parameters",
		-label=>WebGUI::International::get('parameters', 'Asset_Image'),
		-hoverHelp=>WebGUI::International::get('Parameters description', 'Asset_Image'),
		-value=>$self->getValue("parameters")
		);
	if ($self->get("filename") ne "") {
		$tabform->getTab("properties")->readOnly(
			-label=>WebGUI::International::get('thumbnail', 'Asset_Image'),
			-hoverHelp=>WebGUI::International::get('Thumbnail description', 'Asset_Image'),
			-value=>'<a href="'.$self->getFileUrl.'"><img src="'.$self->getThumbnailUrl.'?noCache='.time().'" alt="thumbnail" /></a>'
			);
		my ($x, $y) = $self->getStorageLocation->getSizeInPixels($self->get("filename"));
        	$tabform->getTab("properties")->readOnly(
			-label=>WebGUI::International::get('image size', 'Asset_Image'),
			-value=>$x.' x '.$y
			);
	}
	return $tabform;
}


#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $self->session->config->get("extrasURL").'/assets/image.gif' unless ($small);
	$self->SUPER::getIcon(1);
}


#-------------------------------------------------------------------
sub getStorageLocation {
	my $self = shift;
	unless (exists $self->{_storageLocation}) {
		if ($self->get("storageId") eq "") {
			$self->{_storageLocation} = WebGUI::Storage::Image->create;
			$self->update({storageId=>$self->{_storageLocation}->getId});
		} else {
			$self->{_storageLocation} = WebGUI::Storage::Image->get($self->get("storageId"));
		}
	}
	return $self->{_storageLocation};
}

#-------------------------------------------------------------------
sub getThumbnailUrl {
	my $self = shift;
	return $self->getStorageLocation->getThumbnailUrl($self->get("filename"));
}

#-------------------------------------------------------------------

=head2 getToolbar ( )

Returns a toolbar with a set of icons that hyperlink to functions that delete, edit, promote, demote, cut, and copy.

=cut

sub getToolbar {
	my $self = shift;
	return undef if ($self->getToolbarState);
	return $self->SUPER::getToolbar();
}

#-------------------------------------------------------------------
sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
	my $parameters = $self->get("parameters");
	unless ($parameters =~ /alt\=/) {
		$self->update({parameters=>$parameters.' alt="'.$self->get("title").'"'});
	}
	my $storage = $self->getStorageLocation;
	$self->generateThumbnail($self->session->setting->get("maxImageSize"));
	$storage->deleteFile($self->get("filename"));
	$storage->renameFile('thumb-'.$self->get("filename"),$self->get("filename"));
	$self->generateThumbnail($self->session->form->process("thumbnailSize"));
}

#-------------------------------------------------------------------
sub setSize {
	my $self = shift;
	my $input = shift;
	my $storage = $self->getStorageLocation;
	my $size = ($input > $storage->getFileSize($self->get("filename"))) ? $input : $storage->getFileSize($self->get("filename"));
	return $self->SUPER::setSize($size);
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var = %{$self->get};
	$var{controls} = $self->getToolbar;
	$var{fileUrl} = $self->getFileUrl;
	$var{fileIcon} = $self->getFileIconUrl;
	$var{thumbnail} = $self->getThumbnailUrl;
	return $self->processTemplate(\%var,$self->get("templateId"));
}

#-------------------------------------------------------------------
sub www_edit {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=resize'),WebGUI::International::get("resize image","Asset_Image")) if ($self->get("filename"));
	my $tabform = $self->getEditForm;
	$tabform->getTab("display")->template(
		-value=>$self->get("templateId"),
		-namespace=>"ImageAsset",
		-hoverHelp=>WebGUI::International::get('image template description','Asset_Image'),
		-defaultValue=>"PBtmpl0000000000000088"
		);
        $self->getAdminConsole->setHelp("image add/edit","Asset_Image");
        return $self->getAdminConsole->render($tabform->print,WebGUI::International::get("edit image","Asset_Image"));
}

#-------------------------------------------------------------------
sub www_resize {
        my $self = shift;
        return $self->session->privilege->insufficient() unless $self->canEdit;
	if ($self->session->form->process("newWidth") || $self->session->form->process("newHeight")) {
		$self->getStorageLocation->resize($self->get("filename"),$self->session->form->process("newWidth"),$self->session->form->process("newHeight"));
		$self->setSize($self->getStorageLocation->getFileSize($self->get("filename")));
	}
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=edit'),WebGUI::International::get("edit image","Asset_Image"));
	my $f = WebGUI::HTMLForm->new(-action=>$self->getUrl);
	$f->hidden(
		-name=>"func",
		-value=>"resize"
		);
	my ($x, $y) = $self->getStorageLocation->getSizeInPixels($self->get("filename"));
       	$f->readOnly(
		-label=>WebGUI::International::get('image size', 'Asset_Image'),
		-hoverHelp=>WebGUI::International::get('image size description', 'Asset_Image'),
		-value=>$x.' x '.$y,
		);
	$f->integer(
		-label=>WebGUI::International::get('new width','Asset_Image'),
		-hoverHelp=>WebGUI::International::get('new width description','Asset_Image'),
		-name=>"newWidth",
		-value=>$x,
		);
	$f->integer(
		-label=>WebGUI::International::get('new height','Asset_Image'),
		-hoverHelp=>WebGUI::International::get('new height description','Asset_Image'),
		-name=>"newHeight",
		-value=>$y,
		);
	$f->submit;
	my $image = '<div align="center"><img src="'.$self->getStorageLocation->getUrl($self->get("filename")).'" border="1" alt="'.$self->get("filename").'" /></div>';
        $self->getAdminConsole->setHelp("image resize","Asset_Image");
        return $self->getAdminConsole->render($f->print.$image,WebGUI::International::get("resize image","Asset_Image"));
}

#-------------------------------------------------------------------

=head2 www_view

A web executable method that redirects the user to the specified page, or displays the edit interface when admin mode is enabled.

=cut

sub www_view {
	my $self = shift;
	if ($self->session->var->get("adminOn")) {
		return $self->www_edit;
	}
	my $storage = $self->getStorageLocation;
	WebGUI::HTTP::setRedirect($storage->getUrl($self->get("filename")));
	return "";
}


1;

