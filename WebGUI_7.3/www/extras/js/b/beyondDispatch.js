/*
   BeyondDispatch.JS
   by Dan Shappir and Sjoerd Visscher
   For more information see http://w3future.com/html/beyondJS
*/
if ( typeof(beyondVer) !== "number" || beyondVer < 0.98 )
	alert("beyondDispatch requires Beyond JS library ver 0.98 or higher");
var beyondDispatchVer = 0.90;

function dispatch(otherwise, argString) {
	var options = [];
	var isFunction = typeof(otherwise) == "function";
	if ( isFunction && isUndefined(argString) )
		argString = Function.argString(otherwise);
	var dispatcher = function() {
		var self = this, args = arguments, result;
		return 0 <= options.foreach(function(v) {
			if ( v != null && v[0].apply(self, args) ) {
				result = typeof(v[1]) == "function" ? v[1].apply(self, args) : v[1];
				return false;
			}
		}) ? result : isFunction ? otherwise.apply(self, args) : otherwise;
	};
	dispatcher.add = function(test, target) {
		if ( isUndefined(target) ) {
			target = test;
			test = target.length;
		}
		if ( typeof(test) == "string" ) {
			var args = typeof(target) == "function" ? Function.argString(target) : "";
			eval("test = function(" + args + ") { return " + test + "; }");
			return options.push([test, target]) - 1;
		}
		test = dispatch.fix(test);
		return isUndefined(test) ? -1 : options.push([test, target]) - 1;
	};
	dispatcher.addList = function() {
		var result = -1;
		for ( var i = 0 ; i < arguments.length ; i += 2 )
			result = this.add(arguments[i], arguments[i + 1]);
		return result;
	};
	dispatcher.remove = function(index) {
		options[index] = null;
	};
	dispatcher.removeAll = function() {
		options = [];
	};
	dispatcher.clone = function() {
		var clone = dispatch(otherwise, argString);
		options.foreach(function(e) { 
			if ( e != null )
				clone.add(e[0], e[1]);
		});
		return clone;
	};
	return dispatcher.withArgString(argString);
}

dispatch.fix = select.curry({
	prep: "typeof",
	map : {
		number : function(x) {
			if ( x >= 0 )
				return function() { return arguments.length == x; };
			x = -x;
			return function() { return arguments.length >= x; }
		},
		object : function(x) {
			if ( typeof(x.foreach) == "function" )
				return function() {
					var args = arguments;
					return -1 == x.foreach(function(v, i) {
						var t = typeof(v);
						if ( isUndefined(t) )
							return true;
						if ( i >= args.length )
							return false;
						var a = args[i];
						if ( t == "function" )
							return v.call(this, a);
						if ( v instanceof RegExp )
							return v.test(a);
						if ( t == "string" ) {
							t = v.slice(1);
							switch ( v.charAt(0) ) {
								case ".":
									switch ( typeof(a) ) {
										case "number":
											a = new Number(a);
											break;
										case "boolean":
											a = new Boolean(a);
											break;
										case "string":
											a = new String(a);
									}
									var i = t.indexOf(":");
									if ( i > -1 ) {
										v = t.slice(i + 1);
										t = t.slice(0, i);
									}
									if ( !(t in a) )
										return false;
									if ( i == -1 )
										return true;
									a = a[t];
									t = v;
								case ":":
									return typeof(a) == t || 
										( t != "function" && eval("typeof(" + t + ") == 'function' && a instanceof " + t) );
								case "^":
									return eval(t + ".isPrototypeOf(a)");
								case "?":
									return eval("a " + t);
								case "\\":
									v = t;
							}
						}
						return typeof(v.equals) == "function" ? v.equals(a) : v == a;
					});
				};
		},
		"function" : function(x) { return x; }
	}
});
