//Confugration
//sets the drag accruacy 
//a value of 0 is most accurate.  The number can be raised to improve performance.
var accuracy = 2;

//list of the content item names.  Could be searched for, but hard coded for performance
var draggableObjectList=new Array();
//Internal Config (Do not Edit)

//browser check
//var dom=document.getElementById&&!document.all
var docElement = document.documentElement;
var pageURL = "";
//var topelement=dom? "HTML" : "BODY"
var pageHeight=0;
var pageWidth=0;
var scrollJump=50;
var blankCount=1;

var Dom = YAHOO.util.Dom;
//var Event = YAHOO.util.Event;
var DDM = YAHOO.util.DragDropMgr;



//goes up the parent tree until class is found. If not found, returns null
function dragable_getObjectByClass(target,clazz) {
    var classMatch = new RegExp("\\b" + clazz + "\\b");
    var dom=document.getElementById&&!document.all;
    var topelement=dom? "HTML" : "BODY";
    while (target.tagName!=topelement && target.className.search(classMatch) == -1){
        target=dom? target.parentNode : target.parentElement
    }

    if (target.className.search(classMatch) != -1){
        return target;
    }else {
        return null;
    }
}

YAHOO.webgui = {};

YAHOO.webgui.DDList = function(id, sGroup, config) {

    YAHOO.webgui.DDList.superclass.constructor.call(this, id, sGroup, config);

    this.logger = this.logger || YAHOO;
    var el = this.getDragEl();
    Dom.setStyle(el, "opacity", 0.67); // The proxy is slightly transparent

    this.goingUp = false;
    this.lastY = 0;
};

YAHOO.extend(YAHOO.webgui.DDList, YAHOO.util.DDProxy, {

    startDrag: function(x, y) {
        this.logger.log(this.id + " startDrag");

        // make the proxy look like the source element
        var dragEl = this.getDragEl();
        var clickEl = this.getEl();
        Dom.setStyle(clickEl, "visibility", "hidden");

        dragEl.innerHTML = clickEl.innerHTML;

        Dom.setStyle(dragEl, "color", Dom.getStyle(clickEl, "color"));
        Dom.setStyle(dragEl, "backgroundColor", Dom.getStyle(clickEl, "backgroundColor"));
        Dom.setStyle(dragEl, "border", "2px solid gray");
    },


    //Put things back like they were
    onDragOut: function(e,id){
        var obj = Dom.get(id);
        if (dragable_isBlank(obj)) {
            document.getElementById(id).className="blank";
        }else if (obj.className == 'draggedOverTop' || obj.className == 'draggedOverBottom') {
            document.getElementById(id).className="dragable";
        }
    },

    endDrag: function(e) {

        var srcEl = this.getEl();
        var proxy = this.getDragEl();

        // Show the proxy element and animate it to the src element's location
        Dom.setStyle(proxy, "visibility", "");
        var a = new YAHOO.util.Motion( 
            proxy, { 
                points: { 
                    to: Dom.getXY(srcEl)
                }
            }, 
            0.2, 
            YAHOO.util.Easing.easeOut 
        )
        var proxyid = proxy.id;
        var thisid = this.id;

        // Hide the proxy and show the source element when finished with the animation
        a.onComplete.subscribe(function() {
                Dom.setStyle(proxyid, "visibility", "hidden");
                Dom.setStyle(thisid, "visibility", "");
            });
        a.animate();
    },

    onDragDrop: function(e, id) {
    
        var position; 
        if(this.goingUp){
            position = "top";
        }else{
            position = "bottom";
        }
        var target = this.getEl().parentNode.parentNode;
        var destination = Dom.get(id);
        if(!dragable_isBlank(destination)){
            destination.className = "dragable";
            destination = Dom.get(id).parentNode.parentNode;
        }
        dragable_moveContent(target, destination ,position);

        var url = pageURL + dragable_getContentMap();
        
        document.getElementById("dragSubmitter").src = url; 

        return;
        // If there is one drop interaction, the li was dropped either on the list,
        // or it was dropped on the current location of the source element.
        if (DDM.interactionInfo.drop.length === 1) {

            // The position of the cursor at the time of the drop (YAHOO.util.Point)
            var pt = DDM.interactionInfo.point; 

            // The region occupied by the source element at the time of the drop
            var region = DDM.interactionInfo.sourceRegion; 

            // Check to see if we are over the source element's location.  We will
            // append to the bottom of the list once we are sure it was a drop in
            // the negative space (the area of the list without any list items)
            if (!region.intersect(pt)) {
                var destEl = Dom.get(id);
                var destDD = DDM.getDDById(id);
                destEl.appendChild(this.getEl());
                destDD.isEmpty = false;
                DDM.refreshCache();
            }

        }
    },

    onDrag: function(e) {
        // Keep track of the direction of the drag for use during onDragOver
        var y = YAHOO.util.Event.getPageY(e);
        if (y < this.lastY) {
            this.goingUp = true;
        } else if (y > this.lastY) {
            this.goingUp = false;
        }
        this.lastY = y;
        dragable_adjustScrollBars(e);
    },

    onDragOver: function(e, id) {
        var srcEl = this.getEl();
        if(srcEl.id == id){return;}

        var obj = Dom.get(id);
        // We are only concerned with list items, we ignore the dragover
        // notifications for the list.
        if (dragable_isBlank(obj)) {
            document.getElementById(id).className="blankOver";
        }else if (this.goingUp) {
            document.getElementById(id).className="draggedOverTop";
        }else {
            document.getElementById(id).className="draggedOverBottom";
        }

/*        if (destEl.nodeName.toLowerCase() == "li") {
            var orig_p = srcEl.parentNode;
            var p = destEl.parentNode;

            if (this.goingUp) {
                p.insertBefore(srcEl, destEl); // insert above
            } else {
                p.insertBefore(srcEl, destEl.nextSibling); // insert below
            }

            DDM.refreshCache();
        }
*/
    }
});

//initialization routine, must be called on load.  Sets up event handlers
function dragable_init(url) {

	docElement = document.documentElement;

	if (document.compatMode == "BackCompat") {
		docElement = document.body;
	}

        pageURL = url;
    //window.scroll(10,500);
    //set up event handlers
//    document.onmouseup=dragable_dragStop;
//    document.onkeydown=dragable_checkKeyEvent;
    
    //fill the draggableObject list
    obj = document.getElementById("position1");    
    contentCount=2;    
    while (obj != null) {        
        tbody = dragable_getElementChildren(obj);
        children = dragable_getElementChildren(tbody[0]);
            
        if (children.length == 0) {
            //stick in a blank
            var blank_id =dragable_appendBlankRow(tbody[0]);
            new YAHOO.util.DDTarget(blank_id);
        }else {        
            for (i = 0; i< children.length;i++) {
                draggableObjectList[draggableObjectList.length] = children[i];
                dragDropElement = document.getElementById(children[i].id + "_div");
                dragDrop = new YAHOO.webgui.DDList(dragDropElement);
                new YAHOO.util.DDTarget(dragDropElement);
                dragDrop.setHandleElId(children[i].id + "_handle");
            }       
        }
        obj = document.getElementById("position" + contentCount);
        contentCount++;
    }
}

//checks to see if the scroll bars need to be adjusted
function dragable_adjustScrollBars(e) {

        scrY=0;
        scrX=0;
        if (e.clientY > docElement.clientHeight-scrollJump) {
            if (e.clientY + docElement.scrollTop < pageHeight - (scrollJump + 60)) {
                scrY=scrollJump;
                window.scroll(docElement.scrollLeft,docElement.scrollTop + scrY);
                y-=scrY;
            }
        }else if (e.clientY < scrollJump) {
            if (docElement.scrollTop < scrollJump) {
                scrY = docElement.scrollTop;
            }else {
                scrY=scrollJump;
            }
            window.scroll(docElement.scrollLeft,docElement.scrollTop - scrY);
            y+=scrY;
        }


        if (e.clientX > docElement.clientWidth-scrollJump) {
            if (e.clientX + docElement.scrollLeft < pageWidth - (scrollJump + 60)) {
                scrX=scrollJump;
                window.scroll(docElement.scrollLeft + scrX,docElement.scrollTop);
                x-=scrX;
            } 
        }else if (e.clientX < scrollJump) {
            if (docElement.scrollLeft < scrollJump) {
                scrX = docElement.scrollLeft;
            }else {
                scrX=scrollJump;
            }
            window.scroll(docElement.scrollLeft - scrX,docElement.scrollTop);
            x+=scrX;
        }
}

function dragable_isBlank(td) {
    if (td.id.indexOf("blank") != -1) {
        return true;
    }
    return false;

}

//gets the element children of a dom object
function dragable_getElementChildren(obj) {
    var myArray= new Array();    
    mycnt = 0;
    for (i=0;i<obj.childNodes.length;i++) {
        if (obj.childNodes[i].nodeType==1) {
            myArray[mycnt] = obj.childNodes[i];
            mycnt++;
        }
    }
    return myArray;
}

function dragable_appendBlankRow(parent) {
    var blank = document.getElementById("blank");
    blank.className="blank";
    blankClone = blank.cloneNode(true);
    blankClone.id = "blank" + new Date().getTime() + blankCount++;
    draggableObjectList[draggableObjectList.length] = blankClone;
    parent.appendChild(blankClone);
    blankClone.style.top=0+"px";
    blankClone.style.left=0+"px";
    blank.className="hidden";
    return blankClone.id;
}


//moves a table row from one table to another. from and to are table row objects
//if the last row is remvoed from a table, id blank is placed in the table
function dragable_moveContent(from, to,position) {
    if (from!=to && from && to) {    
        var fromParent = from.parentNode;
        fromParent.removeChild(from);
        if (dragable_getElementChildren(fromParent).length == 0) {
            var blank_id = dragable_appendBlankRow(fromParent);
            new YAHOO.util.DDTarget(blank_id);
        }

        var toParent = to.parentNode;
        var toChildren = dragable_getElementChildren(toParent);
        
        if (toChildren[0].id.indexOf("blank") != -1) {
            toParent.removeChild(document.getElementById(toChildren[0].id));
            toParent.appendChild(from);
        }else if (position == "top"){
            toParent.insertBefore( from, to );
        }else {
            children = dragable_getElementChildren(toParent);
            i=0;
            while(children[i] != to && i < children.length) {
                i++;
            }

            if (i == children.length - 1) {
                toParent.appendChild(from);                
            }else {
                toParent.insertBefore(from,children[i+1]);
            }
        }
    }
}

function dragable_getContentMap() {
    //ex 1001,2004;896,494,10010

    contentMap = "";
    contentCount=1;
    var contentArea = document.getElementById("position1");
    while (contentArea) {
        if ((contentMap != "") || (contentArea.id == 'position2')) {
            contentMap+=".";
        }

        //get down to the tr area
        children = dragable_getElementChildren(contentArea);
        children=dragable_getElementChildren(children[0]);
        for (i=0;i<children.length;i++) {
            if (contentMap != "" && (contentMap.lastIndexOf(".") != contentMap.length-1)) {
                contentMap+=",";
            }
            
            if (children[i].id.indexOf("blank") == -1) {
                contentMap+=children[i].id.replace(/^td/,"");                
            }
        }

        contentCount++;
        contentArea = document.getElementById("position" + contentCount);
    }    
    return contentMap;
}

