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

Active.Templates.Scroll = Active.System.Template.subclass();

Active.Templates.Scroll.create = function(){

/****************************************************************

	Four panes scrollable layout template.

*****************************************************************/

	var obj = this.prototype;
	var _super = this.superclass.prototype;

//	------------------------------------------------------------

	obj.setTag("");

//	------------------------------------------------------------

	var Pane = Active.HTML.DIV;
	var Box = Active.Templates.Box;

	var data = new Pane;
	var top = new Pane;
	var left = new Pane;
	var corner = new Box;
	var fill = new Box;
	var scrollbars = new Pane;
	var space = new Pane;

	data.setClass("scroll", "data");
	top.setClass("scroll", "top");
	left.setClass("scroll", "left");
	corner.setClass("scroll", "corner");
	fill.setClass("scroll", "fill");
	scrollbars.setClass("scroll", "bars");
	space.setClass("scroll", "space");

	obj.setContent("data", data);
	obj.setContent("top", top);
	obj.setContent("left", left);
	obj.setContent("corner", corner);
	obj.setContent("scrollbars", scrollbars);

	obj.setContent("data/html", function(){return this.getMainTemplate()});
	obj.setContent("top/html", function(){return this.getTopTemplate()});
	obj.setContent("left/html", function(){return this.getLeftTemplate()});
	obj.setContent("scrollbars/space", space);
	obj.setContent("top/fill", fill);

//	------------------------------------------------------------

	var scroll = function(){
		var scrollbars = this.getContent("scrollbars").element();
		var data = this.getContent("data").element();
		var top = this.getContent("top").element();
		var left = this.getContent("left").element();

		var x = scrollbars.scrollLeft;
		var y = scrollbars.scrollTop;

		data.scrollLeft = x;
		top.scrollLeft = x;
		data.scrollTop = y;
		left.scrollTop = y;

		scrollbars = null;
		data = null;
		top = null;
		left = null;
	};

	scrollbars.setEvent("onscroll", scroll);

//	------------------------------------------------------------

	var resize = function(){
		if (this._sizeAdjusted){
			this._sizeAdjusted = false;
			this.timeout(adjustSize, 100);

			var data = this.getContent("data").element();
			var scrollbars = this.getContent("scrollbars").element();
			var top = this.getContent("top").element();
			var left = this.getContent("left").element();

			data.runtimeStyle.width = "100%";
			top.runtimeStyle.width = "100%";
			data.runtimeStyle.height = "100%";
			left.runtimeStyle.height = "100%";

			scrollbars.runtimeStyle.zIndex = 1000;

			data = null;
			scrollbars = null;
			top = null;
			left = null;
		}
	};

	scrollbars.setEvent("onresize", resize);

//	------------------------------------------------------------

	obj._sizeAdjusted = true;

	var adjustSize = function(){

		var data = this.getContent("data").element();
		var scrollbars = this.getContent("scrollbars").element();
		var top = this.getContent("top").element();
		var left = this.getContent("left").element();
		var space = this.getContent("scrollbars/space").element();

		if (data) {
			if (data.scrollHeight) {

				space.runtimeStyle.height = data.scrollHeight > data.offsetHeight ? data.scrollHeight : 0;
				space.runtimeStyle.width = data.scrollWidth > data.offsetWidth ? data.scrollWidth : 0;

				var y = scrollbars.clientHeight;
				var x = scrollbars.clientWidth;

				data.runtimeStyle.width = x;
				top.runtimeStyle.width = x;
				data.runtimeStyle.height = y;
				left.runtimeStyle.height = y;

				top.scrollLeft = data.scrollLeft;
				left.scrollTop = data.scrollTop;

				scrollbars.runtimeStyle.zIndex = 0;
			}
			else {
				this.timeout(adjustSize, 500);
			}

			data.className = data.className + "";
		}

		data = null;
		scrollbars = null;
		top = null;
		left = null;
		space = null;

		this._sizeAdjusted = true;
	};

	// delay for grid col resize
	obj.setAction("adjustSize", function(){this.timeout(adjustSize, 500);});

	obj.toString = function(){
		this.timeout(adjustSize);
		return _super.toString.call(this);
	};

};

Active.Templates.Scroll.create();
