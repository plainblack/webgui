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

Active.Formats.Number = Active.System.Format.subclass();

Active.Formats.Number.create = function(){

/****************************************************************

	Number formatting class.

*****************************************************************/

	var obj = this.prototype;

/****************************************************************

	Transforms the wire data into the numeric value.

	@param	data	(String) Wire data.
	@return		Numeric value.

*****************************************************************/

	obj.dataToValue = function(data){
		return Number(data);
	};


	var noFormat = function(value){
		return "" + value;
	};

	var doFormat = function(value){
		var multiplier = this._multiplier;
		var abs = (value<0) ? -value : value;
		var delta = (value<0) ? -0.5 : +0.5;
		var rounded = (Math.round(value * multiplier) + delta)/multiplier + "";
		if (abs<1000) {return rounded.replace(this.p1, this.r1)}
		if (abs<1000000) {return rounded.replace(this.p2, this.r2)}
		if (abs<1000000000) {return rounded.replace(this.p3, this.r3)}
		return rounded.replace(this.p4, this.r4);
	};

/****************************************************************

	Allows to specify the format for the text output.

	@param	format	(String) Format pattern.

*****************************************************************/

	obj.setTextFormat = function(format){
		var pattern = /^([^0#]*)([0#]*)([ .,]?)([0#]|[0#]{3})([.,])([0#]*)([^0#]*)$/;
		var f = format.match(pattern);

		if (!f) {
			this.valueToText = noFormat;
			return;
		}

		this.valueToText = doFormat;

		var rs = f[1]; // result start
		var rg = f[3]; // result group separator;
		var rd = f[5]; // result decimal separator;
		var re = f[7]; // result end

		var decimals = f[6].length;

		this._multiplier = Math.pow(10, decimals);

		var ps = "^(-?\\d+)", pm = "(\\d{3})", pe = "\\.(\\d{" + decimals + "})\\d$";

		this.p1 = new RegExp(ps + pe);
		this.p2 = new RegExp(ps + pm + pe);
		this.p3 = new RegExp(ps + pm + pm + pe);
		this.p4 = new RegExp(ps + pm + pm + pm + pe);

		this.r1 = rs + "$1" + rd + "$2" + re;
		this.r2 = rs + "$1" + rg + "$2" + rd + "$3" + re;
		this.r3 = rs + "$1" + rg + "$2" + rg + "$3" + rd + "$4" + re;
		this.r4 = rs + "$1" + rg + "$2" + rg + "$3" + rg + "$4" + rd + "$5" + re;

	};

	obj.setTextFormat("#.##");
};

Active.Formats.Number.create();

