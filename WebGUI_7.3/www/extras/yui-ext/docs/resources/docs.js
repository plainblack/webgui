YAHOO.ext.Element.selectorFunction = cssQuery;

var Docs = function(){
    var layout, center;
    
    var classClicked = function(e){
        // find the "a" element that was clicked
        var a = e.findTarget(null, 'a');
        if(a){
            e.preventDefault();
            Docs.loadDoc(a.href);
        }  
    };
    
    return {
        init : function(){
            getEl('loading').remove();
            // initialize state manager, we will use cookies
            YAHOO.ext.state.Manager.setProvider(new YAHOO.ext.state.CookieProvider());
            
            // create the main layout
            layout = new YAHOO.ext.BorderLayout(document.body, {
                north: {
                    split:false,
                    initialSize: 32,
                    titlebar: false
                },
                west: {
                    split:true,
                    initialSize: 250,
                    minSize: 175,
                    maxSize: 400,
                    titlebar: true,
                    collapsible: true,
                    animate: true,
                    useShim:true,
                    cmargins: {top:2,bottom:2,right:2,left:2}
                },
                center: {
                    titlebar: true,
                    title: 'View Documentation',
                    autoScroll:false,
                    tabPosition: 'top',
                    closeOnTab: true,
                    //alwaysShowTabs: true,
                    resizeTabs: true
                }
            });
            // tell the layout not to perform layouts until we're done adding everything
            layout.beginUpdate();
            layout.add('north', new YAHOO.ext.ContentPanel('header'));
            
            layout.add('west', new YAHOO.ext.ContentPanel('classes', {title: 'Documentation Explorer', fitToFrame:true}));
            center = layout.getRegion('center');
            center.add(new YAHOO.ext.ContentPanel('main', {fitToFrame:true}));
            
            layout.restoreState();
            layout.endUpdate();
            
            var classes = getEl('classes');
            classes.mon('click', classClicked);
            classes.select('h3').each(function(el){
                var c = new NavNode(el);
                if(!/^(?:YAHOO|API Reference|Examples and Demos)$/.test(el.innerHTML)){
                    c.collapse();
                }
            });
            var page = window.location.href.split('#')[1];
            if(!page){
                page = 'welcome.html';
            }
            this.loadDoc(page);
        },
        
        loadDoc : function(url){
            getEl('main').dom.src = url;
        }
    };
}();
YAHOO.ext.EventManager.onDocumentReady(Docs.init, Docs, true);

/**
 * Simple tree node class based on Collapser and predetermined markup.
 */
var NavNode = function(clickEl, collapseEl){
    this.clickEl = getEl(clickEl);
    if(!collapseEl){
        collapseEl = this.clickEl.dom.nextSibling;
        while(collapseEl.nodeType != 1){
            collapseEl = collapseEl.nextSibling;
        }
    }
    this.collapseEl = getEl(collapseEl);
    this.clickEl.addClass('collapser-expanded');
    this.clickEl.mon('click', function(){
        this.collapsed === true ? 
            this.expand() : this.collapse();
    }, this, true);
};

NavNode.prototype = {
    collapse : function(){
        this.collapsed = true;
        this.collapseEl.setDisplayed(false);
        this.clickEl.replaceClass('collapser-expanded','collapser-collapsed');
    },
    
    expand : function(){
        this.collapseEl.setDisplayed(true);
        this.collapsed = false;
        this.collapseEl.setStyle('height', '');   
        this.clickEl.replaceClass('collapser-collapsed','collapser-expanded');
    }
};