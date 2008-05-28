
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
WebGUI.AssetManager.formatActions 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML 
        = '<a href="' + oRecord.getData( 'url' ) + '?func=edit">Edit</a>'
        + ' | More '
        ;
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatAssetIdCheckbox ( )
    Format the checkbox for the asset ID.
*/
WebGUI.AssetManager.formatAssetIdCheckbox 
= function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = '<input type="checkbox" name="assetId" value="' + oRecord.getData("assetId") + '"'
        + 'onchange="WebGUI.AssetManager.toggleHighlightForRow( this )" />';
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatAssetSize ( )
    Format the asset class name
*/
WebGUI.AssetManager.formatAssetSize
= function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = oRecord.getData( "assetSize" );
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatClassName ( )
    Format the asset class name
*/
WebGUI.AssetManager.formatClassName
= function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = '<img src="' + oRecord.getData( 'icon' ) + '" /> '
        + oRecord.getData( "className" );
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatLockedBy ( )
    Format the asset class name
*/
WebGUI.AssetManager.formatLockedBy
= function ( elCell, oRecord, oColumn, orderNumber ) {
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
WebGUI.AssetManager.formatRank
= function ( elCell, oRecord, oColumn, orderNumber ) {
    var rank    = oRecord.getData("lineage").match(/[1-9][0-9]{0,5}$/); 
    elCell.innerHTML = '<input type="text" name="' + oRecord.getData("assetId") + '"_rank" '
        + 'value="' + rank + '" size="3" '
        + 'onchange="WebGUI.AssetManager.selectRow( this )" />';
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatRevisionDate ( )
    Format the asset class name
*/
WebGUI.AssetManager.formatRevisionDate
= function ( elCell, oRecord, oColumn, orderNumber ) {
    var revisionDate    = new Date( oRecord.getData( "revisionDate" ) * 1000 );
    elCell.innerHTML    = revisionDate.getFullYear() + '-' + ( revisionDate.getMonth() + 1 )
                        + '-' + revisionDate.getDate() + ' ' + ( revisionDate.getHours() )
                        + ':' + revisionDate.getMinutes()
                        ;
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.formatTitle ( )
    Format the link for the title
*/
WebGUI.AssetManager.formatTitle
= function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = '<span class="hasChildren">' 
        + ( oRecord.getData( 'childCount' ) > 0 ? "+" : "&nbsp;" )
        + '</span> <a href="' + oRecord.getData( 'url' ) + '?op=assetManager;method=manage">'
        + oRecord.getData( 'title' )
        + '</a>'
        ;
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.hideMoreMenu ( event, element )
    Hide the more menu located inside element after a short delay.
*/
WebGUI.AssetManager.hideMoreMenu
= function ( event, element ) {
    var ul  = element.getElementsByTagName( "ul" )[0];
    // Store the timeout in the element itself (bad, yes)
    element.menuTimeout
        = setTimeout( function () { ul.style.display = "none"; }, 100 );
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.initManager ( )
    Initialize the www_manage page
*/
WebGUI.AssetManager.initManager
= function () {

    WebGUI.AssetManager.initMoreMenus();

};


/*---------------------------------------------------------------------------
    WebGUI.AssetManager.initMoreMenus ( )
    Initialize the more menus in an asset manager page
*/
WebGUI.AssetManager.initMoreMenus
= function () {
    // Initialize the more menus
    var moreMenus   = YAHOO.util.Dom.getElementsByClassName( "moreMenu" );
    for ( var i = 0; i < moreMenus.length; i++ ) {
        var a   = moreMenus[ i ].getElementsByTagName( "a" );
        for ( var h = 0; h < a.length; h++ ) {
            YAHOO.util.Event.addListener( a[ h ], "mouseover", WebGUI.AssetManager.showMoreMenu, moreMenus[ i ] );
            YAHOO.util.Event.addListener( a[ h ], "mouseout", WebGUI.AssetManager.hideMoreMenu, moreMenus[ i ] );
        }
    }
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.initSearch ( )
    Initialize the www_search page
*/
WebGUI.AssetManager.initSearch 
= function () {

    WebGUI.AssetManager.initMoreMenus();


};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.removeHighlightFromRow ( child )
    Remove the highlight from a row by removing the "highlight" class.
*/
WebGUI.AssetManager.removeHighlightFromRow
= function ( child ) {
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
WebGUI.AssetManager.selectRow 
= function ( child ) {
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
    WebGUI.AssetManager.showMoreMenu ( event, element )
    Show the more menu located inside element.
*/
WebGUI.AssetManager.showMoreMenu
= function ( event, element ) {
    if ( element.menuTimeout ) {
        clearTimeout( element.menuTimeout );
    }
    var ul  = element.getElementsByTagName( "ul" )[0];
    ul.style.display    = "block";
};

/*---------------------------------------------------------------------------
    WebGUI.AssetManager.toggleHighlightForRow ( checkbox )
    Toggle the highlight for the row based on the state of the checkbox
*/
WebGUI.AssetManager.toggleHighlightForRow
= function ( checkbox ) {
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
WebGUI.AssetManager.toggleRow 
= function ( child ) {
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

