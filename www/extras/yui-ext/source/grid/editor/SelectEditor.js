/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */

YAHOO.ext.grid.SelectEditor = function(element){
    element.hideFocus = true;
    YAHOO.ext.grid.SelectEditor.superclass.constructor.call(this, element);
};
YAHOO.extendX(YAHOO.ext.grid.SelectEditor, YAHOO.ext.grid.CellEditor);

YAHOO.ext.grid.SelectEditor.prototype.fitToCell = function(box){
    if(YAHOO.ext.util.Browser.isGecko){
        box.height -= 3;
    }
    this.element.setBox(box, true);
};