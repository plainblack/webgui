function setCancelButton () {
    var cancelButtons = YAHOO.util.Dom.getElementsByClassName('backwardButton','input','application_workarea');
    function deleteTempThing () {
	window.location.href = "?func=deleteThingConfirm;thingId="+newThingId;
    }
    for (var i = cancelButtons.length; i--; ) {
        cancelButtons[i].onclick = deleteTempThing;
    }
}


function initOptionalFields(prefix,fieldId) {
	
	var fieldInThing_module_rendered;

	var height_module = new YAHOO.widget.Module(prefix + "_height_module", { visible: false });
	height_module.render();
	
	var width_module = new YAHOO.widget.Module(prefix + "_width_module", { visible: false });
	width_module.render();

	var size_module = new YAHOO.widget.Module(prefix + "_size_module", { visible: false });
	size_module.render();

	var vertical_module = new YAHOO.widget.Module(prefix + "_vertical_module", { visible: false });
	vertical_module.render();
	
	var values_module = new YAHOO.widget.Module(prefix + "_values_module", { visible: false });
	values_module.render();
	
	var defaultValue_module = new YAHOO.widget.Module(prefix + "_defaultValue_module", { visible: false });
	defaultValue_module.render();
	
	var fieldInThing_module = new YAHOO.widget.Module(prefix + "_fieldInThing_module", { visible: false });
	fieldInThing_module.render();

	var defaultFieldInThing_module = new YAHOO.widget.Module(prefix + "_defaultFieldInThing_module", { visible: false });
	defaultFieldInThing_module.render();
	
	YAHOO.util.Event.onContentReady(prefix+"_fieldType_formId", checkFieldType);
	YAHOO.util.Event.addListener(prefix+"_fieldType_formId", "change", checkFieldType);

    	function checkFieldType(){
	if (this.value in hasHeightWidth){	
		height_module.show();
		width_module.show()
	}else{
		height_module.hide();
		width_module.hide()
	}
	if (this.value in hasVertical){	
		vertical_module.show();
	}else{
		vertical_module.hide();
	}
	if (this.value in hasSize){	
		size_module.show()
	}else{
		size_module.hide();
	}
	if (this.value in hasValues){	
		values_module.show();
	}else{
		values_module.hide();
	}
	var valueStart = this.value.slice(0,10);
	
	if (valueStart != "otherThing"){
		defaultValue_module.show();
	}else{
		defaultValue_module.hide();
	}
	if(valueStart == "otherThing"){
		var thingId = this.value.slice(11);

		var getFieldValues = function() {
			var fieldInOtherThingId = this.value;
			var url = location.pathname + "?func=selectDefaultFieldValue;thingId=" + thingId + ";fieldInOtherThingId=" + fieldInOtherThingId + ";fieldId=" + fieldId;

			var handleSuccess = function(o){
				defaultFieldInThing_module.setBody(o.responseText);
				defaultFieldInThing_module.show();
			};
			
			var handleFailure = function(o) {
				alert("Get field values failed: " + o.status);
			};
			
			var callback =
			{
				success:handleSuccess,
				failure:handleFailure
			};
			
			var request = YAHOO.util.Connect.asyncRequest('GET', url, callback);
	
		};

		if (fieldInThing_module_rendered == thingId){
			fieldInThing_module.show();
			defaultFieldInThing_module.show();
		}else{	
			var url = location.pathname + "?func=selectFieldInThing;thingId=" + thingId + ";prefix=" +prefix + ";fieldId=" + fieldId;
			var handleSuccess = function(o){
				fieldInThing_module.setBody(o.responseText);
				fieldInThing_module.show();
				fieldInThing_module_rendered = thingId;
				YAHOO.util.Event.onContentReady(prefix+"_fieldInOtherThing_formId",getFieldValues);
				YAHOO.util.Event.addListener(prefix+"_fieldInOtherThing_formId","change", getFieldValues);

			};
			
			var handleFailure = function(o) {
				alert("Get fields in thing failed: " + o.status);
			};
			
			var callback =
			{
			success:handleSuccess,
			failure:handleFailure
			};
			
			var request = YAHOO.util.Connect.asyncRequest('GET', url, callback);
		}
	}else{
		fieldInThing_module.hide();
		defaultFieldInThing_module.hide();
	}
    }
}

function editListItem(url,fieldId,copy) {

	var handleGetFormSuccess = function(o){
		
		var handleSuccess = function(o) {
			var response = o.responseText;
			var listItemId = response.slice(0,22); 
			var newInnerHTML = response.slice(22);
			var label = editFieldDialog.getData().label;
			
            if(copy){
                addListItemHTML(listItemId, newInnerHTML,label);
            }

			var li = new YAHOO.util.Element(listItemId);
			li.set('innerHTML',newInnerHTML);
			var search_label = new YAHOO.util.Element("search_label_"+listItemId);
			search_label.set('innerHTML',label);
			var view_label = new YAHOO.util.Element("view_label_"+listItemId);
			view_label.set('innerHTML',label);
		};
		
		var handleFailure = function(o) {
			alert("Submission failed: " + o.status);
		};
		
		var handleSubmit = function() {
			this.submit();
		};
		var handleCancel = function() {
			this.cancel();
			this.destroy();
		};
		function optionalFields() {
			initOptionalFields(dialogId,fieldId);
		}

		var dialogId = "edit_"+fieldId+"_Dialog";
        if(copy){
            dialogId = dialogId + '_copy';
        }

        editFieldDialog = new YAHOO.widget.Dialog(dialogId, { width:"460px", visible:false, draggable:true,close:true, fixedcenter:true, zIndex:11001, height: "430px",
        autofillheight:null,
		buttons : [ { text:"Submit", handler:handleSubmit, isDefault:true }, 
				{ text:"Cancel", handler:handleCancel } ]
		} );
			
		if(copy){
            editFieldDialog.setHeader("Copy Field");
        }else{
            editFieldDialog.setHeader("Edit Field");
        }
        editFieldDialog.setBody(o.responseText);
		editFieldDialog.render(document.body);
		editFieldDialog.callback = { success: handleSuccess, failure: handleFailure };
		editFieldDialog.show();
        YAHOO.util.Event.onContentReady(dialogId, optionalFields);
        initHoverHelp(dialogId);

	};

	var handleGetFormFailure = function(o) {
		alert("Getting edit field dialog failed: " + o.status);
	};
	
	var callbackGetForm =
	{
		success:handleGetFormSuccess,
		failure:handleGetFormFailure,
		cache:false 
	};
	
	var request = YAHOO.util.Connect.asyncRequest('GET', url, callbackGetForm);
}

function addListItemHTML(listItemId, newInnerHTML,label){
    var ul1 = new YAHOO.util.Element('ul1');
		var li = document.createElement('li');
		li.id = listItemId;
		li.className = 'list1';
		li.innerHTML = newInnerHTML;
		ul1.appendChild(li);
		var newListItem = Dom.get(listItemId);
		new YAHOO.draglist.DDList(newListItem);
		
		// Add table row to fields on search tab
		var search_fields_table = new YAHOO.util.Element('search_fields_table'); 
		var search_fields_table_rows = search_fields_table.getElementsByTagName("tr");
		var search_tr = document.createElement('tr');
		search_tr.id = "search_tr_"+listItemId;
		search_fields_table.appendChild(search_tr);
		
		var label_td = document.createElement('td');
		label_td.id = "search_label_"+listItemId;
		label_td.className = 'formDescription';
		label_td.innerHTML = label;
		search_tr.appendChild(label_td);
		
		var displayInSearch_td = document.createElement('td');
		displayInSearch_td.id = "search_displayInSearch_"+listItemId;
		displayInSearch_td.className = 'tableData';
		displayInSearch_td.innerHTML = "<input type='checkbox' name='displayInSearch_"+listItemId+"' value='1' checked='checked'  />";
		search_tr.appendChild(displayInSearch_td);
		
		var searchIn_td = document.createElement('td');
		searchIn_td.id = "search_searchIn_"+listItemId;
		searchIn_td.className = 'tableData';
		// only the first field should be checked by default
		if (search_fields_table_rows.length == 2){
			searchIn_td.innerHTML = "<input type='checkbox' name='searchIn_"+listItemId+"' value='1' checked='checked' />";
		}else{
		        searchIn_td.innerHTML = "<input type='checkbox' name='searchIn_"+listItemId+"' value='1' />";
		}
		search_tr.appendChild(searchIn_td);
		
		var sortBy_td = document.createElement('td');
		sortBy_td.id = "search_sortBy_"+listItemId;
		sortBy_td.className = 'tableData';
		sortBy_td.innerHTML = "<input type='radio' name='sortBy' value='"+listItemId+"' />";
		search_tr.appendChild(sortBy_td);
		
		// Add table row to fields on view tab
		var view_fields_table = new YAHOO.util.Element('view_fields_table'); 
		var view_fields_table_rows = view_fields_table.getElementsByTagName("tr");
		var view_tr = document.createElement('tr');
		view_tr.id = "view_tr_"+listItemId;
		view_fields_table.appendChild(view_tr);
		
		var view_label_td = document.createElement('td');
		view_label_td.id = "view_label_"+listItemId;
		view_label_td.className = 'formDescription';
		view_label_td.innerHTML = label;
		view_tr.appendChild(view_label_td);
		
		var display_td = document.createElement('td');
		display_td.id = "view_display_"+listItemId;
		display_td.className = 'tableData';
		display_td.innerHTML = "<input type='checkbox' name='display_"+listItemId+"' value='1' checked='checked'  />";
		view_tr.appendChild(display_td);
		
		var viewScreenTitle_td = document.createElement('td');
		viewScreenTitle_td.id = "view_viewScreenTitle_"+listItemId;
		viewScreenTitle_td.className = 'tableData';

		// only the first field should be checked by default
		if (view_fields_table_rows.length == 2){
			viewScreenTitle_td.innerHTML = "<input type='checkbox' name='viewScreenTitle_"+listItemId+"' value='1' checked='checked'/>";
		}else{
			viewScreenTitle_td.innerHTML = "<input type='checkbox' name='viewScreenTitle_"+listItemId+"' value='1' />";
		}
		view_tr.appendChild(viewScreenTitle_td);
}


function initAddFieldDialog() {

    var handleSuccess = function(o) {
        var response = o.responseText;
        var listItemId = response.slice(0,22);
        var newInnerHTML = response.slice(22);
        var label = addFieldDialog.getData().label;
        addListItemHTML(listItemId, newInnerHTML,label);
      
	};
	
	var handleFailure = function(o) {
	alert("Submission failed: " + o.status);
	};

	var handleSubmit = function() {
	this.submit();
	};
	var handleCancel = function() {
	this.cancel();
	};

	var addFieldDialog = new YAHOO.widget.Dialog("addDialog", { width:"460px", visible:false,
	draggable:true, close:true, fixedcenter:true, zIndex:11002, height: "430px",
	autofillheight:null,
	buttons : [ { text:"Submit", handler:handleSubmit, isDefault:true }, 
			{ text:"Cancel", handler:handleCancel } ]
	} );
	addFieldDialog.callback = { success: handleSuccess, failure: handleFailure };
	addFieldDialog.render();

	initOptionalFields("addDialog"); 

	YAHOO.util.Event.addListener("showAddFormButton", "click", addFieldDialog.show, addFieldDialog, true);

}

YAHOO.util.Event.addListener(window, "load", initAddFieldDialog);


function deleteListItem (url,listItemId,thingId) {

if (confirm("Are you sure you want to delete this field?")){

	var handleSuccess = function(o){
	
		var ul1 = new YAHOO.util.Element('ul1'); 
		var removeElement = YAHOO.util.Dom.get(listItemId);
		ul1.removeChild(removeElement);
		
		var search_fields_table = new YAHOO.util.Element('search_fields_table'); 
		removeElement = YAHOO.util.Dom.get("search_tr_"+listItemId);
		search_fields_table.removeChild(removeElement);
		
		var view_fields_table = new YAHOO.util.Element('view_fields_table'); 
		removeElement = YAHOO.util.Dom.get("view_tr_"+listItemId);
		view_fields_table.removeChild(removeElement);
	
	};
	
	var handleFailure = function(o) {
	alert("Submission failed: " + o.status);
	};
	
	var callback =
	{
	success:handleSuccess,
	failure:handleFailure
	};
	
	var postData = "func=deleteFieldConfirm;fieldId=" + listItemId + ";thingId=" + thingId;
	var request = YAHOO.util.Connect.asyncRequest('POST', url, callback, postData);
		
	}
}

var Dom = YAHOO.util.Dom;
var Event = YAHOO.util.Event;
var DDM = YAHOO.util.DragDropMgr;
YAHOO.namespace ("draglist");

(function() {


YAHOO.draglist.DDApp = {
    init: function() {


        new YAHOO.util.DDTarget("ul1");
	var ul1=Dom.get("ul1");
	var items = ul1.getElementsByTagName("li");
        for (i=0;i<items.length;i=i+1) {
        	new YAHOO.draglist.DDList(items[i].id);
        }

    }

};

YAHOO.draglist.DDList = function(id, sGroup, config) {

    YAHOO.draglist.DDList.superclass.constructor.call(this, id, sGroup, config);

    this.logger = this.logger || YAHOO;
    var el = this.getDragEl();
	
    Dom.setStyle(el, "opacity", 0.67); // The proxy is slightly transparent
	this.setXConstraint(0,0);

    this.goingUp = false;
    this.lastY = 0;
};

var getRank = function(ul,curId) {
            var items = ul.getElementsByTagName("li");
            var rank;
		for (i=0;i<items.length;i=i+1) {
                if(items[i].id == curId){
			rank = i;
		}
            }
            return rank;
};

var destination = "";
var direction = "";
var origRank = "";

YAHOO.extend(YAHOO.draglist.DDList, YAHOO.util.DDProxy, {
	
    startDrag: function(x, y) {
        this.logger.log(this.id + " startDrag");

        // make the proxy look like the source element
        var dragEl = this.getDragEl();
        var clickEl = this.getEl();
	origRank = getRank(clickEl.parentNode,clickEl.id);
        Dom.setStyle(clickEl, "opacity", 0.20);

        dragEl.innerHTML = clickEl.innerHTML;

        Dom.setStyle(dragEl, "color", Dom.getStyle(clickEl, "color"));
        Dom.setStyle(dragEl, "backgroundColor", Dom.getStyle(clickEl, "backgroundColor"));
        Dom.setStyle(dragEl, "border", "2px solid gray");
    },

    endDrag: function(e) {

        var srcEl = this.getEl();
        var proxy = this.getDragEl();

	var doAnimation = function (){
		Dom.setStyle(proxy, "visibility", "");
		var a = new YAHOO.util.Motion( 
		proxy, { 
			points: { 
			to: Dom.getXY(srcEl)
			}
		}, 
		0.2, 
		YAHOO.util.Easing.easeOut 
		)
		var proxyid = proxy.id;
		var thisid = srcEl.id;
	
		// Hide the proxy and show the source element when finished with the animation
		a.onComplete.subscribe(function() {
			Dom.setStyle(proxyid, "visibility", "hidden");
			//Dom.setStyle(thisid, "visibility", "");
			Dom.setStyle(thisid, "opacity", 1);
		});
		a.animate();
	}
	var curRank = getRank(srcEl.parentNode,srcEl.id);

	if (destination == "" || origRank == curRank){
		doAnimation();
	}
	else{
		var handleSuccess = function(o){
		
			// Show the proxy element and animate it to the src element's location
			if (o.responseText == "fieldMoved"){
				doAnimation();
			}else{
				alert('wrong response from moveFieldConfirm : ' + o.responseText);
			}
		};
		
		var handleFailure = function(o) {
		alert("Submission failed: " + o.status);
		};
		
		var callback =
		{
		success:handleSuccess,
		failure:handleFailure
		};
		var url = location.pathname;
		//curRank = curRank +1;
		//origRank = origRank +1;
		var postData = "func=moveFieldConfirm;fieldId=" + srcEl.id + ";targetFieldId=" + destination+";direction="+direction;//currentRank="+curRank+";originalRank="+origRank+";
		var request = YAHOO.util.Connect.asyncRequest('POST', url, callback, postData);
	}


    },

    onDragDrop: function(e, id) {

        // If there is one drop interaction, the li was dropped either on the list,
        // or it was dropped on the current location of the source element.
        if (DDM.interactionInfo.drop.length === 1) {
		
            // The position of the cursor at the time of the drop (YAHOO.util.Point)
            var pt = DDM.interactionInfo.point; 

            // The region occupied by the source element at the time of the drop
            var region = DDM.interactionInfo.sourceRegion; 
		
            // Check to see if we are over the source element's location.  We will
            // append to the bottom of the list once we are sure it was a drop in
            // the negative space (the area of the list without any list items)
            if (!region.intersect(pt)) {
                var destEl = Dom.get(id);
                var destDD = DDM.getDDById(id);
		destEl.appendChild(this.getEl());
                destDD.isEmpty = false;
                DDM.refreshCache();
            }
        }
    },

    onDrag: function(e) {

        // Keep track of the direction of the drag for use during onDragOver
        var y = Event.getPageY(e);

        if (y < this.lastY) {
            this.goingUp = true;
        } else if (y > this.lastY) {
            this.goingUp = false;
        }

        this.lastY = y;
    },

    onDragOver: function(e, id) {
    
        var srcEl = this.getEl();
        var destEl = Dom.get(id);

        // We are only concerned with list items, we ignore the dragover
        // notifications for the list.
        if (destEl.nodeName.toLowerCase() == "li") {
            var orig_p = srcEl.parentNode;
            var p = destEl.parentNode;
	destination = destEl.id;
            if (this.goingUp) {
		direction = 'up';
		p.insertBefore(srcEl, destEl); // insert above
            } else {
		direction = 'down';
                p.insertBefore(srcEl, destEl.nextSibling); // insert below
            }

            DDM.refreshCache();
        }
    }
});

Event.onDOMReady(YAHOO.draglist.DDApp.init, YAHOO.draglist.DDApp, true);

})();
