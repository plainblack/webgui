

/**
 *  WebGUI.Admin -- The WebGUI Admin Console
 */

if ( typeof WebGUI == "undefined" ) {
    WebGUI = {};
}
WebGUI.Admin = function(cfg){
    // Public properties
    this.cfg = cfg;
    this.currentAssetDef    = null;
    this.currentTab         = "view"; // "view" or "tree" or other ID
    this.treeDirty          = true;

    // Default configuration
    if ( !this.cfg.locationBarId ) {
        this.cfg.locationBarId = "locationBar";
    }
    if ( !this.cfg.tabBarId ) {
        this.cfg.tabBarId = "tabBar";
    }
    if ( !this.cfg.adminBarId ) {
        this.cfg.adminBarId = "adminBar";
    }

    // Custom events
    this.afterNavigate = new YAHOO.util.CustomEvent( "afterNavigate", this );

    // Private methods
    var self = this;
    // Initialize these things AFTER the i18n is fetched
    var _init = function () {
        self.adminBar       = new WebGUI.Admin.AdminBar( self.cfg.adminBarId, { expandMax : true } );
        self.adminBar.afterShow.subscribe( self.updateAdminBar, self );
        YAHOO.util.Event.on( window, 'load', function(){ self.adminBar.show( self.adminBar.dt[0].id ) } );
        self.newContentBar  = new WebGUI.Admin.AdminBar( "newContentBar" );
        self.locationBar    = new WebGUI.Admin.LocationBar( self.cfg.locationBarId );
        self.afterNavigate.subscribe( self.locationBar.afterNavigate, self.locationBar );
        if ( self.currentAssetDef ) {
            self.locationBar.navigate( self.currentAssetDef );
        }

        self.afterNavigate.subscribe( self.requestUpdateCurrentVersionTag, self );

        self.tree           = new WebGUI.Admin.Tree();
        self.tabBar         = new YAHOO.widget.TabView( self.cfg.tabBarId );
        // Keep track of View and Tree tabs
        self.tabBar.getTab(0).addListener('click',self.afterShowViewTab,self,true);
        self.tabBar.getTab(1).addListener('click',self.afterShowTreeTab,self,true);
    };

    // Get I18N
    this.i18n = new WebGUI.i18n( {
        namespaces : {
            'WebGUI' : [ '< prev', 'next >', 'locked by' ],
            'Asset'  : [ 'rank', '99', 'type', 'revision date', 'size', 'locked', 'More', 'unlocked', 'edit' ]
        },
        onpreload : {
            fn : _init
        }
    } );


};

/**
 * afterShowTreeTab()
 * Fired after the Tree tab is shown. Refreshes if necessary.
 */
WebGUI.Admin.prototype.afterShowTreeTab 
= function () {
    // Refresh if necessary
    if ( this.treeDirty ) {
        this.tree.goto( this.currentAssetDef.url );
        this.treeDirty = 0;
    }
    // Update last shown view/tree
    this.currentTab = "tree";
};

/**
 * afterShowViewTab()
 * Fired after the view tab is shown. Refreshes if necessary.
 */
WebGUI.Admin.prototype.afterShowViewTab
= function () {
    // Refresh if necessary
    if ( this.viewDirty ) {
        window.frames[ "view" ].location.href = this.currentAssetDef.url;
        this.viewDirty = 0;
    }
    // Update last shown view/tree
    this.currentTab = "view";
};

/**
 * appendToUrl( url, params )
 * Add URL components to a URL;
 */
appendToUrl 
= function ( url, params ) {
    var components = [ url ];
    if (url.match(/\?/)) {
        components.push(";");
    }
    else {
        components.push("?");
    }
    components.push(params);
    return components.join(''); 
};

/**
 * editAsset( url )
 * Show the edit form for the asset at the given URL
 */
WebGUI.Admin.prototype.editAsset
= function ( url ) {
    // Show the view tab
    this.tabBar.selectTab( 0 );
    this.currentTab = "view";

    // Open the edit form
    window.frames["view"].location.href = appendToUrl( url, "func=edit" );

    // Mark undirty, as we'll clean it ourselves
    this.viewDirty = 0;
};

/**
 * gotoAsset( url )
 * Open the appropriate tab (View or Tree) and go to the given asset URL
 */
WebGUI.Admin.prototype.gotoAsset
= function ( url ) {
    if ( this.currentTab == "view" ) {
        window.frames[ "view" ].location.href = url;
        this.treeDirty = 1;
    }
    else if ( this.currentTab == "tree" ) {
        // Make tree request
        this.tree.goto( url );
        this.viewDirty = 1;
    }
};

/**
 * makeEditAsset( url ) 
 * Create a callback to edit an asset. Use when attaching to event listeners
 */
WebGUI.Admin.prototype.makeEditAsset
= function (url) {
    var self = this;
    return function() {
        self.editAsset( url );
    };
};

/**
 * makeGotoAsset( url )
 * Create a callback to view an asset. Use when attaching to event listeners
 */
WebGUI.Admin.prototype.makeGotoAsset
= function ( url ) {
    var self = this;
    return function() {
        self.gotoAsset( url );
    };
};

/**
 * navigate( assetDef )
 * We've navigated to a new asset. Called by the view iframe when a new 
 * page is reached
 */
WebGUI.Admin.prototype.navigate
= function ( assetDef ) {
    // Don't do the same asset twice
    if ( this.currentAssetDef && this.currentAssetDef.assetId == assetDef.assetId ) {
        // But still fire the event
        this.afterNavigate.fire( assetDef );
        return;
    }

    if ( !this.currentAssetDef || this.currentAssetDef.assetId != assetDef.assetId ) {
        this.currentAssetDef = assetDef;
        this.treeDirty = 1;
        this.updateAssetHelpers( assetDef );
    }

    // Fire event
    this.afterNavigate.fire( assetDef );
};

/**
 * updateAdminBar( type, args, admin )
 * Update the AdminBar. args is an array containing the id of the AdminBar 
 * pane being shown.
 */
WebGUI.Admin.prototype.updateAdminBar
= function ( type, args, admin ) {
    // "this" is the AdminBar
    var id  = args[0];
    if ( id == "assetHelpers" ) {

    }
    else if ( id == "clipboard" ) {
        admin.requestUpdateClipboard.call( admin );
    }
    else if ( id == "newContent" ) {

    }
    else if ( id == "versionTags" ) {

    }
};

/**
 * requestUpdateClipboard( )
 * Request the new set of clipboard assets from the server
 */
WebGUI.Admin.prototype.requestUpdateClipboard
= function ( ) {
    var callback = {
        success : function (o) {
            var clipboard = YAHOO.lang.JSON.parse( o.responseText );
            this.updateClipboard( clipboard );
        },
        failure : function (o) {

        },
        scope: this
    };

    var showAll = document.getElementById( 'clipboardShowAll' ).checked ? ";all=1" : ";all=0";
    var ajax = YAHOO.util.Connect.asyncRequest( 'GET', '?op=admin;method=getClipboard' + showAll, callback );
};

/**
 * updateClipboard( assets )
 * Update the clipboard list with the given assets
 */
WebGUI.Admin.prototype.updateClipboard
= function ( assets ) {
    // Clear out the old clipboard
    var div = document.getElementById( 'clipboardItems' );
    while ( div.childNodes.length > 0 ) {
        div.removeChild( div.childNodes[0] );
    }

    for ( var i = 0; i < assets.length; i++ ) {
        var asset   = assets[i];
        var a       = document.createElement('a');
        var icon    = document.createElement('img');
        icon.src    = asset.icon;
        a.appendChild( icon );
        a.appendChild( document.createTextNode( asset.title ) );
        div.appendChild( a );
        this.addPasteHandler( a, asset.assetId );
    }
};

/**
 * addPasteHandler( elem, assetId )
 * Add an onclick handler to paste an asset.
 */
WebGUI.Admin.prototype.addPasteHandler
= function ( elem, assetId ) {
    var self    = this;
    YAHOO.util.Event.on( elem, "click", function(){
        // Update clipboard after paste in case paste fails
        var updateAfterPaste = function(){
            this.requestUpdateClipboard();
            this.afterNavigate.unsubscribe( updateAfterPaste );
        };
        self.afterNavigate.subscribe(updateAfterPaste, self );
        self.pasteAsset( assetId );
    }, self );
};

/**
 * pasteAsset( id )
 * Paste an asset and update the clipboard
 */
WebGUI.Admin.prototype.pasteAsset
= function ( id ) {
    var url = appendToUrl( this.currentAssetDef.url, 'func=paste;assetId=' + id );
    this.gotoAsset( url );
};

/**
 * updateAssetHelpers( assetDef )
 * Update the asset helpers. assetDef must contain:
 *      helper      - An arrayref of hashrefs of helper definitions
 *      icon        - The icon of the current asset
 *      type        - The type of the current asset
 */
WebGUI.Admin.prototype.updateAssetHelpers
= function ( assetDef ) {
    var typeEl  = document.getElementById( 'helper_asset_name' );
    typeEl.style.backgroundImage = 'url(' + assetDef.icon + ')';
    typeEl.innerHTML = assetDef.type;

    // Clear old helpers
    var helperEl    = document.getElementById( 'helper_list' );
    while ( helperEl.childNodes.length > 0 ) {
        helperEl.removeChild( helperEl.childNodes[0] );
    }

    // Add new ones
    for ( var i = 0; i < assetDef.helpers.length; i++ ) {
        var helper  = assetDef.helpers[i];
        var li      = document.createElement('li');
        li.appendChild( document.createTextNode( helper.label ) );
        this.addHelperHandler( li, helper );
        helperEl.appendChild( li );
    }
};

/**
 * addHelperHandler( elem, helper )
 * Add the click handler to activate the given helper
 */
WebGUI.Admin.prototype.addHelperHandler
= function ( elem, helper ) {
    var self = this;
    if ( helper.url ) {
        YAHOO.util.Event.on( elem, "click", function(){ self.gotoAsset( helper.url ) }, self, true );
    }
    else if ( helper.class ) {
        YAHOO.util.Event.on( elem, "click", function(){ self.requestHelper( helper.class, self.currentAssetDef.assetId ) }, self, true );
    }
};

/**
 * updateCurrentVersionTag( tag )
 * Update the current version tag. tag is an object of data about the tag:
 *      tagId       : the ID of the tag
 *      name        : The name of the tag
 *      editUrl     : A URL to edit the tag
 *      commitUrl   : A URL to commit the tag
 *      leaveUrl    : A URL to leave the tag
 */
WebGUI.Admin.prototype.updateCurrentVersionTag
= function ( tag ) {
    if ( !tag.tagId ) {
        // hide tag area
        document.getElementById( 'versionTag' ).style.display = "none";
        return;
    }

    // Make sure tag is shown now
    document.getElementById( 'versionTag' ).style.display = "block";

    var editEl  = document.getElementById( 'editTag' );
    editEl.innerHTML = tag.name;
    editEl.href     = tag.editUrl;

    var publishEl = document.getElementById( 'publishTag' );
    publishEl.href  = tag.commitUrl;

    var leaveEl = document.getElementById( 'leaveTag' );
    leaveEl.href    = tag.leaveUrl;
};

/**
 * requestUpdateCurrentVersionTag( )
 * Request an update for the current version tag
 */
WebGUI.Admin.prototype.requestUpdateCurrentVersionTag
= function ( ) {
    var callback = {
        success : function (o) {
            var tag = YAHOO.lang.JSON.parse( o.responseText );
            this.updateCurrentVersionTag( tag );
        },
        failure : function (o) {

        },
        scope: this
    };

    var ajax = YAHOO.util.Connect.asyncRequest( 'GET', '?op=admin;method=getCurrentVersionTag', callback );
};

/**
 * requestHelper( helperClass, assetId )
 * Request the Asset Helper for the given assetId
 */
WebGUI.Admin.prototype.requestHelper
= function ( helperClass, assetId ) {
    var callback = {
        success : function (o) {
            var resp = YAHOO.lang.JSON.parse( o.responseText );

            if ( resp.openTab ) {
                this.openTab( resp.openTab );
            }
            else if ( resp.openDialog ) {
                this.openModalDialog( resp.openDialog, resp.width, resp.height );
            }
            else if ( resp.scriptFile ) {
                this.loadAndRun( resp.scriptFile, resp.scriptFunc, resp.scriptArgs );
            }
            else {
                alert( "Unknown helper response: " + resp );
            }
        },
        failure : function (o) {

        },
        scope: this
    };

    var url = '?op=admin;method=processAssetHelper;className=' + helperClass + ';assetId=' + assetId;
    var ajax = YAHOO.util.Connect.asyncRequest( 'GET', url, callback );
};

/**
 * openModalDialog( url, width, height )
 * Open a modal dialog with an iframe containing the given URL.
 * The page inside the iframe must eventually close the dialog using:
 *      window.parent.admin.closeModalDialog();
 */
WebGUI.Admin.prototype.openModalDialog
= function ( url, width, height ) {
    if ( this.modalDialog ) {
        return; // Can't have more than one open
    }

    if ( !width ) {
        width       = parseInt( YAHOO.util.Dom.getViewportWidth() * 0.6 ) + "px";
    }
    if ( !height ) {
        height      = parseInt( YAHOO.util.Dom.getViewportHeight() * 0.6 ) + "px";
    }

    var dialog  = new YAHOO.widget.Panel( 'adminModalDialog', {
        "width"             : width,
        "height"            : height,
        fixedcenter         : true,
        constraintoviewport : true,
        underlay            : "shadow",
        modal               : true,
        close               : false,
        visible             : true,
        draggable           : false
    } );
    dialog.setBody( '<iframe src="' + url + '" width="100%" height="100%"></iframe>' );
    dialog.render( document.body );

    this.modalDialog = dialog;
};

/**
 * closeModalDialog( )
 * Close the current modal dialog
 */
WebGUI.Admin.prototype.closeModalDialog
= function ( ) {
    if ( !this.modalDialog ) {
        return; // Can't close what isn't open
    }

    this.modalDialog.destroy();
    this.modalDialog = null;
};

/**
 * showInfoMessage( message )
 * Show an informative message that requires no response or interaction from 
 * the user.
 */
WebGUI.Admin.prototype.showInfoMessage
= function ( message ) {
    if ( this.infoMessageTimeout ) {
        stopTimeout( this.infoMessageTimeout );
    }

    var info    = document.getElementById( 'infoMessage' );
    info.innerHTML = message;
    info.style.display = "block";

    this.infoMessageTimeout = setTimeout( this.hideInfoMessage, 3000 );
};

/** 
 * hideInfoMessage( )
 * Hide the informative message from showInfoMessage()
 */
WebGUI.Admin.prototype.hideInfoMessage
= function ( ) {
    var info = document.getElementById( 'infoMessage' );
    info.style.display = "none";
};

/****************************************************************************
 *  WebGUI.Admin.LocationBar
 */
WebGUI.Admin.LocationBar 
= function (id, cfg) {
    // Public properties
    this.id                 = id;   // ID of the element containing the location bar
    this.cfg                = cfg;  // Configuration
    this.currentAssetDef    = null; // Object containing assetId, title, url, icon
    this.backAssetDefs      = [ ];  // Asset defs to go back to
    this.forwardAssetDefs   = [ ];  // Asset defs to go forward to

    // Private members
    var self = this;
    var _element    = document.getElementById( self.id );

    // Create buttons
    this.btnBack    = new YAHOO.widget.Button( "backButton", {
        type            : "split",
        label           : '<img src="' + getWebguiProperty("extrasURL") + 'icon/arrow_left.png" />',
        disabled        : true,
        lazyloadmenu    : false,
        onclick         : { fn: this.goBack, scope: this },
        menu            : []
    } );
    this.btnForward = new YAHOO.widget.Button( "forwardButton", {
        type            : "split",
        label           : '<img src="' + getWebguiProperty("extrasURL") + 'icon/arrow_right.png" />',
        disabled        : true,
        lazyloadmenu    : false,
        onclick         : { fn: this.goForward, scope: this },
        menu            : []
    } );
    this.btnSearch  = new YAHOO.widget.Button( "searchButton", {
        label       : '<img src="' + getWebguiProperty("extrasURL") + 'icon/magnifier.png" />',
        onclick     : { fn: this.clickSearchButton, scope: this }
    } );
    this.btnHome    = new YAHOO.widget.Button( "homeButton", {
        type        : "button",
        label       : '<img src="' + getWebguiProperty("extrasURL") + 'icon/house.png" />',
        onclick     : { fn: this.goHome, scope: this }
    } );
    // Take control of the location input
    this.klInput = new YAHOO.util.KeyListener( "locationUrl", { keys: 13 }, {
        fn: this.doInputSearch,
        scope: this,
        correctScope: true
    } );
    YAHOO.util.Event.addListener( "locationUrl", "focus", this.inputFocus, this, true );
    YAHOO.util.Event.addListener( "locationUrl", "blur", this.inputBlur, this, true );

};

/**
 * addBackAsset( assetDef )
 * Update the back menu to include a new asset
 */
WebGUI.Admin.LocationBar.prototype.addBackAsset
= function ( assetDef ) {
    var b = this.btnBack;

    // Button is enabled
    b.set("disabled", false);

    // Add the menu item
    this.backAssetDefs.unshift( assetDef );
    b.getMenu().insertItem( {
        text    : this.getMenuItemLabel( assetDef ), 
        value   : assetDef.url,
        onclick : { fn: this.clickBackMenuItem, obj: assetDef, scope: this }
    }, 0 );
    b.getMenu().render();

    // Remove a menu item if necessary
    // TODO
};

/**
 * clickBackMenuItem( assetDef )
 * Click an item in the back menu
 */
WebGUI.Admin.LocationBar.prototype.clickBackMenuItem
= function ( type, e, assetDef ) {
    window.admin.gotoAsset( assetDef.url );
    this.swapBackToForward( assetDef );
};

/**
 * clickForwardMenuItem( assetDef )
 * Click an item in the forward menu
 */
WebGUI.Admin.LocationBar.prototype.clickForwardMenuItem
= function ( type, e, assetDef ) {
    window.admin.gotoAsset( assetDef.url );
    this.swapForwardToBack( assetDef );
};

/**
 * doInputSearch()
 * Perform the search as described in the location bar
 */
WebGUI.Admin.LocationBar.prototype.doInputSearch
= function ( ) {
    var input = document.getElementById("locationUrl").value;
    // If input starts with a / and doesn't contain a ? go to the asset
    if ( input.match(/^\//) ) {
        if ( !input.match(/\?/) ) {
            window.admin.gotoAsset( input );
        }
        // If does contain a ?, go to url
        else { 
            window.admin.go( input );
        }
    }
    // Otherwise ask WebGUI what do
    else {
        alert("TODO");
    }
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
    var assetDef    = this.forwardAssetDefs[0];

    // First, start the going
    window.admin.gotoAsset( assetDef.url );

    // Update the back and forward menus
    this.swapForwardToBack( assetDef );
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
    this.klInput.disable();
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
    this.klInput.enable();
};

/**
 * afterNavigate( type, args, me )
 * Update our location if necessary
 * Context is the WebGUI.Admin object.
 * Args is array:
 *      assetDef        - the new current asset
 */
WebGUI.Admin.LocationBar.prototype.afterNavigate
= function ( type, args, me ) {
    var assetDef = args[0];

    // Always update location bar
    me.setTitle( assetDef.title );
    me.setUrl( assetDef.url );

    // Don't do the same asset twice
    if ( me.currentAssetDef && me.currentAssetDef.assetId != assetDef.assetId ) {
        me.addBackAsset( me.currentAssetDef );
        // We navigated, so destroy the forward queue
        //this.forwardAssetDefs = [];
        //this.btnForward.getMenu().clearItems();
        //this.btnForward.getMenu().render();
        //this.btnForward.set( "disabled", true );
    }

    // Current asset is now...
    me.currentAssetDef = assetDef;

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
    while ( this.backAssetDefs.length > 0 && this.currentAssetDef.assetId != assetDef.assetId ) {
        var workingDef  = this.currentAssetDef;
        this.forwardAssetDefs.unshift( workingDef );
        this.btnForward.getMenu().insertItem( {
            text    : this.getMenuItemLabel( workingDef ),
            value   : workingDef.url,
            onclick : { fn: this.clickForwardMenuItem, obj: workingDef, scope: this }
        }, 0 );
        this.currentAssetDef = this.backAssetDefs.shift();
        this.btnBack.getMenu().removeItem(0);
    }
    this.btnForward.getMenu().render();
    this.btnForward.set("disabled", false);
    this.btnBack.getMenu().render();
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
    while ( this.forwardAssetDefs.length > 0 && this.currentAssetDef.assetId != assetDef.assetId ) {
        var workingDef  = this.currentAssetDef;
        this.backAssetDefs.unshift( workingDef );
        this.btnBack.getMenu().insertItem( {
            text    : this.getMenuItemLabel( workingDef ),
            value   : workingDef.url,
            onclick : { fn: this.clickBackMenuItem, obj: workingDef, scope : this }
        }, 0 );
        this.currentAssetDef = this.forwardAssetDefs.shift();
        this.btnForward.getMenu().removeItem(0);
    }
    this.btnBack.getMenu().render();
    this.btnBack.set("disabled", false);
    this.btnForward.getMenu().render();
    if ( this.forwardAssetDefs.length == 0 ) {
        this.btnForward.set( "disabled", true );
    }
};


/****************************************************************************
 *
 * WebGUI.Admin.Tree
 */

WebGUI.Admin.Tree 
= function(){
    this.moreMenusDisplayed = {};
    this.crumbMoreMenu = null;
    this.defaultSortBy = {
        "key"       : "lineage",
        "dir"       : YAHOO.widget.DataTable.CLASS_ASC
    };

    var assetPaginator = new YAHOO.widget.Paginator({
        containers            : ['treePagination'],
        pageLinks             : 7,
        rowsPerPage           : 100,
        previousPageLinkLabel : window.admin.i18n.get('WebGUI', '< prev'),
        nextPageLinkLabel     : window.admin.i18n.get('WebGUI', 'next >'),
        template              : "<strong>{CurrentPageReport}</strong> {PreviousPageLink} {PageLinks} {NextPageLink}"
    });

   // initialize the data source
   this.dataSource
        = new YAHOO.util.DataSource( '?op=admin;method=getTreeData;', {connTimeout:30000} );
   this.dataSource.responseType
        = YAHOO.util.DataSource.TYPE_JSON;
   this.dataSource.responseSchema
        = {
            resultsList: 'assets',
            fields: [
                { key: 'assetId' },
                { key: 'lineage' },
                { key: 'canEdit' },
                { key: 'title' },
                { key: 'className' },
                { key: 'revisionDate' },
                { key: 'assetSize' },
                { key: 'lockedBy' },
                { key: 'icon' },
                { key: 'url' },
                { key: 'childCount' }
            ],
            metaFields: {
                totalRecords: "totalAssets", // Access to value in the server response
                crumbtrail : "crumbtrail",
                currentAsset : "currentAsset"
            }
        };

    this.columnDefs 
        = [ 
            { key: 'assetId', label: 'Select All Button', formatter: this.formatAssetIdCheckbox },
            { key: 'lineage', label: window.admin.i18n.get('Asset','rank'), sortable: true, formatter: this.formatRank },
            { key: 'actions', label: "", formatter: this.formatActions },
            { key: 'title', label: window.admin.i18n.get('Asset', '99'), formatter: this.formatTitle, sortable: true },
            { key: 'className', label: window.admin.i18n.get('Asset','type'), sortable: true, formatter: this.formatClassName },
            { key: 'revisionDate', label: window.admin.i18n.get('Asset','revision date' ), formatter: this.formatRevisionDate, sortable: true },
            { key: 'assetSize', label: window.admin.i18n.get('Asset','size' ), formatter: this.formatAssetSize, sortable: true },
            { key: 'lockedBy', label: window.admin.i18n.get('Asset','locked' ), formatter: this.formatLockedBy }
        ];

    // Initialize the data table
    this.dataTable
        = new YAHOO.widget.DataTable( 'treeDataTableContainer', 
            this.columnDefs,
            this.dataSource, 
            {
                initialLoad             : false,
                dynamicData             : true,
                paginator               : assetPaginator,
                sortedBy                : this.defaultSortedBy,
                generateRequest         : this.buildQueryString
            }
        );
    // Save the Tree
    this.dataTable.tree = this;

    this.dataTable.handleDataReturnPayload
        = function(oRequest, oResponse, oPayload) {
            oPayload.totalRecords = oResponse.meta.totalRecords;
            return oPayload;
        };

};

/**
 * addHighlightToRow ( child )
 * Highlight the row containing this element by adding to it the "highlight"
 * class
 */
WebGUI.Admin.Tree.prototype.addHighlightToRow 
= function ( child ) {
    var row     = this.findRow( child );
    if ( !YAHOO.util.Dom.hasClass( row, "highlight" ) ) {
        YAHOO.util.Dom.addClass( row, "highlight" );
    }
};

/**
 * buildMoreMenu ( url, linkElement )
 * Build a WebGUI style "More" menu for the asset referred to by url
 */
WebGUI.Admin.Tree.prototype.buildMoreMenu 
= function ( url, linkElement, isNotLocked ) {
    var rawItems    = this.moreMenuItems;
    var menuItems   = [];
    var isLocked    = !isNotLocked;
    for ( var i = 0; i < rawItems.length; i++ ) {
        var itemUrl     = rawItems[i].url
                        ? appendToUrl(url, rawItems[i].url)
                        : url
                        ;
        if (! (itemUrl.match( /func=edit;/) && isLocked )) {
            menuItems.push( { "url" : itemUrl, "text" : rawItems[i].label } );
        }
    }
    var options = {
        "zindex"                    : 1000,
        "clicktohide"               : true,
        "position"                  : "dynamic",
        "context"                   : [ linkElement, "tl", "bl", ["beforeShow", "windowResize"] ],
        "itemdata"                  : menuItems
    };

    return options;
};

/**
 * buildQueryString ( )
 * Build a query string
 */
WebGUI.Admin.Tree.prototype.buildQueryString 
= function ( state, dt, newUrl ) {
    var assetUrl;
    if ( !newUrl ) {
        assetUrl = window.admin.currentAssetDef.url;
    }
    else {
        assetUrl = newUrl;
    }

    var recordOffset    = state.pagination ? state.pagination.recordOffset : 0;
    var rowsPerPage     = state.pagination ? state.pagination.rowsPerPage : 0;
    var orderByColumn   = state.sortedBy ? state.sortedBy.key : "lineage";
    var orderByDir      = state.sortedBy 
                        ? ( (state.sortedBy.dir === YAHOO.widget.DataTable.CLASS_DESC) ? "DESC" : "ASC" )
                        : "ASC"
                        ;

    var query = "assetUrl=" + assetUrl
        + ";recordOffset=" + recordOffset
        + ';orderByDirection=' + orderByDir
        + ';rowsPerPage=' + rowsPerPage
        + ';orderByColumn=' + orderByColumn
        ;

    return query;
};

/**
 * findRow ( child )
 * Find the row that contains this child element.
 */
WebGUI.Admin.Tree.prototype.findRow
= function ( child ) {
    var node    = child;
    while ( node ) {
        if ( node.tagName == "TR" ) {
            return node;
        }
        node = node.parentNode;
    }
};

/**
 * formatActions ( )
 * Format the Edit and More links for the row
 */
WebGUI.Admin.Tree.prototype.formatActions 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    if ( oRecord.getData( 'canEdit' ) ) {
        var edit    = document.createElement("span");
        edit.className = "clickable";
        YAHOO.util.Event.addListener( edit, "click", function(){
            window.admin.editAsset( oRecord.getData('url') );
        }, window.admin, true );
        edit.appendChild( document.createTextNode( window.admin.i18n.get('Asset', 'edit') ) );
        elCell.appendChild( edit );
        elCell.appendChild( document.createTextNode( " | " ) );
    }

    return; // TODO
    var more    = document.createElement( 'a' );
    elCell.appendChild( more );
    more.appendChild( document.createTextNode( window.admin.i18n.get('Asset','More' ) ) );
    more.href   = '#';

    // Delete the old menu
    if ( document.getElementById( 'moreMenu' + oRecord.getData( 'assetId' ) ) ) {
        var oldMenu = document.getElementById( 'moreMenu' + oRecord.getData( 'assetId' ) );
        oldMenu.parentNode.removeChild( oldMenu );
    }

    var options = this.buildMoreMenu(oRecord.getData( 'url' ), more, oRecord.getData( 'canEdit' ));

    var menu    = new YAHOO.widget.Menu( "moreMenu" + oRecord.getData( 'assetId' ), options );
    YAHOO.util.Event.onDOMReady( function () { menu.render( document.getElementById( 'assetManager' ) ); } );
    YAHOO.util.Event.addListener( more, "click", function (e) { YAHOO.util.Event.stopEvent(e); menu.show(); menu.focus(); }, null, menu );
};

/**
 * formatAssetIdCheckbox ( )
 * Format the checkbox for the asset ID.
 */
WebGUI.Admin.Tree.prototype.formatAssetIdCheckbox
= function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = '<input type="checkbox" name="assetId" value="' + oRecord.getData("assetId") + '"'
        + ' />';
    // TODO: Add onchange handler to toggle checkbox
};

/**
 * formatAssetSize ( )
 * Format the asset class name
 */
WebGUI.Admin.Tree.prototype.formatAssetSize 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = oRecord.getData( "assetSize" );
};

/**
 * formatClassName ( )
 * Format the asset class name
 */
WebGUI.Admin.Tree.prototype.formatClassName 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = '<img src="' + oRecord.getData( 'icon' ) + '" /> '
        + oRecord.getData( "className" );
};

/**
 * formatLockedBy ( )
 * Format the locked icon
 */
WebGUI.Admin.Tree.prototype.formatLockedBy 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    var extras  = getWebguiProperty('extrasURL');
    elCell.innerHTML 
        = oRecord.getData( 'lockedBy' )
        ? '<a href="' + appendToUrl(oRecord.getData( 'url' ), 'func=manageRevisions') + '">'
            + '<img src="' + extras + '/icon/lock.png" alt="' + window.admin.i18n.get('WebGUI', 'locked by') + ' ' + oRecord.getData( 'lockedBy' ) + '" '
            + 'title="' + window.admin.i18n.get('WebGUI', 'locked by') + ' ' + oRecord.getData( 'lockedBy' ) + '" border="0" />'
            + '</a>'
        : '<a href="' + appendToUrl(oRecord.getData( 'url' ), 'func=manageRevisions') + '">'
            + '<img src="' + extras + '/icon/lock_open.png" alt="' + window.admin.i18n.get('Asset', 'unlocked') + '" '
            + 'title="' + window.admin.i18n.get('Asset', 'unlocked') + '" border="0" />'
            + '</a>'
        ;
};

/**
 * formatRank ( )
 * Format the input for the rank box
 */
WebGUI.Admin.Tree.prototype.formatRank 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    var rank    = oRecord.getData("lineage").match(/[1-9][0-9]{0,5}$/); 
    elCell.innerHTML = '<input type="text" name="' + oRecord.getData("assetId") + '_rank" '
        + 'value="' + rank + '" size="3" '
        + '/>';
    // TODO: Add onchange handler to select row
};

/**
 * formatRevisionDate ( )
 * Format the asset class name
 */
WebGUI.Admin.Tree.prototype.formatRevisionDate 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    var revisionDate    = new Date( oRecord.getData( "revisionDate" ) * 1000 );
    var minutes = revisionDate.getMinutes();
    if (minutes < 10) {
        minutes = "0" + minutes;
    }
    elCell.innerHTML
        = revisionDate.getFullYear() + '-' + ( revisionDate.getMonth() + 1 )
        + '-' + revisionDate.getDate() + ' ' + ( revisionDate.getHours() )
        + ':' + minutes
        ;
};

/**
 * formatTitle ( )
 * Format the link for the title
 */
WebGUI.Admin.Tree.prototype.formatTitle 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    var hasChildren = document.createElement("span");
    hasChildren.className = "hasChildren";
    if ( oRecord.getData('childCount') > 0 ) {
        hasChildren.appendChild( document.createTextNode( "+" ) );
    }
    else {
        hasChildren.appendChild( document.createTextNode( " " ) );
    }
    elCell.appendChild( hasChildren );

    var title   = document.createElement("span");
    title.className = "clickable";
    title.appendChild( document.createTextNode( oRecord.getData('title') ) );
    YAHOO.util.Event.addListener( title, "click", function(){ window.admin.gotoAsset(oRecord.getData('url')) }, this, true );
    elCell.appendChild( title );
};

/**
 * Update the tree with a new asset
 * Do not call this directly, use Admin.gotoAsset(url)
 */
WebGUI.Admin.Tree.prototype.goto
= function ( assetUrl ) {
    // TODO: Show loading screen
    var callback = {
        success : this.onDataReturnInitializeTable,
        failure : this.onDataReturnInitializeTable,
        scope   : this,
        argument: this.dataTable.getState()
    };

    this.dataSource.sendRequest( 
        this.buildQueryString( 
            this.dataTable.getState(),
            this.dataTable,
            assetUrl
        ),
        callback
    );
};

/**
 * onDataReturnInitializeTable ( sRequest, oResponse, oPayload )
 * Initialize the table with a new response from the server
 */
WebGUI.Admin.Tree.prototype.onDataReturnInitializeTable
= function ( sRequest, oResponse, oPayload ) {
    this.dataTable.onDataReturnInitializeTable.call( this.dataTable, sRequest, oResponse, oPayload );

    // Rebuild the crumbtrail
    var crumb       = oResponse.meta.crumbtrail;
    var elCrumb     = document.getElementById( "treeCrumbtrail" );
    elCrumb.innerHTML  = '';
    for ( var i = 0; i < crumb.length; i++ ) {
        var item      = crumb[i];
        var elItem    = document.createElement( "span" );
        elItem.className = "clickable";
        YAHOO.util.Event.addListener( elItem, "click", window.admin.makeGotoAsset(item.url) );
        elItem.appendChild( document.createTextNode( item.title ) );

        elCrumb.appendChild( elItem );
        elCrumb.appendChild( document.createTextNode( " > " ) );
    }

    // Final crumb item has a menu
    var elItem  = document.createElement( "span" );
    elItem.className    = "clickable";
    YAHOO.util.Event.addListener( elItem, "click", function(){ alert( "TOADO" ) }, this, true );
    elItem.appendChild( document.createTextNode( oResponse.meta.currentAsset.title ) );
    elCrumb.appendChild( elItem );

    // TODO: Update current asset
    window.admin.navigate( oResponse.meta.currentAsset );

    // TODO Hide loading screen
};

/**
 * removeHighlightFromRow ( child )
 * Remove the highlight from a row by removing the "highlight" class.
 */
WebGUI.Admin.Tree.prototype.removeHighlightFromRow
= function ( child ) {
    var row     = this.findRow( child );
    if ( YAHOO.util.Dom.hasClass( row, "highlight" ) ) {
        YAHOO.util.Dom.removeClass( row, "highlight" );
    }
};

/**
 * selectRow ( child )
 * Check the assetId checkbox in the row that contains the given child. 
 * Used when something in the row changes.
 */
WebGUI.Admin.Tree.prototype.selectRow 
= function ( child ) {
    // First find the row
    var node    = this.findRow( child );
    this.addHighlightToRow( child );

    // Now find the assetId checkbox in the first element
    var inputs   = node.getElementsByTagName( "input" );
    for ( var i = 0; i < inputs.length; i++ ) {
        if ( inputs[i].name == "assetId" ) {
            inputs[i].checked = true;
            break;
        }
    }
};

/**
 * showMoreMenu ( url, linkTextId )
 * Build a More menu for the last element of the Crumb trail
 */
WebGUI.Admin.Tree.prototype.showMoreMenu 
= function ( url, linkTextId, isNotLocked ) {
    return; // TODO
    var menu;
    if ( typeof this.crumbMoreMenu == "undefined" ) {
        var more    = document.getElementById(linkTextId);
        var options = this.buildMoreMenu(url, more, isNotLocked);
        menu    = new YAHOO.widget.Menu( "crumbMoreMenu", options );
        menu.render( document.getElementById( 'assetManager' ) );
        this.crumbMoreMenu = menu;
    }
    else {
        menu = this.crumbMoreMenu;
    }
    menu.show();
    menu.focus();
};

/**
 * toggleHighlightForRow ( checkbox )
 * Toggle the highlight for the row based on the state of the checkbox
 */
WebGUI.Admin.Tree.prototype.toggleHighlightForRow 
= function ( checkbox ) {
    if ( checkbox.checked ) {
        this.addHighlightToRow( checkbox );
    }
    else {
        this.removeHighlightFromRow( checkbox );
    }
};

/**
 * toggleRow ( child )
 * Toggles the entire row by finding the checkbox and doing what needs to be
 * done.
 */
WebGUI.Admin.Tree.prototype.toggleRow = function ( child ) {
    var row     = this.findRow( child );

    // Find the checkbox
    var inputs  = row.getElementsByTagName( "input" );
    for ( var i = 0; i < inputs.length; i++ ) {
        if ( inputs[i].name == "assetId" ) {
            inputs[i].checked   = inputs[i].checked
                                ? false
                                : true
                                ;
            this.toggleHighlightForRow( inputs[i] );
            break;
        }
    }
};

/****************************************************************************
 * WebGUI.Admin.AdminBar( id, cfg )
 * Initialize an adminBar with the given ID.
 *
 * Configuration:
 *      expandMax:      If true, will always expand pane to maximum space
 *
 * Custom Events:
 *      afterShow:      Fired after a new pane is shown.
 *          args:       id  - The ID of the new pane shown
 */
WebGUI.Admin.AdminBar
= function ( id, cfg ) {
    this.id     = id;
    this.cfg    = cfg || {};
    this.animDuration   = 0.25;
    this.dl     = document.getElementById( id );
    this.dt     = [];
    this.dd     = [];

    // Get all the DT and DD
    //  -- Using childNodes so we can nest another accordion inside
    for ( var i = 0; i < this.dl.childNodes.length; i++ ) {
        var node = this.dl.childNodes[i];
        if ( node.nodeName == "DT" ) {
            this.dt.push( node );
        }
        else if ( node.nodeName == "DD" ) {
            this.dd.push( node );
        }
    }

    // Add click handlers to DT to open corresponding DD
    this.dtById = {};
    this.ddById = {};
    for ( var i = 0; i < this.dt.length; i++ ) {
        var dt = this.dt[i];
        var dd = this.dd[i];

        // Make sure dd is hidden
        dd.style.display = "none";

        // Save references by ID
        this.dtById[ dt.id ] = dt;
        this.ddById[ dt.id ] = dd;

        this.addClickHandler( dt, dd );
    }

    // Precalculate dtHeight and maxHeight
    this.dtHeight   = this.getRealHeight( this.dt[0] ) * this.dt.length;
    this.maxHeight  = YAHOO.util.Dom.getViewportHeight() - this.dtHeight;

    // Add custom event when showing an AdminBar pane
    this.afterShow  = new YAHOO.util.CustomEvent("afterShow", this);
};

/**
 * addClickHandler( dt, dd )
 * Add the correct click handler on the dt to show the dd. 
 */
WebGUI.Admin.AdminBar.prototype.addClickHandler
= function ( dt, dd ) {
    var self = this;
    YAHOO.util.Event.on( dt, "click", function(){ self.show.call( self, dt.id ) } );
};

/**
 * getAnim( elem )
 * Get an Animation object for the given element to use for the transition.
 */
WebGUI.Admin.AdminBar.prototype.getAnim
= function ( elem ) {
    var anim = new YAHOO.util.Anim( elem );
    anim.duration  = this.animDuration;
    anim.method    = YAHOO.util.Easing.easeOut;
    return anim;
};

/**
 * getExpandHeight( elem )
 * Get the height to expand the element to.
 */
WebGUI.Admin.AdminBar.prototype.getExpandHeight
= function ( elem ) {
    if ( this.cfg.expandMax ) {
        return this.maxHeight;
    }

    var height  = this.getRealHeight( elem );

    // Make sure not more than maxHeight
    if ( height > this.maxHeight ) {
        return this.maxHeight;
    }
    return height;
};

/**
 * getRealHeight( elem ) 
 * Get the real height of the given element. 
 */
WebGUI.Admin.AdminBar.prototype.getRealHeight
= function ( elem ) {
    var D = YAHOO.util.Dom;
    var clipped = false;
    // We don't want 0 height!
    if ( parseInt( elem.style.height ) == 0 ) {
        elem.style.display = "none";
        elem.style.height = ""
    }
    if (elem.style.display == 'none') {
        clipped = true;
        var _pos = D.getStyle(elem, 'position');
        var _vis = D.getStyle(elem, 'visiblity');
        D.setStyle(elem, 'position', 'absolute');
        D.setStyle(elem, 'visiblity', 'hidden');
        D.setStyle(elem, 'display', 'block');
    }
    var height = elem.offsetHeight;
    if (height == 'auto') {
        //This is IE, let's fool it
        D.setStyle(elem, 'zoom', '1');
        height = elem.clientHeight;
    }
    if (clipped) {
        D.setStyle(elem, 'display', 'none');
        D.setStyle(elem, 'visiblity', _vis);
        D.setStyle(elem, 'position', _pos);
    }
    //Strip the px from the style
    return parseInt(height); 

};

/**
 * show( id )
 * Show the pane with the given ID. The ID is from the DT element.
 */
WebGUI.Admin.AdminBar.prototype.show
= function ( id ) {
    if ( this.currentId ) {
        // Close the current
        var old         = this.ddById[ this.currentId ];
        var oldHeight   = this.getExpandHeight( old );
        if ( !old.anim ) {
            old.anim = this.getAnim(this.current);
        }
        var hideContent = function() {
            // Hide old and restore height for next open
            old.style.display = "none";
            old.style.height  = oldHeight + 'px';
            old.anim.onComplete.unsubscribe( hideContent );
        };
        old.anim.onComplete.subscribe( hideContent, this, true );
        old.anim.attributes.height = { to : 0 };
        old.anim.animate();

        // Let user close by clicking again
        if ( this.currentId == id ) {
            this.currentId  = null;
            return;
        }
    }

    var dd  = this.ddById[ id ];

    if ( !dd.anim ) {
        dd.anim     = this.getAnim(dd);
    }
    dd.anim.attributes.height = { from: 0, to : this.getExpandHeight( dd ) };
    dd.style.height  = "0px";
    dd.style.display = "block";
    dd.anim.animate();
    this.currentId = id;

    this.afterShow.fire( id );

    // TODO: If we're nested inside another accordion-menu, fix 
    // the parent's height as we fix our own to avoid having to set
    // explicit height on parent
};


