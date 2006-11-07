/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */

/**
 * @class
 * This class extends DefaultDataModel and adds the core functionality to load data remotely. <br><br>
 * @extends YAHOO.ext.grid.DefaultDataModel
 * @constructor
 * @param {String} dataType YAHOO.ext.grid.LoadableDataModel.XML, YAHOO.ext.grid.LoadableDataModel.TEXT or YAHOO.ext.grid.JSON
*/
YAHOO.ext.grid.LoadableDataModel = function(dataType){
    YAHOO.ext.grid.LoadableDataModel.superclass.constructor.call(this, []);
    
    /** Fires when a successful load is completed - fireDirect sig: (this)
     * @type YAHOO.util.CustomEvent 
     * @deprecated Use addListener instead of accessing directly
     */
    this.onLoad = new YAHOO.util.CustomEvent('load');
    /** Fires when a load fails - fireDirect sig: (this, errorMsg, responseObj)
     * @type YAHOO.util.CustomEvent 
     * @deprecated Use addListener instead of accessing directly
     */
    this.onLoadException = new YAHOO.util.CustomEvent('loadException');
    
    this.events['load'] = this.onLoad;
    this.events['beforeload'] = new YAHOO.util.CustomEvent('beforeload');
    this.events['loadexception'] = this.onLoadException;
    
    /**@private*/
    this.dataType = dataType;
    /**@private*/
    this.preprocessors = [];
    /**@private*/
    this.postprocessors = [];
    
    // paging info
    /** The active page @type Number*/
    this.loadedPage = 1;
    /** True to use remote sorting, initPaging automatically sets this to true @type Boolean */
    this.remoteSort = false;
    /** The number of records per page @type Number*/
    this.pageSize = 0;
    /** The script/page to call to provide paged/sorted data @type String*/
    this.pageUrl = null;
    /** An object of key/value pairs to be passed as parameters
     * when loading pages/sorting @type Object*/
    this.baseParams = {};
    /** Maps named params to url parameters - Override to specify your own param names */
    this.paramMap = {'page':'page', 'pageSize':'pageSize', 'sortColumn':'sortColumn', 'sortDir':'sortDir'};
    
};
YAHOO.extendX(YAHOO.ext.grid.LoadableDataModel, YAHOO.ext.grid.DefaultDataModel);

/** @ignore */
YAHOO.ext.grid.LoadableDataModel.prototype.setLoadedPage = function(pageNum, userCallback){
    this.loadedPage = pageNum;
    if(typeof userCallback == 'function'){
        userCallback();
    }
};

/** Returns true if this model uses paging @type Boolean */
YAHOO.ext.grid.LoadableDataModel.prototype.isPaged = function(){
    return this.pageSize > 0;
};

/** Returns the total number of records available, override if needed @type Number */
YAHOO.ext.grid.LoadableDataModel.prototype.getTotalRowCount = function(){
    return this.totalCount || this.getRowCount();
};

/** Returns the number of records per page @type Number */
YAHOO.ext.grid.LoadableDataModel.prototype.getPageSize = function(){
    return this.pageSize;
};

/** Returns the total number of pages available @type Number */
YAHOO.ext.grid.LoadableDataModel.prototype.getTotalPages = function(){
    if(this.getPageSize() == 0 || this.getTotalRowCount() == 0){
        return 1;
    }
    return Math.ceil(this.getTotalRowCount()/this.getPageSize());
};

/** Initializes paging for this model. */
YAHOO.ext.grid.LoadableDataModel.prototype.initPaging = function(url, pageSize, baseParams){
    this.pageUrl = url;
    this.pageSize = pageSize;
    this.remoteSort = true;
    if(baseParams) this.baseParams = baseParams;
};

/** @ignore */
YAHOO.ext.grid.LoadableDataModel.prototype.createParams = function(pageNum, sortColumn, sortDir){
    var params = {}, map = this.paramMap;
    for(var key in this.baseParams){
        if(typeof this.baseParams[key] != 'function'){
            params[key] = this.baseParams[key];
        }
    }
    params[map['page']] = pageNum;
    params[map['pageSize']] = this.getPageSize();
    params[map['sortColumn']] = (typeof sortColumn == 'undefined' ? '' : sortColumn);
    params[map['sortDir']] = sortDir || '';
    return params;
};

YAHOO.ext.grid.LoadableDataModel.prototype.loadPage = function(pageNum, callback, keepExisting){
    var sort = this.getSortState();
    var params = this.createParams(pageNum, sort.column, sort.direction);
    this.load(this.pageUrl, params, this.setLoadedPage.createDelegate(this, [pageNum, callback]), 
               keepExisting ? (pageNum-1) * this.pageSize : null);
};

/** @ignore */
YAHOO.ext.grid.LoadableDataModel.prototype.applySort = function(suppressEvent){
	if(!this.remoteSort){
        YAHOO.ext.grid.LoadableDataModel.superclass.applySort.apply(this, arguments);
    }else if(!suppressEvent){
        var sort = this.getSortState();
        if(sort.column){
           this.fireRowsSorted(sort.column, sort.direction, true);
        }
    }
};

/** @ignore */
YAHOO.ext.grid.LoadableDataModel.prototype.resetPaging = function(){
	this.loadedPage = 1;
};

/** Overridden sort method to use remote sorting if turned on */
YAHOO.ext.grid.LoadableDataModel.prototype.sort = function(columnModel, columnIndex, direction, suppressEvent){
    if(!this.remoteSort){
        YAHOO.ext.grid.LoadableDataModel.superclass.sort.apply(this, arguments);
    }else{
        this.columnModel = columnModel;
        this.sortColumn = columnIndex;
        this.sortDir = direction;
        var params = this.createParams(this.loadedPage, columnIndex, direction);
        this.load(this.pageUrl, params, this.fireRowsSorted.createDelegate(this, [columnIndex, direction, true]));
    }
}
/**
 * Initiates the loading of the data from the specified URL - Failed load attempts will 
 * fire the {@link #onLoadException} event.
 * @param {Object/String} url The url from which the data can be loaded
 * @param {<i>String/Object</i>} params (optional) The parameters to pass as either a url encoded string "param1=1&amp;param2=2" or as an object {param1: 1, param2: 2}
 * @param {<i>Function</i>} callback (optional) Callback when load is complete - called with signature (this, rowCountLoaded)
 * @param {<i>Number</i>} insertIndex (optional) if present, loaded data is inserted at the specified index instead of overwriting existing data
 */
YAHOO.ext.grid.LoadableDataModel.prototype.load = function(url, params, callback, insertIndex){
	this.fireEvent('beforeload');
	if(params && typeof params != 'string'){ // must be object
        var buf = [];
        for(var key in params){
            if(typeof params[key] != 'function'){
                buf.push(encodeURIComponent(key), '=', encodeURIComponent(params[key]), '&');
            }
        }
        delete buf[buf.length-1];
        params = buf.join('');
    }
    var cb = {
        success: this.processResponse,
        failure: this.processException,
        scope: this,
		argument: {callback: callback, insertIndex: insertIndex}
    };
    var method = params ? 'POST' : 'GET';
    YAHOO.util.Connect.asyncRequest(method, url, cb, params);
};

/**@private*/
YAHOO.ext.grid.LoadableDataModel.prototype.processResponse = function(response){
    var cb = response.argument.callback;
    var keepExisting = (typeof response.argument.insertIndex == 'number');
    var insertIndex = response.argument.insertIndex;
    switch(this.dataType){
    	case YAHOO.ext.grid.LoadableDataModel.XML:
    		this.loadData(response.responseXML, cb, keepExisting, insertIndex);
    	break;
    	case YAHOO.ext.grid.LoadableDataModel.JSON:
    		var rtext = response.responseText;
    		try { // this code is a modified version of Yahoo! UI DataSource JSON parsing
		        // Trim leading spaces
		        while(rtext.substring(0,1) == " ") {
		            rtext = rtext.substring(1, rtext.length);
		        }
		        // Invalid JSON response
		        if(rtext.indexOf("{") < 0) {
		            throw "Invalid JSON response";
		        }
		
		        // Empty (but not invalid) JSON response
		        if(rtext.indexOf("{}") === 0) {
		            this.loadData({}, response.argument.callback);
		            return;
		        }
		
		        // Turn the string into an object literal...
		        // ...eval is necessary here
		        var jsonObjRaw = eval("(" + rtext + ")");
		        if(!jsonObjRaw) {
		            throw "Error evaling JSON response";
		        }
				this.loadData(jsonObjRaw, cb, keepExisting, insertIndex);
		    } catch(e) {
		        this.fireLoadException(e, response);
				if(typeof callback == 'function'){
			    	callback(this, false);
			    }
		   	}
    	break;
    	case YAHOO.ext.grid.LoadableDataModel.TEXT:
    		this.loadData(response.responseText, cb, keepExisting, insertIndex);
    	break;
    };
};

/**@private*/
YAHOO.ext.grid.LoadableDataModel.prototype.processException = function(response){
    this.fireLoadException(null, response);
    if(typeof response.argument.callback == 'function'){
        response.argument.callback(this, false);
    }
};

YAHOO.ext.grid.LoadableDataModel.prototype.fireLoadException = function(e, responseObj){
    this.onLoadException.fireDirect(this, e, responseObj);
};

YAHOO.ext.grid.LoadableDataModel.prototype.fireLoadEvent = function(){
    this.fireEvent('load', this.loadedPage, this.getTotalPages());
};

/**
 * Adds a preprocessor function to parse data before it is added to the Model - ie. Date.parse to parse dates.
 */
YAHOO.ext.grid.LoadableDataModel.prototype.addPreprocessor = function(columnIndex, fn){
    this.preprocessors[columnIndex] = fn;
};

/**
 * Gets the preprocessor function for the specified column.
 */
YAHOO.ext.grid.LoadableDataModel.prototype.getPreprocessor = function(columnIndex){
    return this.preprocessors[columnIndex];
};

/**
 * Removes a preprocessor function.
 */
YAHOO.ext.grid.LoadableDataModel.prototype.removePreprocessor = function(columnIndex){
    this.preprocessors[columnIndex] = null;
};

/**
 * Adds a postprocessor function to format data before updating the underlying data source (ie. convert date to string before updating XML document).
 */
YAHOO.ext.grid.LoadableDataModel.prototype.addPostprocessor = function(columnIndex, fn){
    this.postprocessors[columnIndex] = fn;
};

/**
 * Gets the postprocessor function for the specified column.
 */
YAHOO.ext.grid.LoadableDataModel.prototype.getPostprocessor = function(columnIndex){
    return this.postprocessors[columnIndex];
};

/**
 * Removes a postprocessor function.
 */
YAHOO.ext.grid.LoadableDataModel.prototype.removePostprocessor = function(columnIndex){
    this.postprocessors[columnIndex] = null;
};
/**
 * Empty interface method - Called to process the data returned by the XHR - Classes which extend LoadableDataModel should implement this method.
 * See {@link YAHOO.ext.XMLDataModel} for an example implementation.
 */
YAHOO.ext.grid.LoadableDataModel.prototype.loadData = function(data, callback, keepExisting, insertIndex){
	
};

YAHOO.ext.grid.LoadableDataModel.XML = 'xml';
YAHOO.ext.grid.LoadableDataModel.JSON = 'json';
YAHOO.ext.grid.LoadableDataModel.TEXT = 'text';

/*
YAHOO.ext.grid.SparceDataset = function(bufferSize){
    this.stack = [];
    this.bufferSize = bufferSize || 1000;
    this.maxIndex = 0;
    
    this.events = {
        'rowsexpired' : new YAHOO.util.CustomEvent('rowsexpired')
    };
};

YAHOO.ext.grid.SparceDataset.prototype = {
    addListener : YAHOO.ext.grid.Grid.prototype.addListener,
    removeListener : YAHOO.ext.grid.Grid.prototype.removeListener,
    fireEvent : YAHOO.ext.grid.Grid.prototype.fireEvent,
    
    getRowAt : function(index){
        return this[String(index)];
    },
    
    splice : function(index, deleteCount){
        this.insertRowsAt(index, Array.prototype.slice.call(arguments, 2));
    },
    
    concat : function(){
        this.insertRowsAt(index, Array.prototype.slice.call(arguments, 2));
    },
    
    insertRowsAt: function(index, rowData){
        for(var i = 0; i < rowData.length; i++) {
        	var d = rowData[i];
        	var dataIndex = index + i;
        	this[dataIndex] = d;
        	this.stack.push(dataIndex);
        }
        this.maxIndex = Math.max(this.maxIndex, index+rowData.length);
        this.cleanup();
    },
    
    cleanup : function(){
        while(stack.length > this.bufferSize){
            var dataIndex = stack.shift();
            delete this[dataIndex];
            this.fireEvent('rowsexpired', dataIndex);
        }
    }
};*/





