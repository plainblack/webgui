var hoverHelpLoaded;
function initHoverHelp (root) {
    if (hoverHelpLoaded && !root)
        return;
    hoverHelpLoaded = true;
    var tips;
    if (root == 'DOMReady') {
        tips = YAHOO.util.Dom.getElementsByClassName('wg-hoverhelp');
    }
    else {
        tips = YAHOO.util.Dom.getElementsByClassName('wg-hoverhelp','',root);
    }
    for (var i = tips.length; i--; ) {
        var myTip = new YAHOO.widget.Tooltip(tips[i], {  
            autodismissdelay: 1000000,
            context: tips[i].parentNode,
            text   : tips[i].innerHTML
        });
        tips[i].innerHTML = "";
    }
}
YAHOO.util.Event.onDOMReady(initHoverHelp,'');

