

/**
 *  WebGUI.Admin -- The WebGUI Admin Console
 */
bind = function ( scope, func ) {
    return function() { func.apply( scope, arguments ) }
};

if ( typeof WebGUI == "undefined" ) {
    WebGUI = {};
}
WebGUI.Admin = function(cfg){
    var self = this;
    // Public properties
    this.cfg = cfg;
    this.currentAssetDef    = null;
    this.currentAssetId     = "";
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

    // TODO: This should be i18n
    this.localeMonths   = [
        'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August',
        'September', 'October', 'November', 'December'
    ];

    // Custom events
    this.afterNavigate = new YAHOO.util.CustomEvent( "afterNavigate", this );

    // Keep track of the view iframe
    var viewframe   = document.getElementById('adminViewFrame');
    // If it already loaded, run the right function
    if ( viewframe.hasLoaded && window.frames[viewframe.name].WG ) {
        this.navigate( window.frames[viewframe.name].WG.currentAssetId );
    }
    // Next and every subsequent time it loads, run the right function again
    YAHOO.util.Event.on( viewframe, 'load', function(){ 
        if ( window.frames[viewframe.name].WG ) {
            self.navigate( window.frames[viewframe.name].WG.currentAssetId );
        }
    } );
    this.afterNavigate.subscribe( function(){
        // Create the toolbars
        var viewframe   = document.getElementById('adminViewFrame');
        var viewWin     = window.frames[viewframe.name];
        // Inject some dependencies
        YAHOO.util.Get.css( [
                    getWebguiProperty( 'extrasURL' ) + 'yui/build/menu/assets/skins/sam/menu.css',
                    getWebguiProperty( 'extrasURL' ) + 'yui/build/button/assets/skins/sam/button.css'
                ],
                {
                    win : viewWin
                }
            );
        YAHOO.util.Get.script( [
                    getWebguiProperty( 'extrasURL' ) + 'yui/build/yahoo-dom-event/yahoo-dom-event.js',
                    getWebguiProperty( 'extrasURL' ) + 'yui/build/utilities/utilities.js',
                    getWebguiProperty( 'extrasURL' ) + 'yui/build/element/element-min.js',
                    getWebguiProperty( 'extrasURL' ) + 'yui/build/container/container-min.js',
                    getWebguiProperty( 'extrasURL' ) + 'yui/build/animation/animation-min.js',
                    getWebguiProperty( 'extrasURL' ) + 'yui/build/menu/menu-min.js',
                    getWebguiProperty( 'extrasURL' ) + 'yui/build/json/json-min.js',
                    getWebguiProperty( 'extrasURL' ) + 'yui/build/button/button-min.js',
                    getWebguiProperty( 'extrasURL' ) + 'yui/build/selector/selector-min.js',
                    getWebguiProperty( 'extrasURL' ) + 'admin/admin.js',
                    getWebguiProperty( 'extrasURL' ) + 'admin/toolbar.js'
                ],
                {
                    win : viewWin,
                    onSuccess : function(data) {
                        // We have to create these menus within the correct window context
                        data.win.WebGUI.Toolbar.createAll();
                    }
                }
            );
    }, this );

    // Private methods
    // Initialize these things AFTER the i18n is fetched
    var _init = function () {
        self.afterNavigate.subscribe( self.requestUpdateCurrentVersionTag, self );
        self.requestUpdateCurrentVersionTag();

        self.tabBar         = new YAHOO.widget.TabView( self.cfg.tabBarId );
        // Keep track of View and Tree tabs
        self.tabBar.getTab(0).addListener('click',self.afterShowViewTab,self,true);
        self.tabBar.getTab(1).addListener('click',self.afterShowTreeTab,self,true);

        self.tree           = new WebGUI.Admin.Tree(self);

        self.adminBar       = new WebGUI.Admin.AdminBar( self.cfg.adminBarId, { expandMax : true } );
        self.adminBar.afterShow.subscribe( self.updateAdminBar, self );
        YAHOO.util.Event.on( window, 'load', function(){ self.adminBar.show( self.adminBar.dt[0].id ) } );
        self.newContentBar  = new WebGUI.Admin.AdminBar( "newContentBar", { expandMax : true } );

        self.locationBar    = new WebGUI.Admin.LocationBar( self.cfg.locationBarId, {
            homeUrl : self.cfg.homeUrl
        } );
        self.afterNavigate.subscribe( self.locationBar.afterNavigate, self.locationBar );
    };

    // Get I18N
    this.i18n = new WebGUI.i18n( {
        namespaces : {
            'WebGUI' : [ '< prev', 'next >', 'locked by' ],
            'Asset'  : [ 'rank', '99', 'type', 'revision date', 'size', 'locked', 'More', 'unlocked', 'edit',
                         'update', 'delete', '43', 'cut', 'Copy', 'duplicate', 'create shortcut'
                       ]
        },
        onpreload : {
            fn : _init
        }
    } );


};

/**
 * getRealHeight( elem ) 
 * Get the real height of the given element. 
 */
WebGUI.Admin.getRealHeight
= function ( elem ) {
    var D = YAHOO.util.Dom;
    var _pos = D.getStyle(elem, 'position');
    var _vis = D.getStyle(elem, 'visibility');
    var clipped = false;
    // We don't want 0 height!
    if ( parseInt( elem.style.height ) == 0 ) {
        elem.style.display = "none";
        elem.style.height = ""
    }
    if (elem.style.display == 'none') {
        clipped = true;
        D.setStyle(elem, 'position', 'absolute');
        D.setStyle(elem, 'visibility', 'hidden');
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
        D.setStyle(elem, 'visibility', _vis);
        D.setStyle(elem, 'position', _pos);
    }
    //Strip the px from the style
    return parseInt(height); 

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
    this.showView( appendToUrl( url, "func=edit" ) );
};

/**
 * gotoAsset( url )
 * Open the appropriate tab (View or Tree) and go to the given asset URL
 */
WebGUI.Admin.prototype.gotoAsset
= function ( url ) {
    if ( this.tabBar.get('activeIndex') > 1 ) {
        this.tabBar.selectTab( 0 );
        this.currentTab = "view";
    }
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
 * showView ( [url] )
 * Open the view tab, optionally navigating to the given URL
 */
WebGUI.Admin.prototype.showView
= function (url) {
    // Show the view tab
    this.tabBar.selectTab( 0 );
    this.currentTab = "view";

    if ( url ) {
        // Open the URL
        window.frames["view"].location.href = url;

        // Mark undirty, as we'll clean it ourselves
        this.viewDirty = 0;
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
= function ( assetId ) {
    // Don't do the same asset twice
    if ( this.currentAssetId && this.currentAssetId == assetId ) {
        // But still fire the event
        this.afterNavigate.fire( this.currentAssetDef );
        return;
    }

    if ( !this.currentAssetId || this.currentAssetId != assetId ) {
        // request asset update
        this.currentAssetId = assetId;
        var self = this;
        this.requestAssetDef( assetId, function( assetDef ) {
            self.currentAssetDef = assetDef;
            self.treeDirty = 1;
            self.updateAssetHelpers( assetDef );
            self.updateAssetHistory( assetDef );

            // Fire event
            this.afterNavigate.fire( assetDef );
        } );
    }
};

/**
 * requestAssetDef( assetId, callback )
 * Request more information about an asset. The callback takes a single
 * argument which is an object containing the asset information and is 
 * called in the scope of the admin function
 */
WebGUI.Admin.prototype.requestAssetDef
= function ( assetId, callback ) {
    var connectCallback = {
        success : function (o) {
            var assetDef = YAHOO.lang.JSON.parse( o.responseText );
            callback.call( this, assetDef );
        },
        failure : function (o) {

        },
        scope: this
    };

    var url = '?op=admin;method=getAssetData;assetId=' + assetId;
    var ajax = YAHOO.util.Connect.asyncRequest( 'GET', url, connectCallback );
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
        admin.requestUpdateVersionTags.call( admin );
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
    var url = appendToUrl( this.currentAssetDef.url, 'func=pasteList&assetId=' + id );
    console.log(url);
    this.gotoAsset( url );
};

/**
 * requestUpdateVersionTags( )
 * Request the new set of version tags from the server
 */
WebGUI.Admin.prototype.requestUpdateVersionTags
= function ( ) {
    var callback = {
        success : function (o) {
            var versionTags = YAHOO.lang.JSON.parse( o.responseText );
            this.updateVersionTags( versionTags );
        },
        failure : function (o) {

        },
        scope: this
    };

    var ajax = YAHOO.util.Connect.asyncRequest( 'GET', '?op=admin;method=getVersionTags', callback );
};

/**
 * updateVersionTags( tags )
 * Update the version tag list with the given tags
 */
WebGUI.Admin.prototype.updateVersionTags
= function ( tags ) {
    // Clear out the old tags
    var div = document.getElementById( 'versionTagItems' );
    while ( div.childNodes.length > 0 ) {
        div.removeChild( div.childNodes[0] );
    }

    for ( var i = 0; i < tags.length; i++ ) {
        var tag     = tags[i];
        var a       = document.createElement('a');
        var icon    = document.createElement('img');
        icon.src    = tag.icon;
        a.appendChild( icon );
        a.appendChild( document.createTextNode( tag.name ) );
        div.appendChild( a );
        this.addJoinTagHandler( a, tag.tagId );
        if ( tag.isCurrent ) {
            this.updateCurrentVersionTag( tag );
        }
    }
};

/**
 * addJoinTagHandler( elem, tagId )
 * Add an onclick handler to join a version tag
 */
WebGUI.Admin.prototype.addJoinTagHandler
= function ( elem, tagId ) {
    var self    = this;
    YAHOO.util.Event.on( elem, "click", function(){
        // Update version tags after join in case paste fails
        var updateAfterJoin = function(){
            this.requestUpdateVersionTags();
            this.afterNavigate.unsubscribe( updateAfterJoin );
        };
        self.afterNavigate.subscribe(updateAfterJoin, self );
        self.joinTag( tagId );
    }, self );
};

/**
 * joinTag( id )
 * Join a new version tag
 */
WebGUI.Admin.prototype.joinTag
= function ( id ) {
    var url = appendToUrl( this.currentAssetDef.url, 'op=setWorkingVersionTag;tagId=' + id );
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
    typeEl.innerHTML = assetDef.className;

    // Clear old helpers
    var helperEl    = document.getElementById( 'helper_list' );
    while ( helperEl.childNodes.length > 0 ) {
        helperEl.removeChild( helperEl.childNodes[0] );
    }

    // Add new ones
    for ( var helperId in assetDef.helpers ) {
        var helper  = assetDef.helpers[helperId];
        var li      = document.createElement('li');
        li.className = "clickable with_icon";
        li.appendChild( document.createTextNode( helper.label ) );
        YAHOO.util.Event.on( li, "click", this.getHelperHandler( this.currentAssetId, helperId, helper ) );
        helperEl.appendChild( li );
    }
};

/**
 * getHelperHandler( helperId, helper )
 * Get a function to handle the helper
 */
WebGUI.Admin.prototype.getHelperHandler
= function ( assetId, helperId, helper ) {
    if ( helper.url ) {
        return bind( this, function(){ 
            this.gotoAsset( helper.url ) 
        } );
    }

    return bind( this, function(){ 
        this.requestHelper( helperId, assetId ) 
    } );
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
 * requestHelper( helperId, assetId )
 * Request the Asset Helper for the given assetId
 */
WebGUI.Admin.prototype.requestHelper
= function ( helperId, assetId ) {
    var callback = {
        success : function (o) {
            var resp = YAHOO.lang.JSON.parse( o.responseText );
            this.processPlugin( resp );
        },
        failure : function (o) {

        },
        scope: this
    };

    var url = '?op=admin;method=processAssetHelper;helperId=' + helperId + ';assetId=' + assetId;
    var ajax = YAHOO.util.Connect.asyncRequest( 'GET', url, callback );
};

/**
 * processPlugin( response )
 * Process the plugin response. Possible responses include:
 *      message     : A message to the user
 *      error       : An error message
 *      openDialog  : Open a dialog with the given URL
 *      openTab     : Open a tab with the given URL
 *      redirect    : Redirect the View pane to the given URL
 *      forkId      : The Helper forked a process, use the ID to get the status
 *      scriptFile  : Load a JS file
 *      scriptFunc  : Run a JS function. Used with scriptFile
 *      scriptArgs  : Arguments to scriptFunc. Used with scriptFile
 */
WebGUI.Admin.prototype.processPlugin
= function ( resp ) {
    if ( resp.openTab ) {
        this.openTab( resp.openTab );
    }
    else if ( resp.openDialog ) {
        this.openModalDialog( resp.openDialog, resp.width, resp.height );
    }
    else if ( resp.scriptFile ) {
        this.loadAndRun( resp.scriptFile, resp.scriptFunc, resp.scriptArgs );
    }
    else if ( resp.message ) {
        this.showInfoMessage( resp.message );
    }
    else if ( resp.error ) {
        this.showInfoMessage( resp.error );
    }
    else if ( resp.forkId ) {
        this.openForkDialog( resp.forkId );
    }
    else if ( resp.redirect ) {
        this.gotoAsset( resp.redirect );
    }
    else {
        alert( "Unknown plugin response: " + YAHOO.lang.JSON.stringify(resp) );
    }
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
        clearTimeout( this.infoMessageTimeout );
    }

    var info    = document.getElementById( 'infoMessage' );
    info.innerHTML = message;

    var infoContainer   = document.getElementById( 'infoMessageContainer' );
    var newHeight       = WebGUI.Admin.getRealHeight( infoContainer );
    infoContainer.style.height   = newHeight + 'px';
    infoContainer.style.top      = -1 * newHeight + 'px';
    infoContainer.style.display  = "block";

    var anim = new YAHOO.util.Anim( infoContainer );
    anim.duration  = 0.25;
    anim.method    = YAHOO.util.Easing.easeOut;
    anim.attributes.top = { to: 0 };
    anim.animate();

    this.infoMessageTimeout = setTimeout( this.hideInfoMessage, 3000 );
};

/** 
 * hideInfoMessage( )
 * Hide the informative message from showInfoMessage()
 */
WebGUI.Admin.prototype.hideInfoMessage
= function ( ) {
    var infoContainer   = document.getElementById( 'infoMessageContainer' );
    infoContainer.style.display  = "none";
};

/**
 * openForkDialog( forkId )
 * Open a dialog to show a progress bar for the forked process
 */
WebGUI.Admin.prototype.openForkDialog
= function ( forkId ) {
    // Open the dialog with a progress bar
    var dialog  = new YAHOO.widget.Panel( 'forkModalDialog', {
        "width"             : '350px',
        fixedcenter         : true,
        constraintoviewport : true,
        underlay            : "shadow",
        close               : true,
        visible             : true,
        draggable           : false
    } );
    dialog.setBody( 
        '<div id="pbTask"></div><div id="pbTaskStatus">Starting...</div>'
    );
    dialog.render( document.body );
    this.treeDialog = dialog;

    var pbTaskBar = new YAHOO.widget.ProgressBar({
        minValue : 0,
        value : 0,
        maxValue : 1,
        width: '300px',
        height: '30px',
        anim: true
    });
    pbTaskBar.render( 'pbTask' );
    pbTaskBar.get('anim').duration = 0.5;
    pbTaskBar.get('anim').method = YAHOO.util.Easing.easeOut;

    YAHOO.WebGUI.Fork.poll({
        url     : '?op=fork;pid=' + forkId,
        draw    : function(data) {
            var status = YAHOO.lang.JSON.parse( data.status );
            if ( status ) {
                pbTaskBar.set( 'maxValue', status.total );
                pbTaskBar.set( 'value', status.finished );
                document.getElementById( 'pbTaskStatus' ).innerHTML = status.message;
            }
        },
        finish  : function(data){
            var status = YAHOO.lang.JSON.parse( data.status );
            if ( status.redirect ) {
                alert("Dispensing product...");
                window.admin.gotoAsset( status.redirect );
            }
            dialog.destroy();
            dialog = null;
            // TODO: Handle the last request of the forked process
        },
        error : function(e){
            alert("Error: " + e);
        }
    });
};

/**
 * addNewContent( urlFragment )
 * Add new content by visiting the given URL fragment
 */
WebGUI.Admin.prototype.addNewContent
= function ( urlFragment ) {
    this.gotoAsset( appendToUrl( this.currentAssetDef.url, urlFragment ) );
};

/**
 * updateAssetHistory( assetDef )
 * Update the history list of the current asset
 */
WebGUI.Admin.prototype.updateAssetHistory
= function ( assetDef ) {
    // Clear old revisions
    var historyEl    = document.getElementById( 'history_list' );
    while ( historyEl.childNodes.length > 0 ) {
        historyEl.removeChild( historyEl.childNodes[0] );
    }

    var now = new Date();
    // Add new ones
    for ( var i = 0; i < assetDef.revisions.length; i++ ) {
        var revisionDate    = assetDef.revisions[i];
        var li              = document.createElement('li');
        li.className        = "clickable with_icon";

        // Create a descriptive date string
        var rDate           = new Date( revisionDate * 1000 ); // JS requires milliseconds
        var minutes         = rDate.getMinutes();
        minutes     = minutes < 10 ? "0" + minutes : minutes;

        var dateString;
        // Last year or older
        if ( rDate.getFullYear() < now.getFullYear() ) {
            dateString  = this.localeMonths[rDate.getMonth()] + " " + rDate.getDate() + ", "
                        + rDate.getFullYear();
        }
        // Earlier this year
        else if ( rDate.getMonth() < now.getMonth() || rDate.getDate() < now.getDate() - 1 ) { 
            dateString  = this.localeMonths[rDate.getMonth()] + " " + rDate.getDate() + " " 
                        + rDate.getHours() + ":" + minutes;
        }
        // Yesterday
        else if ( rDate.getDate() < now.getDate() ) {
            dateString  = "Yesterday " + rDate.getHours() + ":" + minutes;
        }
        // Today
        else {
            dateString  = "Today " + rDate.getHours() + ":" + minutes;
        }

        li.appendChild( document.createTextNode( dateString ) );
        this.addHistoryHandler( li, assetDef, revisionDate );
        historyEl.appendChild( li );
    }
};

/**
 * addHistoryHandler( elem, revisionDate )
 * Add the click handler to view the desired revision
 */
WebGUI.Admin.prototype.addHistoryHandler
= function ( elem, assetDef, revisionDate ) {
    var self = this;
    var url  = appendToUrl( assetDef.url, 'func=view;revision=' + revisionDate );
    YAHOO.util.Event.on( elem, "click", function(){ self.gotoAsset( url ) }, self, true );
};

/**
 * openTab ( url )
 * Open a new tab with an iframe and the given URL
 */
WebGUI.Admin.prototype.openTab
= function ( url ) {
    // Prepare the iframe first
    var iframe = document.createElement( 'iframe' );
    iframe.src = url;
    YAHOO.util.Event.on( iframe, 'load', function(){ this.updateTabLabel(newTab); }, this, true );

    // Prepare the tab
    var newTab = new YAHOO.widget.Tab({
        label : "Loading...",
        content : ''
    });
    newTab.get('contentEl').appendChild( iframe );

    // Fire when ready, Gridley
    this.tabBar.addTab( newTab );

};

/**
 * updateTabLabel( tab )
 * Update the tab's label with the title from the iframe inside
 */
WebGUI.Admin.prototype.updateTabLabel
= function ( tab ) {
    // Find the iframe
    var iframe = tab.get('contentEl').getElementsByTagName( 'iframe' )[0];
    var title = iframe.contentDocument.title;
    tab.set( 'label', title );
};

/**
 * getHelperMenuItems( assetId, helpers )
 * Get the items to create a menu for the given helpers
 */
WebGUI.Admin.prototype.getHelperMenuItems
= function ( assetId, helpers ) {
    var items = [];

    // Add all the items with appropriate onclick handlers
    for ( var i in helpers ) {
        var helper = helpers[i];
        var item   = {
            onclick : {
                fn : this.getHelperHandler( assetId, i, helper ),
                scope : this
            },
            text : helper["label"],
            icon : helper["icon"]
        };
        items.push( item );
    }

    return items;
};

/**
 * showHelperMenu( elem, assetId, helpers )
 * Show a pop-up Helper menu for the given assetId with the given helpers
 */
WebGUI.Admin.prototype.showHelperMenu 
= function ( elem, assetId, helpers ) {
    if ( this.helperMenu ) {
        // destroy the old helper menu!
        this.helperMenu.destroy();
    }
    var helperMenu = new YAHOO.widget.Menu( document.createElement('div'), {
        position : "dynamic",
        clicktohide : true,
        constraintoviewport : true,
        items : this.getHelperMenuItems( assetId, helpers ),
        context : [ elem, 'tl', 'bl' ],
        effect: { effect: YAHOO.widget.ContainerEffect.FADE, duration:0.25 }
    } );
    this.helperMenu.render( document.body );
    this.helperMenu.show();
    this.helperMenu.focus();
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
    this.filters            = [ ];  // search filters

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
    this.btnSearchDialog  = new YAHOO.widget.Button( "searchDialogButton", {
        label       : '<img src="' + getWebguiProperty("extrasURL") + 'icon/magnifier.png" />',
        onclick     : { fn: this.createSearchTab, scope: this }
    } );
    this.btnHome    = new YAHOO.widget.Button( "homeButton", {
        type        : "button",
        label       : '<img src="' + getWebguiProperty("extrasURL") + 'icon/house.png" />',
        onclick     : { fn: this.goHome, scope: this }
    } );

    // Take control of the location input
    this.klInput = new YAHOO.util.KeyListener( "locationInput", { keys: 13 }, {
        fn: this.doInputSearch,
        scope: this,
        correctScope: true
    } );
    YAHOO.util.Event.addListener( "locationInput", "focus", this.inputFocus, this, true );
    YAHOO.util.Event.addListener( "locationInput", "blur", this.inputBlur, this, true );

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
    var input = document.getElementById("locationInput").value;
    // If input starts with a / it's a URL
    if ( input.match(/^\//) ) {
        // If it doesn't have a ?, just go to the asset
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
        this.requestSearch();
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
    var input = document.getElementById( "locationInput" );
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

/**
 * goHome ( )
 * Go to the correct home URL
 */
WebGUI.Admin.LocationBar.prototype.goHome
= function ( ) {
    window.admin.gotoAsset( this.cfg.homeUrl );
};

/**
 * createSearchTab ( )
 * Create a new search tab and clone the searchForm node into it
 */
WebGUI.Admin.LocationBar.prototype.createSearchTab
= function ( ) {
    new WebGUI.Admin.Search( window.admin, {} );
};

/****************************************************************************
 *
 * WebGUI.Admin.AssetTable
 * Display a table of assets. Extend this to create your own display 
 * Used by AssetTable and Search
 */
WebGUI.Admin.AssetTable
= function ( admin, cfg ) {
    this.admin  = admin;
    this.cfg    = cfg;

    var selectAllCheck = document.createElement( 'input' );
    this.selectAllCheck = selectAllCheck;
    selectAllCheck.type = "checkbox";
    // Add the event handler in onDataTableInitializeRows because innerHTML won't
    // save event handlers

    // Create a span so we can get innerHTML to put in DataTable's label
    var selectAllSpan = document.createElement( 'span' );
    selectAllSpan.appendChild( selectAllCheck );

    this.defaultSortBy = {
        "key"       : "lineage",
        "dir"       : YAHOO.widget.DataTable.CLASS_ASC
    };

    this.paginator = new YAHOO.widget.Paginator({
        containers            : this.cfg.paginatorIds,
        pageLinks             : 7,
        rowsPerPage           : 100,
        previousPageLinkLabel : window.admin.i18n.get('WebGUI', '< prev'),
        nextPageLinkLabel     : window.admin.i18n.get('WebGUI', 'next >'),
        template              : "{PreviousPageLink} <strong>{CurrentPageReport}</strong> {NextPageLink}"
    });

   // initialize the data source
   this.dataSource
        = new YAHOO.util.DataSource( this.cfg.dataSourceUrl, {connTimeout:30000} );
   this.dataSource.responseType
        = YAHOO.util.DataSource.TYPE_JSON;
   this.dataSource.responseSchema
        = {
            resultsList: 'assets',
            fields: [
                { key: 'assetId' },
                { key: 'lineage' },
                { key: 'canEdit' },
                { key: 'helpers' },
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
            {
                key: 'assetId', 
                label: selectAllSpan.innerHTML, 
                formatter: bind( this, this.formatAssetIdCheckbox )
            },
            { 
                key: 'helpers', 
                label: "", 
                formatter: bind( this, this.formatHelpers )
            },
            { 
                key: 'title', 
                label: window.admin.i18n.get('Asset', '99'), 
                formatter: bind( this, this.formatTitle ),
                sortable: true 
            },
            { 
                key: 'className', 
                label: window.admin.i18n.get('Asset','type'), 
                sortable: true, 
                formatter: bind( this, this.formatClassName )
            },
            { 
                key: 'revisionDate', 
                label: window.admin.i18n.get('Asset','revision date' ), 
                formatter: bind( this, this.formatRevisionDate ), 
                sortable: true 
            },
            { 
                key: 'assetSize', 
                label: window.admin.i18n.get('Asset','size' ), 
                formatter: bind( this, this.formatAssetSize ),
                sortable: true 
            },
            { 
                key: 'lockedBy', 
                label: '<img src="' + window.getWebguiProperty('extrasURL') + '/icon/lock.png" />', 
                formatter: bind( this, this.formatLockedBy )
            }
        ];
};

/**
 * init ( )
 * Initialize the datatable with the columns we have.
 * You must call this after all the columnDefs are situated
 */
WebGUI.Admin.AssetTable.prototype.init
= function ( ) {
    // Initialize the data table
    this.dataTable
        = new YAHOO.widget.ScrollingDataTable( this.cfg.dataTableId, 
            this.columnDefs,
            this.dataSource, 
            {
                initialLoad             : false,
                dynamicData             : true,
                paginator               : this.paginator,
                sortedBy                : this.defaultSortedBy,
                generateRequest         : this.buildQueryString
            }
        );

    this.dataTable.handleDataReturnPayload
        = function(oRequest, oResponse, oPayload) {
            oPayload.totalRecords = oResponse.meta.totalRecords;
            return oPayload;
        };
}

/**
 * formatHelpers ( )
 * Format the Edit and More links for the row
 */
WebGUI.Admin.AssetTable.prototype.formatHelpers
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

    var more    = document.createElement( 'span' );
    more.className = 'clickable';
    elCell.appendChild( more );
    more.appendChild( document.createTextNode( window.admin.i18n.get('Asset','More' ) ) );
    more.href   = '#';

    // Build onclick handler to show more menu
    this.addMenuOpenHandler( more, oRecord.getData( 'assetId' ), oRecord.getData( 'helpers' ) );
};

/**
 * addMenuOpenHandler( elem, assetId, helpers ) 
 * Add a handler that will open a menu for the given assetId with the given
 * helpers
 */
WebGUI.Admin.AssetTable.prototype.addMenuOpenHandler
= function ( elem, assetId, helpers ) {
    var self = this;
    YAHOO.util.Event.addListener( elem, "click", function(){
        self.showHelperMenu( elem, assetId, helpers );
    } );
};

/**
 * formatAssetIdCheckbox ( )
 * Format the checkbox for the asset ID.
 */
WebGUI.Admin.AssetTable.prototype.formatAssetIdCheckbox
= function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = '<input type="checkbox" name="assetId" value="' + oRecord.getData("assetId") + '"'
        + ' />';
    // TODO: Add onchange handler to toggle checkbox
};

/**
 * formatAssetSize ( )
 * Format the asset class name
 */
WebGUI.Admin.AssetTable.prototype.formatAssetSize 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = oRecord.getData( "assetSize" );
};

/**
 * formatClassName ( )
 * Format the asset class name
 */
WebGUI.Admin.AssetTable.prototype.formatClassName 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = '<img src="' + oRecord.getData( 'icon' ) + '" /> '
        + oRecord.getData( "className" );
};

/**
 * formatLockedBy ( )
 * Format the locked icon
 */
WebGUI.Admin.AssetTable.prototype.formatLockedBy 
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
WebGUI.Admin.AssetTable.prototype.formatRank 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    var rank    = oRecord.getData("lineage").match(/[1-9][0-9]{0,5}$/); 
    var input   = document.createElement( 'input' );
    input.type  = "text";
    input.id    = oRecord.getData("assetId") + '_rank';
    input.name  = input.id;
    input.size  = 3;
    input.value = rank;

    YAHOO.util.Event.addListener( input, "change", function(){ this.selectRow(elCell); }, this, true );
    elCell.appendChild( input );
};

/**
 * formatRevisionDate ( )
 * Format the asset class name
 */
WebGUI.Admin.AssetTable.prototype.formatRevisionDate 
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
WebGUI.Admin.AssetTable.prototype.formatTitle 
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
 * onDataReturnInitializeTable( request, response, payload )
 * Initialize the datatable
 */
WebGUI.Admin.AssetTable.prototype.onDataReturnInitializeTable
= function ( sRequest, oResponse, oPayload ) {

    this.dataTable.onDataReturnInitializeTable.call( this.dataTable, sRequest, oResponse, oPayload );

    YAHOO.util.Event.addListener( this.selectAllCheck, "click", this.toggleAllRows, this, true );
};

/**
 * toggleAllRows( )
 * Toggle all the rows in the data table to the state of the Select All 
 * Checkbox
 */
WebGUI.Admin.AssetTable.prototype.toggleAllRows
= function ( ) {
    var state   = this.selectAllCheck.checked ? true : false;
    var row = this.dataTable.getFirstTrEl();
    while ( row ) {
        if ( state ) { 
            this.selectRow( row );
        }
        else {
            this.deselectRow( row );
        }
        row = this.dataTable.getNextTrEl( row );
    }
};


/**
 * removeHighlightFromRow ( child )
 * Remove the highlight from a row by removing the "highlight" class.
 */
WebGUI.Admin.AssetTable.prototype.removeHighlightFromRow
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
WebGUI.Admin.AssetTable.prototype.selectRow 
= function ( child ) {
    this.addHighlightToRow( child );
    this.findCheckbox( this.findRow( child ) ).checked = true;
};

/**
 * deselectRow( child )
 * Uncheck the checkbox and toggle the highlight
 */
WebGUI.Admin.AssetTable.prototype.deselectRow
= function ( child ) {
    this.removeHighlightFromRow( child );
    this.findCheckbox( this.findRow( child ) ).checked = false;
};

/**
 * toggleHighlightForRow ( checkbox )
 * Toggle the highlight for the row based on the state of the checkbox
 */
WebGUI.Admin.AssetTable.prototype.toggleHighlightForRow 
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
WebGUI.Admin.AssetTable.prototype.toggleRow = function ( child ) {
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

/**
 * findRow ( child )
 * Find the row that contains this child element.
 */
WebGUI.Admin.AssetTable.prototype.findRow
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
 * findCheckbox( row )
 * Find the checkbox in the row for the assetId field
 */
WebGUI.Admin.AssetTable.prototype.findCheckbox
= function ( row ) {
    var inputs   = row.getElementsByTagName( "input" );
    for ( var i = 0; i < inputs.length; i++ ) {
        if ( inputs[i].name == "assetId" ) {
            return inputs[i];
        }
    }
};

/**
 * addHighlightToRow ( child )
 * Highlight the row containing this element by adding to it the "highlight"
 * class
 */
WebGUI.Admin.AssetTable.prototype.addHighlightToRow 
= function ( child ) {
    var row     = this.findRow( child );
    if ( !YAHOO.util.Dom.hasClass( row, "highlight" ) ) {
        YAHOO.util.Dom.addClass( row, "highlight" );
    }
};

/** 
 * buildQueryString( state, dt )
 * Build the query string for the datasource
 */
WebGUI.Admin.AssetTable.prototype.buildQueryString
= function ( state, dt ) {
    var recordOffset    = state.pagination ? state.pagination.recordOffset : 0;
    var rowsPerPage     = state.pagination ? state.pagination.rowsPerPage : 0;
    var orderByColumn   = state.sortedBy ? state.sortedBy.key : "lineage";
    var orderByDir      = state.sortedBy 
                        ? ( (state.sortedBy.dir === YAHOO.widget.DataTable.CLASS_DESC) ? "DESC" : "ASC" )
                        : "ASC"
                        ;

    var query = "recordOffset=" + recordOffset
        + ';orderByDirection=' + orderByDir
        + ';rowsPerPage=' + rowsPerPage
        + ';orderByColumn=' + orderByColumn
        ;

    return query;
};

/**
 * getSelected( )
 * Return an array of the selected asset IDs
 */
WebGUI.Admin.AssetTable.prototype.getSelected
= function ( ) {
    var assetIds = [];
    var row = this.dataTable.getFirstTrEl();
    while ( row ) {
        var check = this.findCheckbox( row );
        if ( check.checked ) {
            assetIds.push( check.value );
        }
        row = this.dataTable.getNextTrEl( row );
    }
    return assetIds;
};

/****************************************************************************
 *
 * WebGUI.Admin.Tree
 */
WebGUI.Admin.Tree
= function(admin) {
    WebGUI.Admin.Tree.superclass.constructor.call( this, admin, {
        dataSourceUrl   : '?op=admin;method=getTreeData;',
        dataTableId     : 'treeDataTableContainer',
        paginatorIds    : [ 'treePagination' ]
    } );

    // Add Rank column for ordering
   this.columnDefs.splice( 1, 0, {
        key: 'lineage', 
        label: window.admin.i18n.get('Asset','rank'), 
        sortable: true, 
        formatter: bind( this, this.formatRank )
    } );

    // Add button behaviors
    this.btnUpdate  = new YAHOO.widget.Button( "treeUpdate", {
        type        : "button",
        label       : window.admin.i18n.get('Asset','update'),
        onclick     : { fn: this.update, scope: this }
    } );

    this.btnDelete  = new YAHOO.widget.Button( "treeDelete", {
        type        : "button",
        label       : window.admin.i18n.get('Asset','delete'),
        onclick     : { fn: this.delete, scope: this }
    } );

    this.btnCut     = new YAHOO.widget.Button( "treeCut", {
        type        : "button",
        label       : window.admin.i18n.get('Asset','cut'),
        onclick     : { fn: this.cut, scope: this }
    } );

    this.btnCopy    = new YAHOO.widget.Button( "treeCopy", {
        type        : "button",
        label       : window.admin.i18n.get('Asset','Copy'),
        onclick     : { fn: this.copy, scope: this }
    } );

    this.btnDuplicate = new YAHOO.widget.Button( "treeDuplicate", {
        type        : "button",
        label       : window.admin.i18n.get('Asset','duplicate'),
        onclick     : { fn: this.duplicate, scope: this }
    } );

    this.btnCreateShortcut  = new YAHOO.widget.Button( "treeCreateShortcut", {
        type        : "button",
        label       : window.admin.i18n.get('Asset','create shortcut'),
        onclick     : { fn: this.shortcut, scope: this }
    } );

    this.init();
};
YAHOO.lang.extend( WebGUI.Admin.Tree, WebGUI.Admin.AssetTable );

/**
 * runHelperForSelected( helperId )
 * Run the named asset helper for each selected asset
 * Show the status of the task in a dialog box
 */
WebGUI.Admin.Tree.prototype.runHelperForSelected
= function ( helperId, title ) {
    var self = this;
    var assetIds = this.getSelected();

    // Open the dialog with two progress bars
    var dialog  = new YAHOO.widget.Panel( 'helperForkModalDialog', {
        "width"             : '350px',
        fixedcenter         : true,
        constraintoviewport : true,
        underlay            : "shadow",
        close               : true,
        visible             : true,
        draggable           : false
    } );
    dialog.setHeader( title );
    dialog.setBody( 
        '<div id="pbQueue"></div><div id="pbQueueStatus">0 / ' + assetIds.length + '</div>'
        + '<div id="pbTask"></div><div id="pbTaskStatus"></div>'
    );
    dialog.render( document.body );
    this.treeDialog = dialog;

    var pbQueueBar = new YAHOO.widget.ProgressBar({
        minValue : 0,
        value : 0,
        maxValue : assetIds.length,
        width: '300px',
        height: '30px',
        anim: true
    });
    pbQueueBar.render( 'pbQueue' );
    pbQueueBar.get('anim').duration = 0.5;
    pbQueueBar.get('anim').method = YAHOO.util.Easing.easeOut;
    var pbQueueStatus = document.getElementById( 'pbQueueStatus' );

    var pbTaskBar = new YAHOO.widget.ProgressBar({
        minValue : 0,
        value : 0,
        maxValue : 1,
        width: '300px',
        height: '30px',
        anim: true
    });
    pbTaskBar.render( 'pbTask' );
    pbTaskBar.get('anim').duration = 0.5;
    pbTaskBar.get('anim').method = YAHOO.util.Easing.easeOut;

    // Clean up when we're done
    var finish = function () {
        dialog.destroy();
        dialog = null;
        self.admin.requestUpdateClipboard();
        self.admin.requestUpdateCurrentVersionTag();
        self.goto( self.admin.currentAssetDef.url );
    };

    // Build a function to call the helper for the next asset
    var callHelper = function( assetIds ) {
        var assetId = assetIds.shift();

        var callback = {
            success : function (o) {
                var resp = YAHOO.lang.JSON.parse( o.responseText );

                if ( resp.error ) {
                    this.admin.processPlugin( resp );
                    finish();
                }
                else if ( resp.forkId ) {
                    // Wait until the helper is done, then call the next
                    YAHOO.WebGUI.Fork.poll({
                        url     : '?op=fork;pid=' + resp.forkId,
                        draw    : function(data) {
                            pbTaskBar.set( 'maxValue', data.total );
                            pbTaskBar.set( 'value', data.finished );
                        },
                        finish  : function(){
                            pbQueueBar.set( 'value', pbQueueBar.get('value') + 1 );
                            pbQueueStatus.innerHTML = pbQueueBar.get('value') + ' / ' + pbQueueBar.get('maxValue');
                            if ( assetIds.length > 0 ) {
                                callHelper( assetIds );
                            }
                            else {
                                // We're all done now!
                                finish();
                            }
                        },
                    });
                }
                else {
                    // Just go to the next one
                    if ( assetIds.length > 0 ) {
                        callHelper( assetIds );
                    }
                    else {
                        finish();
                    }
                }
            },
            failure : function (o) {

            },
            scope: this
        };

        var url = '?op=admin;method=processAssetHelper;helperId=' + helperId + ';assetId=' + assetId;
        var ajax = YAHOO.util.Connect.asyncRequest( 'GET', url, callback );
    };

    // Start the queue
    callHelper( assetIds );
};

/**
 * cut( e )
 * Run the cut assethelper for the selected assets
 */
WebGUI.Admin.Tree.prototype.cut
= function ( e ) {
    this.runHelperForSelected( "cut", "Cut" );
};

/**
 * copy( e )
 * Run the Copy assethelper for the selected assets
 */
WebGUI.Admin.Tree.prototype.copy
= function ( e ) {
    this.runHelperForSelected( "copy", "Copy" );
};

/**
 * shortcut( e )
 * Run the shortcut assethelper for the selected assets
 */
WebGUI.Admin.Tree.prototype.shortcut
= function ( e ) {
    this.runHelperForSelected( "shortcut", "Create Shortcut" );
};

/**
 * Run the duplicate assethelper for the selected assets
 */
WebGUI.Admin.Tree.prototype.duplicate
= function ( e ) {
    this.runHelperForSelected( "duplicate", "Duplicate" );
};

/**
 * Run the delete assetHelper for the selected assets
 */
WebGUI.Admin.Tree.prototype.delete
= function ( e ) {
    this.runHelperForSelected( "delete", "Delete" );
};

/**
 * Update the selected assets' ranks
 */
WebGUI.Admin.Tree.prototype.update
= function ( e ) {
    var self = this;
    var assetIds = this.getSelected();

    // Open the dialog with two progress bars
    var dialog  = new YAHOO.widget.Panel( 'adminModalDialog', {
        "width"             : '350px',
        fixedcenter         : true,
        constraintoviewport : true,
        underlay            : "shadow",
        close               : true,
        visible             : true,
        draggable           : false
    } );
    dialog.setHeader( "Updating" );
    dialog.setBody( 
        '<div id="pbQueue"></div><div id="pbQueueStatus">0 / ' + assetIds.length + '</div>'
        + '<div id="pbTask"></div><div id="pbTaskStatus"></div>'
    );
    dialog.render( document.body );
    this.treeDialog = dialog;

    var pbQueueBar = new YAHOO.widget.ProgressBar({
        minValue : 0,
        value : 0,
        maxValue : assetIds.length,
        width: '300px',
        height: '30px',
        anim: true
    });
    pbQueueBar.render( 'pbQueue' );
    pbQueueBar.get('anim').duration = 0.5;
    pbQueueBar.get('anim').method = YAHOO.util.Easing.easeOut;
    var pbQueueStatus = document.getElementById( 'pbQueueStatus' );

    var pbTaskBar = new YAHOO.widget.ProgressBar({
        minValue : 0,
        value : 0,
        maxValue : 1,
        width: '300px',
        height: '30px',
        anim: true
    });
    pbTaskBar.render( 'pbTask' );
    pbTaskBar.get('anim').duration = 0.5;
    pbTaskBar.get('anim').method = YAHOO.util.Easing.easeOut;

    // Clean up when we're done
    var finish = function () {
        dialog.destroy();
        dialog = null;
        self.admin.requestUpdateClipboard();
        self.admin.requestUpdateCurrentVersionTag();
        self.goto( self.admin.currentAssetDef.url );
    };


    // Build a function to call the helper for the next asset
    var callUpdate = function( assetIds ) {
        var assetId = assetIds.shift();

        var callback = {
            success : function (o) {
                var resp = YAHOO.lang.JSON.parse( o.responseText );

                if ( resp.error ) {
                    this.admin.processPlugin( resp );
                    finish();
                }
                else if ( resp.forkId ) {
                    // Wait until the helper is done, then call the next
                    YAHOO.WebGUI.Fork.poll({
                        url     : '?op=fork;pid=' + resp.forkId,
                        draw    : function(data) {
                            pbTaskBar.set( 'maxValue', data.total );
                            pbTaskBar.set( 'value', data.finished );
                        },
                        finish  : function(){
                            pbQueueBar.set( 'value', pbQueueBar.get('value') + 1 );
                            pbQueueStatus.innerHTML = pbQueueBar.get('value') + ' / ' + pbQueueBar.get('maxValue');
                            if ( assetIds.length > 0 ) {
                                callHelper( assetIds );
                            }
                            else {
                                // We're all done now!
                                finish();
                            }
                        },
                    });
                }
                else if ( assetIds.length > 0 ) {
                    callUpdate( assetIds );
                }
                else {
                    finish();
                }
            },
            failure : function (o) {
            },
            scope : this
        };

        var payload = YAHOO.lang.JSON.stringify({
            "rank" : document.getElementById( assetId + "_rank" ).value
        });

        YAHOO.util.Connect.asyncRequest( "POST", "?op=admin;method=updateAsset;assetId=" + assetId, callback, payload );
    };

    callUpdate( assetIds );
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

    var query = WebGUI.Admin.Tree.superclass.buildQueryString.call( this, state, dt );

    return query + ';assetUrl=' + assetUrl;
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
    WebGUI.Admin.Tree.superclass.onDataReturnInitializeTable.call( this, sRequest, oResponse, oPayload );

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
    var currentAssetId  = oResponse.meta.currentAsset.assetId;
    var currentHelpers  = oResponse.meta.currentAsset.helpers;
    var elItem  = document.createElement( "span" );
    elItem.className    = "clickable";
    var self = this;
    var crumbMenu = function () {
        self.showHelperMenu( elItem, currentAssetId, currentHelpers );
    };
    YAHOO.util.Event.addListener( elItem, "click", crumbMenu, this, true );
    elItem.appendChild( document.createTextNode( oResponse.meta.currentAsset.title ) );
    elCrumb.appendChild( elItem );

    // TODO: Update current asset
    window.admin.navigate( oResponse.meta.currentAsset );

    // TODO Hide loading screen
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
    var maxHeight   = this.getMaxHeight();
    if ( this.cfg.expandMax ) {
        return maxHeight;
    }

    var height  = WebGUI.Admin.getRealHeight( elem );

    // Make sure not more than maxHeight
    if ( height > maxHeight ) {
        return maxHeight;
    }
    return height;
};

/**
 * getMaxHeight( )
 * Get the maximum possible height for the DD
 */
WebGUI.Admin.AdminBar.prototype.getMaxHeight 
= function () {
    var dtHeight   = WebGUI.Admin.getRealHeight( this.dt[0] ) * this.dt.length;
    return WebGUI.Admin.getRealHeight( this.dl.parentNode ) - dtHeight;
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
        old.style.overflowY = "hidden";
        YAHOO.util.Dom.removeClass( this.currentId, "selected" );
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
        // Subtract a few px initially to avoid a scrollbar appearing in the 
        // parent due to race conditions with the opening bar
        old.anim.attributes.height = { from: oldHeight - 5, to : 0 };
        old.anim.animate();

        // Let user close by clicking again
        if ( this.currentId == id ) {
            this.currentId  = null;
            return;
        }
    }

    var dd  = this.ddById[ id ];
    YAHOO.util.Dom.addClass( id, "selected" );

    if ( !dd.anim ) {
        dd.anim     = this.getAnim(dd);
    }
    dd.anim.attributes.height = { from: 0, to : this.getExpandHeight( dd ) };
    dd.style.height  = "0px";
    dd.style.display = "block";
    dd.style.overflow = "hidden";
    var showScrollbars = function () {
        dd.style.overflowY = "auto";
        dd.anim.onComplete.unsubscribe( showScrollbars );
    }
    dd.anim.onComplete.subscribe( showScrollbars, this, true );
    dd.anim.animate();
    this.currentId = id;

    this.afterShow.fire( id );

    // TODO: If we're nested inside another accordion-menu, fix 
    // the parent's height as we fix our own to avoid having to set
    // explicit height on parent
};


/**********************************************************************
 * WebGUI.Admin.Search( admin, cfg )
 *
 * Search for assets
 */
WebGUI.Admin.Search
= function (admin, cfg) {
    this.admin  = admin;
    this.cfg    = cfg;

    // Prepare the tab
    var newForm = document.getElementById( 'searchForm' ).cloneNode( true );
    this.formContainer = newForm;
    newForm.id = null; // Duplicate IDs are baaaad
    newForm.style.display = "block";

    var newTab = new YAHOO.widget.Tab({
        label : "Search",
        content : ''
    });
    this.tab = newTab;
    newTab.get('contentEl').appendChild( newForm );

    // Fire when ready, Gridley
    this.admin.tabBar.addTab( newTab );
    this.admin.tabBar.selectTab( this.admin.tabBar.get('tabs').length - 1 );

    var searchForm      = newForm.getElementsByTagName('form')[0];
    this.form           = searchForm;
    this.form.className = "searchForm";
    var searchButton    = searchForm.elements['searchButton'];
    this.searchSubmitButton   = new YAHOO.widget.Button( searchButton, {
        onclick     : { fn: this.requestSearch, scope: this }
    } );
    this.searchSubmitButton.addClass( searchButton.className );

    var searchFilterSelect  = searchForm.elements['searchFilterSelect'];
    this.searchFilterSelect = searchFilterSelect;
    var searchFilterAdd     = searchForm.elements['searchFilterAdd'];
    this.searchFilterAdd    = searchFilterAdd;
    this.searchFilterButton 
        = new YAHOO.widget.Button( searchFilterAdd, {
            type : "menu",
            menu : searchFilterSelect
        } );
    this.searchFilterButton.getMenu().subscribe( "click", this.addFilter, this, true );

    var searchKeywords = searchForm.elements['searchKeywords'];
    this.searchKeywords = searchKeywords;
    YAHOO.util.Event.on( searchKeywords, 'keyup', this.updateLocationBarQuery, this, true );
    YAHOO.util.Event.on( searchKeywords, 'focus', this.focusKeywords, this, true );
    YAHOO.util.Event.on( searchKeywords, 'blur', this.blurKeywords, this, true );

    var searchFiltersContainer  = searchForm.getElementsByTagName('ul')[0];
    this.searchFiltersContainer = searchFiltersContainer;

    this.filters    = [];

    // Create a container for the datatable
    this.dataTableContainer = document.createElement('div');
    this.dataTableContainer.style.display = "none";
    this.dataTableContainer.className = "searchResults";
    this.dataTableContainer.id  = YAHOO.util.Dom.generateId();
    this.formContainer.appendChild( this.dataTableContainer );

    // Create a container for the paginator
    // TODO
    WebGUI.Admin.Search.superclass.constructor.call( this, admin, {
        dataSourceUrl   : '?op=admin;method=searchAssets;',
        dataTableId     : this.dataTableContainer.id,
        paginatorIds    : [ YAHOO.util.Dom.generateId() ]
    } );

    this.init();
};
YAHOO.lang.extend( WebGUI.Admin.Search, WebGUI.Admin.AssetTable );

/**
 * addFilter ( eventType, args )
 * Add the selected filter into the filter list
 */
WebGUI.Admin.Search.prototype.addFilter
= function ( eventType, args ) {
    var self        = this;
    var ev          = args[0];
    var menuitem    = args[1];
    var keys = {}; // Listen for all keys

    // Keep track of our filters
    var filter = { }; 
    this.filters.push( filter );

    var li          = document.createElement( 'li' );
    filter.li       = li;

    var type        = menuitem.value;
    filter.type     = type;
    li.className    = "filter_" + filter.type;

    var ul = this.searchFiltersContainer;
    ul.appendChild( li );

    var delIcon     = document.createElement('img');
    delIcon.className = "clickable";
    YAHOO.util.Event.on( delIcon, "click", function(){ 
        self.removeFilter( filter.li );
    } );

    var name        = menuitem.cfg.getProperty('text');
    var nameElem    = document.createElement('span');
    nameElem.className = "name";
    nameElem.appendChild( document.createTextNode( name ) );
    li.appendChild( nameElem );

    // Function to create an autocomplete field
    var createAutocomplete = function ( li, filter ) {
        var container       = document.createElement( 'div' );
        container.className = "autocomplete";
        li.appendChild( container );

        var inputElem       = document.createElement('input');
        filter.inputElem    = inputElem;
        filter.getValue     = function () { return inputElem.value; };
        inputElem.type      = "text";
        container.appendChild( inputElem );

        // Auto-complete container
        var acDiv    = document.createElement('div');
        filter.acDiv = acDiv;
        container.appendChild( acDiv );

        filter.autocomplete = new YAHOO.widget.AutoComplete( inputElem, acDiv, filter.dataSource );
        filter.autocomplete.queryQuestionMark = false;
        filter.autocomplete.animVert = true;
        filter.autocomplete.animSpeed = 0.1;
        filter.autocomplete.minQueryLength = 1;
        filter.autocomplete.queryDelay = 0.2;
        filter.autocomplete.typeAhead = true;
        filter.autocomplete.resultTypeList = false;
        filter.autocomplete.applyLocalFilter = true;
    };

    if ( filter.type == "title" ) {
        var inputElem   = document.createElement('input');
        filter.inputElem = inputElem;
        filter.getValue  = function () { return inputElem.value; };
        inputElem.type = "text";
        li.appendChild( inputElem );
        YAHOO.util.Event.on( inputElem, 'keyup', this.updateLocationBarQuery, this, true );
        inputElem.focus();
    }
    else if ( filter.type == "ownerUserId" ) {
        filter.dataSource   = new YAHOO.util.XHRDataSource( '?op=admin;method=findUser;' );
        filter.dataSource.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;
        filter.dataSource.responseSchema = {
            resultsList : "results",
            fields : [ 'username', 'name', 'userId', 'avatar', 'email' ]
        };

        createAutocomplete( li, filter );

        filter.autocomplete.formatResult = function ( result, query, match ) {
            var subtext = ( result.name ? result.name : "" )
                        + ( result.email ? " &lt;" + result.email + "&gt;" : "" )
                        ;
            return '<div style="float: left; width: 50px; height: 50px; background: url(' + result.avatar + ') no-repeat 50% 50%;"></div>'
                    + '<div class="autocomplete_value">' + result.username + "</div>"
                    + '<div class="autocomplete_subtext">' + subtext + '</div>';

        };

        filter.inputElem.focus();
    }
    else if ( filter.type == 'lineage' ) {
        // lineage has autocomplete box and pop-up dialog button
        filter.dataSource   = new YAHOO.util.XHRDataSource( '?op=admin;method=findAsset;' );
        filter.dataSource.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;
        filter.dataSource.responseSchema = {
            resultsList : "results",
            fields : [ 'className', 'title', 'icon' ]
        };

        createAutocomplete( li, filter );

        filter.autocomplete.formatResult = function ( result, query, match ) {
            return '<div style="float: left; width: 50px; height: 50px; background: url(' + result.icon + ') no-repeat 50% 50%;"></div>'
                    + '<div class="autocomplete_value">' + result.name + "</div>"
                    + '<div class="autocomplete_subtext">' + result.className + '</div>';

        };

        filter.inputElem.focus();
    }
    else if ( filter.type == 'className' ) {
        // Create a menu from the asset types
        var container   = document.createElement('div');
        filter.menu = new YAHOO.widget.Menu( container, { } );
        var onMenuItemClick = function (type, args, item) {
            var text = item.cfg.getProperty("text");
            filter.button.set("label", text);
            // Get the right span to add the background to
            var button  = filter.button.getElementsByClassName( "first-child" )[0];
            YAHOO.util.Dom.addClass( button, "with_icon" );
            button.style.backgroundImage = item.element.style.backgroundImage;
        };

        var items = [];
        for ( className in this.admin.cfg['assetTypes'] ) {
            var assetDef    = this.admin.cfg.assetTypes[className];
            var menuItem    = new YAHOO.widget.MenuItem( assetDef.title, {
                onclick     : { fn: onMenuItemClick }
            } );
            menuItem.value = className;

            YAHOO.util.Dom.addClass( menuItem.element, 'with_icon' );
            menuItem.element.style.backgroundImage = 'url(' + assetDef.icon + ')';
            items.push( menuItem );
        }

        // Sort the items first
        items   = items.sort( function(a,b) { 
            var aText = a.cfg.getProperty('text');
            var bText = b.cfg.getProperty('text');
            if ( aText > bText ) { return 1; }
            else if ( aText < bText ) { return -1; }
            else { return 0; }
        } );

        filter.menu.addItems( items );
        filter.menu.render(document.body);

        filter.button   = new YAHOO.widget.Button( {
            name        : "className",
            type        : "menu",
            label       : "Choose...",
            container   : li,
            menu        : filter.menu
        } );

        filter.getValue = function () { return filter.button.value; };
    }
};

/**
 * buildQueryString( state, dt, searchUrl )
 * Build the query URL based on the passed-in data
 */
WebGUI.Admin.Search.prototype.buildQueryString
= function ( state, dt, searchUrl ) {
    if ( searchUrl ) {
        this.lastSearchUrl  = searchUrl;
    }

    var query   = WebGUI.Admin.Search.superclass.buildQueryString.call( this, state, dt );
    return query + ';' + this.lastSearchUrl;
};

/**
 * requestSearch( )
 * Perform the search
 */
WebGUI.Admin.Search.prototype.requestSearch
= function ( ) {
    // Build the new search URL
    var query   = 'query=' + encodeURIComponent( this.searchKeywords.value );
    for ( var i = 0; i < this.filters.length; i++ ) {
        query += ' ' + encodeURIComponent( filter.type + ':' + filter.getValue() );
    }

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
            query
        ),
        callback
    );
};

/**
 * onDataReturnInitializeTable ( sRequest, oResponse, oPayload )
 * Initialize the table with a new response from the server
 */
WebGUI.Admin.Search.prototype.onDataReturnInitializeTable
= function ( sRequest, oResponse, oPayload ) {
    this.dataTableContainer.style.display = "block";
    WebGUI.Admin.Tree.superclass.onDataReturnInitializeTable.call( this, sRequest, oResponse, oPayload );
};


