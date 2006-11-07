/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */


YAHOO.ext.grid.XMLDataModel=function(schema,xml){YAHOO.ext.grid.XMLDataModel.superclass.constructor.call(this,YAHOO.ext.grid.LoadableDataModel.XML);this.schema=schema;this.xml=xml;if(xml){this.loadData(xml);}};YAHOO.extendX(YAHOO.ext.grid.XMLDataModel,YAHOO.ext.grid.LoadableDataModel);YAHOO.ext.grid.XMLDataModel.prototype.getDocument=function(){return this.xml;};YAHOO.ext.grid.XMLDataModel.prototype.loadData=function(doc,callback,keepExisting,insertIndex){this.xml=doc;var idField=this.schema.id;var fields=this.schema.fields;if(this.schema.totalTag){this.totalCount=null;var totalNode=doc.getElementsByTagName(this.schema.totalTag);if(totalNode&&totalNode.item(0)&&totalNode.item(0).firstChild){var v=parseInt(totalNode.item(0).firstChild.nodeValue,10);if(!isNaN(v)){this.totalCount=v;}}}
var rowData=[];var nodes=doc.getElementsByTagName(this.schema.tagName);if(nodes&&nodes.length>0){for(var i=0;i<nodes.length;i++){var node=nodes.item(i);var colData=[];colData.node=node;colData.id=this.getNamedValue(node,idField,String(i));for(var j=0;j<fields.length;j++){var val=this.getNamedValue(node,fields[j],"");if(this.preprocessors[j]){val=this.preprocessors[j](val);}
colData.push(val);}
rowData.push(colData);}}
if(keepExisting!==true){YAHOO.ext.grid.XMLDataModel.superclass.removeAll.call(this);}
if(typeof insertIndex!='number'){insertIndex=this.getRowCount();}
YAHOO.ext.grid.XMLDataModel.superclass.insertRows.call(this,insertIndex,rowData);if(typeof callback=='function'){callback(this,true);}
this.fireLoadEvent();};YAHOO.ext.grid.XMLDataModel.prototype.addRow=function(id,cellValues){var newIndex=this.getRowCount();var node=this.createNode(this.xml,id,cellValues);cellValues.id=id||newIndex;cellValues.node=node;YAHOO.ext.grid.XMLDataModel.superclass.addRow.call(this,cellValues);return newIndex;};YAHOO.ext.grid.XMLDataModel.prototype.insertRow=function(index,id,cellValues){var node=this.createNode(this.xml,id,cellValues);cellValues.id=id||this.getRowCount();cellValues.node=node;YAHOO.ext.grid.XMLDataModel.superclass.insertRow.call(this,index,cellValues);return index;};YAHOO.ext.grid.XMLDataModel.prototype.removeRow=function(index){var node=this.data[index].node;node.parentNode.removeChild(node);YAHOO.ext.grid.XMLDataModel.superclass.removeRow.call(this,index,index);};YAHOO.ext.grid.XMLDataModel.prototype.getNode=function(rowIndex){return this.data[rowIndex].node;};YAHOO.ext.grid.XMLDataModel.prototype.createNode=function(xmlDoc,id,colData){var template=this.data[0].node;var newNode=template.cloneNode(true);var fields=this.schema.fields;for(var i=0;i<fields.length;i++){var nodeValue=colData[i];if(this.postprocessors[i]){nodeValue=this.postprocessors[i](nodeValue);}
this.setNamedValue(newNode,fields[i],nodeValue);}
if(id){this.setNamedValue(newNode,this.schema.idField,id);}
template.parentNode.appendChild(newNode);return newNode;};YAHOO.ext.grid.XMLDataModel.prototype.getNamedValue=function(node,name,defaultValue){if(!node||!name){return defaultValue;}
var nodeValue=defaultValue;var attrNode=node.attributes.getNamedItem(name);if(attrNode){nodeValue=attrNode.value;}else{var childNode=node.getElementsByTagName(name);if(childNode&&childNode.item(0)&&childNode.item(0).firstChild){nodeValue=childNode.item(0).firstChild.nodeValue;}else{var index=name.indexOf(':');if(index>0){return this.getNamedValue(node,name.substr(index+1),defaultValue);}}}
return nodeValue;};YAHOO.ext.grid.XMLDataModel.prototype.setNamedValue=function(node,name,value){if(!node||!name){return;}
var attrNode=node.attributes.getNamedItem(name);if(attrNode){attrNode.value=value;return;}
var childNode=node.getElementsByTagName(name);if(childNode&&childNode.item(0)&&childNode.item(0).firstChild){childNode.item(0).firstChild.nodeValue=value;}else{var index=name.indexOf(':');if(index>0){this.setNamedValue(node,name.substr(index+1),value);}}};YAHOO.ext.grid.XMLDataModel.prototype.setValueAt=function(value,rowIndex,colIndex){var node=this.data[rowIndex].node;if(node){var nodeValue=value;if(this.postprocessors[colIndex]){nodeValue=this.postprocessors[colIndex](value);}
this.setNamedValue(node,this.schema.fields[colIndex],nodeValue);}
YAHOO.ext.grid.XMLDataModel.superclass.setValueAt.call(this,value,rowIndex,colIndex);};YAHOO.ext.grid.XMLDataModel.prototype.getRowId=function(rowIndex){return this.data[rowIndex].id;};