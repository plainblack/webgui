/*
   beyondXML.js
   by Dan Shappir and Sjoerd Visscher
   For more information see http://w3future.com/html/beyondJS
*/
if ( typeof(beyondVer) !== "number" || beyondVer < 0.95 )
	alert("BeyondXML requires Beyond JS library ver 0.95 or higher");
var beyondXMLVer = 0.96;

var beyondXML = new function() {
	var isMozilla = typeof(Document) != "undefined";

	this.createDocument = function() {
		return isMozilla ? new Document() : new ActiveXObject("Microsoft.XMLDOM");
	};
	this.parseFromString = function(doc, xml) {
		return isMozilla ? doc = (new DOMParser()).parseFromString(xml, "text/xml") : doc.loadXML(xml);
	};
	this.load = function(doc, url) {
		return doc.load(url);
	};
	this.invoke = function(method) {
		return Function.from(null, method);
	};

	var origToArray = Array.from;
	Array.from = function(x) {
		var n = x.nextNode;
		return typeof(n) != "object" ? origToArray.call(this, x) :
			!n ? [] : Array.fill(function() { if ( n = x.nextNode ) return n; }, [ n ]);
	};

	if ( typeof(beyondLazyVer) == "number" && beyondLazyVer >= 0.95 ) {
		var origToLazy = Lazy.from;
		Lazy.from = function(x) {
			var n = x.nextNode;
			if ( typeof(n) != "object" )
				return origToLazy.call(this, x);
			return function(prev) {
				if ( !prev.length ) x.reset();
				var n = x.nextNode;
				return n ? [ n ] : [];
			}.lazy();
		};
		this.lazyLists = false;
		this.list = function(list) {
			return beyondXML.lazyLists ? Lazy.from(list) : Array.from(list);
		};
	}
};

function childNodes(n) {
	return beyondXML.list(n.childNodes);
}

_SP.parseFromString = function(doc) {
	if ( !doc )
		doc = beyondXML.createDocument();
	return beyondXML.parseFromString(doc, this) ? doc : null;
};
_SP.load = function(document) {
	if ( !doc )
		doc = beyondXML.createDocument();
	return beyondXML.load(doc, this) ? doc : null;
};

_SP.selectSingleNode = function(node) {
	return node.selectSingleNode(this);
};
_SP.selectNodes = function(node) {
	return beyondXML.list(node.selectNodes(this));
};
_SP.nodeFromID = function(node) {
	return node.ownerDocument.nodeFromID(this);
};
_SP.getElementsByTagName = function(node) {
	return beyondXML.list(node.getElementsByTagName(this));
};

_SP.node = function(node) {
	return node.getElementsByTagName(this).nextNode();
};
_SP.value = function(node) {
	return this.node(node).nodeTypedValue;
};