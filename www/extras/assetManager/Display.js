
//--------Constructor--------------------

//creates a new Display object.  The display object manages selected assets, the drag functionality, and highlighting.

function Display() {
    this.dom=document.getElementById&&!document.all;
    this.focusObjects = new Array();
    this.overObjects = new Array();
    this.topLevelElement=this.dom? "HTML" : "BODY"
    this.scrollJump = 25;
    this.dragEnabled = false;
    this.dragStart = Display_dragStart;
    this.adjustScrollBars = Display_adjustScrollBars;
    this.dragStop = Display_dragStop;
    this.spy = Display_spy;
    this.move = Display_move;
    this.x = 0;
    this.y = 0;
    this.shiftKeyDown=false;
    this.controlKeyDown=false;
    this.contextMenu=new ContextMenu();
    this.bringToFront = Display_bringToFront;
    this.lastZIndex = 1000;
    this.keyDown = Display_keyDown;
    this.keyUp = Display_keyUp;
    this.selectAsset = Display_selectAsset;
    this.isSelected = Display_isSelected;
    this.clearSelectedAssets = Display_clearSelectedAssets;
}

//---------Method Implementations -------------

//changes the z index of obj to be greater than all other elements
function Display_bringToFront(obj) {
    this.lastZIndex++;
    obj.style.zIndex = this.lastZIndex; 
}

//called to enable dragging on an element
function Display_dragStart(firedobj,xCoordinate,yCoordinate) {

    if (!firedobj) return;
    
    if (this.shiftKeyDown || this.controlKeyDown) return;
    	                    
    //traverse up the dom tree until you find the asset    
    while (firedobj.tagName!=this.topLevelElement && !firedobj.asset) {
        firedobj=manager.display.dom? firedobj.parentNode : firedobj.parentElement    
    }
    
    if ((!firedobj.asset || firedobj.asset.isParent)) {
        return;
    }

    this.dragEnabled=true;

    this.pageHeight = document.documentElement.scrollHeight;
    this.pageWidth = document.documentElement.scrollWidth;

    this.focusObjects[0]=firedobj.asset;
                
	this.bringToFront(document.getElementById("dragImage"));
	document.getElementById("dragImage").innerHTML = "&nbsp;&nbsp;" + firedobj.asset.title + "&nbsp;&nbsp;";
    this.x=xCoordinate;
    this.y=yCoordinate;
    return false;
}

//called on mouse up if dragging was enabled
function Display_dragStop() {
    if (this.dragEnabled) {

        this.dragEnabled = false;
		document.getElementById("dragImage").style.display="none";           

        if (this.overObjects[0] && this.overObjects[0].assetId && this.overObjects[0] != this.focusObjects[0]) {		            
	        if (this.overObjects[0].isParent) {
		        this.focusObjects[0].setParent(this.overObjects[0]);			            
    		}else {
    			this.focusObjects[0].setRank(this.overObjects[0].rank);    				
    		}    				    				
        }        
    }        
}
//checks to see if an asset is already in the overObjects array
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

//adds an asset to the overobjects array
function Display_selectAsset(asset) {	
    	if (!this.controlKeyDown && !this.shiftKeyDown) {
    		for (i=0;i<this.overObjects.length;i++) {
    			
    			if (asset.isParent) {
					this.overObjects[i].div.className="am-crumbtrail";
				}else {
	    			this.overObjects[i].div.className="am-grid-row";				
				}
    		}
   			this.overObjects=new Array();
    	}
    	
	
		if (!this.isSelected(asset)) {	
			this.overObjects[this.overObjects.length] = asset;    	
    			if (asset.isParent) {
		   	    	asset.div.className="am-crumbtrail-over";
				}else {
		   	    	asset.div.className="am-grid-row-over";
				}						
		}
}
//Clears out the over objects array
function Display_clearSelectedAssets() {	
    		for (i=0;i<this.overObjects.length;i++) {
    			if (this.overObjects[i].isParent) {
	    			this.overObjects[i].div.className="am-crumbtrail";
				}else {
    				this.overObjects[i].div.className="am-grid-row";
				}


    		}
   			this.overObjects=new Array();
}
//called on mouse move.  checks to see if mouse cursor is over an asset when dragging
function Display_move(e){
    
    if (this.dragEnabled){        		
        this.adjustScrollBars(e);

		var topScroll = document.documentElement.scrollTop;
		var leftScroll =document.documentElement.scrollLeft; 

	    var act = this.spy(this.dom? e.pageX: (e.clientX + document.documentElement.scrollLeft),this.dom? e.pageY: (e.clientY + document.documentElement.scrollTop));
   		       		    
   		if (act && act.asset) {
	   		this.selectAsset(act.asset);
		}else {
			this.clearSelectedAssets();
		}			
					
		//change the position of the drag icon box
		document.getElementById("dragImage").style.display = "block";
		document.getElementById("dragImage").style.top = this.dom? (e.clientY+ 15 + topScroll) + "px" : (event.clientY + 15 + topScroll) + "px";
		document.getElementById("dragImage").style.left = this.dom? (e.clientX + 5 + leftScroll) + "px" : (event.clientX + 5 + leftScroll) + "px";
    }
    return false
}

//check to see if the mouse cursor is over and asset.  If so, returns the asset
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
			//add 13 pixels for ie since border widths are included in calculation
			var fudge = this.dom? 0:13;
            if (y> y1 && y< (y1 + obj.offsetHeight + fudge)) {                    
	            return obj;
            }
        }
    }                                                                                
    return returnObj;
}

//called on keyDown.  Does the right thing (ex.  delete, cut, copy, ect)
function Display_keyDown(e) {
    if (e.keyCode==16) {
    	this.shiftKeyDown = true;
    }else if (e.keyCode ==17) {
    	this.controlKeyDown = true;
    }else if (e.keyCode == 46 ) {
        manager.remove();
    }
}

//called on keyUp.  Does the right thing (ex.  delete, cut, copy, ect)
function Display_keyUp(e) {
    if (e.keyCode==16) {
    	this.shiftKeyDown = false;
    }else if (e.keyCode ==17) {
    	this.controlKeyDown = false;
    }
}

//checks to see if the scroll bars need to be adjusted.  Called durring dragging
function Display_adjustScrollBars(e) {
        var scrY=0;
        var scrX=0;

		var topScroll = document.documentElement.scrollTop;
		var leftScroll = document.documentElement.scrollLeft;
		var innerHeight = document.documentElement.clientHeight;
		var innerWidth = document.documentElement.clientWidth;
		
        if (e.clientY > innerHeight-this.scrollJump) {
            if (e.clientY + topScroll < this.pageHeight - (this.scrollJump + 40)) {
                scrY=this.scrollJump;
                window.scroll(leftScroll,topScroll + scrY);
                this.y-=scrY;
            }
        }else if (e.clientY < this.scrollJump) {
            if (topScroll < this.scrollJump) {
                scrY = topScroll;
            }else {
                scrY=this.scrollJump;
            }
            window.scroll(leftScroll,topScroll - scrY);
            this.y+=scrY;
        }


        if (e.clientX > innerWidth-this.scrollJump) {
            if (e.clientX + leftScroll < this.pageWidth - (this.scrollJump + 40)) {
                scrX=this.scrollJump;
                window.scroll(leftScroll + scrX,topScroll);
                this.x-=scrX;
            }
        }else if (e.clientX < this.scrollJump) {
            if (leftScroll < this.scrollJump) {
                scrX = leftScroll;
            }else {
                scrX=this.scrollJump;
            }
            window.scroll(leftScroll - scrX,topScroll);
            this.x+=scrX;
        }
}


