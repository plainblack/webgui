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
		innerHTML = innerHTML + " class='compareCheckBox'>";
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

	this.myDataSource = new YAHOO.util.DataSource(YAHOO.util.Dom.get("compareFormTable")); 
	this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_HTMLTABLE; 
	this.myDataSource.responseSchema = { 
	    fields: [{key: "checked"},"assetId","title",{key: "views", parser: "number"},{key: "clicks", parser: "number"},{key: "compares", parser: "number"},{key: "lastUpdated", parser: "number"},"url"]
	}; 

    this.myDataTable = new YAHOO.widget.DataTable("compareForm", myColumnDefs,
        this.myDataSource);

	this.myDataTable.hideColumn(this.myDataTable.getColumn(2)); 
	this.myDataTable.hideColumn(this.myDataTable.getColumn(3)); 
	this.myDataTable.hideColumn(this.myDataTable.getColumn(4)); 
	this.myDataTable.hideColumn(this.myDataTable.getColumn(5)); 

	if(document.getElementById("sortByViews")){
	var btnSortByViews = new YAHOO.widget.Button("sortByViews");
        btnSortByViews.on("click", function(e) {
		this.myDataTable.sortColumn(this.myDataTable.getColumn(2)); 
		var request = YAHOO.util.Connect.asyncRequest('POST', matrixUrl + "?func=setSort;sort=views");
        },this,true);
	}

	if(document.getElementById("sortByClicks")){
	var btnSortByClicks = new YAHOO.widget.Button("sortByClicks");
        btnSortByClicks.on("click", function(e) {
	    this.myDataTable.sortColumn(this.myDataTable.getColumn(3)); 
		var request = YAHOO.util.Connect.asyncRequest('POST', matrixUrl + "?func=setSort;sort=clicks");
        },this,true);
	}
	
	if(document.getElementById("sortByCompares")){
	var btnSortByCompares = new YAHOO.widget.Button("sortByCompares");
        btnSortByCompares.on("click", function(e) {
	    this.myDataTable.sortColumn(this.myDataTable.getColumn(4)); 
		var request = YAHOO.util.Connect.asyncRequest('POST', matrixUrl + "?func=setSort;sort=compares");
        },this,true);
	}

	if(document.getElementById("sortByUpdated")){
	var btnSortByUpdated = new YAHOO.widget.Button("sortByUpdated");
        btnSortByUpdated.on("click", function(e) {
	    this.myDataTable.sortColumn(this.myDataTable.getColumn(5)); 
		var request = YAHOO.util.Connect.asyncRequest('POST', matrixUrl + "?func=setSort;sort=lastUpdated");
        },this,true);
	}

	if(document.getElementById("sortByName")){
	var btnSortByName = new YAHOO.widget.Button("sortByName");
        btnSortByName.on("click", function(e) {
	    this.myDataTable.sortColumn(this.myDataTable.getColumn(1)); 
		var request = YAHOO.util.Connect.asyncRequest('POST', matrixUrl + "?func=setSort;sort=lastUpdated");
        },this,true);
	}


        var myCallback = function() {
            this.set("sortedBy", null);
            this.onDataReturnAppendRows.apply(this,arguments);
        };
	
	var compareFormButton = function() {
		var compareCheckBoxes = YAHOO.util.Dom.getElementsByClassName('compareCheckBox','input');
		var checked = 0;
		var checkedCompareBoxes = new Object();
		for (var i = compareCheckBoxes.length; i--; ) {
			if(compareCheckBoxes[i].checked){	
				checked++;
				checkedCompareBoxes[compareCheckBoxes[i].value] = true;
			}
    		}
		if (checked < 2){
			alert(tooFewMessage);
		}else if (checked > maxComparisons){
			alert(tooManyMessage);
		}else{
			window.document.forms['doCompare'].submit();
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

	if(document.getElementById("compare")){
	    var btnCompare = new YAHOO.widget.Button("compare",{id:"compareButton"});
	    btnCompare.on("click", compareFormButton);
	}

	if(document.getElementById("compare2")){
	    var btnCompare2 = new YAHOO.widget.Button("compare2",{id:"compareButton2"});
	    btnCompare2.on("click", compareFormButton);
	}
	
	if(document.getElementById("search")){
	var btnSearch = new YAHOO.widget.Button("search");
        btnSearch.on("click", function(e) {
		window.location.href = matrixUrl + '?func=search';
	},this,true);
	}

	window.compareDataTable = this.myDataTable;

    };
});

