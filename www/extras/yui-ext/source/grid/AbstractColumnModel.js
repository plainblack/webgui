/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */

/**
 * @class
 * This abstract class defines the ColumnModel interface and provides default implementations of the events required by the Grid. 
 * @constructor
*/
YAHOO.ext.grid.AbstractColumnModel = function(){
	/** Fires when a column width is changed - fireDirect sig: (this, columnIndex, newWidth)
     * @type YAHOO.util.CustomEvent 
     * */
    this.onWidthChange = new YAHOO.util.CustomEvent('widthChanged');
    /** Fires when a header has changed - fireDirect sig: (this, columnIndex, newHeader)
     * @type YAHOO.util.CustomEvent 
     * */
    this.onHeaderChange = new YAHOO.util.CustomEvent('headerChanged');
	/** Fires when a column is hidden or unhidden - fireDirect sig: (this, columnIndex, hidden)
     * @type YAHOO.util.CustomEvent 
     * */
    this.onHiddenChange = new YAHOO.util.CustomEvent('hiddenChanged');
};

YAHOO.ext.grid.AbstractColumnModel.prototype = {
	fireWidthChange : function(colIndex, newWidth){
		this.onWidthChange.fireDirect(this, colIndex, newWidth);
	},
	
	fireHeaderChange : function(colIndex, newHeader){
		this.onHeaderChange.fireDirect(this, colIndex, newHeader);
	},
	
	fireHiddenChange : function(colIndex, hidden){
		this.onHiddenChange.fireDirect(this, colIndex, hidden);
	},
	
	/**
     * Interface method - Returns the number of columns.
     * @return {Number}
     */
    getColumnCount : function(){
        return 0;
    },
    
    /**
     * Interface method - Returns true if the specified column is sortable.
     * @param {Number} col The column index
     * @return {Boolean}
     */
    isSortable : function(col){
        return false;
    },
    
    /**
     * Interface method - Returns true if the specified column is hidden.
     * @param {Number} col The column index
     * @return {Boolean}
     */
    isHidden : function(col){
        return false;
    },
    
    /**
     * Interface method - Returns the sorting comparison function defined for the column (defaults to sortTypes.none).
     * @param {Number} col The column index
     * @return {Function}
     */
    getSortType : function(col){
        return YAHOO.ext.grid.DefaultColumnModel.sortTypes.none;
    },
    
    /**
     * Interface method - Returns the rendering (formatting) function defined for the column.
     * @param {Number} col The column index
     * @return {Function}
     */
    getRenderer : function(col){
        return YAHOO.ext.grid.DefaultColumnModel.defaultRenderer;
    },
    
    /**
     * Interface method - Returns the width for the specified column.
     * @param {Number} col The column index
     * @return {Number}
     */
    getColumnWidth : function(col){
        return 0;
    },
    
    /**
     * Interface method - Returns the total width of all columns.
     * @return {Number}
     */
    getTotalWidth : function(){
        return 0;
    },
    
    /**
     * Interface method - Returns the header for the specified column.
     * @param {Number} col The column index
     * @return {String}
     */
    getColumnHeader : function(col){
        return '';
    }
};
