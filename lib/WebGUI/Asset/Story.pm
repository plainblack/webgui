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

Make sure that Stories are always hidden from navigation.

=cut

sub addRevision {
    my $self = shift;
    my $newSelf = $self->next::method(@_);
    $newSelf->update({
        isHidden => 1,
    });
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
        }
    );
    push(@{$definition}, {
        assetName         => $i18n->get('assetName'),
        icon              => 'assets.gif',
        autoGenerateForms => 1,
        tableName         => 'Story',
        className         => 'WebGUI::Asset::Story',
        properties        => \%properties,
        autoGenerateForms => 0,
    });
    return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 indexContent ( )

Making private. See WebGUI::Asset::indexContent() for additonal details. 

=cut

sub indexContent {
    my $self = shift;
    my $indexer = $self->SUPER::indexContent;
    $indexer->setIsPublic(0);
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

Cleaning up storage objects.

=cut

sub purge {
    my $self = shift;
    return $self->SUPER::purge;
}

#-------------------------------------------------------------------
=head2 view ( )

method called by the container www_view method. 

=cut

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
