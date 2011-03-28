/*** The WebGUI Asset History Viewer 
 * Requires: YAHOO, Dom, Event
 * With all due credit to Doug Bell, who wrote the AssetManager.  AssetHistory
 * is a blatant copy/paste/modify of it.
 */

if ( typeof WebGUI == "undefined" ) {
    WebGUI  = {};
}
if ( typeof WebGUI.AssetHistory == "undefined" ) {
    WebGUI.AssetHistory = {};
}

/*---------------------------------------------------------------------------
    WebGUI.AssetHistory.DefaultSortedBy ( )
*/
WebGUI.AssetHistory.DefaultSortedBy = { 
    "key"       : "dateStamp",
    "dir"       : YAHOO.widget.DataTable.CLASS_ASC
};

/*---------------------------------------------------------------------------
    WebGUI.AssetHistory.BuildQueryString ( )
*/
WebGUI.AssetHistory.BuildQueryString = function ( state, dt ) {
    var query = "startIndex=" + state.pagination.recordOffset 
              + ';sortDir='   + ((state.sortedBy.dir === YAHOO.widget.DataTable.CLASS_DESC) ? "DESC" : "ASC")
              + ';results='   + state.pagination.rowsPerPage
              + ';sortKey='   + state.sortedBy.key
              + ';keywords='  + YAHOO.util.Dom.get('keywordsField').value 
              ;
        return query;
    };

/*---------------------------------------------------------------------------
    WebGUI.AssetHistory.formatDate ( )
    Format the date the asset was modified.
*/
WebGUI.AssetHistory.formatDate = function ( elCell, oRecord, oColumn, orderNumber ) {
    var actionDate = new Date( 1000 * oRecord.getData('dateStamp') );
    var formattedDate = YAHOO.util.Date.format(actionDate, { format: '%x %X' });
    elCell.innerHTML = formattedDate;
};


/*---------------------------------------------------------------------------
    WebGUI.AssetHistory.initManager ( )
    Initialize the i18n interface
*/
WebGUI.AssetHistory.initManager = function (o) {
    WebGUI.AssetHistory.i18n
    = new WebGUI.i18n( { 
            namespaces  : {
                'WebGUI' : [
                    "50",
                    "104",
                    "352"
                ]
            },
            onpreload   : {
                fn       : WebGUI.AssetHistory.initDataTable
            }
        } );
};

/*---------------------------------------------------------------------------
    WebGUI.AssetHistory.initDataTable ( )
    Initialize the www_manage page
*/
WebGUI.AssetHistory.initDataTable = function (o) {
    var historyPaginator = new YAHOO.widget.Paginator({
        containers            : ['paginationTop', 'paginationBot'],
        pageLinks             : 7,
        rowsPerPage           : 25,
        template              : "<strong>{CurrentPageReport}</strong> {PreviousPageLink} {PageLinks} {NextPageLink}"
    });


   // initialize the data source
   WebGUI.AssetHistory.DataSource
        = new YAHOO.util.DataSource( encodeURI(location.pathname) + '?op=assetHistory;method=getHistoryAsJson;', {connTimeout:30000} );
    WebGUI.AssetHistory.DataSource.responseType
        = YAHOO.util.DataSource.TYPE_JSON;
    WebGUI.AssetHistory.DataSource.responseSchema
        = {
            resultsList: 'records',
            fields: [
                { key: 'assetId',     parser: 'string' },
                { key: 'username',    parser: 'string' },
                { key: 'dateStamp',   parser: 'number' },
                { key: 'title',       parser: 'string' },
                { key: 'actionTaken', parser: 'string' },
                { key: 'url',         parser: 'string' }
            ],
            metaFields: {
                totalRecords: "totalRecords" // Access to value in the server response
            }
        };
    WebGUI.AssetHistory.ColumnDefs = [ // sortable:true enables sorting
        {key:"assetId",     label:"assetId", sortable: true},
        {key:"username",    label:WebGUI.AssetHistory.i18n.get('WebGUI', '50' ), sortable: true},
        {key:"dateStamp",   label:WebGUI.AssetHistory.i18n.get('WebGUI', '352'), sortable: true, formatter: WebGUI.AssetHistory.formatDate},
        {key:"url",         label:WebGUI.AssetHistory.i18n.get('WebGUI', '104'), sortable: true},
        {key:"actionTaken", label:"actionTaken"}
    ];


    // Initialize the data table
    WebGUI.AssetHistory.DataTable 
        = new YAHOO.widget.DataTable( 'historyData', 
            WebGUI.AssetHistory.ColumnDefs, 
            WebGUI.AssetHistory.DataSource, 
            {
                initialRequest          : 'startIndex=0;results=25',
                dynamicData             : true,
                paginator               : historyPaginator,
                sortedBy                : WebGUI.AssetHistory.DefaultSortedBy,
                generateRequest         : WebGUI.AssetHistory.BuildQueryString
            }
        );

    WebGUI.AssetHistory.DataTable.handleDataReturnPayload = function(oRequest, oResponse, oPayload) {
        oPayload.totalRecords = oResponse.meta.totalRecords;
        return oPayload;
    }

    //Setup the form to submit an AJAX request back to the site.
    YAHOO.util.Dom.get('keywordSearchForm').onsubmit = function () {
        var state = WebGUI.AssetHistory.DataTable.getState();
        state.pagination.recordOffset = 0;
        WebGUI.AssetHistory.DataSource.sendRequest(
            'keywords=' + YAHOO.util.Dom.get('keywordsField').value + ';startIndex=0;results=25',
            {
                success : WebGUI.AssetHistory.DataTable.onDataReturnInitializeTable,
                scope   : WebGUI.AssetHistory.DataTable, argument:state
            }
        );
        return false;
    };

};


