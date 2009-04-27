YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON = new function() {
	var Dom = YAHOO.util.Dom;
	var hideStickies = 0;

	this.formatStickied = function(elCell, oRecord, oColumn, sData) {
		if(oRecord.getData("fieldType") != 'category'){
            		var innerHTML = "<input type='checkBox' class='stickieCheckbox' id='" + oRecord.getData("attributeId") + "_stickied' name='" + oRecord.getData("attributeId") + "' onChange='setStickied(this)'";
			if(typeof(oRecord.getData("checked")) != 'undefined' && oRecord.getData("checked") == 'checked'){
				innerHTML = innerHTML + " checked='checked'";
			}
			innerHTML = innerHTML + ">";
			elCell.innerHTML = innerHTML;
		}
        };

	this.formatColors = function(elCell, oRecord, oColumn, sData) {
		if(oRecord.getData("fieldType") != 'category'){
			var colorField = oColumn.key + "_compareColor";
			var color = oRecord.getData(colorField);
			if(color){
				Dom.setStyle(elCell.parentNode, "background-color", color);
			}
			elCell.innerHTML = sData;
		}else{
			elCell.innerHTML = sData;
		}
        };
	this.formatLabel = function(elCell, oRecord, oColumn, sData) {
		if(oRecord.getData("fieldType") == 'category'){
            		elCell.innerHTML = "<b>" +sData + "</b>";
		}else{
			elCell.innerHTML = sData; 
			if(oRecord.getData("description")){
				elCell.innerHTML = elCell.innerHTML + "<div class='wg-hoverhelp'>" + oRecord.getData("description") +"</div>";
			}
		}
        };

	YAHOO.widget.DataTable.Formatter.formatColors = this.formatColors; 

        var myColumnDefs = [
            	{key:"stickied",formatter:this.formatStickied,label:""},
		{key:"name",formatter:this.formatLabel,label:""}
        ];

        this.myDataSource = new YAHOO.util.DataSource("?");
        this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
        this.myDataSource.connXhrMode = "queueRequests";
        this.myDataSource.responseSchema = {
            resultsList: "ResultSet.Result",
            fields: responseFields 
        };

	var uri = "func=getCompareListData";
	for (var i = 0; i < listingIds.length; i++) {
		uri = uri+';listingId='+listingIds[i];
	}

	var initAttributeHoverHelp = function() {
		initHoverHelp('compareList');
	}

        var myDataTable = new YAHOO.widget.DataTable("compareList", myColumnDefs,
                this.myDataSource, {initialRequest:uri});
	myDataTable.subscribe("initEvent", initAttributeHoverHelp);


	window.removeListing = function(key) {
		myDataTable.hideColumn(myDataTable.removeColumn(key));
	}

	this.myDataSource.doBeforeParseData = function (oRequest, oFullResponse) {
		myDataTable.getRecordSet().reset();
		myDataTable.refreshView();
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
		oFullResponse.ColumnDefs[i].label = "<a href='"+ oFullResponse.ColumnDefs[i].url +"'>" + oFullResponse.ColumnDefs[i].label + "</a> <a href='javascript:removeListing(\""+oFullResponse.ColumnDefs[i].key+"\")'><img src='/extras/toolbar/bullet/delete.gif' border='0'></a>"
		myDataTable.insertColumn(c);
		}
	    }
	    return oFullResponse;		
	}

        var myCallback = function() {
            	this.set("sortedBy", null);
            	this.onDataReturnAppendRows.apply(this,arguments);
		initHoverHelp('compareList');
        };

	var callback2 = {
            success : myCallback,
            failure : myCallback,
            scope : myDataTable
        };

	var btnCompare = new YAHOO.widget.Button("compare",{disabled:true,id:"compareButton"});
        btnCompare.on("click", function(e) {
		var compareCheckBoxes = YAHOO.util.Dom.getElementsByClassName('compareCheckBox','input');
		var uri = "func=getCompareListData";
		for (var i = compareCheckBoxes.length; i--; ) {
			if(compareCheckBoxes[i].checked == true){
				uri = uri+';listingId='+compareCheckBoxes[i].value;
			}
		}
            	this.myDataSource.sendRequest(uri,callback2); 
        },this,true);

	var btnCompare2 = new YAHOO.widget.Button("compare2",{disabled:true,id:"compareButton2"});
        btnCompare2.on("click", function(e) {
		var compareCheckBoxes = YAHOO.util.Dom.getElementsByClassName('compareCheckBox','input');
		var uri = "func=getCompareListData";
		for (var i = compareCheckBoxes.length; i--; ) {
			if(compareCheckBoxes[i].checked == true){
				uri = uri+';listingId='+compareCheckBoxes[i].value;
			}
		}
            	this.myDataSource.sendRequest(uri,callback2); 
        },this,true);

	var btnSearch = new YAHOO.widget.Button("search");
        btnSearch.on("click", function(e) {
		window.location.href = matrixUrl + '?func=search';
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
			btnCompare2.set("disabled",false);
		}else{
			btnCompare.set("disabled",true);
			btnCompare2.set("disabled",true);
		}
	}

	var btnStickied = new YAHOO.widget.Button("stickied");
        btnStickied.on("click", function(e) {
		var elements = myDataTable.getRecordSet().getRecords();
		if(hideStickies == 0){
			// hide non-selected attributes
			for(i=0; i<elements.length; i++){
				if(elements[i].getData('fieldType') != 'category'){
					var attributeId = elements[i].getData('attributeId');
					var checkBox = Dom.get(attributeId+"_stickied");
					if (checkBox.checked == false){
						elRow = myDataTable.getTrEl(elements[i]);
						Dom.setStyle(elRow, "display", "none");
					}
				}
			}
			hideStickies = 1;
		}else{
			// show all attributes
			for(i=0; i<elements.length; i++){
				if(elements[i].getData('fieldType') != 'category'){
					var attributeId = elements[i].getData('attributeId');
					var checkBox = Dom.get(attributeId+"_stickied");
					if (checkBox.checked == false){
						elRow = myDataTable.getTrEl(elements[i]);
						Dom.setStyle(elRow, "display", "table-row");
					}
				}
			}
			hideStickies = 0;
		}
	},this,true);
    };
});

function setStickied (checkbox) {
	if(checkbox.checked == true){
		var request = YAHOO.util.Connect.asyncRequest('POST', "?func=setStickied;attributeId="+checkbox.name);
	}else{
		var request = YAHOO.util.Connect.asyncRequest('POST', "?func=deleteStickied;attributeId="+checkbox.name);
	}
	
}



