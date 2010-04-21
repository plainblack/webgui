

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

    // Private methods
    var self = this;
    // Initialize these things AFTER the i18n is fetched
    var _init = function () {
        self.locationBar    = new WebGUI.Admin.LocationBar( self.cfg.locationBarId );
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

    // Defer until the locationBar is created
    if ( !this.locationBar ) {
        var self = this; // Scope correction
        return setTimeout( function(){ self.navigate( assetDef ) }, 1000 );
    }

    // Update the location bar
    this.locationBar.navigate( assetDef );

    this.currentAssetDef = assetDef;
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
    if ( oRecord.getData( 'actions' ) ) {
        elCell.innerHTML
            = '<a href="' + appendToUrl(oRecord.getData( 'url' ), 'func=edit;proceed=manageAssets') + '">'
            + window.admin.i18n.get('Asset', 'edit') + '</a>'
            + ' | '
            ;
    }
    else {
        elCell.innerHTML = "";
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

    var options = this.buildMoreMenu(oRecord.getData( 'url' ), more, oRecord.getData( 'actions' ));

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
            + '<img src="' + extras + '/assetManager/locked.gif" alt="' + window.admin.i18n.get('WebGUI', 'locked by') + ' ' + oRecord.getData( 'lockedBy' ) + '" '
            + 'title="' + window.admin.i18n.get('WebGUI', 'locked by') + ' ' + oRecord.getData( 'lockedBy' ) + '" border="0" />'
            + '</a>'
        : '<a href="' + appendToUrl(oRecord.getData( 'url' ), 'func=manageRevisions') + '">'
            + '<img src="' + extras + '/assetManager/unlocked.gif" alt="' + window.admin.i18n.get('Asset', 'unlocked') + '" '
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
    elCell.innerHTML = '<span class="hasChildren">' 
        + ( oRecord.getData( 'childCount' ) > 0 ? "+" : "&nbsp;" )
        + '</span> <span class="clickable">'
        + oRecord.getData( 'title' )
        + '</span>'
        ;
};

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
        YAHOO.util.Event.addListener( elItem, "click", function(){ this.goto( item.url ) }, this, true );
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


