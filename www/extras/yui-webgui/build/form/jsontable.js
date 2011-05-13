
// Initialize namespace
if (typeof WebGUI == "undefined") {
    var WebGUI = {};
}
if (typeof WebGUI.Form == "undefined") {
    WebGUI.Form = {};
}

/****************************************************************************
 * WebGUI.Form.JsonTable( fieldName, tableId, columns )
 * Create a JsonTable object. 
 *
 * fieldName holds the current JSON-encoded array of hashrefs of values. 
 *
 * tableId is where to put the rows and add all the events. 
 *
 * columns is an array of hashes of column data with the following keys:
 *      type        -- The type of column, one of "text", "select", 
 *                      "id", "hidden", "readonly"
 *      name        -- The name of the column
 *      label       -- The label of the column
 *      options     -- select only. An array of name, label of options.
 *
 */
WebGUI.Form.JsonTable 
= function ( fieldName, tableId, columns ) {
    this.fieldName  = fieldName;
    this.tableId    = tableId;
    this.columns    = columns;
    this.table      = document.getElementById( this.tableId );
    this.tbody      = this.table.getElementsByTagName( "tbody" )[0];

    // Find the form
    this.form       = this.table;
    while ( this.form.nodeName != "FORM" ) {
        this.form   = this.form.parentNode;
    }

    this.field      = this.form.elements[ this.fieldName ];
    this.json       = this.field.value;
    this.newRow     = YAHOO.util.Dom.getElementsByClassName( "new_row", "tr", this.table )[0];

    try {
        this.data       = YAHOO.lang.JSON.parse( this.json );
    }
    catch (err) {
        this.data       = [];
    }

    // Add submit listener to update JSON
    YAHOO.util.Event.addListener( this.form, "submit", this.update, this, true );

    this.addButton  = this.table.getElementsByTagName( "button" )[0];
    YAHOO.util.Event.addListener( this.addButton, "click",
        function(e) { 
            this.addRow();
            e.preventDefault();
            return false;
        },
        this, true
    );
    this.i18n
    = new WebGUI.i18n( { 
            namespaces  : {
                'WebGUI' : [
                    "576",
                    "Up",
                    "Down"
                ]
            },
            onpreload   : {
                fn       : WebGUI.Form.JsonTable.prototype.init,
                obj      : this,
                override : true
            }
        } );

    return this;
};

/****************************************************************************
 * addActions( row )
 * Add the row actions to the given row
 * Delay creating this so that the i18n object exists
 */
WebGUI.Form.JsonTable.prototype.addActions
= function (row) {
    // Add row actions
    var buttonCell      = row.lastChild;
    var deleteButton    = document.createElement('input');
    deleteButton.type   = "button";
    deleteButton.value  = this.i18n.get('WebGUI', '576');
    YAHOO.util.Event.addListener( deleteButton, "click", 
        function (e) {
            this.deleteRow( row );
        },
        this, true
    );
    buttonCell.appendChild( deleteButton );

    var moveUpButton    = document.createElement('input');
    moveUpButton.type   = "button";
    moveUpButton.value  = this.i18n.get('WebGUI', 'Up');
    YAHOO.util.Event.addListener( moveUpButton, "click", 
        function (e) {
            this.moveRowUp( row );
        },
        this, true
    );
    buttonCell.appendChild( moveUpButton );

    var moveDownButton      = document.createElement('input');
    moveDownButton.type     = "button";
    moveDownButton.value    = this.i18n.get('WebGUI', 'Down');
    YAHOO.util.Event.addListener( moveDownButton, "click", 
        function (e) {
            this.moveRowDown( row );
        },
        this, true
    );
    buttonCell.appendChild( moveDownButton );
};

/****************************************************************************
 * addRow ( )
 * Add a new row to the bottom of the table
 */
WebGUI.Form.JsonTable.prototype.addRow
= function () {
    var newRow  = this.newRow.cloneNode(true);
    this.tbody.appendChild( newRow );
    newRow.className        = "";
    newRow.style.display    = "table-row";
    this.addActions( newRow );
    return newRow;
};

/****************************************************************************
 * deleteRow( row )
 * Delete the row from the table
 */
WebGUI.Form.JsonTable.prototype.deleteRow
= function ( row ) {
    row.parentNode.removeChild( row );
};

/****************************************************************************
 * init ( )
 * Initialize the JsonTable by adding rows for every datum
 */
WebGUI.Form.JsonTable.prototype.init
= function () {
    for ( var row in this.data ) {
        // Copy new_row
        var newRow  = this.addRow();

        // Fill in values based on field type
        var cells   = newRow.getElementsByTagName( "td" );
        for ( var i = 0; i < this.columns.length; i++ ) { // Last cell is for buttons
            var cell        = cells[i];
            var column      = this.columns[i];
            var field       = cell.childNodes[0];
            var value       = this.data[row][column.name] || '';
            if ( column.type == "text" || column.type == "id"
                || column.type == "hidden" ) {
                field.value = value;
            }
            else if ( column.type == "select" ) {
                for ( var x = 0; x < field.options.length; x++ ) {
                    if ( field.options[x].value == value ) {
                        field.options[x].selected = true;
                    }
                }
            }
            else { // "readonly" or unknown
                cell.appendChild( document.createTextNode( value ) );
            }
        }
    }

};

/****************************************************************************
 * moveRowDown( row )
 * Move the row down in the table
 */
WebGUI.Form.JsonTable.prototype.moveRowDown
= function ( row ) {
    var after  = row.nextSibling;
    if ( after ) {
        row.parentNode.insertBefore( after, row );
    }
};

/****************************************************************************
 * moveRowUp( row )
 * Move the row up in the table
 */
WebGUI.Form.JsonTable.prototype.moveRowUp
= function ( row ) {
    var before  = row.previousSibling;
    if ( before && before.className != "new_row" ) {
        row.parentNode.insertBefore( row, before );
    }
};

/****************************************************************************
 * update (  )
 * Update the value in our field with the correct JSON
 */
WebGUI.Form.JsonTable.prototype.update
= function (e) {
    var rows    = this.tbody.getElementsByTagName( 'tr' );
    var data    = [];
    for ( var i = 1; i < rows.length; i++ ) {
        var cells   = rows[i].getElementsByTagName( 'td' );
        var rowData = {};
        for ( var x = 0; x < this.columns.length; x++ ) {
            var cell    = cells[x];
            var column  = this.columns[x];
            var field   = cell.childNodes[0];
            if ( field.nodeName == "INPUT" ) {
                rowData[ column.name ] = field.value;
            }
            else if ( field.nodeName == "SELECT" ) {
                var value   = field.options[ field.selectedIndex ].value;
                rowData[ column.name ] = field.value;
            }
        }
        data.push( rowData );
    }
    this.field.value = YAHOO.lang.JSON.stringify( data );
};
