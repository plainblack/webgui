var ResizableExample = {
    init : function(){
        
        var basic = new YAHOO.ext.Resizable('basic', {
                width: 200,
                height: 100,
                minWidth:100,
                minHeight:50
        });
        
        var animated = new YAHOO.ext.Resizable('animated', {
                width: 200,
                pinned: true,
                height: 100,
                minWidth:100,
                minHeight:50,
                animate:true,
                easing: YAHOO.util.Easing.backIn,
                duration:.6
        });
        
        var wrapped = new YAHOO.ext.Resizable('wrapped', {
            wrap:true,
            pinned:true,
            minWidth:50,
            minHeight: 50,
            preserveRatio: true
        });
        
        var transparent = new YAHOO.ext.Resizable('transparent', {
            wrap:true,
            minWidth:50,
            minHeight: 50,
            preserveRatio: true,
            transparent:true
        });
        
        var custom = new YAHOO.ext.Resizable('custom', {
            wrap:true,
            pinned:true,
            minWidth:50,
            minHeight: 50,
            preserveRatio: true,
            handles: 'all',
            draggable:true,
            dynamic:true
        });
        var customEl = custom.getEl();
        
        customEl.on('dblclick', function(){
            customEl.hide(true);
        });
        customEl.hide();
        
        getEl('showMe').on('click', function(){
            customEl.center();
            customEl.show(true);
        });
        
        var dwrapped = new YAHOO.ext.Resizable('dwrapped', {
            wrap:true,
            pinned:true,
            width:450,
            height:150,
            minWidth:200,
            minHeight: 50,
            dynamic: true
        });
        
        var snap = new YAHOO.ext.Resizable('snap', {
            pinned:true,
            width:250,
            height:100,
            handles: 'e',
            widthIncrement:50,
            minWidth: 50,
            dynamic: true
        });
    }
};

YAHOO.ext.EventManager.onDocumentReady(ResizableExample.init, ResizableExample, true);