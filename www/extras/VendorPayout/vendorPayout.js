if (typeof WebGUI == "undefined" || !WebGUI) {
    var WebGUI = {};
}

WebGUI.VendorPayout = function ( containerId ) {
    var obj = this;
    this.container  = document.getElementById( containerId );

    this.i18nObj = new WebGUI.i18n( {
        namespaces : {
            'Shop' : [
                'schedule all button', 'deschedule all button', 'submit scheduled payouts button',
                'vendor id', 'vendor name', 'scheduled payout amount', 'not scheduled payout amount',
                'vp item id', 'vp item title', 'vp item price', 'vp item quantity', 'vp item payout amount', 
                'vp item payout status', 'vp select vendor', 'vp vendors', 'vp payouts'
            ]
        },
        onpreload : {
            fn       : this.initialize,
            obj      : this,
            override : true,
        }
    } );
    this.i18n = function ( key ) { 
        return this.i18nObj.get( 'Shop', key ) 
    };
                
    return this;
}

//----------------------------------------------------------------------------
WebGUI.VendorPayout.prototype.initialize = function (aaa, bbb,ccc,ddd) {
    // Vendor data table
    this.vendorTable    = document.createElement( 'div' );
    this.vendorButtons  = document.createElement( 'div' );

    var vendor          = document.createElement( 'fieldset' );
    var vendorLegend    = document.createElement( 'legend' );
    vendor.appendChild( vendorLegend        ).innerHTML = this.i18n( 'vp vendors' ); 
    vendor.appendChild( this.vendorTable    );
    vendor.appendChild( this.vendorButtons  );

    this.container.appendChild( vendor );
    
    // Payout data table
    this.payoutTable    = document.createElement( 'div' );
    this.payoutButtons  = document.createElement( 'div' );

    var payout          = document.createElement( 'fieldset' );
    var payoutLegend    = document.createElement( 'legend' );
    payout.appendChild( payoutLegend        ).innerHTML = this.i18n( 'vp payouts' );
    payout.appendChild( this.payoutTable    );
    payout.appendChild( this.payoutButtons  );

    this.container.appendChild( payout );

    // (De)schedule buttons
    this.scheduleAllPayoutsButton   = new YAHOO.widget.Button( { 
        label       : this.i18n( 'schedule all button' ),
        container   : this.payoutButtons,
        disabled    : true
    } );
    this.descheduleAllPayoutsButton = new YAHOO.widget.Button( { 
        label:      this.i18n( 'deschedule all button' ),
        container:  this.payoutButtons,
        disabled    : true
    } );
    this.scheduleAllVendorsButton   = new YAHOO.widget.Button( {
        label       : this.i18n( 'schedule all button' ),
        container   : this.vendorButtons
    } );
    this.descheduleAllVendorsButton = new YAHOO.widget.Button( {
        label       : this.i18n( 'deschedule all button' ),
        container   : this.vendorButtons
    } );

    // Submit button
    this.submitPayoutsButton    = new YAHOO.widget.Button({ label: this.i18n( 'submit scheduled payouts button' ), container: this.buttonDiv });
    this.submitPayoutsButton.on( 'click', function () { 
        YAHOO.util.Connect.asyncRequest( 'GET', '?shop=vendor;method=submitScheduledPayouts', { 
            success: obj.initialize, 
            scope: obj
        } );
    } ); 

    // Payout details data table
    this.payoutDetails  = document.createElement('div');
    this.container.appendChild( this.payoutDetails );

    this.itemBaseUrl = '?shop=vendor;method=payoutDataAsJSON;';

    this.initVendorList();
    this.initPayoutDetails();
    this.initButtons();
}

//----------------------------------------------------------------------------
WebGUI.VendorPayout.prototype.initVendorList = function () {
    var obj = this;
    this.vendorSchema = [
        { key: 'vendorId',  label : this.i18n( 'vendor id' ) },
        { key: 'name',      label : this.i18n( 'vendor name' ) },
        { key: 'Scheduled', label : this.i18n( 'scheduled payout amount' ) }, 
        { key: 'NotPaid',   label : this.i18n( 'not scheduled payout amount' ) }
    ];

    // setup data source
    var url = '?shop=vendor;method=vendorTotalsAsJSON;';
    this.vendorDataSource = new YAHOO.util.DataSource( url );
    this.vendorDataSource.responseType      = YAHOO.util.DataSource.TYPE_JSON;
    this.vendorDataSource.responseSchema    = {
        resultsList : 'vendors',
        fields : this.vendorSchema
    };

    // initialize data table
    this.vendorDataTable = new YAHOO.widget.DataTable( this.vendorTable, this.vendorSchema, this.vendorDataSource, {
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
        obj.currentVendorIndex  = this.getRecordIndex( record );

        obj.refreshItemDataTable();

        obj.scheduleAllPayoutsButton.set(   'disabled', false );
        obj.descheduleAllPayoutsButton.set( 'disabled', false );
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
WebGUI.VendorPayout.prototype.refreshVendorDataTable = function () {
    this.vendorDataSource.sendRequest( '', {
        success : this.vendorDataTable.onDataReturnUpdateRows, //ReplaceRows,
        scope   : this.vendorDataTable
    } );
}

//----------------------------------------------------------------------------
WebGUI.VendorPayout.prototype.refreshVendorRow = function () {
    var obj = this;
    this.vendorDataSource.sendRequest( 'vendorId=' + this.currentVendorId, {
        success : function ( req, response , payload ) { 
            this.updateRow( obj.currentVendorIndex, response.results[0] );
        },
        scope   : this.vendorDataTable
    } );
}

//----------------------------------------------------------------------------
WebGUI.VendorPayout.prototype.initPayoutDetails = function () {
    var obj = this;
    this.itemSchema = [
        { key: 'itemId',             label : this.i18n( 'vp item id' ) },
        { key: 'configuredTitle',    label : this.i18n( 'vp item title' ) },
        { key: 'price',              label : this.i18n( 'vp item price' ) }, 
        { key: 'quantity',           label : this.i18n( 'vp item quantity' ) }, 
        { key: 'vendorPayoutAmount', label : this.i18n( 'vp item payout amount' ) }, 
        { key: 'vendorPayoutStatus', label : this.i18n( 'vp item payout status' ) }
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
    this.itemDataTable = new YAHOO.widget.DataTable( this.payoutTable, this.itemSchema, this.itemDataSource, {
        dynamicData : true,
        formatRow   : rowFormatter,
        paginator   : new YAHOO.widget.Paginator({ rowsPerPage:10 } ),
        MSG_EMPTY   : this.i18n( 'vp select vendor' ) //, updateOnChange: true })
    } );
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
        var url = '?shop=vendor;method=setPayoutStatus' + ';itemId=' + record.getData( 'itemId' ) + ';status=' + status;
        YAHOO.util.Connect.asyncRequest( 'post', url, callback );
    } );  
}

//----------------------------------------------------------------------------
WebGUI.VendorPayout.prototype.initButtons = function () {
    var obj = this;

    var updateAll = function ( status, bulk ) {
        // TODO: Make this range based.
        var records = obj.itemDataTable.getRecordSet().getRecords();

        var postdata = 'shop=vendor&method=setPayoutStatus&status=' + status;
        
        if ( bulk ) {
            postdata += '&all=1';
        }
        else {
            var itemIds = new Array;
            for (i = 0; i < records.length; i++) {
                itemIds.push( 'itemId=' + records[i].getData( 'itemId' ) );
            }
            postdata += '&' + itemIds.join('&');
        }

        var callback = {
            success: function (o) {
                this.refreshItemDataTable();
                bulk ? this.refreshVendorDataTable() : this.refreshVendorRow();
            }, 
            scope: obj 
        };

        YAHOO.util.Connect.asyncRequest( 'POST', '/', callback, postdata );
    }

    this.scheduleAllVendorsButton.on(   'click', function () { updateAll( 'Scheduled',  true ) } );
    this.descheduleAllVendorsButton.on( 'click', function () { updateAll( 'NotPaid',    true ) } );   
    this.scheduleAllPayoutsButton.on(   'click', function () { updateAll( 'Scheduled'        ) } );
    this.descheduleAllPayoutsButton.on( 'click', function () { updateAll( 'NotPaid'          ) } );   
        
}

