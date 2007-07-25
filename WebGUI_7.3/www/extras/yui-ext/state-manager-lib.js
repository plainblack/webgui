/*
 * YUI Extensions 0.33 RC2
 * Copyright(c) 2006, Jack Slocum.
 */


YAHOO.namespace('ext.state');YAHOO.ext.state.Provider=function(){YAHOO.ext.state.Provider.superclass.constructor.call(this);this.events={'statechange':new YAHOO.util.CustomEvent('statechange')};this.state={};};YAHOO.extendX(YAHOO.ext.state.Provider,YAHOO.ext.util.Observable,{get:function(name,defaultValue){return typeof this.state[name]=='undefined'?defaultValue:this.state[name];},clear:function(name){delete this.state[name];this.fireEvent('statechange',this,name,null);},set:function(name,value){this.state[name]=value;this.fireEvent('statechange',this,name,value);},decodeValue:function(cookie){var re=/^(a|n|d|b|s|o)\:(.*)$/;var matches=re.exec(unescape(cookie));if(!matches||!matches[1])return;var type=matches[1];var v=matches[2];switch(type){case'n':return parseFloat(v);case'd':return new Date(Date.parse(v));case'b':return(v=='1');case'a':var all=[];var values=v.split('^');for(var i=0,len=values.length;i<len;i++){all.push(this.decodeValue(values[i]))}
return all;case'o':var all={};var values=v.split('^');for(var i=0,len=values.length;i<len;i++){var kv=values[i].split('=');all[kv[0]]=this.decodeValue(kv[1]);}
return all;default:return v;}},encodeValue:function(v){var enc;if(typeof v=='number'){enc='n:'+v;}else if(typeof v=='boolean'){enc='b:'+(v?'1':'0');}else if(v instanceof Date){enc='d:'+v.toGMTString();}else if(v instanceof Array){var flat='';for(var i=0,len=v.length;i<len;i++){flat+=this.encodeValue(v[i]);if(i!=len-1)flat+='^';}
enc='a:'+flat;}else if(typeof v=='object'){var flat='';for(var key in v){if(typeof v[key]!='function'){flat+=key+'='+this.encodeValue(v[key])+'^';}}
enc='o:'+flat.substring(0,flat.length-1);}else{enc='s:'+v;}
return escape(enc);}});YAHOO.ext.state.Manager=new function(){var provider=new YAHOO.ext.state.Provider();return{setProvider:function(stateProvider){provider=stateProvider;},get:function(key,defaultValue){return provider.get(key,defaultValue);},set:function(key,value){provider.set(key,value);},clear:function(key){provider.clear(key);},getProvider:function(){return provider;}};}();YAHOO.ext.state.CookieProvider=function(config){YAHOO.ext.state.CookieProvider.superclass.constructor.call(this);this.path='/';this.expires=new Date(new Date().getTime()+(1000*60*60*24*7));this.domain=null;this.secure=false;YAHOO.ext.util.Config.apply(this,config);this.state=this.readCookies();};YAHOO.extendX(YAHOO.ext.state.CookieProvider,YAHOO.ext.state.Provider,{set:function(name,value){if(typeof value=='undefined'||value===null){this.clear(name);return;}
this.setCookie(name,value);YAHOO.ext.state.CookieProvider.superclass.set.call(this,name,value);},clear:function(name){this.clearCookie(name);YAHOO.ext.state.CookieProvider.superclass.clear.call(this,name);},readCookies:function(){var cookies={};var c=document.cookie+';';var re=/\s?(.*?)=(.*?);/g;var matches;while((matches=re.exec(c))!=null){var name=matches[1];var value=matches[2];if(name&&name.substring(0,3)=='ys-'){cookies[name.substr(3)]=this.decodeValue(value);}}
return cookies;},setCookie:function(name,value){document.cookie="ys-"+name+"="+this.encodeValue(value)+
((this.expires==null)?"":("; expires="+this.expires.toGMTString()))+
((this.path==null)?"":("; path="+this.path))+
((this.domain==null)?"":("; domain="+this.domain))+
((this.secure==true)?"; secure":"");},clearCookie:function(name){document.cookie="ys-"+name+"=null; expires=Thu, 01-Jan-70 00:00:01 GMT"+
((this.path==null)?"":("; path="+this.path))+
((this.domain==null)?"":("; domain="+this.domain))+
((this.secure==true)?"; secure":"");}});
