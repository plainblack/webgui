

var site = {};


site.head = function(title, subtitle){
	return	"<div class='head'><table class='page' align='center'><tr>" +
			"<td class='title'>" + title + "</td>" +
			"<td class='subtitle'>" + subtitle + "</td>" +
			"</tr></table></div>";
}

site.menu = function(left, right){
	return	"<div class='menu'><table class='page' align='center'><tr>" +
			"<td class='left'>" + left + "</td>" +
			"<td class='right'>" + right + "</td>" +
			"</tr></table></div>";
}

site.main = function(){
	return	"<div class='body'><table class='page' align='center'><col class='main'/><col class='right'/><tr><td class='main'>";
}

site.foot = function(){
	return	"</td></tr></table></div>";
}

site.copyright = function(message){
	return	"<div class='copyright'><table class='page' align='center'><tr>" +
			"<td>" + message + "</td>" +
			"</tr></table></div>";
}

site.doctree = [
	["Tutorial", [
		["Introduction", [
			["Hello World",				"tutorial/introduction/helloworld.htm"],
		]],
		["HTML", [
			["Tags",					"tutorial/html/tags.htm"],
			["Attributes",				"tutorial/html/attributes.htm"],
			["Styles",					"tutorial/html/styles.htm"],
		]],
		["Grid", [
			["Quick Start",				"tutorial/grid/intro.htm"],
			["Data Sources",			"tutorial/grid/data.htm"],
			["Number Formatting",		"tutorial/grid/formats.htm"],
			["Visual Style",			"tutorial/grid/style.htm"],
			["Mouseover Effects",		"tutorial/grid/mouseover.htm"],
			["Selections",				"tutorial/grid/selection.htm"],
		]],
	]],

	["Reference", [
		["System", [
			["Active.System.Object",	"reference/active.system.object/index.htm"],
			["Active.System.HTML",		"reference/active.system.html/index.htm"],
			["Active.System.Template",	"reference/active.system.template/index.htm"],
			["Active.System.Control",	"reference/active.system.control/index.htm"],
			["Active.System.Model",		"reference/active.system.model/index.htm"],
			["Active.System.Format",	"reference/active.system.format/index.htm"],
		]],
		["Templates", [
			["Active.Templates.Box",	"reference/active.templates.box/index.htm"],
			["Active.Templates.Text",	"reference/active.templates.text/index.htm"],
			["Active.Templates.Image",	"reference/active.templates.image/index.htm"],
			["Active.Templates.Link",	"reference/active.templates.link/index.htm"],
			["Active.Templates.Item",	"reference/active.templates.item/index.htm"],
			["Active.Templates.List",	"reference/active.templates.list/index.htm"],
			["Active.Templates.Row",	"reference/active.templates.row/index.htm"],
			["Active.Templates.Header",	"reference/active.templates.header/index.htm"],
			["Active.Templates.Scroll",	"reference/active.templates.scroll/index.htm"],
			["Active.Templates.Status",	"reference/active.templates.status/index.htm"],
			["Active.Templates.Error",	"reference/active.templates.error/index.htm"],
		]],
		["Controls", [
			["Active.Controls.Grid",	"reference/active.controls.grid/index.htm"],
		]],
		["HTTP", [
			["Active.HTTP.Request",		"reference/active.http.request/index.htm"],
		]],
		["Text", [
			["Active.Text.Table",		"reference/active.text.table/index.htm"],
		]],
		["XML", [
			["Active.XML.Table",		"reference/active.xml.table/index.htm"],
		]],
		["Formats", [
			["Active.Formats.String",	"reference/active.formats.string/index.htm"],
			["Active.Formats.Number",	"reference/active.formats.number/index.htm"],
			["Active.Formats.Date",		"reference/active.formats.date/index.htm"],
		]],
	]],
];



site.reference = function(){
	function tree(a){
		var i, temp, s = "";
		for (i=0; i<a.length; i++){
			if (!a[i]) {}
			else if (typeof(a[i][1]) == "object"){
				temp = "<a>" + a[i][0] + "</a><ul>" + tree(a[i][1]) + "</ul>";
				if (a[i][1].expanded) {
					s += "<li onclick='site.toggleTree(event, this)' class='treeVisible'>" + temp + "</li>";
					a.expanded = true;
				}
				else {
					s += "<li onclick='site.toggleTree(event, this)'>" + temp + "</li>";
				}
			}
			else {
				var pattern = a[i][1].replace("index.htm", "");
				if (window.location.href.match(pattern)) {
					a.expanded = true
					s += "<li class='tree-active'><a href='../../" + a[i][1] + "'>" + a[i][0] + "</a></li>";
				}
				else {
					s += "<li><a href='../../" + a[i][1] + "'>" + a[i][0] + "</a></li>";
				}
			}
		}
		return s;
	}

	var s = "";
	s += "<ul class='reference' onclick='site.toggleTree(event)'>";
	s += tree(site.doctree);
	s += "</ul>";

	return s;
}

site.tutorial = site.reference;

site.toggleTree = function(event, ref){
//	var e = event.srcElement ? event.srcElement : event.target;
//	if (e.href) {return}
//	if (e.tagName != "LI") {e = e.parentElement}
	ref.className = ref.className ? "" : "treeVisible";
	event.cancelBubble = true;
}

site.base = function(){
	var i, src = "common/site.js", scripts = document.getElementsByTagName("script");
	for (i=0; i<scripts.length; i++){if (scripts[i].src.match(src)){ return scripts[i].src.replace(src, "")}}
	return "";
}

site.home = function(){
	return ("" + window.location).match("activewidgets.com") ? "" : "readme.htm";
}

site.examples = function(){
	return ("" + window.location).match("activewidgets.com") ? "grid/" : "grid/index.htm";
}


site.adjustFonts = function(){
	try {
		if (window.navigator.userAgent.match("Linux")) {
			document.body.style.font = "menu";
		}
	}
	catch(error){
	}
}

site.example = function(source){
	try {

		var text = document.getElementById(source).value;
		var style = document.getElementById(source).getAttribute("target");

		var b = "<button style=\"position:relative;left:-60px;top:8px;margin-bottom:-22px;font-size:11px;line-height:11px;height:22px;width:50px\"";
		b += " title=\"This example is live! Try to modify the script in the textbox and press 'refresh' to see the results.\"";
		b += " onclick=\"window.refresh" + source + "()\">Refresh</button><br />";
		document.write(b);

		var name = source + "-frame";
		var f = "<iframe name='" + name + "' style='" + style +"' frameborder=\"0\"></iframe>";
		document.write(f);

		var doc = frames[name].document;
		doc.open();
		doc.write("<html><head>");
		doc.write("</head><body>");
		doc.write("</body></html>");
		doc.close()

		var wl = window.onload;

		window.onload = window["refresh" + source] = function(){

			if (typeof wl == "function" ) {wl()}

			var doc = frames[name].document;
			doc.open();
			doc.write("<html><head>");
			doc.write("<style> body, html {margin:0px; padding: 0px; overflow: hidden; font: menu} </style>");
			doc.write("<link href=\"../../../runtime/styles/classic/grid.css\" rel=\"stylesheet\" type=\"text/css\" ></link>");
			doc.write("<style>.active-row-highlight .active-row-cell {background-color: threedshadow}</style>");
			doc.write("<s" + "cript src=\"../../../runtime/lib/grid.js\"></s" + "cript>");
			doc.write("</head><body>");
			doc.write("<s" + "cript>" + document.getElementById(source).value + "</s" + "cript>");

			window.setTimeout(function(){
					doc.write("</body></html>");
					doc.close()
			}, 1000);

		}

	}
	catch(e){
	}
}



var $header = {toString: function(){

	site.adjustFonts();

	var s = "", base = site.base(), home = site.home(), examples = site.examples();
	s += site.head("ActiveWidgets", "Cross-browser DHTML widgets toolkit");
	s += site.menu(	"<a href='" + base + home + "'>Home</a>|" +
					"<a href='" + base + examples + "'>ActiveWidgets Grid 1.0</a>",
					"<a href='http://www.activewidgets.com/messages/'>Support Forum</a>|" +
					"<a href='" + base + "documentation/tutorial/introduction/helloworld.htm'>Tutorial</a>|" +
					"<a href='" + base + "documentation/reference/active.controls.grid/index.htm'>Reference</a>|" +
					"<a href='http://www.activewidgets.com/download/'>Download</a>|" +
					"<a href='http://www.activewidgets.com/company/'>Contacts</a>");

	s += site.main();

	return s;
}};


var $column = {toString: function(){
	return "</td><td class='right'>";
}};

var $reference = {toString: function(){
	return 	site.reference();
}};

var $tutorial = {toString: function(){
	return 	site.tutorial();
}};

var $footer = {toString: function(){
	var s = "";
	s += site.foot();
	s += site.copyright("Copyright &copy; 2004 ActiveWidgets Ltd. All Rights Reserved.");
	return s;
}};
