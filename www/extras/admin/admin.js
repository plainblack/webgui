

/**
 *  WebGUI.Admin -- The WebGUI Admin Console
 */

if ( typeof WebGUI == "undefined" ) {
    WebGUI = {};
}
WebGUI.Admin = function(){
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

    this.locationBar    = new WebGUI.Admin.LocationBar( this.cfg.locationBarId );
    this.tabBar         = new YAHOO.widget.TabView( this.cfg.tabBarId );
    // Keep track of View and Tree tabs
    this.tabBar.getTab(0).addListener('click',this.afterShowViewTab,this,true);
    this.tabBar.getTab(1).addListener('click',this.afterShowTreeTab,this,true);

    // Private methods
};

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
 * navigate( assetDef )
 * Tell the locationbar we've navigated to a new asset. 
 */
WebGUI.Admin.LocationBar.prototype.navigate
= function ( assetDef ) {
    // Always update location bar
    this.setTitle( assetDef.title );
    this.setUrl( assetDef.url );

    // Don't do the same asset twice
    if ( this.currentAssetDef && this.currentAssetDef.assetId != assetDef.assetId ) {
        this.addBackAsset( this.currentAssetDef );
        // We navigated, so destroy the forward queue
        //this.forwardAssetDefs = [];
        //this.btnForward.getMenu().clearItems();
        //this.btnForward.getMenu().render();
        //this.btnForward.set( "disabled", true );
    }

    // Current asset is now...
    this.currentAssetDef = assetDef;

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

WebGUI.Admin.Tree = function(){
    this.moreMenusDisplayed = {};
    this.crumbMoreMenu = null;
};

/**
 * appendToUrl( url, params )
 * Add URL components to a URL;
 */
WebGUI.Admin.Tree.prototype.appendToUrl = function ( url, params ) {
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
 * addHighlightToRow ( child )
 * Highlight the row containing this element by adding to it the "highlight"
 * class
 */
WebGUI.Admin.Tree.prototype.addHighlightToRow = function ( child ) {
    var row     = this.findRow( child );
    if ( !YAHOO.util.Dom.hasClass( row, "highlight" ) ) {
        YAHOO.util.Dom.addClass( row, "highlight" );
    }
};

/**
 * buildMoreMenu ( url, linkElement )
 * Build a WebGUI style "More" menu for the asset referred to by url
 */
WebGUI.AssetManager.buildMoreMenu = function ( url, linkElement, isNotLocked ) {
    var rawItems    = this.moreMenuItems;
    var menuItems   = [];
    var isLocked    = !isNotLocked;
    for ( var i = 0; i < rawItems.length; i++ ) {
        var itemUrl     = rawItems[i].url
                        ? this.appendToUrl(url, rawItems[i].url)
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
 * findRow ( child )
 * Find the row that contains this child element.
 */
WebGUI.Admin.Tree.prototype.findRow = function ( child ) {
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
WebGUI.AssetManager.formatActions = function ( elCell, oRecord, oColumn, orderNumber ) {
    if ( oRecord.getData( 'actions' ) ) {
        elCell.innerHTML 
            = '<a href="' + WebGUI.AssetManager.appendToUrl(oRecord.getData( 'url' ), 'func=edit;proceed=manageAssets') + '">'
            + WebGUI.AssetManager.i18n.get('Asset', 'edit') + '</a>'
            + ' | '
            ;
    }
    else {
        elCell.innerHTML = "";
    }
    var more    = document.createElement( 'a' );
    elCell.appendChild( more );
    more.appendChild( document.createTextNode( WebGUI.AssetManager.i18n.get('Asset','More' ) ) );
    more.href   = '#';

    // Delete the old menu
    if ( document.getElementById( 'moreMenu' + oRecord.getData( 'assetId' ) ) ) {
        var oldMenu = document.getElementById( 'moreMenu' + oRecord.getData( 'assetId' ) );
        oldMenu.parentNode.removeChild( oldMenu );
    }

    var options = WebGUI.AssetManager.buildMoreMenu(oRecord.getData( 'url' ), more, oRecord.getData( 'actions' ));

    var menu    = new YAHOO.widget.Menu( "moreMenu" + oRecord.getData( 'assetId' ), options );
    YAHOO.util.Event.onDOMReady( function () { menu.render( document.getElementById( 'assetManager' ) ); } );
    YAHOO.util.Event.addListener( more, "click", function (e) { YAHOO.util.Event.stopEvent(e); menu.show(); menu.focus(); }, null, menu );
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatAssetIdCheckbox ( )
    Format the checkbox for the asset ID.
*/
WebGUI.AssetManager.formatAssetIdCheckbox = function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = '<input type="checkbox" name="assetId" value="' + oRecord.getData("assetId") + '"'
        + 'onchange="WebGUI.AssetManager.toggleHighlightForRow( this )" />';
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatAssetSize ( )
    Format the asset class name
*/
WebGUI.AssetManager.formatAssetSize = function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = oRecord.getData( "assetSize" );
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatClassName ( )
    Format the asset class name
*/
WebGUI.AssetManager.formatClassName = function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = '<img src="' + oRecord.getData( 'icon' ) + '" /> '
        + oRecord.getData( "className" );
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatLockedBy ( )
    Format the asset class name
*/
WebGUI.AssetManager.formatLockedBy = function ( elCell, oRecord, oColumn, orderNumber ) {
    var extras  = getWebguiProperty('extrasURL');
    elCell.innerHTML 
        = oRecord.getData( 'lockedBy' )
        ? '<a href="' + WebGUI.AssetManager.appendToUrl(oRecord.getData( 'url' ), 'func=manageRevisions') + '">'
            + '<img src="' + extras + '/assetManager/locked.gif" alt="' + WebGUI.AssetManager.i18n.get('WebGUI', 'locked by') + ' ' + oRecord.getData( 'lockedBy' ) + '" '
            + 'title="' + WebGUI.AssetManager.i18n.get('WebGUI', 'locked by') + ' ' + oRecord.getData( 'lockedBy' ) + '" border="0" />'
            + '</a>'
        : '<a href="' + WebGUI.AssetManager.appendToUrl(oRecord.getData( 'url' ), 'func=manageRevisions') + '">'
            + '<img src="' + extras + '/assetManager/unlocked.gif" alt="' + WebGUI.AssetManager.i18n.get('Asset', 'unlocked') + '" '
            + 'title="' + WebGUI.AssetManager.i18n.get('Asset', 'unlocked') +'" border="0" />'
            + '</a>'
        ;
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatRank ( )
    Format the input for the rank box
*/
WebGUI.AssetManager.formatRank = function ( elCell, oRecord, oColumn, orderNumber ) {
    var rank    = oRecord.getData("lineage").match(/[1-9][0-9]{0,5}$/); 
    elCell.innerHTML = '<input type="text" name="' + oRecord.getData("assetId") + '_rank" '
        + 'value="' + rank + '" size="3" '
        + 'onchange="WebGUI.AssetManager.selectRow( this )" />';
};


/*---------------------------------------------------------------------------
    WebGUI.AssetManager.DefaultSortedBy ( )
*/
WebGUI.AssetManager.DefaultSortedBy = { 
    "key"       : "lineage",
    "dir"       : YAHOO.widget.DataTable.CLASS_ASC
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.BuildQueryString ( )
*/
WebGUI.AssetManager.BuildQueryString = function ( state, dt ) {
    var query = "recordOffset=" + state.pagination.recordOffset 
            + ';orderByDirection=' + ((state.sortedBy.dir === YAHOO.widget.DataTable.CLASS_DESC) ? "DESC" : "ASC")
            + ';rowsPerPage=' + state.pagination.rowsPerPage
            + ';orderByColumn=' + state.sortedBy.key
            ;
        return query;
    };

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatRevisionDate ( )
    Format the asset class name
*/
WebGUI.AssetManager.formatRevisionDate = function ( elCell, oRecord, oColumn, orderNumber ) {
    var revisionDate    = new Date( oRecord.getData( "revisionDate" ) * 1000 );
    var minutes = revisionDate.getMinutes();
    if (minutes < 10) {
        minutes = "0" + minutes;
    }
    elCell.innerHTML    = revisionDate.getFullYear() + '-' + ( revisionDate.getMonth() + 1 )
                        + '-' + revisionDate.getDate() + ' ' + ( revisionDate.getHours() )
                        + ':' + minutes
                        ;
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatTitle ( )
    Format the link for the title
*/
WebGUI.AssetManager.formatTitle = function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = '<span class="hasChildren">' 
        + ( oRecord.getData( 'childCount' ) > 0 ? "+" : "&nbsp;" )
        + '</span> <a href="' + WebGUI.AssetManager.appendToUrl(oRecord.getData( 'url' ), 'op=assetManager;method=manage') + '">'
        + oRecord.getData( 'title' )
        + '</a>'
        ;
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.initManager ( )
    Initialize the i18n interface
*/
WebGUI.AssetManager.initManager = function (o) {
    WebGUI.AssetManager.i18n
    = new WebGUI.i18n( { 
            namespaces  : {
                'Asset' : [
                    "edit",
                    "More",
                    "unlocked",
                    "locked by"
                ],
                'WebGUI' : [
                    "< prev",
                    "next >"
                ]
            },
            onpreload   : {
                fn       : WebGUI.AssetManager.initDataTable
            }
        } );
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.initDataTable ( )
    Initialize the www_manage page
*/
WebGUI.AssetManager.initDataTable = function (o) {
    var assetPaginator = new YAHOO.widget.Paginator({
        containers            : ['pagination'],
        pageLinks             : 7,
        rowsPerPage           : 100,
        previousPageLinkLabel : WebGUI.AssetManager.i18n.get('WebGUI', '< prev'),
        nextPageLinkLabel     : WebGUI.AssetManager.i18n.get('WebGUI', 'next >'),
        template              : "<strong>{CurrentPageReport}</strong> {PreviousPageLink} {PageLinks} {NextPageLink}"
    });


   // initialize the data source
   WebGUI.AssetManager.DataSource
        = new YAHOO.util.DataSource( '?op=assetManager;method=ajaxGetManagerPage;',{connTimeout:30000} );
    WebGUI.AssetManager.DataSource.responseType
        = YAHOO.util.DataSource.TYPE_JSON;
    WebGUI.AssetManager.DataSource.responseSchema
        = {
            resultsList: 'assets',
            fields: [
                { key: 'assetId' },
                { key: 'lineage' },
                { key: 'actions' },
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
                totalRecords: "totalAssets" // Access to value in the server response
            }
        };



    // Initialize the data table
    WebGUI.AssetManager.DataTable 
        = new YAHOO.widget.DataTable( 'dataTableContainer', 
            WebGUI.AssetManager.ColumnDefs, 
            WebGUI.AssetManager.DataSource, 
            {
                initialRequest          : 'recordOffset=0',
                dynamicData             : true,
                paginator               : assetPaginator,
                sortedBy                : WebGUI.AssetManager.DefaultSortedBy,
                generateRequest         : WebGUI.AssetManager.BuildQueryString
            }
        );

    WebGUI.AssetManager.DataTable.handleDataReturnPayload = function(oRequest, oResponse, oPayload) {
        oPayload.totalRecords = oResponse.meta.totalRecords;
        return oPayload;
    };

};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.removeHighlightFromRow ( child )
    Remove the highlight from a row by removing the "highlight" class.
*/
WebGUI.AssetManager.removeHighlightFromRow = function ( child ) {
    var row     = WebGUI.AssetManager.findRow( child );
    if ( YAHOO.util.Dom.hasClass( row, "highlight" ) ) {
        YAHOO.util.Dom.removeClass( row, "highlight" );
    }
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.selectRow ( child )
    Check the assetId checkbox in the row that contains the given child. 
    Used when something in the row changes.
*/
WebGUI.AssetManager.selectRow = function ( child ) {
    // First find the row
    var node    = WebGUI.AssetManager.findRow( child );
    WebGUI.AssetManager.addHighlightToRow( child );

    // Now find the assetId checkbox in the first element
    var inputs   = node.getElementsByTagName( "input" );
    for ( var i = 0; i < inputs.length; i++ ) {
        if ( inputs[i].name == "assetId" ) {
            inputs[i].checked = true;
            break;
        }
    }
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.showMoreMenu ( url, linkTextId )
    Build a More menu for the last element of the Crumb trail
*/
WebGUI.AssetManager.showMoreMenu 
= function ( url, linkTextId, isNotLocked ) {

    var menu;
    if ( typeof WebGUI.AssetManager.CrumbMoreMenu == "undefined" ) {
        var more    = document.getElementById(linkTextId);
        var options = WebGUI.AssetManager.buildMoreMenu(url, more, isNotLocked);
        menu    = new YAHOO.widget.Menu( "crumbMoreMenu", options );
        menu.render( document.getElementById( 'assetManager' ) );
        WebGUI.AssetManager.CrumbMoreMenu = menu;
    }
    else {
        menu = WebGUI.AssetManager.CrumbMoreMenu;
    }
    menu.show();
    menu.focus();
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.toggleHighlightForRow ( checkbox )
    Toggle the highlight for the row based on the state of the checkbox
*/
WebGUI.AssetManager.toggleHighlightForRow = function ( checkbox ) {
    if ( checkbox.checked ) {
        WebGUI.AssetManager.addHighlightToRow( checkbox );
    }
    else {
        WebGUI.AssetManager.removeHighlightFromRow( checkbox );
    }
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.toggleRow ( child )
    Toggles the entire row by finding the checkbox and doing what needs to be
    done.
*/
WebGUI.AssetManager.toggleRow = function ( child ) {
    var row     = WebGUI.AssetManager.findRow( child );
    
    // Find the checkbox
    var inputs  = row.getElementsByTagName( "input" );
    for ( var i = 0; i < inputs.length; i++ ) {
        if ( inputs[i].name == "assetId" ) {
            inputs[i].checked   = inputs[i].checked
                                ? false
                                : true
                                ;
            WebGUI.AssetManager.toggleHighlightForRow( inputs[i] );
            break;
        }
    }
};


