var ie5=document.all&&document.getElementById
var contextMenu_timer = null;
var contextMenu_items = new Array();
function contextMenu_renderLeftClickHold(menuId,e) {		
	contextMenu_hideAll(e) 
      contextMenu_timer = setTimeout("contextMenu_show('" + menuId + "', " + contextMenu_getXOffset(e,document.getElementById("menuId")) + "," + contextMenu_getYOffset(e,document.getElementById("menuId")) + ")",1000);
	return false;
}

document.onmousedown=contextMenu_hideAll;

function contextMenu_hideAll(e) {     
      e =ie5? event : e;
	var firedobj = ie5?e.srcElement:e.target;

	while (firedobj != null && firedobj.tagName != "HTML" && firedobj.tagName != "IMG") {
		if (firedobj.id.indexOf("contextMenu") != -1) {
			return;
		}
		firedobj = firedobj.offsetParent;
      }   
   contextMenu_hide();
}

function contextMenu_renderRightClick(menuId,e) {
	contextMenu_hideAll(e) 
	contextMenu_show(menuId,contextMenu_getXOffset(e,document.getElementById("menuId")),contextMenu_getYOffset(e,document.getElementById("menuId")));
	e.cancelBubble=true;
	e.returnValue=false;
	return false;
} 


function contextMenu_getXOffset(e,menu) {
    var firedobj = ie5?e.srcElement:e.target;
    var tempX = 0;
    foundDiv = false;
    while (firedobj!=null && firedobj.tagName!="HTML"){
		//this is a hack, need to revisit
		if (firedobj.tagName == "DIV") foundDiv = true;
		tempX+=firedobj.offsetLeft;
            firedobj=firedobj.offsetParent;
   }
   if (foundDiv) {
	   return e.clientX - tempX;
   }else {
   	   return e.clientX;
   }
}

function contextMenu_getYOffset(e,menu) {
    var firedobj = ie5?e.srcElement:e.target;
    var tempY = 0;
    foundDiv = false;
    while (firedobj!=null && firedobj.tagName!="HTML"){
		//this is a hack, need to revisit
		if (firedobj.tagName == "DIV") foundDiv = true;
		tempY+=firedobj.offsetTop;
            firedobj=firedobj.offsetParent;
   }
   if (foundDiv) {
	   return e.clientY - tempY;
   }else {
   	   return e.clientY;
   }
}

function contextMenu_show(menuId,x,y){
	var menuobj=document.getElementById(menuId)
	//Find out how close the mouse is to the corner of the window
	var rightedge=ie5? document.body.clientWidth-x : window.innerWidth-x
	var bottomedge=ie5? document.body.clientHeight-y : window.innerHeight-y

	//if the horizontal distance isn't enough to accomodate the width of the context menu
	if (rightedge<menuobj.offsetWidth)
		//move the horizontal position of the menu to the left by it's width
		menuobj.style.left=ie5? document.body.scrollLeft+x-menuobj.offsetWidth : window.pageXOffset+x-menuobj.offsetWidth
	else
		//position the horizontal position of the menu where the mouse was clicked
		menuobj.style.left=ie5? document.body.scrollLeft+x : window.pageXOffset+x

	//same concept with the vertical position
	if (bottomedge<menuobj.offsetHeight)
		menuobj.style.top=ie5? document.body.scrollTop+y-menuobj.offsetHeight : window.pageYOffset+y-menuobj.offsetHeight
	else
		menuobj.style.top=ie5? document.body.scrollTop+y : window.pageYOffset+y

      menuobj.style.visibility="visible"
	return false
}

function contextMenu_hide(){
	for (i=0;i<contextMenu_items.length;i++) {
		document.getElementById("contextMenu_"+contextMenu_items[i]+"_menu").style.visibility="hidden"
	}
	return false;
}

function contextMenu_killTimer(){
	try {
		clearTimeout(contextMenu_timer);
	}catch (e) {
	}
	return false;
}

function contextMenu_create(imagePath, id, name){
	contextMenu_items.push(id);
	this.id = id;
	this.name = name;
	this.imagePath=imagePath;
	this.linkLabels = new Array();
	this.linkUrls = new Array();
	this.draw = contextMenu_draw;
	this.addLink = contextMenu_addLink;
}

function contextMenu_draw(){
	document.write('<div id="contextMenu_' + this.id + '_menu" class="contextMenu_skin">');
	for (i=0;i<this.linkUrls.length;i++) {
		document.write("<a href=\"" + this.linkUrls[i] + "\">" + this.linkLabels[i] + "</a><br />");
	}
	document.write('</div>');
	document.write('<img src="' + this.imagePath + '" id="contextMenu_' + this.id + '" onmouseup="contextMenu_killTimer()" oncontextmenu="return contextMenu_renderRightClick(\'contextMenu_' + this.id + '_menu\',event)" onmousedown="contextMenu_renderLeftClickHold(\'contextMenu_' + this.id + '_menu\',event)" alt="' + this.name + '" title="' + this.name + '" align="absmiddle" />');

}

function contextMenu_addLink(linkUrl,linkLabel){
	this.linkUrls.push(linkUrl);
	this.linkLabels.push(linkLabel);
}


