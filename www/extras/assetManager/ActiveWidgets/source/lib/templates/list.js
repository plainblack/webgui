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

Active.Templates.List = Active.System.Template.subclass();

Active.Templates.List.create = function(){

/****************************************************************

	List box template.

*****************************************************************/

	var obj = this.prototype;

//	list does not have html element (provides content only)
	obj.setTag("");

	obj.defineTemplate("item", new Active.Templates.Text);

//	redirect item property request to data property (index)
	var getItemProperty = function(property){
		return this.$owner.getDataProperty(property, this.$index);
	};

	var setItemProperty = function(property, value){
		return this.$owner.setDataProperty(property, value, this.$index);
	};

	obj.getItemTemplate = function(index, temp){
		var template = this.defaultItemTemplate(index);

		if (!temp) {temp = []}

		if (!temp.selected) {
			temp.selected = [];

			var i, values = this.getSelectionProperty("values");
			for (i=0; i<values.length; i++) {temp.selected[values[i]]=true}

			template.getItemProperty = getItemProperty;
			template.setItemProperty = setItemProperty;
			template.setClass("list", "item");
		}

		if (temp.selected[index]){
			template = template.clone();
			template.$index = "";
			template.setClass("selection", true);
			template.$index = index;
		}

		return template;
	};


//	------------------------------------------------------------

	var html = function(){
		var i, result = [], temp = [], items = this.getItemsProperty("values");
		for(i=0; i<items.length; i++) {result[i] = this.getItemTemplate(items[i], temp).toString()}
		return result.join("");
	};

	obj.setContent("html", html);

//	------------------------------------------------------------

};

Active.Templates.List.create();