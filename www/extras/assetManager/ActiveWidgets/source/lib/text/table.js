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

Active.Text.Table = Active.HTTP.Request.subclass();

Active.Text.Table.create = function(){

/****************************************************************

	Table model for loading and parsing data in CSV text format.

*****************************************************************/

	var obj = this.prototype;
	var _super = this.superclass.prototype;

/****************************************************************

	Allows to process the received text.

	@param text (String) The downloaded text.

*****************************************************************/

	obj.response = function(text){
		var i, s, table = [], a = text.split(/\r*\n/);

		var pattern = new RegExp("(^|\\t|,)(\"*|'*)(.*?)\\2(?=,|\\t|$)", "g");

		for (i=0; i<a.length; i++) {
			s = a[i].replace(/""/g, "'");
			s = s.replace(pattern, "$3\t");
			s = s.replace(/\t$/, "");
			if (s) {table[i] = s.split(/\t/)}
		}

		this._data = table;
		_super.response.call(this);
	};

	obj._data = [];

/****************************************************************

	Returns the number of data rows.

*****************************************************************/

	obj.getCount = function(){
		return this._data.length;
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
		return this._data[i][j];
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
		var text = this.getText(i, j);
		var value = Number(text.replace(/[ ,%\$]/gi, "").replace(/\((.*)\)/, "-$1"));
		return isNaN(value) ? text.toLowerCase() + " " : value;
	};
};

Active.Text.Table.create();