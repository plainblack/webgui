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
	this.formatLabel = function(elCell, oRecord, oColumn, sData) {
		if(oRecord.getData("fieldType") == 'category'){
            		elCell.innerHTML = "<b>" +sData + "</b>";
		}else{
			elCell.innerHTML = sData + "<div class='wg-hoverhelp'>" + oRecord.getData("description") +"</div>";
		}
        };
	this.formatColors = function(elCell, oRecord, oColumn, sData) {
		if(oRecord.getData("fieldType") != 'category'){
			var color = oRecord.getData("compareColor");
			if(color){
				Dom.setStyle(elCell.parentNode, "background-color", color);
			}
			elCell.innerHTML = sData;
		}
        };
        var myColumnDefs = [
            	{key:"stickied",formatter:this.formatStickied,label:""},
		{key:"label",formatter:this.formatLabel,label:""},
		{key:"value",label:"",formatter:this.formatColors}
        ];

        this.myDataSource = new YAHOO.util.DataSource("?");
        this.myDataSource.responseType = YAHOO.util.DataSource.TYPE_JSON;
        this.myDataSource.connXhrMode = "queueRequests";
        this.myDataSource.responseSchema = {
            resultsList: "ResultSet.Result",
            fields: ["label","value","attributeId","fieldType","checked","description","compareColor"]
        };

	var uri = "func=getAttributes";

	var initAttributeHoverHelp = function() {
		initHoverHelp('attributes');
	}

        var myDataTable = new YAHOO.widget.DataTable("attributes", myColumnDefs,
                this.myDataSource, {initialRequest:uri});
	myDataTable.subscribe("initEvent", initAttributeHoverHelp);


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



