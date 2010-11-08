/*global YAHOO, setTimeout, window */
/* Dependencies: yahoo */

(function () {
    var ns = YAHOO.namespace('WebGUI.Fork');
    ns.redirect = function (params, after) {
        var redir, msg, admin, fn;
        if (redir = params.redirect) {
            fn = function () {
                // The idea here is to only allow local redirects
                var loc = window.location;
                loc.href = loc.protocol + '//' + loc.host + redir;
            };
        }
        else if (msg = params.message) {
            fn = function () {
                admin = window.parent.admin;
                admin.processPlugin({ message: msg });
                admin.closeModalDialog();
            };
        }
        if (fn) {
            setTimeout(fn, after || 1000);
        }
    };
}());
