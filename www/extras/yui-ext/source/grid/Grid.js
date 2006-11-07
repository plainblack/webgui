/*
 * YUI Extensions
 * Copyright(c) 2006, Jack Slocum.
 * 
 * This code is licensed under BSD license. 
 * http://www.opensource.org/licenses/bsd-license.php
 */

YAHOO.namespace('ext.grid');

/**
 * @class
 * This class represents the primary interface of a component based grid control.
 * <br><br>Usage:<pre><code>
 * var grid = new YAHOO.ext.grid.Grid('my-container-id', dataModel, columnModel);
 * // set any options
 * grid.render();
 * </code></pre>
 * @requires YAHOO.util.Dom
 * @requires YAHOO.util.Event
 * @requires YAHOO.util.CustomEvent 
 * @requires YAHOO.ext.Element
 * @requires YAHOO.ext.util.Browser
 * @requires YAHOO.ext.util.CSS
 * @requires YAHOO.ext.SplitBar 
 * @requires YAHOO.ext.EventObject 
 * @constructor
 * @param {String/HTMLElement/YAHOO.ext.Element} container The element into which this grid will be rendered - 
 * The container MUST have some type of size defined for the grid to fill. The container will be 
 * automatically set to position relative if it isn't already.
 * @param {Object} dataModel The data model to bind to
 * @param {Object} colModel The column model with info about this grid's columns
 * @param {<i>Object</i>} selectionModel (optional) The selection model for this grid (defaults to DefaultSelectionModel)
 */
YAHOO.ext.grid.Grid = function(container, dataModel, colModel, selectionModel){
	/** @private */
	this.container = YAHOO.ext.Element.get(container);
	if(this.container.getStyle('position') != 'absolute'){
	    this.container.setStyle('position', 'relative');
	}
	//this.container.setStyle('overflow', 'hidden');
	/** @private */
	this.id = this.container.id;
	
    /** @private */
	this.rows = [];
    /** @private */
	this.rowCount = 0;
    /** @private */
	this.fieldId = null;
    /** @private */
	this.dataModel = dataModel;
    /** @private */
	this.colModel = colModel;
    /** @private */
	this.selModel = selectionModel;
	
	/** @private */
	this.activeEditor = null;
	
	/** @private */
	this.editingCell = null;
	
	/** The minimum width a column can be resized to. (Defaults to 25)
	 * @type Number */
	this.minColumnWidth = 25;
	
	/** True to automatically resize the columns to fit their content <b>on initial render</b>
	 * @type Boolean */
	this.autoSizeColumns = false;
	
	/** True to measure headers with column data when auto sizing columns
	 * @type Boolean */
	this.autoSizeHeaders = false;
	
	/**
	 * True to autoSize the grid when the window resizes - defaults to true
	 */
	this.monitorWindowResize = true;
	
	/** If autoSizeColumns is on, maxRowsToMeasure can be used to limit the number of
	 * rows measured to get a columns size - defaults to 0 (all rows).
	 * @type Number */
	this.maxRowsToMeasure = 0;
	
	/** True to highlight rows when the mouse is over (default is false)
	 * @type Boolean */
	this.trackMouseOver = false;
	
	/** True to enable drag and drop of rows
	 * @type Boolean */
	this.enableDragDrop = false;
	
	/** True to stripe the rows (default is true)
	 * @type Boolean */
	this.stripeRows = true;
	
	/** A regular expression defining tagNames 
     * allowed to have text selection (Defaults to <code>/INPUT|TEXTAREA/i</code>) */
    this.allowTextSelectionPattern = /INPUT|TEXTAREA|SELECT/i;
	
	/** @private */
	this.setValueDelegate = this.setCellValue.createDelegate(this);
	
	var CE = YAHOO.util.CustomEvent;
	/** @private */
	this.events = {
	    // raw events
	    'click' : new CE('click'),
	    'dblclick' : new CE('dblclick'),
	    'mousedown' : new CE('mousedown'),
	    'mouseup' : new CE('mouseup'),
	    'mouseover' : new CE('mouseover'),
	    'mouseout' : new CE('mouseout'),
	    'keypress' : new CE('keypress'),
	    'keydown' : new CE('keydown'),
	    // custom events
	    'cellclick' : new CE('cellclick'),
	    'celldblclick' : new CE('celldblclick'),
	    'rowclick' : new CE('rowclick'),
	    'rowdblclick' : new CE('rowdblclick'),
	    'headerclick' : new CE('headerclick'),
	    'rowcontextmenu' : new CE('rowcontextmenu'),
	    'headercontextmenu' : new CE('headercontextmenu'),
	    'beforeedit' : new CE('beforeedit'),
	    'afteredit' : new CE('afteredit'),
	    'bodyscroll' : new CE('bodyscroll'),
	    'columnresize' : new CE('columnresize'),
	    'startdrag' : new CE('startdrag'),
	    'enddrag' : new CE('enddrag'),
	    'dragdrop' : new CE('dragdrop'),
	    'dragover' : new CE('dragover'),
	    'dragenter' : new CE('dragenter'),
	    'dragout' : new CE('dragout')
	};
};

YAHOO.ext.grid.Grid.prototype = { 
    /**
     * Called once after all setup has been completed and the grid is ready to be rendered.
     */
    render : function(){
    	if(!this.view){
    	    if(this.dataModel.isPaged()){
    		    this.view = new YAHOO.ext.grid.PagedGridView();
    	    }else{
    	        this.view = new YAHOO.ext.grid.GridView();
    	    }
    	}
    	this.view.init(this);
        this.el = getEl(this.view.render(), true);
        var c = this.container;
        c.mon("click", this.onClick, this, true);
        c.mon("dblclick", this.onDblClick, this, true);
        c.mon("contextmenu", this.onContextMenu, this, true);
        c.mon("selectstart", this.cancelTextSelection, this, true);
        c.mon("mousedown", this.cancelTextSelection, this, true);
        c.mon("mousedown", this.onMouseDown, this, true);
        c.mon("mouseup", this.onMouseUp, this, true);
        if(this.trackMouseOver){
            this.el.mon("mouseover", this.onMouseOver, this, true);
            this.el.mon("mouseout", this.onMouseOut, this, true);
        }
        c.mon("keypress", this.onKeyPress, this, true);
        c.mon("keydown", this.onKeyDown, this, true);
        this.init();
    },
    
    /** @private */
    init : function(){
        this.rows = this.el.dom.rows;
        if(!this.disableSelection){
	        if(!this.selModel){
	            this.selModel = new YAHOO.ext.grid.DefaultSelectionModel(this);
	        }
	        this.selModel.init(this);
	        this.selModel.onSelectionChange.subscribe(this.updateField, this, true);
        }else{
            this.selModel = new YAHOO.ext.grid.DisableSelectionModel(this);
            this.selModel.init(this);
        }
        
        if(this.enableDragDrop){
            this.dd = new YAHOO.ext.grid.GridDD(this, this.container.dom);
        }
     },   

    /** @ignore */
    onMouseDown : function(e){
        this.fireEvent('mousedown', e);
    },
    
    /** @ignore */
    onMouseUp : function(e){
        this.fireEvent('mouseup', e);
    },
    
    /** @ignore */
    onMouseOver : function(e){
        this.fireEvent('mouseover', e);
    },
    
    /** @ignore */
    onMouseOut : function(e){
        this.fireEvent('mouseout', e);
    },
    
    /** @ignore */
    onKeyPress : function(e){
        this.fireEvent('keypress', e);
    },
    
    /** @ignore */
    onKeyDown : function(e){
        this.fireEvent('keydown', e);
    },
    
    /** 
     * @private internal event firing 
     * expects arguments[0] is the event name and the rest are the fireDirect arguments
     */
    fireEvent : function(){
        var ce = this.events[arguments[0].toLowerCase()];
        ce.fireDirect.apply(ce, Array.prototype.slice.call(arguments, 1));
    },
    /**
     * Adds a listener for one of the many defined grid events
     * @param {String}   eventName     The type of event to listen for
     * @param {Function} fn        The method the event invokes
     * @param {<i>Object</i>}   scope  (optional)  An arbitrary object that will be 
     *                             passed as a parameter to the handler
     * @param {<i>boolean</i>}  override (optional) If true, the obj passed in becomes
     *                             the execution scope of the listener
     */
    addListener : function(eventName, fn, scope, override){
        this.events[eventName.toLowerCase()].subscribe(fn, scope, override);
    },
    
    /**
     * Shorthand for addListener
     */
    on : function(eventName, fn, scope, override){
        this.events[eventName.toLowerCase()].subscribe(fn, scope, override);
    },
    
    removeListener : function(eventName, fn, scope){
        this.events[eventName.toLowerCase()].unsubscribe(fn, scope);
    },
    
    /** @ignore */
    onClick : function(e){
        this.fireEvent('click', e);
        var target = e.getTarget();
        var row = this.getRowFromChild(target);
        var cell = this.getCellFromChild(target);
        var header = this.getHeaderFromChild(target);
        if(row){
            this.fireEvent('rowclick', this, row.rowIndex, e);
        }
        if(cell){
            this.fireEvent('cellclick', this, row.rowIndex, cell.columnIndex, e);
        }
        if(header){
            this.fireEvent('headerclick', this, header.columnIndex, e);
        }
    },

    /** @ignore */
    onContextMenu : function(e){
        var target = e.getTarget();
        var row = this.getRowFromChild(target);
        var header = this.getHeaderFromChild(target);
        if(row){
            this.fireEvent('rowcontextmenu', this, row.rowIndex, e);
        }
        if(header){
            this.fireEvent('headercontextmenu', this, header.columnIndex, e);
        }
        e.preventDefault();
    },

    /** @ignore */
    onDblClick : function(e){
        this.fireEvent('dblclick', e);
        var target = e.getTarget();
        var row = this.getRowFromChild(target);
        var cell = this.getCellFromChild(target);
        if(row){
            this.fireEvent('rowdblclick', this, row.rowIndex, e);
        }
        if(cell){
            this.fireEvent('celldblclick', this, row.rowIndex, cell.columnIndex, e);
        }
    },
    
    /**
     * Starts editing the specified for the specified row/column
     */
    startEditing : function(rowIndex, colIndex){
        var row = this.rows[rowIndex];
        var cell = row.childNodes[colIndex];
        this.stopEditing();
        setTimeout(this.doEdit.createDelegate(this, [row, cell]), 10);
    },
        
    /**
     * Stops any active editing
     */
    stopEditing : function(){
        if(this.activeEditor){
            this.activeEditor.stopEditing();
        }
    },
        
    /** @ignore */
    doEdit : function(row, cell){
        if(!row || !cell) return;
        var cm = this.colModel;
        var dm = this.dataModel;
        var colIndex = cell.columnIndex;
        var rowIndex = row.rowIndex;
        if(cm.isCellEditable(colIndex, rowIndex)){
           var ed = cm.getCellEditor(colIndex, rowIndex);
           if(ed){
               if(this.activeEditor){
                   this.activeEditor.stopEditing();
               }
               this.fireEvent('beforeedit', this, rowIndex, colIndex);
               this.activeEditor = ed;
               this.editingCell = cell;
               this.view.ensureVisible(row, true);
               try{
                   cell.focus();
               }catch(e){}
               ed.init(this, this.el.dom.parentNode, this.setValueDelegate);
               var value = dm.getValueAt(rowIndex, cm.getDataIndex(colIndex));
               // set timeout so firefox stops editing before starting a new edit
               setTimeout(ed.startEditing.createDelegate(ed, [value, row, cell]), 1);
           }   
        }  
    },
    
    setCellValue : function(value, rowIndex, colIndex){
         this.dataModel.setValueAt(value, rowIndex, this.colModel.getDataIndex(colIndex));
         this.fireEvent('afteredit', this, rowIndex, colIndex);
    },
    
    /** @ignore Called when text selection starts or mousedown to prevent default */
    cancelTextSelection : function(e){
        var target = e.getTarget();
        if(target && target != this.el.dom.parentNode && !this.allowTextSelectionPattern.test(target.tagName)){
            e.preventDefault();
        }
    },
    
    /**
     * Causes the grid to manually recalculate it's dimensions. Generally this is done automatically, 
     * but if manual update is required this method will initiate it.
     */
    autoSize : function(){
        this.view.updateWrapHeight();
        this.view.adjustForScroll();
    },
    
    /**
     * Scrolls the grid to the specified row
     * @param {Number/HTMLElement} row The row object or index of the row
     */
    scrollTo : function(row){
        if(typeof row == 'number'){
            row = this.rows[row];
        }
        this.view.ensureVisible(row, true);
    },
    
    /** @private */
    getEditingCell : function(){
        return this.editingCell;    
    },
    
    /**
     * Binds this grid to the field with the specified id. Initially reads and parses the comma 
     * delimited ids in the field and selects those items. All selections made in the grid
     * will be persisted to the field by their ids comma delimited.
     * @param {String} The id of the field to bind to
     */
    bindToField : function(fieldId){
        this.fieldId = fieldId;
        this.readField();
    },
    
    /** @private */
    updateField : function(){
        if(this.fieldId){
            var field = YAHOO.util.Dom.get(this.fieldId);
            field.value = this.getSelectedRowIds().join(',');
        }
    },
    
    /**
     * Causes the grid to read and select the ids from the bound field - See {@link #bindToField}.
     */
    readField : function(){
        if(this.fieldId){
            var field = YAHOO.util.Dom.get(this.fieldId);
            var values = field.value.split(',');
            var rows = this.getRowsById(values);
            this.selModel.selectRows(rows, false);
        }
    },
	
	/**
	 * Returns the table row at the specified index
	 * @return {HTMLElement} 
	 */
    getRow : function(index){
        return this.rows[index];
    },
	
	/**
	 * Returns the rows that have the specified id(s). The id value for a row is provided 
	 * by the DataModel. See {@link YAHOO.ext.grid.DefaultDataModel#getRowId}.
	 * @param {String/Array} An id to find or an array of ids
	 * @return {HtmlElement/Array} If one id was passed in, it returns one result. 
	 * If an array of ids was specified, it returns an Array of HTMLElements
	 */
    getRowsById : function(id){
        var dm = this.dataModel;
        if(!(id instanceof Array)){
            for(var i = 0; i < this.rows.length; i++){
                if(dm.getRowId(i) == id){
                    return this.rows[i];
                }
            }
            return null;
        }
        var found = [];
        var re = "^(?:";
        for(var i = 0; i < id.length; i++){
            re += id[i];
            if(i != id.length-1) re += "|";
        }
        var regex = new RegExp(re + ")$");
        for(var i = 0; i < this.rows.length; i++){
            if(regex.test(dm.getRowId(i))){
                found.push(this.rows[i]);
            }
        }
        return found;
    },
    
    /**
	 * Returns the row that comes after the specified row - text nodes are skipped.
	 * @param {HTMLElement} row
	 * @return {HTMLElement} 
	 */
    getRowAfter : function(row){
        return this.getSibling('next', row);
    },
    
    /**
	 * Returns the row that comes before the specified row - text nodes are skipped.
	 * @param {HTMLElement} row
	 * @return {HTMLElement} 
	 */
    getRowBefore : function(row){
        return this.getSibling('previous', row);
    },
    
    /**
	 * Returns the cell that comes after the specified cell - text nodes are skipped.
	 * @param {HTMLElement} cell
	 * @param {Boolean} includeHidden
	 * @return {HTMLElement} 
	 */
    getCellAfter : function(cell, includeHidden){
        var next = this.getSibling('next', cell);
        if(next && !includeHidden && this.colModel.isHidden(next.columnIndex)){
            return this.getCellAfter(next);
        }
        return next;
    },
    
    /**
	 * Returns the cell that comes before the specified cell - text nodes are skipped.
	 * @param {HTMLElement} cell
	 * @param {Boolean} includeHidden
	 * @return {HTMLElement} 
	 */
    getCellBefore : function(cell, includeHidden){
        var prev = this.getSibling('previous', cell);
        if(prev && !includeHidden && this.colModel.isHidden(prev.columnIndex)){
            return this.getCellBefore(prev);
        }
        return prev;
    },
    
    /**
	 * Returns the last cell for the row - text nodes and hidden columns are skipped.
	 * @param {HTMLElement} row
	 * @param {Boolean} includeHidden
	 * @return {HTMLElement} 
	 */
    getLastCell : function(row, includeHidden){
        var cell = this.getElement('previous', row.lastChild);
        if(cell && !includeHidden && this.colModel.isHidden(cell.columnIndex)){
            return this.getCellBefore(cell);
        }
        return cell;
    },
    
    /**
	 * Returns the first cell for the row - text nodes and hidden columns are skipped.
	 * @param {HTMLElement} row
	 * @param {Boolean} includeHidden
	 * @return {HTMLElement} 
	 */
    getFirstCell : function(row, includeHidden){
        var cell = this.getElement('next', row.firstChild);
        if(cell && !includeHidden && this.colModel.isHidden(cell.columnIndex)){
            return this.getCellAfter(cell);
        }
        return cell;
    },
    
    /**
     * Gets siblings, skipping text nodes
     * @param {String} type The direction to walk: 'next' or 'previous'
     * @private
     */
    getSibling : function(type, node){
        if(!node) return null;
        type += 'Sibling';
        var n = node[type];
        while(n && n.nodeType != 1){
            n = n[type];
        }
        return n;
    },
    
    /**
     * Returns node if node is an HTMLElement else walks the siblings in direction looking for 
     * a node that is an element
     * @param {String} direction The direction to walk: 'next' or 'previous'
     * @private
     */
    getElement : function(direction, node){
        if(!node || node.nodeType == 1) return node;
        else return this.getSibling(direction, node);
    },
    
    /**
     * @private
     */
    getElementFromChild : function(childEl, parentClass){
        if(!childEl || (YAHOO.util.Dom.hasClass(childEl, parentClass))){
		    return childEl;
	    }
	    var p = childEl.parentNode;
	    while(p && p.tagName.toUpperCase() != 'BODY'){
            if(YAHOO.util.Dom.hasClass(p, parentClass)){
            	return p;
            }
            p = p.parentNode;
        }
	    return null;
    },
    
    /**
	 * Returns the row that contains the specified child element.
	 * @param {HTMLElement} childEl
	 * @return {HTMLElement} 
	 */
    getRowFromChild : function(childEl){
        return this.getElementFromChild(childEl, 'ygrid-row');
    },
    
    /**
	 * Returns the cell that contains the specified child element.
	 * @param {HTMLElement} childEl
	 * @return {HTMLElement} 
	 */
    getCellFromChild : function(childEl){
        return this.getElementFromChild(childEl, 'ygrid-col');
    },
    
    
    /**
     * Returns the header element that contains the specified child element.
     * @param {HTMLElement}  childEl
	 * @return {HTMLElement} 
	 */
     getHeaderFromChild : function(childEl){
        return this.getElementFromChild(childEl, 'ygrid-hd');
    },
    
    /**
     * Convenience method for getSelectionModel().getSelectedRows() - 
     * See <small>{@link YAHOO.ext.grid.DefaultSelectionModel#getSelectedRows}</small> for more details.
     */
    getSelectedRows : function(){
        return this.selModel.getSelectedRows();
    },
    
    /**
     * Convenience method for getSelectionModel().getSelectedRows()[0] - 
     * See <small>{@link YAHOO.ext.grid.DefaultSelectionModel#getSelectedRows}</small> for more details.
     */
    getSelectedRow : function(){
        if(this.selModel.hasSelection()){
            return this.selModel.getSelectedRows()[0];
        }
        return null;
    },
    
    /**
     * Get the selected row indexes
     * @return {Array} Array of indexes
     */
    getSelectedRowIndexes : function(){
        var a = [];
        var rows = this.selModel.getSelectedRows();
        for(var i = 0; i < rows.length; i++) {
        	a[i] = rows[i].rowIndex;
        }
        return a;
    },
    
    /**
     * Gets the first selected row or -1 if none are selected
     * @return {Number}
     */
    getSelectedRowIndex : function(){
        if(this.selModel.hasSelection()){
           return this.selModel.getSelectedRows()[0].rowIndex;
        }
        return -1;
    },
    
    /**
     * Convenience method for getSelectionModel().getSelectedRowIds()[0] - 
     * See <small>{@link YAHOO.ext.grid.DefaultSelectionModel#getSelectedRowIds}</small> for more details.
     */
    getSelectedRowId : function(){
        if(this.selModel.hasSelection()){
           return this.selModel.getSelectedRowIds()[0];
        }
        return null;
    },
    
    /**
     * Convenience method for getSelectionModel().getSelectedRowIds() - 
     * See <small>{@link YAHOO.ext.grid.DefaultSelectionModel#getSelectedRowIds}</small> for more details.
     */
    getSelectedRowIds : function(){
        return this.selModel.getSelectedRowIds();
    },
    
    /**
     * Convenience method for getSelectionModel().clearSelections() - 
     * See <small>{@link YAHOO.ext.grid.DefaultSelectionModel#clearSelections}</small> for more details.
     */
    clearSelections : function(){
        this.selModel.clearSelections();
    },
    
        
    /**
     * Convenience method for getSelectionModel().selectAll() - 
     * See <small>{@link YAHOO.ext.grid.DefaultSelectionModel#selectAll}</small> for more details.
     */
    selectAll : function(){
        this.selModel.selectAll();
    },
    
        
    /**
     * Convenience method for getSelectionModel().getCount() - 
     * See <small>{@link YAHOO.ext.grid.DefaultSelectionModel#getCount}</small> for more details.
     */
    getSelectionCount : function(){
        return this.selModel.getCount();
    },
    
    /**
     * Convenience method for getSelectionModel().hasSelection() - 
     * See <small>{@link YAHOO.ext.grid.DefaultSelectionModel#hasSelection}</small> for more details.
     */
    hasSelection : function(){
        return this.selModel.hasSelection();
    },
    
    /**
     * Returns the grid's SelectionModel.
     */
    getSelectionModel : function(){
        if(!this.selModel){
            this.selModel = new DefaultSelectionModel();
        }
        return this.selModel;
    },
    
    /**
     * Returns the grid's DataModel.
     */
    getDataModel : function(){
        return this.dataModel;
    },
    
    /**
     * Returns the grid's ColumnModel.
     */
    getColumnModel : function(){
        return this.colModel;
    },
    
    /**
     * Returns the grid's GridView object.
     */
    getView : function(){
        return this.view;
    },
    /**
     * Called to get grid's drag proxy text, by default returns this.ddText. 
     * @return {String}
     */
    getDragDropText : function(){
        return this.ddText.replace('%0', this.selModel.getCount());
    }
};
/**
 * Configures the text is the drag proxy (defaults to "%0 selected row(s)"). 
 * %0 is replaced with the number of selected rows.
 * @type String
 */
YAHOO.ext.grid.Grid.prototype.ddText = "%0 selected row(s)";