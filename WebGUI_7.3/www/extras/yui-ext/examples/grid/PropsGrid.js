YAHOO.ext.grid.PropsDataModel = function(propertyNames, source){
    YAHOO.ext.grid.PropsDataModel.superclass.constructor.call(this, []);
    if(source){
        this.setSource(source);
    }
    this.names = propertyNames || {};
};
YAHOO.extendX(YAHOO.ext.grid.PropsDataModel, YAHOO.ext.grid.DefaultDataModel, {
    setSource : function(o){
        this.source = o;
        var data = [];
        for(var key in o){
            if(this.isEditableValue(o[key])){
                var vals = [key, o[key]];
                vals.key = key;
                data.push(vals);
            }
        }
        this.removeAll();
        this.addRows(data);
    },
    
    getRowId: function(rowIndex){
        return this.data[rowIndex].key;  
    },
    
    getPropertyName: function(rowIndex){
        return this.data[rowIndex].key;  
    },
    
    isEditableValue: function(val){
        if(val && val instanceof Date){
            return true;
        }else if(typeof val == 'object' || typeof val == 'function'){
            return false;
        }
        return true;
    },
    
    setValueAt : function(value, rowIndex, colIndex){
        var origVal = this.getValueAt(rowIndex, colIndex);
        if(typeof origVal == 'boolean'){
            value = (value == 'true' || value == '1');
        }
        YAHOO.ext.grid.PropsDataModel.superclass.setValueAt.call(this, value, rowIndex, colIndex);
        var key = this.data[rowIndex].key;
        if(key){
            this.source[key] = value;
        }
    },
    
    getName : function(propName){
        if(typeof this.names[propName] != 'undefined'){
            return this.names[propName];
        }
        return propName;
    },
    
    getSource : function(){
        return this.source;
    }
});
YAHOO.ext.grid.PropsColumnModel = function(dataModel, customEditors){
    YAHOO.ext.grid.PropsColumnModel.superclass.constructor.call(this, [
        {header: 'Name', sortable: true},
        {header: 'Value'} 
    ]);
    this.dataModel = dataModel;
    this.bselect = YAHOO.ext.DomHelper.append(document.body, {
        tag: 'select', cls: 'ygrid-editor', children: [
            {tag: 'option', value: 'true', html: 'true'},
            {tag: 'option', value: 'false', html: 'false'}
        ]
    });
    YAHOO.util.Dom.generateId(this.bselect);
    this.editors = {
        'date' : new YAHOO.ext.grid.DateEditor(),
        'string' : new YAHOO.ext.grid.TextEditor(),
        'number' : new YAHOO.ext.grid.NumberEditor(),
        'boolean' : new YAHOO.ext.grid.SelectEditor(this.bselect)
    };
    this.customEditors = customEditors || {};
    this.renderCellDelegate = this.renderCell.createDelegate(this);
};

YAHOO.extendX(YAHOO.ext.grid.PropsColumnModel, YAHOO.ext.grid.DefaultColumnModel, {
    isCellEditable : function(colIndex, rowIndex){
        return colIndex == 1;
    },
    
    getRenderer : function(col){
        if(col == 1){
            return this.renderCellDelegate;
        }
        return YAHOO.ext.grid.DefaultColumnModel.defaultRenderer; 
    },
    
    renderCell : function(val, rowIndex, colIndex){
        if(val instanceof Date){
            return this.renderDate(val);
        }else if(typeof val == 'boolean'){
            return this.renderBool(val);
        }else{
            return val;
        }
    },
    
    getCellEditor : function(colIndex, rowIndex){
        var propName = this.dataModel.getPropertyName(rowIndex);
        if(this.customEditors[propName]){
            return this.customEditors[propName];
        }
        var val = this.dataModel.getValueAt(rowIndex, colIndex);
        if(val instanceof Date){
            return this.editors['date'];
        }else if(typeof val == 'number'){
            return this.editors['number'];
        }else if(typeof val == 'boolean'){
            return this.editors['boolean'];
        }else{
            return this.editors['string'];
        }
    },
    
    getCellEditor : function(colIndex, rowIndex){
        var val = this.dataModel.getValueAt(rowIndex, colIndex);
        if(val instanceof Date){
            return this.editors['date'];
        }else if(typeof val == 'number'){
            return this.editors['number'];
        }else if(typeof val == 'boolean'){
            return this.editors['boolean'];
        }else{
            return this.editors['string'];
        }
    }
});

YAHOO.ext.grid.PropsColumnModel.prototype.renderDate = function(dateVal){
    return dateVal.dateFormat('m/j/Y');
};

YAHOO.ext.grid.PropsColumnModel.prototype.renderBool = function(bVal){
    return bVal ? 'true' : 'false';
};

YAHOO.ext.grid.PropsGrid = function(container, propNames){
    var dm = new YAHOO.ext.grid.PropsDataModel(propNames);
    var cm =new YAHOO.ext.grid.PropsColumnModel(dm);
    dm.sort(cm, 0, 'ASC');
    YAHOO.ext.grid.PropsGrid.superclass.constructor.call(this, container, dm, cm);
    this.container.addClass('yprops-grid');
    this.lastEditRow = null;
    this.on('cellclick', this.onCellClick, this, true);
    this.on('beforeedit', this.beforeEdit, this, true); 
    this.on('columnresize', this.onColumnResize, this, true); 
};
YAHOO.extendX(YAHOO.ext.grid.PropsGrid, YAHOO.ext.grid.EditorGrid, {
    onCellClick : function(grid, rowIndex, colIndex, e){
        if(colIndex == 0){
            this.startEditing(rowIndex, 1);
        }
    },
    
    render : function(){
        YAHOO.ext.grid.PropsGrid.superclass.render.call(this);
        this.getView().fitColumnsToContainer();
    },
    
    autoSize : function(){
        YAHOO.ext.grid.PropsGrid.superclass.autoSize.call(this);
        this.getView().fitColumnsToContainer();
    },
    
    onColumnResize : function(){
        this.colModel.setColumnWidth(1, this.getView().wrap.clientWidth - this.colModel.getColumnWidth(0));
    },
    
    beforeEdit : function(grid, rowIndex, colIndex){
        if(this.lastEditRow && rowIndex != this.lastEditRow.rowIndex){
            YAHOO.util.Dom.removeClass(this.lastEditRow, 'ygrid-prop-edting');
        }
        this.lastEditRow = this.getRow(rowIndex);
        YAHOO.util.Dom.addClass(this.lastEditRow, 'ygrid-prop-edting');
    },
    
    setSource : function(source){
        this.dataModel.setSource(source);
    },
    
    getSource : function(){
        return this.dataModel.getSource();
    }
});