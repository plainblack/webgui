
// Initialize namespace
if (typeof WebGUI == "undefined") {
    var WebGUI = {};
}
if (typeof WebGUI.Form == "undefined") {
    WebGUI.Form = {};
}


/**
 * This object contains scripts for the DataTable form control
 */

/****************************************************************************
 * DataTable ( containerId, columns, options )
 * Initialize a WebGUI.Form.DataTable.
 * containerId is the ID of the container for the table. It is assumed the data
 *   is already in a table inside of the container (progressive enhancement).
 * columns is an array of definitions for YAHOO.widget.Column objects
 * rows is an array of key/value pairs
 * options is an object literal of options with the following keys
 *      ajaxDataUrl     : The URL to get data from
 *      ajaxSaveUrl     : The URL to save data to
 *      ajaxSaveFunc    : The ?func= to save data to
 *      ajaxSaveExtras  : Any extra name=value pairs necessary to save the data
 *      inputName       : The name of the DataTable when editing the data
 *      showEdit        : Show the edit controls and allow inline editing of values
 *      
 */
WebGUI.Form.DataTable 
= function ( containerId, columns, options ) {
    this.containerId            = containerId;
    this.columns                = columns;
    this.dataSource             = undefined;    
    this.dataTable              = undefined;
    this.form                   = undefined;
    this.options                = options;
    this.schemaDialog           = undefined;

    /************************************************************************
     * addRow ( event, data )
     * Add a row to the bottom of the table
     */
    this.addRow
    = function ( event, data ) {
        if ( !data ) {
            // Make a blank row
            data        = {};
            var columns = this.dataTable.getColumnSet().getDefinitions();
            for ( var i = 0; i < columns.length; i++ ) {
                data[ columns[ i ].key ] = "";
            }
        }
        this.dataTable.addRow( data );
    };

    /************************************************************************
     * deleteSelectedRows ( )
     * Delete the selected rows after confirming
     */
    this.deleteSelectedRows 
    = function ( ) {
        if ( confirm( this.i18n.get( "Form_DataTable", "delete confirm" ) ) ) {
            var rows    = this.dataTable.getSelectedRows();
            for ( var i = 0; i < rows.length; i++ ) {
                this.dataTable.deleteRow( this.dataTable.getRecord( rows[i] ) );
            }
        }
    };

    /************************************************************************
     * getJson ( )
     * Get the JSON data structure for the current state of the datatable
     */
    this.getJson
    = function () {
        var data    = { rows : [], columns : [] };
        
        // Get the rows
        var rows    = this.dataTable.getRecordSet().getRecords();
        for ( var i = 0; i < rows.length; i++ ) {
            data.rows[ i ] = rows[i].getData();
        }
        
        // Get the columns
        var cols    = this.dataTable.getColumnSet().getDefinitions();
        for ( var i = 0; i < cols.length; i++ ) {
            data.columns[ i ] = cols[i];
            delete data.columns[ i ].editor;
            delete data.columns[ i ].editorOptions;
        }

        YAHOO.lang.JSON.dateToString = function(d) { return d.toString(); }; /* this overrides the default stringify date format */
        return YAHOO.lang.JSON.stringify( data );
    };

    /************************************************************************
     * handleEditorKeyEvent ( obj )
     * Handle a keypress when the Cell Editor is open
     * Enter will close the editor and move down
     * Tab will close the editor and move right.
     * Use the handleTableKeyEvent() to handle the moving
     * Open a new cell editor on the newly focused cell
     */
    this.handleEditorKeyEvent
    = function ( obj ) {
        // 9 = tab, 13 = enter
        var e   = obj.event;
        if ( e.keyCode == 9 || e.keyCode == 13 ) {
            var cell        = this.dataTable.getCellEditor().getTdEl();
            var nextCell    = this.dataTable.getNextTdEl( cell );
            this.dataTable.saveCellEditor();
            if ( nextCell ) {
                this.dataTable.showCellEditor( nextCell );
                e.returnValue   = false;
                e.preventDefault();
                return false;
            }
            else {
                // No next cell, make a new row and open the editor for that one
                this.dataTable.addRow( {} );
            }
            // BUG: If pressing Enter, editor gets hidden right away due to YUI default event
            // putting e.preventDefault() and return false here makes no difference
        }
    };
    
    /************************************************************************
     * handleEditorShowEvent ( editor )
     * Give the focus to the editor
     */
    this.handleEditorShowEvent
    = function ( obj ) {
        /* If we set the focus now, something might (and sometimes does) set
         * it later in the event handling chain.  Let's defer the focus set
         * until this chain is finished. */
        setTimeout(function() { obj.editor.focus(); }, 0);
    };

    /************************************************************************
     * handleRowAdd ( )
     * Open the cell editor for the newly-added row
     */
    this.handleRowAdd 
    = function () { 
        var row = this.dataTable.getLastTrEl();
        this.dataTable.showCellEditor( row.firstChild );
    };

    /************************************************************************
     * handleTableKeyEvent ( obj )
     * Handle a keypress inside the DataTable
     * Space will open the cell editor
     */
    this.handleTableKeyEvent 
    = function ( obj ) {
        // 9 = tab, 13 = enter, 32 = space
        var e   = obj.event;
        if ( e.keyCode == 32 ) {
            var cell    = this.dataTable.getSelectedTdEls()[0];
            if ( cell ) {
                this.dataTable.showCellEditor(cell);
            }
        }
    };

    /************************************************************************ 
     * hideSchemaDialog ( )
     * Hide the schema dialog without saving changed
     */
    this.hideSchemaDialog
    = function () {
        this.schemaDialog.cancel();
    };

    /************************************************************************
     * initDataTable
     * Initialize the data table. Called automatically when the DOM is ready
     */
    this.initDataTable
    = function () {
        var container   = document.getElementById( this.containerId );

        // If we have an ajax datasource
        if ( this.options.ajaxDataUrl ) {
            this.dataSource
                = new YAHOO.util.DataSource( this.options.ajaxDataUrl );
            this.dataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
            this.dataSource.responseSchema = {
                resultsList : "rows",
                fields : this.columns
            };
        }
        else {
            // Initialize a datasource with the table 
            this.dataSource 
                = new YAHOO.util.DataSource( YAHOO.util.Dom.get( this.containerId + "-table" ) );
            this.dataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE;
            this.dataSource.responseSchema = {
                fields : this.columns
            };
            YAHOO.util.Dom.get( this.containerId + "-table" ).style.display = "none";
        }

        var dataTableOptions    = { };
        if ( this.options.showEdit ) {
            dataTableOptions.draggableColumns   = true;
        }
        if ( this.options.ajaxDataUrl ) {
            dataTableOptions.initialLoad        = true;
            dataTableOptions.initialRequest     = "";
        }

        this.dataTable = new YAHOO.widget.DataTable(
            this.containerId,
            this.columns,
            this.dataSource,
            dataTableOptions
        );

        if ( this.options.showEdit ) {
            // Add the class so our editors get the right skin
            YAHOO.util.Dom.addClass( document.body, "yui-skin-sam" );

            this.dataTable.subscribe( "cellDblclickEvent", this.dataTable.onEventShowCellEditor ); 
            this.dataTable.subscribe( "rowClickEvent", this.dataTable.onEventSelectRow );
            this.dataTable.subscribe( "tableKeyEvent", this.handleTableKeyEvent, this, true );
            this.dataTable.subscribe( "editorKeydownEvent", this.handleEditorKeyEvent, this, true );
            this.dataTable.subscribe( "editorShowEvent", this.handleEditorShowEvent, this, true );
            this.dataTable.subscribe( "rowAddEvent", this.handleRowAdd, this, true );

            // Add the Help button
            var help        = new YAHOO.widget.Button( {
                id          : "help",
                type        : "push",
                label       : this.i18n.get( "Form_DataTable", "help" ),
                container   : this.containerId,
                onclick     : {
                    fn          : this.showHelp,
                    scope       : this
                }
            });
            help.setStyle( "float", "left" );

            // Add the Edit Schema button
            var editSchema  = new YAHOO.widget.Button( {
                id          : "editSchema",
                type        : "push",
                label       : this.i18n.get( "Form_DataTable", "edit schema" ),
                container   : this.containerId,
                onclick     : {
                    fn          : this.showSchemaDialog,
                    scope       : this
                }
            } );
            editSchema.setStyle( "float", "right" );

            // Add the Add Row and Delete Row buttons
            var addRow      = new YAHOO.widget.Button( {
                id          : "addRow",
                type        : "push",
                label       : this.i18n.get( "Form_DataTable", "add row" ),
                container   : this.containerId,
                onclick     : {
                    fn          : this.addRow,
                    scope       : this
                }
            } );

            var deleteRow   = new YAHOO.widget.Button( {
                id          : "deleteRow",
                type        : "push",
                label       : this.i18n.get( "Form_DataTable", "delete rows" ),
                container   : this.containerId,
                onclick     : {
                    fn          : this.deleteSelectedRows,
                    scope       : this
                }
            } );
            
            // This data table will be submitted async
            if ( this.options.ajaxSaveUrl ) {
                var save        = new YAHOO.widget.Button( {
                    id          : "saveTable",
                    type        : "push",
                    label       : this.i18n.get( "Form_DataTable", "save" ),
                    container   : this.containerId,
                    onclick     : {
                        fn          : this.submitToAjax,
                        scope       : this
                    }
                } );
            }
            
            // This data table will be submitted with a form
            if ( this.options.inputName && !this.options.ajaxSaveUrl ) {
                // Find our form
                var form    = document.getElementById( this.containerId );
                while ( form.nodeName != "FORM" ) {
                    form    = form.parentNode;
                }
                this.form   = form;

                // When form is submitted, compile the JSON
                YAHOO.util.Event.addListener( form, "submit", this.submitToForm, this, true );
            }
        }
    };

    /************************************************************************
     * initI18N ( )
     * Initialize the I18N that we need. Then initialize the datatable.
     */
    this.initI18N 
    = function ( ) {
        this.i18n   = new WebGUI.i18n( { 
            namespaces  : {
                'Form_DataTable' : [
                    "topicName",
                    "save",
                    "delete rows",
                    "add row",
                    "help",
                    "edit schema",
                    "delete confirm",
                    "delete column",
                    "format text",
                    "format email",
                    "format link",
                    "format number",
                    "format date",
                    "add column",
                    "cancel",
                    "ok",
                    "save success",
                    "save failure",
                    "help edit cell",
                    "help select row",
                    "help add row",
                    "help default sort",
                    "help reorder column"
                ]
            },
            onpreload   : {
                fn          : this.initDataTable,
                obj         : this,
                override    : true
            }
        } );
    };
    // Run this automatically
    YAHOO.util.Event.onContentReady( this.containerId, this.initI18N, undefined, this );

    /************************************************************************
     * showHelp ( event )
     * Show the help dialog, creating it if necessary
     */
    this.showHelp 
    = function ( e ) {
        if ( !this.helpDialog ) {
            var helpDialog  = new YAHOO.widget.Panel( "helpWindow", {
                modal       : false,
                draggable   : true,
                zIndex      : 1000
            } );
            helpDialog.setHeader( "DataTable Help" );
            helpDialog.setBody( 
                  "<ul>"
                + "<li>" + this.i18n.get( "Form_DataTable", "help edit cell" ) + "</li>"
                + "<li>" + this.i18n.get( "Form_DataTable", "help select row" ) + "</li>"
                + "<li>" + this.i18n.get( "Form_DataTable", "help add row" ) + "</li>"
                + "<li>" + this.i18n.get( "Form_DataTable", "help default sort" ) + "</li>"
                + "<li>" + this.i18n.get( "Form_DataTable", "help reorder column" ) + "</li>"
                + "</ul>"
            );
            helpDialog.render( document.body );
            this.helpDialog = helpDialog;
        }
        this.helpDialog.show();
    };

    /************************************************************************
     * showSchemaDialog ( event )
     * Show the Edit Schema YUI Dialog. Markup is in WebGUI::Form::DataTable
     */
    this.showSchemaDialog
    = function ( e ) {
        
        // Function to remove a column
        var removeColumn = function ( e, colId ) {
            var form    = this.element.getElementsByTagName( "form" )[0];
            // Add to deleteCols
            var deleteCols  = YAHOO.lang.JSON.parse( form.elements[ "deleteCols" ].value );
            deleteCols.push( form.elements[ "oldKey_" + colId ].value );
            form.elements[ "deleteCols" ].value 
                = YAHOO.lang.JSON.stringify( deleteCols );
            // Remove column from dialog
            var div = document.getElementById( "col_" + colId );
            div.parentNode.removeChild( div );
        };

        var buttonLabel = this.i18n.get( "Form_DataTable", "delete column" );
        var availableFormats    = [
            {
                "value" : "text",
                "label" : this.i18n.get( "Form_DataTable", "format text" )
            },
            {
                "value" : "number",
                "label" : this.i18n.get( "Form_DataTable", "format number" )
            },
            {
                "value" : "email",
                "label" : this.i18n.get( "Form_DataTable", "format email" )
            },
            {
                "value" : "link",
                "label" : this.i18n.get( "Form_DataTable", "format link" )
            },
            {
                "value" : "date",
                "label" : this.i18n.get( "Form_DataTable", "format date" )
            }
        ];
        
        // function for creating new database columns to the table schema
        var createTableColumn = function(i,cols) {
            var div = document.createElement( 'div' );
            div.className   = "yui-skin-sam";
            div.id          = "col_" + i;

            var del     = new YAHOO.widget.Button( {
                    type        : "push",
                    label       : buttonLabel,
                    container   : div,
                    onclick     : {
                        fn          : removeColumn,
                        obj         : i,
                        scope       : dg
                    }
            } );

            var oldKey  = document.createElement( "input" );
            oldKey.type     = "hidden";
            oldKey.name     = "oldKey_" + i;
            oldKey.value    = cols[i].key;
            div.appendChild( oldKey );

            var newKey  = document.createElement( "input" );
            newKey.type     = "text";
            newKey.name     = "newKey_" + i;
            newKey.value    = cols[i].key;
            div.appendChild( newKey );

            var format  = document.createElement('select');
            format.name             = "format_" + i;

            for ( var x = 0; x < availableFormats.length; x++ ) {
                var opt = new Option(
                    availableFormats[x].label, 
                    availableFormats[x].value,
                    cols[i].formatter == availableFormats[x].value
                );
                format.appendChild( opt );
            }
            div.appendChild( format );
            return div;
        };
       
        // Function to add a column
        var addColumn   = function ( e, cols ) {
            // this is the body of the dialog box

            // Find the last indexed column
            var newIdx  = cols.length;
            // create a new column object
            cols[newIdx] = new YAHOO.widget.Column();
            // add it to the dialog box
            this.appendChild( createTableColumn(newIdx,cols) );
        };

        var dg  = new YAHOO.widget.Dialog( "editSchemaDialog", {
            modal           : true,
            fixedcenter     : true
        });
        dg.setHeader( this.i18n.get( "Form_DataTable", "edit schema" ) );

        var cols    = this.dataTable.getColumnSet().keys;
        var body    = document.createElement( 'form' );
        for ( var i = 0; i < cols.length; i++ ) {
            body.appendChild( createTableColumn(i,cols) );
        }

        // Columns to delete
        var deleteCols = document.createElement( "input" );
        deleteCols.type = "hidden";
        deleteCols.name = "deleteCols";
        deleteCols.value = "[]";
        body.appendChild( deleteCols );

        dg.setBody( body );
        
        dg.cfg.queueProperty( "buttons", [ 
            { text: this.i18n.get( "Form_DataTable", "add column" ), handler: { fn : addColumn, obj : cols, scope : body } },
            { text: this.i18n.get( "Form_DataTable", "cancel" ), handler: { fn: this.hideSchemaDialog, scope: this } },
            { text: this.i18n.get( "Form_DataTable", "save" ), handler: { fn: this.updateSchema, scope: this }, isDefault: true }
        ] );
        dg.render( document.body );
        this.schemaDialog   = dg;
    };



    /************************************************************************
     * submitToAjax ( event )
     * Save the data table to the AJAX URL
     */
    this.submitToAjax
    = function ( e ) {
        if ( this.options.ajaxSaveUrl ) {
            var callback    = {
                success : function ( o ) {
                    var dialog = new YAHOO.widget.Panel( "savedMessage", {
                        modal       : true,
                        fixedcenter : true
                    } );
                    dialog.setBody( this.i18n.get( "Form_DataTable", "save success" ) + "<br/>" );
                    var button = new YAHOO.widget.Button( {
                        id          : "ok",
                        type        : "push",
                        label       : this.i18n.get( "Form_DataTable", "ok" ),
                        container   : dialog.body,
                        onclick     : {
                            fn          : function () { this.destroy(); },
                            scope       : dialog
                        }
                    } );
                    dialog.render( document.body );
                },
                failure : function ( o ) {
                    var dialog = new YAHOO.widget.Panel( el, {
                        modal       : true,
                        fixedcenter : true
                    } );
                    dialog.setBody( this.i18n.get( "Form_DataTable", "save failure" ) + "<br/>" );
                    var button = new YAHOO.widget.Button( {
                        id          : "ok",
                        type        : "push",
                        label       : this.i18n.get( "Form_DataTable", "ok" ),
                        container   : dialog.body,
                        onclick     : {
                            fn          : function () { this.destroy(); },
                            scope       : dialog
                        }
                    } );
                    dialog.render( document.body );
                },
                scope : this
            };
            
            var data        = this.getJson();
            var postdata    = "func=" + this.options.ajaxSaveFunc + ";" 
                            + this.options.ajaxSaveExtras + ";" 
                            + this.options.inputName + "=" + escape( data )
                            ;

            YAHOO.util.Connect.asyncRequest(
                "POST",
                this.options.ajaxSaveUrl,
                callback,
                postdata
            );
        }
    };

    /************************************************************************
     * submitToForm ( event )
     * Compile the DataTable data into the right form element
     */
     this.submitToForm
     = function (e) { 
        var elem    = this.form.elements[ this.options.inputName ];
        elem.value  = this.getJson();
    }; 

    /************************************************************************ 
     * updateSchema callback
     */
    this.updateSchema
    = function () {
        var data        = this.schemaDialog.getData();
        
        // First delete columns
        var deleteCols  = YAHOO.lang.JSON.parse( data[ "deleteCols" ] );
        for ( var x = 0; x < deleteCols.length; x++ ) {
            var col = this.dataTable.getColumn( deleteCols[x] ); 
            this.dataTable.removeColumn( col );
        }

        // Update columns
        var i           = 0;
        while ( data[ "newKey_" + i ] ) {
            var oldKey  = data[ "oldKey_" + i ];
            var newKey  = data[ "newKey_" + i ];
            var format  = data[ "format_" + i ][0];
            var col     = this.dataTable.getColumn( oldKey );

            // Don't allow adding multiple columns with same key
            if ( oldKey != newKey && this.dataTable.getColumn( newKey ) ) {
                // TODO: Log an error
                i++;
                continue;
            }

            // If the key has changed, update the row data
            if ( col && col.key != newKey ) {
                var rows    = this.dataTable.getRecordSet().getRecords();
                for ( var i = 0; i < rows.length; i++ ) {
                    rows[ i ].setData( newKey, rows[ i ].getData( oldKey ) );
                    rows[ i ].setData( oldKey, undefined ); 
                }
            }

            // Change the column info
            var newCol  = {
                key         : newKey,
                formatter   : format,
                resizeable  : ( col ? col.resizeable : 1 ),
                sortable    : ( col ? col.sortable : 1 )
            };
            var newIndex    = col ? col.getKeyIndex() : undefined;

            // Set the editor
            if ( format == "date" ) {
                newCol.editor   = "date";
            }
            else {
                newCol.editor   = "textbox";
            }

            this.dataTable.insertColumn( newCol, newIndex );
            if ( col ) {
                // Get a new reference so we remove the right column
                var delCol;
                if ( oldKey == newKey ) {
                    delCol  = this.dataTable.getColumn( oldKey )[1];
                }
                else {
                    delCol  = this.dataTable.getColumn( oldKey );
                }
                this.dataTable.removeColumn( delCol );
            }
            i++;
        }

        this.dataTable.render();
        this.schemaDialog.cancel();
    };

};
