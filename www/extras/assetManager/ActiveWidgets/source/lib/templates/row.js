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

Active.Templates.Row = Active.Templates.List.subclass();

Active.Templates.Row.create = function(){

/****************************************************************

	Grid row template.

*****************************************************************/

	var obj = this.prototype;
	var _super = this.superclass.prototype;

//	------------------------------------------------------------

	obj.setTag("div");
	obj.setClass("templates", "row");
	obj.setClass("grid", "row");

//	------------------------------------------------------------

	obj.getDataProperty = function(property, i){
		return this.$owner.getDataProperty(property, this.$index, i);
	};

	obj.setDataProperty = function(property, value, i){
		return this.$owner.setDataProperty(property, value, this.$index, i);
	};

	obj.getItemsProperty = function(property){
		return this.getColumnProperty(property);
	};

	obj.getSelectionProperty = function(property){
		return this.getDummyProperty(property);
	};

	obj.getRowProperty = function(property){
		return this.$owner.getItemsProperty(property, this.$index);
	};

//	------------------------------------------------------------

	var getItemProperty = function(property){
		return this.$owner.getDataProperty(property, this.$index);
	};

	var setItemProperty = function(property, value){
		return this.$owner.setDataProperty(property, value, this.$index);
	};

	var getColumnProperty = function(property){
		return this.$owner.getColumnProperty(property, this.$index);
	};

	obj.getItemTemplate = function(i){
		if (!this._itemTemplates) {
			this._itemTemplates = [];
		}

		if (this._itemTemplates[i]) {
			this._itemTemplates[i]._id = this._id + ".item:" + i;
			return this._itemTemplates[i];
		}

		if (typeof(i)=="undefined") {return _super.getItemTemplate.call(this)}

		var template = _super.getItemTemplate.call(this, i).clone();
		template.$index = i;
		template.setClass("column", i);
		this._itemTemplates[i] = template;
		return template;
	};

	obj.setItemTemplate = function(template, i){

		template.getItemProperty = getItemProperty;
		template.setItemProperty = setItemProperty;
		template.getColumnProperty = getColumnProperty;

		template.setClass("row", "cell");
		template.setClass("grid", "column");

		if (typeof(i)=="undefined") {return _super.setItemTemplate.call(this, template)}

		template.setClass("column", i);

		template.$owner = this;
		template.$index = i;

		if (!this._itemTemplates) {
			this._itemTemplates = [];
		}
		this._itemTemplates[i] = template;
	};

//	------------------------------------------------------------

	var selectRow = function(event){
		if (event.shiftKey) {return this.action("selectRangeOfRows")}
		if (event.ctrlKey) {return this.action("selectMultipleRows")}
		this.action("selectRow");
	};

	//obj.setEvent("onclick", selectRow);

};

Active.Templates.Row.create();