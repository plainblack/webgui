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

Active.System.Format = Active.System.Object.subclass();

Active.System.Format.create = function(){

/****************************************************************

	Generic data formatting class.

*****************************************************************/

	var obj = this.prototype;

/****************************************************************

	Transforms the primitive value into the readable text.

	@param	value	(Any) Primitive value.
	@return		Readable text.

*****************************************************************/

	obj.valueToText = function(value){
		return value;
	};

/****************************************************************

	Transforms the wire data into the primitive value.

	@param	data	(String) Wire data.
	@return		Primitive value.

*****************************************************************/

	obj.dataToValue = function(data){
		return data;
	};

/****************************************************************

	Transforms the wire data into the readable text.

	@param	data	(String) Wire data.
	@return		Readable text.

*****************************************************************/

	obj.dataToText = function(data){
		var value = this.dataToValue(data);
		return this.valueToText(value);
	};

/****************************************************************

	Specifies the text to be returned in case of error.

	@param	text	(String) Error text.

*****************************************************************/

	obj.setErrorText = function(text){
		this._textError = text;
	};

/****************************************************************

	Specifies the value to be returned in case of error.

	@param	value	(Any) Error value.

*****************************************************************/

	obj.setErrorValue = function(value){
		this._valueError = value;
	};

	obj.setErrorText("#ERR");
	obj.setErrorValue(NaN);
};

Active.System.Format.create();

