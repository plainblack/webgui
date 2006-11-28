/*
 * YUI Extensions 0.33 RC2
 * Copyright(c) 2006, Jack Slocum.
 */


YAHOO.ext.util.MixedCollection=function(allowFunctions){this.items=[];this.keys=[];this.events={'clear':new YAHOO.util.CustomEvent('clear'),'add':new YAHOO.util.CustomEvent('add'),'replace':new YAHOO.util.CustomEvent('replace'),'remove':new YAHOO.util.CustomEvent('remove')}
this.allowFunctions=allowFunctions===true;};YAHOO.extendX(YAHOO.ext.util.MixedCollection,YAHOO.ext.util.Observable,{allowFunctions:false,add:function(key,o){if(arguments.length==1){o=arguments[0];key=this.getKey(o);}
this.items.push(o);if(typeof key!='undefined'&&key!=null){this.items[key]=o;this.keys.push(key);}
this.fireEvent('add',this.items.length-1,o,key);return o;},getKey:function(o){return null;},replace:function(key,o){if(arguments.length==1){o=arguments[0];key=this.getKey(o);}
if(typeof this.items[key]=='undefined'){return this.add(key,o);}
var old=this.items[key];if(typeof key=='number'){this.items[key]=o;}else{var index=this.indexOfKey(key);this.items[index]=o;this.items[key]=o;}
this.fireEvent('replace',key,old,o);return o;},addAll:function(objs){if(arguments.length>1||objs instanceof Array){var args=arguments.length>1?arguments:objs;for(var i=0,len=args.length;i<len;i++){this.add(args[i]);}}else{for(var key in objs){if(this.allowFunctions||typeof objs[key]!='function'){this.add(objs[key],key);}}}},each:function(fn,scope){for(var i=0,len=this.items.length;i<len;i++){fn.call(scope||window,this.items[i]);}},eachKey:function(fn,scope){for(var i=0,len=this.keys.length;i<len;i++){fn.call(scope||window,this.keys[i],this.items[i]);}},find:function(fn,scope){for(var i=0,len=this.items.length;i<len;i++){if(fn.call(scope||window,this.items[i])){return this.items[i];}}
return null;},insert:function(index,key,o){if(arguments.length==2){o=arguments[1];key=this.getKey(o);}
if(index>=this.items.length){return this.add(o,key);}
this.items.splice(index,0,o);if(typeof key!='undefined'&&key!=null){this.items[key]=o;this.keys.splice(index,0,key);}
this.fireEvent('add',index,o,key);return o;},remove:function(o){var index=this.indexOf(o);this.items.splice(index,1);if(typeof this.keys[index]!='undefined'){var key=this.keys[index];this.keys.splice(index,1);delete this.items[key];}
this.fireEvent('remove',o);return o;},removeAt:function(index){this.items.splice(index,1);var key=this.keys[index];if(typeof key!='undefined'){this.keys.splice(index,1);delete this.items[key];}
this.fireEvent('remove',o,key);},removeKey:function(key){var o=this.items[key];var index=this.indexOf(o);this.items.splice(index,1);this.keys.splice(index,1);delete this.items[key];this.fireEvent('remove',o,key);},getCount:function(){return this.items.length;},indexOf:function(o){if(!this.items.indexOf){for(var i=0,len=this.items.length;i<len;i++){if(this.items[i]==o)return i;}
return-1;}else{return this.items.indexOf(o);}},indexOfKey:function(key){if(!this.keys.indexOf){for(var i=0,len=this.keys.length;i<len;i++){if(this.keys[i]==key)return i;}
return-1;}else{return this.keys.indexOf(key);}},item:function(key){return this.items[key];},contains:function(o){return this.indexOf(o)!=-1;},containsKey:function(key){return typeof this.items[key]!='undefined';},clear:function(o){this.items=[];this.keys=[];this.fireEvent('clear');},first:function(){return this.items[0];},last:function(){return this.items[this.items.length];}});YAHOO.ext.util.MixedCollection.prototype.get=YAHOO.ext.util.MixedCollection.prototype.item;