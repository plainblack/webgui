/*
 * YUI Extensions 0.33 RC2
 * Copyright(c) 2006, Jack Slocum.
 */


YAHOO.ext.util.CSS=new function(){var rules=null;var toCamel=function(property){var convert=function(prop){var test=/(-[a-z])/i.exec(prop);return prop.replace(RegExp.$1,RegExp.$1.substr(1).toUpperCase());};while(property.indexOf('-')>-1){property=convert(property);}
return property;};this.getRules=function(refreshCache){if(rules==null||refreshCache){rules={};var ds=document.styleSheets;for(var i=0,len=ds.length;i<len;i++){try{var ss=ds[i];var ssRules=ss.cssRules||ss.rules;for(var j=ssRules.length-1;j>=0;--j){rules[ssRules[j].selectorText]=ssRules[j];}}catch(e){}}}
return rules;};this.getRule=function(selector,refreshCache){var rs=this.getRules(refreshCache);if(!(selector instanceof Array)){return rs[selector];}
for(var i=0;i<selector.length;i++){if(rs[selector[i]]){return rs[selector[i]];}}
return null;};this.updateRule=function(selector,property,value){if(!(selector instanceof Array)){var rule=this.getRule(selector);if(rule){rule.style[toCamel(property)]=value;return true;}}else{for(var i=0;i<selector.length;i++){if(this.updateRule(selector[i],property,value)){return true;}}}
return false;};this.apply=function(el,selector){if(!(selector instanceof Array)){var rule=this.getRule(selector);if(rule){var s=rule.style;for(var key in s){if(typeof s[key]!='function'){if(s[key]&&String(s[key]).indexOf(':')<0&&s[key]!='false'){try{el.style[key]=s[key];}catch(e){}}}}
return true;}}else{for(var i=0;i<selector.length;i++){if(this.apply(el,selector[i])){return true;}}}
return false;};this.applyFirst=function(el,id,selector){var selectors=['#'+id+' '+selector,selector];return this.apply(el,selectors);};this.revert=function(el,selector){if(!(selector instanceof Array)){var rule=this.getRule(selector);if(rule){for(key in rule.style){if(rule.style[key]&&String(rule.style[key]).indexOf(':')<0&&rule.style[key]!='false'){try{el.style[key]='';}catch(e){}}}
return true;}}else{for(var i=0;i<selector.length;i++){if(this.revert(el,selector[i])){return true;}}}
return false;};this.revertFirst=function(el,id,selector){var selectors=['#'+id+' '+selector,selector];return this.revert(el,selectors);};}();