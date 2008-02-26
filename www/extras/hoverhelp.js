var hoverHelpLoaded;
YAHOO.util.Event.onDOMReady(function () {
    if (hoverHelpLoaded)
        return;
    hoverHelpLoaded = true;
    var tips = YAHOO.util.Dom.getElementsByClassName('wg-hoverhelp');
    for (var i = tips.length; i--; ) {
        var myTip = new YAHOO.widget.Tooltip(tips[i], {  
            autodismissdelay: 1000000,
            context: tips[i].parentNode
        });
    }
});

