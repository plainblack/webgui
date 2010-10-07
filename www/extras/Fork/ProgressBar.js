/*global YAHOO, WebGUI, document */
/* Dependencies: yahoo, dom */
(function () {
    var dom = YAHOO.util.Dom,
    ns      = YAHOO.namespace('WebGUI.Fork'),
    cls     = ns.ProgressBar = function () {},
    proto   = cls.prototype;

    proto.render = function (node) {
        var bar, cap;
        if (!node.tagName) {
            node = document.getElementById(node);
        }
        dom.addClass(node, 'webgui-fork-pb');
        bar = document.createElement('div');
        cap = document.createElement('div');
        dom.addClass(bar, 'webgui-fork-pb-bar');
        dom.addClass(cap, 'webgui-fork-pb-caption');
        node.appendChild(bar);
        node.appendChild(cap);
        this.domNode = node;
        this.bar     = bar;
        this.caption = cap;
    };
    proto.update = function (done, total) {
        var pct = (total > 0 ? Math.floor((done/total)*100) : 100) + '%';
        this.caption.innerHTML = pct;
        this.bar.style.width = pct;
    };
}());
