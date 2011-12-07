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
use Moose;
use WebGUI::Definition::Asset;
use Geo::Coder::Googlev3;

extends 'WebGUI::Asset';
define assetName         => ['assetName', 'Asset_MapPoint'];
define icon              => 'mappoint.png';
define tableName         => 'MapPoint';
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
property region => (
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
property isGeocoded   => (
            fieldType       => "yesNo",
            tab             => "properties",
            label           => ["isGeocoded label",'Asset_MapPoint'],
            hoverHelp       => ["isGeocoded description",'Asset_MapPoint'],
        );

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

=head2 canEdit ( [userId] )

Returns true if the user can edit this MapPoint. Only the owner or the
group to edit the parent Map are allowed to edit MapPoint.

=cut

around canEdit => sub {
    my $orig    = shift;
    my $self    = shift;
    my $userId  = shift || $self->session->user->userId;
    return 1 if $userId eq $self->ownerUserId;
    return $self->$orig( $userId );
};

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
    userDefined1-5  - The userDefined fields 

The following keys are optional

    canEdit         - If true, the user is allowed to edit the MapPoint


=cut

sub getMapInfo {
    my $self    = shift;
    my $var     = {}; 
    
    # Get asset properties
    $var->{ url         } = $self->getUrl;
    $var->{ assetId     } = $self->getId;
    my @keys    = qw( latitude longitude title userDefined1 userDefined2 userDefined3 userDefined4 userDefined5 isGeocoded );
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

    my $parent  = $self->getParent;
    #If it's a new point, we have to get the parent from the url
    unless ($parent) {
        my $url = $session->url->page;
        $parent = WebGUI::Asset->newByUrl($session,$url);
    }

    $var->{'can_edit_map'} = $parent->canEdit;

    $var->{ form_header } 
        = WebGUI::Form::formHeader( $session )
        . WebGUI::Form::Hidden->new( $session, { 
            name    => 'func', 
            value   => 'ajaxEditPointSave',
        } )->toHtml
        . WebGUI::Form::Hidden->new( $session, {
            name    => 'assetId',
            value   => $self->getId,
            defaultValue => 'new',
        } )->toHtml
        . WebGUI::Form::Hidden->new( $session, {
            name    => 'latitude',
            value   => $self->latitude,
        } )->toHtml
        . WebGUI::Form::Hidden->new( $session, {
            name    => 'longitude',
            value   => $self->longitude,
        } )->toHtml
        ;
    $var->{ form_footer } = WebGUI::Form::formFooter( $session );

    $var->{ form_save } = WebGUI::Form::submit( $session, {
        name        => "save",
    } );

    # Stuff from this class's definition
    foreach my $key ( $self->getProperties ) {
        my $fieldHash = $self->getFieldData( $key );
        next if $fieldHash->{noFormPost};
        next if $key eq 'latitude' 
             || $key eq 'longitude';
        $var->{ "form_$key" } 
            = WebGUI::Form::dynamicField( $session, $fieldHash );
    }
    
    # Stuff from Asset
    $var->{ "form_title" }
        = WebGUI::Form::Text->new( $session, {
            name        => "title",
            value       => $self->title,
        } )->toHtml;
    $var->{ "form_synopsis" }
        = WebGUI::Form::Textarea->new( $session, {
            name        => "synopsis",
            value       => $self->synopsis,
            resizable   => 0,
        } )->toHtml;

    #Only allow people who can edit the parent to change isHidden
    if($var->{'can_edit_map'}) {
        my $isHidden = (defined $self->get("isHidden")) ? $self->get("isHidden") : 1;
        $var->{ "form_isHidden" }
            = WebGUI::Form::YesNo->toHtml( $session, {
                name        => "isHidden",
                value       => $isHidden,
            } )->toHtml;
    }
    
    my $isGeocoded = ( $self->getId ) ? $self->get("isGeocoded") : 1;
    $var->{"form_isGeocoded"}
        = WebGUI::Form::Checkbox->new( $session, {
            name        => "isGeocoded",
            value       => 1,
            checked     => $isGeocoded
        } )->toHtml;
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

=head2 indexContent ( )

Indexing the content of attachments and user defined fields. See WebGUI::Asset::indexContent() for additonal details.

=cut

override indexContent => sub {
    my $self = shift;
    my $indexer = super();
    $indexer->addKeywords($self->get("website"));
    $indexer->addKeywords($self->get("address1"));
    $indexer->addKeywords($self->get("address2"));
    $indexer->addKeywords($self->get("city"));
    $indexer->addKeywords($self->get("region"));
    $indexer->addKeywords($self->get("zipCode"));
    $indexer->addKeywords($self->get("country"));
    $indexer->addKeywords($self->get("phone"));
    $indexer->addKeywords($self->get("fax"));
    $indexer->addKeywords($self->get("email"));
    $indexer->addKeywords($self->get("userDefined1"));
    $indexer->addKeywords($self->get("userDefined2"));
    $indexer->addKeywords($self->get("userDefined3"));
    $indexer->addKeywords($self->get("userDefined4"));
    $indexer->addKeywords($self->get("userDefined5"));
    return $indexer;
};

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
    for my $key ( $self->getProperties ) {
        my $field   = $self->getFieldData( $key );
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
    #Only users who can edit the map can set this property
    if($self->getParent->canEdit) {
        $prop->{ isHidden       } = $form->get('isHidden');
    }
    $prop->{isGeocoded      } = $form->get('isGeocoded') || 0;
    if($prop->{isGeocoded} &&
        (
               ( $form->get("address1") ne $self->get("address1") )
            || ( $form->get("address2") ne $self->get("address2") )
            || ( $form->get("city") ne $self->get("city") )
            || ( $form->get("region") ne $self->get("region") )
            || ( $form->get("zipCode") ne $self->get("zipCode") )
            || ( $form->get("country") ne $self->get("country") )
        )
    ) {
        my $geocoder = Geo::Coder::Googlev3->new;
        my $address_str   = $form->get("address1");
        $address_str     .= " ".$form->get("address2") if($form->get("address2"));
        $address_str     .= ", ".$form->get("city").", ".$form->get("region").", ".$form->get("zipCode").", ".$form->get("country");
        my $location = $geocoder->geocode( location => $address_str );
        $prop->{latitude } = $location->{geometry}->{location}->{lat};
        $prop->{longitude} = $location->{geometry}->{location}->{lng};
    }
    
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

    $self->session->response->setRedirect( 
        $self->getParent->getUrl('focusOn=' . $self->getId )
    );
    return "redirect";
}

__PACKAGE__->meta->make_immutable;
1;

#vim:ft=perl
