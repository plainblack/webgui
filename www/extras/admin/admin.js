

if ( typeof WebGUI == "undefined" ) {
    WebGUI = {};
}
WebGUI.Admin = {};

WebGUI.Admin.LocationBar = (function(){
    
    // Public stuff

    return function (id) {
        this.id = id;
        var self = this;

        // Private members
        var _element    = document.getElementById( self.id );

        function _init () {
            _element.appendChild( document.createTextNode( "Location Bar" ) );
        }

        _init();
    };
})();
