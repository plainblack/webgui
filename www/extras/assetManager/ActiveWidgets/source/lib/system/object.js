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

Active.System.Object = function(){};

/*
	var Active is an object, the root of the hierarchy. Active.System is
	also an object (System is a property of Active) Active.System.Object
	is a function (Object is a method of System). To be precise, it is
	not just a function, it is a constructor function, which is used to
	create objects of type Active.System.Object (like this: var obj = new
	Active.System.Object;).
*/

Active.System.Object.subclass = function(){

/*
	We are creating a method 'subclass' of the Active.System.Object.
	Again, Active.System.Object is a constructor function, which
	represents a class, not an object instance. It is OK to create a
	method or a property of a function because functions themselves
	behave like objects.
*/

	var constructor = function(){this.init()};

/*
	Our 'subclass' method should return a constructor function, which
	we create here. Because the constructor is created automatically,
	the actual object initialization code should be somewhere else,
	i.e. in a special 'init' method. So each object constructor just
	calls 'init' method of a newly created object. Here 'this' keyword
	refers to the newly created object, when subclass constructor runs.
*/

	for (var i in this) {constructor[i] = this[i]}

/*
	This code copies all properties and methods from the base class
	constructor to the derived class constructor. Note, it is NOT object
	properties, it is constructor function properties. Keyword 'this'
	refers to the base class constructor, i.e. Active.System.Object
	function.
*/

	constructor.prototype = new this();

/*
	The 'prototype' property of the constructor of the derived class
	should point to the base class object instance. Here we create a new
	instance of the base class by calling the base class constructor
	function with the keyword 'new'. Again, 'this' refers to the base
	class constructor, i.e. Active.System.Object function.
*/

	constructor.superclass = this;

/*
	We also create special 'superclass' property, which provides quick
	access to the base class constructor from within the derived class.
	It is very useful when you want to overload a method in the derived
	class but still be able to call the base class implementation of the
	same method.
*/

	return constructor;
};

Active.System.Object.handle = function(error){
	throw(error);
};

Active.System.Object.create = function(){

/****************************************************************

	Generic base class - root of the ActiveWidgets class hierarchy.

*****************************************************************/

	var obj = this.prototype;

/****************************************************************

	Creates an object clone.

	@return		A new object.

	The clone function creates a fast copy of the object. Instead of
	physically copying each property and method of the source object -
	it creates a clone as a ‘subclass’ of the source object, i.e.
	properties and methods  are inherited from the source object into
	the clone.

	Note that the clone continues to be dependent on the source
	object. Changes in the source object property or method will
	affect all the clones unless this property is already overwritten
	in the clone object itself.

*****************************************************************/

	obj.clone = function(){
		if (this._clone.prototype!==this) {
			this._clone = function(){this.init()};
			this._clone.prototype = this;
		}
		return new this._clone();
	};

	obj._clone = function(){};

/****************************************************************

	Initializes the object.

	@remarks

	This method normaly contains all object initialization code
	(instead of the constructor function).	Constructor function is
	the same for all objects and only contains object.init() call.

*****************************************************************/

	obj.init = function(){
		// overload
	};

/****************************************************************

	Handles exceptions in the ActiveWidgets methods.

	@param	error (Error) Error object.

	The default error handler just throws the same exception to the
	next level. Overload this function to add your own diagnostics
	and error logging.

*****************************************************************/

 	obj.handle = function(error){
		throw(error);
	};

/****************************************************************

	Calls a method after a specified time interval has elapsed.

	@param	handler (Function) Method to call.
	@param	delay (Number) Time interval in milliseconds.
	@return An identifier that can be used with window.clearTimeout
			to cancel the current method call.

	This method has the same effect as window.setTimeout except that
	the function will be evaluated not as a global function but
	as a method of the current object.

*****************************************************************/

	obj.timeout = function(handler, delay){
		var self = this;
		var wrapper = function(){handler.call(self)};
		return window.setTimeout(wrapper, delay ? delay : 0);
	};

/****************************************************************

	Converts object to string.

	@return Text or HTML representation of the object.

	This method is overloaded in ActiveWidgets subclasses.

*****************************************************************/

 	obj.toString = function(){
		return "";
	};

};

Active.System.Object.create();

