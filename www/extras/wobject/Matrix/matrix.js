var myCompareTable;

YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON = new function() {
        this.formatUrl = function(elCell, oRecord, oColumn, sData) {
            elCell.innerHTML = "<a href='" + oRecord.getData("url") + "' target='_blank'>" + sData + "</a>";
        };

	this.formatCheckBox = function(elCell, oRecord, oColumn, sData) {
		var innerHTML = "<input type='checkbox' name='listingId' value='" + sData + "' id='" + sData + "_checkBox'";
		if(typeof(oRecord.getData("checked")) != 'undefined'){
			innerHTML = innerHTML + " checked='checked'";
		}
		innerHTML = innerHTML + ">";
            	elCell.innerHTML = innerHTML;
        };

        var myColumnDefs = [
	    {key:"checkBox",label:"",sortable:false},//,formatter:this.formatCheckBox
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

	//var oColumn = this.myDataTable.getColumn(3);
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



	//var compareCheckBoxes = YAHOO.util.Dom.getElementsByClassName('compareCheckBox');
	//for (var i = compareCheckBoxes.length; i--; ) {
	//	alert('bla');
	//	compareCheckBoxes[i].onchange = compareFormButton;
    	//}
	
    };
});
	function compareFormButton () {
		var compareCheckBoxes = YAHOO.util.Dom.getElementsByClassName('compareCheckBox','input');
		//alert(compareCheckBoxes.length);
		var checked = 0;
		for (var i = compareCheckBoxes.length; i--; ) {
			if(compareCheckBoxes[i].checked){	
				checked++;
			}
    		}
		//alert(checked);
	}

//function sort() {
//	myCompareTable.sortColumn()
//	var oColumn = myCompareTable.getColumn(3);
//	myCompareTable.hideColumn(oColumn); 
//}

function bla() {
        var callback1 = {
            success : myCallback,
            failure : myCallback,
            scope : this.myDataTable
        };
        this.myDataSource.sendRequest("func=getCompareFormData",
                callback1);

        var callback2 = {
            success : myCallback,
            failure : myCallback,
            scope : this.myDataTable
        };
        this.myDataSource.sendRequest("func=getCompareFormData",
                callback2);
}