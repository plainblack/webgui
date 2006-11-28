/*
 * YUI Extensions 0.33 RC2
 * Copyright(c) 2006, Jack Slocum.
 */


YAHOO.ext.grid.EditorGrid=function(container,dataModel,colModel){YAHOO.ext.grid.EditorGrid.superclass.constructor.call(this,container,dataModel,colModel,new YAHOO.ext.grid.EditorSelectionModel());this.container.addClass('yeditgrid');};YAHOO.extendX(YAHOO.ext.grid.EditorGrid,YAHOO.ext.grid.Grid);