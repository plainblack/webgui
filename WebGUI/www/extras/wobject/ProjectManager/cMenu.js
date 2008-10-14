/*
Determine whether the browser is IE5.0.
*/
function isIE50() { // Private method
  return isIE5() && !isIE55();
}

/*
Determine whether the browser is IE5.5.
*/
function isIE55() { // Private method
  return navigator.userAgent.indexOf("MSIE 5.5") > -1;
}

/*
Determine whether the browser is IE5.0 or IE5.5.
*/
function isIE5() { // Private method
  return navigator.userAgent.indexOf("MSIE 5") > -1;
}

/*
Determine whether the browser is IE6.
*/
function isIE6() { // Private method
  return navigator.userAgent.indexOf("MSIE 6") > -1 && navigator.userAgent.indexOf("Opera") == -1;
}

/*
Determine whether the browser is IE.
*/
function isIE() { // Private method
  return isIE5() || isIE6();
}

/*
Determine whether the browser is Opera.
*/
function isOpera() { // Private method
  return navigator.userAgent.indexOf("Opera") > -1;
}

/* 
Determine whether the browser is Safari.
*/
function isSafari() { // Private method
  return navigator.userAgent.indexOf("Safari") > -1;
}

var ie50 = isIE50(); // Private field
var ie55 = isIE55(); // Private field
var ie5 = isIE5(); // Private field
var ie6 = isIE6(); // Private field
var ie = isIE(); // Private field
var opera = isOpera(); // Private field
var safari = isSafari(); // Private field
var pageMode = getPageMode();
var px = "px";

var cMenu_items = new Array();

if (cMenu_old == undefined)
{
  var cMenu_old = (document.onclick) ? document.onclick : function () {};
  document.onclick= function () {cMenu_old();cMenu_hide();};
}

/*
Determine the page render mode.

0: Quirks mode.
1: Strict mode.
*/
function getPageMode() { // Private method
  if (document.compatMode) {
    switch (document.compatMode) {
      case "BackCompat":
        return 0;
      case "CSS1Compat":
        return 1;
      case "QuirksMode":
        return 0;
    }
  }
  else {
    if (ie5) {
      return 0;
    }
    if (safari) {
      return 1;
    }
  }
  return 0;
}

function getMainMenuLeftPos(menuObj, x) { // Private method
  //alert(x);
  if (x + menuObj.offsetWidth <= getClientWidth()) {
    return x;
  }
  else {
    return x - menuObj.offsetWidth;
  }
}

/*
Get the top position of the pop-up menu.
*/
function getMainMenuTopPos(menuObj, y) { // Private method
  //alert(y);
  if (y + menuObj.offsetHeight <= getClientHeight()) {
    return y;
  }
  else {
    return y - menuObj.offsetHeight;
  }
}

/*
Get the clientHeight property.
*/
function getClientHeight() { // Private method
  switch (pageMode) {
    case 0:
      return document.body.clientHeight;
    case 1:
      if (safari) {
        return self.innerHeight;
      }
      else {
        if (!opera && document.documentElement && document.documentElement.clientHeight > 0) {
          return document.documentElement.clientHeight;
        }
        else {
          return document.body.clientHeight;
        }
      }
  }
}

/*
Get the clientWidth property.
*/
function getClientWidth() { // Private method
  switch (pageMode) {
    case 0:
      return document.body.clientWidth;
    case 1:
      if (safari) {
        return self.innerWidth;
      }
      else {
        if (!opera && document.documentElement && document.documentElement.clientWidth > 0) {
          return document.documentElement.clientWidth;
        }
        else {
          return document.body.clientWidth;
        }
      }
  }
}

/*
Get the x-coordinate of the cursor position relative to the window.
*/
function getX(e) { // Private method
  if (!e) {
    var e = window.event;
  }
  if (safari) {
    return e.clientX - getScrollLeft();
  }
  else {
    return e.clientX;
  }
}

/*
Get the y-coordinate of the cursor position relative to the window.
*/
function getY(e) { // Private method
  if (!e) {
    var e = window.event;
  }
  if (safari) {
    return e.clientY - getScrollTop();
  }
  else {
    return e.clientY;
  }
}

/*
Get the scrollLeft property.
*/
function getScrollLeft() { // Private method
  switch (pageMode) {
    case 0:
      return document.body.scrollLeft;
    case 1:
      if (document.documentElement && document.documentElement.scrollLeft > 0) {
        return document.documentElement.scrollLeft;
      }
      else {
        return document.body.scrollLeft;
      }
  }
}

/*
Get the scrollTop property.
*/
function getScrollTop() { // Private method
  switch (pageMode) {
    case 0:
      return document.body.scrollTop;
    case 1:
      if (document.documentElement && document.documentElement.scrollTop > 0) {
        return document.documentElement.scrollTop;
      }
      else {
        return document.body.scrollTop;
      }
  }
}

function cMenu_renderLeftClick(menuId,e) {
	cMenu_hide(e);
	cMenu_show(menuId,e);
	e.cancelBubble=true;
	e.returnValue=false;
	return false;
} 

function cMenu_show(menuId,e){
   // alert(menuId);
	var menuobj=document.getElementById(menuId)
	var posx = 0;
	var posy = 0;
	var yoffset = 0;
	var xoffset = 0;
    var firedobj = ie5?e.srcElement:e.target;
    /*while (firedobj!=null && firedobj.tagName!="HTML"){
       //this is a hack, need to revisit
       if (firedobj.tagName == "DIV") {
          xoffset+=firedobj.offsetLeft;
          yoffset+=firedobj.offsetTop;
	   }
       firedobj=firedobj.offsetParent;
    }
	   
	var el = document.documentElement;
    posx = e.clientX - xoffset + (ie5? el.scrollLeft : window.pageXOffset);
    posy = e.clientY - yoffset + (ie5? el.scrollTop : window.pageYOffset);
	alert(posx);
	alert(posy);
	//menuobj.style.left=posx + "px";
	//menuobj.style.top=posy + "px";
	*/
	var hackedTopOffset = (ie?180:130);
	menuobj.style.left = (getMainMenuLeftPos(menuobj, getX(e)) + getScrollLeft()) + px;
    menuobj.style.top = (getMainMenuTopPos(menuobj, getY(e)) + getScrollTop() - hackedTopOffset) + px;
	//alert(menuobj.style.left);
	//alert(menuobj.style.top);
    menuobj.style.visibility="visible"
	return false
}

function cMenu_hide(){
	for (i=0;i<cMenu_items.length;i++) {
		document.getElementById("cMenu_"+cMenu_items[i]+"_menu").style.visibility="hidden"
	}
	return false;
}

function cMenu_createWithImage(imagePath, id, name){
	cMenu_items.push(id);
	this.id = id;
	this.name = name;
	this.type = "image";
	this.imagePath=imagePath;
	this.linkLabels = new Array();
	this.linkUrls = new Array();
	this.draw = cMenu_draw;
	this.print = cMenu_print;
	this.addLink = cMenu_addLink;
}

function cMenu_createWithLink(id, name){
	cMenu_items.push(id);
	this.id = id;
	this.name = name;
	this.type = "link";
	this.linkLabels = new Array();
	this.linkUrls = new Array();
	this.draw = cMenu_draw;
	this.print = cMenu_print;
	this.addLink = cMenu_addLink;
}

function cMenu_draw(){
	var output = "";
	output += '<div id="cMenu_' + this.id + '_menu" class="cMenu_skin">';
	for (i=0;i<this.linkUrls.length;i++) {
        var urlparts  = this.linkUrls[i].split("?");
        var dataparts = urlparts[1].split(";");
        var projectId = "";
        var taskId    = "";
        var insertAt  = "";
        for (var j = 0; j < dataparts.length; j++) {
          var keyval = dataparts[j].split("=");
          var key = keyval[0];
          var val = keyval[1];
          if(key == "projectId") {
            projectId = val;
          }
          else if(key == "taskId") {
            taskId = val;
          }
          else if(key == "insertAt") {
            insertAt = val;
          }
        }
        
        var clazz = "submodal-400-300";
		var id    = projectId + "~~" + taskId + "~~" + insertAt;
        var url   = "#";
        if(this.linkUrls[i].indexOf("delete") != -1) {
		   clazz = "";
           url   = this.linkUrls[i];
           id    = "";
		}
        
		output += "<a href=\"" + url + "\" class=\"" + clazz + "\" id=\"" + id +"\">" + this.linkLabels[i] + "</a><br />";
	}
	output += '</div>';
	if (this.type == "image") {
		output += '<img src="' + this.imagePath + '" id="cMenu_' + this.id + '" onclick="return cMenu_renderLeftClick(\'cMenu_' + this.id + '_menu\',event)" alt="' + this.name + '" title="' + this.name + '" align="absmiddle" />';
	} else {
		output += '<a href="#" id="cMenu_' + this.id + '" onclick="return cMenu_renderLeftClick(\'cMenu_' + this.id + '_menu\',event)">' + this.name + '</a>';
	}
	return output;
}

function cMenu_print(){
	document.write(this.draw());
}

function cMenu_addLink(linkUrl,linkLabel){
	this.linkUrls.push(linkUrl);
	this.linkLabels.push(linkLabel);
}
