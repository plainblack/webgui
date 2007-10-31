YAHOO.util.Event.onDOMReady(function () {
    var tips = YAHOO.util.Dom.getElementsByClassName('wg-hoverhelp');
    var i;
    for (i = 0; i < tips.length; i++) {
        var myTip = new YAHOO.widget.Tooltip(tips[i], {  
            autodismissdelay: 1000000,
            context: tips[i].parentNode
        });
        myTip.beforeShowEvent.subscribe(function() {
            YAHOO.util.Dom.addClass(this.element, 'wg-hoverhelp-visible');
        });
        myTip.beforeHideEvent.subscribe(function() {
            YAHOO.util.Dom.removeClass(this.element, 'wg-hoverhelp-visible');
        });
    }
});

