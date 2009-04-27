
// Requires YUI Connection and JSON

if ( typeof WebGUI == "undefined" ) {
    WebGUI  = {};
}
if ( typeof WebGUI.ThingyRecord == "undefined" ) {
    WebGUI.ThingyRecord = {};
}

WebGUI.ThingyRecord.getThingFields
= function ( thingId, elementId ) {
    
    // Callback to populate the form element
    var callback = {
        success : function (o) {
            var el      = document.getElementById(elementId);
            while ( el.options.length >= 1 )
                el.remove(0);
            var fields  = YAHOO.lang.JSON.parse( o.responseText );
            for ( var key in fields ) {
                el.options[el.options.length]
                    = new Option( fields[key], key, 1, 1 );
            }
        }
    };
    
    var url = '?op=formHelper;class=ThingFieldsList;sub=getThingFields;thingId='
            + thingId
            ;
    YAHOO.util.Connect.asyncRequest( 'GET', url, callback );
};
