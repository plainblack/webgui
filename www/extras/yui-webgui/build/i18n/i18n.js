
// Initialize namespace
if (typeof WebGUI == "undefined") {
    var WebGUI = {};
}

/****************************************************************************
 * WebGUI.i18n ( { options } )
 * Initialize an i18n object. Options is an object with the following keys:
 *  - url           : (Optional) Specify a URL to a WebGUI site. Do not include the query string
 *  - namespaces    : (Optional) Object of arrays of namespaces to preload. Keys are namespace names,
 *                    and array members are i18n entries to get.
 *  - onpreload     : (Optional) Callback object for after the i18n is loaded.
 *                      fn          : The function to call
 *                      obj         : An object to pass to the function
 *                      override    : If true, the function will be called in "obj" scope
 * Requires: YUI Event, YUI Connect, and YUI JSON
 * Events: 
 *  - preload       : Fired when preloading is complete
 */
WebGUI.i18n 
= function ( opt ) {
    this.url        = opt.url   || "";
    this.namespaces = {};

    this.evPreload  = this.createEvent( "preload" );
    if ( opt.onpreload ) {
        this.subscribe( "preload", opt.onpreload.fn, opt.onpreload.obj, opt.onpreload.override );
    }
    
    if ( opt.namespaces ) {
        this.load( opt.namespaces, true );
    }
};

YAHOO.lang.augmentProto( WebGUI.i18n, YAHOO.util.EventProvider );

/****************************************************************************
 * get( ns, key )
 * Return the string referenced by namespace and key. If the namespace and key
 * have not yet been retrieved, get it from the WebGUI server.
 */
WebGUI.i18n.prototype.get
= function ( ns, key ) {
    if ( typeof this.namespaces[ ns ][ key ] == "undefined" ) {
        var obj = {};
        obj[ns] = [ key ];
        this.load( obj );
        // TODO: Return placeholder that will get auto-updated
    }
    return this.namespaces[ ns ][ key ];
};

/****************************************************************************
 * load( { ns : keys, ns : keys, ... }, preload )
 * Grab the requested namespace / keys from the WebGUI server.
 * keys is an array of keys to get. 
 * If preload is defined, will fire off the preload event
 */
WebGUI.i18n.prototype.load
= function ( obj, preload ) {
    var requestUrl  = this.url + "?op=ajaxGetI18N"
    var callback    = {
        failure : function ( o, preload ) {
            // TODO: YUI logger for this
            console.log( "Could not load i18n" );
        },
        success : function ( o ) {
            var responseObj = YAHOO.lang.JSON.parse( o.responseText );
            for ( var ns in responseObj ) {
                for ( var key in responseObj[ ns ] ) {
                    if ( !this.namespaces[ ns ] ) {
                        this.namespaces[ ns ] = {};
                    }
                    this.namespaces[ ns ][ key ] = responseObj[ ns ][ key ];
                }
            }
            if ( o.argument.preload ) {
                this.fireEvent( "preload" );
            }
        },
        scope       : this,
        argument    : { preload : preload }
    };

    var postJson    = 'request=' + YAHOO.lang.JSON.stringify( obj );

    YAHOO.util.Connect.asyncRequest( "POST", requestUrl, callback, postJson );
};
