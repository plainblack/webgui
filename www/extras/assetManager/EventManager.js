
//--------Constructor--------------------

function EventManager() {   
    //int document events
    document.onmousedown=EventManager_documentMouseDown;
    document.onmouseup=EventManager_documentMouseUp;
    document.onmousemove=EventManager_documentMouseMove;

    document.onkeydown=EventManager_keyDown;

    this.activityDoubleClick = EventManager_activityDoubleClick;
    this.activityRightClick = EventManager_activityRightClick;
    this.activityMouseDown = EventManager_activityMouseDown;
 
}

//---------Method Implementations -------------

function EventManager_keyDown(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
    manager.display.keyDown(e);
    return false;
}

function EventManager_activityDoubleClick(e) {
    var dom = document.getElementById&&!document.all;
    var e=dom? e : event;
    var obj =dom? e.target : e.srcElement
    obj = manager.tools.getActivity(obj);
    obj.edit();
}

function EventManager_activityRightClick(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
    
    if (!dom) { 
        e.cancelBubble = true;
        e.returnValue = false;
    }

    obj =dom? e.target : e.srcElement

    obj = manager.tools.getActivity(obj);
    
    manager.display.contextMenu.owner = obj;
    obj.displayContextMenu(e.clientX,e.clientY);
    
    return false;
} 

function EventManager_activityMouseDown(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;

    if (e.button==2) {
	    //this is a hack to get the context menu stuff to work right in IE
   	 	if (!dom) {
		    obj =dom? e.target : e.srcElement
		    var asset = manager.tools.getActivity(obj);
	    	manager.display.selectActivity(asset.div);
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
        
    var asset = manager.tools.getActivity(obj);
    
    if (asset) {
    	manager.display.selectActivity(asset.div);
	    if (e.button != 2) {
    		manager.display.dragStart(asset.div,e.clientX,e.clientY);
    		return;
    	}
    }
     
     
                    
    if (e.button != 2) {
    	manager.display.dragStart(obj,e.clientX,e.clientY);
    }
    return false;
} 

function EventManager_documentMouseUp(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;    
    obj =dom? e.target : e.srcElement
    obj = manager.tools.getActivity(obj);
        
    //if the pointer is still on the activity don't close the window.
    if (manager.display.contextMenu.owner && (!obj || obj.div.id != manager.display.contextMenu.owner.div.id)) {
        manager.display.contextMenu.hide();
    }
    manager.display.dragStop();
    //if (obj) manager.display.selectActivity(obj);
    
    manager.setEventHandlers();
    return false;
} 

function EventManager_documentMouseMove(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
    manager.display.move(e);
    return false;
} 

