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

Active.System.Template = Active.System.HTML.subclass();

Active.System.Template.create = function(){

/****************************************************************

	Generic HTML template class. Template is a re-usable HTML
	fragment aimed to produce markup as part of a larger
	object (control).

	Template can either be a simple element or a complex HTML structure
	and may include calls to other templates as part of the output.

	Templates can access properties of the parent control,
	so the template output will be different depending on
	the control's data. Templates can also accept parameters
	allowing to generate lists or tables of data with the
	single instance of the template.

*****************************************************************/

	var obj = this.prototype;
	var _super = this.superclass.prototype;
	var _pattern = /^(\w+)\W(.+)$/;

	var join = function(){
		var i, s = arguments[0];
		for (i=1; i<arguments.length; i++){s += arguments[i].substr(0,1).toUpperCase() + arguments[i].substr(1)}
		return s;
	};

/****************************************************************

	Retrieves the value of the property.

	@param	name	(String) Property name.
	@return			Property value.

*****************************************************************/

	obj.getProperty = function(name, a, b, c){
		if (name.match(_pattern)) {
			var getProperty = join("get", RegExp.$1, "property");
			if (this[getProperty]) {return this[getProperty](RegExp.$2, a, b, c)}
		}
	};

/****************************************************************

	Assignes the new value to the property.

	@param	name	(String) Property name.
	@param	value	(Any) Property value.

*****************************************************************/

	obj.setProperty = function(name, value, a, b, c){
		if (name.match(_pattern)) {
			var setProperty = join("set", RegExp.$1, "property");
			if (this[setProperty]) {return this[setProperty](RegExp.$2, value, a, b, c)}
		}
	};

/****************************************************************

	Returns the data model object. For a built-in model this method
	will create a temporary proxy attached to the template.

	@param	name	(String) Name of the data model.
	@return			A data model object.

*****************************************************************/

	obj.getModel = function(name){
		var getModel = join("get", name, "model");
		return this[getModel]();
	};

/****************************************************************

	Sets the external data model.

	@param	name	(String) Name of the data model.
	@param	model	(Object) Data model object.

*****************************************************************/

	obj.setModel = function(name, model){
		var setModel = join("set", name, "model");
		return this[setModel](model);
	};

/****************************************************************

	Creates a link to the new content template.

	@param	name	(String) Template name.
	@param	template	(Object) Template object.

*****************************************************************/

	obj.defineTemplate = function(name, template){

		var ref = "_" + name + "Template";
		var get = join("get", name, "template");
		var set = join("set", name, "template");
		var getDefault = join("default", name, "template");

		var name1 = "." + name;
		var name2 = "." + name + ":";

		this[get] = this[getDefault] = function(index){
			if (typeof(this[ref])=="function") {
				return this[ref].call(this, index);
			}
			if (this[ref].$owner != this) {this[set](this[ref].clone())}
			if (typeof(index)=="undefined") {
				this[ref]._id = this._id + name1;
			}
			else {
				this[ref]._id = this._id + name2 + index;
			}
			this[ref].$index = index;
			return this[ref];
		};

		obj[get] = function(a, b, c){
			return this.$owner[get](a, b, c);
		};

		obj[set] = function(template){
			this[ref] = template;
			if (template) {
				template.$owner = this; 
			}
		};

		this[set](template);
	};


/****************************************************************

	Returns the template object.

	@param	name	(String) Template name.
	@return			Template object.

*****************************************************************/

	obj.getTemplate = function(name){
		if (name.match(_pattern)) {
			var get = join("get", RegExp.$1, "template");
			arguments[0] = RegExp.$2;
			var template = this[get]();
			return template.getTemplate.apply(template, arguments);
		}
		else {
			get = join("get", name, "template");
			var i, args = [];
			for(i=1; i<arguments.length; i++) {args[i-1]=arguments[i]}
			return this[get].apply(this, args);
		}
	};

/****************************************************************

	Sets the template.

	@param	name	(String) Template name.
	@param	template (Object) Template object.

*****************************************************************/

	obj.setTemplate = function(name, template, index){
		if (name.match(_pattern)) {
			var get = join("get", RegExp.$1, "template");
			var n = RegExp.$2;
			this[get]().setTemplate(n, template, index);
		}
		else {
			var set = join("set", name, "template");
			this[set](template, index);
		}
	};

/****************************************************************

	Returns the action handler.

	@param	name	(String) Action name.
	@return 		Action handler.

*****************************************************************/

	obj.getAction = function(name){
		return this["_" + name + "Action"];
	};

/****************************************************************

	Sets the action handler.

	@param	name	(String) Action name.
	@param	value	(Function) Action handler.

*****************************************************************/

	obj.setAction = function(name, value){
		this["_" + name + "Action"] = value;
	};

/****************************************************************

	Runs the action.

	@param	name	(String) Action name.
	@param	source	(Object) Action source.

*****************************************************************/

	obj.action = function(name, source, a, b, c){
		if (typeof source == "undefined") {source = this}
		var action = this["_" + name + "Action"];
		if (typeof(action)=="function") {action.call(this, source, a, b, c)}
		else if (this.$owner) {this.$owner.action(name, source, a, b, c)}
	};

};

Active.System.Template.create();