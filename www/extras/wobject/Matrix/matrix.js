YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON = new function() {
        this.formatUrl = function(elCell, oRecord, oColumn, sData) {
            elCell.innerHTML = "<a href='" + oRecord.getData("url") + "'>" + sData + "</a>";
        };
	this.formatCheckBox = function(elCell, oRecord, oColumn, sData) { 
		var innerHTML = "<input type='checkbox' name='listingId' value='" + sData + "' id='" + sData + "_checkBox'";
		if(typeof(oRecord.getData("checked")) != 'undefined' && oRecord.getData("checked") == 'checked'){
			innerHTML = innerHTML + " checked='checked'";
		}
		innerHTML = innerHTML + " onchange='javascript:compareFormButton()' class='compareCheckBox'>";
		elCell.innerHTML = innerHTML;
	};

        var myColumnDefs = [
	    {key:"assetId",label:"",sortable:false, formatter:this.formatCheckBox},
            {key:"title", label:"", sortable:true, formatter:this.formatUrl},
            {key:"views", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}},
            {key:"clicks", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}},
            {key:"compares", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}},
            {key:"lastUpdated", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}}
        ];

	var uri = "func=getCompareFormData";
		if(typeof(listingIds) != 'undefined'){
		uri = uri + ';__listingId_isIn=1';
		for (var i = 0; i < listingIds.length; i++) {
			uri = uri+';listingId='+listingIds[i];
		}
	}

        this.myDataSource = new YAHOO.util.DataSource(matrixUrl + "?");
        this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
        this.myDataSource.connXhrMode = "queueRequests";
        this.myDataSource.responseSchema = {
            resultsList: "ResultSet.Result",
            fields: ["title",{key: "views", parser: "number"},{key: "clicks", parser: "number"},{key: "compares", parser: "number"},{key: "checked"},{key: "lastUpdated", parser: "number"},"url","assetId"]
        };

        this.myDataTable = new YAHOO.widget.DataTable("compareForm", myColumnDefs,
                this.myDataSource, {initialRequest:uri});

	this.myDataTable.hideColumn(this.myDataTable.getColumn(2)); 
	this.myDataTable.hideColumn(this.myDataTable.getColumn(3)); 
	this.myDataTable.hideColumn(this.myDataTable.getColumn(4)); 
	this.myDataTable.hideColumn(this.myDataTable.getColumn(5)); 

	var btnSortByViews = new YAHOO.widget.Button("sortByViews");
        btnSortByViews.on("click", function(e) {
		this.myDataTable.sortColumn(this.myDataTable.getColumn(2)); 
		var request = YAHOO.util.Connect.asyncRequest('POST', matrixUrl + "?func=setSort;sort=views");
        },this,true);

	var btnSortByClicks = new YAHOO.widget.Button("sortByClicks");
        btnSortByClicks.on("click", function(e) {
	    this.myDataTable.sortColumn(this.myDataTable.getColumn(3)); 
		var request = YAHOO.util.Connect.asyncRequest('POST', matrixUrl + "?func=setSort;sort=clicks");
        },this,true);

	var btnSortByCompares = new YAHOO.widget.Button("sortByCompares");
        btnSortByCompares.on("click", function(e) {
	    this.myDataTable.sortColumn(this.myDataTable.getColumn(4)); 
		var request = YAHOO.util.Connect.asyncRequest('POST', matrixUrl + "?func=setSort;sort=compares");
        },this,true);

	var btnSortByUpdated = new YAHOO.widget.Button("sortByUpdated");
        btnSortByUpdated.on("click", function(e) {
	    this.myDataTable.sortColumn(this.myDataTable.getColumn(5)); 
		var request = YAHOO.util.Connect.asyncRequest('POST', matrixUrl + "?func=setSort;sort=lastUpdated");
        },this,true);

        var myCallback = function() {
            this.set("sortedBy", null);
            this.onDataReturnAppendRows.apply(this,arguments);
        };
	
	var btnCompare = new YAHOO.widget.Button("compare",{disabled:true,id:"compareButton"});
        btnCompare.on("click", function(e) {
		window.document.forms['doCompare'].submit();
        },this,true);
	var btnCompare2 = new YAHOO.widget.Button("compare2",{disabled:true,id:"compareButton2"});
        btnCompare2.on("click", function(e) {
		window.document.forms['doCompare'].submit();
        },this,true);

	var btnSearch = new YAHOO.widget.Button("search");
        btnSearch.on("click", function(e) {
		window.location.href = matrixUrl + '?func=search';
	},this,true);

	window.compareDataTable = this.myDataTable;

	window.compareFormButton = function() {
		var compareCheckBoxes = YAHOO.util.Dom.getElementsByClassName('compareCheckBox','input');
		var checked = 0;
		var checkedCompareBoxes = new Object();
		for (var i = compareCheckBoxes.length; i--; ) {
			if(compareCheckBoxes[i].checked){	
				checked++;
				checkedCompareBoxes[compareCheckBoxes[i].value] = true;
			}
    		}
		if (checked > 1 && checked < maxComparisons){
			btnCompare.set("disabled",false);
			btnCompare2.set("disabled",false);
		}else{
			btnCompare.set("disabled",true);
			btnCompare2.set("disabled",true);
		}
		var elements = window.compareDataTable.getRecordSet().getRecords();
		for(j=0; j<elements.length; j++){
			var assetId = elements[j].getData('assetId');
			if(assetId in checkedCompareBoxes){
				elements[j].setData('checked','checked');
			}else{
				elements[j].setData('checked',null);
			}
		}
	}
    };
});

