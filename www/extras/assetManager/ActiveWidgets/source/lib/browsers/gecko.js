/*****************************************************************

	ActiveWidgets Grid 1.0.0 (Free Edition).
	Copyright (C) 2004 ActiveWidgets Ltd. All Rights Reserved. 
	More information at http://www.activewidgets.com/

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*****************************************************************/

(function(){

	if (!window.HTMLElement) {return}

	var element = HTMLElement.prototype;

//	------------------------------------------------------------

	var capture = ["click",	 "mouseup",	"mousemove", "mouseover", "mouseout" ];

	element.setCapture = function(){
		var self = this;
		var flag = false;
		this._capture = function(event){
			if (flag) {return}
			flag = true;
			self.dispatchEvent(event);
			flag = false;
		};
		for (var i=0; i<capture.length; i++) {
			window.addEventListener(capture[i], this._capture, true);
			window.captureEvents(Event[capture[i]]);
		}
	};

	element.releaseCapture = function(){
		for (var i=0; i<capture.length; i++) {
			window.releaseEvents(Event[capture[i]]);
			window.removeEventListener(capture[i], this._capture, true);
		}
		this._capture = null;
	};

//	------------------------------------------------------------

	element.attachEvent = function (name, handler) {
		if (typeof handler != "function") {return}
		var nsName = name.replace(/^on/, "");
		var nsHandler = function(event){
			window.event = event;
			handler();
			window.event = null;
		};
		handler[name] = nsHandler;
		this.addEventListener(nsName, nsHandler, false);
	};

	element.detachEvent = function (name, handler) {
		if (typeof handler != "function") {return}
		var nsName = name.replace(/^on/, "");
		this.removeEventListener(nsName, handler[name], false);
		handler[name] = null;
	};

//	------------------------------------------------------------

	var getClientWidth = function(){
		return this.offsetWidth - 20;
	};

	var getClientHeight = function(){
		return this.offsetHeight - 20;
	};

	element.__defineGetter__("clientWidth", getClientWidth);
	element.__defineGetter__("clientHeight", getClientHeight);

//	------------------------------------------------------------

	var getRuntimeStyle = function(){
		return this.style;
	};

	element.__defineGetter__("runtimeStyle", getRuntimeStyle);

//	------------------------------------------------------------

	var cs = ComputedCSSStyleDeclaration.prototype;

	cs.__defineGetter__("paddingTop", function(){return this.getPropertyValue("padding-top")});

	var getCurrentStyle = function(){
		return document.defaultView.getComputedStyle(this, "");
	};

	element.__defineGetter__("currentStyle", getCurrentStyle);

//	------------------------------------------------------------

	var setOuterHtml = function(s){
	   var range = this.ownerDocument.createRange();
	   range.setStartBefore(this);
	   var fragment = range.createContextualFragment(s);
	   this.parentNode.replaceChild(fragment, this);
	};

	element.__defineSetter__("outerHTML", setOuterHtml);

})();

//	------------------------------------------------------------

(function(){

	if (!window.Event) {return}

	var event = Event.prototype;

	if (!event) {return}

//	------------------------------------------------------------

	var getSrcElement = function(){
		return (this.target.nodeType==3) ? this.target.parentNode : this.target;
	};

	event.__defineGetter__("srcElement", getSrcElement);

//	------------------------------------------------------------

	var setReturnValue = function(value){
		if (!value) {this.preventDefault()}
	};

	event.__defineSetter__("returnValue", setReturnValue);

})();

//	------------------------------------------------------------

(function(){

	if (!window.CSSStyleSheet){return}

	var stylesheet = CSSStyleSheet.prototype;

	stylesheet.addRule = function(selector, rule){
		this.insertRule(selector + "{" + rule + "}", this.cssRules.length);
	};

	stylesheet.__defineGetter__("rules", function(){return this.cssRules});

})();

//	------------------------------------------------------------

(function(){

	if (!window.XMLHttpRequest) {return}

	var ActiveXObject = function(type) {
		ActiveXObject[type](this);
	};

	ActiveXObject["MSXML2.DOMDocument"] = function(obj){
		obj.setProperty = function(){};
		obj.load = function(url){
			var xml = this;
			var async = this.async ? true : false;
			var request = new XMLHttpRequest();
			request.open("GET", url, async);
			request.overrideMimeType("text/xml");

			if (async) {
				request.onreadystatechange = function(){
					xml.readyState = request.readyState;
					if (request.readyState == 4 ) {
						xml.documentElement = request.responseXML.documentElement;
						xml.firstChild = xml.documentElement; 
						request.onreadystatechange = null;
					}
					if (xml.onreadystatechange) {xml.onreadystatechange()}
				}
			}

			this.parseError = {errorCode: 0, reason: "Emulation"};

			request.send(null);
			this.readyState = request.readyState;
			if (request.responseXML && !async) {
				this.documentElement = request.responseXML.documentElement;
				this.firstChild = this.documentElement; 
			}
		}
	};

	ActiveXObject["MSXML2.XMLHTTP"] = function(obj){

		obj.open = function(method, url, async){
			this.request = new XMLHttpRequest();
			this.request.open(method, url, async);
		};

		obj.send = function(data){
			this.request.send(data);
		};

		obj.setRequestHeader = function(name, value){
			this.request.setRequestHeader(name, value);
		};

		obj.__defineGetter__("readyState", function(){return this.request.readyState});
		obj.__defineGetter__("responseXML", function(){return this.request.responseXML});
		obj.__defineGetter__("responseText", function(){return this.request.responseText});
	};

//	window.ActiveXObject = ActiveXObject;
})();

//	------------------------------------------------------------

(function(){

	if (!window.XPathEvaluator) {return}

	var xpath = new XPathEvaluator();

	var element = Element.prototype;
	var attribute = Attr.prototype;
	var doc = Document.prototype;

	doc.loadXML = function(text){
		var parser = new DOMParser;
		var newDoc = parser.parseFromString(text, "text/xml");
		this.replaceChild(newDoc.documentElement, this.documentElement);
	};

	doc.setProperty = function(name, value){
		if(name=="SelectionNamespaces"){
			namespaces = {};
			var a = value.split(" xmlns:");
			for (var i=1;i<a.length;i++){
				var s = a[i].split("=");
				namespaces[s[0]] = s[1].replace(/\"/g, "");
			}
			this._ns = {
				lookupNamespaceURI : function(prefix){return namespaces[prefix]}
			}
		}
	};

	doc._ns = {
		lookupNamespaceURI : function(){return null}
	};

	doc.selectNodes = function (path) {
	   var result = xpath.evaluate(path, this, this._ns, 7, null);
	   var i, nodes = [];
	   for (i=0; i<result.snapshotLength; i++) {nodes[i]=result.snapshotItem(i)}
	   return nodes;
	};

	doc.selectSingleNode = function (path) {
	   return xpath.evaluate(path, this, this._ns, 9, null).singleNodeValue;
	};

	element.selectNodes = function (path) {
	   var result = xpath.evaluate(path, this, this.ownerDocument._ns, 7, null);
	   var i, nodes = [];
	   for (i=0; i<result.snapshotLength; i++) {nodes[i]=result.snapshotItem(i)}
	   return nodes;
	};

	element.selectSingleNode = function (path) {
	   return xpath.evaluate(path, this, this.ownerDocument._ns, 9, null).singleNodeValue;
	};

	element.__defineGetter__("text", function(){return this.firstChild.nodeValue});
	attribute.__defineGetter__("text", function(){return this.nodeValue});

})();

