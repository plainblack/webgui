if (typeof WebGUI == "undefined" || !WebGUI) {
    var WebGUI = {};
}

WebGUI.VendorPayout = function ( containerId ) {
    var obj = this;
    this.container  = document.getElementById( containerId );

    // Vendors data table
    this.vendorList = document.createElement('div');
    this.container.appendChild( this.vendorList );
    
    // (De)schedule buttons
    this.buttonDiv  = document.createElement('div');
    this.container.appendChild( this.buttonDiv );
    this.scheduleAllButton      = new YAHOO.widget.Button({ label: 'Schedule all',   container: this.buttonDiv });
    this.descheduleAllButton    = new YAHOO.widget.Button({ label: 'Deschedule all', container: this.buttonDiv });

    // Submit button
    this.submitPayoutsButton    = new YAHOO.widget.Button({ label: 'Submit Scheduled Payouts', container: this.buttonDiv });
    this.submitPayoutsButton.on( 'click', function () { 
        YAHOO.util.Connect.asyncRequest( 'GET', '/?shop=vendor;method=submitScheduledPayouts', { 
            success: obj.initialize, 
            scope: obj
        } );
    } ); 

    // Payout details data table
    this.payoutDetails  = document.createElement('div');
    this.container.appendChild( this.payoutDetails );


    this.itemBaseUrl = '/?shop=vendor;method=payoutDataAsJSON;';

    // Initialise tables
    this.initialize();

    return this;
}

//----------------------------------------------------------------------------
WebGUI.VendorPayout.prototype.initialize = function () {
    this.initVendorList();
    this.initPayoutDetails();
    this.initButtons();
}

//----------------------------------------------------------------------------
WebGUI.VendorPayout.prototype.initVendorList = function () {
    var obj = this;
    this.vendorSchema = [
        { key: 'vendorId'   },
        { key: 'name' },
        { key: 'Scheduled'  }, 
        { key: 'NotPaid'   }
    ];

    // setup data source
    var url = '/?shop=vendor;method=vendorTotalsAsJSON;';
    this.vendorDataSource = new YAHOO.util.DataSource( url );
    this.vendorDataSource.responseType      = YAHOO.util.DataSource.TYPE_JSON;
    this.vendorDataSource.responseSchema    = {
        resultsList : 'vendors',
        fields : this.vendorSchema
    };

    // initialize data table
    this.vendorDataTable = new YAHOO.widget.DataTable( this.vendorList, this.vendorSchema, this.vendorDataSource, {
        selectionMode : 'single'
    } );

    // add handlers for rowhighlighting/selection
    this.vendorDataTable.subscribe( "rowClickEvent",     this.vendorDataTable.onEventSelectRow      );
    this.vendorDataTable.subscribe( "rowMouseoverEvent", this.vendorDataTable.onEventHighlightRow   );
    this.vendorDataTable.subscribe( "rowMouseoutEvent",  this.vendorDataTable.onEventUnhighlightRow );

    // add an additional row click handler that fetches this vendor's data for the payout details table
    this.vendorDataTable.subscribe( "rowClickEvent", function (e) {
        var record  = this.getRecord( e.target );
        obj.currentVendorId     = record.getData( 'vendorId' );
        obj.currentVendorRow    = record;

        obj.refreshItemDataTable();
    } );
}

//----------------------------------------------------------------------------
WebGUI.VendorPayout.prototype.refreshItemDataTable = function () {
    // Set the url here so pagination keeps working...
    this.itemDataSource.liveData = this.itemBaseUrl + 'vendorId=' + this.currentVendorId +';';

    this.itemDataSource.sendRequest( '', {
        success : this.itemDataTable.onDataReturnInitializeTable, //ReplaceRows,
        scope   : this.itemDataTable
    } );
}

//----------------------------------------------------------------------------
WebGUI.VendorPayout.prototype.refreshVendorRow = function () {
    var obj = this;
    this.vendorDataSource.sendRequest( 'vendorId=' + this.currentVendorId, {
        // onDataReturnUpdateRows is not available in yui 2.6.0...
        success : function ( req, response , payload ) {
            this.updateRow( obj.currentVendorRow, response.results[0] );
        },
        scope   : this.vendorDataTable
    } );
}

//----------------------------------------------------------------------------
WebGUI.VendorPayout.prototype.initPayoutDetails = function () {
    var obj = this;
    this.itemSchema = [
        { key: 'itemId' },
        { key: 'configuredTitle' }, 
        { key: 'price' }, 
        { key: 'quantity' }, 
        { key: 'vendorPayoutAmount' }, 
        { key: 'vendorPayoutStatus' }
    ]

    // Create a row formatter to highlight Scheduled payouts
    var rowFormatter = function ( tr, record ) {
        if (record.getData('vendorPayoutStatus') === 'Scheduled') {
            YAHOO.util.Dom.addClass( tr, 'scheduled' );
        } 
        else {
            YAHOO.util.Dom.removeClass( tr, 'scheduled' );
        }

        return true;
    }

    // Instanciate the datasource.
    this.itemDataSource  = new YAHOO.util.DataSource( this.itemBaseUrl );
    this.itemDataSource.responseType    = YAHOO.util.DataSource.TYPE_JSON;
    this.itemDataSource.responseSchema  = {
        resultsList : 'results',
        fields      : this.itemSchema,
        metaFields  : { totalRecords : 'totalRecords' }
    };

    // Instanciate the DataTable.
    this.itemDataTable = new YAHOO.widget.DataTable( this.payoutDetails, this.itemSchema, this.itemDataSource, {
        dynamicData : true,
        formatRow   : rowFormatter,
        paginator   : new YAHOO.widget.Paginator({ rowsPerPage:10 } ) //, updateOnChange: true })
    });
    this.itemDataTable.handleDataReturnPayload = function(oRequest, oResponse, oPayload) { 
        // For some reason oPayload is undefined when we're switch vendors. This is a hack to
        // still set the paginator correctly.
        if ( !oPayload ) { 
            oPayload = this;
            var paginator = this.get('paginator');
            paginator.set( 'totalRecords', parseInt( oResponse.meta.totalRecords,10) );
        }
        oPayload.totalRecords = oResponse.meta.totalRecords; 
        return oPayload; 
    };

    // Add event handlers for mouseover highlighting
    this.itemDataTable.subscribe( "rowMouseoverEvent", this.itemDataTable.onEventHighlightRow   );
    this.itemDataTable.subscribe( "rowMouseoutEvent",  this.itemDataTable.onEventUnhighlightRow );
    
    // Add a row click handler which takes care of switching between Scheduled and NotPaid.
    this.itemDataTable.subscribe( "rowClickEvent", function (e) {
        var record      = this.getRecord( e.target );
        var callback    = {
            scope   : this,
            success : function ( o ) {
                var status = o.responseText;
                if ( status.match(/^error/) ) {
                    alert( status );
                    return;
                }
                
                // Update status cell contents
                this.updateCell( record, 'vendorPayoutStatus', status );

                // Update row higlighting
                rowFormatter( this.getTrEl( record ), record );

                // Update vendor row
                obj.refreshVendorRow();
            }
        };
    
        var status = record.getData( 'vendorPayoutStatus' ) === 'NotPaid' ? 'Scheduled' : 'NotPaid';
        var url = '/?shop=vendor;method=setPayoutStatus' + ';itemId=' + record.getData( 'itemId' ) + ';status=' + status;
        YAHOO.util.Connect.asyncRequest( 'post', url, callback );
    } );  
}

//----------------------------------------------------------------------------
WebGUI.VendorPayout.prototype.initButtons = function () {
    var obj = this;

    var updateAll = function ( status ) {
        // TODO: Make this range based.
        var records = obj.itemDataTable.getRecordSet().getRecords();
        var itemIds = new Array;
        for (i = 0; i < records.length; i++) {
            itemIds.push( 'itemId=' + records[i].getData( 'itemId' ) );
        }
        
        var postdata = itemIds.join('&');
        var url      = '/?shop=vendor&method=setPayoutStatus&status=' + status;
        var callback = {
            success: function (o) {
                this.refreshItemDataTable();
                this.refreshVendorRow();
            }, 
            scope: obj 
        };

        YAHOO.util.Connect.asyncRequest( 'POST', url, callback, postdata );
    }

    this.scheduleAllButton.on(   'click', function () { updateAll( 'Scheduled' ) } );
    this.descheduleAllButton.on( 'click', function () { updateAll( 'NotPaid'  ) } );   
        
}

