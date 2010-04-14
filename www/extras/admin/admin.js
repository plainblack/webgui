

/**
 *  WebGUI.Admin -- The WebGUI Admin Console
 */

if ( typeof WebGUI == "undefined" ) {
    WebGUI = {};
}
WebGUI.Admin = (function(){
    // Public methods

    return function (cfg) {
        // Public properties
        this.cfg = cfg;
        this.currentAssetDef    = null;
        this.viewOrTree         = 0; // 0 - Last on View tab. 1 - Last on Tree tab

        // Default configuration
        if ( !this.cfg.locationBarId ) {
            this.cfg.locationBarId = "locationBar";
        }
        if ( !this.cfg.tabBarId ) {
            this.cfg.tabBarId = "tabBar";
        }

        // Private properties
        var self    = this;

        // Private methods
        function _init() {
            self.locationBar    = new WebGUI.Admin.LocationBar( self.cfg.locationBarId );
            self.tabBar         = new YAHOO.widget.TabView( self.cfg.tabBarId );
            // Keep track of View and Tree tabs
            self.tabBar.getTab(0).addListener('click',self.afterShowViewTab,self,true);
            self.tabBar.getTab(1).addListener('click',self.afterShowTreeTab,self,true);
        }

        _init();
    };
})();

/**
 * afterShowTreeTab()
 * Fired after the Tree tab is shown. Refreshes if necessary.
 */
WebGUI.Admin.prototype.afterShowTreeTab 
= function () {
    // Refresh if necessary
    // Update last shown view/tree
    this.viewOrTree = 1;
};

/**
 * afterShowViewTab()
 * Fired after the view tab is shown. Refreshes if necessary.
 */
WebGUI.Admin.prototype.afterShowViewTab
= function () {
    // Refresh if necessary
    // Update last shown view/tree
    this.viewOrTree = 0;
};

/**
 * go( url )
 * Open the view tab and go to the given URL.
 * Should not be used for assets, use gotoAsset() instead
 */

/**
 * gotoAsset( url )
 * Open the appropriate tab (View or Tree) and go to the given asset URL
 */
WebGUI.Admin.prototype.gotoAsset
= function ( url ) {
    window.frames[ "view" ].location.href = url;
};

/**
 * navigate( assetDef )
 * We've navigated to a new asset. Called by one of the iframes when a new 
 * page is reached
 */
WebGUI.Admin.prototype.navigate
= function ( assetDef ) {
    // Don't do the same asset twice
    if ( this.currentAssetDef && this.currentAssetDef.assetId == assetDef.assetId ) {
        return;
    }
    
    // Update the location bar
    this.locationBar.navigate( assetDef );

    // Mark the other frame dirty
};

/****************************************************************************
 *  WebGUI.Admin.LocationBar
 */
WebGUI.Admin.LocationBar 
= function (id) {
    // Public properties
    this.id                 = id;   // ID of the element containing the location bar
    this.currentAssetDef    = null; // Object containing assetId, title, url, icon
    this.backAssetDefs      = [ ];  // Asset defs to go back to
    this.forwardAssetDefs   = [ ];  // Asset defs to go forward to

    // Private members
    var self = this;
    var _element    = document.getElementById( self.id );

    function _init () {
        // Create buttons
        self.btnBack    = new YAHOO.widget.Button( "backButton", {
            type            : "split",
            label           : '<img src="' + getWebguiProperty("extrasURL") + 'icon/arrow_left.png" />',
            disabled        : true,
            lazyloadmenu    : false,
            onclick         : { fn: self.goBack, scope: self },
            menu            : []
        } );
        self.btnForward = new YAHOO.widget.Button( "forwardButton", {
            type            : "split",
            label           : '<img src="' + getWebguiProperty("extrasURL") + 'icon/arrow_right.png" />',
            disabled        : true,
            lazyloadmenu    : false,
            onclick         : { fn: self.goForward, scope: self },
            menu            : []
        } );
        self.btnSearch  = new YAHOO.widget.Button( "searchButton", {
            label       : '<img src="' + getWebguiProperty("extrasURL") + 'icon/magnifier.png" />'
        } );
        self.btnHome    = new YAHOO.widget.Button( "homeButton", {
            label       : '<img src="' + getWebguiProperty("extrasURL") + 'icon/house.png" />'
        } );
        // Take control of the location input
        YAHOO.util.Event.addListener( "locationUrl", "focus", self.inputFocus, self, true );
        YAHOO.util.Event.addListener( "locationUrl", "blur", self.inputBlur, self, true );
    }

    _init();
};

/**
 * addBackAsset( assetDef )
 * Update the back menu to include a new asset
 */
WebGUI.Admin.LocationBar.prototype.addBackAsset
= function ( assetDef ) {
    var self = this; // Scope correction for event handlers
    var b = this.btnBack;

    // Button is enabled
    b.set("disabled", false);

    // Add the menu item
    this.backAssetDefs.unshift( assetDef );
    b.getMenu().insertItem( {
        text    : this.getMenuItemLabel( assetDef ), 
        value   : assetDef.url,
        onclick : function () { self.clickMenuItem( "back", assetDef ) }
    }, 0 );
    b.getMenu().render();

    // Remove a menu item if necessary
    // TODO
};

/**
 * getMenuItemLabel( assetDef )
 * Build a menu item label for the given assetDef
 */
WebGUI.Admin.LocationBar.prototype.getMenuItemLabel
= function ( assetDef ) {
    return '<img src="' + assetDef.icon + '" /> ' + assetDef.title;
}

/** 
 * goBack( e )
 * Called when the mouse clicks on the back button
 */
WebGUI.Admin.LocationBar.prototype.goBack
= function ( e ) {
    var assetDef    = this.backAssetDefs[0];

    // First, start the going
    window.admin.gotoAsset( assetDef.url );

    // Update the back and forward menus
    this.swapBackToForward( assetDef );
};

/**
 * goForward( e )
 * Called when the mouse clicks down on the forward button
 */
WebGUI.Admin.LocationBar.prototype.goForward
= function ( e ) {
};

/**
 * inputBlur( e )
 * Called after the URL input field loses focus
 */
WebGUI.Admin.LocationBar.prototype.inputBlur
= function ( e ) {
    if ( e.target.value.match(/^\s*$/) ) {
        e.target.value = this.currentAssetDef.url;
    }
};

/**
 * inputFocus( e )
 * Called after the URL input field gains focus.
 */
WebGUI.Admin.LocationBar.prototype.inputFocus
= function ( e ) {
    if ( e.target.value == this.currentAssetDef.url ) {
        e.target.value = "";
    }
};

/**
 * navigate( assetDef )
 * Tell the locationbar we've navigated to a new asset. 
 */
WebGUI.Admin.LocationBar.prototype.navigate
= function ( assetDef ) {
    if ( this.currentAssetDef ) {
        if ( this.currentAssetDef.assetId == assetDef.assetId ) {
            // Don't do the same asset twice
            return;
        }
        this.addBackAsset( this.currentAssetDef );
    }

    // Current asset is now...
    this.currentAssetDef = assetDef;

    // Update location bar
    this.setTitle( assetDef.title );
    this.setUrl( assetDef.url );

    return;
};

/**
 * setTitle( title )
 * Set the title to the new title
 */
WebGUI.Admin.LocationBar.prototype.setTitle
= function ( title ) {
    var span = document.getElementById("locationTitle");
    while ( span.childNodes.length ) span.removeChild( span.childNodes[0] );
    span.appendChild( document.createTextNode( title ) );
};

/**
 * setUrl( url )
 * Set the URL to the new URL
 */
WebGUI.Admin.LocationBar.prototype.setUrl
= function ( url ) {
    var input = document.getElementById( "locationUrl" );
    input.value = url;
};

/**
 * swapBackToForward( assetDef )
 * Swap items from the back list to the forward list until assetDef is the 
 * current asset.
 */
WebGUI.Admin.LocationBar.prototype.swapBackToForward
= function ( assetDef ) {
    var self = this; // scope correction for inner stuff
    while ( this.backAssetDefs.length > 0 && this.currentAssetDef.assetId != assetDef.assetId ) {
        var workingDef  = this.currentAssetDef;
        this.forwardAssetDefs.unshift( workingDef );
        this.btnForward.getMenu().insertItem( {
            text    : this.getMenuItemLabel( workingDef ),
            value   : workingDef.url,
            onclick : function(){ self.clickForwardMenuItem( workingDef ) }
        }, 0 );
        this.currentAssetDef = this.backAssetDefs.shift();
        this.btnBack.getMenu().removeItem(0);
    }
    this.btnForward.getMenu().render();
    this.btnForward.set("disabled", false);
    this.btnBack.render();
    if ( this.backAssetDefs.length == 0 ) {
        this.btnBack.set( "disabled", true );
    }
};

/**
 * swapForwardToBack( assetDef )
 * Swap items from the forward list to the back list until assetDef is the 
 * current asset.
 */
WebGUI.Admin.LocationBar.prototype.swapForwardToBack
= function ( assetDef ) {


};




