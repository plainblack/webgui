//var myCompareTable;

YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON = new function() {

        var myColumnDefs = [
            {key:"name"}
        ];

        this.myDataSource = new YAHOO.util.DataSource("?");
        this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
        this.myDataSource.connXhrMode = "queueRequests";
        this.myDataSource.responseSchema = {
            resultsList: "ResultSet.Result",
            fields: columnKeys //["name","AwioUvaZXmAEaFw20tx3Q","CWNjAHcmh0pEF6WJooomJA"]
        };

	var uri = "func=getCompareListData";
	for (var i = 0; i < listingIds.length; i++) {
		uri = uri+';listingId='+listingIds[i];
	}

        var myDataTable = new YAHOO.widget.DataTable("compareList", myColumnDefs,
                this.myDataSource, {initialRequest:uri});

	//var oColumn = this.myDataTable.getColumn(3);
	//this.myDataTable.hideColumn(oColumn); 


	//var btnAddRows = new YAHOO.widget.Button("hidecolumn");
        //btnAddRows.on("click", function(e) {

            //var oColumn = this.myDataTable.getColumn(3);
	//    this.myDataTable.sortColumn(oColumn); 
        //},this,true);

	this.myDataSource.doBeforeParseData = function (oRequest, oFullResponse) {
		myDataTable.getRecordSet().reset();
		var existingColumns = myDataTable.getColumnSet().keys;
		for (var i = 0; i < existingColumns.length; i++) {
		if(i > 0){
			myDataTable.removeColumn(existingColumns[1]);
		}
		}
	    if (oFullResponse.ColumnDefs) {
		var len = oFullResponse.ColumnDefs.length;
		
		for (var i = 0; i < len; i++) {
		var c = oFullResponse.ColumnDefs[i];
		myDataTable.insertColumn(c);
		}
	    }
	    return oFullResponse;		
	}

        var myCallback = function() {
            this.set("sortedBy", null);
            this.onDataReturnAppendRows.apply(this,arguments);
        };

        var myCallback2 = function() {
	this.getRecordSet().reset();
	//this.render();		
            this.set("sortedBy", null);
            this.onDataReturnAppendRows.apply(this,arguments);
		this.getRecordSet().reset();
        };
	

	var callback2 = {
            success : myCallback,
            failure : myCallback,
            scope : myDataTable
        };
        this.myDataSource.sendRequest("func=getCompareListData;listingId=CWNjAHcmh0pEF6WJooomJA",
                callback2);
	
    };
});

//function sort() {
//	myCompareTable.sortColumn()
//	var oColumn = myCompareTable.getColumn(3);
//	myCompareTable.hideColumn(oColumn); 
//}

