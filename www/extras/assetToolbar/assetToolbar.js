function initWGContextMenus() {
    var menus = YAHOO.util.Dom.getElementsByClassName('wg-contextmenu');
    var max_loop = 15;
    for (var i = menus.length; i--; ) {
        var menu = menus[i];
        if (menu.initialized) {
            continue;
        }
        menu.initialized = true;
        var ctx = YAHOO.util.Dom.getPreviousSibling(menu);
        var myMenu = new YAHOO.widget.Menu(menu, {
            context             : [ctx, "tl", "bl"]
        });
        myMenu.render();
        YAHOO.util.Event.addListener(ctx, "click", function (e, menu) {
            YAHOO.util.Event.preventDefault(e);
            menu.align("tl", "bl");
            menu.show();
        }, myMenu);
        max_loop--;
        if (max_loop == 0) {
            window.setTimeout(initWGContextMenus, 50);
            break;
        }
    }
}
YAHOO.util.Event.onDOMReady(initWGContextMenus);

