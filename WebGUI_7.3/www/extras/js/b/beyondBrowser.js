/*
   beyondBrowser.js
   by Dan Shappir and Sjoerd Visscher
   For more information see http://w3future.com/html/beyondJS
*/
if ( typeof(beyondVer) !== "number" || beyondVer < 0.98 )
	alert("beyondBrowser requires beyond JS library ver 0.98 or higher");
var beyondBrowserVer = 0.96;

Array.as = function(c) {
	if ( typeof(c.length) != "number" )
		return [].append(c);
	if ( !c.foreach )
		c.foreach = _AP.foreach;
	if ( !c.head )
		c.head = _AP.head;
	if ( !c.tail )
		c.tail = _AP.tail;
	if ( !c.itemAt )
		c.tail = _AP.itemAt;
	if ( !c.isEmpty )
		c.isEmpty = _AP.isEmpty;
	if ( !c.slice )
		c.slice = function(start, end) {
			var a = Array.from(this);
			return isDefined(end) ? a.slice(start, end) : a.slice(start);
		};
	iteratable(c);
	return c;
};

_SP.element = function() {
	return document.getElementById(this);
};
_SP.children = function(index, subIndex) {
	var e = this.element();
	var c = isDefined(subIndex) ? e.children(index, subIndex) :
		isDefined(index) ? e.children(index) : e.children;
	return isDefined(c.length) ? Array.as(c) : c;
};
_SP.foreach = function(f, r) {
	return ( isUndefined(document.all) ? [ this.element() ] : Array.as(document.all[this]) ).foreach(f, r);
};
iteratable("");
_SP.setTo = function(html) {
	this.foreach(function(e) { e.innerHTML = html; });
	return this;
};
_SP.into = function(id) {
	id.toString().setTo(this);
	return this;
};
_SP.add = function(where, html) {
	this.foreach(function(e) { e.insertAdjacentHTML(where, html); });
	return this;
};
_SP.insert = _SP.add.curry("afterBegin");
_SP.append = _SP.add.curry("beforeEnd");
_SP.showHide = function(show) {
	var display = show ? "" : "none";
	this.foreach(function(e) { e.style.display = display; });
	return this;
};
_SP.show = _SP.showHide.curry(true);
_SP.hide = _SP.showHide.curry(false);
_SP.toggleShow = function() {
	this.foreach(function(e) { e.style.display = e.style.display.length ? "" : "none"; });
	return this;
};
_SP.moveTo = function(clientX, clientY) {
	this.foreach(function(e) { e.style.left = clientX + "px"; e.style.top = clientY + "px"; });
	return this;
};
_SP.w = function(text) {
	return "<" + this + ">" + text + "</" + this.replace(_SP.w.re, "") + ">";
};
_SP.w.re = /\s.*/;
_SP.tag = function(tag) {
	return tag.toString().w(this);
};
_SP.write = function(s) {
	return document.write(this.w(s));
};

if ( isUndefined(document.getElementById) )
	document.getElementById = function(id) {
		return Array.as(document.all[id])[0];
	};
if ( isUndefined(document.getElementsByTagName) )
	document.getElementsByTagName = function(tagName) {
		tagName = tagName.toUpperCase()
		return Array.as(document.all).filter(function(e) { return e.tagName.toUpperCase() == tagName; });
	};
