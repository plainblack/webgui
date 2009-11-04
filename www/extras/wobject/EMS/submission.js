
/*** The WebGUI EMS Submission system
 * Requires: YAHOO, Dom, Event, DataSource, DataTable, Paginator, Container
 *
 */

var DataSource = YAHOO.util.DataSource,
    DataTable  = YAHOO.widget.DataTable,
    Paginator  = YAHOO.widget.Paginator;

if ( typeof WebGUI == "undefined" ) {
    WebGUI  = {};
}

/*** WebGUI EMS Object
 *
 * This object renders the WebGUI EMS Submission datatable
 * 
 * @method WebGUI.EMS.constructor
 * @param configs {Object} object containing configuration necessary for creating the datatable.
TODO -- fix this to match what EMS really needs
 *      datasource        {String}     Required     URL that returns the JSON data structure of data to be displayed.
 *      container         {String}     Required     id of the HTML Element in which to render both the datatable and the pagination
 *      dtContainer       {String}     Required     id of the HTML Element in which to render the datatable
 *      view              {String}     Required     String which is passed to the ticket to properly return uses to the right view [all,my,search].
 *      fields            {ArrayRef}   Required     Array Reference of Objects used by the DataSource to configure and store data to be used by the data table
 *      columns           {ArrayRef}   Required     Array Reference of Objects which define the columns for the datatable to render
 *      p_containers      {ArrayRef}   Required     Array Reference containing the ids of the HTML Elements in which to render pagination.
 *      defaultSort       {Object}     Optional     Custom object which defines which column and direction the paginator should sort by
 *      initRequestString {String}     Optional     Parameters to append to the end of the url when initializing the datatable
 */


WebGUI.EMS = function (configs) {
    // Initialize configs
    this._configs = {};    
    if(configs) {
        this._configs = configs;
	WebGUI.EMS.url = configs.url;
	WebGUI.EMS.tabContent = configs.tabContent;
    }
    WebGUI.EMS.items = new Object();

    if(!this._configs.initRequestString) {
        this._configs.initRequestString = ';startIndex=0';
    }

    ///////////////////////////////////////////////////////////////
    //              Internationalization
    //  this comes first because it is used in other areas...
    ///////////////////////////////////////////////////////////////
    WebGUI.EMS.i18n = new WebGUI.i18n( {
        namespaces : {
            'Asset_EMSSubmission' : [
                ''
            ],
            'Asset_EventManagementSystem' : [
	        'close tab',
                ''
            ]
        }
//        onpreload : {
//            fn       : this.initialize,
//            obj      : this,
//            override : true,
//        }
    } );

    ///////////////////////////////////////////////////////////////
    //              Protected Static Methods
    ///////////////////////////////////////////////////////////////
    
    //***********************************************************************************
    //    This Method updates the window.location.hash when the user changes tabs
    WebGUI.EMS.changeTab = function ( e ) {
	 alert('tab changed');
	 var index = WebGUI.EMS.tabs.getTabIndex( e.newValue );
         if( index == 0 ) {
	     window.location.hash = '';
	 }  else {
	     window.location.hash = WebGUI.EMS.Tabs[index].id;
	 }
    };

    //***********************************************************************************
    //  This method closes the active tab
    //
    //   Parameters:   ( integer ) -- if a ticket id is passed in then remove the tab for that ticket
    //                 ( e, object ) -- cancel the event and close the tab associated with the object
    //                 ( ) -- get the current tab from the tabview object and close it
    //
    WebGUI.EMS.closeTab = function ( e, myTab ) {
        var index;
        if( typeof(e) == "string" || typeof(e) == "number" ) {
            index = e;
            myTab = WebGUI.EMS.items[index].tab;
        } else {
            if( typeof(e) != "undefined" ) {
                YAHOO.util.Event.preventDefault(e);
            }
            if( typeof(myTab) == "undefined" ) {
                myTab = WebGUI.EMS.tabs.get('activeTab');
	    }
	    index = WebGUI.EMS.tabs.getTabIndex(myTab);
        }
        delete WebGUI.EMS.items[index];
        WebGUI.EMS.tabs.removeTab(myTab);
        if( WebGUI.EMS.lastTab ) {
	   WebGUI.EMS.tabs.set('activeTab',WebGUI.EMS.lastTab);
        }
    };

    //***********************************************************************************
    // Custom function to handle pagination requests
    WebGUI.EMS.handlePagination = function (state,dt) {
        var sortedBy  = dt.get('sortedBy');
        // Define the new state
        var newState = {
            startIndex: state.startIndex, 
            sorting: {
                key: sortedBy.key,
                dir: ((sortedBy.dir === DataTable.CLASS_ASC) ? "asc" : "desc")
            },
            pagination : { // Pagination values
                startIndex: state.startIndex, // Go to the proper page offset
                rowsPerPage: state.rowsPerPage // Return the proper rows per page
            }
        };

        // Create callback object for the request
        var oCallback = {
            success: dt.onDataReturnSetRows,
            failure: dt.onDataReturnSetRows,
            scope: dt,
            argument: newState // Pass in new state as data payload for callback function to use
        };
        
        // Send the request
        dt.getDataSource().sendRequest(WebGUI.EMS.buildQueryString(newState, dt), oCallback);
    };

    //***********************************************************************************
    //This method is out here so it can be overridden.  The datatable uses this method to sort it's columns
    WebGUI.EMS.newTab = function(url) {
        //  the 'loading' 'indicator'
        if( typeof(WebGUI.EMS.loadingIndicator) == "undefined" ) {
            WebGUI.EMS.loadingIndicator = new YAHOO.widget.Overlay( "loadingIndicator", {  
                fixedcenter         : true,
                visible             : false
           } );
            WebGUI.EMS.loadingIndicator.setBody( "Loading ..." +
		"<img id='loadingIndicator' title='Loading' src='/extras/wobject/EMS/indicator.gif'/>"
		);
	    WebGUI.EMS.loadingIndicator.render(document.body);
        }
        WebGUI.EMS.loadingIndicator.show();

		// Create callback object for the request
	var oCallback = {
	    success: function(o) {
		   var response = eval('(' + o.responseText + ')');
		   var myTab;
		   if(response.hasError){
		       var message = "";
		       for(var i = 0; i < response.errors.length; i++) {
			   message += response.errors[i];
		       }
		       alert(message);
		       return;
		        // currently only one tab exists, so instead of checking we just delete it and recreate
			//  this condition is going to have to search for the id in the list
		   } else { // if( typeof(WebGUI.EMS.items[response.title]) == "undefined" 
			      // || WebGUI.EMS.items[response.title] == null ) { // }
		       // if there is a tab .. close it,
		       // at least until I can get the JS/HTML re-written to handle multiple tabs
		       //  there should only be one
		       for( var item in WebGUI.EMS.items ) { WebGUI.EMS.closeTab(item) }
		       var myContent = document.createElement("div");
		       myContent.innerHTML = response.text;
		       myTab = new YAHOO.widget.Tab({
			     label: response.title + '<span class="close"><img src="/extras/wobject/EMS/close12_1.gif" alt="X" title="' +
				    WebGUI.EMS.i18n.get('Asset_EventManagementSystem','close tab') + '" /></span>',
			     contentEl: myContent
			 });
		       WebGUI.EMS.tabs.addTab( myTab );
		       var index = WebGUI.EMS.tabs.getTabIndex(myTab);
		       YAHOO.util.Event.on(myTab.getElementsByClassName('close')[0], 'click', WebGUI.EMS.closeTab , myTab);
		       WebGUI.EMS.items[index] = new Object();
		       WebGUI.EMS.items[index].tab = myTab;
		       WebGUI.EMS.items[index].id = response.id;
		       WebGUI.EMS.items[index].title = response.title;
		   //} else {
		       //myTab = WebGUI.EMS.items[response.title].tab;
		       //myTab.set('content', response.text);
		   }
		   // make sure the script on the ticket has run
		   // if( typeof( WebGUI.ticketJScriptRun ) == "undefined" ) {
		       // eval( document.getElementById("ticketJScript").innerHTML );
		   // }
		   // delete WebGUI.ticketJScriptRun;
		   WebGUI.EMS.loadingIndicator.hide();
		   WebGUI.EMS.lastTab = WebGUI.EMS.tabs.get('activeTab');
		   //initHoverHelp(myTab);
		   WebGUI.EMS.tabs.set('activeTab',myTab);
	       },
	    failure: function(o) {
		   WebGUI.EMS.loadingIndicator.hide();
		    alert("AJAX call failed");
	       }
	};
	var request = YAHOO.util.Connect.asyncRequest('GET', url + ';asJson=1' , oCallback); 
    };

    //***********************************************************************************
    //This method is out here so it can be overridden.  The datatable uses this method to sort it's columns
    WebGUI.EMS.sortColumn = function(oColumn,sDir) {
        // Default ascending
        var sDir = "desc";

        // If already sorted, sort in opposite direction
        if(oColumn.key === this.get("sortedBy").key) {
            sDir = (this.get("sortedBy").dir === DataTable.CLASS_ASC) ? "desc" : "asc";
        }

        // Define the new state
        var newState = {
            startIndex: 0,
            sorting: { // Sort values
                key: oColumn.key,
                dir: (sDir === "asc") ? DataTable.CLASS_ASC : DataTable.CLASS_DESC
            },
            pagination : { // Pagination values
                startIndex: 0, // Default to first page when sorting
                rowsPerPage: this.get("paginator").getRowsPerPage() // Keep current setting
            }
        };

        // Create callback object for the request
        var oCallback = {
            success: this.onDataReturnSetRows,
            failure: this.onDataReturnSetRows,
            scope: this,
            argument: newState // Pass in new state as data payload for callback function to use
        };
        
        // Send the request
        this.getDataSource().sendRequest(WebGUI.EMS.buildQueryString(newState, this), oCallback);
    };

    //***********************************************************************************
    //  This method checks for modifier keys pressed during the mouse click
    function eventModifiers( e ) {
        if( e.event.modifiers ) {
            return e.event.modifiers & (Event.ALT_MASK | Event.CONTROL_MASK
                                | Event.SHIFT_MASK | Event.META_MASK);
        } else {
            return  e.event.altKey | e.event.shiftKey | e.event.ctrlKey;
        }
    }

    //***********************************************************************************
    // This method does the actual work of loading an item into a tab
    //
    WebGUI.EMS.loadItem = function ( contentId ) {
            var submissionId = parseInt( contentId, 10 );
            var url;
	    //  compare contentId with submissionId incase we get an assetId that starts with numeric chars
            if( contentId == submissionId ) {
	        url     = WebGUI.EMS.tabContent['editSubmission'] + ";submissionId=" + submissionId;
            } else {
	        url     = WebGUI.EMS.tabContent[contentId];
            }
	    WebGUI.EMS.newTab(url);
    };

    //***********************************************************************************
    // Load an item when the user clicks on an anchor html element
    //
    WebGUI.EMS.loadItemFromAnchor = function ( anchorObject ) {
	var tabContent = anchorObject.hash.substring(1);
	WebGUI.EMS.loadItem(tabContent);
    };

    //***********************************************************************************
    //  This method is subscribed to by the DataTable and thus becomes a member of the DataTable
    //  class even though it is a member of the EMS Class.  For this reason, a EMS instance
    //  is actually passed to the method as it's second parameter.
    //
    WebGUI.EMS.loadItemFromTable = function ( evt, obj ) {
               // if the user pressed a modifier key we want to default
        if( eventModifiers( evt ) ) { return }
        var target = evt.target;
	YAHOO.util.Event.stopEvent(evt.event);
        var elCell = this.getTdEl(target);
        if(elCell) {
            var oRecord = this.getRecord(elCell);
	    var submissionId = oRecord.getData('submissionId');

            if( typeof( WebGUI.EMS.items[submissionId] ) != "undefined" ) {
	        WebGUI.EMS.tabs.set('activeTab',WebGUI.EMS.items[submissionId].tab);
	        WebGUI.EMS.loadingIndicator.hide();
	    }  else {
		WebGUI.EMS.loadItem( submissionId );
            }
        } else {
            alert("Could not get table cell for " + target);
        }
    };


    ///////////////////////////////////////////////////////////////
    //              Public Instance Methods
    ///////////////////////////////////////////////////////////////

    //***********************************************************************************
    this.getDataTable = function() {
        if(!this.EMSQ) {
            return {};
        }
        return this.EMSQ;
    };    

    //***********************************************************************************
    this.getDefaultSort = function() {
        if(this._configs.defaultSort) {
            return this._configs.defaultSort;
        }
        return {
            "key" : "creationDate",
            "dir" : DataTable.CLASS_DESC
        };
    };
    
    //***********************************************************************************
    // Override this method if you want pagination to work differently    
    this.getPaginator = function () {
        return new Paginator({
            containers         : this._configs.p_containers,
            pageLinks          : 5,
            rowsPerPage        : 25,
            rowsPerPageOptions : [25,50,100],
            template           : "<strong>{CurrentPageReport}</strong> {PreviousPageLink} {PageLinks} {NextPageLink} {RowsPerPageDropdown}"
        });
    };

    //***********************************************************************************
    this.initDataTable = function () {
        var datasource  = new DataSource(this._configs.datasource);
        datasource.responseType   = DataSource.TYPE_JSON;
        datasource.responseSchema = {
            resultsList : 'records',
            fields      : this._configs.fields,
            metaFields  : { totalRecords: 'totalRecords' }
        };

        // Initialize the data table
        this.EMSQ = new DataTable(
            this._configs.dtContainer,
            this._configs.columns,
            datasource,
            {
                initialRequest         : this._configs.initRequestString,
                paginationEventHandler : WebGUI.EMS.handlePagination,
                paginator              : this.getPaginator(),
                dynamicData            : true, 
                sortedBy               : this.getDefaultSort()
            }
        );
        this.EMSQ.subscribe("rowMouseoverEvent", this.EMSQ.onEventHighlightRow);
        this.EMSQ.subscribe("rowMouseoutEvent", this.EMSQ.onEventUnhighlightRow);
        this.EMSQ.subscribe("cellClickEvent",WebGUI.EMS.loadItemFromTable,this);
        // Override function for custom server-side sorting
        this.EMSQ.sortColumn = WebGUI.EMS.sortColumn;
        this.EMSQ.handleDataReturnPayload = function (oReq, oRes, oPayload ) {
               oPayload.totalRecords = parseInt( oRes.meta.totalRecords );
               return oPayload;
        };
        this.EMSQ.generateRequest = WebGUI.EMS.buildQueryString;
        
        //Work around nested scoping for the callback
        var myEMSQ = this.EMSQ;
        //ensure no memory leaks with the datatable
    };

};

///////////////////////////////////////////////////////////////
//            Public Static Methods
///////////////////////////////////////////////////////////////

//***********************************************************************************
WebGUI.EMS.formatTitle = function ( elCell, oRecord, oColumn, orderNumber ) {
    elCell.innerHTML = '<a href="' + oRecord.getData('url') + '>'
        + oRecord.getData( 'title' )
        + '</a>'
        ;
};

//***********************************************************************************
WebGUI.EMS.buildQueryString = function ( state, dt ) {
    var query = ";startIndex=" + state.pagination.startIndex 
        + ';orderByDirection=' + ((state.sortedBy.dir === DataTable.CLASS_ASC) ? "ASC" : "DESC")
        + ';rowsPerPage=' + state.pagination.rowsPerPage
        + ';orderByColumn=' + state.sortedBy.key
        ;
    return query;
};

