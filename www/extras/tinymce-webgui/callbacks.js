// WebGUI Specific javascript functions for TinyMCE

(function () {
    var carat      = /%5E/g,
        colon      = /%3B/g,
        leftParen  = /%28/g,
        rightParen = /%29/g,
        front      = /^.*(\^.*)$/,
        quot       = /&quot;/g;

    function convert(url) {
        return url.replace(carat, '^')
            .replace(colon, ':')
            .replace(leftParen, '(')
            .replace(rightParen, ')')
            .replace(front, '$1');
    }

    function recurse(el) {
        var i, nodes = el.childNodes, len = nodes.length;
        if (el.href) {
            el.href = convert(el.href);
        }
        if (el.src) {
            el.src = convert(el.src);
        }
        for (i = 0; i < len; i += 1) {
            recurse(nodes[i]);
        }
    }

    function postproc (pl, o) {
        recurse(o.node);
    }

    function cleanup (type, value) {
        if (type === 'get_from_editor') {
            value = value.replace(quot, '"');
        }
        return value;
    }

    window.tinyMCE_WebGUI_URLConvertor = convert;
    window.tinyMCE_WebGUI_paste_postprocess = postproc;
    window.tinyMCE_WebGUI_Cleanup = cleanup;
}());
