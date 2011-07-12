/*global WebGUI*/
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
     * editorByFormat ( event, data )
     * Return the DataTable editor type that matches the given format
     */
    this.editorByFormat
    = function ( format ) {
        switch( format ) {
        case "text":
        case "number":
        case "link":
            return "textbox";
        }
        return format;
    };

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
                data[ columns[ i ].key ] = columns[i].formatter == "date" ? new Date() : "";
            }
        }
        this.dataTable.addRow( data );
    };

    /************************************************************************
     * deleteSelectedRows ( )
     * Delete the selected rows after confirming
     * If there is an editor in the deleted row, cancel it
     */
    this.deleteSelectedRows 
    = function ( ) {
        if ( confirm( this.i18n.get( "Form_DataTable", "delete confirm" ) ) ) {
            var rows    = this.dataTable.getSelectedRows();

            // Cancel editor if present
            if ( this.dataTable.getCellEditor() ) {
                    this.dataTable.cancelCellEditor();
            }

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
        for ( i = 0; i < cols.length; i++ ) {
            data.columns[ i ] = cols[i];
            delete data.columns[ i ].editor;
            delete data.columns[ i ].editorOptions;
        }

        return YAHOO.lang.JSON.stringify( data );
    };

    /************************************************************************
     * handleEditorKeyEvent ( obj )
     * Handle a keypress when the Cell Editor is open
     * Not implemented: Enter will close the editor and move down
     * Tab will close the editor and move right.
     * Open a new cell editor on the newly focused cell
     */
    this.handleEditorKeyEvent
    = function ( obj ) {
        // 9 = tab, 13 = enter
        var e   = obj.event;

        // Avoid terminating the editor on enter
        if ( e.keyCode == 13) {
            return false;
        }

        if ( e.keyCode == 9) {
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
     * Note: it doesn't currently work: getSelectedTdEls() always returns [] when selectionMode is "standard"
     * Commented out for now.
     */
/*
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
*/

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

        var dataTableOptions    = { 
            dateOptions : {
                format :        this.options.dateFormat,
                MSG_LOADING :   this.i18n.get( "WebGUI", "Loading..." ),
                MSG_ERROR :     this.i18n.get( "Form_DataTable", "data error" ),
                MSG_SORTASC :   this.i18n.get( "Form_DataTable", "sort ascending" ),
                MSG_SORTDESC :  this.i18n.get( "Form_DataTable", "sort descending" )
            }
        };

        if ( this.options.showEdit ) {
            dataTableOptions.draggableColumns   = true;
        }
        if ( this.options.ajaxDataUrl ) {
            dataTableOptions.initialLoad        = true;
            dataTableOptions.initialRequest     = "";
        }

        for ( var i = 0; i < this.columns.length; i++ ) {
            this.columns[ i ].editor = this.editorByFormat( this.columns[ i ].formatter );
        }

        var widget      = YAHOO.widget,
            DT          = widget.DataTable;

        // Dynamically add HTMLarea field type
        // HTMLAreaCellEditor is like TextareaCellEditor, but with an additional property "htmlarea" which is true
        var HTMLAreaCellEditor = function(a) {
            widget.TextareaCellEditor.superclass.constructor.call(this, a);
        };
        YAHOO.lang.extend( HTMLAreaCellEditor, widget.TextareaCellEditor, {
            htmlarea : true
        } );
        // Extend the static arrays of editors and formatters
        DT.Editors[ "htmlarea" ] = HTMLAreaCellEditor;

        // Define classes "wg-dt-textarea" and "wg-dt-htmlarea" that can be overided by a stylesheet
        // (e.g. in the extraHeadTags of the asset).
        var formatter = function ( type ) {
            var fmt = function( el, oRecord, oColumn, oData ) {
                var value = YAHOO.lang.isValue(oData) ? oData : "";
                el.innerHTML = "<div class='wg-dt-" + type + "'>" + value + "</div>";
            };
            return fmt;
        };
        DT.Formatter[ "textarea" ] = formatter( "textarea" );
        DT.Formatter[ "htmlarea" ] = formatter( "htmlarea" );

        // XXX need to do it with YUI API
        widget.BaseCellEditor.prototype.LABEL_SAVE   = this.i18n.get( "Form_DataTable", "save" );
        widget.BaseCellEditor.prototype.LABEL_CANCEL = this.i18n.get( "Form_DataTable", "cancel" );

        this.dataTable = new YAHOO.widget.DataTable(
            this.containerId,
            this.columns,
            this.dataSource,
            dataTableOptions
        );

        if ( this.options.showEdit ) {
            var tinymceEdit = "tinymce-edit";
            var saveThis = this;

            this.dataTable.doBeforeShowCellEditor = function( oCellEditor ) {
                if ( !oCellEditor.htmlarea ) {
                    return true;
                }

                oCellEditor.getInputValue = function() {
                    return tinyMCE.activeEditor.getContent();
                };

                oCellEditor.textarea.setAttribute( 'id', tinymceEdit );
                tinyMCE.execCommand( 'mceAddControl', false, tinymceEdit );
                setTimeout(function(){ tinyMCE.execCommand( 'mceFocus',false, tinymceEdit ); }, 0);

                // watch hitting tab, which should save the current cell and open an editor on the next
                tinyMCE.activeEditor.onKeyDown.add(
                    function( eh, t ) {
                        return function(ed, e) {    // ed unused
                            eh.call( t, { event: e } );
                        };
                    }( saveThis.handleEditorKeyEvent, saveThis )
                );

                return true;
            };

            // Remove TinyMCE on save or cancel
            var mceRemoveControl = function ( oArgs ) {
                var oCellEditor = oArgs.editor;
                if ( oCellEditor.htmlarea ) {
                    tinyMCE.execCommand( 'mceRemoveControl', false, tinymceEdit );
                    oCellEditor.textarea.removeAttribute( 'id' );
                }
            };
            this.dataTable.subscribe( "editorSaveEvent", mceRemoveControl );
            this.dataTable.subscribe( "editorCancelEvent", mceRemoveControl );

            // Add the class so our editors get the right skin
            YAHOO.util.Dom.addClass( document.body, "yui-skin-sam" );

            this.dataTable.subscribe( "cellDblclickEvent", this.dataTable.onEventShowCellEditor ); 
            this.dataTable.subscribe( "rowClickEvent", this.dataTable.onEventSelectRow );
	    /* this.handleTableKeyEvent() is commented out, see there for the reason */
            /* this.dataTable.subscribe( "tableKeyEvent", this.handleTableKeyEvent, this, true ); */
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
                    "format textarea",
                    "format htmlarea",
                    "add column",
                    "cancel",
                    "ok",
                    "save success",
                    "save failure",
                    "help edit cell",
                    "help select row",
                    "help add row",
                    "help default sort",
                    "help reorder column",
                    "data error",
                    "sort ascending",
                    "sort descending"
                ],
                'WebGUI' : [
                    "Loading..."
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
                zIndex      : 10000
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
        var availableFormats = [];
        var formatType = [ "text", "number", "email", "link", "date", "textarea", "htmlarea" ];
        for ( var fti = 0; fti < formatType.length; fti++) {
            availableFormats.push(
                {
                    "value" : formatType[fti],
                    "label" : this.i18n.get( "Form_DataTable", "format " + formatType[fti] )
                }
             );
        }
        
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
                var selected = cols[i].formatter == availableFormats[x].value;
                var opt = new Option(
                    availableFormats[x].label, 
                    availableFormats[x].value,
                    selected,
                    selected
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
            col         = this.dataTable.getColumn( oldKey );

            // Don't allow adding multiple columns with same key
            if ( oldKey != newKey && this.dataTable.getColumn( newKey ) ) {
                // TODO: Log an error
                i++;
                continue;
            }

            // If the key has changed, update the row data
            if ( col && col.key != newKey ) {
                var rows    = this.dataTable.getRecordSet().getRecords();
                for ( var r = 0; r < rows.length; r++ ) {
                    rows[ r ].setData( newKey, rows[ r ].getData( oldKey ) );
                    rows[ r ].setData( oldKey, undefined );
                }
            }

            // Change the column info
            var newCol  = {
                key         : newKey,
                formatter   : format,
                resizeable  : ( col ? col.resizeable : 1 ),
                sortable    : ( col ? col.sortable : 1 ),
                editor      : this.editorByFormat( format )
            };
            if ( format == "date" ) {
                newCol["dateOptions"] = { format : this.options.dateFormat };
            }
            var newIndex    = col ? col.getKeyIndex() : undefined;

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
            else {
                //Set data in the new column to useful defaults.
                var allRecords = this.dataTable.getRecordSet().getRecords();
                var numRecords = allRecords.length;
                for (j=0; j < numRecords; j++) {
                    if (format == "date") {
                        allRecords[j].setData(newKey, new Date());
                    } else {
                        allRecords[j].setData(newKey, '');
                    }
                }
            }

            i++;
        }
        this.dataTable.render();
        this.schemaDialog.cancel();
    };

};
