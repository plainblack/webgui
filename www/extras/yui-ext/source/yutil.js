/*
 * YUI Extensions 0.33 RC2
 * Copyright(c) 2006, Jack Slocum.
 */

YAHOO.namespace('ext');
YAHOO.namespace('ext.util');
YAHOO.namespace('ext.grid');
YAHOO.ext.Strict = (document.compatMode == 'CSS1Compat');
YAHOO.ext.SSL_SECURE_URL = 'javascript:false';
// for old browsers
window.undefined = undefined;
/**
 * @class Function
 */
 //
/**
 * Creates a callback that passes arguments[0], arguments[1], arguments[2], ...
 * Call directly on any function. Example: <code>myFunction.createCallback(myarg, myarg2)</code>
 * Will create a function that is bound to those 2 args.
 * @return {Function} The new function
*/
Function.prototype.createCallback = function(/*args...*/){
    // make args available, in function below
    var args = arguments;
    var method = this;
    return function() {
        return method.apply(window, args);
    };
};

/**
 * Creates a delegate (callback) that sets the scope to obj.
 * Call directly on any function. Example: <code>this.myFunction.createDelegate(this)</code>
 * Will create a function that is automatically scoped to this.
 * @param {Object} obj (optional) The object for which the scope is set
 * @param {<i>Array</i>} args (optional) Overrides arguments for the call. (Defaults to the arguments passed by the caller)
 * @param {<i>Boolean/Number</i>} appendArgs (optional) if True args are appended to call args instead of overriding, 
 *                                             if a number the args are inserted at the specified position
 * @return {Function} The new function
 */
Function.prototype.createDelegate = function(obj, args, appendArgs){
    var method = this;
    return function() {
        var callargs = args || arguments;
        if(appendArgs === true){
            callArgs = Array.prototype.slice.call(arguments, 0);
            callargs = callArgs.concat(args);
        }else if(typeof appendArgs == 'number'){
            callargs = Array.prototype.slice.call(arguments, 0); // copy arguments first
            var applyArgs = [appendArgs, 0].concat(args); // create method call params
            Array.prototype.splice.apply(callargs, applyArgs); // splice them in
        }
        return method.apply(obj || window, callargs);
    };
};

/**
 * Calls this function after the number of millseconds specified.
 * @param {Number} millis The number of milliseconds for the setTimeout call
 * @param {Object} obj (optional) The object for which the scope is set
 * @param {<i>Array</i>} args (optional) Overrides arguments for the call. (Defaults to the arguments passed by the caller)
 * @param {<i>Boolean/Number</i>} appendArgs (optional) if True args are appended to call args instead of overriding, 
 *                                             if a number the args are inserted at the specified position
 * @return {Number} The timeout id that can be used with clearTimeout
 */
Function.prototype.defer = function(millis, obj, args, appendArgs){
    return setTimeout(this.createDelegate(obj, args, appendArgs), millis);
};
/**
 * Create a combined function call sequence of the original function + the passed function.
 * The resulting function returns the results of the original function.
 * The passed fcn is called with the parameters of the original function
 * @param {Function} fcn The function to sequence
 * @param {<i>Object</i>} scope (optional) The scope of the passed fcn (Defaults to scope of original function or window)
 * @return {Function} The new function
 */
Function.prototype.createSequence = function(fcn, scope){
    if(typeof fcn != 'function'){
        return this;
    }
    var method = this;
    return function() {
        var retval = method.apply(this || window, arguments);
        fcn.apply(scope || this || window, arguments);
        return retval;
    };
};

/**
 * Creates an interceptor function. The passed fcn is called before the original one. If it returns false, the original one is not called.
 * The resulting function returns the results of the original function.
 * The passed fcn is called with the parameters of the original function.
 * @addon
 * @param {Function} fcn The function to call before the original
 * @param {<i>Object</i>} scope (optional) The scope of the passed fcn (Defaults to scope of original function or window)
 * @return {Function} The new function
 */
Function.prototype.createInterceptor = function(fcn, scope){
    if(typeof fcn != 'function'){
        return this;
    }
    var method = this;
    return function() {
        fcn.target = this;
        fcn.method = method;
        if(fcn.apply(scope || this || window, arguments) === false){
            return;
        }
        return method.apply(this || window, arguments);;
    };
};

/**
 * @class YAHOO.ext.util.Browser
 * @singleton
 */
YAHOO.ext.util.Browser = new function(){
	var ua = navigator.userAgent.toLowerCase();
	/** @type Boolean */
	this.isOpera = (ua.indexOf('opera') > -1);
   	/** @type Boolean */
	this.isSafari = (ua.indexOf('webkit') > -1);
   	/** @type Boolean */
	this.isIE = (window.ActiveXObject);
   	/** @type Boolean */
	this.isIE7 = (ua.indexOf('msie 7') > -1);
   	/** @type Boolean */
	this.isGecko = !this.isSafari && (ua.indexOf('gecko') > -1);
	
	if(ua.indexOf("windows") != -1 || ua.indexOf("win32") != -1){
	    /** @type Boolean */
	    this.isWindows = true;
	}else if(ua.indexOf("macintosh") != -1){
		/** @type Boolean */
	    this.isMac = true;
	}
}();

YAHOO.print = function(arg1, arg2, etc){
    if(!YAHOO.ext._console){
        var cs = YAHOO.ext.DomHelper.insertBefore(document.body.firstChild,
        {tag: 'div',style:'width:250px;height:350px;overflow:auto;border:3px solid #c3daf9;' +
                'background:white;position:absolute;right:5px;top:5px;' +
                'font:normal 8pt arial,verdana,helvetica;z-index:50000;padding:5px;'}, true);
        new YAHOO.ext.Resizable(cs, {
            transparent:true,
            handles: 'all',
            pinned:true, 
            adjustments: [0,0], 
            wrap:true, 
            draggable:(YAHOO.util.DD ? true : false)
        });
        cs.on('dblclick', cs.hide);
        YAHOO.ext._console = cs;
    }
    var msg = '';
    for(var i = 0, len = arguments.length; i < len; i++) {
    	msg += arguments[i] + '<hr noshade style="color:#eeeeee;" size="1">';
    }
    YAHOO.ext._console.dom.innerHTML = msg + YAHOO.ext._console.dom.innerHTML;
    YAHOO.ext._console.dom.scrollTop = 0;
    YAHOO.ext._console.show();
};

YAHOO.printf = function(format, arg1, arg2, etc){
    var args = Array.prototype.slice.call(arguments, 1);
    YAHOO.print(format.replace(
      /\{\{[^{}]*\}\}|\{(\d+)(,\s*([\w.]+))?\}/g,
      function(m, a1, a2, a3) {
        if (m.chatAt == '{') {
          return m.slice(1, -1);
        }
        var rpl = args[a1];
        if (a3) {
          var f = eval(a3);
          rpl = f(rpl);
        }
        return rpl ? rpl : '';
      }));
}

 /**
 * Enable custom handler signature and event cancelling. Using fireDirect() instead of fire() calls the subscribed event handlers 
 * with the exact parameters passed to fireDirect, instead of the usual (eventType, args[], obj). IMO this is more intuitive 
 * and promotes cleaner code. Also, if an event handler returns false, it is returned by fireDirect and no other handlers will be called.<br>
 * Example:<br><br><pre><code>
 * if(beforeUpdateEvent.fireDirect(myArg, myArg2) !== false){
 *     // do update
 * }</code></pre>
 */
YAHOO.util.CustomEvent.prototype.fireDirect = function(){
    var len=this.subscribers.length;
    for (var i=0; i<len; ++i) {
        var s = this.subscribers[i];
        if(s){
            var scope = (s.override) ? s.obj : this.scope;
            if(s.fn.apply(scope, arguments) === false){
                return false;
            }
        }
    }
    return true;
};

YAHOO.extendX = function(subclass, superclass, overrides){
    YAHOO.extend(subclass, superclass);
    subclass.override = function(o){
        YAHOO.override(subclass, o);
    };
    if(!subclass.prototype.override){
        subclass.prototype.override = function(o){
            for(var method in o){
                this[method] = o[method];
            }  
        };
    }
    if(overrides){
        subclass.override(overrides);
    }
};

YAHOO.override = function(origclass, overrides){
    if(overrides){
        var p = origclass.prototype;
        for(var method in overrides){
            p[method] = overrides[method];
        }
    }
};

/**
 * @class YAHOO.ext.util.DelayedTask
 * Provides a convenient method of performing setTimeout where a new
 * timeout cancels the old timeout. An example would be performing validation on a keypress.
 * You can use this class to buffer
 * the keypress events for a certain number of milliseconds, and perform only if they stop
 * for that amount of time.
 * @constructor The parameters to this constructor serve as defaults and are not required.
 * @param {<i>Function</i>} fn (optional) The default function to timeout
 * @param {<i>Object</i>} scope (optional) The default scope of that timeout
 * @param {<i>Array</i>} args (optional) The default Array of arguments
 */
YAHOO.ext.util.DelayedTask = function(fn, scope, args){
    var timeoutId = null;
    
    /**
     * Cancels any pending timeout and queues a new one
     * @param {Number} delay The milliseconds to delay
     * @param {Function} newFn (optional) Overrides function passed to constructor
     * @param {Object} newScope (optional) Overrides scope passed to constructor
     * @param {Array} newArgs (optional) Overrides args passed to constructor
     */
    this.delay = function(delay, newFn, newScope, newArgs){
        if(timeoutId){
            clearTimeout(timeoutId);
        }
        fn = newFn || fn;
        scope = newScope || scope;
        args = newArgs || args;
        timeoutId = setTimeout(fn.createDelegate(scope, args), delay);
    };
    
    /**
     * Cancel the last queued timeout
     */
    this.cancel = function(){
        if(timeoutId){
            clearTimeout(timeoutId);
            timeoutId = null;
        }
    };
};

/**
 * @class YAHOO.ext.util.Observable
 * Abstract base class that provides a common interface for publishing events. Subclasses are expected to 
 * to have a property "events" with all the events defined.<br>
 * For example:
 * <pre><code>
 var Employee = function(name){
    this.name = name;
    this.events = {
        'fired' : new YAHOO.util.CustomEvent('fired'),
        'quit' : new YAHOO.util.CustomEvent('quit')
    }
 }
 YAHOO.extend(Employee, YAHOO.ext.util.Observable);
</code></pre>
 */
YAHOO.ext.util.Observable = function(){};
YAHOO.ext.util.Observable.prototype = {
    /**
     * Fires the specified event with the passed parameters (minus the event name).
     * @param {String} eventName
     * @param {Object...} args Variable number of parameters are passed to handlers
     * @return {Boolean} returns false if any of the handlers return false otherwise it returns true
     */
    fireEvent : function(){
        var ce = this.events[arguments[0].toLowerCase()];
        return ce.fireDirect.apply(ce, Array.prototype.slice.call(arguments, 1));
    },
    
    /**
     * Appends an event handler to this element
     * @param {String}   eventName     The type of event to listen for
     * @param {Function} handler        The method the event invokes
     * @param {<i>Object</i>}   scope  (optional) The scope (this object) for the handler
     * @param {<i>boolean</i>}  override (optional) If true, scope becomes the scope
     */
    addListener : function(eventName, fn, scope, override){
        eventName = eventName.toLowerCase();
        if(!this.events[eventName]){
            // added for a better message when subscribing to wrong event
            throw 'You are trying to listen for an event that does not exist: "' + eventName + '".';
        }
        this.events[eventName].subscribe(fn, scope, override);
    },
    
    /**
     * Appends an event handler to this element that is delayed the specified number of milliseconds.
     * @param {String}   eventName     The type of event to listen for
     * @param {Function} handler        The method the event invokes
     * @param {<i>Object</i>}   scope  (optional) The scope (this object) for the handler
     * @param {<i>Number</i>}  delay (optional) The number of milliseconds to delay
     * @return {Function} The wrapped function that was created (can be used to remove the listener)
     */
    delayedListener : function(eventName, fn, scope, delay){
        var newFn = function(){
            setTimeout(fn.createDelegate(scope, arguments), delay || 1);
        }
        this.addListener(eventName, newFn);
        return newFn;
    },
    
    /**
     * Removes a listener
     * @param {String}   eventName     The type of event to listen for
     * @param {Function} handler        The handler to remove
     * @param {<i>Object</i>}   scope  (optional) The scope (this object) for the handler
     */
    removeListener : function(eventName, fn, scope){
        this.events[eventName.toLowerCase()].unsubscribe(fn, scope);
    },
    
    /**
     * Removes all listeners for this object
     */
    purgeListeners : function(){
        for(var evt in this.events){
            if(typeof this.events[evt] != 'function'){
                 this.events[evt].unsubscribeAll();
            }
        }
    }
};
YAHOO.ext.util.Observable.prototype.on = YAHOO.ext.util.Observable.prototype.addListener;

/**
 * @class YAHOO.ext.util.Config
 * Class with one useful method
 * @singleton
 */
YAHOO.ext.util.Config = {
    /**
     * Copies all the properties of config to obj.
     * @param {Object} obj The receiver of the properties
     * @param {Object} config The source of the properties
     * @param {Object} defaults A different object that will also be applied for default values
     * @return {Object} returns obj
     */
    apply : function(obj, config, defaults){
        if(defaults){
            this.apply(obj, defaults);
        }
        if(config){
            for(var prop in config){
                obj[prop] = config[prop];
            }
        }
        return obj;
    }
};

if(!String.escape){
    String.escape = function(string) {
        return string.replace(/('|\\)/g, "\\$1");
    };
};

String.leftPad = function (val, size, ch) {
    var result = new String(val);
    if (ch == null) {
        ch = " ";
    }
    while (result.length < size) {
        result = ch + result;
    }
    return result;
};

// workaround for Safari 1.3 not supporting hasOwnProperty
if(YAHOO.util.Connect){
    YAHOO.util.Connect.setHeader = function(o){
		for(var prop in this._http_header){
		    // if(this._http_header.hasOwnProperty(prop)){
			if(typeof this._http_header[prop] != 'function'){
				o.conn.setRequestHeader(prop, this._http_header[prop]);
			}
		}
		delete this._http_header;
		this._http_header = {};
		this._has_http_headers = false;
	};   
}
/**
 * A simple enhancement to drag drop that allows you to constrain the movement of the
 * DD or DDProxy object to a particular element.<br /><br />
 * 
 * Usage:
 <pre><code>
 var dd = new YAHOO.util.DDProxy("dragDiv1", "proxytest",  
                { dragElId: "existingProxyDiv" });
 dd.startDrag = function(){
     this.constrainTo('parent-id');
 }; 
 </code></pre>
 * Or you can initalize it using the {@link YAHOO.ext.Element} object:
 <pre><code>
 getEl('dragDiv1').initDDProxy('proxytest', {dragElId: "existingProxyDiv"}, {
     startDrag : function(){
         this.constrainTo('parent-id');
     }
 });
 </code></pre>
 */
if(YAHOO.util.DragDrop){
    /**
     * Provides default constraint padding to "constrainTo" elements (defaults to {left: 0, right:0, top:0, bottom:0}).
     * @type Object
     */
    YAHOO.util.DragDrop.prototype.defaultPadding = {left:0, right:0, top:0, bottom:0};
    
    /**
     * Initializes the drag drop object's constraints to restrict movement to a certain element.
     * @param {String/HTMLElement/Element} constrainTo The element to constrain to.
     * @param {Object/Number} pad (optional) Pad provides a way to specify "padding" of the constraints, 
     * and can be either a number for symmetrical padding (4 would be equal to {left:4, right:4, top:4, bottom:4}) or
     * an object containing the sides to pad. For example: {right:10, bottom:10}
     * @param {Boolean} inContent (optional) Constrain the draggable in the content box of the element (inside padding and borders)
     */
    YAHOO.util.DragDrop.prototype.constrainTo = function(constrainTo, pad, inContent){
        if(typeof pad == 'number'){
            pad = {left: pad, right:pad, top:pad, bottom:pad};
        }
        pad = pad || this.defaultPadding;
        var b = getEl(this.getEl()).getBox();
        var ce = getEl(constrainTo);
        var c = ce.dom == document.body ? { x: 0, y: 0,
                width: YAHOO.util.Dom.getViewportWidth(), 
                height: YAHOO.util.Dom.getViewportHeight()} : ce.getBox(inContent || false);
        this.resetConstraints();
        this.setXConstraint(
                b.x - c.x - (pad.left||0), // left
                c.width - b.x - b.width - (pad.right||0) // right
        );
        this.setYConstraint(
                b.y - c.y - (pad.top||0), // top
                c.height - b.y - b.height - (pad.bottom||0)  //bottom
        );
    }
}