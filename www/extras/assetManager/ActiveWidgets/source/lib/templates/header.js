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

Active.Templates.Header = Active.Templates.Item.subclass();

Active.Templates.Header.create = function(){

/****************************************************************

	Column header template.

*****************************************************************/

	var obj = this.prototype;

//	------------------------------------------------------------

	obj.setClass("templates", "header");
	obj.setClass("column", function(){return this.$index});
	obj.setClass("sort", function(){
		return this.getSortProperty("index") != this.$index ? "none" : this.getSortProperty("direction");
	});

	obj.setAttribute("title", function(){return this.getItemProperty("tooltip")});

//	------------------------------------------------------------

	var div = new Active.HTML.DIV;
	div.setClass("box", "resize");
	div.setEvent("onmousedown", function(){this.action("startColumnResize")});
	div.setContent("html", "&nbsp;"); 

	obj.setContent("div", div);
	obj.setEvent("onmousedown", function(){
		this.setClass("header", "pressed");
		window.status = "Sorting...";
		this.timeout(function(){this.action("columnSort")});
	});

	var sort = new Active.HTML.SPAN;
	sort.setClass("box", "sort");
	obj.setContent("box/sort", sort);

	obj.setEvent("onmouseenter", "mouseover(this, 'active-header-over')");
	obj.setEvent("onmouseleave", "mouseout(this, 'active-header-over')");

};

Active.Templates.Header.create();