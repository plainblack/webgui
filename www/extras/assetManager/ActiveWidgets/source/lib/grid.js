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

$import("namespaces/grid.js");
$import("browsers/gecko.js");
$import("system/object.js");
$import("system/model.js");
$import("system/format.js");
$import("system/html.js");
$import("system/template.js");
$import("system/control.js");
$import("formats/string.js");
$import("formats/number.js");
$import("formats/date.js");
$import("html/tags.js");
$import("templates/status.js");
$import("templates/error.js");
$import("templates/text.js");
$import("templates/image.js");
$import("templates/link.js");
$import("templates/item.js");
$import("templates/list.js");
$import("templates/row.js");
$import("templates/header.js");
$import("templates/box.js");
$import("templates/scroll.js");
$import("controls/grid.js");
$import("http/request.js");
$import("text/table.js");
$import("xml/table.js");

//	------------------------------------------------------------

function $import(path){
	var i, base, src = "grid.js", scripts = document.getElementsByTagName("script");
	for (i=0; i<scripts.length; i++){if (scripts[i].src.match(src)){ base = scripts[i].src.replace(src, "");break;}}
	document.write("<" + "script src=\"" + base + path + "\"></" + "script>");
}

