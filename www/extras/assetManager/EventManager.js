
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
    this.assetDoubleClick = EventManager_assetDoubleClick;
    this.assetRightClick = EventManager_assetRightClick;
    this.assetMouseDown = EventManager_assetMouseDown;
 
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

function EventManager_assetDoubleClick(e) {
    var dom = document.getElementById&&!document.all;
    var e=dom? e : event;
    var obj =dom? e.target : e.srcElement
   	
   	AssetManager_getManager().getAsset(obj).go();   	
}

function EventManager_assetRightClick(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
    
    if (!dom) { 
        e.cancelBubble = true;
        e.returnValue = false;
    }

    obj =dom? e.target : e.srcElement

   	var asset = manager.getAsset(obj);
       
    manager.display.contextMenu.owner = asset;
    manager.displayContextMenu(e.clientX,e.clientY,asset);
    
    return false;
} 

function EventManager_assetMouseDown(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;

	Display_adjustScrollBars(e);

    if (e.button==2) {
	    //this is a hack to get the context menu stuff to work right in IE
   	 	if (!dom) {
     	    e.cancelBubble = true;
        	e.returnValue = false;
    	}
    }    

    return false;
} 

function EventManager_documentMouseDown(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;    
    obj =dom? e.target : e.srcElement
        
    var asset = manager.getAsset(obj);
    
    if (asset) {
    	
    	if (e.button != 2 || (e.button == 2 && !manager.display.isSelected(asset))) {    	
	    	manager.display.selectAsset(asset);    	
    	} 
	    if (e.button != 2) {
    		manager.display.dragStart(asset.div,e.clientX,e.clientY);
    		return;
    	}
    }else {
    	manager.display.clearSelectedAssets();
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
    //obj = manager.tools.getActivity(obj);
   
    var asset = manager.getAsset(obj);
                        
    if (manager.display.contextMenu.owner && (!asset || asset.assetId != manager.display.contextMenu.owner.assetId)) {
        manager.display.contextMenu.hide();
    }else {
    	if (!asset) {
	    	manager.display.clearSelectedAssets();
    	}
    
    }
    manager.display.dragStop();
    return false;
} 

function EventManager_documentMouseMove(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
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
