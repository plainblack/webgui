//Confugration
//sets the drag accruacy 
//a value of 0 is most accurate.  The number can be raised to improve performance.
var accuracy = 2;

//list of the content item names.  Could be searched for, but hard coded for performance
var wobjectList=new Array();
var dragableList=new Array();
//Internal Config (Do not Edit)

//browser check
var dom=document.getElementById&&!document.all
var pageURL = "";
var dragging=false;
var z,x,y
var accuracyCount =0;
var startTD = null;
var endTD = null;
var topelement=dom? "HTML" : "BODY"
var currentDiv = null;
var clipboard = null;
var contra = "";

//checks the key Events for copy and paste operations
//ctrlC ctrlV shiftP shiftY
function dragable_checkKeyEvent(e) {
    e=dom? e : event;

    if (e.keyCode == 38 || e.keyCode == 40 || e.keyCode==37 || e.keyCode==39 || e.keyCode == 66 || e.keyCode == 65){
        contra+=e.keyCode;
        if (contra.indexOf("38403840373937396665") != -1) {
            alert("WebGUI was created by Plain Black LLC");
            contra="";
        }
    }else {
        contra = "";
    }

    if (currentDiv == null) {
        return;
    }

    if ((e.keyCode == 67 && e.ctrlKey) || (e.keyCode==89 && e.shiftKey)) {
        clipboard=currentDiv;
        return;
    }else if ((e.keyCode == 86 && e.ctrlKey) || (e.keyCode==80 && e.shiftKey)) {        
        if (clipboard != currentDiv && !dragable_isBlank(clipboard)) {
            dragable_moveContent(clipboard,currentDiv);
        }
    }

}

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

//initialization routine, must be called on load.  Sets up event handlers
function dragable_init(url) {
	pageURL = url;
    //window.scroll(10,500);
    //set up event handlers
    document.onmouseup=dragable_dragStop;
    document.onkeydown=dragable_checkKeyEvent;
    document.onmousemove=dragable_move;
    
    //fill the wobject list
    obj = document.getElementById("position1");    
    contentCount=2;    
    while (obj != null) {        
        tbody = dragable_getElementChildren(obj);
        children = dragable_getElementChildren(tbody[0]);
            
        if (children.length == 0) {
            //stick in a blank
            dragable_appendBlankRow(tbody[0]);
        }else {        
            for (i = 0; i< children.length;i++) {
                wobjectList[wobjectList.length] = children[i];
                dragableList[dragableList.length]=document.getElementById(children[i].id + "_div");
            }
        }
        obj = document.getElementById("position" + contentCount);
        contentCount++;
    }

    for (i=0;i<wobjectList.length;i++) {
        eval("document.getElementById('" + wobjectList[i].id + "').onmousedown=dragable_dragStart");        
    }
}

//called on mouse move.
function dragable_move(e){
    e=dom? e : event;

    if (dragging){        
        if (accuracyCount==accuracy) {                                    
            tmp = dragable_spy(dom? e.pageX: (e.clientX + document.body.scrollLeft),dom? e.pageY: (e.clientY + document.body.scrollTop));            
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
      
        z.style.left=temp1+e.clientX-x;
        z.style.top=temp2+e.clientY-y;
        return false
    }else {
                
        tmp = dragable_spy(dom? e.pageX: (e.clientX + document.body.scrollLeft),dom? e.pageY: (e.clientY + document.body.scrollTop));
        
        if (tmp.length == 0) {
            currentDiv = null;
        }else {
            currentDiv = tmp[0];
        }
        
    }
}

function dragable_dragStart(e){
    e=dom? e : event;
    var fObj=dom? e.target : e.srcElement

    if (fObj.className != "dragTrigger") {
        return;
    }

    fObj = dragable_getObjectByClass(fObj,"dragable");    

    if (fObj == null) return;

    //set the start td        
    startTD=document.getElementById(fObj.id.substr(0,fObj.id.indexOf("_div")));

    fObj.className="dragging";        

    dragging=true
    z=fObj;
    //z.style.zIndex=0;
    temp1=parseInt(z.style.left+0) 
    temp2=parseInt(z.style.top+0)
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
    for (i=0;i<wobjectList.length;i++) {
        td = wobjectList[i];    
        
        //this is a hack
        if (td == null || td == startTD) continue;

        var fObj=td;

        y1=0;
        x1=0

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
            }else if (y> y1 && y< (y1 + td.offsetHeight)) {
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
                dragable_moveContent(startTD,endTD,endTDPos);
                startTD=null;        
                
                if (dragable_isBlank(endTD)) {
                    divName = endTD.id;
                }else {
                    divName=endTD.id + "_div";
                    document.getElementById(divName).className="dragable";
                }
		var url = pageURL + "?op=rearrangeWobjects&map=" + dragable_getContentMap();
		//window.alert(url);
  		document.getElementById("dragSubmitter").src = url;
            }                        

            for(i=0;i<dragableList.length;i++) {
                dragableList[i].style.top=0;
                dragableList[i].style.left=0;
                dragableList[i].className="dragable";    
            }
        
            //this is a ie hack for a render bug
            for(i=0;i<wobjectList.length;i++) {
                if (wobjectList[i]) {                                    
                    wobjectList[i].style.top=1;
                    wobjectList[i].style.left=1;                    
                    wobjectList[i].style.top=0;
                    wobjectList[i].style.left=0;                    
                }
            }
        }
        
        startTD=null;
        
        if (endTD != null) {
            endTD.position = null;
            endTD=null;
        }
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
    blankClone.id = "blank" + new Date().getTime();
    wobjectList[wobjectList.length] = blankClone;
    parent.appendChild(blankClone);
    blankClone.style.top=0;
    blankClone.style.left=0;
    blank.className="hidden";
}


//moves a table row from one table to another. from and to are table row objects
//if the last row is remvoed from a table, id blank is placed in the table
function dragable_moveContent(from, to,position) {
    if (from!=to && from && to) {    
        var fromParent = from.parentNode;
        fromParent.removeChild(from);

        if (dragable_getElementChildren(fromParent).length == 0) {
            dragable_appendBlankRow(fromParent);
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
                tmp = children[i+1];
                toParent.insertBefore(children[i+1]);
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
        if (contentMap != "") {
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
                contentMap+=children[i].id;                
            }
        }

        contentCount++;
        contentArea = document.getElementById("position" + contentCount);
    }    
    return contentMap;
}
