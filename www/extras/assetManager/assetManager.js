/* 
	WebGUI Asset Manager Table
	based upon the sortable table by Matt Kruse
	http://www.mattkruse.com/
*/

var sort_object;
var sort_column;
var reverse=0;

// Constructor for AssetManager object
function AssetManager() {
	// Properties
	this.name = 'assetManager';
	this.sortcolumn="";
	this.dosort=true;
	this.tablecontainsforms=false;
	// Methods
	this.AddLine         = AssetManager_AddLine;
	this.AddColumn       = AssetManager_AddColumn;
	this.AddButton       = AssetManager_AddButton;
	this.Write           = AssetManager_Write;
	this.SortRows        = AssetManager_SortRows;
	this.AddLineSortData = AssetManager_AddLineSortData;
    this.AddFormHidden   = AssetManager_AddFormHidden;
	// Structure
	this.Columns    = new Array();
	this.Lines      = new Array();
	this.Buttons    = new Array();
    this.FormHidden = new Array();

	
	//***************Properties used for dragging

	this.dom=document.getElementById&&!document.all;
	this.documentElement = document.documentElement;
    
	if (document.compatMode == "BackCompat") {
	    this.documentElement = document.body;
	}
	    
	this.focusObject = null;
	this.overObject = null;
	//this.topLevelElement=this.dom? "HTML" : "BODY"
	this.topLevelElement="HTML";
	this.scrollJump = 25;
	this.dragEnabled = false;
	this.x = 0;
	this.y = 0;
	this.lastZIndex = 1000;	    
	this.draggableObjects = new Array();
	this.metaData = new Array();
	this.select = AssetManager_select;
	this.clear = AssetManager_clear;
	this.addAssetMetaData = AssetManager_addAssetMetaData;
	this.initializeDragEventHandlers = AssetManager_initializeDragEventHandlers;
	this.dragStart = AssetManager_dragStart;
	this.adjustScrollBars = AssetManager_adjustScrollBars;
	this.dragStop = AssetManager_dragStop;
	this.spy = AssetManager_spy;
	this.move = AssetManager_move;
	this.bringToFront = AssetManager_bringToFront;
        //*****************End Properties used for dragging

}

// Add a hidden input field to the form
function AssetManager_AddFormHidden( hiddenObj ) {
	var index = this.FormHidden.length;
    this.FormHidden[index] = hiddenObj;
}

// Add a line to the grid
function AssetManager_AddLine() {
	var index = this.Lines.length;
	this.Lines[index] = new Array();
	for (var i=0; i<arguments.length; i++) {
		this.Lines[index][i] = new Object();
		this.Lines[index][i].text = arguments[i];
		this.Lines[index][i].data = arguments[i];
	}
}

// Add a button to the form
function AssetManager_AddButton(label,func,proceed) {
	var index = this.Buttons.length;
	this.Buttons[index] = new Object();
	this.Buttons[index].label = label;
	this.Buttons[index].func = func;
	this.Buttons[index].proceed = proceed;
}

// Define sorting data for the last line added
function AssetManager_AddLineSortData() {
	var index = this.Lines.length-1;
	for (var i=0; i<arguments.length; i++) {
		if (arguments[i] != '') {
			this.Lines[index][i].data = arguments[i];
			}
		}
	}

// Add a column definition to the table
// Arguments:
//   name = name of the column
//   td   = any arguments to go into the <TD> tag for this column (ex: BGCOLOR="red")
//   align= Alignment of data in cells
//   type = type of data in this column (numeric, money, etc) - default alphanumeric
function AssetManager_AddColumn(name,td,align,type) {
	var index = this.Columns.length;
	this.Columns[index] = new Object;
	this.Columns[index].name = name;
	this.Columns[index].td   = td;
	this.Columns[index].align=align;
	this.Columns[index].type = type;
	if (type == "form") {
		 this.tablecontainsforms=true; 
		}
	}

	
// Print out the table
function AssetManager_Write() {
	var open_div = "";
	var close_div =	"";
	
	//added drag image
	document.write('<div id="dragImage" class="dragImage"></div>');
	
	document.write('<form method="post" action="'+getWebguiProperty('pageURL')+'" name="assetManagerForm"><input type="hidden" name="func" /><input type="hidden" name="proceed" />');
	document.write('<table class="am-table">');
	document.write('<thead><tr class="am-headers">');
	for (var i=0; i<this.Columns.length; i++) {
		var title = (this.Columns[i].type == "form") ? this.Columns[i].name : '<a class="sort" href="javascript:AssetManager_SortRows(assetManager,'+i+');">'+this.Columns[i].name+'</a>';
		document.write('<td class="am-header">'+title+'</td>');
	}
	document.write('</tr><tbody>');
	for (var i=0; i<this.Lines.length; i++) {
		document.write('<tr class="am-row">');
		
		for (var j=0; j<this.Columns.length; j++) {
			var div_name = "d"+this.name+"-"+i+"-"+j;

				if (this.Columns[j].align != '') {
					var align = ' class="am-'+this.Columns[j].align+'"';
					}
				else {
					var align = "";
					}
				open_div = "<div id=\""+div_name+"\" "+align+" style='width:100%;'>";
				close_div= "</div>";
				
				document.write("<td "+this.Columns[j].td+">"+open_div+this.Lines[i][j].text+close_div+"</td>");
				
				//added for dragging to map draggable objects and meta data objects
				if (j==1) {
					this.draggableObjects[i] = document.getElementById(div_name);
					if (this.metaData && this.metaData[i]) {
						this.draggableObjects[i].metaData = this.metaData[i];
					}
				
				}
				//end added for dragging

		}
		document.write("</tr>");
	}
	document.write('</tbody></table>');
	for (var j=0; j<this.Buttons.length; j++) {
		document.write('<input type="button" onclick="this.form.func.value=\''+this.Buttons[j].func+'\';this.form.proceed.value=\''+this.Buttons[j].proceed+'\';this.form.submit();" value="'+this.Buttons[j].label+'" />');
	}
    for (var j=0; j < this.FormHidden.length; j++) {
        var myHidden = this.FormHidden[j];
        document.write('<input type="hidden" name="'+ myHidden.name+'" value="'+ myHidden.value+'" />');
    }
	document.write('</form>');
}
	
// Sort the table and re-write the results to the existing table
function AssetManager_SortRows(table,column) {
	sort_object = table;
	if (!sort_object.dosort) { return; }
	if (sort_column == column) { reverse=1-reverse; }
	else { reverse=0; }
	sort_column = column;

	// Save all form column contents into a temporary object
	// This is a nasty hack to keep the current values of form elements intact
	if (table.tablecontainsforms) {
		var iname="1";
		var tempcolumns = new Object();
		var tempcheckboxes = new Object();
		for (var i=0; i<table.Lines.length; i++) {
			for (var j=0; j<table.Columns.length; j++) {
				if(table.Columns[j].type == "form") {
					var cell_name = "d"+table.name+"-"+i+"-"+j;
					tempcolumns[iname] = document.getElementById(cell_name).innerHTML;
					// Okay, this is an even nastier hack...
					// Other temporary arrays could be created to hold other attribute states.
					var inputboxes = document.getElementById(cell_name).getElementsByTagName('input');
					for(k = 0; k < inputboxes.length; k++) {
						tempcheckboxes[iname] = inputboxes[k].checked;
						}
					table.Lines[i][j].text = iname;
					iname++;
					}
				}
			}
		}
	
	if (table.Columns[column].type == "numeric") {
		// Sort by Float
		table.Lines.sort(	function by_name(a,b) {
									if (parseFloat(a[column].data) < parseFloat(b[column].data) ) { return -1; }
									if (parseFloat(a[column].data) > parseFloat(b[column].data) ) { return 1; }
									return 0;
									}
								);
		}
	else if (table.Columns[column].type == "money") {
		// Sort by Money
		table.Lines.sort(	function by_name(a,b) {
									if (parseFloat(a[column].data.substring(1)) < parseFloat(b[column].data.substring(1)) ) { return -1; }
									if (parseFloat(a[column].data.substring(1)) > parseFloat(b[column].data.substring(1)) ) { return 1; }
									return 0;
									}
								);
		}
	else if (table.Columns[column].type == "date") {
		// Sort by Date
		table.Lines.sort(	function by_name(a,b) {
									if (Date.parse(a[column].data) < Date.parse(b[column].data) ) { return -1; }
									if (Date.parse(a[column].data) > Date.parse(b[column].data) ) { return 1; }
									return 0;
									}
								);
		}

	else {
		// Sort by alphanumeric
		table.Lines.sort(	function by_name(a,b) {
									if (a[column].data+"" < b[column].data+"") { return -1; }
									if (a[column].data+"" > b[column].data+"") { return 1; }
									return 0;
									}
								);
		}

	if (reverse) { table.Lines.reverse(); }
	for (var i=0; i<table.Lines.length; i++) {
		for (var j=0; j<table.Columns.length; j++) {
			var cell_name = "d"+table.name+"-"+i+"-"+j;
	
				if(table.Columns[j].type == "form") {
					var iname = table.Lines[i][j].text;
					document.getElementById(cell_name).innerHTML = tempcolumns[iname];
					var inputboxes = document.getElementById(cell_name).getElementsByTagName('input');
					for(k = 0; k < inputboxes.length; k++) {
						inputboxes[k].checked = tempcheckboxes[iname];
						}
					}
				else {
					document.getElementById(cell_name).innerHTML = table.Lines[i][j].text;
					}
	
			}
		}
	}
	
	
//called to enable dragging on an element
function AssetManager_dragStart(firedobj,xCoordinate,yCoordinate) {

    if (!firedobj) return;
    	                    
    if (this.dragEnabled) return;

    found = false;
    //traverse up the dom tree until you find the asset    
    while (firedobj.tagName!=this.topLevelElement && !found) {
	    for (i = 0; i< this.draggableObjects.length; i++) {
		    if (firedobj == this.draggableObjects[i]) {
			found = true;    
	            }
            }
	    
	    
	    if (!found) {
	        firedobj=this.dom? firedobj.parentNode : firedobj.parentElement    
	    }else {
		    break;
	    }
    }
    
    if (!found) return;
    
    this.dragEnabled=true;

    this.pageHeight = this.documentElement.scrollHeight;
    this.pageWidth = this.documentElement.scrollWidth;
 
    this.focusObject=firedobj;
    this.bringToFront(document.getElementById("dragImage"));
    
    //alert(firedobj.id);
    document.getElementById("dragImage").innerHTML = "&nbsp;&nbsp;" + firedobj.metaData.title + "&nbsp;&nbsp;";
    this.x=xCoordinate;
    this.y=yCoordinate;
    
    return false;
}

//called on mouse up if dragging was enabled
function AssetManager_dragStop() {
    if (this.dragEnabled) {

        this.dragEnabled = false;
	document.getElementById("dragImage").style.display="none";           

        if (this.overObject && this.overObject != null && this.overObject != this.focusObject) {		            
   	    
		
   	    var serverParts = location.href.split("/");
	    var hostName = serverParts[2];
	    
	    var url = "http://" + hostName + this.focusObject.metaData.url;
	    if (this.focusObject.metaData.url.indexOf("?") == -1) {
		 url = url + "?";
	    }else {
		url =url + "&";
            }

	        url = url + "func=setRank&rank="+ this.overObject.metaData.rank;
		
		
		location.href=url;
        }         
    }        
}

//changes the z index of obj to be greater than all other elements
function AssetManager_bringToFront(obj) {
    this.lastZIndex++;
    obj.style.zIndex = this.lastZIndex; 
}

function AssetManager_select(obj) {
	
	this.overObject=obj;
	this.overObject.style.backgroundColor = "yellow";
	for (i = 0 ; i< this.draggableObjects.length; i++) {
		if (obj != this.draggableObjects[i]) {
		    this.draggableObjects[i].style.backgroundColor = "white";	
		}
        }
}

function AssetManager_clear() {
	
	for (i = 0 ; i< this.draggableObjects.length; i++) {
		this.draggableObjects[i].style.backgroundColor="white";	
	}
	
       this.overObject=null;
        
}

//called on mouse move.  checks to see if mouse cursor is over an asset when dragging
function AssetManager_move(e){
    if (this.dragEnabled){        		
       this.adjustScrollBars(e);

        var topScroll = this.documentElement.scrollTop;
		var leftScroll =this.documentElement.scrollLeft; 

	        var obj = this.spy(this.dom? e.pageX: (e.clientX + this.documentElement.scrollLeft),this.dom? e.pageY: (e.clientY + this.documentElement.scrollTop));
   		       		    
   		if (obj && obj != null) {
	   		this.select(obj);
		}else {
			this.clear();
		}			
					
		document.getElementById("dragImage").style.display = "block";
		document.getElementById("dragImage").style.top = this.dom? (e.clientY+ 15 + topScroll) + "px" : (event.clientY + 15 + topScroll) + "px";
		document.getElementById("dragImage").style.left = this.dom? (e.clientX + 5 + leftScroll) + "px" : (event.clientX + 5 + leftScroll) + "px";
    }
    return false
}

//check to see if the mouse cursor is over and asset.  If so, returns the asset
function AssetManager_spy(x,y) {
    var returnObj = null;
               
    for (i=0;i<this.draggableObjects.length;i++) {
        obj = this.draggableObjects[i];
                           
        //this is a hack
        if (obj == null || obj == this.focusObject) continue;
                                                                                
        var fObj=obj;
                                                                                
        y1=0;
        x1=0
                
        while (fObj!=null && fObj.tagName!=this.topLevelElement){
            y1+=fObj.offsetTop;
            x1+=fObj.offsetLeft;
            fObj=fObj.offsetParent;
        }
                                                                                    
	var fudge = 13;
        if (x >(x1 + fudge) && x < (x1 + obj.offsetWidth + fudge)) {
			//add 13 pixels for ie since border widths are included in calculation
			//var fudge = this.dom? 0:13;
			var fudge = 13;
            if (y> (y1 + fudge) && y< (y1 + obj.offsetHeight + fudge)) {                    
		    return obj;
            }
        }
    }                                                                                
    
    return returnObj;
}


//checks to see if the scroll bars need to be adjusted.  Called durring dragging
function AssetManager_adjustScrollBars(e) {
        var scrY=0;
        var scrX=0;
		
		if (!this.documentElement) return;

		var topScroll = this.documentElement.scrollTop;
		var leftScroll = this.documentElement.scrollLeft;
		var innerHeight = this.documentElement.clientHeight;
		var innerWidth = this.documentElement.clientWidth;
		
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

//adds the asset meta data to an array.  When the write method is called, the meta
//data is appended to the draggable divs as a meta data property
function AssetManager_addAssetMetaData(url, rank,title) {
    var obj = new Object();
    obj.url = url;
    obj.rank = rank;
    obj.title = title;
    //this.metaData[rank-1] = obj;
    this.metaData[this.metaData.length] = obj;
}

//********Event Handlers***********
function AssetManager_initializeDragEventHandlers() {
	document.onmousedown=AssetManager_documentMouseDown;
	document.onmouseup=AssetManager_documentMouseUp;
	document.onmousemove=AssetManager_documentMouseMove;
/*
	// Failed attempt at making it more compatible.
	var oldOnMouseDown = (document.onmousedown) ? document.onmousedown : function () {};
    	document.onmousedown= function () {oldOnMouseDown();AssetManager_documentMouseDown();};
	var oldOnMouseUp = (document.onmouseup) ? document.onmouseup : function () {};
    	document.onmouseup= function () { oldOnMouseUp();AssetManager_documentMouseUp();};
	var oldOnMouseMove= (document.onmousemove) ? document.onmousemove : function () {};
    	document.onmousemove= function () { oldOnMouseMove();AssetManager_documentMouseMove();};
*/
}

/* called on document mouse down.  Gets a reference to the asset manager and passes in event*/
function AssetManager_documentMouseDown(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;    
    obj =dom? e.target : e.srcElement
        
        
    if (e.button != 2) {
    	assetManager.dragStart(obj,e.clientX,e.clientY);
    }
    return false;
} 

/* called on document mouse up.  Gets a reference to the asset manager and passes in event*/
function AssetManager_documentMouseUp(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;    
    obj =dom? e.target : e.srcElement
    assetManager.dragStop();        
    return false;
} 


/* called on document mouse move.  Gets a reference to the asset manager and passes in event*/
function AssetManager_documentMouseMove(e) { 
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;

    assetManager.move(e);
    return false;
} 
//******End Event Handlers***********
