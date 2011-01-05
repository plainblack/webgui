/*global YAHOO, document, alert, window */

(function () {
    var $event     = YAHOO.util.Event,
        $connect   = YAHOO.util.Connect,
        $json      = YAHOO.lang.JSON,
        $dom       = YAHOO.util.Dom,
        assetId, panel, panelRendered, onHide;

    function absolute(url) {
        // We have to do this innerHTML trick or it doesn't work on IE6
        var div = document.createElement('div'), a;
        div.innerHTML = '<a></a>';
        a = div.firstChild;
        a.href = url;
        return a.href;
    }

    function base() {
        return absolute('_#').slice(0, -2);
    }

    function runConfigDialog(k) {
        if (!panelRendered) {
            panel.render();
            panelRendered = true;
        }
        else {
            panel.hideEvent.unsubscribe(onHide);
            panel.show();
        }
        if (k) {
            onHide = k;
            panel.hideEvent.subscribe(k);
        }
    }

    function fetch(k) {
        var url = document.getElementById('previewFetchUrl').value,
            abs, b;

        if (!url) {
            runConfigDialog(function () {
                fetch(k);
            });
            return;
        }

        abs = absolute(url);
        b   = base();

        if (abs.indexOf(b) === 0) {
            url = document.getElementById('previewGateway').value +
                abs.slice(b.length);
        }

        $connect.initHeader('X-Webgui-Template-Variables', assetId);
        $connect.asyncRequest(
            'GET', url, {
                success: function (o) {
                    var h      = o.getResponseHeader,
                        start  = h['X-Webgui-Template-Variables-Start'],
                        end    = h['X-Webgui-Template-Variables-End'],
                        text   = o.responseText,
                        si     = text.indexOf(start) + start.length,
                        ei     = text.indexOf(end),
                        raw    = text.slice(si, ei),
                        vars   = $json.parse(raw),
                        pretty = $json.stringify(vars, 0, 4),
                        vbox   = document.getElementById('previewVars');

                    vbox.value = pretty;
                    if (k) {
                        k(pretty);
                    }
                },
                failure: function (o) {
                    alert(o.statusText);
                }
            }, null
        );
    }

    function withVariables(k) {
        var inBox  = document.getElementById('previewVars').value;


        function finish(raw) {
            var parsed, flat;
            try {
                parsed = $json.parse(raw);
                flat   = $json.stringify(parsed);
                k(flat);
            }
            catch (e) {
                alert(e);
            }
        }

        if (inBox) {
            finish(inBox);
        }
        else {
            fetch(finish);
        }
    }

    function render() {
        withVariables(function (v) {
            var body = document.body,
                params = {
                template  : document.getElementById('template_formId').value,
                variables : v,
                parser    : document.getElementById('parser_formId').value,
                func      : 'preview'
            }, form = document.createElement('form'), input, key;

            if ($dom.getElementsBy(function (e) {
                    return e.value === '1';
                }, 'input', 'previewRaw_row')[0].checked) 
            {
                params.plainText = 'true';
            }

            form.method = 'POST';
            form.action = window.location.pathname;
            form.target = '_blank';

            for (key in params) {
                if (params.hasOwnProperty(key)) {
                    input = document.createElement('input');
                    input.type = 'hidden';
                    input.name = key;
                    input.value = params[key];
                    form.appendChild(input);
                }
            }

            body.appendChild(form);
            form.submit();
            body.removeChild(form);
        });
    }

    function listen() {
        assetId = document.getElementById('previewId').value;
        panel = document.getElementById('previewConfigForm');
        panel.parentNode.removeChild(panel);
        document.body.appendChild(panel);
        panel = new YAHOO.widget.Panel(panel, {
            close       : true,
            draggable   : false,
            underlay    : 'shadow',
            modal       : true,
            fixedcenter : true
        });
        $event.on('previewFetch', 'click', fetch);
        $event.on('preview', 'click', render);
        $event.on('previewConfig', 'click', runConfigDialog);
        $event.on('previewConfigClose', 'click', function () {
            panel.hide();
        });
    }

    $event.onDOMReady(listen);
}());
