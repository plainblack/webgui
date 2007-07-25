/*
 * YUI Extensions 0.33 RC2
 * Copyright(c) 2006, Jack Slocum.
 */


YAHOO.ext.grid.JSONDataModel=function(schema){YAHOO.ext.grid.JSONDataModel.superclass.constructor.call(this,YAHOO.ext.grid.LoadableDataModel.JSON);this.schema=schema;};YAHOO.extendX(YAHOO.ext.grid.JSONDataModel,YAHOO.ext.grid.LoadableDataModel,{loadData:function(data,callback,keepExisting){var idField=this.schema.id;var fields=this.schema.fields;if(this.schema.totalProperty){var v=parseInt(eval('data.'+this.schema.totalProperty),10);if(!isNaN(v)){this.totalCount=v;}}
var rowData=[];try{var root=eval('data.'+this.schema.root);for(var i=0;i<root.length;i++){var node=root[i];var colData=[];colData.node=node;colData.id=(typeof node[idField]!='undefined'&&node[idField]!==''?node[idField]:String(i));for(var j=0;j<fields.length;j++){var val=node[fields[j]];if(typeof val=='undefined'){val='';}
if(this.preprocessors[j]){val=this.preprocessors[j](val);}
colData.push(val);}
rowData.push(colData);}
if(keepExisting!==true){this.removeAll();}
this.addRows(rowData);if(typeof callback=='function'){callback(this,true);}
this.fireLoadEvent();}catch(e){this.fireLoadException(e,null);if(typeof callback=='function'){callback(this,false);}}},getRowId:function(rowIndex){return this.data[rowIndex].id;}});