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
use base 'WebGUI::AssetAspect::Installable','WebGUI::Asset';
use WebGUI::Utility;

# To get an installer for your wobject, add the Installable AssetAspect
# See WebGUI::AssetAspect::Installable and sbin/installClass.pl for more
# details

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
        latitude    => {
            tab         => "properties",
            fieldType   => "float",
            label       => $i18n->echo("Latitude"),
            hoverHelp   => $i18n->echo("The latitude of the point"),
            noFormPost  => 1,
        },
        longitude   => {
            tab         => "properties",
            fieldType   => "float",
            label       => $i18n->echo("Longitude"),
            hoverHelp   => $i18n->echo("The longitude of the point"),
            noFormPost  => 1,
        },
        website     => {
            tab         => "properties",
            fieldType   => "text",
            label       => $i18n->echo("Website"),
            hoverHelp   => $i18n->echo("The URL to the location's website"),
        },
        address1    => {
            tab         => "properties",
            fieldType   => "text",
            label       => $i18n->echo("Address 1"),
            hoverHelp   => $i18n->echo("The first line of the address"),
        },
        address2    => {
            tab         => "properties",
            fieldType   => "text",
            label       => $i18n->echo("Address 2"),
            hoverHelp   => $i18n->echo("The second line of the address"),
        },
        city        => {
            tab         => "properties",
            fieldType   => "text",
            label       => $i18n->echo("City"),
            hoverHelp   => $i18n->echo("The city the point is located in"),
        },
        state       => {
            tab         => "properties",
            fieldType   => "text",
            label       => $i18n->echo("State/Province"),
            hoverHelp   => $i18n->echo("The state/provice the point is located in"),
        },
        zipCode     => {
            tab         => "properties",
            fieldType   => "text",
            label       => $i18n->echo("Zip/Postal Code"),
            hoverHelp   => $i18n->echo("The zip/postal code the point is located in"),
        },
        country     => {
            tab         => "properties",
            fieldType   => "country",
            label       => $i18n->echo("Country"),
            hoverHelp   => $i18n->echo("The country the point is located in"),
        },
        phone       => {
            tab         => "properties",
            fieldType   => "phone",
            label       => $i18n->echo("Phone"),
            hoverHelp   => $i18n->echo("The phone number of the location"),
        },
        fax         => {
            tab         => "properties",
            fieldType   => "phone",
            label       => $i18n->echo("Fax"),
            hoverHelp   => $i18n->echo("The fax number of the location"),
        },
        email       => {
            tab         => "properties",
            fieldType   => "email",
            label       => $i18n->echo("E-mail"),
            hoverHelp   => $i18n->echo("The e-mail address of the location"),
        },
        storageIdPhoto       => {
            tab             => "properties",
            fieldType       => "image",
            forceImageOnly  => 1,
            label           => $i18n->echo("Photo"),
            hoverHelp       => $i18n->echo("A photo of the location"),
            noFormPost      => 1,
        },
        userDefined1 => {
            fieldType       => "hidden",
        },
        userDefined2 => {
            fieldType       => "hidden",
        },
        userDefined3 => {
            fieldType       => "hidden",
        },
        userDefined4 => {
            fieldType       => "hidden",
        },
        userDefined5 => {
            fieldType       => "hidden",
        },
    );
    push @{$definition}, {
        assetName         => $i18n->get('assetName'),
        icon              => 'MapPoint.gif',
        autoGenerateForms => 1,
        tableName         => 'MapPoint',
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
    return 1 if $userId eq $self->get('ownerUserId');
    return $self->SUPER::canEdit( $userId );
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
        $var->{ $key } = $self->get( $key );
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
        ;
    $var->{ form_footer } = WebGUI::Form::formFooter( $session );

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
            value       => $self->get("title"),
        } );
    $var->{ "form_synopsis" }
        = WebGUI::Form::textarea( $session, {
            name        => "synopsis",
            value       => $self->get("synopsis"),
            resizable   => 0,
        } );	

    # Fix storageIdPhoto because scripts do not get executed in ajax requests
    $var->{ "form_storageIdPhoto" }
	= '<input type="file" name="storageIdPhoto" />';
    if ( $self->get('storageIdPhoto') ) {
        my $storage = WebGUI::Storage->get( $self->session, $self->get('storageIdPhoto') );        
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
    $session->log->info("BEEP!");
    if ( $form->get('storageIdPhoto') ) {
        $session->log->info("BOOP!");
        my $storage;
        if ( $self->get('storageIdPhoto') ) {
            $storage = WebGUI::Storage->get( $session, $self->get('storageIdPhoto') );
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
