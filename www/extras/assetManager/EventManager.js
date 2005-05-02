
//--------Constructor--------------------

function EventManager() {   
    //int document events
    document.onmousedown=EventManager_documentMouseDown;
    document.onmouseup=EventManager_documentMouseUp;
    document.onmousemove=EventManager_documentMouseMove;

    document.onkeydown=EventManager_keyDown;
    document.onkeyup=EventManager_keyUp;

	this.gridHeaderClick = EventManager_gridHeaderClick;
	this.gridHeaderMouseOver = EventManager_gridHeaderMouseOver;
	this.gridHeaderMouseOut = EventManager_gridHeaderMouseOut;
 
}

//---------Method Implementations -------------

function EventManager_gridHeaderMouseOver(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;

	if (!manager.display.dragEnabled) {
	    var obj =dom? e.target : e.srcElement
		var parts = obj.className.split("-");
		obj.className="am-grid-header-over-" + parts[parts.length -1];
	}
}

function EventManager_gridHeaderMouseOut(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
    var obj =dom? e.target : e.srcElement

	var parts = obj.className.split("-");

	obj.className="am-grid-header-" + parts[parts.length -1];

}

function EventManager_keyDown(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
    manager.display.keyDown(e);
    return false;
}

function EventManager_keyUp(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
    manager.display.keyUp(e);
    return false;
}


function EventManager_documentMouseDown(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;    
    obj =dom? e.target : e.srcElement
        
    var asset = manager.getAsset(obj);
        
    if (asset) {
    	
    	if (e.button != 2) {
	    	manager.display.primeLeftClickContextMenu();
    		setTimeout("AssetManager_getManager().display.displayLeftClickContextMenu(" + e.clientX + "," + e.clientY + ")",1000);
    	}
    	if (e.button != 2 || (e.button == 2 && !manager.display.isSelected(asset))) {    	
	    	manager.display.selectAsset(asset);    	
    	} 
	    if (e.button != 2) {
    		manager.display.dragStart(asset.div,e.clientX,e.clientY);
    		return;
    	}
    }
                              
    if (e.button != 2) {
    	manager.display.dragStart(obj,e.clientX,e.clientY);
    }
    return true;
} 

function EventManager_documentMouseUp(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;    
    obj =dom? e.target : e.srcElement
    var asset = manager.getAsset(obj);
                                 
    if ((asset && e.button == 2) || (manager.display.leftClickContextMenuPrimed && manager.contextMenu.owner == manager.display.focusObjects[0])) {		
		return false;
    }    
        
    //no longer want the left click context menu
    manager.display.resetLeftClickContextMenu();    
        manager.display.contextMenu.hide();
                  
    if (manager.display.contextMenu.owner && (!asset || asset.assetId != manager.display.contextMenu.owner.assetId)) {
        manager.display.contextMenu.hide();
    }else {
    }

   	if (!asset && obj.id.indexOf("contextMenuItem") == -1) {
    	manager.display.clearSelectedAssets();
   	}    

    manager.display.dragStop();
        
    return false;
} 

function EventManager_documentMouseMove(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;

    //no longer want the left click context menu
    manager.display.resetLeftClickContextMenu();    

    manager.display.move(e);
    return false;
} 

function EventManager_gridHeaderClick(e) {
    var dom = document.getElementById&&!document.all;
    var e=dom? e : event;
    var obj =dom? e.target : e.srcElement
   	
   	var parts = obj.id.split(".");   	
   	AssetManager_getManager().sortGrid(parts[parts.length-1]);   	
}
