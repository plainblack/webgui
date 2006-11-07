/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */

/**
 * @class
 * Utility class for working with DOM
 */
YAHOO.ext.DomHelper = new function(){
    /**@private*/
    var d = document;
    
    /** True to force the use of DOM instead of html fragments @type Boolean */
    this.useDom = false;
    
    // parse and apply styles to dom element
    /** @ignore */
    function applyStyles(el, styles){
        if(styles){
            var D = YAHOO.util.Dom;
            var re = /\s?(.*?)\:(.*?);/g;
            var matches;
            while ((matches = re.exec(styles)) != null){
                D.setStyle(el, matches[1], matches[2]);
            }
        }
    }
    
    // build as innerHTML where available
    /** @ignore */
    function createHtml(o){
        var b = '';
        b += '<' + o.tag;
        for(var attr in o){
            if(attr == 'tag' || attr == 'children' || attr == 'html' || typeof o[attr] == 'function') continue;
            if(attr == 'cls'){
                b += ' class="' + o['cls'] + '"';
            }else{
                b += ' ' + attr + '="' + o[attr] + '"';
            }
        }
        b += '>';
        if(o.children){
            for(var i = 0, len = o.children.length; i < len; i++) {
                b += createHtml(o.children[i], b);
            }
        }
        if(o.html){
            b += o.html;
        }
        b += '</' + o.tag + '>';
        return b;
    }
    
    // build as dom
    /** @ignore */
    function createDom(o, parentNode){
        var el = d.createElement(o.tag);
        var useSet = el.setAttribute ? true : false; // In IE some elements don't have setAttribute
        for(var attr in o){
            if(attr == 'tag' || attr == 'children' || attr == 'html' || attr == 'style' || typeof o[attr] == 'function') continue;
            if(attr=='cls'){
                el.className = o['cls'];
            }else{
                if(useSet) el.setAttribute(attr, o[attr]);
                else el[attr] = o[attr];
            }
        }
        applyStyles(el, o.style);
        if(o.children){
            for(var i = 0, len = o.children.length; i < len; i++) {
             	createDom(o.children[i], el);
            }
        }
        if(o.html){
            el.innerHTML = o.html;
        }
        if(parentNode){
           parentNode.appendChild(el);
        }
        return el;
    }
    
    /**
     * Inserts an HTML fragment into the Dom
     * @param {String} where Where to insert the html in relation to el - beforeBegin, afterBegin, beforeEnd, afterEnd.
     * @param {HTMLElement} el The context element
     * @param {String} html The HTML fragmenet
     * @return {HTMLElement} The new node
     */
    this.insertHtml = function(where, el, html){
        if(el.insertAdjacentHTML){
            if(where == 'beforeBegin'){
                el.insertAdjacentHTML(where, html);
                return el.previousSibling;
            }else if(where == 'afterBegin'){
                el.insertAdjacentHTML(where, html);
                return el.firstChild;
            }else if(where == 'beforeEnd'){
                el.insertAdjacentHTML(where, html);
                return el.lastChild;
            }else if(where == 'afterEnd'){
                el.insertAdjacentHTML(where, html);
                return el.nextSibling;
            }
            throw 'Illegal insertion point -> "' + where + '"';
        }
        var range = el.ownerDocument.createRange();
        var frag;
        if(where == 'beforeBegin'){
            range.setStartBefore(el);
            frag = range.createContextualFragment(html);
            el.parentNode.insertBefore(frag, el);
            return el.previousSibling;
        }else if(where == 'afterBegin'){
            range.selectNodeContents(el);
            range.collapse(true);
            frag = range.createContextualFragment(html);
            el.insertBefore(frag, el.firstChild);
            return el.firstChild;
        }else if(where == 'beforeEnd'){
            range.selectNodeContents(el);
            range.collapse(false);
            frag = range.createContextualFragment(html);
            el.appendChild(frag);
            return el.lastChild;
        }else if(where == 'afterEnd'){
            range.setStartAfter(el);
            frag = range.createContextualFragment(html);
            el.parentNode.insertBefore(frag, el.nextSibling);
            return el.nextSibling;
        }else{
            throw 'Illegal insertion point -> "' + where + '"';
        } 
    };
    
    /**
     * Creates new Dom element(s) and inserts them before el
     * @param {HTMLElement} el The context element
     * @param {Object} o The Dom object spec (and children)
     * @param {<i>Boolean</i>} returnElement (optional) true to return a YAHOO.ext.Element
     * @return {HTMLElement} The new node
     */
    this.insertBefore = function(el, o, returnElement){
        el = YAHOO.util.Dom.get(el);
        var newNode;
        if(this.useDom){
            newNode = createDom(o, null);
            el.parentNode.insertBefore(newNode, el);
        }else{
            var html = createHtml(o);
            newNode = this.insertHtml('beforeBegin', el, html);
        }
        return returnElement ? YAHOO.ext.Element.get(newNode, true) : newNode;
    };
    
    /**
     * Creates new Dom element(s) and inserts them after el
     * @param {HTMLElement} el The context element
     * @param {Object} o The Dom object spec (and children)
     * @return {HTMLElement} The new node
     */
    this.insertAfter = function(el, o, returnElement){
        el = YAHOO.util.Dom.get(el);
        var newNode;
        if(this.useDom){
            newNode = createDom(o, null);
            el.parentNode.insertBefore(newNode, el.nextSibling);
        }else{
            var html = createHtml(o);
            newNode = this.insertHtml('afterEnd', el, html);
        }
        return returnElement ? YAHOO.ext.Element.get(newNode, true) : newNode;
    };
    
    /**
     * Creates new Dom element(s) and appends them to el
     * @param {HTMLElement} el The context element
     * @param {Object} o The Dom object spec (and children)
     * @param {<i>Boolean</i>} returnElement (optional) true to return a YAHOO.ext.Element
     * @return {HTMLElement} The new node
     */
    this.append = function(el, o, returnElement){
        el = YAHOO.util.Dom.get(el);
        var newNode;
        if(this.useDom){
            newNode = createDom(o, null);
            el.appendChild(newNode);
        }else{
            var html = createHtml(o);
            newNode = this.insertHtml('beforeEnd', el, html);
        }
        return returnElement ? YAHOO.ext.Element.get(newNode, true) : newNode;
    };
    
    /**
     * Creates new Dom element(s) and overwrites the contents of el with them
     * @param {HTMLElement} el The context element
     * @param {Object} o The Dom object spec (and children)
     * @param {<i>Boolean</i>} returnElement (optional) true to return a YAHOO.ext.Element
     * @return {HTMLElement} The new node
     */
    this.overwrite = function(el, o, returnElement){
        el = YAHOO.util.Dom.get(el);
        el.innerHTML = createHtml(o);
        return returnElement ? YAHOO.ext.Element.get(el.firstChild, true) : el.firstChild;
    };
    
    /**
     * Creates a new YAHOO.ext.DomHelper.Template from the Dom object spec 
     * @param {Object} o The Dom object spec (and children)
     * @param {<i>Boolean</i>} returnElement (optional) true to return a YAHOO.ext.Element
     * @return {YAHOO.ext.DomHelper.Template} The new template
     */
    this.createTemplate = function(o){
        var html = createHtml(o);
        return new YAHOO.ext.DomHelper.Template(html);
    };
}();

/**
* @class
* Represents an HTML fragment template
* @constructor
* @param {String} html The HTML fragment
*/
YAHOO.ext.DomHelper.Template = function(html){
    /**@private*/
    this.html = html;
    /**@private*/
    this.re = /\{(\w+)\}/g;
};
YAHOO.ext.DomHelper.Template.prototype = {
    /**
     * Returns an HTML fragment of this template with the specified values applied
     * @param {Object} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @return {String}
     */
    applyTemplate : function(values){
        if(this.compiled){
            return this.compiled(values);
        }
        var empty = '';
        var fn = function(match, index){
            if(typeof values[index] != 'undefined'){
                return values[index];
            }else{
                return empty;
            }
        }
        return this.html.replace(this.re, fn);
    },
    
    /**
     * Compiles the template into an internal function, eliminating the RegEx overhead
     */
    compile : function(){
        var html = this.html;
        var re = /\{(\w+)\}/g;
        var body = [];
        body.push("this.compiled = function(values){ return ");
        var result;
        var lastMatchEnd = 0;
        while ((result = re.exec(html)) != null){
            body.push("'", html.substring(lastMatchEnd, result.index), "' + ");
            body.push("values[", html.substring(result.index+1,re.lastIndex-1), "] + ");
            lastMatchEnd = re.lastIndex;
        }
        body.push("'", html.substr(lastMatchEnd), "';};");
        eval(body.join(''));
    },
   
    /**
     * Applies the supplied values to the template and inserts the new node(s) before el
     * @param {HTMLElement} el The context element
     * @param {Object} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @param {<i>Boolean</i>} returnElement (optional) true to return a YAHOO.ext.Element
     * @return {HTMLElement} The new node
     */
    insertBefore: function(el, values, returnElement){
        el = YAHOO.util.Dom.get(el);
        var newNode = YAHOO.ext.DomHelper.insertHtml('beforeBegin', el, this.applyTemplate(values));
        return returnElement ? YAHOO.ext.Element.get(newNode, true) : newNode;
    },
    
    /**
     * Applies the supplied values to the template and inserts the new node(s) after el
     * @param {HTMLElement} el The context element
     * @param {Object} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @param {<i>Boolean</i>} returnElement (optional) true to return a YAHOO.ext.Element
     * @return {HTMLElement} The new node
     */
    insertAfter : function(el, values, returnElement){
        el = YAHOO.util.Dom.get(el);
        var newNode = YAHOO.ext.DomHelper.insertHtml('afterEnd', el, this.applyTemplate(values));
        return returnElement ? YAHOO.ext.Element.get(newNode, true) : newNode;
    },
    
    /**
     * Applies the supplied values to the template and append the new node(s) to el
     * @param {HTMLElement} el The context element
     * @param {Object} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @param {<i>Boolean</i>} returnElement (optional) true to return a YAHOO.ext.Element
     * @return {HTMLElement} The new node
     */
    append : function(el, values, returnElement){
        el = YAHOO.util.Dom.get(el);
        var newNode = YAHOO.ext.DomHelper.insertHtml('beforeEnd', el, this.applyTemplate(values));
        return returnElement ? YAHOO.ext.Element.get(newNode, true) : newNode;
    },
    
    /**
     * Applies the supplied values to the template and overwrites the content of el with the new node(s)
     * @param {HTMLElement} el The context element
     * @param {Object} values The template values. Can be an array if your params are numeric (i.e. {0}) or an object (i.e. {foo: 'bar'})
     * @param {<i>Boolean</i>} returnElement (optional) true to return a YAHOO.ext.Element
     * @return {HTMLElement} The new node
     */
    overwrite : function(el, values, returnElement){
        el = YAHOO.util.Dom.get(el);
        el.innerHTML = '';
        var newNode = YAHOO.ext.DomHelper.insertHtml('beforeEnd', el, this.applyTemplate(values));
        return returnElement ? YAHOO.ext.Element.get(newNode, true) : newNode;
    }
};