function initWGContextMenus() {
    var menus = YAHOO.util.Dom.getElementsByClassName('wg-contextmenu');
    for (var i = menus.length; i--; ) {
        var menu = menus[i];
        if (menu.initialized) {
            continue;
        }
        var ctx = menu.previousSibling;
        var myMenu = new YAHOO.widget.Menu(menu, {
            context             : [ctx, "tl", "bl"]
        });
        myMenu.render();
        YAHOO.util.Event.addListener(ctx, "click", function (e, menu) {
            YAHOO.util.Event.preventDefault(e);
            menu.align("tl", "bl");
            menu.show();
        }, myMenu);
    }
}
YAHOO.util.Event.onDOMReady(initWGContextMenus);

