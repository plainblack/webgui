/*global YAHOO, document */

(function () {
    var proto, event = YAHOO.util.Event;

    YAHOO.namespace('YAHOO.WebGUI');
    YAHOO.WebGUI.CodeArea = function (el) {
        this.el = el;
    };

    proto = YAHOO.WebGUI.CodeArea.prototype;
    proto.draw = function () {
        var el = this.el;
        if (typeof el === 'string') {
            el = this.el = document.getElementById(el);
        }
        el.style.fontFamily = 'monospace';
    };
    proto.render = function () {
        this.draw();
        this.bind();
    };
    proto.bind = function () {
        new YAHOO.util.KeyListener(this.el, { keys: 9 }, {
            fn           : this.onTab,
            scope        : this,
            correctScope : true
        }).enable();
    };
    proto.onTab = function (type, args) {
        var el = this.el,
        e      = args[1],
        start  = el.selectionStart,
        end    = el.selectionEnd,
        top    = el.scrollTop,
        old    = el.value,
        str    = old.slice(0, start) + '\t' + old.slice(end, old.length);

        el.value          = str;
        el.selectionStart = el.selectionEnd = start + 1;
        el.scrollTop      = top;

        event.stopEvent(e);
    };
}());
