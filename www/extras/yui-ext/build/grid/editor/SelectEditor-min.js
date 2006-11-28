/*
 * YUI Extensions 0.33 RC2
 * Copyright(c) 2006, Jack Slocum.
 */


YAHOO.ext.grid.SelectEditor=function(element){element.hideFocus=true;YAHOO.ext.grid.SelectEditor.superclass.constructor.call(this,element);this.element.swallowEvent('click');};YAHOO.extendX(YAHOO.ext.grid.SelectEditor,YAHOO.ext.grid.CellEditor);YAHOO.ext.grid.SelectEditor.prototype.fitToCell=function(box){if(YAHOO.ext.util.Browser.isGecko){box.height-=3;}
this.element.setBox(box,true);};