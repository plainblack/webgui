/**
 * util.js 
 * by Garrett Smith 
 * Provides functionality for working nodeLists.
 */
Browser = {
	isSupported : function(){
			return (Boolean(document.getElementsByTagName)
						&& Boolean(document.getElementById));
		},
	id : new function() {

			var ua= navigator.userAgent;
			var OMNI = ua.indexOf("Omni") > 0;

			this.OP5 = ua.indexOf("Opera 5") >= 0 || ua.indexOf("Opera 6") >= 0;
			this.OP7 = ua.indexOf("Opera 7") >= 0;
			this.MAC = ua.indexOf("Mac") > 0;

			if(!this.OP5 && !OMNI){
				this.IE5 = ua.indexOf("MSIE 5") > 0;
				this.IE5_0 = ua.indexOf("MSIE 5.0") > 0;
				this.NS6 = ua.indexOf("Gecko") > 0;
				this.MOZ = this.NS6 && ua.indexOf("Netscape") == -1;
				this.MAC_IE5 = this.MAC && this.IE5;
				this.IE6 = ua.indexOf("MSIE 6") > 0;
				this.KONQUEROR = ua.indexOf("Konqueror/") > 0;
			}
		}		
};
var px = "px";
TokenizedExps = {};
function getTokenizedExp(token){
	var x = TokenizedExps[token];
	if(!x)
		x = TokenizedExps[token] =  new RegExp("\\b"+token+"\\b");
	return x;
}

function hasToken(s, token){
	return getTokenizedExp(token).test(s);
};
	
/** returns an array of all childNodes
 *	who have a className that matches the className
 *	parameter.
 *
 *	Nested elements are not returned, only
 *	direct descendants (i.e. childNodes).
 */
function getChildNodesWithClass(parent, klass){
		
	var collection = parent.childNodes;
	var returnedCollection = [];
	var exp = getTokenizedExp(klass);

	for(var i = 0, counter = 0; i < collection.length; i++)
		if(exp.test(collection[i].className))
			returnedCollection[counter++] = collection[i];

	return returnedCollection;
}

/** Obtains a NodeList of all descendant elements
 *	who have a className that matches the className
 *	parameter. This method differs from getChildNodesWithClass
 *	because it returns ALL descendants (deep).
 */	
function getElementsWithClass(parent, tagName, klass){
	var returnedCollection = [];
	
	var exp = getTokenizedExp(klass);
	var collection = (tagName == "*" && parent.all) ?
		parent.all : parent.getElementsByTagName(tagName);
	
	for(var i = 0, counter = 0; i < collection.length; i++){
		
		if(exp.test(collection[i].className))
			returnedCollection[counter++] = collection[i];
	}
	return returnedCollection;
}

/** Returns an Array of all descendant elements
 *  where each element has a className that matches 
 *  any of the classNames in classList.
 *
 *  This method is like getElementsWithClass except it accepts 
 *  an Array of classes to search for.
 */	

function get_elements_with_class_from_classList(el, tagName, classList){

    var returnedCollection = new Array(0);
    
    var collection = (tagName == "*" && el.all) ?
    	el.all : el.getElementsByTagName(tagName);
    var exps = [];
	for(var i = 0; i < classList.length; i++)
		exps[i] = getTokenizedExp(classList[i]);
	for(var j = 0, coLen = collection.length; j < coLen; j++){
		kloop: for(var k = 0; k < classList.length; k++){
			if(exps[k].test(collection[j].className)){
				returnedCollection[returnedCollection.length] = collection[j];
				break kloop;
			}
		}
	}
    return returnedCollection;
}

function findAncestorWithClass(el, klass) {
	
	if(el == null)
		return null;
	var exp = getTokenizedExp(klass);
	for(var parent = el.parentNode;parent != null;){
	
		if( exp.test(parent.className) )
			return parent;
			
		parent = parent.parentNode;
	}
	return null;
}


function getDescendantById(parent, id){
	var childNodes = parent.all ? parent.all : parent.getElementsByTagName("*");
	for(var i = 0, len = childNodes.length; i < len; i++)
		if(childNodes[i].id == id)
			return childNodes[i];
	return null;
}


function removeClass(el, klass){
	el.className = el.className.replace(getTokenizedExp(klass),"").normalize();
}

function repaintFix(el){
	el.style.visibility = 'hidden';
	el.style.visibility = 'visible';
}
var trimExp = /^\s+|\s+$/g;
String.prototype.trim = function(){
		return this.replace(trimExp, "");
};
var wsMultExp = /\s\s+/g;
String.prototype.normalize = function(){
		return this.trim().replace(wsMultExp, " ");
};
if(!Array.prototype.unshift)
	Array.prototype.unshift = function() {
        this.reverse();
        for(var i=arguments.length-1; i > -1; i--)
            this[this.length] = arguments[i];
        this.reverse();
        return this.length;
};