/*
   BeyondRhino.JS
   by Dan Shappir and Sjoerd Visscher
   For more information see http://w3future.com/html/beyondJS
*/
load("beyond.js", "beyondLazy.js", "beyondStreams.js");

var beyondRhinoVer = 0.9;
var Beyond = {};

importPackage(java.util);

function javaArray(type, length) {
	var alloc = new Function("length", "return java.lang.reflect.Array.newInstance(" + type + ", length)");
	return alloc(length);
}

function alert(s) {
	print(s);
}

function toJava(v, asObjects) {
	return typeof(v.toJava) == "function" ? v.toJava(asObjects) : v;
}

_NP.toJava = function() {
	var v = this.valueOf();
	return v == Math.round(v) ? new java.lang.Integer(v) : new java.lang.Double(v);
};
_SP.toJava = function() {
	var v = this.valueOf();
	return new java.lang.String(v);
};
Boolean.prototype.toJava = function() {
	var v = this.valueOf();
	return new java.lang.Boolean(v);
};

function javaType(v) {
	switch ( typeof(v) ) {
		case "boolean":
			return java.lang.Boolean.TYPE;

		case "number":
			return v == Math.round(v) ? java.lang.Integer.TYPE : java.lang.Double.TYPE;

		case "string":
			return java.lang.String;
	}
	return java.lang.Object;
}
_AP.toJava = function(asObjects) {
	if ( !this.length )
		return java.lang.reflect.Array.newInstance(java.lang.Object, 0);
	var r;
	if ( asObjects )
		r = java.lang.reflect.Array.newInstance(java.lang.Object, this.length);
	else {
		var type = this.coalesce(function(type, v) {
			var jt = javaType(v);
			return isUndefined(type) || type == jt || ( type == java.lang.Integer.TYPE && jt == java.lang.Double.TYPE ) ?
				jt : java.lang.Object;
		});
		r = java.lang.reflect.Array.newInstance(type, this.length);
	}
	this.foreach(function(v, i) {
		r[i] = toJava(v);
	});
	return r;
};

function toJavaScript(v) {
	if ( typeof(v) != "object" || v == null )
		return v;
	if ( typeof(v.getClass) != "function" ) {
		if ( typeof(v.valueOf) == "function" )
			v = v.valueOf();
		return "undefined" != v ? v : undefined;
	}
	var cls = v.getClass();
	switch ( String(cls.getName()) ) {
		case "java.lang.Boolean":
			return "true" == v;
			
		case "java.lang.Byte":
		case "java.lang.Short":
		case "java.lang.Integer":
		case "java.lang.Long":
			return parseInt(v);
			
		case "java.lang.Float":
		case "java.lang.Double":
			return parseFloat(v);

		default:
			var s = String(v);
			return s == v ? s : v;
	}
}

// Hack to enable use of Array.from() on Java arrays
_AP.toArray = null;

_AP.enumeration = function() {
	var self = this;
	var index = 0;
	return new Enumeration() {
		hasMoreElements : function() {
			return index < self.length;
		},
		nextElement : function() {
			return toJava(self[index++]);
		}
	};
};
_LP.enumeration = function() {
	var self = this;
	var item = [];
	var cached = false;
	var reuse = false;
	return new Enumeration() {
		hasMoreElements : function() {
			if ( !cached ) {
				cached = reuse = true;
				item = self.generator(item);
			}
			return item.length;		  
		},
		nextElement : function() {
			if ( !reuse )
				item = self.generator(item);
			cached = !cached;
			reuse = false;
			return toJava(item[0]);
		}
	};
};
Beyond.enumeration = function(e) {
	return function() {
		return e.hasMoreElements() ? [ toJavaScript(e.nextElement()) ] : [];
	}.lazy();
};

_AP.iterator = function() {
	var self = this;
	var index = 0;
	return new Iterator() {
		hasNext : function() {
			return index < self.length;
		},
		next : function() {
			return toJava(self[index++]);
		},
		remove : function() {
			if ( index > 0 )
				self.splice(--index, 1);
		}
	};
};
_LP.iterator = function() {
	var self = this;
	var item = [];
	var cached = false;
	var reuse = false;
	return new Iterator() {
		hasNext : function() {
			if ( !cached ) {
				cached = reuse = true;
				item = self.generator(item);
			}
			return item.length;		  
		},
		next : function() {
			if ( !reuse )
				item = self.generator(item);
			cached = !cached;
			reuse = false;
			return toJava(item[0]);
		}
	};
};
Beyond.iterator = function(i) {
	return function() {
		return i.hasNext() ? [ toJavaScript(i.next()) ] : [];
	}.lazy();
};

function isTypeOrDerived(v, type) {
	for ( var c = v.getClass() ; c ; c = c.getSuperclass() )
		if ( c.getName() == type )
			return true;
	return false;
}

_AP.listIterator = function() {
	var self = this;
	var index, prev;
	return new ListIterator() {
hasNext : function() {
		  return isDefined(index) ? index < self.length : self.length > 0;
	  },
hasPrevious : function() {
		  return isDefined(index) ? index > 0 : self.length > 0;
	  },
next : function() {
		  if ( isUndefined(index) )
			  index = 0;
		  prev = index;
		  return toJava(self[index++]);
	  },
previous : function() {
		  if ( isUndefined(index) )
			  index = self.length;
		  prev = index;
		  return toJava(self[--index]);
	  },
nextIndex : function() {
		  return isUndefined(index) ? 0 : index;
	  },
previousIndex : function() {
		  return ( isUndefiend(index) ? self.length : index ) - 1;
	  },
set : function(element) {
		  if ( isDefined(prev) )
			  self.splice(prev, 1, toJavaScript(element));
	  },
add : function(element) {
		  prev = index;
		  self.splice(index++, 0, toJavaScript(element));
	  },
remove : function() {
		  if ( isDefined(prev) )
			  self.splice(prev, 1);
	  }
	};
};
Beyond.reverseIterator = function(i) {
	return function() {
		return i.hasPrevious() ? [ toJavaScript(i.previous()) ] : [];
	}.lazy();
};

_AP.collection = function() {
	var self = this;
	return new Collection() {
add : function(element) {
	      element = toJavaScript(element)
			if ( self.search(element) != -1 )
		      return false;
	      self.push(element);
	      return true;
      },
addAll : function(collection) {
	      var me = this;
	      return Beyond.iterator(collection.iterator()).coalesce(function(r, v) {
		      return me.add(v) || r;
	      });
      },
clear : function() {
	      self.length = 0;
      },
contains : function(element) {
	      return self.search(toJavaScript(element)) != -1;
      },
containsAll : function(collection) {
	      var me = this;
	      return Beyond.iterator(collection.iterator()).coalesce(true, function(r, v) {
		      return r && me.contains(v);
	      });
      },
isEmpty : function() {
	      return self.length == 0;
      },
iterator : function() {
	      return self.iterator();
      },
remove : function(element) {
	      element = toJavaScript(element)
			var index = self.search(element);
	      if ( index == -1 )
		      return false;
	      self.splice(index, 1);
	      return true;
      },
removeAll : function(collection) {
	      var me = this;
	      return Beyond.iterator(collection.iterator()).coalesce(function(r, v) { return me.remove(v) || r; });
      },
retainAll : function(collection) {
	      var length = self.length;
	      var filtered = self.filter(function(v) { return collection.contains(toJava(v)); });
	      filtered.foreach(function(v, i) { self[i] = v; });
	      self.length = filtered.length;
	      return self.length != length;
      },
size : function() {
	      return self.length;
      },
toArray : function(a) {
	      if ( typeof(a) != "object" )
		      return self.toJava(true);
	      var type = a.getClass().getName().slice(2, -1);
	      var java = self.collect(function(v) { return toJava(v, true); }).
			 filter(function(v) { return isTypeOrDerived(v, type); });
	      if ( a.length < java.length )
		      a = javaArray(type, java.length);
	      java.foreach(function(v, i) { a[i] = v; });
	      if ( a.length > java.length )
		      Arrays.fill(a, java.length, a.length, null);
	      return a;
      }
	};
};
Beyond.collection = function(collection) {
	return function(item) {
		var i = item.length ? item[1] : collection.iterator();
		return i.hasNext() ? [ toJavaScript(i.next()) , i ] : [];
	}.lazy();
};

_AP.list = function() {
	var self = this;
	return new List() {
add : function(index, element) {
	      if ( isUndefined(element) )
		      self.push(toJavaScript(index));
	      else
		      self.splice(index, 0, toJavaScript(element));
	      return true;
      },
addAll : function(index, collection) {
	      var me = this;
	      if ( isUndefined(collection) )
		      Beyond.iterator(index.iterator()).foreach(function(v) { me.add(v); });
	      else
		      Beyond.iterator(collection.iterator()).foreach(function(v) { me.add(index++, v); });
	      return true;
      },
clear : function() {
	      self.length = 0;
      },
contains : function(element) {
	      return self.search(toJavaScript(element)) != -1;
      },
containsAll : function(collection) {
	      var me = this;
	      return Beyond.iterator(collection.iterator()).coalesce(true, function(r, v) { return r && me.contains(v); });
      },
get : function(index) {
	      var x = toJava(self[index]);
	      return toJava(self[index]);
      },
indexOf : function(element) {
	      return self.search(toJavaScript(element));
      },
lastIndexOf : function(element) {
	      var index = self.reverese().search(toJavaScript(element));
	      return index == -1 ? -1 : self.length - index - 1;
      },
isEmpty : function() {
	      return self.length == 0;
      },
iterator : function() {
	      return self.iterator();
      },
listIterator : function(index) {
	      var i = self.listIterator();
	      if ( isDefined(index) )
		      for ( ; i.hasNext() && i.nextIndex() < index ; i.next() );
	      return i;
      },
remove : function(index) {
	      return self.splice(index, 1)[0];
      },
removeAll : function(collection) {
	      var me = this;
	      return Beyond.iterator(collection.iterator()).coalesce(function(r, v) { return me.remove(v) || r; });
      },
retainAll : function(collection) {
	      var length = self.length;
	      var filtered = self.filter(function(v) { return collection.contains(toJava(v)); });
	      filtered.foreach(function(v, i) { self[i] = v; });
	      self.length = filtered.length;
	      return self.length != length;
      },
set : function(index, element) {
	      var prev = self[index];
	      self[index] = toJavaScript(element);
	      return toJava(prev, true);
      },
size : function() {
	      return self.length;
      },
subList : function(from, to) {
	      return self.slice(from, to).list();
      },
toArray : function(a) {
	      if ( typeof(a) != "object" )
		      return self.toJava(true);
	      var type = a.getClass().getName().slice(2, -1);
	      var java = self.collect(function(v) { return toJava(v, true); }).
			 filter(function(v) { return isTypeOrDerived(v, type); });
	      if ( a.length < java.length )
		      a = javaArray(type, java.length);
	      java.foreach(function(v, i) { a[i] = v; });
	      if ( a.length > java.length )
		      Arrays.fill(a, java.length, a.length, null);
	      return a;
      }
	};
};
Beyond.list = Beyond.collection;
Beyond.reverseList = function(list) {
	return function(item) {
		var i = item.length ? item[1] : list.listIterator();
		return i.hasPrevious() ? [ toJavaScript(i.previous()) , i ] : [];
	}.lazy();
};

var File = {

read : function(file, cache, reader) {
	       var rf = function(item) {
		       var stream = item[1] ? 
				    item[1] :
				    new java.io.BufferedReader(reader ? file : new java.io.FileReader(file));
		       var line = stream.readLine();
		       return line != null ? [ String(line), stream ] : [];
	       }.lazy();
	       if ( cache )
		       rf = rf.cached();
	       rf.file = file;
	       return rf;
       },
write : function(file, overwrite, writer) {
	       var st = new Stream(writer ? file : new java.io.FileWriter(file, !overwrite));
	       var handle = st.foreach(function(v, stream) {
		       if ( isDefined(v) ) {
			       var s = String(v) + "\n";
			       stream.write(s, 0, s.length);
			       stream.flush();
		       }
	       });
	       st.stop = function() {
		       this.detach(handle);
		       this.owner.Close();
	       };
	       return st;
       },
process : function(input, output, f, append) {
	       if ( !f )
		       f = Function.NOP;
	       else if ( f.constructor === RegExp ) {
		       var re = f;
		       f = function(line) {
			       if ( re.test(line) )
				       return line;
		       };
	       }
	       return this.write(output, !append).extend(this.read(input).collect(f));
       }

};

File.StdIn = File.read(new java.io.InputStreamReader(java.lang.System["in"]), false, true);
File.StdOut = File.write(new java.io.OutputStreamWriter(java.lang.System["out"]), false, true);
File.StdErr = File.write(new java.io.OutputStreamWriter(java.lang.System["err"]), false, true);