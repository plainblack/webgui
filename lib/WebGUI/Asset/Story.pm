package WebGUI::Asset::Story;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Class::C3;
use base 'WebGUI::Asset';
use Tie::IxHash;
use WebGUI::Utility;
use WebGUI::International;

=head1 NAME

Package WebGUI::Asset::Story

=head1 DESCRIPTION

The Story Asset is like a Thread for the Collaboration.

=head1 SYNOPSIS

use WebGUI::Asset::Story;


=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 addChild ( )

You can't add children to a Story.

=cut

sub addChild {
    return undef;
}

#-------------------------------------------------------------------

=head2 addRevision

Make sure that Stories are always hidden from navigation.  Copy storage locations so that
purging individual revisions works correctly.

=cut

sub addRevision {
    my $self = shift;
    my $newSelf = $self->next::method(@_);

    my $newProperties = {
        isHidden => 1,
    };

    if ($newSelf->get("storageId") && $newSelf->get("storageId") eq $self->get('storageId')) {
        my $newStorage = $self->getStorageClass->get($self->session,$self->get("storageId"))->copy;
        $newProperties->{storageId} = $newStorage->getId;
    }

    $newSelf->update($newProperties);

    return $newSelf;
}

#-------------------------------------------------------------------

=head2 definition ( session, definition )

defines asset properties for New Asset instances.  You absolutely need 
this method in your new Assets. 

=head3 session

=head3 definition

A hash reference passed in from a subclass definition.

=cut

sub definition {
    my $class = shift;
    my $session = shift;
    my $definition = shift;
    my %properties;
    tie %properties, 'Tie::IxHash';
    my $i18n = WebGUI::International->new($session, 'Asset_Story');
    %properties = (
        headline => {
            fieldType    => 'text',  
            #label        => $i18n->get('headline'),
            #hoverHelp    => $i18n->get('headline help'),
            defaultValue => '',
        },
        subtitle => {
            fieldType    => 'text',  
            #label        => $i18n->get('subtitle'),
            #hoverHelp    => $i18n->get('subtitle help'),
            defaultValue => '',
        },
        byline => {
            fieldType    => 'text',  
            #label        => $i18n->get('byline'),
            #hoverHelp    => $i18n->get('byline help'),
            defaultValue => '',
        },
        location => {
            fieldType    => 'text',  
            #label        => $i18n->get('location'),
            #hoverHelp    => $i18n->get('location help'),
            defaultValue => '',
        },
        highlights => {
            fieldType    => 'text',  
            #label        => $i18n->get('highlights'),
            #hoverHelp    => $i18n->get('highlights help'),
            defaultValue => '',
        },
        story => {
            fieldType    => 'HTMLArea',  
            #label        => $i18n->get('highlights'),
            #hoverHelp    => $i18n->get('highlights help'),
            #richEditId  => $self->parent->getStoryRichEdit,
            defaultValue => '',
        },
        photo => {
            fieldType    => 'text',
            defaultValue => '',
        },
        storageId => {
            fieldType    => 'hidden',
            defaultValue => '',
            noFormPost   => 1,
        },
    );
    push(@{$definition}, {
        assetName         => $i18n->get('assetName'),
        icon              => 'assets.gif',
        tableName         => 'Story',
        className         => 'WebGUI::Asset::Story',
        properties        => \%properties,
        autoGenerateForms => 0,
    });
    return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 exportAssetData ( )

See WebGUI::AssetPackage::exportAssetData() for details.
Add the storage location to the export data.

=cut

sub exportAssetData {
	my $self = shift;
	my $data = $self->SUPER::exportAssetData;
	push(@{$data->{storage}}, $self->get("storageId")) if ($self->get("storageId") ne "");
	return $data;
}

#-------------------------------------------------------------------

=head2 getStorageLocation

Returns the storage location for this Story.  If it does not exist,
then it creates it via setStorageLocation.  Subsequent lookups return
an internally cached Storage object to save time.

=cut

sub getStorageLocation {
	my $self = shift;
	unless (exists $self->{_storageLocation}) {
		$self->setStorageLocation;
	}
	return $self->{_storageLocation};
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

Cleaning up storage objects in all revisions.

=cut

sub purge {
    my $self = shift;
    my $sth = $self->session->db->read("select storageId from Story where assetId=".$self->session->db->quote($self->getId));
    while (my ($storageId) = $sth->array) {
        WebGUI::Storage->get($self->session,$storageId)->delete;
	}
    $sth->finish;
    return $self->SUPER::purge;
}

#-------------------------------------------------------------------

=head2 purgeRevision

Remove the storage location for this revision of the Asset.

=cut

sub purgeRevision {
	my $self = shift;
	$self->getStorageLocation->delete;
	return $self->SUPER::purgeRevision;
}

#-------------------------------------------------------------------

=head2 setSize ( fileSize )

Set the size of this asset by including all the files in its storage
location. C<fileSize> is an integer of additional bytes to include in
the asset size.

=cut

sub setSize {
    my $self        = shift;
    my $fileSize    = shift || 0;
    my $storage     = $self->getStorageLocation;
    if (defined $storage) {	
        foreach my $file (@{$storage->getFiles}) {
            $fileSize += $storage->getFileSize($file);
        }
    }
    return $self->SUPER::setSize($fileSize);
}

#-------------------------------------------------------------------

=head2 setStorageLocation ( [ $storage] )

=head3 $storage

A storage location to use for this Story.

=cut

sub setStorageLocation {
    my $self    = shift;
    my $storage = shift;
    if (defined $storage) {
        $self->{_storageLocation} = $storage;
    }
    elsif ($self->get("storageId") eq "") {
        $self->{_storageLocation} = WebGUI::Storage->create($self->session);
        $self->update({storageId=>$self->{_storageLocation}->getId});
    }
    else {
        $self->{_storageLocation} = WebGUI::Storage->get($self->session,$self->get("storageId"));
    }
}

#-------------------------------------------------------------------

=head2 validParent

Make sure that the current session asset is a StoryArchive for pasting and adding checks.

This is a class method.

=cut

sub validParent {
    my $class   = shift;
    my $session = shift;
    return $session->asset && $session->asset->isa('WebGUI::Asset::Wobject::StoryArchive');
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the container www_view method. 

=cut

##Keyword cloud generated by WebGUI::Keyword

sub view {
    my $self = shift;
    my $var = $self->get; # $var is a hash reference.
    $var->{controls} = $self->getToolbar;
    return $self->processTemplate($var,undef, $self->{_viewTemplate});
}


#-------------------------------------------------------------------

=head2 www_edit ( )

Web facing method which is the default edit page.  Unless the method needs
special handling or formatting, it does not need to be included in
the module.

=cut

sub www_edit {
   my $self = shift;
   my $session = $self->session;
   return $session->privilege->insufficient() unless $self->canEdit;
   return $session->privilege->locked() unless $self->canEditIfLocked;
   my $i18n = WebGUI::International->new($session, 'Asset_NewAsset');
   return $self->getAdminConsole->render($self->getEditForm->print, $i18n->get('edit asset'));
}


1;

#vim:ft=perl
