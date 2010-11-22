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
use WebGUI::International;
use HTML::Entities qw(encode_entities);
use Moose;
use WebGUI::Definition::Asset;
extends 'WebGUI::Asset::Wobject';
define assetName         => ['assetName', 'Asset_Map'];
define icon              => 'maps.png';
define tableName         => 'Map';
property groupIdAddPoint => (
            tab         => "security",
            fieldType   => "group",
            label       => ["groupIdAddPoint label", 'Asset_Map'],
            hoverHelp   => ["groupIdAddPoint description", 'Asset_Map'],
            default     => '2', # Registered users
         );
property mapApiKey => (
            tab         => "properties",
            fieldType   => "text",
            label       => ["mapApiKey label", 'Asset_Map'],
            hoverHelp   => ["mapApiKey description", 'Asset_Map'],
            builder     => '_mapApiKey_builder',
            lazy        => 1,
            subtext     => \&_mapApiKey_subtext,
         );
sub _mapApiKey_builder {
    my $self = shift;
    return $self->getDefaultApiKey($self->session);
}
sub _mapApiKey_subtext {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session, 'Asset_Map');
    my $googleApiKeyUrl = 'http://code.google.com/apis/maps/signup.html';
    my $googleApiKeyLink
        = q{<a href="%s" onclick="window.open('%s'); return false;">%s</a>};
    return sprintf($googleApiKeyLink, ($googleApiKeyUrl)x2, $i18n->get('mapApiKey link') );
}
property mapHeight => (
            tab         => "display",
            fieldType   => "text",
            label       => ["mapHeight label", 'Asset_Map'],
            hoverHelp   => ["mapHeight description", 'Asset_Map'],
            default     => '400px',
         );
property mapWidth => (
            tab         => "display",
            fieldType   => "text",
            label       => ["mapWidth label", 'Asset_Map'],
            hoverHelp   => ["mapWidth description", 'Asset_Map'],
            default     => '100%',
         );
property startLatitude => (
            tab         => "display",
            fieldType   => "float",
            label       => ["startLatitude label", 'Asset_Map'],
            hoverHelp   => ["startLatitude description", 'Asset_Map'],
            default     => 43.074719,
         );
property startLongitude => (
            tab         => "display",
            fieldType   => "float",
            label       => ["startLongitude label", 'Asset_Map'],
            hoverHelp   => ["startLongitude description", 'Asset_Map'],
            default     => -89.384251,
         );
property startZoom => (
            tab         => "display",
            fieldType   => "intSlider",
            minimum     => 1,
            maximum     => 19,
            label       => ["startZoom label", 'Asset_Map'],
            hoverHelp   => ["startZoom description", 'Asset_Map'],
            default     => 1,
         );
property templateIdEditPoint => (
            tab         => "display",
            fieldType   => "template",
            namespace   => "MapPoint/Edit",
            default     => 'oHh0UqAJeY7u2n--WD-BAA',
            label       => ["templateIdEditPoint label", 'Asset_Map'],
            hoverHelp   => ["templateIdEditPoint description", 'Asset_Map'],
         );
property templateIdView => (
            tab         => "display",
            fieldType   => "template",
            namespace   => "Map/View",
            default     => '9j0_Z1j3Jd0QBbY2akb6qw',
            label       => ["templateIdView label", 'Asset_Map'],
            hoverHelp   => ["templateIdView description", 'Asset_Map'],
         );
property templateIdViewPoint => (
            tab         => "display",
            fieldType   => "template",
            namespace   => "MapPoint/View",
            default     => 'u9vfx33XDk5la1-QC5FK7g',
            label       => ["templateIdViewPoint label", 'Asset_Map'],
            hoverHelp   => ["templateIdViewPoint description", 'Asset_Map'],
         );
property workflowIdPoint => (
            tab         => "security",
            fieldType   => "workflow",
            label       => ["workflowIdPoint label", 'Asset_Map'],
            hoverHelp   => ["workflowIdPoint description", 'Asset_Map'],
            type        => 'WebGUI::VersionTag',
            default     => "pbworkflow000000000003",
         );

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

    return $user->isInGroup( $self->groupIdAddPoint );
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
        
        return $user->isInGroup( $self->groupIdEdit );
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
        my $templateId  = $self->templateIdEditPoint;
        my $template
            = WebGUI::Asset::Template->newById( $self->session, $templateId );
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
        my $templateId  = $self->templateIdViewPoint;
        my $template
            = WebGUI::Asset::Template->newById( $self->session, $templateId );
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

    $style->setCss($url->extras('yui/build/container/assets/skins/sam/container.css'));
    $style->setCss($url->extras('yui/build/button/assets/skins/sam/button.css'));
    $style->setScript("http://www.google.com/jsapi?key=" . $self->mapApiKey);
    $style->setRawHeadTags(<<'ENDHTML');
<script type="text/javascript">
    google.load("maps", "2", { "other_params" : "sensor=false" });
</script>
ENDHTML
    $style->setScript('http://gmaps-utility-library.googlecode.com/svn/trunk/markermanager/release/src/markermanager.js');
    $style->setScript($url->extras('yui/build/yahoo-dom-event/yahoo-dom-event.js'));
    $style->setScript($url->extras('yui/build/connection/connection-min.js'));
    $style->setScript($url->extras('yui/build/dragdrop/dragdrop-min.js'));
    $style->setScript($url->extras('yui/build/element/element-min.js'));
    $style->setScript($url->extras('yui/build/button/button-min.js'));
    $style->setScript($url->extras('yui/build/container/container-min.js'));
    $style->setScript($url->extras('yui/build/json/json-min.js'));
    $style->setScript($url->extras('yui-webgui/build/map/map.js'));

    return;
}

#-------------------------------------------------------------------

=head2 prepareView ( )

See WebGUI::Asset::prepareView() for details.

=cut

sub prepareView {
    my $self    = shift;
    $self->SUPER::prepareView();
    my $template = WebGUI::Asset::Template->newById( $self->session, $self->templateIdView );
    if (!$template) {
        WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => $self->templateIdView,
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
                    $self->mapHeight,
                    $self->mapWidth,
                    ;

    # The script to load the map into the container
    $mapHtml    .= sprintf <<'ENDHTML', $self->getId, $self->getUrl, $self->startLatitude, $self->startLongitude, $self->startZoom, $session->url->extras;
<script type="text/javascript">
    google.setOnLoadCallback( function() {
        var mapId           = "%s";
        var mapUrl          = "%s";
        var map             = new GMap2( document.getElementById("map_" + mapId) );
        map.url             = mapUrl;
        map.assetId         = mapId;
        map.setCenter(new GLatLng(%s, %s), %s);
        map.setUIToDefault();
        map.extrasUrl       = "%s";

        var markermanager   = new MarkerManager(map, {trackMarkers: true});
ENDHTML

    
    # Load the map point info
    my $pointIds    = $self->getAllPoints;
    if ( @$pointIds ) {
        $mapHtml    .= <<'ENDHTML';
            var points          = [];
ENDHTML

        for my $pointId ( @{$pointIds} ) {
            my $point   = WebGUI::Asset->newById( $session, $pointId );
            next unless $point;
            $mapHtml    .= sprintf '        points.push(%s);'."\n", 
                            JSON->new->encode($point->getMapInfo),
                            ;

            push @{$var->{ mapPoints }}, $point->getTemplateVars;
        }

        $mapHtml    .= <<'ENDHTML';
            markermanager.addMarkers( WebGUI.Map.preparePoints(map, markermanager, points), 0 );
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
                WebGUI.Map.setCenter( map );
            } );
        }
        if ( document.getElementById( "addPoint_" + mapId ) ) {
            var button = document.getElementById( "addPoint_" + mapId );
            GEvent.addDomListener( button, "click", function () {
                WebGUI.Map.editPoint( map, markermanager );
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

    # Select box to choose a map point
    tie my %selectPointOptions, 'Tie::IxHash', (
        ""      => '-- ' . $i18n->get('select a point'),
    );
    if ( $var->{mapPoints} ) {
        for my $point ( sort { $a->{title} cmp $b->{title} } @{$var->{mapPoints}} ) {
            $selectPointOptions{ $point->{assetId} } = $point->{title}; 
        }
    }
    $var->{ selectPoint }
        = WebGUI::Form::selectBox( $session, {
            extras      => q{onchange="WebGUI.Map.focusOn(this.options[this.selectedIndex].value);"},
            id          => sprintf( q{selectPoint_%s}, $self->getId ),
            options     => \%selectPointOptions,
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
    my $asset   = WebGUI::Asset->newById( $session, $assetId );
    $session->response->content_type('application/json');
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
        $asset  = WebGUI::Asset->newById( $session, $form->get('assetId') );
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
    $session->response->content_type("text/html"); 
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
        $asset  = WebGUI::Asset->newById( $session, $assetId );
        return JSON->new->encode({message => $i18n->get("error edit unauthorized")})
            unless $asset && $asset->canEdit;
        $asset  = $asset->addRevision;
    }
    
    my $errors  = $asset->processAjaxEditForm;

    # Commit!
    if ( $asset->getAutoCommitWorkflowId ) {
        if ( $self->hasBeenCommitted) {
            $asset->requestAutoCommit;
        }
        else {
            # Add mappoint to map's version tag
            my $oldTagId = $asset->get('tagId');
            $asset->setVersionTag( $self->get('tagId') );
            my $oldTag = WebGUI::VersionTag->new( $session, $oldTagId );
            if ( $oldTag->getAssetCount <= 0 ) {
                $oldTag->rollback;
            }
        }
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

    $session->response->content_type("application/json");

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

    $session->response->content_type("application/json");
    
    my $assetId = $form->get('assetId');
    my $asset   = WebGUI::Asset->newById( $session, $assetId );
    return JSON->new->encode({message => $i18n->get("error edit unauthorized")})
        unless $asset && $asset->canEdit;
    $asset->update( {
        latitude    => $form->get('latitude'),
        longitude   => $form->get('longitude'),
    } );

    return JSON->new->encode( {message => $i18n->get("message set point location")} ); 
}

__PACKAGE__->meta->make_immutable;
1;

#vim:ft=perl
