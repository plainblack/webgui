// Initialize namespace
if (typeof WebGUI == "undefined") {
    var WebGUI = {};
}
if (typeof WebGUI.Map == "undefined") {
    WebGUI.Map = {};
}

// Keep track of all points on all maps and how to focus on them
// A hash (map) of hashes (markers)
WebGUI.Map.markers = {};

// Keep a loading dialog
WebGUI.Map.loadingDialog = undefined;

/**
 * WebGUI.Map.deletePoint( map, mgr, marker )
 * Delete a point from the map. 
 * NOTE: We assume the user has already confirmed this action
 */
WebGUI.Map.deletePoint
= function ( map, mgr, marker ) {
    var callback    = function ( text, code ) {
        WebGUI.Map.hideLoading();
        var response    = YAHOO.lang.JSON.parse( text );
        // remove the marker from the map
        if ( !response.error ) {
            mgr.removeMarker( marker );
            delete WebGUI.Map.markers[ map.assetId ][ marker.assetId ];
        }
    };
    WebGUI.Map.showLoading();
    GDownloadUrl( map.url + '?func=ajaxDeletePoint;assetId=' + marker.assetId, callback);
};

/**
 * WebGUI.Map.editPoint( map, mgr, marker )
 * Edit a point on the map. 
 * up the edit box. mgr is the Marker Manager to add the marker
 * to. 
 */
WebGUI.Map.editPoint
= function ( map, mgr, marker ) {
    var assetId = '';
    if ( !marker ) {
        marker = new GMarker( map.getCenter(), { draggable: true } );
        marker.infoWin = document.createElement("div");
        marker.bindInfoWindow( marker.infoWin );
        marker.map = map;
        mgr.addMarker( marker, 0 );
        mgr.refresh();
        assetId         = "new";
        marker.assetId  = "new";
        GEvent.addListener( marker, "dragend", function (latlng) {
            WebGUI.Map.setPointLocation( marker, latlng );
        } );
    }
    else {
        assetId = marker.assetId;
    }

    // Callback should open the window with the form
    var callback    = function (text, code) {
        YAHOO.util.Dom.addClass( document.body, "yui-skin-sam" );
        var dialog = new YAHOO.widget.Dialog("editPoint");
        
        var handleCancel = function() {
            if ( marker.assetId == "new" ) {
                mgr.removeMarker( marker );
            }
            this.cancel();
        }

        var handleSubmit = function() {
            // Add the lat/long to the form
            var lat = marker.getLatLng().lat();
            var lng = marker.getLatLng().lng();
            this.form.elements['latitude'].value = lat;
            this.form.elements['longitude'].value = lng;
            WebGUI.Map.showLoading();
            this.submit();
        }
        
        var myButtons = [ 
            { text:"Submit", handler:handleSubmit, isDefault:true },
            { text:"Cancel", handler:handleCancel } 
        ];
        dialog.cfg.queueProperty("buttons", myButtons);
        dialog.cfg.queueProperty("constraintoviewport", true);
        dialog.cfg.queueProperty("fixedcenter", true);
        dialog.setBody( text );
        dialog.render(document.body);
        dialog.show();

        dialog.callback = {
            upload: function (o) {
                // Update marker info
                var point   = YAHOO.lang.JSON.parse( o.responseText );
                marker.assetId  = point.assetId;
                marker.title    = point.title;
                GEvent.clearListeners( marker, "click" );
                GEvent.clearListeners( marker, "infowindowbeforeclose" );

                // Decode HTML entities because JSON is being returned as text/html
                // See WebGUI::Asset::Wobject::Map www_ajaxEditPointSave
                var decoder = document.createElement( "textarea" );
                decoder.innerHTML       = point.content;
                point.content           = decoder.value;

                var infoWin = document.createElement( "div" );
                infoWin.innerHTML       = point.content;
                marker.infoWin          = infoWin;

                if ( point.canEdit ) {
                    var divButton    = document.createElement('div');
                    infoWin.appendChild( divButton );

                    var editButton      = document.createElement("input");
                    editButton.type     = "button";
                    editButton.value    = "Edit";
                    GEvent.addDomListener( editButton, "click", function () {
                        WebGUI.Map.editPoint( map, mgr,  marker );
                    } );
                    divButton.appendChild( editButton );

                    var deleteButton    = document.createElement("input");
                    deleteButton.type   = "button";
                    deleteButton.value  = "Delete"; // Replace with i18n
                    GEvent.addDomListener( deleteButton, "click", function () {
                        if ( confirm("Are you sure you want to delete this point?") ) {
                            WebGUI.Map.deletePoint( map, mgr, marker );
                        }
                    } );
                    divButton.appendChild( deleteButton );
                }
                WebGUI.Map.hideLoading();

                marker.bindInfoWindow( infoWin );
                GEvent.addListener( marker, "dragend", function (latlng) {
                    WebGUI.Map.setPointLocation( marker, latlng );
                } );
                WebGUI.Map.markers[map.assetId][marker.assetId] = marker;
                WebGUI.Map.updateSelectPoint( map );
            }
        };

        // Hide the loading dialog
        WebGUI.Map.hideLoading();
    };

    // Show the loading dialog
    WebGUI.Map.showLoading();

    // Get the form
    GDownloadUrl( map.url + '?func=ajaxEditPoint;assetId=' + assetId, callback );
};

/**
 * WebGUI.Map.focusOn( pointId )
 * Pan the appropriate map to view the appropriate map point
 */
WebGUI.Map.focusOn
= function ( pointId ) {
    var marker;
    for ( var mapId in WebGUI.Map.markers ) {
        if ( WebGUI.Map.markers[mapId][pointId] ) {
            marker = WebGUI.Map.markers[mapId][pointId];
            break;
        }
    }
    if ( !marker ) return;
    var map     = marker.map;
    var infoWin = marker.infoWin;
    if ( map.getZoom() <= 4 ) {
        map.setZoom(5);
    }
    map.panTo( marker.getLatLng() );
    marker.openInfoWindow( marker.infoWin );
};

WebGUI.Map.hideLoading
= function () {
    WebGUI.Map.loadingDialog.hide();
};

/**
 * WebGUI.Map.preparePoints ( map, mgr, points )
 * Prepare the points from WebGUI into Google Map GMarkers
 */
WebGUI.Map.preparePoints
= function ( map, mgr, points ) {
    WebGUI.Map.markers[map.assetId] = {};

    // Transform points into markers
    var markers = [];
    for ( var i = 0; i < points.length; i++ ) (function(i){ // Create closure for callbacks
        var point   = points[i];
        var latlng  = new GLatLng( point.latitude, point.longitude );
        var marker  = new GMarker( latlng, { 
                            title: point.title, 
                            draggable: point.canEdit 
                    } );
        marker.assetId  = point.assetId;
        marker.title    = point.title;
        marker.map      = map;

        // Create info window
        var infoWin = document.createElement( "div" );
        infoWin.innerHTML   = point.content;
        marker.infoWin      = infoWin;
        
        // Make editable features
        if ( point.canEdit ) {
            var divButton    = document.createElement('div');
            
            var editButton   = document.createElement("input");
            editButton.type  = "button";
            editButton.value = "Edit";  // Replace with i18n
            GEvent.addDomListener( editButton, "click", function () {
                WebGUI.Map.editPoint( map, mgr, marker );
            } );
            divButton.appendChild( editButton );

            var deleteButton    = document.createElement("input");
            deleteButton.type   = "button";
            deleteButton.value  = "Delete"; // Replace with i18n
            GEvent.addDomListener( deleteButton, "click", function () {
                if ( confirm("Are you sure you want to delete this point?") ) {
                    WebGUI.Map.deletePoint( map, mgr, marker );
                }
            } );
            divButton.appendChild( deleteButton );

            infoWin.appendChild( divButton );
            GEvent.addListener( marker, "dragend", function (latlng) {
                WebGUI.Map.setPointLocation( marker, latlng );
            } );
        }

        // Keep info
        WebGUI.Map.markers[map.assetId][point.assetId] = marker;

        marker.bindInfoWindow( infoWin );

        markers.push(marker);
    })(i);
    return markers;
};

/**
 * WebGUI.Map.setCenter ( map, baseUrl ) 
 * Set the new center point and zoom level of the map.
 * map is the Google Map object
 * baseUrl is the base URL to the Map asset
 */
WebGUI.Map.setCenter
= function ( map, baseUrl ) {
    var url     = baseUrl + '?func=ajaxSetCenter';
    var center  = map.getCenter();
    url         = url + ';startLatitude=' + center.lat()
                + ';startLongitude=' + center.lng()
                + ';startZoom=' + map.getZoom()
                ;
    var callback = function ( text, code ) {
        // TODO: Notify the poor user
        WebGUI.Map.hideLoading();
    };
    WebGUI.Map.showLoading();
    GDownloadUrl(url,callback);
};

/**
 * WebGUI.Map.setPointLocation( marker, latlng )
 * Update the point's location in the database.
 */
WebGUI.Map.setPointLocation
= function ( marker, latlng ) {
    var url = marker.map.url + '?func=ajaxSetPointLocation'
            + ';assetId=' + marker.assetId
            + ';latitude=' + latlng.lat()
            + ';longitude=' + latlng.lng()
            ;
    var callback = function ( text, code ) {
        // TODO: Notify the poor user
        WebGUI.Map.hideLoading();
    };
    WebGUI.Map.showLoading();
    GDownloadUrl(url, callback);
};

WebGUI.Map.showLoading
= function () {
    // Create a loading dialog
    if ( !WebGUI.Map.loadingDialog ) {
        var loadingDialog = new YAHOO.widget.Panel("loading", { width:"240px", 
                              fixedcenter:true, 
                              close:false, 
                              draggable:false, 
                              zindex:4,
                              modal:true,
                              visible:false
                            } 
                    );

        loadingDialog.setHeader("Loading, please wait...");
        loadingDialog.setBody('<img src="' + getWebguiProperty('extrasURL') + '/yui-webgui/build/map/assets/loading.gif" />');
        loadingDialog.render(document.body);
        WebGUI.Map.loadingDialog = loadingDialog;
    }

    WebGUI.Map.loadingDialog.show();
};


WebGUI.Map.updateSelectPoint
= function (map) {
    var select  = document.getElementById( 'selectPoint_' + map.assetId );
    if ( !select) {
        return;
    }

    // Clear old points
    while ( select.options.length > 1 ) {
        select.length = 1;
    }

    var markers = WebGUI.Map.markers[map.assetId];
    var sorted  = [];
    for ( var pointId in markers ) {
        sorted.push( pointId );
    }

    sorted.sort( function (a,b) { 
        var ma  = WebGUI.Map.markers[map.assetId][a];
        var mb  = WebGUI.Map.markers[map.assetId][b];

        if ( ma.title > mb.title ) { return 1; }
        else if ( ma.title < mb.title ) { return -1; }
        else { return 0; }
    } );

    // Add new points
    for ( var i = 0; i < sorted.length; i++ ) {
        select.options[ select.options.length ]
            = new Option( markers[sorted[i]].title, sorted[i] );
    }
};
