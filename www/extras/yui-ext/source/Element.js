/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */

/**
 * @class Wraps around a DOM element and provides convenient access to Yahoo 
 * UI library functionality.<br><br>
 * Usage:<br>
 * <pre><code>
 * var el = YAHOO.ext.Element.get('myElementId');
 * // or the shorter
 * var el = getEl('myElementId');
 * </code></pre>
 * Using YAHOO.ext.Element.get() instead of calling the constructor directly ensures you get the same object 
 * each call instead of constructing a new one.<br>
 * @requires YAHOO.util.Dom
 * @requires YAHOO.util.Event
 * @requires YAHOO.util.CustomEvent 
 * @requires YAHOO.util.Anim (optional) to support animation
 * @requires YAHOO.util.Motion (optional) to support animation
 * @requires YAHOO.util.Easing (optional) to support animation
 * @constructor Create a new Element directly.
 * @param {String} elementId 
 * @param {<i>Boolean</i>} forceNew (optional) By default the constructor checks to see if there is already an instance of this element in the cache and if there is it returns the same instance. This will skip that check (useful for extending this class).
 */
YAHOO.ext.Element = function(elementId, forceNew){
    var dom = YAHOO.util.Dom.get(elementId);
    if(!dom){ // invalid id/element
        return;
    }
    if(!forceNew && YAHOO.ext.Element.cache[dom.id]){ // element object already exists
        return YAHOO.ext.Element.cache[dom.id];
    }
    /**
     * The DOM element
     * @type HTMLElement
     */
    this.dom = dom;
    /**
     * The DOM element ID
     * @type String
     */
    this.id = this.dom.id;
    /**
     * @private the current visibility mode
     */
    this.visibilityMode = YAHOO.ext.Element.VISIBILITY;
    
    
    /**
     * @private the element's default display mode
     */
    this.originalDisplay = YAHOO.util.Dom.getStyle(this.dom, 'display');
    if (!this.originalDisplay || this.originalDisplay == 'none') {
        this.originalDisplay = '';
    }
    
    /**
     * The default unit to append to CSS values where a unit isn't provided (Defaults to px).
     * @type String
     */
    this.defaultUnit = 'px';
    
    /**
     * @private the element's default overflow
     */
    this.originalClip = YAHOO.util.Dom.getStyle(this.dom, 'overflow');
    
   
    /**
     * Fires when visibility changes. Uses fireDirect with signature: (oElement, boolean isVisible)
     * @type CustomEvent
     */
    this.onVisibilityChanged = new YAHOO.util.CustomEvent('visibilityChanged');
    
    /**
     * Fires when element moves. Uses fireDirect with signature: (oElement, newX, newY)
     * @type CustomEvent
     */
    this.onMoved = new YAHOO.util.CustomEvent('moved');
    
    /**
     * Fires when element is resized. Uses fireDirect with signature: (oElement, newWidth, newHeight)
     * @type CustomEvent
     */
    this.onResized = new YAHOO.util.CustomEvent('resized');
    
    // The delegates below handle setting of 'this' when being called from other objects.
    
    /**
     * @private
     */
    this.visibilityDelegate = this.fireVisibilityChanged.createDelegate(this);
    /**
     * @private
     */
    this.resizedDelegate = this.fireResized.createDelegate(this);
    /**
     * @private
     */
    this.movedDelegate = this.fireMoved.createDelegate(this);
}

YAHOO.ext.Element.prototype = {    
    // Utility methods to make firing events painless.
    /**
     *@private
     */
    fireMoved : function(){
        this.onMoved.fireDirect(this, this.getX(), this.getY());
    },
    
    /**
     *@private
     */
    fireVisibilityChanged : function(){
        this.onVisibilityChanged.fireDirect(this, this.isVisible());
    },
    
    /**
     *@private
     */
    fireResized : function(){
        this.onResized.fireDirect(this, this.getWidth(), this.getHeight());
    },
    
    /**
     * Sets the elements visibility mode. When setVisible() is called it
     * will use this to determine whether to set the visibility or the display property.
     * @param visMode Element.VISIBILITY or Element.DISPLAY
     */
    setVisibilityMode : function(visMode){
        this.visibilityMode = visMode;
    },
    
    /**
     * Convenience method for setVisibilityMode(Element.DISPLAY)
     */
    enableDisplayMode : function(){
        this.setVisibilityMode(YAHOO.ext.Element.DISPLAY)
    },
    
    /**
     * Perform Yahoo UI animation on this element. 
     * @param {Object} args The YUI animation control args
     * @param {<i>Float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeBoth)
     * @param {<i>Function</i>} animType (optional) YAHOO.util.Anim subclass to use. For example: YAHOO.util.Motion
     */
    animate : function(args, duration, onComplete, easing, animType){
        this.anim(args, duration, onComplete, easing, animType);
    },
    
    /**
     * @private Internal animation call
     */
    anim : function(args, duration, onComplete, easing, animType){
        animType = animType || YAHOO.util.Anim;
        var anim = new animType(this.dom, args, duration || .35, 
                easing || YAHOO.util.Easing.easeBoth);
        if(onComplete){
            if(!(onComplete instanceof Array)){
                anim.onComplete.subscribe(onComplete);
            }else{
                for(var i = 0; i < onComplete.length; i++){
                    var fn = onComplete[i];
                    if(fn) anim.onComplete.subscribe(fn);
                }
            }
        }
        anim.animate();
    },
    
    /**
     * Checks whether the element is currently visible using both visibility and display properties.
     * @param {<i>Boolean</i>} deep True to walk the dom and see if parent elements are hidden
     * @return {Boolean} Whether the element is currently visible 
     */
    isVisible : function(deep) {
        var vis = YAHOO.util.Dom.getStyle(this.dom, 'visibility') != 'hidden' 
               && YAHOO.util.Dom.getStyle(this.dom, 'display') != 'none';
        if(!deep || !vis){
            return vis;
        }
        var p = this.dom.parentNode;
        while(p && p.tagName.toLowerCase() != 'body'){
            if(YAHOO.util.Dom.getStyle(p, 'visibility') == 'hidden' || YAHOO.util.Dom.getStyle(p, 'display') == 'none'){
                return false;
            }
            p = p.parentNode;
        }
        return true;
    },
    
    /**
     * Sets the visibility of the element (see details). If the visibilityMode is set to Element.DISPLAY, it will use 
     * the display property to hide the element, otherwise it uses visibility. The default is to hide and show using the visibility property.
     * @param {Boolean} visible Whether the element is visible
     * @param {<i>Boolean</i>} animate (optional) Fade the element in or out (Default is false)
     * @param {<i>Float</i>} duration (optional) How long the fade effect lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeOut for hiding or YAHOO.util.Easing.easeIn for showing)
     */
     setVisible : function(visible, animate, duration, onComplete, easing){
        //if(this.isVisible() == visible) return; // nothing to do
        if(!animate || !YAHOO.util.Anim){
            if(this.visibilityMode == YAHOO.ext.Element.DISPLAY){
                this.setDisplayed(visible);
            }else{
                YAHOO.util.Dom.setStyle(this.dom, 'visibility', visible ? 'visible' : 'hidden');
            }
            this.fireVisibilityChanged();
        }else{
            // make sure they can see the transition
            YAHOO.util.Dom.setStyle(this.dom, 'visibility', 'visible');
            if(this.visibilityMode == YAHOO.ext.Element.DISPLAY){
                this.setDisplayed(true);
            }
            var args = {opacity: { from: (visible?0:1), to: (visible?1:0) }};
            var anim = new YAHOO.util.Anim(this.dom, args, duration || .35, 
                easing || (visible ? YAHOO.util.Easing.easeIn : YAHOO.util.Easing.easeOut));
            anim.onComplete.subscribe((function(){
                if(this.visibilityMode == YAHOO.ext.Element.DISPLAY){
                    this.setDisplayed(visible);
                }else{
                    YAHOO.util.Dom.setStyle(this.dom, 'visibility', visible ? 'visible' : 'hidden');
                }
                this.fireVisibilityChanged();
            }).createDelegate(this));
            if(onComplete){
                anim.onComplete.subscribe(onComplete);
            }
            anim.animate();
        }
    },
    
    /**
     *@private
     */
    isDisplayed : function() {
        return YAHOO.util.Dom.getStyle(this.dom, 'display') != 'none';
    },
    
    /**
     * Toggles the elements visibility or display, depending on visibility mode.
     * @param {<i>Boolean</i>} animate (optional) Fade the element in or out (Default is false)
     * @param {<i>float</i>} duration (optional) How long the fade effect lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeOut for hiding or YAHOO.util.Easing.easeIn for showing)
     */
    toggle : function(animate, duration, onComplete, easing){
        this.setVisible(!this.isVisible(), animate, duration, onComplete, easing); 
    },
    
    /**
     *@private
     */
    setDisplayed : function(value) {
        YAHOO.util.Dom.setStyle(this.dom, 'display', value ? this.originalDisplay : 'none');
    },
    
    /**
     * Tries to focus the element. Any exceptions are caught.
     */
    focus : function() {
        try{
            this.dom.focus();
        }catch(e){}
    },
    
    /**
     * Add a CSS class to the element.
     * @param {String} className The CSS class to add
     */
    addClass : function(className){
        YAHOO.util.Dom.addClass(this.dom, className);
    },
    
    /**
     * Adds the passed className to this element and removes the class from all siblings
     */
    radioClass : function(className){
        var siblings = this.dom.parentNode.childNodes;
        for(var i = 0; i < siblings.length; i++) {
        	var s = siblings[i];
        	if(s.nodeType == 1){
        	    YAHOO.util.Dom.removeClass(s, className);
        	}
        }
        YAHOO.util.Dom.addClass(this.dom, className);
    },
    /**
     * Removes a CSS class from the element.
     * @param {String} className The CSS class to remove
     */
    removeClass : function(className){
        YAHOO.util.Dom.removeClass(this.dom, className);
    },
    
    toggleClass : function(className){
        if(YAHOO.util.Dom.hasClass(this.dom, className)){
            YAHOO.util.Dom.removeClass(this.dom, className);
        }else{
            YAHOO.util.Dom.addClass(this.dom, className);
        }
    },
    
    /**
     * Checks if a CSS class is in use by the element.
     * @param {String} className The CSS class to check
     * @return {Boolean} true or false
     */
    hasClass : function(className){
        return YAHOO.util.Dom.hasClass(this.dom, className);
    },
    
    /**
     * Replaces a CSS class on the element with another.
     * @param {String} oldClassName The CSS class to replace
     * @param {String} newClassName The replacement CSS class
     */
    replaceClass : function(oldClassName, newClassName){
        YAHOO.util.Dom.replaceClass(this.dom, oldClassName, newClassName);
    },
    
    /**
       * Normalizes currentStyle and ComputedStyle.
       * @param {String} property The style property whose value is returned.
       * @return {String} The current value of the style property for this element.
       */
    getStyle : function(name){
        return YAHOO.util.Dom.getStyle(this.dom, name);
    },
    
    /**
       * Wrapper for setting style properties
       * @param {String} property The style property to be set.
       * @param {String} val The value to apply to the given property.
       */
    setStyle : function(name, value){
        YAHOO.util.Dom.setStyle(this.dom, name, value);
    },
    
    /**
       * Gets the current X position of the element based on page coordinates.  Element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
       @ return {String} The X position of the element
       */
    getX : function(){
        return YAHOO.util.Dom.getX(this.dom);
    },
    
    /**
       * Gets the current Y position of the element based on page coordinates.  Element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
       @ return {String} The Y position of the element
       */
    getY : function(){
        return YAHOO.util.Dom.getY(this.dom);
    },
    
    /**
       * Gets the current position of the element based on page coordinates.  Element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
       @ return {Array} The XY position of the element
       */
    getXY : function(){
        return YAHOO.util.Dom.getXY(this.dom);
    },
    
    /**
       * Sets the X position of the element based on page coordinates.  Element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
       @param {String} The X position of the element
       */
    setX : function(x){
        YAHOO.util.Dom.setX(this.dom, x);
        this.fireMoved();
    },
    
    /**
       * Sets the Y position of the element based on page coordinates.  Element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
       @param {String} The Y position of the element
       */
    setY : function(y){
        YAHOO.util.Dom.setY(this.dom, y);
        this.fireMoved();
    },
    
    /**
     * Set the element's X position directly using CSS style (instead of setX())
     * @param {String} left The left CSS property value
     */
    setLeft : function(left){
        YAHOO.util.Dom.setStyle(this.dom, 'left', this.addUnits(left));
        this.fireMoved();
    },
    
    /**
     * Set the element's Y position directly using CSS style (instead of setY())
     * @param {String} top The top CSS property value
     */
    setTop : function(top){
        YAHOO.util.Dom.setStyle(this.dom, 'top', this.addUnits(top));
        this.fireMoved();
    },
    
    /**
     * Set the element's css right style
     * @param {String} left The right CSS property value
     */
    setRight : function(right){
        YAHOO.util.Dom.setStyle(this.dom, 'right', this.addUnits(right));
        this.fireMoved();
    },
    
    /**
     * Set the element's css bottom style
     * @param {String} top The bottom CSS property value
     */
    setBottom : function(bottom){
        YAHOO.util.Dom.setStyle(this.dom, 'bottom', this.addUnits(bottom));
        this.fireMoved();
    },
    
    /**
     * Set the position of the element in page coordinates, regardless of how the element is positioned.
     * The element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
     * @param {Array} pos Contains X & Y [x, y] values for new position (coordinates are page-based)
     * @param {<i>Boolean</i>} animate (optional) Animate the transition (Default is false)
     * @param {<i>float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeBoth)
        */
    setXY : function(pos, animate, duration, onComplete, easing){
        if(!animate || !YAHOO.util.Anim){
            YAHOO.util.Dom.setXY(this.dom, pos);
            this.fireMoved();
        }else{
            this.anim({points: {to: pos}}, duration, [onComplete, this.movedDelegate], easing, YAHOO.util.Motion);
        }
    },
    
    /**
     * Set the position of the element in page coordinates, regardless of how the element is positioned.
     * The element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
     * @param {Number} x X value for new position (coordinates are page-based)
     * @param {Number} y Y value for new position (coordinates are page-based)
     * @param {<i>Boolean</i>} animate (optional) Animate the transition (Default is false)
     * @param {<i>float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeBoth)
     */
    setLocation : function(x, y, animate, duration, onComplete, easing){
        this.setXY([x, y], animate, duration, onComplete, easing);
    },
    
    /**
     * Set the position of the element in page coordinates, regardless of how the element is positioned.
     * The element must be part of the DOM tree to have page coordinates (display:none or elements not appended return false).
     * @param {Number} x X value for new position (coordinates are page-based)
     * @param {Number} y Y value for new position (coordinates are page-based)
     * @param {<i>Boolean</i>} animate (optional) Animate the transition (Default is false)
     * @param {<i>float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeBoth)
     */
    moveTo : function(x, y, animate, duration, onComplete, easing){
        //YAHOO.util.Dom.setStyle(this.dom, 'left', this.addUnits(x));
        //YAHOO.util.Dom.setStyle(this.dom, 'top', this.addUnits(y));
        this.setXY([x, y], animate, duration, onComplete, easing);
    },
    
    /**
       * Returns the region position of the given element.
       * The element must be part of the DOM tree to have a region (display:none or elements not appended return false).
       * @return {Region} A YAHOO.util.Region containing "top, left, bottom, right" member data.
       */
    getRegion : function(){
        return YAHOO.util.Dom.getRegion(this.dom);
    },
    
    /**
     * Returns the offset height of the element
     * @return {Number} The element's height
     */
    getHeight : function(){
        return this.dom.offsetHeight;
    },
    
    /**
     * Returns the offset width of the element
     * @return {Number} The element's width
     */
    getWidth : function(){
        return this.dom.offsetWidth;
    },
    
    /**
     * Returns the size of the element
     * @return {Object} An object containing the element's size {width: (element width), height: (element height)}
     */
    getSize : function(){
        return {width: this.getWidth(), height: this.getHeight()};
    },
    
    /** @private */
    adjustWidth : function(width){
        if(this.autoBoxAdjust && typeof width == 'number' && !this.isBorderBox()){
           width -= (this.getBorderWidth('lr') + this.getPadding('lr'));
        }
        return width;
    },
    
    /** @private */
    adjustHeight : function(height){
        if(this.autoBoxAdjust && typeof height == 'number' && !this.isBorderBox()){
           height -= (this.getBorderWidth('tb') + this.getPadding('tb'));
        }
        return height;
    },
    
    /**
     * Set the width of the element
     * @param {Number} width The new width
     * @param {<i>Boolean</i>} animate (optional) Animate the transition (Default is false)
     * @param {<i>float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeOut if width is larger or YAHOO.util.Easing.easeIn if it is smaller)
     */
    setWidth : function(width, animate, duration, onComplete, easing){
        width = this.adjustWidth(width);
        if(!animate || !YAHOO.util.Anim){
            YAHOO.util.Dom.setStyle(this.dom, 'width', this.addUnits(width));
            this.fireResized();
        }else{
            this.anim({width: {to: width}}, duration, [onComplete, this.resizedDelegate], 
                easing || (width > this.getWidth() ? YAHOO.util.Easing.easeOut : YAHOO.util.Easing.easeIn));
        }
    },
    
    /**
     * Set the height of the element
     * @param {Number} height The new height
     * @param {<i>Boolean</i>} animate (optional) Animate the transition (Default is false)
     * @param {<i>float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeOut if height is larger or YAHOO.util.Easing.easeIn if it is smaller)
     */
     setHeight : function(height, animate, duration, onComplete, easing){
        height = this.adjustHeight(height);
        if(!animate || !YAHOO.util.Anim){
            YAHOO.util.Dom.setStyle(this.dom, 'height', this.addUnits(height));
            this.fireResized();
        }else{
            this.anim({height: {to: height}}, duration, [onComplete, this.resizedDelegate],  
                   easing || (height > this.getHeight() ? YAHOO.util.Easing.easeOut : YAHOO.util.Easing.easeIn));
        }
    },
    
    /**
     * Set the size of the element. If animation is true, both width an height will be animated concurrently.
     * @param {Number} width The new width
     * @param {Number} height The new height
     * @param {<i>Boolean</i>} animate (optional) Animate the transition (Default is false)
     * @param {<i>float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeBoth)
     */
     setSize : function(width, height, animate, duration, onComplete, easing){
        if(!animate || !YAHOO.util.Anim){
            this.setWidth(width);
            this.setHeight(height);
            this.fireResized();
        }else{
            width = this.adjustWidth(width); height = this.adjustHeight(height);
            this.anim({width: {to: width}, height: {to: height}}, duration, [onComplete, this.resizedDelegate], easing);
        }
    },
    
    /**
     * Sets the element's position and size in one shot. If animation is true then width, height, x and y will be animated concurrently.
     * @param {Number} x X value for new position (coordinates are page-based)
     * @param {Number} y Y value for new position (coordinates are page-based)
     * @param {Number} width The new width
     * @param {Number} height The new height
     * @param {<i>Boolean</i>} animate (optional) Animate the transition (Default is false)
     * @param {<i>float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeBoth)
     */
    setBounds : function(x, y, width, height, animate, duration, onComplete, easing){
        if(!animate || !YAHOO.util.Anim){
            this.setWidth(width);
            this.setHeight(height);
            this.setLocation(x, y);
            this.fireResized();
            this.fireMoved();
        }else{
            width = this.adjustWidth(width); height = this.adjustHeight(height);
            this.anim({points: {to: [x, y]}, width: {to: width}, height: {to: height}}, duration, [onComplete, this.movedDelegate], easing, YAHOO.util.Motion);
        }
    },
    
    /**
     * Sets the element's position and size the the specified region. If animation is true then width, height, x and y will be animated concurrently.
     * @param {YAHOO.util.Region} region The region to fill
     * @param {<i>Boolean</i>} animate (optional) Animate the transition (Default is false)
     * @param {<i>float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeBoth)
     */
    setRegion : function(region, animate, duration, onComplete, easing){
        this.setBounds(region.left, region.top, region.right-region.left, region.bottom-region.top, animate, duration, onComplete, easing);
    },
    
    /**
     * Appends an event handler to this element
     * @param {String}   eventName     The type of event to listen for
     * @param {Function} handler        The method the event invokes
     * @param {<i>Object</i>}   scope  (optional)  An arbitrary object that will be 
     *                             passed as a parameter to the handler
     * @param {<i>boolean</i>}  override (optional) If true, the obj passed in becomes
     *                             the execution scope of the listener
     */
    addListener : function(eventName, handler, scope, override){
        YAHOO.util.Event.addListener(this.dom, eventName, handler, scope, override);
    },
    
    /**
     * Appends an event handler to this element and automatically prevents the default action, and if set stops propagation (bubbling) as well
     * @param {String}   eventName     The type of event to listen for
     * @param {Boolean}   stopPropagation     Whether to also stopPropagation (bubbling) 
     * @param {Function} handler        The method the event invokes
     * @param {<i>Object</i>}   scope  (optional)  An arbitrary object that will be 
     *                             passed as a parameter to the handler
     * @param {<i>boolean</i>}  override (optional) If true, the obj passed in becomes
     *                             the execution scope of the listener
     */
    addHandler : function(eventName, stopPropagation, handler, scope, override){
        var fn = YAHOO.ext.Element.createStopHandler(stopPropagation, handler, scope, override);
        YAHOO.util.Event.addListener(this.dom, eventName, fn);
    },
    
    /** @private */
    
    /**
     * Appends an event handler to this element (Same as addListener)
     * @param {String}   eventName     The type of event to listen for
     * @param {Function} handler        The method the event invokes
     * @param {<i>Object</i>}   scope (optional)   An arbitrary object that will be 
     *                             passed as a parameter to the handler
     * @param {<i>boolean</i>}  override (optional) If true, the obj passed in becomes
     *                             the execution scope of the listener
     */
    on : function(eventName, handler, scope, override){
        YAHOO.util.Event.addListener(this.dom, eventName, handler, scope, override);
    },
    
    /**
     * Append a managed listener - See {@link YAHOO.ext.EventObject} for more details.
     * @param {String}   eventName     The type of event to listen for
     * @param {Function} fn        The method the event invokes
     * @param {<i>Object</i>}   scope  (optional)  An arbitrary object that will be 
     *                             passed as a parameter to the handler
     * @param {<i>boolean</i>}  override (optional) If true, the obj passed in becomes
     *                             the execution scope of the listener
     */
    addManagedListener : function(eventName, fn, scope, override){
        return YAHOO.ext.EventManager.on(this.dom, eventName, fn, scope, override);
    },
    
    /** 
     * Append a managed listener (shorthanded for {@link #addManagedListener}) 
     * @param {String}   eventName     The type of event to listen for
     * @param {Function} fn        The method the event invokes
     * @param {<i>Object</i>}   scope  (optional)  An arbitrary object that will be 
     *                             passed as a parameter to the handler
     * @param {<i>boolean</i>}  override (optional) If true, the obj passed in becomes
     *                             the execution scope of the listener
     */
    mon : function(eventName, fn, scope, override){
        return YAHOO.ext.EventManager.on(this.dom, eventName, fn, scope, override);
    },
    /**
     * Removes an event handler from this element
     * @param {String} sType the type of event to remove
     * @param {Function} fn the method the event invokes
     */
    removeListener : function(eventName, handler){
        YAHOO.util.Event.removeListener(this.dom, eventName, handler);
    },
    
    /**
     * Removes all previous added listeners from this element
     */
    removeAllListeners : function(){
        YAHOO.util.Event.purgeElement(this.dom);
    },
    
    
    /**
     * Set the opacity of the element
     * @param {Float} opacity The new opacity. 0 = transparent, .5 = 50% visibile, 1 = fully visible, etc
     * @param {<i>Boolean</i>} animate (optional) Animate (fade) the transition (Default is false)
     * @param {<i>Float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeOut if height is larger or YAHOO.util.Easing.easeIn if it is smaller)
     */
     setOpacity : function(opacity, animate, duration, onComplete, easing){
        if(!animate || !YAHOO.util.Anim){
            YAHOO.util.Dom.setStyle(this.dom, 'opacity', opacity);
        }else{
            this.anim({opacity: {to: opacity}}, duration, onComplete, easing);
        }
    },
    
    /**
     * Same as getX()
     */
    getLeft : function(){
        return this.getX();
    },
    
    /**
     * Gets the right X coordinate of the element (element X position + element width)
     * @return {String} The left position of the element
     */
    getRight : function(){
        return this.getX() + this.getWidth();
    },
    
    /**
     * Same as getY()
     */
    getTop : function() {
        return this.getY();
    },
    
    /**
     * Gets the bottom Y coordinate of the element (element Y position + element height)
     * @return {String} The bottom position of the element
     */
    getBottom : function(){
        return this.getY() + this.getHeight();
    },
    
    /**
    * Set the element as absolute positioned with the specified z-index
    * @param {<i>Number</i>} zIndex (optional)
    */
    setAbsolutePositioned : function(zIndex){
        this.setStyle('position', 'absolute');
        if(zIndex){
            this.setStyle('z-index', zIndex);
        }
    },
    
    /**
    * Set the element as relative positioned with the specified z-index
    * @param {<i>Number</i>} zIndex (optional)
    */
    setRelativePositioned : function(zIndex){
        this.setStyle('position', 'relative');
        if(zIndex){
            this.setStyle('z-index', zIndex);
        }
        //this.setStyle('left', 0);
        //this.setStyle('top', 0);
    },
    
    /**
    * Clear positioning back to the default when the document was loaded
    */
    clearPositioning : function(){
        this.setStyle('position', '');
        this.setStyle('left', '');
        this.setStyle('right', '');
        this.setStyle('top', '');
        this.setStyle('bottom', '');
    },
    
    /**
    * Gets an object with all CSS positioning properties. Useful along with {@link #setPositioning} to get snapshot before performing an update and then restoring the element.
    */
    getPositioning : function(){
        return {
            'position' : this.getStyle('position'),
            'left' : this.getStyle('left'),
            'right' : this.getStyle('right'),
            'top' : this.getStyle('top'),
            'bottom' : this.getStyle('bottom')
        };
    },
    
    /**
     * Gets the width of the border(s) for the specified side(s)
     * @param {String} side Can be t, l, r, b or any combination of those to add multiple values. For example, 
     * passing lr would get the border (l)eft width + the border (r)ight width.
     * @return {Number} The width of the sides passed added together
     */
    getBorderWidth : function(side){
        var width = 0;
        var b = YAHOO.ext.Element.borders;
        for(var s in b){
            if(typeof b[s] != 'function'){
                if(side.indexOf(s) !== -1){
                    var w = parseInt(this.getStyle(b[s]), 10);
                    if(!isNaN(w)) width += w;
                }
            }
        }
        return width;
    },
    
    /**
     * Gets the width of the padding(s) for the specified side(s)
     * @param {String} side Can be t, l, r, b or any combination of those to add multiple values. For example, 
     * passing lr would get the padding (l)eft + the padding (r)ight.
     * @return {Number} The padding of the sides passed added together
     */
    getPadding : function(side){
        var pad = 0;
        var b = YAHOO.ext.Element.paddings;
        for(var s in b){
            if(typeof s[b] != 'function'){
                if(side.indexOf(s) !== -1){
                    var w = parseInt(this.getStyle(b[s]), 10);
                    if(!isNaN(w)) pad += w;
                }
            }
        }
        return pad;
    },
    
    /**
    * Set positioning with an object returned by {@link #getPositioning}.
    */
    setPositioning : function(positionCfg){
        this.setStyle('position', positionCfg.position);
        this.setStyle('left', positionCfg.left);
        this.setStyle('right', positionCfg.right);
        this.setStyle('top', positionCfg.top);
        this.setStyle('bottom', positionCfg.bottom);
    },
    
    /**
     * Move this element relative to it's current position.
     * @param {String} direction Possible values are: 'left', 'right', 'up', 'down'.
     * @param {Number} distance How far to move the element in pixels
     * @param {<i>Boolean</i>} animate (optional) Animate the movement (Default is false)
     * @param {<i>Float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. 
     */
     move : function(direction, distance, animate, duration, onComplete, easing){
        var xy = this.getXY();
        direction = direction.toLowerCase();
        switch(direction){
            case 'left':
                this.moveTo(xy[0]-distance, xy[1], animate, duration, onComplete, easing);
                return;
           case 'right':
                this.moveTo(xy[0]+distance, xy[1], animate, duration, onComplete, easing);
                return;
           case 'up':
                this.moveTo(xy[0], xy[1]-distance, animate, duration, onComplete, easing);
                return;
           case 'down':
                this.moveTo(xy[0], xy[1]+distance, animate, duration, onComplete, easing);
                return;
        }
    },
    
    /**
     *  Clip overflow on the element - use {@link #unclip} to remove
     */
    clip : function(){
        this.setStyle('overflow', 'hidden');
    },
    
    /**
     *  Return clipping (overflow) to original clipping when the document loaded
     */
    unclip : function(){
        this.setStyle('overflow', this.originalClip);
    },
    
    /**
     * Align this element with another element.
     * @param {String/HTMLElement/YAHOO.ext.Element} element The element to align to.
     * @param {String} position The position to align to. Possible values are 'tl' - top left, 'tr' - top right, 'bl' - bottom left, and 'br' - bottom right. 
     * @param {<i>Array</i>} offsets (optional) Offset the positioning by [x, y]
     * @param {<i>Boolean</i>} animate (optional) Animate the movement (Default is false)
     * @param {<i>Float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. 
     */
     alignTo : function(element, position, offsets, animate, duration, onComplete, easing){
        var otherEl = getEl(element);
        if(!otherEl){
            return; // must not exist
        }
        offsets = offsets || [0, 0];
        var r = otherEl.getRegion();
        position = position.toLowerCase();
        switch(position){
           case 'bl':
                this.moveTo(r.left + offsets[0], r.bottom + offsets[1], 
                            animate, duration, onComplete, easing);
                return;
           case 'br':
                this.moveTo(r.right + offsets[0], r.bottom + offsets[1], 
                            animate, duration, onComplete, easing);
                return;
           case 'tl':
                this.moveTo(r.left + offsets[0], r.top + offsets[1], 
                            animate, duration, onComplete, easing);
                return;
           case 'tr':
                this.moveTo(r.right + offsets[0], r.top + offsets[1], 
                            animate, duration, onComplete, easing);
                return;
        }
    },
    
    /**
    * Clears any opacity settings from this element. Required in some cases for IE.
    */
    clearOpacity : function(){
        if (window.ActiveXObject) {
            this.dom.style.filter = '';
        } else {
            this.dom.style.opacity = '';
            this.dom.style['-moz-opacity'] = '';
            this.dom.style['-khtml-opacity'] = '';
        }
    },
    
    /**
    * Hide this element - Uses display mode to determine whether to use "display" or "visibility". See {@link #setVisible}.
    * @param {<i>Boolean</i>} animate (optional) Animate (fade) the transition (Default is false)
     * @param {<i>Float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeBoth)
     */
    hide : function(animate, duration, onComplete, easing){
        this.setVisible(false, animate, duration, onComplete, easing);
    },
    
    /**
    * Show this element - Uses display mode to determine whether to use "display" or "visibility". See {@link #setVisible}.
    * @param {<i>Boolean</i>} animate (optional) Animate (fade in) the transition (Default is false)
     * @param {<i>Float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeBoth)
     */
    show : function(animate, duration, onComplete, easing){
        this.setVisible(true, animate, duration, onComplete, easing);
    },
    
    /**
     * @private Test if size has a unit, otherwise appends the default 
     */
    addUnits : function(size){
        if(typeof size == 'number' || !YAHOO.ext.Element.unitPattern.test(size)){
            return size + this.defaultUnit;
        }
        return size;
    },
    
    beginMeasure : function(){
        var p = this.dom;
        if(p.offsetWidth || p.offsetHeight){
            return; // offsets work already
        }
        var changed = [];
        var p = this.dom; // start with this element
        while(p && p.tagName.toLowerCase() != 'body'){
            if(YAHOO.util.Dom.getStyle(p, 'display') == 'none'){
                changed.push({el: p, visibility: YAHOO.util.Dom.getStyle(p, 'visibility')});
                p.style.visibility = 'hidden';
                p.style.display = 'block';
            }
            p = p.parentNode;
        }
        this._measureChanged = changed;        
    },
    
    endMeasure : function(){
        var changed = this._measureChanged;
        if(changed){
            for(var i = 0, len = changed.length; i < len; i++) {
            	var r = changed[i];
            	r.el.style.visibility = r.visibility;
                r.el.style.display = 'none';
            }
            this._measureChanged = null;
        }
    },
    /**
    *   Update the innerHTML of this element, optionally searching for and processing scripts
    * @param {String} html The new HTML
    * @param {<i>Boolean</i>} loadScripts (optional) true to look for and process scripts
    */
    update : function(html, loadScripts){
        this.dom.innerHTML = html;
        if(!loadScripts) return;
        
        var dom = this.dom;
        var _parseScripts = function(){
            var s = this.dom.getElementsByTagName("script");
            var docHead = document.getElementsByTagName("head")[0];
            
            //   For browsers which discard scripts when inserting innerHTML, extract the scripts using a RegExp
            if(s.length == 0){
                var re = /(?:<script.*(?:src=[\"\'](.*)[\"\']).*>.*<\/script>)|(?:<script.*>([\S\s]*?)<\/script>)/ig; // assumes HTML well formed and then loop through it.
                var match;
                while(match = re.exec(html)){
                     var s0 = document.createElement("script");
                     if (match[1])
                        s0.src = match[1];
                     else if (match[2])
                        s0.text = match[2];
                     else
                          continue;
                     docHead.appendChild(s0);
                }
            }else {
              for(var i = 0; i < s.length; i++){
                 var s0 = document.createElement("script");
                 s0.type = s[i].type;
                 if (s[i].text) {
                    s0.text = s[i].text;
                 } else {
                    s0.src = s[i].src;
                 }
                 docHead.appendChild(s0);
              }
            }
        }
        // set timeout to give DOM opportunity to catch up
        setTimeout(_parseScripts, 10);
    },
    
    /**
    * Gets this elements UpdateManager
    * @return The UpdateManager
    * @type YAHOO.ext.UpdateManager 
    */
    getUpdateManager : function(){
        if(!this.updateManager){
            this.updateManager = new YAHOO.ext.UpdateManager(this);
        }
        return this.updateManager;
    },
    
    /**
    * Calculates the x, y to center this element on the screen
    * @return {Array} The x, y values [x, y]
    */
    getCenterXY : function(offsetScroll){
        var centerX = Math.round((YAHOO.util.Dom.getViewportWidth()-this.getWidth())/2);
        var centerY = Math.round((YAHOO.util.Dom.getViewportHeight()-this.getHeight())/2);
        if(!offsetScroll){
            return [centerX, centerY];
        }else{
            var scrollX = document.documentElement.scrollLeft || document.body.scrollLeft || 0;
            var scrollY = document.documentElement.scrollTop || document.body.scrollTop || 0;
            return[centerX + scrollX, centerY + scrollY];
        }
    },
    /**
    * Gets an array of child YAHOO.ext.Element objects by tag name
    * @param {String} tagName
    * @return {Array} The children
    */
    getChildrenByTagName : function(tagName){
        var children = this.dom.getElementsByTagName(tagName);
        var len = children.length;
        var ce = [len];
        for(var i = 0; i < len; ++i){
            ce[i] = YAHOO.ext.Element.get(children[i], true);
        }
        return ce;
    },
    
    /**
    * Gets an array of child YAHOO.ext.Element objects by class name and optional tagName
    * @param {String} className
    * @param {<i>String</i>} tagName (optional)
    * @return {Array} The children
    */
    getChildrenByClassName : function(className, tagName){
        var children = YAHOO.util.Dom.getElementsByClassName(className, tagName, this.dom);
        var len = children.length;
        var ce = [len];
        for(var i = 0; i < len; ++i){
            ce[i] = YAHOO.ext.Element.get(children[i], true);
        }
        return ce;
    },
    
    /**
     * Tests various css rules/browsers to determine if this element uses a border box
     */
    isBorderBox : function(){
        var el = this.dom;
        var b = YAHOO.ext.util.Browser;
        var strict = YAHOO.ext.Strict;
        return((b.isIE && !b.isIE7) || (b.isIE7 && !strict && el.style.boxSizing != 'content-box') || 
           (b.isGecko && YAHOO.util.Dom.getStyle(el, "-moz-box-sizing") == 'border-box') || 
           (!b.isSafari && YAHOO.util.Dom.getStyle(el, "box-sizing") == 'border-box'));  
    },
    
    /**
     * Return a box {x, y, width, height} that can be used to set another elements
     * size to match this element. If contentBox is true, a box for the content 
     * of the element is returned.
     */
    getBox : function(contentBox){
        var xy = this.getXY();
        var el = this.dom;
        var w = el.offsetWidth;
        var h = el.offsetHeight;
        if(!contentBox){
            return {x: xy[0], y: xy[1], width: w, height: h};
        }else{
            var l = this.getBorderWidth('l')+this.getPadding('l');
            var r = this.getBorderWidth('r')+this.getPadding('r');
            var t = this.getBorderWidth('t')+this.getPadding('t');
            var b = this.getBorderWidth('b')+this.getPadding('b');
            return {x: xy[0]+l, y: xy[1]+t, width: w-(l+r), height: h-(t+b)};
        }
    },
    
    /**
     * Sets the element's box. Use getBox() on another element to get a box obj. If animate is true then width, height, x and y will be animated concurrently.
     * @param {Object} box The box to fill {x, y, width, height}
     * @param {<i>Boolean</i>} adjust (optional) Whether to adjust for box-model issues automatically
     * @param {<i>Boolean</i>} animate (optional) Animate the transition (Default is false)
     * @param {<i>float</i>} duration (optional) How long the animation lasts. (Defaults to .35 seconds)
     * @param {<i>Function</i>} onComplete (optional) Function to call when animation completes.
     * @param {<i>Function</i>} easing (optional) YAHOO.util.Easing method to use. (Defaults to YAHOO.util.Easing.easeBoth)
     */
    setBox : function(box, adjust, animate, duration, onComplete, easing){
        var w = box.width, h = box.height;
        if((adjust && !this.autoBoxAdjust) && !this.isBorderBox()){
           w -= (this.getBorderWidth('lr') + this.getPadding('lr'));
           h -= (this.getBorderWidth('tb') + this.getPadding('tb'));
        }
        this.setBounds(box.x, box.y, w, h, animate, duration, onComplete, easing);
    },
    
    repaint : function(){
        var dom = this.dom;
        YAHOO.util.Dom.addClass(dom, 'yui-ext-repaint');
        setTimeout(function(){
            YAHOO.util.Dom.removeClass(dom, 'yui-ext-repaint');
        }, 1);
    }
};

/**
 * Whether to automatically adjust width and height settings for box-model issues
 */
YAHOO.ext.Element.prototype.autoBoxAdjust = true;

/**
 * @private Used to check if a value has a unit
 */
YAHOO.ext.Element.unitPattern = /\d+(px|em|%|en|ex|pt|in|cm|mm|pc)$/i;
/**
 * Visibility mode constant - Use visibility to hide element
 * @type Number
 */
YAHOO.ext.Element.VISIBILITY = 1;
/**
 * Visibility mode constant - Use display to hide element
 * @type Number
 */
YAHOO.ext.Element.DISPLAY = 2;

/** @ignore */
YAHOO.ext.Element.borders = {l: 'border-left-width', r: 'border-right-width', t: 'border-top-width', b: 'border-bottom-width'};
/** @ignore */
YAHOO.ext.Element.paddings = {l: 'padding-left', r: 'padding-right', t: 'padding-top', b: 'padding-bottom'};
        
/**
 * @private Call out to here so we make minimal closure
 */
YAHOO.ext.Element.createStopHandler = function(stopPropagation, handler, scope, override){
    return function(e){
        if(e){
            if(stopPropagation){
                YAHOO.util.Event.stopEvent(e);
            }else {
                YAHOO.util.Event.preventDefault(e);
            }
        }
        handler.call(override && scope ? scope : window, e, scope);
    };
};

/**
 * @private
 */
YAHOO.ext.Element.cache = {};

/**
 * Static method to retreive Element objects. Uses simple caching to consistently return the same object. 
 * Automatically fixes if an object was recreated with the same id via AJAX or DOM.
 * @param {String/HTMLElement/Element} el The id of the element or the element to wrap (must have an id). If you pass in an element, it is returned
 * @param {<i>Boolean</i>} autoGenerateId (optional) Set this flag to true if you are passing an element without an id (like document.body). It will auto generate an id if one isn't present. 
 * @return {Element} The element object
 */
YAHOO.ext.Element.get = function(el, autoGenerateId){
    if(!el){ return null; }
    if(el instanceof YAHOO.ext.Element){
        el.dom = YAHOO.util.Dom.get(el.id); // refresh dom element in case no longer valid
        YAHOO.ext.Element.cache[el.id] = el; // in case it was created directly with Element(), let's cache it
        return el;
    }
    var key = el;
    if(typeof el != 'string'){ // must be an element
        if(!el.id && !autoGenerateId){ return null; }
        YAHOO.util.Dom.generateId(el, 'elgen-');
        key = el.id;
    }
    var element = YAHOO.ext.Element.cache[key];
    if(!element){
        element = new YAHOO.ext.Element(key);
        YAHOO.ext.Element.cache[key] = element;
    }else{
        element.dom = YAHOO.util.Dom.get(key);
    }
    return element;
};

/**
 * Shorthand function for YAHOO.ext.Element.get()
 */
var getEl = YAHOO.ext.Element.get;

// clean up refs
YAHOO.util.Event.addListener(window, 'unload', function(){ YAHOO.ext.Element.cache = null; });