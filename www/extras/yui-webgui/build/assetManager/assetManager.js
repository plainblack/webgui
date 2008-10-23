
/*** The WebGUI Asset Manager 
 * Requires: YAHOO, Dom, Event
 *
 */

if ( typeof WebGUI == "undefined" ) {
    WebGUI  = {};
}
if ( typeof WebGUI.AssetManager == "undefined" ) {
    WebGUI.AssetManager = {};
}

// The extras folder
WebGUI.AssetManager.extrasUrl   = '/extras/';
// Keep track of the open more menus
WebGUI.AssetManager.MoreMenusDisplayed = {};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.addHighlightToRow ( child )
    Highlight the row containing this element by adding to it the "highlight"
    class
*/
WebGUI.AssetManager.addHighlightToRow
= function ( child ) {
    var row     = WebGUI.AssetManager.findRow( child );
    if ( !YAHOO.util.Dom.hasClass( row, "highlight" ) ) {
        YAHOO.util.Dom.addClass( row, "highlight" );
    }
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.findRow ( child )
    Find the row that contains this child element.
*/
WebGUI.AssetManager.findRow
= function ( child ) {
    var node    = child;
    while ( node ) {
        if ( node.tagName == "TR" ) {
            return node;
        }
        node = node.parentNode;
    }
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatActions ( )
    Format the Edit and More links for the row
*/
WebGUI.AssetManager.formatActions = function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML 
        = '<a href="' + oRecord.getData( 'url' ) + '?func=edit;proceed=manageAssets">Edit</a>'
        + ' | '
        ;
    var more    = document.createElement( 'a' );
    elCell.appendChild( more );
    more.appendChild( document.createTextNode( 'More' ) );
    more.href   = '#';

    // Delete the old menu
    if ( document.getElementById( 'moreMenu' + oRecord.getData( 'assetId' ) ) ) {
        var oldMenu = document.getElementById( 'moreMenu' + oRecord.getData( 'assetId' ) );
        oldMenu.parentNode.removeChild( oldMenu );
    }

    // Build a more menu
    var rawItems    = WebGUI.AssetManager.MoreMenuItems;
    var menuItems   = [];
    for ( var i = 0; i < rawItems.length; i++ ) {
        var itemUrl     = rawItems[i].url.match( /<url>/ )
                        ? rawItems[i].url.replace( "<url>", oRecord.getData( 'url' ) )
                        : oRecord.getData( 'url' ) + rawItems[i].url
                        ;
        menuItems.push( { "url" : itemUrl, "text" : rawItems[i].label } );
    }

    var options = {
        "zindex"                    : 1000,
        "clicktohide"               : true,
        "position"                  : "dynamic",
        "context"                   : [ more, "tl", "bl" ],
        "itemdata"                  : menuItems
    };

    var menu    = new YAHOO.widget.Menu( "moreMenu" + oRecord.getData( 'assetId' ), options );
    YAHOO.util.Event.onDOMReady( function () { menu.render( document.getElementById( 'assetManager' ) ) } );
    YAHOO.util.Event.addListener( more, "click", function (e) { menu.show(); menu.focus(); YAHOO.util.Event.stopEvent(e); }, null, menu );
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
    var extras  = WebGUI.AssetManager.extrasUrl;
    elCell.innerHTML 
        = oRecord.getData( 'lockedBy' )
        ? '<a href="' + oRecord.getData( 'url' ) + '?func=manageRevisions">'
            + '<img src="' + extras + '/assetManager/locked.gif" alt="locked by ' + oRecord.getData( 'lockedBy' ) + '" '
            + 'title="locked by ' + oRecord.getData( 'lockedBy' ) + '" border="0" />'
            + '</a>'
        : '<a href="' + oRecord.getData( 'url' ) + '?func=manageRevisions">'
            + '<img src="' + extras + '/assetManager/unlocked.gif" alt="unlocked" '
            + 'title="unlocked" border="0" />'
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
            + ';orderByDirection=' + ((state.sorting.dir === YAHOO.widget.DataTable.CLASS_DESC) ? "DESC" : "ASC")
            + ';rowsPerPage=' + state.pagination.rowsPerPage
            + ';orderByColumn=' + state.sorting.key
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
    if (minutes < 10)
        minutes = "0" + minutes;
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
        + '</span> <a href="' + oRecord.getData( 'url' ) + '?op=assetManager;method=manage">'
        + oRecord.getData( 'title' )
        + '</a>'
        ;
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.initManager ( )
    Initialize the www_manage page
*/
WebGUI.AssetManager.initManager = function (o) {
    var assetPaginator = new YAHOO.widget.Paginator({
        containers         : ['pagination'],
        pageLinks          : 7,
        rowsPerPage        : 100,
        template           : "<strong>{CurrentPageReport}</strong> {PreviousPageLink} {PageLinks} {NextPageLink}"
    });


    // Custom function to handle pagination requests
    var handlePagination = function (state,dt) {
        var sortedBy  = dt.get('sortedBy');

        // Define the new state
        var newState = {
            startIndex: state.recordOffset, 
            sorting: {
                key: sortedBy.key,
                dir: ((sortedBy.dir === YAHOO.widget.DataTable.CLASS_DESC) ? "desc" : "asc")
            },
            pagination : { // Pagination values
                recordOffset: state.recordOffset, // Default to first page when sorting
                rowsPerPage: dt.get("paginator").getRowsPerPage() // Keep current setting
            }
        };

        // Create callback object for the request
        var oCallback = {
            success: dt.onDataReturnSetRows,
            failure: dt.onDataReturnSetRows,
            scope: dt,
            argument: newState // Pass in new state as data payload for callback function to use
        };
        
        // Send the request
        dt.getDataSource().sendRequest(WebGUI.AssetManager.BuildQueryString(newState, dt), oCallback);
    };
 
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
                sortedBy                : WebGUI.AssetManager.DefaultSortedBy
            }
        );
     WebGUI.AssetManager.DataTable.onPaginatorChangeRequest  = handlePagination;

        
    WebGUI.AssetManager.DataTable.handleDataReturnPayload = function(oRequest, oResponse, oPayload) {
        oPayload.totalRecords = oResponse.meta.totalRecords;
        return oPayload;
    }

    // Override function for custom server-side sorting
    WebGUI.AssetManager.DataTable.sortColumn = function(oColumn) {
        // Default ascending
        var sDir = "asc";
        
        // If already sorted, sort in opposite direction
        if(oColumn.key === this.get("sortedBy").key) {
            sDir = (this.get("sortedBy").dir === YAHOO.widget.DataTable.CLASS_ASC) ?
                    "desc" : "asc";
        }

        // Define the new state
        var newState = {
            startIndex: 0,
            sorting: { // Sort values
                key: oColumn.key,
                dir: (sDir === "desc") ? YAHOO.widget.DataTable.CLASS_DESC : YAHOO.widget.DataTable.CLASS_ASC
            },
            pagination : { // Pagination values
                recordOffset: 0, // Default to first page when sorting
                rowsPerPage: this.get("paginator").getRowsPerPage() // Keep current setting
            }
        };

        // Create callback object for the request
        var oCallback = {
            success: this.onDataReturnSetRows,
            failure: this.onDataReturnSetRows,
            scope: this,
            argument: newState // Pass in new state as data payload for callback function to use
        };
        
        // Send the request
        this.getDataSource().sendRequest(WebGUI.AssetManager.BuildQueryString(newState, this), oCallback);
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

