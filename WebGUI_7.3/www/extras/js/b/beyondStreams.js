/*
   BeyondStreams.JS
   by Dan Shappir and Sjoerd Visscher
   For more information see http://w3future.com/html/beyondJS
*/
if ( typeof(beyondVer) !== "number" || beyondVer < 0.99 )
	alert("beyondStreams requires Beyond JS library ver 0.99 or higher");
var beyondStreamsVer = 0.91;

function Stream(owner) {
	this.owner = owner;
	this.callbacks = [];
}
var _STP = Stream.prototype;

_STP.foreach = function(f) {
	return this.callbacks.push(f)-1;
};
_STP.detach = function(x) {
	if ( isUndefined(x) || x === null ) {
		if ( this.callbacks.isEmpty() )
			return false;
		this.callbacks.empty();
		return true;
	}
	if ( typeof(x) == "function" || typeof(x) == "object" )
		x = this.callbacks.search("===".curry(x));
	if ( x < 0 || x >= this.callbacks.length )
		return false;
	if ( x == this.callbacks.length-1 )
		this.callbacks.pop();
	else {
		this.callbacks[x] = this.undef;
		if ( this.callbacks.filter(isDefined).isEmpty() )
			this.callbacks.empty();
	}
	return true;
};

_STP.push = function() {
	var self = this;
	Array.from(arguments).foreach(function(v) {
		self.callbacks.foreach(function(f, i) {
			if ( typeof(f) == "function" ) {
				if ( f.call(self.owner, v, self.owner, self) === false )
					self.detach(i);
			}
			else if ( f(v, self.owner, self) === false )
				self.detach(i);
		});
	});
	return this;
};
_STP.append = function() {
	this.push.apply(this, Array.from(arguments).filter(isDefined));
	return this;
};
_STP.extend = function(x) {
	if ( !x || isUndefined(x.foreach) )
		this.push(x);
	else {
		var self = this;
		x.foreach(function(v) { self.push(v); });
	}
	return this;
};

_STP.feed = function(st) {
	return this.foreach(function(v) { st.push(v); });
};

_STP.pre = function(f) {
	var st = new Stream(this.owner);
	st.collect(f).feed(this);
	return st;
};

_STP.fold = function(r, f) {
	if ( isUndefined(f) ) {
		f = arguments[0];
		r = arguments[1];
	}
	if ( typeof(f) == "string" ) 
		f = f.toFunction();
	var st = new Stream(this.owner);
	this.coalesce(function(x, v) {
		r = isDefined(r) ? f(r, v) : v;
		st.push(r);
	});
	return st;
};
_STP.search = function(f) {
	if ( f.constructor === RegExp )
		f = Function.from(f, "test");
	else if ( typeof(f) != "function" ) {
		var x = f;
		f = function(y) { return y === x; };
	}
	var st = new Stream(this.owner);
	this.foreach(function(v, owner, self) {
		if ( f(v, owner, self) ) {
			st.push(v);
			return false;
		}
	});
	return st;
};

_STP.delay = function(iMilliSeconds) {
	var st = new Stream(this.owner);
	this.foreach(function(v) { Function.from(st, "push").delay(iMilliSeconds)(v); });
	return st;
};
_STP.buffer = function(f) {
	if ( typeof(f) == "number" ) {
		var count = f;
		f = function(v, buffer) {
			return buffer.length+1 >= count;
		};
	}
	else if ( f.constructor === RegExp )
		f = Function.from(f, "test");
	var st = new Stream(this.owner), buffer = [];
	this.foreach(function(v, owner, self) {
		var r = f.call(owner, v, buffer, owner, self);
		buffer.push(v);
		if ( r ) {
			st.push(buffer);
			buffer = [];
		}
	});
	return st;
};

Stream.from = function(x) {
	if ( typeof(x.foreach) != "function" )
		x = Array.from(x);
	var st = new this(x);
	x.foreach(function(v) { st.push(v); });
	return st;
};
iteratable(Stream);

function timerStream(iMilliSeconds) {
	var st = new Stream(iMilliSeconds);
	var nInterval = setInterval(function() { st.push(new Date); }, iMilliSeconds);
	st.stop = function() {
		if ( isDefined(nInterval) ) {
			clearInterval(nInterval);
			nInterval = timerStream.undef;
		}
	};
	return st;
}

function eventStream(element, eventName, noAttach) {
	if ( typeof(element) == "string" )
		element = element.element();
	var st = new Stream(element);

	if ( !noAttach && isDefined(element.attachEvent) ) {
		function pushEvent(event) {
			st.push(event ? event : window.event);
		}
		if ( element.attachEvent(eventName, pushEvent) ) {
			st.stop = function() {
				element.detachEvent(eventName, pushEvent);
			};
			return st;
		}
	}

	function pushEvent(event) {
		if ( !st.stopped )
			st.push(event ? event : window.event);
	}
	var prev = eval("element." + eventName);
	if ( !prev )
		eval("element." + eventName + " = pushEvent");
	else
		eval("element." + eventName + " = prev.andThen(pushEvent)");
	st.stop = function() {
		st.stopped = true;
	};
	return st;
}
function propertyStream(element, propertyName) {
	if ( typeof(element) == "string" )
		element = element.element();
	var st = new Stream(element);
	var handle = st.foreach(Function.set(element, propertyName));
	st.stop = function() {
		this.detach(handle);
		this.stop = Function.NOP;
	};
	return st;
}

function cancelDefaultAction(e) {
	e.returnValue = false;
	return e;
}
function cancelBubble(e) {
	e.cancelBubble = true;
	return e;
}

function logStream(log) {
	var st = new Stream(log ? log : []);
	var handle = st.foreach(function(v) {
		st.owner.push([ new Date, v ]);
	});
	st.stop = function() {
		st.detach(handle);
		this.stop = Function.NOP;
	};
	st.flush = function() {
		st.owner.empty();
	};
	return st;
}
