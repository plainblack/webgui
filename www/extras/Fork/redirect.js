/*global YAHOO, setTimeout, window */
/* Dependencies: yahoo */

(function () {
    var ns = YAHOO.namespace('WebGUI.Fork');
    ns.redirect = function (redir, after) {
        if (!redir) {
            return;
        }
        setTimeout(function() {
            // The idea here is to only allow local redirects
            var loc = window.location;
            loc.href = loc.protocol + '//' + loc.host + redir;
        }, after || 1000);
    };
}());
