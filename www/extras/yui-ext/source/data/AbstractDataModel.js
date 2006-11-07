/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */

/**
 * @class
 * This abstract class provides default implementations of the events required by the Grid. 
 It takes care of the creating the CustomEvents and provides some convenient methods for firing the events. <br><br>
 * @constructor
*/
YAHOO.ext.grid.AbstractDataModel = function(){
    /** Fires when a cell is updated - fireDirect sig: (this, rowIndex, columnIndex)
     * @type YAHOO.util.CustomEvent
     * @deprecated Use addListener instead of accessing directly
     */
    this.onCellUpdated = new YAHOO.util.CustomEvent('onCellUpdated');
    /** Fires when all data needs to be revalidated - fireDirect sig: (thisd)
     * @type YAHOO.util.CustomEvent 
     * @deprecated Use addListener instead of accessing directly
     */
    this.onTableDataChanged = new YAHOO.util.CustomEvent('onTableDataChanged');
    /** Fires when rows are deleted - fireDirect sig: (this, firstRowIndex, lastRowIndex)
     * @type YAHOO.util.CustomEvent 
     * @deprecated Use addListener instead of accessing directly
     */
    this.onRowsDeleted = new YAHOO.util.CustomEvent('onRowsDeleted');
    /** Fires when a rows are inserted - fireDirect sig: (this, firstRowIndex, lastRowIndex)
     * @type YAHOO.util.CustomEvent 
     * @deprecated Use addListener instead of accessing directly
     */
    this.onRowsInserted = new YAHOO.util.CustomEvent('onRowsInserted');
    /** Fires when a rows are updated - fireDirect sig: (this, firstRowIndex, lastRowIndex)
     * @type YAHOO.util.CustomEvent 
     * @deprecated Use addListener instead of accessing directly
     */
    this.onRowsUpdated = new YAHOO.util.CustomEvent('onRowsUpdated');
    /** Fires when a sort has reordered the rows - fireDirect sig: (this, sortColumnIndex, 
     * sortDirection = 'ASC' or 'DESC')
     * @type YAHOO.util.CustomEvent 
     * @deprecated Use addListener instead of accessing directly
     */
    this.onRowsSorted = new YAHOO.util.CustomEvent('onRowsSorted');
    
    this.events = {
      'cellupdated' : this.onCellUpdated,
      'datachanged' : this.onTableDataChanged,
      'rowsdeleted' : this.onRowsDeleted,
      'rowsinserted' : this.onRowsInserted,
      'rowsupdated' : this.onRowsUpdated,
      'rowssorted' : this.onRowsSorted
    };
};

YAHOO.ext.grid.AbstractDataModel.prototype = {
    
    addListener : YAHOO.ext.grid.Grid.prototype.addListener,
    removeListener : YAHOO.ext.grid.Grid.prototype.removeListener,
    fireEvent : YAHOO.ext.grid.Grid.prototype.fireEvent,
    
    /**
     *  Notifies listeners that the value of the cell at [row, col] has been updated
     */
    fireCellUpdated : function(row, col){
        this.onCellUpdated.fireDirect(this, row, col);
    },
    
    /**
     *  Notifies listeners that all data for the grid may have changed - use as a last resort. This 
     * also wipes out all selections a user might have made.
     */
    fireTableDataChanged : function(){
        this.onTableDataChanged.fireDirect(this);
    },
    
    /**
     *  Notifies listeners that rows in the range [firstRow, lastRow], inclusive, have been deleted
     */
    fireRowsDeleted : function(firstRow, lastRow){
        this.onRowsDeleted.fireDirect(this, firstRow, lastRow);
    },
    
    /**
     *  Notifies listeners that rows in the range [firstRow, lastRow], inclusive, have been inserted
     */
    fireRowsInserted : function(firstRow, lastRow){
        this.onRowsInserted.fireDirect(this, firstRow, lastRow);
    },
    
    /**
     *  Notifies listeners that rows in the range [firstRow, lastRow], inclusive, have been updated
     */
    fireRowsUpdated : function(firstRow, lastRow){
        this.onRowsUpdated.fireDirect(this, firstRow, lastRow);
    },
    
    /**
     *  Notifies listeners that rows have been sorted and any indexes may be invalid
     */
    fireRowsSorted : function(sortColumnIndex, sortDir, noRefresh){
        this.onRowsSorted.fireDirect(this, sortColumnIndex, sortDir, noRefresh);
    },
    
    /**
     * Empty interface method - Classes which extend AbstractDataModel should implement this method.
     * See {@link YAHOO.ext.DefaultDataModel} for an example implementation.
     */
    sort : function(columnModel, columnIndex, direction, suppressEvent){
    	
    },
    
    /**
     * Interface method to supply the view with info regarding the Grid's current sort state - if overridden,
     * this should return an object like this {column: this.sortColumn, direction: this.sortDir}.
     * @return {Object} 
     */
    getSortState : function(){
    	return {column: this.sortColumn, direction: this.sortDir};
    },
    
    /**
     * Empty interface method - Classes which extend AbstractDataModel should implement this method.
     * See {@link YAHOO.ext.DefaultDataModel} for an example implementation.
     */
    getRowCount : function(){
    	
    },
    
    /**
     * Empty interface method - Classes which extend AbstractDataModel should implement this method to support virtual row counts.
     */
    getTotalRowCount : function(){
    	return this.getRowCount();
    },
    
    
    /**
     * Empty interface method - Classes which extend AbstractDataModel should implement this method.
     * See {@link YAHOO.ext.DefaultDataModel} for an example implementation.
     */
    getRowId : function(rowIndex){
    	
    },
    
    /**
     * Empty interface method - Classes which extend AbstractDataModel should implement this method.
     * See {@link YAHOO.ext.DefaultDataModel} for an example implementation.
     */
    getValueAt : function(rowIndex, colIndex){
    	
    },
    
    /**
     * Empty interface method - Classes which extend AbstractDataModel should implement this method.
     * See {@link YAHOO.ext.DefaultDataModel} for an example implementation.
     */
    setValueAt : function(value, rowIndex, colIndex){
    	
    },
    
    isPaged : function(){
        return false;
    }
};