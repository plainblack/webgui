/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */


YAHOO.ext.grid.AbstractColumnModel=function(){this.onWidthChange=new YAHOO.util.CustomEvent('widthChanged');this.onHeaderChange=new YAHOO.util.CustomEvent('headerChanged');this.onHiddenChange=new YAHOO.util.CustomEvent('hiddenChanged');};YAHOO.ext.grid.AbstractColumnModel.prototype={fireWidthChange:function(colIndex,newWidth){this.onWidthChange.fireDirect(this,colIndex,newWidth);},fireHeaderChange:function(colIndex,newHeader){this.onHeaderChange.fireDirect(this,colIndex,newHeader);},fireHiddenChange:function(colIndex,hidden){this.onHiddenChange.fireDirect(this,colIndex,hidden);},getColumnCount:function(){return 0;},isSortable:function(col){return false;},isHidden:function(col){return false;},getSortType:function(col){return YAHOO.ext.grid.DefaultColumnModel.sortTypes.none;},getRenderer:function(col){return YAHOO.ext.grid.DefaultColumnModel.defaultRenderer;},getColumnWidth:function(col){return 0;},getTotalWidth:function(){return 0;},getColumnHeader:function(col){return'';}};