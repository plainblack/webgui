/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */


/**
 * @class
 * This is the default implementation of a DataModel used by the Grid. It works 
 * with multi-dimensional array based data. Using the event system in the base class 
 * {@link YAHOO.ext.grid.AbstractDataModel}, all updates to this DataModel are automatically
 * reflected in the user interface.
 * <br>Usage:<br>
 * <pre><code>
 * var myData = [
	["MSFT","Microsoft Corporation", "314,571.156", "32,187.000", "55000"],
	["ORCL", "Oracle Corporation", "62,615.266", "9,519.000", "40650"]
 * ];
 * var dataModel = new YAHOO.ext.grid.DefaultDataModel(myData);
 * </code></pre>
 * @extends YAHOO.ext.grid.AbstractDataModel
 * @constructor
*/
YAHOO.ext.grid.DefaultDataModel = function(data){
    YAHOO.ext.grid.DefaultDataModel.superclass.constructor.call(this);
    /**@private*/
    this.data = data;
};
YAHOO.extendX(YAHOO.ext.grid.DefaultDataModel, YAHOO.ext.grid.AbstractDataModel);

/**
 * Returns the number of rows in the dataset
 * @return {Number}
 */
YAHOO.ext.grid.DefaultDataModel.prototype.getRowCount = function(){
    return this.data.length;
};
    
/**
 * Returns the ID of the specified row. By default it return the value of the first column. 
 * Override to provide more advanced ID handling. 
 * @return {Number}
 */
YAHOO.ext.grid.DefaultDataModel.prototype.getRowId = function(rowIndex){
    return this.data[rowIndex][0];
};

/**
 * Returns the column data for the specified row. 
 * @return {Array}
 */
YAHOO.ext.grid.DefaultDataModel.prototype.getRow = function(rowIndex){
    return this.data[rowIndex];
};

/**
 * Returns the column data for the specified rows as a 
 * multi-dimensional array: rows[3][0] would give you the value of row 4, column 0. 
 * @param {Array} indexes The row indexes to fetch
 * @return {Array}
 */
YAHOO.ext.grid.DefaultDataModel.prototype.getRows = function(indexes){
    var data = this.data;
    var r = [];
    for(var i = 0; i < indexes.length; i++){
       r.push(data[indexes[i]]);
    }
    return r;
};

/**
 * Returns the value at the specified data position
 * @param {Number} rowIndex
 * @param {Number} colIndex
 * @return {Object}
 */
YAHOO.ext.grid.DefaultDataModel.prototype.getValueAt = function(rowIndex, colIndex){
	return this.data[rowIndex][colIndex];
};

/**
 * Sets the specified value at the specified data position
 * @param {Object} value The new value
 * @param {Number} rowIndex
 * @param {Number} colIndex
 */
YAHOO.ext.grid.DefaultDataModel.prototype.setValueAt = function(value, rowIndex, colIndex){
    this.data[rowIndex][colIndex] = value;
    this.fireCellUpdated(rowIndex, colIndex);
};

/**
 * @private
 * Removes the specified range of rows.
 * @param {Number} startIndex
 * @param {<i>Number</i>} endIndex (optional) Defaults to startIndex
 */
YAHOO.ext.grid.DefaultDataModel.prototype.removeRows = function(startIndex, endIndex){
    endIndex = endIndex || startIndex;
    this.data.splice(startIndex, endIndex-startIndex+1);
    this.fireRowsDeleted(startIndex, endIndex);
};

/**
 * Remove a row.
 * @param {Number} index
 */
YAHOO.ext.grid.DefaultDataModel.prototype.removeRow = function(index){
    this.data.splice(index, 1);
    this.fireRowsDeleted(index, index);
};

/**
 * @private
 * Removes all rows.
 */
YAHOO.ext.grid.DefaultDataModel.prototype.removeAll = function(){
	var count = this.getRowCount();
	if(count > 0){
    	this.removeRows(0, count-1);
	}
};

/**
 * Query the DataModel rows by the filters defined in spec, for example...
 * <pre><code>
 * // column 1 starts with Jack, column 2 filtered by myFcn, column 3 equals 'Fred'
 * dataModel.filter({1: /^Jack.+/i}, 2: myFcn, 3: 'Fred'});
 * </code></pre> 
 * @param {Object} spec The spec is generally an object literal consisting of
 * column index and filter type. The filter type can be a string/number (exact match),
 * a regular expression to test using String.search() or a function to call. If it's a function, 
 * it will be called with the value for the specified column and an array of the all column 
 * values for that row: yourFcn(value, columnData). If it returns anything other than true, 
 * the row is not a match.
 * @param {Boolean} returnUnmatched True to return rows which <b>don't</b> match the query instead
 * of rows that do match
 * @return {Array} An array of row indexes that match
 */
YAHOO.ext.grid.DefaultDataModel.prototype.query = function(spec, returnUnmatched){
    var d = this.data;
    var r = [];
    for(var i = 0; i < d.length; i++){
        var row = d[i];
        var isMatch = true;
        for(var col in spec){
            if(typeof spec[col] != 'function'){
                if(!isMatch) continue;
                var filter = spec[col];
                switch(typeof filter){
                    case 'string':
                    case 'number':
                    case 'boolean':
                      if(row[col] != filter){
                          isMatch = false;
                      }
                    break;
                    case 'function':
                      if(!filter(row[col], row)){
                          isMatch = false;
                      }
                    break;
                    case 'object':
                       if(filter instanceof RegExp){
                           if(String(row[col]).search(filter) === -1){
                               isMatch = false;
                           }
                       }
                    break;
                }
            }
        }
        if(isMatch && !returnUnmatched){
            r.push(i);
        }else if(!isMatch && returnUnmatched){
            r.push(i);
        }
    }
    return r;
};

/**
 * Filter the DataModel rows by the query defined in spec, see {@link #query} for more details 
 * on the query spec.
 * @param {Object} query The query spec {@link #query}
 * @return {Number} The number of rows removed
 */
YAHOO.ext.grid.DefaultDataModel.prototype.filter = function(query){
    var matches = this.query(query, true);
    var data = this.data;
    // go thru the data setting matches to deleted
    // while not disturbing row indexes
    for(var i = 0; i < matches.length; i++){ 
        data[matches[i]]._deleted = true;
    }
    for(var i = 0; i < data.length; i++){
        while(data[i] && data[i]._deleted === true){
            this.removeRow(i);
        }
    }
    return matches.length;
};

/**
 * Adds a row to the dataset.
 * @param {Array} cellValues The array of values for the new row
 * @return {Number} The index of the added row
 */
YAHOO.ext.grid.DefaultDataModel.prototype.addRow = function(cellValues){
    this.data.push(cellValues);
    var newIndex = this.data.length-1;
    this.fireRowsInserted(newIndex, newIndex);
    this.applySort();
    return newIndex;
};

/**
 * @private
 * Adds a set of rows.
 * @param {Array} rowData This should be an array of arrays like the constructor takes
 */
YAHOO.ext.grid.DefaultDataModel.prototype.addRows = function(rowData){
    this.data = this.data.concat(rowData);
    var firstIndex = this.data.length-rowData.length;
    this.fireRowsInserted(firstIndex, firstIndex+rowData.length-1);
    this.applySort();
};

/**
 * Inserts a row a the specified location in the dataset.
 * @param {Number} index The index where the row should be inserted
 * @param {Array} cellValues The array of values for the new row
 * @return {Number} The index the row was inserted in
 */
YAHOO.ext.grid.DefaultDataModel.prototype.insertRow = function(index, cellValues){
    this.data.splice(index, 0, cellValues);
    this.fireRowsInserted(index, index);
    this.applySort();
    return index;
};

/**
 * @private
 * Inserts a set of rows.
 * @param {Number} index The index where the rows should be inserted
 * @param {Array} rowData This should be an array of arrays like the constructor takes
 */
YAHOO.ext.grid.DefaultDataModel.prototype.insertRows = function(index, rowData){
    /*
    if(index == this.data.length){ // try these two first since they are faster
        this.data = this.data.concat(rowData);
    }else if(index == 0){
        this.data = rowData.concat(this.data);
    }else{
        var newData = this.data.slice(0, index);
        newData.concat(rowData);
        newData.concat(this.data.slice(index));
        this.data = newData;
    }*/
    var args = rowData.concat();
    args.splice(0, 0, index, 0);
    this.data.splice.apply(this.data, args);
    this.fireRowsInserted(index, index+rowData.length-1);
    this.applySort();
};

/**
 * Applies the last used sort to the current data.
 */
YAHOO.ext.grid.DefaultDataModel.prototype.applySort = function(suppressEvent){
	if(this.columnModel && typeof this.sortColumn != 'undefined'){
		this.sort(this.columnModel, this.sortColumn, this.sortDir, suppressEvent);
	}
};

YAHOO.ext.grid.DefaultDataModel.prototype.setDefaultSort = function(columnModel, columnIndex, direction){
    this.columnModel = columnModel;
    this.sortColumn = columnIndex;
    this.sortDir = direction;
};
/**
 * Sorts the data by the specified column - Uses the sortType specified for the column in the passed columnModel.
 * @param {YAHOO.ext.grid.DefaultColumnModel} columnModel The ColumnModel for this dataset
 * @param {Number} columnIndex The column index to sort by
 * @param {String} direction The direction of the sort ('DESC' or 'ASC')
 */
YAHOO.ext.grid.DefaultDataModel.prototype.sort = function(columnModel, columnIndex, direction, suppressEvent){
    // store these so we can maintain sorting when we load new data
    this.columnModel = columnModel;
    this.sortColumn = columnIndex;
    this.sortDir = direction;
    
    var dsc = direction == 'DESC';
    var sortType = columnModel.getSortType(columnIndex);
    var fn = function(cells, cells2){
        var v1 = sortType(cells[columnIndex], cells);
        var v2 = sortType(cells2[columnIndex], cells2);
        if(v1 < v2)
			return dsc ? -1 : +1;
		if(v1 > v2)
			return dsc ? +1 : -1;
	    return 0;
    };
    this.data.sort(fn);
    if(!suppressEvent){
       this.fireRowsSorted(columnIndex, direction);
    }
};