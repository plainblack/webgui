YAHOO.util.Event.addListener(window, "load", function() {
    YAHOO.example.XHR_JSON = new function() {
	var Dom = YAHOO.util.Dom;

        this.formatUrl = function(elCell, oRecord, oColumn, sData) {
            elCell.innerHTML = "<a href='" + oRecord.getData("url") + "' target='_blank'>" + sData + "</a>";
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
            {key:"title", label:"Name", sortable:true, formatter:this.formatUrl}
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
            fields: ["title","checked","url","assetId"]
        };

        var myDataTable = new YAHOO.widget.DataTable("compareForm", myColumnDefs,
                this.myDataSource, {initialRequest:uri});

	var myDataSource = this.myDataSource;

        var myCallback = function() {
		this.set("sortedBy", null);
            	this.onDataReturnAppendRows.apply(this,arguments);
		compareFormButton();
        };

	var callback2 = {
            success : myCallback,
            failure : myCallback,
            scope : myDataTable
        };
		
	var reloadCompareForm = function() {
		var attributeSelects = YAHOO.util.Dom.getElementsByClassName('attributeSelect','select');
		var newUri = "func=getCompareFormData;search=1";
    		for (var i = attributeSelects.length; i--; ) {
			if(attributeSelects[i].value != 'blank'){
				newUri = newUri + ';search_' + attributeSelects[i].id + '=' + attributeSelects[i].value;
			}
        	}
		myDataTable.getRecordSet().reset();
		myDataTable.refreshView();
		myDataTable.showTableMessage('Loading...');
		
		myDataSource.sendRequest(newUri,callback2);
		
    	}
	var attributeSelects = YAHOO.util.Dom.getElementsByClassName('attributeSelect','select');
	for (var i = attributeSelects.length; i--; ) {
		attributeSelects[i].onchange = reloadCompareForm;
    	}
	
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

