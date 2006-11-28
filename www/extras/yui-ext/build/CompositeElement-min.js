/*
 * YUI Extensions 0.33 RC2
 * Copyright(c) 2006, Jack Slocum.
 */


YAHOO.ext.CompositeElement=function(els){this.elements=[];this.addElements(els);};YAHOO.ext.CompositeElement.prototype={isComposite:true,addElements:function(els){if(!els)return this;var yels=this.elements;var index=yels.length-1;for(var i=0,len=els.length;i<len;i++){yels[++index]=getEl(els[i],true);}
return this;},invoke:function(fn,args){var els=this.elements;for(var i=0,len=els.length;i<len;i++){YAHOO.ext.Element.prototype[fn].apply(els[i],args);}
return this;},add:function(els){if(typeof els=='string'){this.addElements(YAHOO.ext.Element.selectorFunction(string));}else if(els instanceof Array){this.addElements(els);}else{this.addElements([els]);}
return this;},each:function(fn,scope){var els=this.elements;for(var i=0,len=els.length;i<len;i++){fn.call(scope||els[i],els[i],this,i);}
return this;}};YAHOO.ext.CompositeElementLite=function(els){YAHOO.ext.CompositeElementLite.superclass.constructor.call(this,els);this.el=YAHOO.ext.Element.get(this.elements[0],true);};YAHOO.extendX(YAHOO.ext.CompositeElementLite,YAHOO.ext.CompositeElement,{addElements:function(els){if(els){this.elements=this.elements.concat(els);}
return this;},invoke:function(fn,args){var els=this.elements;var el=this.el;for(var i=0,len=els.length;i<len;i++){el.dom=els[i];YAHOO.ext.Element.prototype[fn].apply(el,args);}
return this;}});YAHOO.ext.CompositeElement.createCall=function(proto,fnName){if(!proto[fnName]){proto[fnName]=function(){return this.invoke(fnName,arguments);};}};for(var fnName in YAHOO.ext.Element.prototype){if(typeof YAHOO.ext.Element.prototype[fnName]=='function'){YAHOO.ext.CompositeElement.createCall(YAHOO.ext.CompositeElement.prototype,fnName);}}
if(typeof cssQuery=='function'){YAHOO.ext.Element.selectorFunction=cssQuery;}else if(typeof document.getElementsBySelector=='function'){YAHOO.ext.Element.selectorFunction=document.getElementsBySelector.createDelegate(document);}
YAHOO.ext.Element.select=function(selector,unique){var els;if(typeof selector=='string'){els=YAHOO.ext.Element.selectorFunction(selector);}else if(selector instanceof Array){els=selector;}else{throw'Invalid selector';}
if(unique===true){return new YAHOO.ext.CompositeElement(els);}else{return new YAHOO.ext.CompositeElementLite(els);}};var getEls=YAHOO.ext.Element.select;