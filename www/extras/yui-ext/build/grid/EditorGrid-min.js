/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */


YAHOO.ext.grid.EditorGrid=function(container,dataModel,colModel){YAHOO.ext.grid.EditorGrid.superclass.constructor.call(this,container,dataModel,colModel,new YAHOO.ext.grid.EditorSelectionModel());this.container.addClass('yeditgrid');};YAHOO.extendX(YAHOO.ext.grid.EditorGrid,YAHOO.ext.grid.Grid);