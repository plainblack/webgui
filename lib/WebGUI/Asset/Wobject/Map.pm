package WebGUI::Asset::Wobject::Map;

$VERSION = "1.0.0";

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::IxHash;
use WebGUI::International;
use WebGUI::Utility;
use HTML::Entities qw(encode_entities);
use base 'WebGUI::Asset::Wobject';

# To get an installer for your wobject, add the Installable AssetAspect
# See WebGUI::AssetAspect::Installable and sbin/installClass.pl for more
# details

#-------------------------------------------------------------------

=head2 definition ( )

Define asset properties

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    my $definition = shift;
    my $i18n       = WebGUI::International->new( $session, 'Asset_Map' );

    my $googleApiKeyUrl = 'http://code.google.com/apis/maps/signup.html';
    my $googleApiKeyLink
        = q{<a href="%s" onclick="window.open('%s'); return false;">%s</a>};
    
    tie my %properties, 'Tie::IxHash', (
        groupIdAddPoint => {
            tab         => "security",
            fieldType   => "group",
            label       => $i18n->get("groupIdAddPoint label"),
            hoverHelp   => $i18n->get("groupIdAddPoint description"),
            defaultValue=> '2', # Registered users
        },
        mapApiKey       => {
            tab         => "properties",
            fieldType   => "text",
            label       => $i18n->get("mapApiKey label"),
            hoverHelp   => $i18n->get("mapApiKey description"),
            defaultValue=> $class->getDefaultApiKey($session),
            subtext     => sprintf($googleApiKeyLink, ($googleApiKeyUrl)x2, $i18n->get('mapApiKey link') ),
        },
        mapHeight       => {
            tab         => "display",
            fieldType   => "text",
            label       => $i18n->get("mapHeight label"),
            hoverHelp   => $i18n->get("mapHeight description"),
            defaultValue    => '400px',
        },
        mapWidth       => {
            tab         => "display",
            fieldType   => "text",
            label       => $i18n->get("mapWidth label"),
            hoverHelp   => $i18n->get("mapWidth description"),
            defaultValue    => '100%',
        },
        startLatitude   => {
            tab         => "display",
            fieldType   => "float",
            label       => $i18n->get("startLatitude label"),
            hoverHelp   => $i18n->get("startLatitude description"),
            defaultValue    => 43.074719,
        },
        startLongitude  => {
            tab         => "display",
            fieldType   => "float",
            label       => $i18n->get("startLongitude label"),
            hoverHelp   => $i18n->get("startLongitude description"),
            defaultValue    => -89.384251,
        },
        startZoom       => {
            tab         => "display",
            fieldType   => "intSlider",
            minimum     => 1,
            maximum     => 19,
            label       => $i18n->get("startZoom label"),
            hoverHelp   => $i18n->get("startZoom description"),
        },
        templateIdEditPoint => {
            tab         => "display",
            fieldType   => "template",
            namespace   => "MapPoint/Edit",
            label       => $i18n->get("templateIdEditPoint label"),
            hoverHelp   => $i18n->get("templateIdEditPoint description"),
        },
        templateIdView  => {
            tab         => "display",
            fieldType   => "template",
            namespace   => "Map/View",
            label       => $i18n->get("templateIdView label"),
            hoverHelp   => $i18n->get("templateIdView description"),
        },
        templateIdViewPoint => {
            tab         => "display",
            fieldType   => "template",
            namespace   => "MapPoint/View",
            label       => $i18n->get("templateIdViewPoint label"),
            hoverHelp   => $i18n->get("templateIdViewPoint description"),
        },
        workflowIdPoint => {
            tab         => "security",
            fieldType   => "workflow",
            label       => $i18n->get("workflowIdPoint label"),
            hoverHelp   => $i18n->get("workflowIdPoint description"),
            type        => 'WebGUI::VersionTag',
        },
    );
    push @{$definition}, {
        assetName         => $i18n->get('assetName'),
        icon              => 'maps.png',
        autoGenerateForms => 1,
        tableName         => 'Map',
        className         => 'WebGUI::Asset::Wobject::Map',
        properties        => \%properties
        };
    return $class->SUPER::definition( $session, $definition );
} ## end sub definition

#-------------------------------------------------------------------

=head2 canAddPoint ( [userId] )

Returns true if the user can add points to this map. C<userId> is the
ID of the user to check, defaults to the current user.

=cut

sub canAddPoint {
    my $self    = shift;
    my $userId  = shift;
    my $user    = $userId
                ? WebGUI::User->new( $self->session, $userId )
                : $self->session->user
                ;

    return $user->isInGroup( $self->get("groupIdAddPoint") );
}

#----------------------------------------------------------------------------

=head2 canEdit ( [userId] )

Returns true if the user can edit this Map. C<userId> is the userId to 
check. If no userId is passed, will check the current user.

Users can edit this map if they are part of the C<groupIdEdit> group.

Also checks if a user is adding a MapPoint and allows them to if they are
part of the C<groupIdAddPoint> group.

=cut

sub canEdit {
    my $self        = shift;
    my $userId      = shift;

    my $form        = $self->session->form;

    if ( $form->get('func') eq "add" && $form->get( 'class' )->isa( "WebGUI::Asset::MapPoint" ) ) {
        return $self->canAddPoint( $userId );
    }
    elsif ( $form->get('func') eq "editSave" && $form->get('assetId') eq "new" && $form->get( 'class' )->isa( 'WebGUI::Asset::MapPoint' ) ) {
        return $self->canAddPoint( $userId );
    }
    else {
        my $user        = $userId
                        ? WebGUI::User->new( $self->session, $userId )
                        : $self->session->user
                        ;
        
        return $user->isInGroup( $self->get("groupIdEdit") );
    }
}

#-------------------------------------------------------------------

=head2 getAllPoints ( )

Get all the MapPoints for this Map. Returns an array reference of 
asset IDs.

=cut

sub getAllPoints {
    my $self        = shift;
    
    my $assetIds    = $self->getLineage(['children']);
    return $assetIds;
}

#-------------------------------------------------------------------

=head2 getDefaultApiKey ( session )

Get the default API key for the Map.

=cut

sub getDefaultApiKey {
    my $class       = shift;
    my $session     = shift;

    # Get the API key used in other Maps on the site
    eval { # Map may not exist yet!
        my $defaultApiKey   = $session->db->quickScalar(
            "SELECT mapApiKey FROM Map LIMIT 1"
        );
        
        return $defaultApiKey;
    };
    return '';
}

#-------------------------------------------------------------------

=head2 getEditPointTemplate ( )

Get the template to edit a MapPoint. Returns a fully-prepared template

=cut 

sub getEditPointTemplate {
    my $self    = shift;
    
    if ( !$self->{_editPointTemplate} ) {
        my $templateId  = $self->get('templateIdEditPoint');
        my $template
            = WebGUI::Asset::Template->new( $self->session, $templateId );
        $template->prepare;
        $self->{_editPointTemplate} = $template;
    }
    
    return $self->{_editPointTemplate};
}

#-------------------------------------------------------------------

=head2 getViewPointTemplate ( )

Get the template to view a MapPoint. Returns a fully-prepared template
that can be used multiple times in a Map.

=cut 

sub getViewPointTemplate {
    my $self    = shift;
    
    if ( !$self->{_viewPointTemplate} ) {
        my $templateId  = $self->get('templateIdViewPoint');
        my $template
            = WebGUI::Asset::Template->new( $self->session, $templateId );
        $self->{_viewPointTemplate} = $template;
    }
    
    return $self->{_viewPointTemplate};
}

#-------------------------------------------------------------------

=head2 getTemplateVars ( )

Get the template variables for this asset

=cut

sub getTemplateVars {
    my $self    = shift;
    my $var     = {};

    $var->{ url         } = $self->getUrl;
    $var->{ canAddPoint } = $self->canAddPoint;
    $var->{ canEdit     } = $self->canEdit;

    return $var;
}

#-------------------------------------------------------------------

=head2 loadMapApiTags ( )

Load the Map API tags into the response. Load everything needed to 
create the map (but do not create the map itself).

This is seperate for timing purposes. This part can be loaded in the HEAD or
in the BODY, but the rest of the map must be loaded at a very specific
time.

=cut

sub loadMapApiTags {
    my $self    = shift;
    my $style   = $self->session->style;
    my $url     = $self->session->url;

    $style->setScript("http://www.google.com/jsapi?key=" . $self->get('mapApiKey'),{type=>"text/javascript"});
    $style->setRawHeadTags(<<'ENDHTML');
<script type="text/javascript">
    google.load("maps", "2", { "other_params" : "sensor=false" });
</script>
ENDHTML
    $style->setScript('http://gmaps-utility-library.googlecode.com/svn/trunk/markermanager/release/src/markermanager.js', {type=>"text/javascript"});
    $style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'),{type=>'text/javascript'});
    $style->setScript($url->extras('yui/build/connection/connection-min.js'),{type=>'text/javascript'});
    $style->setScript($url->extras('yui/build/json/json-min.js'),{type=>'text/javascript'});
    $style->setScript($url->extras('yui-webgui/build/map/map.js'),{type=>'text/javascript'});

    return;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self    = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->new( $self->session, $self->get("templateIdView") );
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->get("templateIdView"),
            assetId    => $self->getId,
        );
    }
    $template->prepare;
    $self->{_viewTemplate} = $template;
}

#-------------------------------------------------------------------

=head2 view ( )

method called by the www_view method.  Returns a processed template
to be displayed within the page style.  

=cut

sub view {
    my $self    = shift;
    my $session = $self->session;
    my $style   = $self->session->style;
    my $i18n    = WebGUI::International->new( $session, 'Asset_Map' );

    $self->loadMapApiTags;
    my $var     = $self->getTemplateVars;

    # Build the map container
    my $mapHtml = sprintf '<div id="map_%s" style="height: %s; width: %s"></div>', 
                    $self->getId,
                    $self->get('mapHeight'),
                    $self->get('mapWidth'),
                    ;

    # The script to load the map into the container
    $mapHtml    .= sprintf <<'ENDHTML', $self->getId, $self->getUrl, $self->get('startLatitude'), $self->get('startLongitude'), $self->get('startZoom');
<script type="text/javascript">
    google.setOnLoadCallback( function() {
        var mapId           = "%s";
        var mapUrl          = "%s";
        var map             = new GMap2( document.getElementById("map_" + mapId) );
        map.setCenter(new GLatLng(%s, %s), %s);
        map.setUIToDefault();

        var markermanager   = new MarkerManager(map, {trackMarkers: true});
ENDHTML

    
    # Load the map point info
    my $pointIds    = $self->getAllPoints;
    if ( @$pointIds ) {
        $mapHtml    .= <<'ENDHTML';
            var points          = [];
ENDHTML

        for my $pointId ( @{$pointIds} ) {
            my $point   = WebGUI::Asset->newByDynamicClass( $session, $pointId );
            next unless $point;
            $mapHtml    .= sprintf '        points.push(%s);'."\n", 
                            JSON->new->encode($point->getMapInfo),
                            ;

            push @{$var->{ mapPoints }}, $point->getTemplateVars;
        }

        $mapHtml    .= <<'ENDHTML';
            markermanager.addMarkers( WebGUI.Map.preparePoints(map, markermanager, mapUrl, points), 1 );
ENDHTML
    }

    $mapHtml    .= <<'ENDHTML';
        markermanager.refresh();

ENDHTML
;

    # If we need to focus on a point, do so
    if ( my $pointId = $session->form->get('focusOn') ) {
        $mapHtml    .= sprintf 'WebGUI.Map.focusOn("%s");'."\n", $pointId;
    }

    # Script to control addPoint and setPoint buttons
    $mapHtml    .= <<'ENDHTML';
        if ( document.getElementById( "setCenter_" + mapId ) ) {
            var button = document.getElementById( "setCenter_" + mapId );
            GEvent.addDomListener( button, "click", function () { 
                WebGUI.Map.setCenter( map, mapUrl );
            } );
        }
        if ( document.getElementById( "addPoint_" + mapId ) ) {
            var button = document.getElementById( "addPoint_" + mapId );
            GEvent.addDomListener( button, "click", function () {
                WebGUI.Map.editPoint( map, markermanager, mapUrl );
            } );
        }
    });
</script>
ENDHTML
    
    $var->{ map }   = $mapHtml;

    # Button to add a map point
    $var->{ button_addPoint }
        = WebGUI::Form::Button( $session, {
            value       => $i18n->get("add point label"),
            id          => sprintf( 'addPoint_%s', $self->getId ),
        } );

    # Button to set the map's default view
    $var->{ button_setCenter }
        = WebGUI::Form::Button( $session, {
            value       => $i18n->get("set default viewing area label"),
            id          => sprintf( 'setCenter_%s', $self->getId ),
        } );

    return $self->processTemplate( $var, undef, $self->{_viewTemplate} );
}

#-------------------------------------------------------------------

=head2 www_ajaxDeletePoint ( )

Immediately remove a point from the map.

=cut

sub www_ajaxDeletePoint {
    my ( $self ) = @_;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new( $session, 'Asset_Map' );
    my $assetId = $session->form->get('assetId');
    my $asset   = WebGUI::Asset->newByDynamicClass( $session, $assetId );
    $session->http->setMimeType('application/json');
    return JSON->new->encode({error => $i18n->get('error delete unauthorized')})
        unless $asset && $asset->canEdit;

    $asset->purge;
    return JSON->new->encode({message => $i18n->get('message delete success')});
}

#-------------------------------------------------------------------

=head2 www_ajaxEditPoint ( )

Get the form to edit a point to the map

=cut

sub www_ajaxEditPoint {
    my $self        = shift;
    my $session     = $self->session;
    my $form        = $self->session->form;
    
    my $asset;
    if ( $form->get('assetId') eq "new" ) {
        $asset  = WebGUI::Asset->newByPropertyHashRef( $session, {
            className       => "WebGUI::Asset::MapPoint",
        } );
    }
    else {
        $asset  = WebGUI::Asset->newByDynamicClass( $session, $form->get('assetId') );
    }
    
    my $output  = $self->getEditPointTemplate->process( $asset->getTemplateVarsEditForm );
    WebGUI::Macro::process( $session, \$output );
    $session->log->preventDebugOutput;
    return $output;
}

#-------------------------------------------------------------------

=head2 www_ajaxEditPointSave ( )

Process the form to edit a point to the map

=cut

sub www_ajaxEditPointSave {
    my $self        = shift;
    my $session     = $self->session;
    my $form        = $self->session->form;
    my $i18n        = WebGUI::International->new( $session, 'Asset_Map' );

    # We're returning as HTML because application/json causes download pop-up
    # and text/plain causes <pre>...</pre> in firefox
    $session->http->setMimeType("text/html"); 
    $session->log->preventDebugOutput;

    my $assetId     = $form->get('assetId');
    my $asset;
    if ( $assetId eq "new" ) {
        return JSON->new->encode({message => $i18n->get("error add unauthorized")})
            unless $self->canAddPoint;

        $asset  = $self->addChild( {
            className   => 'WebGUI::Asset::MapPoint',
        } );
    }
    else {
        $asset  = WebGUI::Asset->newByDynamicClass( $session, $assetId );
        return JSON->new->encode({message => $i18n->get("error edit unauthorized")})
            unless $asset && $asset->canEdit;
        $asset  = $asset->addRevision;
    }
    
    my $errors  = $asset->processAjaxEditForm;

    # Commit!
    if ($asset->getAutoCommitWorkflowId && $self->hasBeenCommitted) {
        $asset->requestAutoCommit;
    }

    # Encode entities because we're returning as HTML
    return encode_entities( JSON->new->encode($asset->getMapInfo) );
}

#-------------------------------------------------------------------

=head2 www_ajaxSetCenter ( )

Set the center of the map, ajax-style.

=cut

sub www_ajaxSetCenter {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $self->session->form;
    my $i18n    = WebGUI::International->new( $session, 'Asset_Map' );

    $session->http->setMimeType("application/json");

    return JSON->new->encode({message => $i18n->get("error set center unauthorized")})
        unless $self->canEdit;

    $self->update({
        startLatitude   => $form->get("startLatitude"),
        startLongitude  => $form->get("startLongitude"),
        startZoom       => $form->get("startZoom"),
    });

    return JSON->new->encode({message => $i18n->get("message set center success")});
}

#-------------------------------------------------------------------

=head2 www_ajaxSetPointLocation ( )

Set the location of a point

=cut

sub www_ajaxSetPointLocation {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $self->session->form;
    my $i18n    = WebGUI::International->new( $session, 'Asset_Map' );

    $session->http->setMimeType("application/json");
    
    my $assetId = $form->get('assetId');
    my $asset   = WebGUI::Asset->newByDynamicClass( $session, $assetId );
    return JSON->new->encode({message => $i18n->get("error edit unauthorized")})
        unless $asset && $asset->canEdit;
    $asset->update( {
        latitude    => $form->get('latitude'),
        longitude   => $form->get('longitude'),
    } );

    return JSON->new->encode( {message => $i18n->get("message set point location")} ); 
}

1;

#vim:ft=perl
