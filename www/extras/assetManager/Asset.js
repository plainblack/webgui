
//--------Constructor--------------------

//Creates a new asset object.
function Asset() {
		//properties
        this.url = "";
        this.rank = 1;
        this.labels = new Array();
        this.assetId = "";
		this.type = "";
        this.title = "";
        this.size = 0;
        this.lastUpdate = "";
        this.icon = "";
        this.div = null;
        this.dragEnabled = true;
        this.allowMultiSelect = true;
        this.isParent=false;
		
//---------Method Implementations -------------

this.registerEvents = function() {		
	this.div.ondblclick=Asset_doubleClick;	
	this.div.onmousedown=Asset_mouseDown;	
	this.div.oncontextmenu=Asset_rightClick;	

}

//Moving to a new parent (move)
//----------------------
//url + ?||& + func=setParent&assetId= + assetId 		
this.setParent = function(asset) {
	//parentURL
	location.href = "http://" + manager.tools.getHostName(location.href) + manager.tools.addParamDelimiter(this.url) + "func=setParent&assetId="+ asset.assetId;		
}
	
			
//Set the rank of an asset amongst its siblings (move)
//---------------------------------------------
//url + ?||& + func=setRank&rank= + newRank
this.setRank = function(rank) {
	//to child
	location.href = "http://" + manager.tools.getHostName(location.href) + manager.tools.addParamDelimiter(this.url) + "func=setRank&rank="+ rank;		
}


//url + ?||& + func=editTree 				
this.editTree = function() {	
	//parentURL
	location.href = "http://" + manager.tools.getHostName(location.href) + manager.tools.addParamDelimiter(this.url) + "func=editTree";		
}


//Edit the properties of an asset (edit)
//-------------------------------
//url + ?||& + func=edit
this.edit = function() {
	location.href = "http://" + manager.tools.getHostName(location.href) + manager.tools.addParamDelimiter(this.url) + "func=edit&proceed=manageAssets";		
}

//Edit the properties of an asset (edit)
//-------------------------------
//url + ?||& + func=edit
this.go = function() {
	location.href = "http://" + manager.tools.getHostName(location.href) + manager.tools.addParamDelimiter(this.url) + "func=manageAssets";		
}

//View an asset (view)
//-------------
//url + ?||& + func=view
this.view = function() {
	location.href = "http://" + manager.tools.getHostName(location.href) + this.url;		
}

//displays the right click context menu
this.getContextMenu = function () {
    var arr = new Array();    
    if (AssetManager_getManager().display.overObjects.length == 1) {
    	arr[arr.length] = new ContextMenuItem(this.labels["go"],"javascript:manager.display.contextMenu.owner.go()");
   	 	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
	    arr[arr.length] = new ContextMenuItem(this.labels["view"],"javascript:manager.display.contextMenu.owner.view()");
    	arr[arr.length] = new ContextMenuItem(this.labels["edit"],"javascript:manager.display.contextMenu.owner.edit()");
    }
    
	arr[arr.length] = new ContextMenuItem(this.labels["delete"],"javascript:manager.remove()");        
 	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
  	arr[arr.length] = new ContextMenuItem(this.labels["cut"],"javascript:AssetManager_getManager().cut()");        
   	arr[arr.length] = new ContextMenuItem(this.labels["copy"],"javascript:manager.copy()");
    
   	if (AssetManager_getManager().display.overObjects.length ==1) {
    	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
    	arr[arr.length] = new ContextMenuItem(this.labels["editTree"],"javascript:manager.display.contextMenu.owner.editTree()");        
	}    

	return arr;    
}

this.select= function() {
	this.div.className="am-grid-row-over";				
}

this.deselect = function() {
	this.div.className="am-grid-row";				
}

}//end object		

//Staic Methods
function Asset_doubleClick(e) {
    alert("here");
    var dom = document.getElementById&&!document.all;
    var e=dom? e : event;
    var obj =dom? e.target : e.srcElement
   	
   	AssetManager_getManager().getAsset(obj).go();   	
}

function Asset_rightClick(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
    
    if (!dom) { 
        e.cancelBubble = true;
        e.returnValue = false;
    }

    obj =dom? e.target : e.srcElement

   	var asset = AssetManager_getManager().getAsset(obj);
       
    manager.display.contextMenu.owner = asset;
    manager.displayContextMenu(e.clientX,e.clientY,asset);
    
    return false;
} 

function Asset_mouseDown(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;

	//Display_adjustScrollBars(e);

    if (e.button==2) {
	    //this is a hack to get the context menu stuff to work right in IE
   	 	if (!dom) {
     	    e.cancelBubble = true;
        	e.returnValue = false;
    	}
    }    

    return false;
} 


