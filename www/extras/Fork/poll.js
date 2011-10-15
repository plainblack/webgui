/*global YAHOO, setTimeout */
/* Dependencies: yahoo, connection_core, json */

(function () {
    var ns = YAHOO.namespace('WebGUI.Fork'), JSON = YAHOO.lang.JSON;

    ns.poll = function(args) {
        function fetch() {
            var first = true;
            YAHOO.util.Connect.asyncRequest('GET', args.url, {
                success: function (o) {
                    var data, e;
                    if (o.status != 200) {
                        args.error("Server returned bad response");
                        return;
                    }
                    data = JSON.parse(o.responseText);
                    e = data.error;
                    if (e) {
                        args.error(e);
                        return;
                    }
                    args.draw(data);
                    if (args.first && first) {
                        first = false;
                        args.first();
                    }
                    if (data.finished) {
                        args.finish(data);
                    }
                    else {
                        setTimeout(fetch, args.interval || 1000);
                    }
                },
                failure: function (o) {
                    args.error("Could not communicate with server");
                }
            });
        }
        fetch();
    };
}());
