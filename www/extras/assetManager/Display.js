
//--------Constructor--------------------

function Display() {
    this.dom=document.getElementById&&!document.all;
    this.baseX=0;
    this.baseY=0;
    this.width=0;
    this.height=0;
    this.rootNode="";
    this.packageNS = "";
    this.focusObjects = new Array();
    this.overObjects = new Array();
    this.overCrumbtrail = null;
    this.topLevelElement=this.dom? "HTML" : "BODY"
    this.scrollJump = 25;
    this.dragEnabled = false;
    this.displayPropertiesWindow = Display_displayPropertiesWindow;
    this.hidePropertiesWindow = Display_hidePropertiesWindow;
    this.dragStart = Display_dragStart;
    this.adjustScrollBars = Display_adjustScrollBars;
    this.dragStop = Display_dragStop;
    this.activityLists = new Array();
    this.spy = Display_spy;
    this.currentTemp=null;
    this.temp1 = 0;
    this.temp2=0;
    this.move = Display_move;
    this.x = 0;
    this.y = 0;
    this.shiftKeyDown=false;
    this.controlKeyDown=false;
    this.contextMenu=new ContextMenu();
    this.bringToFront = Display_bringToFront;
    this.lastZIndex = 1000;
    this.dragableObjectClasses = new Array();
    this.registerDragableClass = Display_registerDragableClass;
    this.keyDown = Display_keyDown;
    this.keyUp = Display_keyUp;
    this.selectAsset = Display_selectAsset;
    this.isSelected = Display_isSelected;
    this.clearSelectedAssets = Display_clearSelectedAssets;
}

//---------Method Implementations -------------

function Display_registerDragableClass(objectClassName,classNameDuringDrag) {
    var obj = new Object();
    obj.clazzName = objectClassName;
    obj.clazzNameDuringDrag = classNameDuringDrag;
    this.dragableObjectClasses[this.dragableObjectClasses.length] = obj;    
}

function Display_bringToFront(obj) {
    this.lastZIndex++;
    obj.style.zIndex = this.lastZIndex; 
}

function Display_hidePropertiesWindow() {
    manager.tools.hideObject(document.getElementById("propertiesWindow"));
}

function Display_displayPropertiesWindow(html) {    
    temp = "<table border='1' cellspacing='0'><tr><td><table border='0'><tr bgcolor='#000000'><td width='325' class='dragable'><font color='#FFFFFF'>" + manager.labels['properties'] + "</font></td><td align='right'><a href='javascript:manager.display.hidePropertiesWindow()'>X</a></td></tr><tr><td colspan='2'>" + html + "</td></tr></table></td></tr></table>";    
    
    propWindow = document.getElementById("propertiesWindow");        
    propWindow.innerHTML=temp;
    propWindow.style.top=50 + document.body.scrollTop;
    propWindow.style.left=50 + document.body.scrollLeft;
    manager.tools.showObject(propWindow);  
    this.bringToFront(propWindow);
}


function Display_dragStart(firedobj,xCoordinate,yCoordinate) {
    if (!firedobj) return;
    
    if (this.shiftKeyDown) return;
    
	
        
    while (firedobj.tagName!=this.topLevelElement && !firedobj.asset && firedobj.className != "dragable") {
        firedobj=manager.display.dom? firedobj.parentNode : firedobj.parentElement    
    }

    
    if ((!firedobj.asset || firedobj.asset.isParent) && firedobj.className != "dragable") {
        return;
    }

    this.dragEnabled=true;

//    while (firedobj.tagName!=this.topLevelElement) {
 //       for (i =0;i<this.dragableObjectClasses.length;i++) {
 //           if (firedobj.className==this.dragableObjectClasses[i].clazzName) {
     			                
								
                this.pageHeight = window.document.body.scrollHeight;
                this.pageWidth = window.document.body.scrollWidth;

                if (firedobj.asset) {
	                this.focusObjects[0]=firedobj.asset;
	            }else {
	            	this.focusObjects[0] = firedobj;
	            }
                
                //this.bringToFront(this.focusObject);
                
                //hack to get the transparency - need to make generic
//                this.focusObject.dragDescriptor = this.dragableObjectClasses[i];
 //               this.focusObject.className=this.dragableObjectClasses[i].clazzNameDuringDrag;

				if (firedobj.asset) {
					this.bringToFront(document.getElementById("dragImage"));
					document.getElementById("dragImage").innerHTML = "&nbsp;&nbsp;" + firedobj.asset.title + "&nbsp;&nbsp;";
				}else {
					this.temp1=parseInt(this.focusObjects[0].style.left+0)
                	this.temp2=parseInt(this.focusObjects[0].style.top+0)
                }
                this.x=xCoordinate;
                this.y=yCoordinate;
                return false;
     //       }

   //      }
 //        firedobj=display.dom? firedobj.parentNode : firedobj.parentElement    
   // }
    //return false;
}

function Display_dragStop() {
    if (this.dragEnabled) {

        this.dragEnabled = false;
		document.getElementById("dragImage").style.display="none";           

        //if (this.focusObjects.dragDescriptor.clazzName == "activityMenuItem") {
            if (this.overObjects[0] && this.overObjects[0].assetId && this.overObjects[0] != this.focusObjects[0]) {
		            
		            if (this.overObjects[0].isParent) {
			            this.focusObjects[0].setParent(this.overObjects[0]);			            
    				}else {
    					this.focusObjects[0].setRank(this.overObjects[0].rank);    				
    				}    				    				
            }        
            //this.focusObject.style.top=0;
            //this.focusObject.style.left=0;
        }
        
        //this.focusObject.className = this.focusObject.dragDescriptor.clazzName;

    //}
}


function Display_isSelected(asset) {
		//check to see if obj is already in array
		var inArray=false;
		for (i=0;i<this.overObjects.length;i++) {
			if (this.overObjects[i] == asset) {
				return true;
			}
		}
		return false;
}

function Display_selectAsset(asset) {	
//    	debug(this.overObjects.length);
    	if (!this.controlKeyDown && !this.shiftKeyDown) {
    		for (i=0;i<this.overObjects.length;i++) {
    			this.overObjects[i].div.className="am-grid-row";
    		}
   			this.overObjects=new Array();
    	}
    	

		if (!this.isSelected(asset)) {	
			this.overObjects[this.overObjects.length] = asset;    	
   	    	asset.div.className="am-grid-row-over";
		}
}

function Display_clearSelectedAssets() {	
    		for (i=0;i<this.overObjects.length;i++) {
    			this.overObjects[i].div.style.backgroundColor="white";
    		}
   			this.overObjects=new Array();
}


function Display_move(e){
    
    if (this.dragEnabled){        

        this.adjustScrollBars(e);

        if (this.focusObjects[0].className=="dragable") {	        	        
	        this.focusObjects[0].style.left=this.dom? this.temp1+e.clientX-this.x: this.temp1+event.clientX-this.x    	    
    	    this.focusObjects[0].style.top=this.dom? this.temp2+e.clientY-this.y : this.temp2+event.clientY-this.y       
        }else {
	        var act = this.spy(this.dom? e.pageX: (e.clientX + document.body.scrollLeft),this.dom? e.pageY: (e.clientY + document.body.scrollTop));
   		       		    
   		    if (act && act.asset) {
	   		    this.selectAsset(act.asset);
			}else {
				this.clearSelectedAssets();
			}			
					
			if (this.overObjects[0] != this.focusObjects[0]) {
			    //var act = this.spy(this.dom? e.pageX: (e.clientX + document.body.scrollLeft),this.dom? e.pageY: (e.clientY + document.body.scrollTop));
			    var act = this.spy(this.dom? e.pageX: (e.clientX + window.scrollX),this.dom? e.pageY: (e.clientY + window.scrollY));
				document.getElementById("dragImage").style.display = "block";
//				document.getElementById("dragImage").style.top = this.dom? (e.clientY+ 15 + document.body.scrollTop) + "px" : (event.clientY + 15) + "px";
				document.getElementById("dragImage").style.top = this.dom? (e.clientY+ 15 + window.scrollY) + "px" : (event.clientY + 15) + "px";

//				debug(document.body.scrollTop);
				//debug(window.scrollY);
				//document.getElementById("dragImage").style.left = this.dom? (e.clientX + 5 + document.body.scrollTop) + "px" : (event.clientX + 5) + "px";
				document.getElementById("dragImage").style.left = this.dom? (e.clientX + 5 + window.scrollX) + "px" : (event.clientX + 5) + "px";
	        	
	        }          
        }        

        return false
    }
}

function Display_spy(x,y) {
    var returnObj = null;
               
    for (i=0;i<manager.assets.length;i++) {
        obj = manager.assets[i].div;
                       
        //this is a hack
        if (obj == null || obj == this.focusObjects[0]) continue;
                                                                                
        var fObj=obj;
                                                                                
        y1=0;
        x1=0
                
        while (fObj!=null && fObj.tagName!=this.topLevelElement){
            y1+=fObj.offsetTop;
            x1+=fObj.offsetLeft;
            fObj=fObj.offsetParent;
        }
        
                                                                                
        if (x >x1 && x < (x1 + obj.offsetWidth)) {
            if (y> y1 && y< (y1 + obj.offsetHeight)) {                    
                    //for (j=0;j<obj.bpm.children.length;j++) {
                    //     if (y>(y1 + obj.bpm.children[j].offsetTop) && y < (y1 + obj.bpm.children[j].offsetTop + obj.bpm.children[j].offsetHeight)) {                            
                            return obj;
                    //     }
                    //}
            }
        }
    }
                                                                                
    return returnObj;
}

function Display_keyDown(e) {
    if (e.keyCode==16) {
    	this.shiftKeyDown = true;
    }else if (e.keyCode ==17) {
    	this.controlKeyDown = true;
    }else if (e.keyCode == 46 ) {
        manager.remove();
    }
}

function Display_keyUp(e) {
    if (e.keyCode==16) {
    	this.shiftKeyDown = false;
    }else if (e.keyCode ==17) {
    	this.controlKeyDown = false;
    }
}


//checks to see if the scroll bars need to be adjusted
function Display_adjustScrollBars(e) {
        var scrY=0;
        var scrX=0;

        if (e.clientY > document.body.clientHeight-this.scrollJump) {
            if (e.clientY + document.body.scrollTop < this.pageHeight - (this.scrollJump + 40)) {
                scrY=this.scrollJump;
                window.scroll(document.body.scrollLeft,document.body.scrollTop + scrY);
                this.y-=scrY;
            }
        }else if (e.clientY < this.scrollJump) {
            if (document.body.scrollTop < this.scrollJump) {
                scrY = document.body.scrollTop;
            }else {
                scrY=this.scrollJump;
            }
            window.scroll(document.body.scrollLeft,document.body.scrollTop - scrY);
            this.y+=scrY;
        }


        if (e.clientX > document.body.clientWidth-this.scrollJump) {
            if (e.clientX + document.body.scrollLeft < this.pageWidth - (this.scrollJump + 40)) {
                scrX=this.scrollJump;
                window.scroll(document.body.scrollLeft + scrX,document.body.scrollTop);
                this.x-=scrX;
            }
        }else if (e.clientX < this.scrollJump) {
            if (document.body.scrollLeft < this.scrollJump) {
                scrX = document.body.scrollLeft;
            }else {
                scrX=this.scrollJump;
            }
            window.scroll(document.body.scrollLeft - scrX,document.body.scrollTop);
            this.x+=scrX;
        }
}


