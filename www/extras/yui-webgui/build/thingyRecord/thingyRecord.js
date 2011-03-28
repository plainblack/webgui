
// Requires YUI Connection and JSON

if ( typeof WebGUI == "undefined" ) {
    WebGUI  = {};
}
if ( typeof WebGUI.ThingyRecord == "undefined" ) {
    WebGUI.ThingyRecord = {};
}

WebGUI.ThingyRecord.getThingFields
= function ( thingId ) {
    
    // Callback to populate the form element
    var callback = {
        success : function (o) {
            // Add fields to select list
            var el      = document.getElementById('thingFields_formId');
            while ( el.options.length >= 1 )
                el.remove(0);
            var fields  = YAHOO.lang.JSON.parse( o.responseText );
            for ( var key in fields ) {
                el.options[el.options.length]
                    = new Option( fields[key], key, 1, 1 );
            }

            // Add fields to field price
            WebGUI.ThingyRecord.updateFieldPrices();
        }
    };
    
    var url = encodeURI(location.pathname) + '?op=formHelper;class=ThingFieldsList;sub=getThingFields;thingId='
            + thingId
            ;
    YAHOO.util.Connect.asyncRequest( 'GET', url, callback );
};

WebGUI.ThingyRecord.updateFieldPrices
= function ( ) {
    var form        = document.forms[0];
    var fieldList   = document.getElementById( 'thingFields_formId' );
    var selected    = [];
    var div         = document.getElementById( 'fieldPrice' );
    var fieldPrice  = document.getElementById( 'fieldPrice_formId' );
    var currentPrices = {};
    try {
        currentPrices = YAHOO.lang.JSON.parse( fieldPrice.value );
    } 
    catch (e) {
        // Initialize if there's a parse error
        fieldPrice.value = "{}";    
    }

    // Get the selected fields
    for ( var i = 0; i < fieldList.options.length; i++ ) {
        var opt = fieldList.options[i];
        if ( opt.selected ) {
            selected.push( opt );
        }
        else { 
            currentPrices[ opt.value ] = 0;
        }
    }
    fieldPrice.value = YAHOO.lang.JSON.stringify( currentPrices );

    // Clear out old records
    while ( div.childNodes.length ) 
        div.removeChild( div.childNodes[0] );

    for ( var i = 0; i < selected.length; i++ ) {
        var opt     = selected[i];
        var label   = document.createElement( 'label' );
        label.style.display = "block";
        label.style.width   = "50%";
        var price   = document.createElement( 'input' );
        price.name  = "fieldPrice_" + opt.value;
        price.type  = "text";
        price.size  = "5";
        price.value = currentPrices[ opt.value ] ? currentPrices[ opt.value ] : "0.00";
        YAHOO.util.Event.addListener( price, "change", function () {
            var fieldName = this.name.substr( "fieldPrice_".length );
            var json = YAHOO.lang.JSON.parse( fieldPrice.value );
            json[fieldName] = this.value;
            fieldPrice.value = YAHOO.lang.JSON.stringify( json );
        } );

        label.appendChild( price );

        label.appendChild( document.createTextNode( opt.text ) );
        div.appendChild( label );
    }
};


// Load the columns and field prices
YAHOO.util.Event.onDOMReady( function () {
    var form        = document.forms[0];
    var thingId     = document.getElementById("thingId_formId");
    var thingFields = document.getElementById("thingFields_formId")

    // Add events to form fields
    YAHOO.util.Event.addListener( thingId, "change", function () {
        WebGUI.ThingyRecord.getThingFields( this.value );
    } );
    
    YAHOO.util.Event.addListener( thingFields, "change", function () {
        WebGUI.ThingyRecord.updateFieldPrices();
    } );

    // Populate the fields list if necessary
    if ( thingId.value ) {
        WebGUI.ThingyRecord.getThingFields( thingId.value );
    }
} );
