YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON = new function() {
        this.formatUrl = function(elCell, oRecord, oColumn, sData) {
            elCell.innerHTML = "<a href='" + oRecord.getData("url") + "' target='_blank'>" + sData + "</a>";
        };

        var myColumnDefs = [
	    {key:"checkBox",label:"",sortable:false},
            {key:"title", label:"Name", sortable:true, formatter:this.formatUrl},
            {key:"views", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}},
            {key:"clicks", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}},
            {key:"compares", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}},
            {key:"lastUpdated", sortable:true, sortOptions:{defaultDir:YAHOO.widget.DataTable.CLASS_DESC}}
        ];

	var uri = "func=getCompareFormData";
	if(typeof(listingIds) != 'undefined'){
	for (var i = 0; i < listingIds.length; i++) {
		uri = uri+';listingId='+listingIds[i];
	}
	}

        this.myDataSource = new YAHOO.util.DataSource("?");
        this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
        this.myDataSource.connXhrMode = "queueRequests";
        this.myDataSource.responseSchema = {
            resultsList: "ResultSet.Result",
            fields: ["title","views","clicks","compares","checkBox","checked","lastUpdated","url"]
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
        },this,true);

	var btnSortByClicks = new YAHOO.widget.Button("sortByClicks");
        btnSortByClicks.on("click", function(e) {
	    this.myDataTable.sortColumn(this.myDataTable.getColumn(3)); 
        },this,true);

	var btnSortByCompares = new YAHOO.widget.Button("sortByCompares");
        btnSortByCompares.on("click", function(e) {
	    this.myDataTable.sortColumn(this.myDataTable.getColumn(4)); 
        },this,true);

	var btnSortByUpdated = new YAHOO.widget.Button("sortByUpdated");
        btnSortByUpdated.on("click", function(e) {
	    this.myDataTable.sortColumn(this.myDataTable.getColumn(5)); 
        },this,true);

        var myCallback = function() {
            this.set("sortedBy", null);
            this.onDataReturnAppendRows.apply(this,arguments);
        };
	
	var btnCompare = new YAHOO.widget.Button("compare",{disabled:true,id:"compareButton"});
        btnCompare.on("click", function(e) {
		window.document.forms['doCompare'].submit();
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
    };
});

