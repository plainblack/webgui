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

Active.System.Model = Active.System.Object.subclass();

Active.System.Model.create = function(){

/****************************************************************

	Generic data model class.

*****************************************************************/

	var obj = this.prototype;

	var join = function(){
		var i, s = arguments[0];
		for (i=1; i<arguments.length; i++){s += arguments[i].substr(0,1).toUpperCase() + arguments[i].substr(1)}
		return s;
	};

/****************************************************************

	Creates a new property.

	@param	name	(String) Property name.
	@param	value	(String) Default property value.

*****************************************************************/

	obj.defineProperty = function(name, value){

		var _getProperty = join("get", name);
		var _setProperty = join("set", name);
		var _property = "_" + name;

		var getProperty = function(){
			return this[_property];
		};

		this[_setProperty] = function(value){
			if(typeof value == "function"){
				this[_getProperty] = value;
			}
			else {
				this[_getProperty] = getProperty;
				this[_property] = value;
			}
		};

		this[_setProperty](value);
	};

	var get = {};
	var set = {};

/****************************************************************

	Returns property value.

	@param	name	(String) Property name.
	@return Property value.

*****************************************************************/

	obj.getProperty = function(name, a, b, c){
		if (!get[name]) {get[name] = join("get", name)}
		return this[get[name]](a, b, c);
	};

/****************************************************************

	Sets property value.

	@param	name	(String) Property name.
	@param	value	(String) Property value.

*****************************************************************/

	obj.setProperty = function(name, value, a, b, c){
		if (!set[name]) {set[name] = join("set", name)}
		return this[set[name]](value, a, b, c);
	};

/****************************************************************

	Indicates whether the data is available.

*****************************************************************/

	obj.isReady = function(){
		return true;
	};
};

Active.System.Model.create();

