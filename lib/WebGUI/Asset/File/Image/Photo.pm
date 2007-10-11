package WebGUI::Asset::File::Image::Photo;

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
use Tie::IxHash;
use base 'WebGUI::Asset::File::Image';
use WebGUI::Utility;


=head1 NAME

WebGUI::Asset::File::Image::Photo

=head1 DESCRIPTION


=head1 SYNOPSIS

use WebGUI::Asset::File::Image::Photo


=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 definition ( session, definition )

defines asset properties for New Asset instances.  You absolutely need 
this method in your new Assets. 

=head3 session

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
	my $class       = shift;
	my $session     = shift;
	my $definition  = shift;
        my $i18n        = $class->i18n($session);

	tie my %properties, 'Tie::IxHash', (


        );

	push @{$definition}, {
            assetName   => $i18n->get('assetName'),
            icon        => 'Image.gif',
            tableName   => 'Photo',
            className   => 'WebGUI::Asset::File::Image::Photo',
            i18n        => 'Asset_Photo',
            properties  => \%properties,
	};
	return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 i18n ( [ session ] )

Get a WebGUI::International object for this class. 

Can be called as a class method, in which case a WebGUI::Session object
must be passed in.

Can be called as an object method, in which case the session is 
filled in automatically.

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Used to process properties from the form posted.  Do custom things with
noFormPost fields here, or do whatever you want.  This method is called
when /yourAssetUrl?func=editSave is requested/posted.

=cut

sub processPropertiesFromFormPost {
	my $self = shift;
	$self->SUPER::processPropertiesFromFormPost;
}


#-------------------------------------------------------------------

=head2 purge ( )

This method is called when data is purged by the system.
removes collateral data associated with a NewAsset when the system
purges it's data.  This method is unnecessary, but if you have 
auxiliary, ancillary, or "collateral" data or files related to your 
asset instances, you will need to purge them here.

=cut

sub purge {
	my $self = shift;
	return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 purgeRevision ( )

This method is called when data is purged by the system.

=cut

sub purgeRevision {
	my $self = shift;
	return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------
=head2 view ( )

method called by the container www_view method. 

=cut

sub view {
	my $self = shift;
	my $var = $self->get; # $var is a hash reference.
	$var->{controls} = $self->getToolbar;
	$var->{fileUrl} = $self->getFileUrl;
	$var->{fileIcon} = $self->getFileIconUrl;
	return $self->processTemplate($var,undef, $self->{_viewTemplate});
}


#-------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page

=cut

sub www_edit {
   my $self = shift;
   return $self->session->privilege->insufficient() unless $self->canEdit;
   return $self->session->privilege->locked() unless $self->canEditIfLocked;
   return $self->getAdminConsole->render($self->getEditForm->print,WebGUI::International::get('edit asset',"Asset_NewAsset"));
}

#-------------------------------------------------------------------

=head2 www_view ( )

Web facing method which is the default view page.  This method does a 
302 redirect to the "showPage" file in the storage location.

=cut

sub www_view {
	my $self = shift;
	return $self->session->privilege->noAccess() unless $self->canView;
	if ($self->session->var->isAdminOn) {
		return $self->getContainer->www_view;
	}
	$self->session->http->setRedirect($self->getFileUrl($self->getValue("showPage")));
	return "";
}


1;

