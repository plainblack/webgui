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

Active.XML.Table = Active.HTTP.Request.subclass();

Active.XML.Table.create = function(){

/****************************************************************

	Table model for loading and parsing data in XML format.

*****************************************************************/

	var obj = this.prototype;
	var _super = this.superclass.prototype;

/****************************************************************

	Allows to process the received data.

	@param xml (DOMDocument) The received data.

*****************************************************************/

	obj.response = function(xml){
		this.setXML(xml);
		_super.response.call(this);
	};

/****************************************************************

	Sets or retrieves the XML document (or string).

*****************************************************************/

	obj.defineProperty("XML");

	obj.setXML = function(xml){

		if (!xml.nodeType) {
			var s = "" + xml;
			xml = window.ActiveXObject ? new ActiveXObject("MSXML2.DOMDocument") : new XMLDocument;
			xml.loadXML(s);
		}

		xml.setProperty("SelectionLanguage", "XPath");
		if (this._namespaces) {xml.setProperty("SelectionNamespaces", this._namespaces);}

		this._xml = xml;
		this._data = this._xml.selectSingleNode(this._dataPath);
		this._items = this._data ? this._data.selectNodes(this._itemPath) : null;
		this._ready = true;
	};

	obj.getXML = function(){
		return this._xml;
	};

	obj._dataPath = "*";
	obj._itemPath = "*";
	obj._valuePath = "*";
	obj._valuesPath = [];
	obj._formats = [];

/****************************************************************

	Sets the XPath expressions to retrieve values for each column.

	@param array (Array) The array of XPaths expressions.

*****************************************************************/

	obj.setColumns = function(array){
		this._valuesPath = array;
	};

/****************************************************************

	Specifies the XPath expression to retrieve the set of rows.

	@param xpath (String) The xpath expression.

*****************************************************************/

	obj.setRows = function(xpath){
		this._itemPath = xpath;
	};

/****************************************************************

	Specifies the XPath expression to select the table root element.

	@param xpath (String) The xpath expression.

*****************************************************************/

	obj.setTable = function(xpath){
		this._dataPath = xpath;
	};

/****************************************************************

	Allows to specify the formatting object for the column.

	@param format (Object) The formatting object.
	@param index (Index) The column index.

*****************************************************************/

	obj.setFormat = function(format, index){
		this._formats = this._formats.concat();
		this._formats[index] = format;
	};

/****************************************************************

	Allows to specify the formatting objects for each column.

	@param formats (Array) The array of formatting objects.

*****************************************************************/

	obj.setFormats = function(formats){
		this._formats = formats;
	};

/****************************************************************

	Returns the number of the data rows.

*****************************************************************/

	obj.getCount = function(){
		if (!this._items) {return 0}
		return this._items.length;
	};

/****************************************************************

	Returns the index.

*****************************************************************/

	obj.getIndex = function(i){
		return i;
	};

/****************************************************************

	Returns the cell text.

	@param i (Index) Row index.
	@param j (Index) Column index.

*****************************************************************/

	obj.getText = function(i, j){
		var node = this.getNode(i, j);
		var data = node ? node.text : "";
		var format = this._formats[j];
		return format ? format.dataToText(data) : data;
	};

/****************************************************************

	Returns the cell image.

	@param i (Index) Row index.
	@param j (Index) Column index.

*****************************************************************/

	obj.getImage = function(){
		return "none";
	};

/****************************************************************

	Returns the cell hyperlink.

	@param i (Index) Row index.
	@param j (Index) Column index.

*****************************************************************/

	obj.getLink = function(){
		return "";
	};

/****************************************************************

	Returns the cell value.

	@param i (Index) Row index.
	@param j (Index) Column index.

*****************************************************************/

	obj.getValue = function(i, j){
		var node = this.getNode(i, j);
		var text = node ? node.text : "";
		var format = this._formats[j];
		if (format) {
			return format.dataToValue(text);
		}
		var value = Number(text.replace(/[ ,%\$]/gi, "").replace(/\((.*)\)/, "-$1"));
		return isNaN(value) ? text.toLowerCase() + " " : value;
	};

/****************************************************************

	Returns the cell XML node text (internal).

	@param i (Index) Row index.
	@param j (Index) Column index.

*****************************************************************/

	obj.getNode = function(i, j){
		if (!this._items || !this._items[i]) {
			return null;
		}
		if (this._valuesPath[j]) {
			return this._items[i].selectSingleNode(this._valuesPath[j]);
		}
		else {
			return this._items[i].selectNodes(this._valuePath)[j];
		}
	};

/****************************************************************

	Returns the cell XML node text (obsolete, don't use).

	@param i (Index) Row index.
	@param j (Index) Column index.

*****************************************************************/

	obj.getData = function(i, j){
		if (!this._items) {return null}
		var node = null;
		if (this._valuesPath[j]) {
			node = this._items[i].selectSingleNode(this._valuesPath[j]);
		}
		else {
			node = this._items[i].selectNodes(this._valuePath)[j];
		}
		return node ? node.text : null;
	};

};

Active.XML.Table.create();