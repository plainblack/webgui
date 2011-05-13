/*global YAHOO, document, alert, window */

(function () {
    var $event     = YAHOO.util.Event,
        $connect   = YAHOO.util.Connect,
        $json      = YAHOO.lang.JSON,
        $dom       = YAHOO.util.Dom,
        assetId, panel, panelRendered, onHide, previewPanel;

    function absolute(url) {
        // We have to do this innerHTML trick or it doesn't work on IE6
        var div = document.createElement('div'), a;
        div.innerHTML = '<a></a>';
        a = div.firstChild;
        a.href = url;
        return a.href;
    }

    function base() {
        return absolute('_#').slice(0, -2) || '/';
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

    function on_fetch(o) {
        var h      = o.getResponseHeader,
            start  = h['X-Webgui-Template-Variables-Start'],
            end    = h['X-Webgui-Template-Variables-End'],
            text   = o.responseText,
            si     = text.indexOf(start) + start.length,
            ei     = text.indexOf(end),
            raw    = text.slice(si, ei),
            vars   = $json.parse(raw),
            pretty = $json.stringify(vars, null, 4),
            vbox   = document.getElementById('previewVars'),
            k      = o.argument;

        vbox.value = pretty;
        if (k) {
            k(pretty);
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
                argument: k,
                success: on_fetch,
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
            },
                form = document.createElement('form'),
                target = document.getElementById('preview_target'),
                iframe, setSize, input, key;

            if (target) {
                previewPanel.show();
            }
            else {
                target = document.createElement('div');
                target.id = 'preview_target';
                target.innerHTML =
                    '<div class="hd"></div>' +
                    '<div class="bd">' +
                        '<iframe name="preview_target">' +
                    '</div>' +
                    '<div class="ft"></div>';
                body.appendChild(target);
                previewPanel = new YAHOO.widget.Panel(target, {
                    close       : true,
                    draggable   : false,
                    underlay    : 'shadow',
                    modal       : true,
                    fixedcenter : true
                });

                // i18n'd title
                previewPanel.setHeader(
                    document.getElementById('preview').value
                );

                iframe = target.childNodes[1].firstChild;
                setSize = function () {
                    iframe.style.width = $dom.getViewportWidth() * 0.8 + 'px';
                    iframe.style.height = $dom.getViewportHeight() * 0.8 + 'px';
                };
                setSize();
                YAHOO.widget.Overlay.windowResizeEvent.subscribe(setSize);
                previewPanel.render();
            }

            if ($dom.getElementsBy(function (e) {
                    return e.value === '1';
                }, 'input', 'previewRaw_row')[0].checked)
            {
                params.plainText = 'true';
            }

            form.action = window.location.pathname;
            form.target = 'preview_target';
            form.method = 'POST';
            for (key in params) {
                if (params.hasOwnProperty(key)) {
                    try {
                        // IE fails at setting names, so let's try an IE only
                        // way to do this first.
                        input = document.createElement(
                            '<input name="' + key + '">'
                        );
                    }
                    catch (e) {
                        input = document.createElement('input');
                        input.name = key;
                    }
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
            close               : true,
            draggable           : false,
            underlay            : 'shadow',
            modal               : true,
            fixedcenter         : true,
            constraintoviewport : true
        });
        $event.on('previewFetch', 'click', function() { fetch() });
        $event.on('preview', 'click', render);
        $event.on('previewConfig', 'click', runConfigDialog);
        $event.on('previewConfigClose', 'click', function () {
            panel.hide();
        });
    }

    $event.onDOMReady(listen);
}());
