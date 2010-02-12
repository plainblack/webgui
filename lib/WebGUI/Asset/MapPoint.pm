package WebGUI::Asset::MapPoint;

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
use Tie::IxHash;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset';
aspect assetName         => ['assetName', 'Asset_MapPoint'];
aspect icon              => 'MapPoint.gif';
aspect tableName         => 'MapPoint';
property latitude => (
            tab         => "properties",
            fieldType   => "float",
            label       => ["latitude label", 'Asset_MapPoint'],
            hoverHelp   => ["latitude description", 'Asset_MapPoint'],
         );
property longitude => (
            tab         => "properties",
            fieldType   => "float",
            label       => ["longitude label", 'Asset_MapPoint'],
            hoverHelp   => ["longitude description", 'Asset_MapPoint'],
         );
property website => (
            tab         => "properties",
            fieldType   => "text",
            label       => ["website label", 'Asset_MapPoint'],
            hoverHelp   => ["website description", 'Asset_MapPoint'],
         );
property address1 => (
            tab         => "properties",
            fieldType   => "text",
            label       => ["address1 label", 'Asset_MapPoint'],
            hoverHelp   => ["address1 description", 'Asset_MapPoint'],
         );
property address2 => (
            tab         => "properties",
            fieldType   => "text",
            label       => ["address2 label", 'Asset_MapPoint'],
            hoverHelp   => ["address2 description", 'Asset_MapPoint'],
         );
property city => (
            tab         => "properties",
            fieldType   => "text",
            label       => ["city label", 'Asset_MapPoint'],
            hoverHelp   => ["city description", 'Asset_MapPoint'],
         );
property state => (
            tab         => "properties",
            fieldType   => "text",
            label       => ["state label", 'Asset_MapPoint'],
            hoverHelp   => ["state description", 'Asset_MapPoint'],
         );
property zipCode => (
            tab         => "properties",
            fieldType   => "text",
            label       => ["zipCode label", 'Asset_MapPoint'],
            hoverHelp   => ["zipCode description", 'Asset_MapPoint'],
         );
property country => (
            tab         => "properties",
            fieldType   => "country",
            label       => ["country label", 'Asset_MapPoint'],
            hoverHelp   => ["country description", 'Asset_MapPoint'],
         );
property phone => (
            tab         => "properties",
            fieldType   => "phone",
            label       => ["phone label", 'Asset_MapPoint'],
            hoverHelp   => ["phone description", 'Asset_MapPoint'],
         );
property fax => (
            tab         => "properties",
            fieldType   => "phone",
            label       => ["fax label", 'Asset_MapPoint'],
            hoverHelp   => ["fax description", 'Asset_MapPoint'],
         );
property email => (
            tab         => "properties",
            fieldType   => "email",
            label       => ["email label", 'Asset_MapPoint'],
            hoverHelp   => ["email description", 'Asset_MapPoint'],
         );
property storageIdPhoto => (
            tab             => "properties",
            fieldType       => "image",
            forceImageOnly  => 1,
            label           => ["storageIdPhoto label", 'Asset_MapPoint'],
            hoverHelp       => ["storageIdPhoto description", 'Asset_MapPoint'],
            noFormPost      => 1,
         );
property userDefined1 => (
            fieldType       => "hidden",
            noFormPost      => 1,
         );
property userDefined2 => (
            fieldType       => "hidden",
            noFormPost      => 1,
         );
property userDefined3 => (
            fieldType       => "hidden",
            noFormPost      => 1,
         );
property userDefined4 => (
            fieldType       => "hidden",
            noFormPost      => 1,
         );
property userDefined5 => (
            fieldType       => "hidden",
            noFormPost      => 1,
         );

use WebGUI::Utility;

=head1 NAME

Package WebGUI::Asset::MapPoint

=head1 DESCRIPTION

Describe your New Asset's functionality and features here.

=head1 SYNOPSIS

use WebGUI::Asset::MapPoint;


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
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, "Asset_MapPoint" );
    tie my %properties, 'Tie::IxHash', (
    );
    push @{$definition}, {
        className         => 'WebGUI::Asset::MapPoint',
        properties        => \%properties,
        };
    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

#-------------------------------------------------------------------

=head2 canEdit ( [userId] )

Returns true if the user can edit this MapPoint. Only the owner or the
group to edit the parent Map are allowed to edit MapPoint.

=cut

sub canEdit {
    my $self    = shift;
    my $userId  = shift || $self->session->user->userId;
    return 1 if $userId eq $self->ownerUserId;
    return $self->SUPER::canEdit( $userId );
}

#-------------------------------------------------------------------

=head2 getAutoCommitWorkflowId ( )

Get the workflowId to commit this MapPoint

=cut

sub getAutoCommitWorkflowId {
    my ( $self ) = @_;
    return $self->getParent->workflowIdPoint;
}

#-------------------------------------------------------------------

=head2 getMapInfo ( )

Get a hash of info to be put into the parent Map. Must include 
AT LEAST the following keys:

    assetId         - The ID of the MapPoint
    latitude        - The latitude of the point
    longitude       - The longitude of the point
    title           - The title of the point
    content         - HTML content to show details about the point
    url             - The URL of the point

The following keys are optional

    canEdit         - If true, the user is allowed to edit the MapPoint


=cut

sub getMapInfo {
    my $self    = shift;
    my $var     = {}; 
    
    # Get asset properties
    $var->{ url         } = $self->getUrl;
    $var->{ assetId     } = $self->getId;
    my @keys    = qw( latitude longitude title );
    for my $key ( @keys ) {
        $var->{ $key } = $self->$key;
    }

    # Get permissions
    $var->{ canEdit } = $self->canEdit;

    # Process the template to get the content
    my $template    = $self->getParent->getViewPointTemplate;
    $var->{ content } = $template->process( $self->getTemplateVars );
    WebGUI::Macro::process( $self->session, \$var->{content} );

    return $var;
}

#-------------------------------------------------------------------

=head2 getTemplateVars ( )

Get common template vars for this MapPoint

=cut

sub getTemplateVars {
    my $self    = shift;
    my $var     = $self->get;
    
    # Add gateway to URL
    $var->{ url } = $self->getUrl;

    return $var;
}

#-------------------------------------------------------------------

=head2 getTemplateVarsEditForm ( )

Get the template vars for the MapPoint edit form

=cut

sub getTemplateVarsEditForm {
    my $self    = shift;
    my $session = $self->session;
    my $var     = $self->getTemplateVars;

    $var->{ form_header } 
        = WebGUI::Form::formHeader( $session )
        . WebGUI::Form::hidden( $session, { 
            name    => 'func', 
            value   => 'ajaxEditPointSave',
        } )
        . WebGUI::Form::hidden( $session, {
            name    => 'assetId',
            value   => $self->getId,
            defaultValue => 'new',
        } )
        . WebGUI::Form::hidden( $session, {
            name    => 'latitude',
            value   => $self->latitude,
        } )
        . WebGUI::Form::hidden( $session, {
            name    => 'longitude',
            value   => $self->longitude,
        } )
        ;
    $var->{ form_footer } = WebGUI::Form::formFooter( $session );

    $var->{ form_save } = WebGUI::Form::submit( $session, {
        name        => "save",
    } );

    # Stuff from this class's definition
    my $definition  = __PACKAGE__->definition($session)->[0]->{properties};
    for my $key ( keys %{$definition} ) {
        next if $definition->{$key}->{noFormPost};
        $definition->{$key}->{name}     = $key;
        $definition->{$key}->{value}    = $self->getValue($key);
        $var->{ "form_$key" } 
            = WebGUI::Form::dynamicField( $session, %{$definition->{$key}} );
    }
    
    # Stuff from Asset
    $var->{ "form_title" }
        = WebGUI::Form::text( $session, {
            name        => "title",
            value       => $self->title,
        } );
    $var->{ "form_synopsis" }
        = WebGUI::Form::textarea( $session, {
            name        => "synopsis",
            value       => $self->synopsis,
            resizable   => 0,
        } );	

    # Fix storageIdPhoto because scripts do not get executed in ajax requests
    $var->{ "form_storageIdPhoto" }
	= '<input type="file" name="storageIdPhoto" />';
    if ( $self->storageIdPhoto ) {
        my $storage = WebGUI::Storage->get( $self->session, $self->storageIdPhoto );        
        $var->{ "currentPhoto" }
	    = sprintf '<img src="%s" />', $storage->getUrl($storage->getFiles->[0]);
    }

    return $var;
}

#-------------------------------------------------------------------

=head2 processAjaxEditForm ( )

Process the Ajax Edit Form from the Map. If any errors occur, return
an array reference of error messages.

=cut

sub processAjaxEditForm {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $self->session->form;
    my $prop    = {};

    # Stuff from this class's definition
    my $definition = __PACKAGE__->definition($session)->[0]->{properties};
    for my $key ( keys %{$definition} ) {
        my $field   = $definition->{$key};
        next if $field->{noFormPost};
        $prop->{$key}
            = $form->get($key,$field->{fieldType},$field->{defaultValue},$field);    
    }
    
    # Stuff from Asset
    $prop->{ title          } = $form->get('title');
    $prop->{ menuTitle      } = $form->get('title');
    $prop->{ synopsis       } = $form->get('synopsis');
    $prop->{ url            } = $session->url->urlize( $self->getParent->getUrl . '/' . $prop->{title} );
    $prop->{ ownerUserId    } = $form->get('ownerUserId') || $session->user->userId;
    
    $self->update( $prop );

    # Photo magic
    if ( $form->get('storageIdPhoto') ) {
        my $storage;
        if ( $self->storageIdPhoto ) {
            $storage = WebGUI::Storage->get( $session, $self->storageIdPhoto );
            $storage->deleteFile( $storage->getFiles->[0] );
        }
        else {
            $storage = WebGUI::Storage->create( $session );
            $self->update({ storageIdPhoto => $storage->getId });
        }

        $storage->addFileFromFormPost( 'storageIdPhoto', 1 );
    }

    return;
}

#-------------------------------------------------------------------

=head2 view ( )

Get the content to show in the map text box. This will not be called
by www_view, but we may want to call it elsewhere for some reason.

=cut

sub view {
    my $self = shift;
    return "TODO";
}

#-------------------------------------------------------------------

=head2 www_view ( )

Redirect the user to the correct Map with the appropriate focus point
so that this point is automatically shown.

=cut

sub www_view {
    my $self    = shift;

    $self->session->http->setRedirect( 
        $self->getParent->getUrl('focusOn=' . $self->getId )
    );
    return "redirect";
}

1;

#vim:ft=perl
