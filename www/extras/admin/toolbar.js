
/**
 * WebGUI.Toolbar - the asset toolbars
 */

bind = function ( scope, func ) {
    return function() { func.apply( scope, arguments ) }
};

if ( typeof WebGUI == "undefined" ) {
    WebGUI = {};
}

/**
 * WebGUI.Toolbar( assetId, cfg )
 * Create a toolbar for the given asset ID.
 * cfg is an option of configuration values:
 *      parent      : The parent element, can be an ID or an element
 *      assetData   : The data containing the asset's URL and helpers
 */
WebGUI.Toolbar = function( assetId, cfg ) {
    this.assetId    = assetId;
    this.cfg        = cfg;
    this.container  = document.createElement('span');
};

/**
 * WebGUI.Toolbar.createAll( )
 * Create all the toolbars from placeholders found in the current document
 */
WebGUI.Toolbar.createAll = function( ) {
    var holders = YAHOO.util.Selector.query( '.wg-admin-toolbar' );
    for ( var i = 0; i < holders.length; i++ ) {
        var holder = holders[i];
        var assetId = holder.id.match( /wg-admin-toolbar-(.+)/ )[1];
        var toolbar = new WebGUI.Toolbar( assetId, { "parent" : holder } );
        toolbar.getAssetData( assetId, bind( toolbar, toolbar.render ) );
    }
};

/**
 * getAssetData( assetId, callback )
 * Get the data for an asset.
 */
WebGUI.Toolbar.prototype.getAssetData
= function ( assetId, callback ) {
    var connectCallback = {
        success : function (o) {
            var assetDef = YAHOO.lang.JSON.parse( o.responseText );
            this.cfg.assetData = assetDef;
            callback.call( this );
        },
        failure : function (o) {

        },
        scope: this
    };

    var url = '?op=admin;method=getAssetData;assetId=' + assetId;
    var ajax = YAHOO.util.Connect.asyncRequest( 'GET', url, connectCallback );
};

/**
 * render( [parent] )
 * Render the toolbar on the given parent. If parent is not specified,
 * will use the parent from the configuration. If that is not specified, we
 * got problems.
 *
 * This should be called only AFTER the asset data has been populated. Otherwise
 * I cannot be held responsible for what happens to the universe.
 */
WebGUI.Toolbar.prototype.render
= function ( parent ) {
    parent = parent ? parent : this.cfg.parent;
    if ( typeof parent == "string" ) {
        parent = document.getElementById( parent );
    }

    var assetData = this.cfg.assetData;

    // Create the buttons in our container
    // Menu button
    YAHOO.util.Dom.addClass( document.body, 'yui-skin-sam' );

    var menu = new YAHOO.widget.Menu( document.createElement('div'), {
        clicktohide : true,
        constraintoviewport : true,
        effect: { effect: YAHOO.widget.ContainerEffect.FADE, duration:0.25 }
    });
    var items = window.parent.admin.getHelperMenuItems( this.assetId, assetData.helpers );
    menu.addItems( items );
    menu.render( document.body );

    var menuButton = new YAHOO.widget.Button({
        "container" : this.container,
        "type"      : "menu",
        "label"     : '<img src="' + assetData.icon + '" style="border:none; position: relative; top: 2px; height: 14px" />',
        "menu"      : menu
    });

    // Edit button
    var editButton = new YAHOO.widget.Button({
        type        : "push",
        "container" : this.container,
        label       : assetData.helpers["edit"].label,
        onclick     : {
            fn: window.parent.admin.getHelperHandler( this.assetId, "edit", assetData.helpers["edit"] )
        }
    });

    // Add the container to our parent
    parent.appendChild( this.container );
};

/**
 * destroy()
 * Destroy this toolbar
 */
WebGUI.Toolbar.prototype.destroy
= function () {
    this.container.parentNode.removeChild( this.container );
};

