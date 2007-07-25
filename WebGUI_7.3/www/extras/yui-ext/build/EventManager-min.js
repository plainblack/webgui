/*
 * YUI Extensions 0.33 RC2
 * Copyright(c) 2006, Jack Slocum.
 */


YAHOO.ext.EventManager=new function(){var docReadyEvent;var docReadyProcId;var docReadyState=false;this.ieDeferSrc=null;var resizeEvent;var resizeTask;var fireDocReady=function(){if(!docReadyState){docReadyState=true;if(docReadyProcId){clearInterval(docReadyProcId);}
if(docReadyEvent){docReadyEvent.fire();}}};var initDocReady=function(){docReadyEvent=new YAHOO.util.CustomEvent('documentready');if(document.addEventListener){YAHOO.util.Event.on(document,"DOMContentLoaded",fireDocReady);}else if(YAHOO.ext.util.Browser.isIE){document.write('<s'+'cript id="ie-deferred-loader" defer="defer" src="'+
(YAHOO.ext.EventManager.ieDeferSrc||YAHOO.ext.SSL_SECURE_URL)+'"></s'+'cript>');YAHOO.util.Event.on('ie-deferred-loader','readystatechange',function(){if(this.readyState=='complete'){fireDocReady();}});}else if(YAHOO.ext.util.Browser.isSafari){docReadyProcId=setInterval(function(){var rs=document.readyState;if(rs=='loaded'||rs=='complete'){fireDocReady();}},10);}
YAHOO.util.Event.on(window,'load',fireDocReady);};this.wrap=function(fn,scope,override){var wrappedFn=function(e){YAHOO.ext.EventObject.setEvent(e);fn.call(override?scope||window:window,YAHOO.ext.EventObject,scope);};return wrappedFn;};this.addListener=function(element,eventName,fn,scope,override){var wrappedFn=this.wrap(fn,scope,override);YAHOO.util.Event.addListener(element,eventName,wrappedFn);return wrappedFn;};this.removeListener=function(element,eventName,wrappedFn){return YAHOO.util.Event.removeListener(element,eventName,wrappedFn);};this.on=this.addListener;this.onDocumentReady=function(fn,scope,override){if(!docReadyEvent){initDocReady();}
docReadyEvent.subscribe(fn,scope,override);}
this.onWindowResize=function(fn,scope,override){if(!resizeEvent){resizeEvent=new YAHOO.util.CustomEvent('windowresize');resizeTask=new YAHOO.ext.util.DelayedTask(function(){resizeEvent.fireDirect(YAHOO.util.Dom.getViewportWidth(),YAHOO.util.Dom.getViewportHeight());});YAHOO.util.Event.on(window,'resize',function(){resizeTask.delay(50);});}
resizeEvent.subscribe(fn,scope,override);},this.removeResizeListener=function(fn,scope){if(resizeEvent){resizeEvent.unsubscribe(fn,scope);}}};YAHOO.ext.EventObject=new function(){this.browserEvent=null;this.button=-1;this.shiftKey=false;this.ctrlKey=false;this.altKey=false;this.BACKSPACE=8;this.TAB=9;this.RETURN=13;this.ESC=27;this.SPACE=32;this.PAGEUP=33;this.PAGEDOWN=34;this.END=35;this.HOME=36;this.LEFT=37;this.UP=38;this.RIGHT=39;this.DOWN=40;this.DELETE=46;this.F5=116;this.setEvent=function(e){this.browserEvent=e;if(e){this.button=e.button;this.shiftKey=e.shiftKey;this.ctrlKey=e.ctrlKey;this.altKey=e.altKey;}else{this.button=-1;this.shiftKey=false;this.ctrlKey=false;this.altKey=false;}};this.stopEvent=function(){if(this.browserEvent){YAHOO.util.Event.stopEvent(this.browserEvent);}};this.preventDefault=function(){if(this.browserEvent){YAHOO.util.Event.preventDefault(this.browserEvent);}};this.isNavKeyPress=function(){return(this.browserEvent.keyCode&&this.browserEvent.keyCode>=33&&this.browserEvent.keyCode<=40);};this.stopPropagation=function(){if(this.browserEvent){YAHOO.util.Event.stopPropagation(this.browserEvent);}};this.getCharCode=function(){if(this.browserEvent){return YAHOO.util.Event.getCharCode(this.browserEvent);}
return null;};this.getKey=function(){if(this.browserEvent){return this.browserEvent.charCode||this.browserEvent.keyCode;}
return null;};this.getPageX=function(){if(this.browserEvent){return YAHOO.util.Event.getPageX(this.browserEvent);}
return null;};this.getPageY=function(){if(this.browserEvent){return YAHOO.util.Event.getPageY(this.browserEvent);}
return null;};this.getTime=function(){if(this.browserEvent){return YAHOO.util.Event.getTime(this.browserEvent);}
return null;};this.getXY=function(){if(this.browserEvent){return YAHOO.util.Event.getXY(this.browserEvent);}
return[];};this.getTarget=function(){if(this.browserEvent){return YAHOO.util.Event.getTarget(this.browserEvent);}
return null;};this.findTarget=function(className,tagName){if(tagName)tagName=tagName.toLowerCase();if(this.browserEvent){function isMatch(el){if(!el){return false;}
if(className&&!YAHOO.util.Dom.hasClass(el,className)){return false;}
if(tagName&&el.tagName.toLowerCase()!=tagName){return false;}
return true;};var t=this.getTarget();if(!t||isMatch(t)){return t;}
var p=t.parentNode;var b=document.body;while(p&&p!=b){if(isMatch(p)){return p;}
p=p.parentNode;}}
return null;};this.getRelatedTarget=function(){if(this.browserEvent){return YAHOO.util.Event.getRelatedTarget(this.browserEvent);}
return null;};this.getWheelDelta=function(){var e=this.browserEvent;var delta=0;if(e.wheelDelta){delta=e.wheelDelta/120;if(window.opera)delta=-delta;}else if(e.detail){delta=-e.detail/3;}
return delta;};this.hasModifier=function(){return this.ctrlKey||this.altKey||this.shiftKey;};}();