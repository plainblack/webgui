/*****************************************************************

	ActiveWidgets Grid 1.0.0 (Free Edition).
	Copyright (C) 2004 ActiveWidgets Ltd. All Rights Reserved. 
	More information at http://www.activewidgets.com/

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*****************************************************************/

Active.Controls.Grid = Active.System.Control.subclass();

Active.Controls.Grid.create = function(){

/****************************************************************

	Scrollable grid con trol. Displays data in a table with fixed
	headers, resizable columns, client-side sorting and much more.

*****************************************************************/

	var obj = this.prototype;

	obj.setClass("controls", "grid");

/****************************************************************

	Splits the grid display into the four scrolling areas.

*****************************************************************/

	obj.defineTemplate("layout", new Active.Templates.Scroll);

/****************************************************************

	Contains the main area of the grid.

*****************************************************************/

	obj.defineTemplate("main", function(){

		switch (this.getStatusProperty("code")) {
			case "":
				return this.getDataTemplate();
			case "error":
				return this.getErrorTemplate();
			default:
				return this.getStatusTemplate();
		}
	});

/****************************************************************

	Contains the list of data rows.

*****************************************************************/

	obj.defineTemplate("data", new Active.Templates.List);

/****************************************************************

	Contains the row headings area.

*****************************************************************/

	obj.defineTemplate("left", new Active.Templates.List);

/****************************************************************

	Contains the column headings area.

*****************************************************************/

	obj.defineTemplate("top", new Active.Templates.List);

/****************************************************************

	Displays control status text.

*****************************************************************/

	obj.defineTemplate("status", new Active.Templates.Status);

/****************************************************************

	Displays error text.

*****************************************************************/

	obj.defineTemplate("error",	new Active.Templates.Error);

/****************************************************************

	Grid row template.

*****************************************************************/

	obj.defineTemplate("row", new Active.System.Template);

/****************************************************************

	Grid column (cell) template.

*****************************************************************/

	obj.defineTemplate("column", new Active.System.Template);

	obj.getColumnTemplate = function(i){return this.getTemplate("data/item/item", i)};
	obj.setColumnTemplate = function(template, i){this.setTemplate("data/item/item", template, i)};

	obj.getRowTemplate = function(i){return this.getTemplate("data/item", i)};
	obj.setRowTemplate = function(template, i){this.setTemplate("data/item", template, i)};

	obj.setTemplate("data/item", 	new Active.Templates.Row);
	obj.setTemplate("left/item",	new Active.Templates.Item);
	obj.setTemplate("top/item", 	new Active.Templates.Header);


/****************************************************************

	Specifies the row indices and the row headers data.
	It defines which data rows and in which order should be requested
	from the data model for the grid display.

*****************************************************************/

	obj.defineModel("row");

/****************************************************************

	Sets or retrieves the number of rows in the grid.

	@remarks

	Setting row count will re-initialize row values array to 0..count-1

*****************************************************************/

	obj.defineRowProperty("count", function(){return this.getDataProperty("count")} );

/****************************************************************

	Retrieves the row index.

*****************************************************************/

	obj.defineRowProperty("index", function(i){return i});

/****************************************************************

	Retrieves the display order for the row.

*****************************************************************/

	obj.defineRowProperty("order", function(i){return i});

/****************************************************************

	Allows to specify the text for the row headers.

*****************************************************************/

	obj.defineRowPropertyArray("text", function(i){return this.getRowOrder(i) + 1});

/****************************************************************

	Allows to specify the image to display in the row headers.

*****************************************************************/

	obj.defineRowPropertyArray("image", "none");

/****************************************************************

	Sets or retrieves the row index or the array of indexes.

*****************************************************************/

	obj.defineRowPropertyArray("value", function(i){return i});

/****************************************************************

	Specifies the column indices and the column headers data.
	Defines which data items should be displayed in each column.

*****************************************************************/

	obj.defineModel("column");

/****************************************************************

	Sets or retrieves the number of columns in the grid.

*****************************************************************/

	obj.defineColumnProperty("count", 0 );

/****************************************************************

	Retrieves the column index.

*****************************************************************/

	obj.defineColumnProperty("index", function(i){return i});

/****************************************************************

	Retrieves the display order for the column.

*****************************************************************/

	obj.defineColumnProperty("order", function(i){return i});

/****************************************************************

	Allows to specify the text for the column headers.

*****************************************************************/

	obj.defineColumnPropertyArray("text", function(i){return "Column " + i});

/****************************************************************

	Allows to specify the image to display in the column headers.

*****************************************************************/

	obj.defineColumnPropertyArray("image", "none");

/****************************************************************

	Sets or retrieves the column index or the array of indexes.

*****************************************************************/

	obj.defineColumnPropertyArray("value", function(i){return i});

/****************************************************************

	Allows to specify the tooltips text for the column headers.

*****************************************************************/

	obj.defineColumnPropertyArray("tooltip", "");

/****************************************************************

	Provides the content to display inside the grid cells.

*****************************************************************/

	obj.defineModel("data");

/****************************************************************

	Sets or retrieves the number of data items (rows).

*****************************************************************/

	obj.defineDataProperty("count", 0);

/****************************************************************

	Retrieves the data item index (row).

*****************************************************************/

	obj.defineDataProperty("index", function(i){return i});

/****************************************************************

	Allows to specify the text for the grid cells.

*****************************************************************/

	obj.defineDataProperty("text", "");

/****************************************************************

	Allows to specify the image to display in the grid cells.

*****************************************************************/

	obj.defineDataProperty("image", "none");

/****************************************************************

	Allows to specify the link URL for a cell.
	Use Active.Templates.Link as a column template.

*****************************************************************/

	obj.defineDataProperty("link", "");

/****************************************************************

	Provides the value to be used for sorting the data.

*****************************************************************/

	obj.defineDataProperty("value", function(i,j){
		var text = "" + this.getDataText(i, j);
		var value = Number(text.replace(/[ ,%\$]/gi, "").replace(/\((.*)\)/, "-$1"));
		return isNaN(value) ? text.toLowerCase() + " " : value;
	});

/****************************************************************

	Items model.

*****************************************************************/

	obj.defineModel("items"); 

/****************************************************************

	Used as a stub where no actual data is required.

*****************************************************************/

	obj.defineModel("dummy");
	obj.defineDummyProperty("count", 0);
	obj.defineDummyPropertyArray("value", -1);

/****************************************************************

	Controls the row/column/cell selection.

*****************************************************************/

	obj.defineModel("selection");

/****************************************************************

	Sets or retrieves the active cell index.

*****************************************************************/

	obj.defineSelectionProperty("index", -1); 

/****************************************************************

	Specifies if multiple selection is allowed.

*****************************************************************/

	obj.defineSelectionProperty("multiple", false);

/****************************************************************

	Provides the number of selected items.

*****************************************************************/

	obj.defineSelectionProperty("count", 0);

/****************************************************************

	Provides the array of the selected item indices.

*****************************************************************/

	obj.defineSelectionPropertyArray("value", 0);

/****************************************************************

	Controls sorting of the grid rows.

*****************************************************************/

	obj.defineModel("sort");

/****************************************************************

	Specifies the index of a column to sort data on.

*****************************************************************/

	obj.defineSortProperty("index", -1);

/****************************************************************

	Specifies the sort direction.

*****************************************************************/

	obj.defineSortProperty("direction", "none");

/****************************************************************

	Provides control status.

*****************************************************************/

	obj.defineModel("status");

/****************************************************************

	Provides status code.

*****************************************************************/

	obj.defineStatusProperty("code", function(){

		var data = this.getDataModel();
		if (!data.isReady()) {
			return "loading";
		}
		if (!this.getRowProperty("count")) {
			return "nodata";
		}
		return "";
	});

/****************************************************************

	Provides status text.

*****************************************************************/

	obj.defineStatusProperty("text", function(){

		switch(this.getStatusProperty("code")) {
			case "loading":
				return "Loading data, please wait...";
			case "nodata":
				return "No data found.";
			default:
				return "";
		}
	});

/****************************************************************

	Provides status image.

*****************************************************************/

	obj.defineStatusProperty("image", function(){

		switch(this.getStatusProperty("code")) {
			case "loading":
				return "loading";
			default:
				return "none";
		}
	});

/****************************************************************

	Provides error information.

*****************************************************************/

	obj.defineModel("error");

/****************************************************************

	Provides error code.

*****************************************************************/

	obj.defineErrorProperty("code", 0);

/****************************************************************

	Provides error text.

*****************************************************************/

	obj.defineErrorProperty("text", "");



//	------------------------------------------------------------
//	------------------------------------------------------------

	obj.getLeftTemplate = function(){
		var template = this.defaultLeftTemplate();
		template.setDataModel(this.getRowModel());
		template.setItemsModel(this.getRowModel());
		template.setSelectionModel(this.getDummyModel());
		return template;
	};

//	------------------------------------------------------------

	obj.getTopTemplate = function(){
		var template = this.defaultTopTemplate();
		template.setDataModel(this.getColumnModel());
		template.setItemsModel(this.getColumnModel());
		template.setSelectionModel(this.getDummyModel());
		return template;
	};

//	------------------------------------------------------------

	obj.getDataTemplate = function(){
		var template = this.defaultDataTemplate();
		template.setDataModel(this.getDataModel());
		template.setItemsModel(this.getRowModel());
		return template;
	};

//	------------------------------------------------------------

	obj.setContent(function(){return this.getLayoutTemplate()});

/****************************************************************

	Allows to specify the height of the column headers.

	@param	height (Number) The new height value.


*****************************************************************/

	obj.setColumnHeaderHeight = function(height){
		var layout = this.getTemplate("layout");
		layout.getContent("top").setStyle("height", height);
		layout.getContent("corner").setStyle("height", height);
		layout.getContent("left").setStyle("padding-top", height);
		layout.getContent("data").setStyle("padding-top", height);
	};

/****************************************************************

	Allows to specify the width of the row headers.

	@param	width (Number) The new width value.

*****************************************************************/

	obj.setRowHeaderWidth = function(width){
		var layout = this.getTemplate("layout");
		layout.getContent("left").setStyle("width", width);
		layout.getContent("corner").setStyle("width", width);
		layout.getContent("top").setStyle("padding-left", width);
		layout.getContent("data").setStyle("padding-left", width);
	};

//	------------------------------------------------------------

	var startColumnResize = function(header){

		
		var el = header.element();
		var pos = event.clientX;
		var size = el.offsetWidth;
		var grid = this;

		var doResize = function(){
			var el = header.element();
			var sz = size + event.clientX - pos;
			el.style.width = sz < 5 ? 5 : sz;
			el = null;
		};

		var endResize = function(){

			var el = header.element();

			if( typeof el.onmouseleave == "function") {
				el.onmouseleave();
			}

			el.detachEvent("onmousemove", doResize);
			el.detachEvent("onmouseup", endResize);
			el.detachEvent("onlosecapture", endResize);
			el.releaseCapture();

			var width = size + event.clientX - pos;
			if (width < 5) {width = 5}
			el.style.width = width;

			var ss = document.styleSheets[document.styleSheets.length-1];
			var i, selector = "#" + grid.getId() + " .active-column-" + header.getItemProperty("index");
			for(i=0; i<ss.rules.length;i++){
				if(ss.rules[i].selectorText == selector){
					ss.rules[i].style.width = width;
					el = null;
					grid.getTemplate("layout").action("adjustSize");
					return; 
				}
			}
			ss.addRule(selector, "width:" + width + "px");
			el = null;
			grid.getTemplate("layout").action("adjustSize");
		};

		el.attachEvent("onmousemove", doResize);
		el.attachEvent("onmouseup", endResize);
		el.attachEvent("onlosecapture", endResize);
		el.setCapture();

//		break object reference to avoid memory leak
		el = null;

		event.cancelBubble = true;
	};

	obj.setAction("startColumnResize", startColumnResize);

//	------------------------------------------------------------

	var setSelectionIndex = obj.setSelectionIndex;

	obj.setSelectionIndex = function(index){

		setSelectionIndex.call(this, index);
		this.setSelectionValues([index]);

		var row = this.getTemplate("row", index);
		var data = this.getTemplate("layout").getContent("data");
		var left = this.getTemplate("layout").getContent("left");
		var scrollbars = this.getTemplate("layout").getContent("scrollbars");

		try {
			var top, padding = parseInt(data.element().currentStyle.paddingTop);
			if (data.element().scrollTop > row.element().offsetTop - padding) {
				top = row.element().offsetTop  - padding;
				left.element().scrollTop = top;
				data.element().scrollTop = top;
				scrollbars.element().scrollTop = top;
			}

			if (data.element().offsetHeight + data.element().scrollTop <
				row.element().offsetTop + row.element().offsetHeight ) {
				top = row.element().offsetTop + row.element().offsetHeight - data.element().offsetHeight;
				left.element().scrollTop = top;
				data.element().scrollTop = top;
				scrollbars.element().scrollTop = top;
			}
		}
		catch(error){
			// ignore errors
		}
	};

//	------------------------------------------------------------

	var setSelectionValues = obj.setSelectionValues;

	obj.setSelectionValues = function(array){
		var i, current = this.getSelectionValues();
		setSelectionValues.call(this, array);

		for (i=0; i<current.length; i++) {
			this.getRowTemplate(current[i]).refreshClasses();
		}

		for (i=0; i<array.length; i++) {
			this.getRowTemplate(array[i]).refreshClasses();
		}

		this.action("selectionChanged");
	};

//	------------------------------------------------------------

	var selectRow = function(src){
		this.setSelectionProperty("index", src.getItemProperty("index"));
	};

	var selectMultipleRows = function(src){
		if (!this.getSelectionProperty("multiple")){
			return this.action("selectRow", src);
		}
		var index = src.getItemProperty("index");
		var selection = this.getSelectionProperty("values");
		for (var i=0; i<selection.length; i++){
			if(selection[i]==index){
				selection.splice(i, 1);
				i = -1;
				break;
			}
		}
		if (i!=-1) {
			selection.push(index);
		}
		this.setSelectionProperty("values", selection);
		setSelectionIndex.call(this, index);

		this.getRowTemplate(index).refreshClasses();
		this.action("selectionChanged");
	};


	var selectRangeOfRows = function(src){
		if (!this.getSelectionProperty("multiple")){
			return this.action("selectRow", src);
		}
		var previous = this.getSelectionProperty("index");
		var index = src.getItemProperty("index");

		var row1 = Number(this.getRowProperty("order", previous));
		var row2 = Number(this.getRowProperty("order", index));

		var start = row1 > row2 ? row2 : row1;
		var count = row1 > row2 ? row1 - row2 : row2 - row1;

		var i, selection = [];
		for(i=0; i<=count; i++){
			selection.push(this.getRowProperty("value", start + i));
		}

		this.setSelectionProperty("values", selection);
		setSelectionIndex.call(this, index);

		this.getRowTemplate(index).refreshClasses();
		this.action("selectionChanged");
	};


	obj.setAction("selectRow", selectRow);
	obj.setAction("selectMultipleRows", selectMultipleRows);
	obj.setAction("selectRangeOfRows", selectRangeOfRows);

/****************************************************************

	Sorts the rows with the data in the given column.

	@param 	index (Number) Column index to sort on.
	@param 	direction (String) Sort direction ("ascending" or "descending").

*****************************************************************/

	obj.sort = function(index, direction){

		var model = this.getModel("row");
		if (model.sort) {
			return model.sort(index, direction);
		}

		var a = {};
		var rows = this.getRowProperty("values");

 		if (direction && direction != "ascending" ) {
 			direction = "descending";
 		}
 		else {
 			direction = "ascending";
 		}

		if (this.getSortProperty("index") != index) {
			for (var i=0; i<rows.length; i++) {
				a[rows[i]] = this.getDataProperty("value", rows[i], index);
			}
			rows.sort(function(x,y){return a[x] > a[y] ? 1 : (a[x] == a[y] ? 0 : -1)});
			if (direction == "descending") {
				rows.reverse();
			}
		}
		else if (this.getSortProperty("direction") != direction) {
			rows.reverse();
		}


		this.setRowProperty("values", rows);
		this.setSortProperty("index", index);
		this.setSortProperty("direction", direction);
	};


	obj.setAction("columnSort", function(src){
		var i = src.getItemProperty("index");
		var d = (this.getSortProperty("index") == i) && (this.getSortProperty("direction")=="ascending") ? "descending" : "ascending";
		window.status = "Sorting...";
		this.sort(i, d);
		this.refresh();
		this.timeout(function(){window.status = ""});
	});

//	------------------------------------------------------------

	var _getRowOrder = function(i){
		return this._rowOrders[i];
	};

	var _setRowValues = obj.setRowValues;

	obj.setRowValues = function(values){
		_setRowValues.call(this, values);

		var i, max = values.length, orders = [];
		for(i=0; i<max; i++){
			orders[values[i]] = i;
		}

		this._rowOrders = orders;
		this.getRowOrder = _getRowOrder;
	};

//	------------------------------------------------------------

	obj._kbSelect = function(delta){
		var index = this.getSelectionProperty("index");
		var order = this.getRowProperty("order", index );
		var count = this.getRowProperty("count");
		var newOrder = Number(order) + delta;
		if (newOrder<0) {newOrder = 0}
		if (newOrder>count-1) {newOrder = count-1}
		if (delta == -100) {newOrder = 0}
		if (delta == 100) {newOrder = count-1}
		var newIndex = this.getRowProperty("value", newOrder);
		this.setSelectionProperty("index", newIndex);
	};

	obj.setAction("up", function(){this._kbSelect(-1)});
	obj.setAction("down", function(){this._kbSelect(+1)});
	obj.setAction("pageUp", function(){this._kbSelect(-10)});
	obj.setAction("pageDown", function(){this._kbSelect(+10)});
	obj.setAction("home", function(){this._kbSelect(-100)});
	obj.setAction("end", function(){this._kbSelect(+100)});

//	------------------------------------------------------------

	var kbActions = {
		38 : "up",
		40 : "down",
		33 : "pageUp",
		34 : "pageDown",
		36 : "home",
		35 : "end"	};

	var onkeydown = function(event){
		var action = kbActions[event.keyCode];
		if (action)	{
			this.action(action);
			event.returnValue = false;
			event.cancelBubble = true;
		}
	};

	obj.setEvent("onkeydown", onkeydown);

//	------------------------------------------------------------

	function onmousewheel(event){
		
	 	var scrollbars = this.getTemplate("layout").getContent("scrollbars");
		var delta = scrollbars.element().offsetHeight * event.wheelDelta/480;
		scrollbars.element().scrollTop -= delta;
		event.returnValue = false;
		event.cancelBubble = true;
	}

	obj.setEvent("onmousewheel", onmousewheel);

};

Active.Controls.Grid.create();