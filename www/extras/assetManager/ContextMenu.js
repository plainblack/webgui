

//--------Constructor--------------------

//document.write('<div id="contextMenu" class="contextMenu"></div>');

//Constructor for a context menu 
function ContextMenu() {
    this.render = ContextMenu_render;
    this.hide = ContextMenu_hide;
    this.owner = null;
    this.contextMenu = document.getElementById("contextMenu");
    this.contextMenu.oncontextmenu=new function() {return false;};
    this.contextMenu.onmousedown=new function() {return false;};
    this.contextMenu.onmouseup=new function() {return false;};
    this.nameArray = new Array();
}

//Container used by the render method to delimit context menu items
function ContextMenuItem(cminame,cmilink) {
    this.name = cminame;
    this.link = cmilink;
    
}

//---------Method Implementations -------------


//renders the context menu based on the contextMenuItemArray and owner.
function ContextMenu_render(contextMenuItemArray,x,y,owner) {
//    manager.tools.showObject(this.contextMenu);        
//    	alert("top = " + this.contextMenu.className);

    this.owner = owner;

    var html='<table border="0">';
    for (var i=0;i<contextMenuItemArray.length;i++) {        
        var name = "contextMenuItem" + i + new Date().getTime();
        html+='<tr>';
        html+='    <td>'
        
        if (contextMenuItemArray[i].link == "") {
            html+=contextMenuItemArray[i].name;
        }else {
            html+='<a href="' + contextMenuItemArray[i].link +  '"><div id="' + name + '" class="contextMenuTab">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;' + contextMenuItemArray[i].name + '</div></a>';
        }
        
        html+='</td>';
        html+='</tr>';    
        this.nameArray[this.nameArray.length] = name;          
    }

    html+='</table>';
    this.contextMenu.innerHTML = html;
   
    for (var k=0;k<this.nameArray.length;k++) {        
        if (document.getElementById(this.nameArray[k])) {
            document.getElementById(this.nameArray[k]).onmouseover=new Function("document.getElementById('" + this.nameArray[k] + "').className='contextMenuTabOver'");
            document.getElementById(this.nameArray[k]).onmouseout=new Function("document.getElementById('" + this.nameArray[k] + "').className='contextMenuTab'");
        }
    }


    if (y > parseInt(this.contextMenu.offsetHeight)) {
//        this.contextMenu.style.top = (y + document.body.scrollTop - this.contextMenu.offsetHeight -1) + "px";
        this.contextMenu.style.top = (y + window.scrollY - this.contextMenu.offsetHeight -1) + "px";
    }else {
  //      this.contextMenu.style.top = (y + document.body.scrollTop + 3) + "px";
        this.contextMenu.style.top = (y + window.scrollY + 3) + "px";
    }
    //this.contextMenu.style.left= (x + document.body.scrollLeft) + "px";
    this.contextMenu.style.left= (x + window.scrollX) + "px";


    manager.display.bringToFront(this.contextMenu);

    //alert(this.contextMenu.style.top);
    manager.tools.showObject(this.contextMenu);        
}

//hides the context menu
function ContextMenu_hide() {
    for (var k=0;k<this.nameArray.length;k++) {        
        if (document.getElementById(this.nameArray[k])) {
            document.getElementById(this.nameArray[k]).onmouseover="";
            document.getElementById(this.nameArray[k]).onmouseout="";
        }
    }
    this.contextMenu.style.visibility="hidden";
}
