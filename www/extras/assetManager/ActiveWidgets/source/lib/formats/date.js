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

Active.Formats.Date = Active.System.Format.subclass();

Active.Formats.Date.create = function(){

/****************************************************************

	Date formatting class.

*****************************************************************/

	var obj = this.prototype;

	obj.date = new Date();

	obj.digits = [];
	obj.shortMonths = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
	obj.longMonths = ["January","February","March","April","May","June","July","August","September","October","November","December"];
	obj.shortWeekdays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"];
	obj.longWeekdays = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];

	for(var i=0; i<100; i++){obj.digits[i] = i<10 ? "0" + i : "" + i}

	var tokens = {
		"hh"	: "this.digits[this.date.getUTCHours()]",
		":mm"	: "':'+this.digits[this.date.getUTCMinutes()]",
		"mm:"	: "this.digits[this.date.getUTCMinutes()]+':'",
		"ss"	: "this.digits[this.date.getUTCSeconds()]",
		"dddd"	: "this.longWeekdays[this.date.getUTCDay()]",
		"ddd"	: "this.shortWeekdays[this.date.getUTCDay()]",
		"dd"	: "this.digits[this.date.getUTCDate()]",
		"d"		: "this.date.getUTCDate()",
		"mmmm"	: "this.longMonths[this.date.getUTCMonth()]",
		"mmm"	: "this.shortMonths[this.date.getUTCMonth()]",
		"mm"	: "this.digits[this.date.getUTCMonth()]",
		"m"		: "this.date.getUTCMonth()",
		"yyyy"	: "this.date.getUTCFullYear()",
		"yy"    : "this.digits[this.date.getUTCFullYear()%100]" };

	var match = "";
	for(i in tokens){
		if (typeof(i) == "string"){
			match += "|" + i;
		}
	}
	var re = new RegExp(match.replace("|", "(")+")", "gi");

/****************************************************************

	Allows to specify the format for the text output.

	@param	format	(String) Format pattern.

*****************************************************************/

	obj.setTextFormat = function(format){
		format = format.replace(re, function(i){return "'+" + tokens[i.toLowerCase()] + "+'"});
		format = "if (isNaN(value)) return this._textError;" +
				 "this.date.setTime(value + this._textTimezoneOffset);" +
				("return '" + format + "'").replace(/(''\+|\+'')/g, "");
		this.valueToText = new Function("value", format);
	};

	var xmlExpr = /^(....).(..).(..).(..).(..).(..)........(...).(..)/;
	var xmlOut = "$1/$2/$3 $4:$5:$6 GMT$7$8";

	var auto = function(data){
		return Date.parse(data + this._dataTimezoneCode);
	};

	var RFC822 = function(data){
		return Date.parse(data);
	};

	var ISO8061 = function(data){
		return Date.parse(data.replace(xmlExpr, xmlOut));
	};

/****************************************************************

	Allows to specify the wire format for data input.

	@param	format	(String) Format pattern.

*****************************************************************/

	obj.setDataFormat = function(format){
		if (format == "RFC822") {
			this.dataToValue = RFC822;
		}
		else if (format == "ISO8061") {
			this.dataToValue = ISO8061;
		}
		else {
			this.dataToValue = auto;
		}
	};

/****************************************************************

	Allows to specify the timezone used for the text output.

	@param	value	(Number) Timezone offset.

*****************************************************************/

	obj.setTextTimezone = function(value){
		this._textTimezoneOffset = value;
	};

/****************************************************************

	Allows to specify the timezone used for the data input.

	@param	value	(Number) Timezone offset.

*****************************************************************/

	obj.setDataTimezone = function(value){
		if (!value) {
			this._dataTimezoneCode = " GMT";
		}
		else {
			this._dataTimezoneCode = " GMT" +
				(value>0 ? "+" : "-") +
				this.digits[Math.floor(Math.abs(value/3600000))] +
				this.digits[Math.abs(value/60000)%60];
		}
	};

	var localTimezone = - obj.date.getTimezoneOffset() * 60000;

	obj.setTextTimezone(localTimezone);
	obj.setDataTimezone(localTimezone);

	obj.setTextFormat("d mmm yy");
	obj.setDataFormat("default");
};

Active.Formats.Date.create();

