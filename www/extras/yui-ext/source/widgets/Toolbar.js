/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */

/**
 * @class
 * Basic Toolbar used by the Grid to create the paging toolbar. This class is reusable but functionality
 * is limited. Look for more functionality in a future version. 
 */
 YAHOO.ext.Toolbar = function(container){
    this.el = getEl(container, true);
    var div = document.createElement('div');
    div.className = 'ytoolbar';
    var tb = document.createElement('table');
    tb.border = 0;
    tb.cellPadding = 0;
    tb.cellSpacing = 0;
    div.appendChild(tb);
    var tbody = document.createElement('tbody');
    tb.appendChild(tbody);
    var tr = document.createElement('tr');
    tbody.appendChild(tr);
    this.el.dom.appendChild(div);
    this.tr = tr;
};

YAHOO.ext.Toolbar.prototype = {
    /**
     * Adds element(s) to the toolbar - this function takes a variable number of 
     * arguments of mixed type and adds them to the toolbar...
     * If an argument is a ToolbarButton, it is added. If the element is a string, it is wrapped 
     * in a ytb-text element and added unless the text is "separator" in which case a separator
     * is added. Otherwise, it is assumed the element is an HTMLElement and it is added directly.
     */
    add : function(){
        for(var i = 0; i < arguments.length; i++){
            var el = arguments[i];
            var td = document.createElement('td');
            this.tr.appendChild(td);
            if(el instanceof YAHOO.ext.ToolbarButton){
                el.init(td);
            }else if(typeof el == 'string'){
                var span = document.createElement('span');
                if(el == 'separator'){
                    span.className = 'ytb-sep';
                }else{
                    span.innerHTML = el;
                    span.className = 'ytb-text';
                }
                td.appendChild(span);
            }else if(typeof el == 'object'){ // must be element?
                td.appendChild(el);
            }
        }
    },
    
    addSeparator : function(){
        var td = document.createElement('td');
        this.tr.appendChild(td);
        var span = document.createElement('span');
        span.className = 'ytb-sep';
        td.appendChild(span);
    },
    
    /**
     * Adds a button, see {@link YAHOO.ext.ToolbarButton} for more info on the config
     * @return {YAHOO.ext.ToolbarButton}
     */
    addButton : function(config){
        var b = new YAHOO.ext.ToolbarButton(config);
        this.add(b);
        return b;
    },
    
    addText : function(text){
        var td = document.createElement('td');
        this.tr.appendChild(td);
        var span = document.createElement('span');
        span.className = 'ytb-text';
        span.innerHTML = text;
        td.appendChild(span);
        return span;
    }
};

/**
 * @class
 * A toolbar button. The config has the following options:
 * <ul>
 * <li>className - The CSS class for the button. Use this to attach a background image for an icon.</li>
 * <li>text - The button's text</li>
 * <li>tooltip - The buttons tooltip text</li>
 * <li>click - function to call when the button is clicked</li>
 * <li>mouseover - function to call when the mouse moves over the button</li>
 * <li>mouseout - function to call when the mouse moves off the button</li>
 * <li>scope - The scope of the above event handlers</li>
 * <li></li>
 * <li></li>
 */
YAHOO.ext.ToolbarButton = function(config){
    YAHOO.ext.util.Config.apply(this, config);
};

YAHOO.ext.ToolbarButton.prototype = {
    /** @private */
    init : function(appendTo){
        var element = document.createElement('span');
        element.className = 'ytb-button';
        this.disabled = (this.disabled === true);
        var inner = document.createElement('span');
        inner.className = 'ytb-button-inner ' + this.className;
        if(this.tooltip){
            element.setAttribute('title', this.tooltip);
        }
        element.appendChild(inner);
        appendTo.appendChild(element);
        this.el = getEl(element, true);
        inner.innerHTML = (this.text ? this.text : '&nbsp;');
        this.el.mon('click', this.onClick, this, true);    
        this.el.mon('mouseover', this.onMouseOver, this, true);    
        this.el.mon('mouseout', this.onMouseOut, this, true);
    },
    
    disable : function(){
        this.disabled = true;
        if(this.el){
            this.el.addClass('ytb-button-disabled');
        }
    },
    
    enable : function(){
        this.disabled = false;
        if(this.el){
            this.el.removeClass('ytb-button-disabled');
        }
    },
    
    isDisabled : function(){
        return this.disabled === true;
    },
    
    setDisabled : function(disabled){
        if(disabled){
            this.disable();
        }else{
            this.enable();
        }
    },
    
    /** @private */
    onClick : function(){
        if(!this.disabled && this.click){
            this.click.call(this.scope || window, this);
        }
    },
    
    /** @private */
    onMouseOver : function(){
        if(!this.disabled){
            this.el.addClass('ytb-button-over');
            if(this.mouseover){
                this.mouseover.call(this.scope || window, this);
            }
        }
    },
    
    /** @private */
    onMouseOut : function(){
        this.el.removeClass('ytb-button-over');
        if(!this.disabled){
            if(this.mouseout){
                this.mouseout.call(this.scope || window, this);
            }
        }
    }
};