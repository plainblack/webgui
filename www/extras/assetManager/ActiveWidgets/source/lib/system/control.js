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

Active.System.Control = Active.System.Template.subclass();

Active.System.Control.create = function(){

/****************************************************************

	Generic user interface control class. Control is a screen element,
	which can have focus and responds to the keyboard or mouse commands.

	Typical control has a set of built-in or external data models
	and may also contain additional presentation templates.

*****************************************************************/

	var obj = this.prototype;
	//alert(obj);
	var _super = this.superclass.prototype;
	var _pattern = /^(\w+)\W(.+)$/;

	var join = function(){
		var i, s = arguments[0];
		for (i=1; i<arguments.length; i++){s += arguments[i].substr(0,1).toUpperCase() + arguments[i].substr(1)}
		return s;
	};

	//obj.setEvent("oncontextmenu", "return false");
	obj.setEvent("onselectstart", "return false");
/****************************************************************

	Creates a new data model.

	@param	name	(String) New data model name.

*****************************************************************/

	obj.defineModel = function(name){

		var external = "_" + name + "Model";

		var defineProperty = join("define", name, "property");
		var definePropertyArray = join("define", name, "property", "array");
		var getProperty = join("get", name, "property");
		var setProperty = join("set", name, "property");
		var get = {};
		var set = {};

		var getModel = join("get", name, "model");
		var setModel = join("set", name, "model");
		var updateModel = join("update", name, "model");


//		------------------------------------------------------------

		this[defineProperty] = function(property, defaultValue){

			var _getProperty = join("get", name, property);
			var _setProperty = join("set", name, property);
			var _property = "_" + join(name, property);

			var getPropertyMethod = function(){
				return this[_property];
			};

			this[_getProperty] = getPropertyMethod;

			this[_setProperty] = function(value){
				if(typeof value == "function"){
					this[_getProperty] = value;
				}
				else {
					if (this[_getProperty] !== getPropertyMethod) {this[_getProperty] = getPropertyMethod}
					this[_property] = value;
				}
				this[updateModel](property);
			};

			this[_setProperty](defaultValue);
		};

//		------------------------------------------------------------

		this[getProperty] = function(property, a, b, c){
			try {
				if (this[external]) {return this[external].getProperty(property, a, b, c)}
				if (!get[property]) {get[property] = join("get", name, property)}
				return this[get[property]](a, b, c);
			}
			catch(error){
				return this.handle(error);
			}
		};

//		------------------------------------------------------------

		this[setProperty] = function(property, value, a, b, c){
			try {
				if (this[external]) {return this[external].setProperty(property, value, a, b, c)}
				if (!set[property]) {set[property] = join("set", name, property)}
				return this[set[property]](value, a, b, c);
			}
			catch(error){
				return this.handle(error);
			}
		};

//		------------------------------------------------------------

		_super[getProperty] = function(property, a, b, c){
			if (this[external]) {return this[external].getProperty(property, a, b, c)}
			return this.$owner[getProperty](property, a, b, c);
		};

		_super[setProperty] = function(property, value, a, b, c){
			if (this[external]) {return this[external].setProperty(property, value, a, b, c)}
			return this.$owner[setProperty](property, value, a, b, c);
		};

//		------------------------------------------------------------

		this[definePropertyArray] = function(property, defaultValue){

			var _getProperty = join("get", name, property);
			var _setProperty = join("set", name, property);
			var _getArray = join("get", name, property + "s");
			var _setArray = join("set", name, property + "s");
			var _array = "_" + join(name, property + "s");
			var _getCount = join("get", name, "count");
			var _setCount = join("set", name, "count");

			var getArrayElement = function(index){
				return this[_array][index];
			};

			var getStaticElement = function(){
				return this[_array];
			};

			var getArray = function(){
				return this[_array].concat();
			};

			var getTempArray = function(){
				var i, a = [], max = this[_getCount]();
				for(i=0; i<max; i++) {a[i] = this[_getProperty](i)}
				return a;
			};

			this[_setProperty] = function(value, index){
				if(typeof value == "function"){
					this[_getProperty] = value; 
					this[_getArray] = getTempArray;
				}
				else if (arguments.length==1) {
					this[_array] = value;
					this[_getProperty] = getStaticElement;
					this[_getArray] = getTempArray;
				}
				else {
					if (this[_getArray] != getArray) {this[_array] = this[_getArray]()}
					this[_array][index] = value;
					this[_getProperty] = getArrayElement;
					this[_getArray] = getArray;
				}
				this[updateModel](property);
			};

			this[_setArray] = function(value){
				if(typeof value == "function"){
					this[_getArray] = value;
				}
				else {
					this[_array] = value.concat();
					this[_getProperty] = getArrayElement;
					this[_getArray] = getArray;
					this[_setCount](value.length);
				}
				this[updateModel](property);
			};

			this[_setProperty](defaultValue);
		};

//		------------------------------------------------------------

		var proxyPrototype = new Active.System.Model;

		proxyPrototype.getProperty = function(property, a, b, c){
			return this._target[getProperty](property, a, b, c);
		};

		proxyPrototype.setProperty = function(property, value, a, b, c){
			return this._target[setProperty](property, value, a, b, c);
		};

		var proxy = join("_", name, "proxy");

		this[getModel] = function(){
			if (this[external]) {return this[external]}
			if (!this[proxy]) {
				this[proxy] = proxyPrototype.clone();
				this[proxy]._target = this;
				this[proxy].$owner = this.$owner; 
			}
			return this[proxy];
		};

		_super[setModel] = function(model){
			this[external] = model;
			if (model && !model.$owner) {model.$owner = this}
		};

		_super[getModel] = function(a, b, c){
			if (this[external]) {return this[external]}
			return this.$owner[getModel](a, b, c);
		};

//		------------------------------------------------------------

		this[updateModel] = function(){};

	};

/****************************************************************

	Creates a new property for the built-in data model.

	@param	name	(String) Name of the property.
	@param	value	(Any) Default value for the property.

*****************************************************************/

	obj.defineProperty = function(name, defaultValue){
		if (name.match(_pattern)) {
			var defineProperty = join("define", RegExp.$1, "property");
			if (this[defineProperty]) {return this[defineProperty](RegExp.$2, defaultValue)}
		}
	};

/****************************************************************

	Creates a new property array for the built-in data model.

	@param	name	(String) Name of the property.
	@param	value	(Any) Default value for the property.

*****************************************************************/

	obj.definePropertyArray = function(name, defaultValue){
		if (name.match(_pattern)) {
			var defineArray = join("define", RegExp.$1, "property", "array");
			if (this[defineArray]) {return this[defineArray](RegExp.$2, defaultValue)}
		}
	};
};

Active.System.Control.create();

