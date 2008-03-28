package WebGUI::Asset::File::Image;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2008 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Asset::File';
use WebGUI::Storage::Image;
use WebGUI::HTMLForm;
use WebGUI::Utility;
use WebGUI::Form::Image;

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

=head2 applyConstraints ( options ) 

Things that are done after a new file is attached.

=head3 options

A hash reference of optional parameters.

=head4 maxImageSize

An integer (in pixels) representing the longest edge the image may have.

=head4 thumbnailSize

An integer (in pixels) representing the longest edge a thumbnail may have.

=cut

sub applyConstraints {
    my $self = shift;
    my $options = shift;
    $self->SUPER::applyConstraints($options);
    my $maxImageSize = $options->{maxImageSize} || $self->get('maxImageSize') || $self->session->setting->get("maxImageSize");
    my $thumbnailSize = $options->{thumbnailSize} || $self->get('thumbnailSize') || $self->session->setting->get("thumbnailSize");
	my $parameters = $self->get("parameters");
    my $storage = $self->getStorageLocation;
	unless ($parameters =~ /alt\=/) {
		$self->update({parameters=>$parameters.' alt="'.$self->get("title").'"'});
	}
    my $file = $self->get("filename");
    $storage->adjustMaxImageSize($file, $maxImageSize);
    $self->generateThumbnail($thumbnailSize);
    $self->setSize;
}



#-------------------------------------------------------------------

=head2 definition ( definition )

Defines the properties of this asset.

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
    my $class       = shift;
    my $session     = shift;
    my $definition  = shift;
    my $i18n        = WebGUI::International->new($session,"Asset_Image");
    push @{$definition}, {
        assetName       => $i18n->get('assetName'),
        tableName       => 'ImageAsset',
        className       => 'WebGUI::Asset::File::Image',
        icon            => 'image.gif',
        properties => {
            thumbnailSize => {
                fieldType       => 'integer',
                defaultValue    => $session->setting->get("thumbnailSize"),
            },
            parameters => {
                fieldType       => 'textarea',
                defaultValue    => 'style="border-style:none;"',
            },
        },
    };
    return $class->SUPER::definition($session,$definition);
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

=head2 getEditForm ( )

Returns the TabForm object that will be used in generating the edit page for this asset.

=cut

sub getEditForm {
	my $self = shift;
	my $tabform = $self->SUPER::getEditForm();
	my $i18n = WebGUI::International->new($self->session,"Asset_Image");
        $tabform->getTab("properties")->integer(
               	-name=>"thumbnailSize",
		-label=>$i18n->get('thumbnail size'),
		-hoverHelp=>$i18n->get('Thumbnail size description'),
		-value=>$self->getValue("thumbnailSize")
               	);
	$tabform->getTab("properties")->textarea(
		-name=>"parameters",
		-label=>$i18n->get('parameters'),
		-hoverHelp=>$i18n->get('Parameters description'),
		-value=>$self->getValue("parameters")
		);
	if ($self->get("filename") ne "") {
		$tabform->getTab("properties")->readOnly(
			-label=>$i18n->get('thumbnail'),
			-hoverHelp=>$i18n->get('Thumbnail description'),
			-value=>'<a href="'.$self->getFileUrl.'"><img src="'.$self->getThumbnailUrl.'?noCache='.$self->session->datetime->time().'" alt="thumbnail" /></a>'
			);
		my ($x, $y) = $self->getStorageLocation->getSizeInPixels($self->get("filename"));
        	$tabform->getTab("properties")->readOnly(
			-label=>$i18n->get('image size'),
			-value=>$x.' x '.$y
			);
	}
	return $tabform;
}

#----------------------------------------------------------------------------

=head2 getStorageClass

Returns the class name of the WebGUI::Storage we should use for this asset.

=cut

sub getStorageClass {
    return 'WebGUI::Storage::Image';
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

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
	my $self = shift;
	$self->SUPER::prepareView();
	my $template = WebGUI::Asset::Template->new($self->session, $self->get("templateId"));
	$template->prepare;
	$self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------
sub view {
	my $self = shift;
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		my $out = WebGUI::Cache->new($self->session,"view_".$self->getId)->get;
		return $out if $out;
	}
	my %var = %{$self->get};
	$var{controls} = $self->getToolbar;
	$var{fileUrl} = $self->getFileUrl;
	$var{fileIcon} = $self->getFileIconUrl;
	$var{thumbnail} = $self->getThumbnailUrl;
       	my $out = $self->processTemplate(\%var,undef,$self->{_viewTemplate});
	if (!$self->session->var->isAdminOn && $self->get("cacheTimeout") > 10) {
		WebGUI::Cache->new($self->session,"view_".$self->getId)->set($out,$self->get("cacheTimeout"));
	}
       	return $out;
}

#----------------------------------------------------------------------------

=head2 setFile ( filename )

Extend the superclass setFile to automatically generate thumbnails.

=cut

sub setFile {
    my $self    = shift;
    $self->SUPER::setFile(@_);
    $self->generateThumbnail;
}

#-------------------------------------------------------------------
sub www_edit {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
	my $i18n = WebGUI::International->new($self->session, 'Asset_Image');
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=resize'),$i18n->get("resize image")) if ($self->get("filename"));
	my $tabform = $self->getEditForm;
	$tabform->getTab("display")->template(
		-value=>$self->get("templateId"),
		-namespace=>"ImageAsset",
		-hoverHelp=>$i18n->get('image template description'),
		-defaultValue=>"PBtmpl0000000000000088"
		);
        return $self->getAdminConsole->render($tabform->print,$i18n->get("edit image"));
}

#-------------------------------------------------------------------
sub www_resize {
    my $self = shift;
    return $self->session->privilege->insufficient() unless $self->canEdit;
    return $self->session->privilege->locked() unless $self->canEditIfLocked;
	if ($self->session->form->process("newWidth") || $self->session->form->process("newHeight")) {
		my $newSelf = $self->addRevision();
		delete $newSelf->{_storageLocation};
		$newSelf->getStorageLocation->resize($newSelf->get("filename"),$newSelf->session->form->process("newWidth"),$newSelf->session->form->process("newHeight"));
		$newSelf->setSize($newSelf->getStorageLocation->getFileSize($newSelf->get("filename")));
		$self = $newSelf;
	}
	my $i18n = WebGUI::International->new($self->session,"Asset_Image");
	$self->getAdminConsole->addSubmenuItem($self->getUrl('func=edit'),$i18n->get("edit image"));
	my $f = WebGUI::HTMLForm->new($self->session,-action=>$self->getUrl);
	$f->hidden(
		-name=>"func",
		-value=>"resize"
		);
	my ($x, $y) = $self->getStorageLocation->getSizeInPixels($self->get("filename"));
       	$f->readOnly(
		-label=>$i18n->get('image size'),
		-hoverHelp=>$i18n->get('image size description'),
		-value=>$x.' x '.$y,
		);
	$f->integer(
		-label=>$i18n->get('new width'),
		-hoverHelp=>$i18n->get('new width description'),
		-name=>"newWidth",
		-value=>$x,
		);
	$f->integer(
		-label=>$i18n->get('new height'),
		-hoverHelp=>$i18n->get('new height description'),
		-name=>"newHeight",
		-value=>$y,
		);
	$f->submit;
	my $image = '<div align="center"><img src="'.$self->getStorageLocation->getUrl($self->get("filename")).'" style="border-style:none;" alt="'.$self->get("filename").'" /></div>';
        return $self->getAdminConsole->render($f->print.$image,$i18n->get("resize image"));
}

#-------------------------------------------------------------------
# Use superclass method for now.
sub www_view {
	my $self = shift;
	$self->SUPER::www_view;
}

#sub www_view {
#	my $self = shift;
#	my $storage = $self->getStorageLocation;
#	$self->session->http->setRedirect($storage->getUrl($self->get("filename")));
#	$self->session->http->setStreamedFile($storage->getPath($self->get("filename")));
#	return "1";
#}


1;

