//Confugration
//sets the drag accruacy 
//a value of 0 is most accurate.  The number can be raised to improve performance.
var accuracy = 4;

//list of the content item names.  Could be searched for, but hard coded for performance
var draggableObjectList=new Array();
var dragableList=new Array();
//Internal Config (Do not Edit)

//browser check
var dom=document.getElementById&&!document.all
var docElement = document.documentElement;
var pageURL = "";
var dragging=false;
var z,x,y
var accuracyCount =0;
var startTD = null;
var endTD = null;
var topelement=dom? "HTML" : "BODY"
var currentDiv = null;
var clipboard = null;
var pageHeight=0;
var pageWidth=0;
var scrollJump=50;
var blankCount=1;
// var getScript = s/<script>(.*)?<\/script>/$1/m;
var reloadIntervals = new Array();

//goes up the parent tree until class is found. If not found, returns null
function dragable_getObjectByClass(target,clazz) {
    while (target.tagName!=topelement&&target.className!=clazz){
        target=dom? target.parentNode : target.parentElement
    }

    if (target.className==clazz){
        return target;
    }else {
        return null;
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


//initialization routine, must be called on load.  Sets up event handlers
function dragable_init(url) {

	docElement = document.documentElement;

	if (document.compatMode == "BackCompat") {
		docElement = document.body;
	}

    pageURL = url;
    //set up event handlers
    document.onmouseup=dragable_dragStop;
    document.onmousemove=dragable_move;

    //fill the draggableObject list
    obj = document.getElementById("position1");    
    contentCount=2;    
    while (obj != null) {        
        tbody = dragable_getElementChildren(obj);
        children = dragable_getElementChildren(tbody[0]);

        var hasMovableChildren = false;
        for (i = 0; i< children.length;i++) {
            var childId = children[i].id;
            childId = childId.replace(/^td/,'');
            if (available_dashlets[childId]) {
                draggableObjectList[draggableObjectList.length] = children[i];
                dragableList[dragableList.length]=document.getElementById(children[i].id + "_div");
                hasMovableChildren = true;
            }
        }
        //Add a blank row if the position is empty, or if there are no movable children.
        if (! hasMovableChildren) {
            dragable_appendBlankRow(tbody[0]);
        }
        obj = document.getElementById("position" + contentCount);
        contentCount++;
    }

    for (i=0;i<draggableObjectList.length;i++) {
        eval("document.getElementById('" + draggableObjectList[i].id + "').onmousedown=dragable_dragStart");        
    }
}

//called on mouse move.
function dragable_move(e){
    e=dom? e : event;

    if (dragging){        
        if (accuracyCount==accuracy) {                                    
            tmp = dragable_spy(dom? e.pageX: (e.clientX + docElement.scrollLeft),dom? e.pageY: (e.clientY + docElement.scrollTop));            
            if (tmp.length != 0) {
                dragable_dragOver(tmp[0],tmp[1]);
            }else {
                //only occurs if not found

                if (endTD != null) {
                    if (!dragable_isBlank(endTD)) {
                        document.getElementById(endTD.id + "_div").className="dragable";
                    }else {
                        endTD.className="blank";
                    }
                    endTDPos=null;
                    endTD=null;
                }
            }

            accuracyCount=0;
        }else {
            accuracyCount++;
        }

        dragable_adjustScrollBars(e);
      //  alert('x is: '+ (temp1+e.clientX-x));
        z.style.left=(temp1+e.clientX-x)+"px";
        z.style.top=(temp2+e.clientY-y)+"px";
        return false
 //   }else {

 //       tmp = dragable_spy(dom? e.pageX: (e.clientX + docElement.scrollLeft),dom? e.pageY: (e.clientY + docElement.scrollTop));

 //       if (tmp.length == 0) {
 //           currentDiv = null;
 //       }else {
 //           currentDiv = tmp[0];
 //       }

    }
}

function dragable_dragStart(e){
    e=dom? e : event;
    var fObj=dom? e.target : e.srcElement

    if (fObj.nodeName=='IMG') { return;}

    fObj2 = dragable_getObjectByClass(fObj,"dragTrigger");  

    if (!fObj2) {
        return;
    }

    fObj = dragable_getObjectByClass(fObj,"dragable");    

    if (fObj == null) return;

    //set the start td        
    startTD=document.getElementById(fObj.id.substr(0,fObj.id.indexOf("_div")));

    fObj.className="dragging";        

    //set the page height and width in a var since IE changes them when scrolling
    pageHeight = docElement.scrollHeight;
    pageWidth = docElement.scrollWidth;

    dragging=true
    z=fObj;
    temp1=z.style.left;
    temp1=temp1.replace(/px/g,'')+0;
    temp1=parseInt(temp1);
    temp2=z.style.top;
    temp2=temp2.replace(/px/g,'')+0;
    temp2=parseInt(temp2);
//    alert(temp1,temp2);
    x=e.clientX;
    y=e.clientY;
    return false
}

function dragable_isBlank(td) {
    if (td.id.indexOf("blank") != -1) {
        return true;
    }
    return false;

}

//returns an array.  array[0] holds the tr object, and array[1] holds the position (top or bottom)
function dragable_spy(x, y) {

    var returnArray = new Array();
    for (i=0;i<draggableObjectList.length;i++) {
        td = draggableObjectList[i];    

        //this is a hack
      if (td == null || td == startTD || !td.parentNode || !td.parentNode.parentNode) { continue; }
        var fObj=td;

        y1=0;
        x1=0;
			var gap = (td.className=='blank' || (td.parentNode.parentNode.rows.length == td.rowIndex + 1)) ? 500 : 0

        while (fObj!=null && fObj.tagName!=topelement){
            y1+=fObj.offsetTop;   
            x1+=fObj.offsetLeft;
            fObj=fObj.offsetParent;
        }

        if (x >x1 && x < (x1 + td.offsetWidth)) {
            if (y> y1 && y< (y1 + (td.offsetHeight/2))) {
                    returnArray[0] = td;
                    returnArray[1] = "top";
                    return returnArray;
            }else if (y> y1 && y< (y1 + td.offsetHeight + gap)) {
                    returnArray[0] = td;
                    returnArray[1] = "bottom";
                    return returnArray;
            }
        }
    }

    return returnArray;
}

//Called when a content item is dragged over
function dragable_dragOver(obj,position) {            

    if (endTD == obj && endTDPos == position ) {
        return;
    }


    if(endTD != null && endTD != obj) {       
        if (dragable_isBlank(endTD)) {
            document.getElementById(endTD.id).className="blank";
        }else {
            document.getElementById(endTD.id + "_div").className="dragable";
        }        
    }

    if (dragable_isBlank(obj)) {
        divName = td.id;
    }else {
        divName = td.id + "_div";
    }

    if (dragable_isBlank(obj)) {
        document.getElementById(divName).className="blankOver";
        endTDPos=null;
    }else if (position == "top") {
        endTDPos=position;
        document.getElementById(divName).className="draggedOverTop";        
    }else {
        endTDPos=position;
        document.getElementById(divName).className="draggedOverBottom";
    }

    endTD=obj;    
}

//called on mouse up, If an element is being dragged, this method does the right thing.
function dragable_dragStop(e) {    
    dragging=false;            
    if (z) {
        if (endTD !=null && startTD!=null) {
            fObj2 = dragable_getObjectByClass(startTD,"availableDashlet");  
            dragable_moveContent(startTD,endTD,endTDPos);
            if (fObj2) {
                var replId = startTD.id;
                replId = replId.replace(/^td/,'');
                //alert(replId);
                var replUrl = available_dashlets[replId];
                //alert(replUrl);
                contentDiv = document.getElementById("ct" + replId + "_div");

                var callback = {
                    success : function(req) {
                        var myArr528 = req.responseText.split(/beginDebug/mg,1);
                        contentDiv.innerHTML = myArr528[0];
                    },
                    failure : function(req) {
                        alert("Move failed.  Problem with connection.  Please refresh the page and try again.");
                    }
                }

                var url    = encodeURI(replUrl) + "?func=ajaxInlineView";
                var status = YAHOO.util.Connect.asyncRequest('GET',url,callback);
            }
            startTD=null;        

            if (dragable_isBlank(endTD)) {
                divName = endTD.id;
            }
            else {
                divName=endTD.id + "_div";
                document.getElementById(divName).className="dragable";
            }
            dragable_postNewContentMap();    
        }                        

        for(i=0;i<dragableList.length;i++) {
            dragableList[i].style.top='0px';
            dragableList[i].style.left='0px';
            dragableList[i].className="dragable";    
        }

        //this is a ie hack for a render bug
        for(i=0;i<draggableObjectList.length;i++) {
            if (draggableObjectList[i]) {                                    
                draggableObjectList[i].style.top='1px';
                draggableObjectList[i].style.left='1px';                    
                draggableObjectList[i].style.top='0px';
                draggableObjectList[i].style.left='0px';                    
            }
        }
    }

    startTD=null;

    if (endTD != null) {
        endTD.position = null;
        endTD=null;
    }    
}

function dragable_postNewContentMap() {
	var callback = {
        success : function(req) {  },
        failure : function(req) {
            alert("Post New Content Map Failed.  Problem with connection.  Please refresh the page and try again.");
        }
    }

    var url       = encodeURI(pageURL);
    var dataParts = "func=setContentPositions&map=" + dragable_getContentMap();
    var status = YAHOO.util.Connect.asyncRequest('POST',url,callback,dataParts);

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

//gets the element children of a dom object that can be moved, including the blank row
function dragable_getMovableChildren(obj) {
    var myArray= new Array();    
    mycnt = 0;
    for (i=0;i<obj.childNodes.length;i++) {
        if (obj.childNodes[i].nodeType==1) {
            var childId = obj.childNodes[i].id;
            childId = childId.replace(/^td/,'');
            if (available_dashlets[childId] || dragable_isBlank(obj.childNodes[i])) {
                myArray[mycnt] = obj.childNodes[i];
                mycnt++;
            }
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
    blankClone.style.top='0px';
    blankClone.style.left='0px';
    blank.className="hidden";
}


// deletes a dashlet (moves it from its current location to the bottom of position 1)
function dragable_deleteContent(e,from,postNewContentMap) {
	from = dragable_getObjectByClass(from,"dragable");
	from = document.getElementById(from.id.substr(0,from.id.indexOf("_div")));
	dragable_moveContent(from,document.getElementById('position1').rows[document.getElementById('position1').rows.length - 1],"bottom");
	 if (postNewContentMap) {dragable_postNewContentMap();} // This will help avoid meaningless web server hits.
}

//moves a table row from one table to another. from and to are table row objects
//if the last row is removed from a table, id blank is placed in the table
function dragable_moveContent(from, to,position) {
    if (from!=to && from && to) {    
        var fromParent = from.parentNode;
        fromParent.removeChild(from);

        if (dragable_getMovableChildren(fromParent).length == 0) {
            dragable_appendBlankRow(fromParent);
        }

        var toParent = to.parentNode;
        var toChildren = dragable_getMovableChildren(toParent);

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

function dashboard_toggleEditForm(event,shortcutId,editFormUrl) {
	//discover if form is there.
	var existingForm = document.getElementById("form" + shortcutId + "_div");
	if (existingForm) {
		var throwAway = existingForm.parentNode.removeChild(existingForm);
		return;
	}
	// Create the new form element.
	var formDiv = document.createElement("div");
	formDiv.id = "form" + shortcutId + "_div";
	formDiv.className = "userPrefsForm";
	var parentDiv = document.getElementById("td" + shortcutId + "_div");
	var contentDiv = document.getElementById("ct" + shortcutId + "_div");
	parentDiv.insertBefore(formDiv,contentDiv);

    var callback = {
        success : function(req) {
            var myHtml = req.responseText.split(/beginDebug/mg,1)[0];
			var myScript = myHtml.split(/\<script\>/mg)[1];
			if (myScript) {
				myScript = myScript.split(/\<\/script\>/mg)[0];
				eval(myScript);
			}
			formDiv.innerHTML = myHtml;
            var myTips;
            myTips = YAHOO.util.Dom.getElementsByClassName('wg-hoverhelp','',formDiv);
            for (var i = myTips.length; i--; ) {
                var myTip = new YAHOO.widget.Tooltip(myTips[i], {  
                    autodismissdelay: 1000000,
                    context: myTips[i].parentNode,
                    text   : myTips[i].innerHTML
                });
                myTips[i].innerHTML = "";
            }
        },
        failure : function(req) {
            alert("Toggle Edit Form failed.  Problem with connection.  Please refresh the page and try again.");
        }
    }

    editFormUrl = encodeURI(editFormUrl);
    var status = YAHOO.util.Connect.asyncRequest('GET',editFormUrl,callback);

}

//Edit Dashlet Form is for the new per-asset settings for the Dashboard that
//sets required, and movable.  It calls a method from the Dashboard and saves
//settings in a dashboard collateral table.

function dashboard_toggleEditDashletForm(event,assetId,dashboardUrl) {
	//discover if form is there.
    var divId = "form" + assetId + "_editDashlet_div";
	var existingForm = document.getElementById(divId);
	if (existingForm) {
		var throwAway = existingForm.parentNode.removeChild(existingForm);
		return;
	}
	// Create the new form element.
	var formDiv = document.createElement("div");
	formDiv.id = divId;
	formDiv.className = "userPrefsForm";
	var parentDiv = document.getElementById("td" + assetId + "_div");
	var contentDiv = document.getElementById("ct" + assetId + "_div");
	parentDiv.insertBefore(formDiv,contentDiv);

    var callback = {
        success : function(req) {
			formDiv.innerHTML = req.responseText;
            var myTips;
            myTips = YAHOO.util.Dom.getElementsByClassName('wg-hoverhelp','',formDiv);
            for (var i = myTips.length; i--; ) {
                var myTip = new YAHOO.widget.Tooltip(myTips[i], {  
                    autodismissdelay: 1000000,
                    context: myTips[i].parentNode,
                    text   : myTips[i].innerHTML
                });
                myTips[i].innerHTML = "";
            }
        },
        failure : function(req) {
            alert("Dashlet Edit Form failed.  Problem with connection.  Please refresh the page and try again.");
        }
    }

    var url    = encodeURI(dashboardUrl) + "?func=editDashlet;dashletAssetId="+assetId;
    var status = YAHOO.util.Connect.asyncRequest('GET',url,callback);

}

function dashboard_reloadDashlet(event,shortcutId,shortcutUrl) {
	// Reload the content div.
	contentDiv = document.getElementById("ct" + shortcutId + "_div");

    var callback = {
        success : function(req) {
            var myHtml = req.responseText.split(/beginDebug/mg,1)[0];
			var myScript = myHtml.split(/\<script\>/mg)[1];
			if (myScript) {
				myScript = myScript.split(/\<\/script\>/mg)[0];
				eval(myScript);
			}
			contentDiv.innerHTML = myHtml;
        },
        failure : function(req) {
            alert("Reload Dashlet failed.  Problem with connection.  Please refresh the page and try again.");
        }
    }

    var url    = encodeURI(shortcutUrl) + "?func=ajaxInlineView";
    var status = YAHOO.util.Connect.asyncRequest('GET',url,callback);
}

function makeActive(o) { o.style.display = "inline"; }

function makeInactive(o) { o.style.display = "none"; }

//Confugration
//sets the drag accruacy 
//a value of 0 is most accurate.  The number can be raised to improve performance.
var accuracy = 4;

//list of the content item names.  Could be searched for, but hard coded for performance
var draggableObjectList=new Array();
var dragableList=new Array();
//Internal Config (Do not Edit)

//browser check
var dom=document.getElementById&&!document.all
var docElement = document.documentElement;
var pageURL = "";
var dragging=false;
var z,x,y
var accuracyCount =0;
var startTD = null;
var endTD = null;
var topelement=dom? "HTML" : "BODY"
var currentDiv = null;
var clipboard = null;
var pageHeight=0;
var pageWidth=0;
var scrollJump=50;
var blankCount=1;
// var getScript = s/<script>(.*)?<\/script>/$1/m;
var reloadIntervals = new Array();

//goes up the parent tree until class is found. If not found, returns null
function dragable_getObjectByClass(target,clazz) {
    while (target.tagName!=topelement&&target.className!=clazz){
        target=dom? target.parentNode : target.parentElement
    }

    if (target.className==clazz){
        return target;
    }else {
        return null;
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


//initialization routine, must be called on load.  Sets up event handlers
function dragable_init(url) {

	docElement = document.documentElement;

	if (document.compatMode == "BackCompat") {
		docElement = document.body;
	}

    pageURL = url;
    //set up event handlers
    document.onmouseup=dragable_dragStop;
    document.onmousemove=dragable_move;

    //fill the draggableObject list
    obj = document.getElementById("position1");    
    contentCount=2;    
    while (obj != null) {        
        tbody = dragable_getElementChildren(obj);
        children = dragable_getElementChildren(tbody[0]);

        var hasMovableChildren = false;
        for (i = 0; i< children.length;i++) {
            var childId = children[i].id;
            childId = childId.replace(/^td/,'');
            if (available_dashlets[childId]) {
                draggableObjectList[draggableObjectList.length] = children[i];
                dragableList[dragableList.length]=document.getElementById(children[i].id + "_div");
                hasMovableChildren = true;
            }
        }
        //Add a blank row if the position is empty, or if there are no movable children.
        if (! hasMovableChildren) {
            dragable_appendBlankRow(tbody[0]);
        }
        obj = document.getElementById("position" + contentCount);
        contentCount++;
    }

    for (i=0;i<draggableObjectList.length;i++) {
        eval("document.getElementById('" + draggableObjectList[i].id + "').onmousedown=dragable_dragStart");        
    }
}

//called on mouse move.
function dragable_move(e){
    e=dom? e : event;

    if (dragging){        
        if (accuracyCount==accuracy) {                                    
            tmp = dragable_spy(dom? e.pageX: (e.clientX + docElement.scrollLeft),dom? e.pageY: (e.clientY + docElement.scrollTop));            
            if (tmp.length != 0) {
                dragable_dragOver(tmp[0],tmp[1]);
            }else {
                //only occurs if not found

                if (endTD != null) {
                    if (!dragable_isBlank(endTD)) {
                        document.getElementById(endTD.id + "_div").className="dragable";
                    }else {
                        endTD.className="blank";
                    }
                    endTDPos=null;
                    endTD=null;
                }
            }

            accuracyCount=0;
        }else {
            accuracyCount++;
        }

        dragable_adjustScrollBars(e);
      //  alert('x is: '+ (temp1+e.clientX-x));
        z.style.left=(temp1+e.clientX-x)+"px";
        z.style.top=(temp2+e.clientY-y)+"px";
        return false
 //   }else {

 //       tmp = dragable_spy(dom? e.pageX: (e.clientX + docElement.scrollLeft),dom? e.pageY: (e.clientY + docElement.scrollTop));

 //       if (tmp.length == 0) {
 //           currentDiv = null;
 //       }else {
 //           currentDiv = tmp[0];
 //       }

    }
}

function dragable_dragStart(e){
    e=dom? e : event;
    var fObj=dom? e.target : e.srcElement

    if (fObj.nodeName=='IMG') { return;}

    fObj2 = dragable_getObjectByClass(fObj,"dragTrigger");  

    if (!fObj2) {
        return;
    }

    fObj = dragable_getObjectByClass(fObj,"dragable");    

    if (fObj == null) return;

    //set the start td        
    startTD=document.getElementById(fObj.id.substr(0,fObj.id.indexOf("_div")));

    fObj.className="dragging";        

    //set the page height and width in a var since IE changes them when scrolling
    pageHeight = docElement.scrollHeight;
    pageWidth = docElement.scrollWidth;

    dragging=true
    z=fObj;
    temp1=z.style.left;
    temp1=temp1.replace(/px/g,'')+0;
    temp1=parseInt(temp1);
    temp2=z.style.top;
    temp2=temp2.replace(/px/g,'')+0;
    temp2=parseInt(temp2);
//    alert(temp1,temp2);
    x=e.clientX;
    y=e.clientY;
    return false
}

function dragable_isBlank(td) {
    if (td.id.indexOf("blank") != -1) {
        return true;
    }
    return false;

}

//returns an array.  array[0] holds the tr object, and array[1] holds the position (top or bottom)
function dragable_spy(x, y) {

    var returnArray = new Array();
    for (i=0;i<draggableObjectList.length;i++) {
        td = draggableObjectList[i];    

        //this is a hack
      if (td == null || td == startTD || !td.parentNode || !td.parentNode.parentNode) { continue; }
        var fObj=td;

        y1=0;
        x1=0;
			var gap = (td.className=='blank' || (td.parentNode.parentNode.rows.length == td.rowIndex + 1)) ? 500 : 0

        while (fObj!=null && fObj.tagName!=topelement){
            y1+=fObj.offsetTop;   
            x1+=fObj.offsetLeft;
            fObj=fObj.offsetParent;
        }

        if (x >x1 && x < (x1 + td.offsetWidth)) {
            if (y> y1 && y< (y1 + (td.offsetHeight/2))) {
                    returnArray[0] = td;
                    returnArray[1] = "top";
                    return returnArray;
            }else if (y> y1 && y< (y1 + td.offsetHeight + gap)) {
                    returnArray[0] = td;
                    returnArray[1] = "bottom";
                    return returnArray;
            }
        }
    }

    return returnArray;
}

//Called when a content item is dragged over
function dragable_dragOver(obj,position) {            

    if (endTD == obj && endTDPos == position ) {
        return;
    }


    if(endTD != null && endTD != obj) {       
        if (dragable_isBlank(endTD)) {
            document.getElementById(endTD.id).className="blank";
        }else {
            document.getElementById(endTD.id + "_div").className="dragable";
        }        
    }

    if (dragable_isBlank(obj)) {
        divName = td.id;
    }else {
        divName = td.id + "_div";
    }

    if (dragable_isBlank(obj)) {
        document.getElementById(divName).className="blankOver";
        endTDPos=null;
    }else if (position == "top") {
        endTDPos=position;
        document.getElementById(divName).className="draggedOverTop";        
    }else {
        endTDPos=position;
        document.getElementById(divName).className="draggedOverBottom";
    }

    endTD=obj;    
}

//called on mouse up, If an element is being dragged, this method does the right thing.
function dragable_dragStop(e) {    
    dragging=false;            
    if (z) {
        if (endTD !=null && startTD!=null) {
            fObj2 = dragable_getObjectByClass(startTD,"availableDashlet");  
            dragable_moveContent(startTD,endTD,endTDPos);
            if (fObj2) {
                var replId = startTD.id;
                replId = replId.replace(/^td/,'');
                //alert(replId);
                var replUrl = available_dashlets[replId];
                //alert(replUrl);
                contentDiv = document.getElementById("ct" + replId + "_div");

                var callback = {
                    success : function(req) {
                        var myArr528 = req.responseText.split(/beginDebug/mg,1);
                        contentDiv.innerHTML = myArr528[0];
                    },
                    failure : function(req) {
                        alert("Move failed.  Problem with connection.  Please refresh the page and try again.");
                    }
                }

                var url    = encodeURI(replUrl) + "?func=ajaxInlineView";
                var status = YAHOO.util.Connect.asyncRequest('GET',url,callback);
            }
            startTD=null;        

            if (dragable_isBlank(endTD)) {
                divName = endTD.id;
            }
            else {
                divName=endTD.id + "_div";
                document.getElementById(divName).className="dragable";
            }
            dragable_postNewContentMap();    
        }                        

        for(i=0;i<dragableList.length;i++) {
            dragableList[i].style.top='0px';
            dragableList[i].style.left='0px';
            dragableList[i].className="dragable";    
        }

        //this is a ie hack for a render bug
        for(i=0;i<draggableObjectList.length;i++) {
            if (draggableObjectList[i]) {                                    
                draggableObjectList[i].style.top='1px';
                draggableObjectList[i].style.left='1px';                    
                draggableObjectList[i].style.top='0px';
                draggableObjectList[i].style.left='0px';                    
            }
        }
    }

    startTD=null;

    if (endTD != null) {
        endTD.position = null;
        endTD=null;
    }    
}

function dragable_postNewContentMap() {
	var callback = {
        success : function(req) {  },
        failure : function(req) {
            alert("Post New Content Map Failed.  Problem with connection.  Please refresh the page and try again.");
        }
    }

    var url       = encodeURI(pageURL);
    var dataParts = "func=setContentPositions&map=" + dragable_getContentMap();
    var status = YAHOO.util.Connect.asyncRequest('POST',url,callback,dataParts);

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

//gets the element children of a dom object that can be moved, including the blank row
function dragable_getMovableChildren(obj) {
    var myArray= new Array();    
    mycnt = 0;
    for (i=0;i<obj.childNodes.length;i++) {
        if (obj.childNodes[i].nodeType==1) {
            var childId = obj.childNodes[i].id;
            childId = childId.replace(/^td/,'');
            if (available_dashlets[childId] || dragable_isBlank(obj.childNodes[i])) {
                myArray[mycnt] = obj.childNodes[i];
                mycnt++;
            }
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
    blankClone.style.top='0px';
    blankClone.style.left='0px';
    blank.className="hidden";
}


// deletes a dashlet (moves it from its current location to the bottom of position 1)
function dragable_deleteContent(e,from,postNewContentMap) {
	from = dragable_getObjectByClass(from,"dragable");
	from = document.getElementById(from.id.substr(0,from.id.indexOf("_div")));
	dragable_moveContent(from,document.getElementById('position1').rows[document.getElementById('position1').rows.length - 1],"bottom");
	 if (postNewContentMap) {dragable_postNewContentMap();} // This will help avoid meaningless web server hits.
}

//moves a table row from one table to another. from and to are table row objects
//if the last row is removed from a table, id blank is placed in the table
function dragable_moveContent(from, to,position) {
    if (from!=to && from && to) {    
        var fromParent = from.parentNode;
        fromParent.removeChild(from);

        if (dragable_getMovableChildren(fromParent).length == 0) {
            dragable_appendBlankRow(fromParent);
        }

        var toParent = to.parentNode;
        var toChildren = dragable_getMovableChildren(toParent);

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

function dashboard_toggleEditForm(event,shortcutId,editFormUrl) {
	//discover if form is there.
	var existingForm = document.getElementById("form" + shortcutId + "_div");
	if (existingForm) {
		var throwAway = existingForm.parentNode.removeChild(existingForm);
		return;
	}
	// Create the new form element.
	var formDiv = document.createElement("div");
	formDiv.id = "form" + shortcutId + "_div";
	formDiv.className = "userPrefsForm";
	var parentDiv = document.getElementById("td" + shortcutId + "_div");
	var contentDiv = document.getElementById("ct" + shortcutId + "_div");
	parentDiv.insertBefore(formDiv,contentDiv);

    var callback = {
        success : function(req) {
            var myHtml = req.responseText.split(/beginDebug/mg,1)[0];
			var myScript = myHtml.split(/\<script\>/mg)[1];
			if (myScript) {
				myScript = myScript.split(/\<\/script\>/mg)[0];
				eval(myScript);
			}
			formDiv.innerHTML = myHtml;
            var myTips;
            myTips = YAHOO.util.Dom.getElementsByClassName('wg-hoverhelp','',formDiv);
            for (var i = myTips.length; i--; ) {
                var myTip = new YAHOO.widget.Tooltip(myTips[i], {  
                    autodismissdelay: 1000000,
                    context: myTips[i].parentNode,
                    text   : myTips[i].innerHTML
                });
                myTips[i].innerHTML = "";
            }
        },
        failure : function(req) {
            alert("Toggle Edit Form failed.  Problem with connection.  Please refresh the page and try again.");
        }
    }

    editFormUrl = encodeURI(editFormUrl);
    var status = YAHOO.util.Connect.asyncRequest('GET',editFormUrl,callback);

}

//Edit Dashlet Form is for the new per-asset settings for the Dashboard that
//sets required, and movable.  It calls a method from the Dashboard and saves
//settings in a dashboard collateral table.

function dashboard_toggleEditDashletForm(event,assetId,dashboardUrl) {
	//discover if form is there.
    var divId = "form" + assetId + "_editDashlet_div";
	var existingForm = document.getElementById(divId);
	if (existingForm) {
		var throwAway = existingForm.parentNode.removeChild(existingForm);
		return;
	}
	// Create the new form element.
	var formDiv = document.createElement("div");
	formDiv.id = divId;
	formDiv.className = "userPrefsForm";
	var parentDiv = document.getElementById("td" + assetId + "_div");
	var contentDiv = document.getElementById("ct" + assetId + "_div");
	parentDiv.insertBefore(formDiv,contentDiv);

    var callback = {
        success : function(req) {
			formDiv.innerHTML = req.responseText;
            var myTips;
            myTips = YAHOO.util.Dom.getElementsByClassName('wg-hoverhelp','',formDiv);
            for (var i = myTips.length; i--; ) {
                var myTip = new YAHOO.widget.Tooltip(myTips[i], {  
                    autodismissdelay: 1000000,
                    context: myTips[i].parentNode,
                    text   : myTips[i].innerHTML
                });
                myTips[i].innerHTML = "";
            }
        },
        failure : function(req) {
            alert("Dashlet Edit Form failed.  Problem with connection.  Please refresh the page and try again.");
        }
    }

    var url    = encodeURI(dashboardUrl) + "?func=editDashlet;dashletAssetId="+assetId;
    var status = YAHOO.util.Connect.asyncRequest('GET',url,callback);

}

function dashboard_reloadDashlet(event,shortcutId,shortcutUrl) {
	// Reload the content div.
	contentDiv = document.getElementById("ct" + shortcutId + "_div");

    var callback = {
        success : function(req) {
            var myHtml = req.responseText.split(/beginDebug/mg,1)[0];
			var myScript = myHtml.split(/\<script\>/mg)[1];
			if (myScript) {
				myScript = myScript.split(/\<\/script\>/mg)[0];
				eval(myScript);
			}
			contentDiv.innerHTML = myHtml;
        },
        failure : function(req) {
            alert("Reload Dashlet failed.  Problem with connection.  Please refresh the page and try again.");
        }
    }

    var url    = encodeURI(shortcutUrl) + "?func=ajaxInlineView";
    var status = YAHOO.util.Connect.asyncRequest('GET',url,callback);
}

function makeActive(o) { o.style.display = "inline"; }

function makeInactive(o) { o.style.display = "none"; }

