/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */

/*
	tabpanel.js, version .1
	Copyright(c) 2006, Jack Slocum.
	Code licensed under the BSD License
*/

/**
 * @class Creates a lightweight TabPanel component using Yahoo! UI.
 * <br><br>
 * Usage:
 * <pre><code>
    <font color="#008000">// basic tabs 1, built from existing content</font>
    var tabs = new YAHOO.ext.TabPanel('tabs1');
    tabs.addTab('script', "View Script");
    tabs.addTab('markup', "View Markup");
    tabs.activate('script');
    
    <font color="#008000">// more advanced tabs, built from javascript</font>
    var jtabs = new YAHOO.ext.TabPanel('jtabs');
    jtabs.addTab('jtabs-1', "Normal Tab", "My content was added during construction.");
    
    <font color="#008000">// set up the UpdateManager</font>
    var tab2 = jtabs.addTab('jtabs-2', "Ajax Tab 1");
    var updater = tab2.getUpdateManager();
    updater.setDefaultUrl('ajax1.htm');
    tab2.onActivate.subscribe(updater.refresh, updater, true);
    
    <font color="#008000">// Use setUrl for Ajax loading</font>
    var tab3 = jtabs.addTab('jtabs-3', "Ajax Tab 2");
    tab3.setUrl('ajax2.htm', null, true);
    
    <font color="#008000">// Disabled tab</font>
    var tab4 = jtabs.addTab('tabs1-5', "Disabled Tab", "Can't see me cause I'm disabled");
    tab4.disable();
    
    jtabs.activate('jtabs-1');
}
 * </code></pre>
 * @requires YAHOO.ext.Element
 * @requires YAHOO.ext.UpdateManager
 * @requires YAHOO.util.Dom
 * @requires YAHOO.util.Event
 * @requires YAHOO.util.CustomEvent 
 * @requires YAHOO.util.DDProxy
 * @requires YAHOO.util.Connect (optional)
 * @constructor
 * Create new TabPanel.
 * @param {String/HTMLElement/Element} container The id, DOM element or YAHOO.ext.Element container where this TabPanel is to be rendered. 
 */
YAHOO.ext.TabPanel = function(container, onBottom){
    /**
    * The container element for this TabPanel.
    * @type YAHOO.ext.Element
    */
    this.el = getEl(container);
    if(onBottom){
        this.bodyEl = getEl(this.createBody(this.el.dom));
        this.el.addClass('ytabs-bottom');
    }
    /** @private */
    this.stripWrap = getEl(this.createStrip(this.el.dom));
    /** @private */
    this.stripEl = getEl(this.createStripList(this.stripWrap.dom));
    /** The body element that contains TabPaneItem bodies. 
     * @type YAHOO.ext.Element
     */
    if(!onBottom){
      this.bodyEl = getEl(this.createBody(this.el.dom));
    }
    /** @private */
    this.items = {};
    /** @private */
    this.active = null;
    /**
     * Fires when the active TabPanelItem changes. Uses fireDirect with signature: (TabPanel this, TabPanelItem activedTab).
     * @type CustomEvent
     */
    this.onTabChange = new YAHOO.util.CustomEvent('TabItem.onTabChange');
    /** @private */
    this.activateDelegate = this.activate.createDelegate(this);
}

YAHOO.ext.TabPanel.prototype = {
    /**
     * Creates a new TabPanelItem by looking for an existing element with the provided id - if it's not found it creates one.
     * @param {String} id The id of the div to use or create
     * @param {String} text The text for the tab
     * @param {<i>String</i>} content (optional) Content to put in the TabPanelItem body
     * @return {YAHOO.ext.TabPanelItem} The created TabPanelItem
     */
    addTab : function(id, text, content){
        var item = new YAHOO.ext.TabPanelItem(this, id, text);
        this.addTabItem(item);
        if(content){
            item.setContent(content);
        }
        return item;
    },
    
    /**
     * Returns the TabPanelItem with the specified id
     * @param {String} id The id of the TabPanelItem to fetch.
     * @return {YAHOO.ext.TabPanelItem}
     */
    getTab : function(id){
        return this.items[id];
    },
    
    /**
     * Add an existing TabPanelItem.
     * @param {YAHOO.ext.TabPanelItem} item The TabPanelItem to add
     */
    addTabItem : function(item){
        this.items[item.id] = item;
    },
        
    /**
     * Remove a TabPanelItem.
     * @param {String} id The id of the TabPanelItem to remove.
     */
    removeTab : function(id){
        var tab = this.items[id];
        if(tab && this.active == tab){// if it's active, activate the first tab
            for(var key in this.items){
                if(typeof this.items[key] != 'function' && this.items[key] != tab){
                    this.items[key].activate();
                    break;
                }
            }
        }
        this.stripEl.dom.removeChild(tab.onEl.dom);
        this.stripEl.dom.removeChild(tab.offEl.dom);
        this.bodyEl.dom.removeChild(tab.bodyEl.dom);
        delete this.items[id];
    },
    
    /**
     * Disable a TabPanelItem. <b>It cannot be the active tab, if it is this call is ignored.</b>. 
     * @param {String} id The id of the TabPanelItem to disable.
     */
    disableTab : function(id){
        var tab = this.items[id];
        if(tab && this.active != tab){
            tab.disable();
        }
    },
    
    /**
     * Enable a TabPanelItem that is disabled.
     * @param {String} id The id of the TabPanelItem to enable.
     */
    enableTab : function(id){
        var tab = this.items[id];
        tab.enable();
    },
    
    /**
     * Activate a TabPanelItem. The currently active will be deactivated. 
     * @param {String} id The id of the TabPanelItem to activate.
     */
    activate : function(id){
        var tab = this.items[id];
        if(!tab.disabled){
            if(this.active){
                this.active.hide();
            }
            this.active = this.items[id];
            this.active.show();
            this.onTabChange.fireDirect(this, this.active);
        }
    },
    
    /**
     * Get the active TabPanelItem
     * @return {YAHOO.ext.TabPanelItem} The active TabPanelItem or null if none are active.
     */
    getActiveTab : function(){
        return this.active;
    }
    
};

YAHOO.ext.TabPanelItem = function(tabPanel, id, text){
    /**
     * The TabPanel this TabPanelItem belongs to
     * @type YAHOO.ext.TabPanel
     */
    this.tabPanel = tabPanel;
    /**
     * The id for this TabPanelItem
     * @type String
     */
    this.id = id;
    /** @private */
    this.disabled = false;
    /** @private */
    this.text = text;
    /** @private */
    this.loaded = false;
    
    /** 
     * The body element for this TabPanelItem
     * @type YAHOO.ext.Element
     */
    this.bodyEl = getEl(tabPanel.createItemBody(tabPanel.bodyEl.dom, id));
    this.bodyEl.originalDisplay = 'block';
    this.bodyEl.setStyle('display', 'none');
    this.bodyEl.enableDisplayMode();
    
    var stripElements =tabPanel.createStripElements(tabPanel.stripEl.dom, text);
    /** @private */
    this.onEl = getEl(stripElements.on, true);
    /** @private */
    this.offEl = getEl(stripElements.off, true);
    this.onEl.originalDisplay = 'inline';
    this.onEl.enableDisplayMode();
    this.offEl.originalDisplay = 'inline';
    this.offEl.enableDisplayMode();
    this.offEl.on('click', tabPanel.activateDelegate.createCallback(id));
    /**
     * Fires when this TabPanelItem is activated. Uses fireDirect with signature: (TabPanel tabPanel, TabPanelItem this).
     * @type CustomEvent
     */
    this.onActivate = new YAHOO.util.CustomEvent('TabItem.onActivate');
    /**
     * Fires when this TabPanelItem is deactivated. Uses fireDirect with signature: (TabPanel tabPanel, TabPanelItem this).
     * @type CustomEvent
     */
    this.onDeactivate = new YAHOO.util.CustomEvent('TabItem.onDeactivate');
};

YAHOO.ext.TabPanelItem.prototype = {
    /**
     * Show this TabPanelItem - this <b>does not</b> deactivate the currently active TabPanelItem.
     */
    show : function(){
        this.onEl.show();
        this.offEl.hide();
        this.bodyEl.show();
        this.onActivate.fireDirect(this.tabPanel, this); 
    },
    
    setText : function(text){
        this.onEl.dom.firstChild.firstChild.firstChild.innerHTML = text;
        this.offEl.dom.firstChild.firstChild.innerHTML = text;
    },
    /**
     * Activate this TabPanelItem - this <b>does</b> deactivate the currently active TabPanelItem.
     */
    activate : function(){
        this.tabPanel.activate(this.id);
    },
    
    /**
     * Hide this TabPanelItem - if you don't activate another TabPanelItem this could look odd.
     */
    hide : function(){
        this.onEl.hide();
        this.offEl.show();
        this.bodyEl.hide();
        this.onDeactivate.fireDirect(this.tabPanel, this); 
    },
    
    /**
     * Disable this TabPanelItem - this call is ignore if this is the active TabPanelItem.
     */
    disable : function(){
        if(this.tabPanel.active != this){
            this.disabled = true;
            this.offEl.addClass('disabled');
            this.offEl.dom.title = 'disabled';
        }
    },
    
    /**
     * Enable this TabPanelItem if it was previously disabled.
     */
    enable : function(){
        this.disabled = false;
        this.offEl.removeClass('disabled');
        this.offEl.dom.title = '';
    },
    
    /**
     * Set the content for this TabPanelItem.
     * @param {String} content The content
     */
    setContent : function(content){
        this.bodyEl.update(content);
    },
    
    /**
     * Get the {@link YAHOO.ext.UpdateManager} for the body of this TabPanelItem. Enables you to perform Ajax updates.
     * @return {YAHOO.ext.UpdateManager} The UpdateManager
     */
    getUpdateManager : function(){
        return this.bodyEl.getUpdateManager();
    },
    
    /**
     * Set a URL to be used to load the content for this TabPanelItem.
     * @param {String/Function} url The url to load the content from or a function to call to get the url
     * @param {<i>String/Object</i>} params (optional) The string params for the update call or an object of the params. See {@link YAHOO.ext.UpdateManager#update} for more details. (Defaults to null)
     * @param {<i>Boolean</i>} loadOnce (optional) Whether to only load the content once. If this is false it makes the Ajax call every time this TabPanelItem is activated. (Defaults to false)
     * @return {YAHOO.ext.UpdateManager} The UpdateManager
     */
    setUrl : function(url, params, loadOnce){
        this.onActivate.subscribe(this._handleRefresh.createDelegate(this, [url, params, loadOnce]));
    },
    
    /** @private */
    _handleRefresh : function(url, params, loadOnce){
        if(!loadOnce || !this.loaded){
            var updater = this.bodyEl.getUpdateManager();
            updater.update(url, params, this._setLoaded.createDelegate(this));
        }
    },
    
    /** @private */
    _setLoaded : function(){
        this.loaded = true;
    }   
};
/** @private */
YAHOO.ext.TabPanel.prototype.createStrip = function(container){
    var strip = document.createElement('div');
    YAHOO.util.Dom.addClass(strip, 'tabset');
    container.appendChild(strip);
    var stripInner = document.createElement('div');
    YAHOO.util.Dom.generateId(stripInner, 'tab-strip');
    YAHOO.util.Dom.addClass(stripInner, 'hd');
    strip.appendChild(stripInner);
    return stripInner;
};
/** @private */
YAHOO.ext.TabPanel.prototype.createStripList = function(strip){
    var list = document.createElement('ul');
    YAHOO.util.Dom.generateId(list, 'tab-strip-list');
    strip.appendChild(list);
    return list;
};
/** @private */
YAHOO.ext.TabPanel.prototype.createBody = function(container){
    var body = document.createElement('div');
    YAHOO.util.Dom.generateId(body, 'tab-body');
    YAHOO.util.Dom.addClass(body, 'yui-ext-tabbody');
    container.appendChild(body);
    return body;
};
/** @private */
YAHOO.ext.TabPanel.prototype.createItemBody = function(bodyEl, id){
    var body = YAHOO.util.Dom.get(id);
    if(!body){
        body = document.createElement('div');
        body.id = id;
    }
    YAHOO.util.Dom.addClass(body, 'yui-ext-tabitembody');
    bodyEl.appendChild(body);
    return body;
};
/** @private */
YAHOO.ext.TabPanel.prototype.createStripElements = function(stripEl, text){
    var li = document.createElement('li');
    var a = document.createElement('a');
    var em = document.createElement('em');
       
    stripEl.appendChild(li);
    li.appendChild(a);
    a.appendChild(em);
    em.innerHTML = text;
    
    var li2 = document.createElement('li');
    var a2 = document.createElement('a');
    var em2 = document.createElement('em');
    var strong = document.createElement('strong');
       
    stripEl.appendChild(li2);
    YAHOO.util.Dom.addClass(li2, 'on');
    YAHOO.util.Dom.setStyle(li2, 'display', 'none');
    li2.appendChild(a2);
    a2.appendChild(strong);
    strong.appendChild(em2);
    em2.innerHTML = text;
    
    return {on: li2, off: li};
};