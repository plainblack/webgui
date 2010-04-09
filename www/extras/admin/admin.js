

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
            var back    = new YAHOO.widget.Button( "backButton", {
                label       : '<img src="' + getWebguiProperty("extrasURL") + 'icon/arrow_left.png" />'
            } );
            var forward = new YAHOO.widget.Button( "forwardButton", {
                label       : '<img src="' + getWebguiProperty("extrasURL") + 'icon/arrow_right.png" />'
            } );
            var search  = new YAHOO.widget.Button( "searchButton", {
                label       : '<img src="' + getWebguiProperty("extrasURL") + 'icon/magnifier.png" />'
            } );
            var home    = new YAHOO.widget.Button( "homeButton", {
                label       : '<img src="' + getWebguiProperty("extrasURL") + 'icon/house.png" />'
            } );
        }

        _init();
    };
})();
