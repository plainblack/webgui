YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON = new function() {
	var Dom = YAHOO.util.Dom;
	var hideStickies = 0;

	this.formatStickied = function(elCell, oRecord, oColumn, sData) {
            	elCell.innerHTML = "<input type='checkBox' class='stickieCheckbox' id='" + oRecord.getData("attributeId") + "_stickied'>";
        };

	this.formatColors = function(elCell, oRecord, oColumn, sData) {
		var colorField = oColumn.key + "_compareColor";
		var color = oRecord.getData(colorField);
		if(color){
			Dom.setStyle(elCell.parentNode, "background-color", color);
		}
            	elCell.innerHTML = sData;
        };

	YAHOO.widget.DataTable.Formatter.formatColors = this.formatColors; 

        var myColumnDefs = [
            	{key:"stickied",formatter:this.formatStickied},
		{key:"name"}
        ];

        this.myDataSource = new YAHOO.util.DataSource("?");
        this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
        this.myDataSource.connXhrMode = "queueRequests";
        this.myDataSource.responseSchema = {
            resultsList: "ResultSet.Result",
            fields: columnKeys 
        };

	var uri = "func=getCompareListData";
	for (var i = 0; i < listingIds.length; i++) {
		uri = uri+';listingId='+listingIds[i];
	}

        var myDataTable = new YAHOO.widget.DataTable("compareList", myColumnDefs,
                this.myDataSource, {initialRequest:uri});


	this.myDataSource.doBeforeParseData = function (oRequest, oFullResponse) {
		myDataTable.getRecordSet().reset();
		var existingColumns = myDataTable.getColumnSet().keys;
		for (var i = 0; i < existingColumns.length; i++) {
		if(i > 1){
			// after deleting a column the next column will
			// allways be no. 2 (the third in the array)
			myDataTable.removeColumn(existingColumns[2]);
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
		this.set("sortedBy", null);
            	this.onDataReturnAppendRows.apply(this,arguments);
        };
	

	var callback2 = {
            success : myCallback,
            failure : myCallback,
            scope : myDataTable
        };

	var btnCompare = new YAHOO.widget.Button("compare",{disabled:true,id:"compareButton"});
        btnCompare.on("click", function(e) {
		var uri = "func=getCompareListData";
		for (var i = 0; i < columnKeys.length; i++) {
			if(columnKeys[i] != 'name'){
				var checkBox = new Dom.get(columnKeys[i] + '_checkBox');	
				if(checkBox.checked == true){
					uri = uri+';listingId='+columnKeys[i];
				}
			}
		}
            	this.myDataSource.sendRequest(uri,callback2); 
        },this,true);

	window.compareFormButton = function() {
		var compareCheckBoxes = YAHOO.util.Dom.getElementsByClassName('compareCheckBox','input');
		var checked = 0;
		for (var i = compareCheckBoxes.length; i--; ) {
			if(compareCheckBoxes[i].checked){	
				checked++;
			}
    		}
		if (checked > 1 && checked < maxComparisons){
			btnCompare.set("disabled",false);
		}else{
			btnCompare.set("disabled",true);
		}
	}

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



