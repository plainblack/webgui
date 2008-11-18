var myCompareTable;
//var search;

YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON = new function() {
        this.formatUrl = function(elCell, oRecord, oColumn, sData) {
            elCell.innerHTML = "<a href='" + oRecord.getData("ClickUrl") + "' target='_blank'>" + sData + "</a>";
        };

	this.formatCheckBox = function(elCell, oRecord, oColumn, sData) {
		var innerHTML = "<input type='checkbox' name='listingId' value='" + sData + "' id='" + sData + "_checkBox'";
		if(typeof(oRecord.getData("checked")) != 'undefined'){
			if(oRecord.getData("checked") == 'checked'){
			innerHTML = innerHTML + " checked='checked'";
			}
		}
		innerHTML = innerHTML + ">";
            	elCell.innerHTML = innerHTML;
        };

        var myColumnDefs = [
	    {key:"assetId",label:"",sortable:false,formatter:this.formatCheckBox},
            {key:"title", label:"Name", sortable:true, formatter:this.formatUrl},
            {key:"views", sortable:true},
            {key:"clicks", sortable:true},
            {key:"compares", sortable:true}
        ];

	var uri = "func=getCompareFormData";
	if(typeof(listingIds) != 'undefined'){
	for (var i = 0; i < listingIds.length; i++) {
		uri = uri+';listingId='+listingIds[i];
	}
	}

        var myDataSource = new YAHOO.util.DataSource("?");
        myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
        myDataSource.connXhrMode = "queueRequests";
        myDataSource.responseSchema = {
            resultsList: "ResultSet.Result",
            fields: ["title","views","clicks","compares","assetId","checked"]
        };


        var myDataTable = new YAHOO.widget.DataTable("compareForm", myColumnDefs,
                myDataSource, {initialRequest:uri});

	myDataSource.doBeforeParseData = function (oRequest, oFullResponse) {
		
		myDataTable.getRecordSet().reset();
		return oFullResponse;
	}

	var oColumn = myDataTable.getColumn(3);
	myDataTable.hideColumn(oColumn); 


        var myCallback = function() {
		myDataTable.getRecordSet().reset();
            this.set("sortedBy", null);
            this.onDataReturnAppendRows.apply(this,arguments);
        };

	var callback2 = {
            success : myCallback,
            failure : myCallback,
            scope : myDataTable
        };

	var attributeSelects = YAHOO.util.Dom.getElementsByClassName('attributeSelect','select');
	var reloadCompareForm = function() {
		myDataTable.getRecordSet().reset();
		myDataTable.initializeTable;

		var elements = myDataTable.getRecordSet().getRecords();
		alert(elements.length);
			// hide non-selected attributes
		for(i=0; i<elements.length; i++){
			
			myDataTable.getRecordSet().deleteRecords(0,elements.length);
			alert("deleting record " + i);
		}
		myDataSource.sendRequest(newUri,callback2);
		myDataTable.getRecordSet().reset();
		myDataTable.initializeTable;
    	}
	var newUri = "func=getCompareFormData;search=1";
    	for (var i = attributeSelects.length; i--; ) {
		newUri = newUri + ';search_' + attributeSelects[i].id + '=' + attributeSelects[i].value;
        	attributeSelects[i].onchange = reloadCompareForm;
    	}

	
    };
});

