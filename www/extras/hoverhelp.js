YAHOO.util.Event.onDOMReady(function () {
    var tips = YAHOO.util.Dom.getElementsByClassName('wg-hoverhelp');
    var i;
    for (i = 0; i < tips.length; i++) {
        var myTip = new YAHOO.widget.Tooltip(tips[i], {  
            autodismissdelay: 1000000,
            width: '300px',
            context: tips[i].parentNode
        }); 
    }
});

