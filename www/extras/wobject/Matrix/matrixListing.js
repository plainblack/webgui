YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON = new function() {
	var Dom = YAHOO.util.Dom;
	var hideStickies = 0;

	this.formatStickied = function(elCell, oRecord, oColumn, sData) {
            	elCell.innerHTML = "<input type='checkBox' class='stickieCheckbox' id='" + oRecord.getData("attributeId") + "_stickied'>";
        };

        var myColumnDefs = [
            	{key:"stickied",formatter:this.formatStickied},
		{key:"label"},
		{key:"value"}
        ];

        this.myDataSource = new YAHOO.util.DataSource("?");
        this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
        this.myDataSource.connXhrMode = "queueRequests";
        this.myDataSource.responseSchema = {
            resultsList: "ResultSet.Result",
            fields: ["label","value","attributeId"]
        };

	var uri = "func=getAttributes";

//	for (var i = 0; i < listingIds.length; i++) {
//		uri = uri+';listingId='+listingIds[i];
//	}

        var myDataTable = new YAHOO.widget.DataTable("attributes", myColumnDefs,
                this.myDataSource, {initialRequest:uri});


	this.myDataSource.doBeforeParseData = function (oRequest, oFullResponse) {
		myDataTable.getRecordSet().reset();
		return oFullResponse;		
	}

        var myCallback = function() {
            this.set("sortedBy", null);
            this.onDataReturnAppendRows.apply(this,arguments);
        };

        var myCallback2 = function() {
		this.set("sortedBy", null);
            	this.onDataReturnAppendRows.apply(this,arguments);
        };
	

	var callback2 = {
            success : myCallback,
            failure : myCallback,
            scope : myDataTable
        };


	var btnStickied = new YAHOO.widget.Button("stickied");
        btnStickied.on("click", function(e) {
		var elements = myDataTable.getRecordSet().getRecords();
		if(hideStickies == 0){
			// hide non-selected attributes
			for(i=0; i<elements.length; i++){
				var attributeId = elements[i].getData('attributeId');
				var checkBox = Dom.get(attributeId+"_stickied");
				if (checkBox.checked == false){
					elRow = myDataTable.getTrEl(elements[i]);
					Dom.setStyle(elRow, "display", "none");
				}
			}
			hideStickies = 1;
		}else{
			// show all attributes
			for(i=0; i<elements.length; i++){
				var attributeId = elements[i].getData('attributeId');
				var checkBox = Dom.get(attributeId+"_stickied");
				if (checkBox.checked == false){
					elRow = myDataTable.getTrEl(elements[i]);
					Dom.setStyle(elRow, "display", "table-row");
				}
			}
			hideStickies = 0;
		}
	},this,true);

    };
});



