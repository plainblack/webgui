//--------Constructor--------------------

function AssetManager(assetArrayData,headerArrayData,lables,crumbtrail) {	
	this.tools = new Tools();
	this.contextMenu = new ContextMenu();
	this.display = new Display();
	this.eventManager = new EventManager();


	this.keys = new Array();
	this.keys[0] = "rank"; 
	this.keys[1] = "title";
	this.keys[2] = "type";
	this.keys[3] = "lastUpdate";
	this.keys[4] = "size";

	this.parentURL = "";
			
	this.lables = lables;
	this.crumbtrail = crumbtrail;		
	this.parentURL = "d";		
	this.renderAssets = AssetManager_renderAssets;
	this.assetArrayData = assetArrayData;
	this.columnHeadings = headerArrayData;
	this.assets = new Array();
	this.getAsset= AssetManager_getAsset;
	this.buildCrumbTrail = AssetManager_buildCrumbTrail;
	this.displayContextMenu = AssetManager_displayContextMenu;
	this.editTree=AssetManager_editTree;
	this.setParent=AssetManager_setParent;
	this.setRank=AssetManager_setRank;
	this.remove = AssetManager_remove;
	this.cut = AssetManager_cut;
	this.copy = AssetManager_copy;
	this.sortGrid = AssetManager_sortGrid;
	this.getSelectedAssetIds = AssetManager_getSelectedAssetIds;
}

function AssetManager_getManager() {
	//debug(manager.assetArrayData);
	return manager;	
}

function AssetManager_renderAssets() {


	var gridStr = '<table border="1" id="am_grid" class="am-grid"><tbody id="am_grid_body"><tr id="am_grid.headers" class="am-grid-header">';
	var eventStr='';
	var id = "";
		
	for (i=0;i<this.columnHeadings.length;i++) {
		id = 'am_grid.headers.' + i;		
		gridStr+= '<td id="' + id + '" class="am-grid-header-' + i + '">' + this.columnHeadings[i] + '</td>';	
		eventStr += 'document.getElementById("' + id + '").onclick=AssetManager_getManager().eventManager.gridHeaderClick;';			
	}

	gridStr+= '</tr>';
//['Rank','Title','Type','Last Updated','Size'];
	for (i=0;i<this.assetArrayData.length;i++) {
		id = 'am_grid.row.'+ i;
		gridStr += '<tr id="'+ id + '" class="am-grid-row">';
		
		/* rank, title, type, lastUpdate, size, url, assetId */						
		asset = new Asset();
		
		asset.rank = this.assetArrayData[i][0];
		asset.title = this.assetArrayData[i][1];
		asset.type = this.assetArrayData[i][2];
		asset.lastUpdate = this.assetArrayData[i][3];
		asset.size = this.assetArrayData[i][4];
		asset.url = this.assetArrayData[i][5];
		asset.assetId = this.assetArrayData[i][6];
		asset.icon = this.assetArrayData[i][7];
		this.assets[i]=asset;
						
		//add the row events
//		eventStr += 'document.getElementById("' + id + '").onclick=Grid_rowClicked;';	
//		eventStr += 'document.getElementById("' + id + '").onmouseover=Grid_rowMouseOver;';	
//		eventStr += 'document.getElementById("' + id + '").onmouseout=Grid_rowMouseOut;';	
		eventStr += 'document.getElementById("' + id + '").ondblclick=AssetManager_getManager().eventManager.assetDoubleClick;';	
		eventStr += 'document.getElementById("' + id + '").onmousedown=AssetManager_getManager().eventManager.assetMouseDown;';	
		eventStr += 'document.getElementById("' + id + '").oncontextmenu=AssetManager_getManager().eventManager.assetRightClick;';	
		eventStr += 'document.getElementById("' + id + '").asset = AssetManager_getManager().assets[' + i + '];';
		eventStr += 'AssetManager_getManager().assets[' + i + '].div = document.getElementById("' + id + '");';
			
						
		for (k=0;k<this.columnHeadings.length;k++) {
			id = 'am_grid.row' + '.' + i + '.col.' + k;
			gridStr+= '<td id="' + id  + '" class="am-grid-col-' + k +'">' + this.assetArrayData[i][k] + '</td>';	
//			eventStr += 'document.getElementById("' + id + '").asset = AssetManager_getManager().assets[' + i + '];';
		}
	}
		gridStr+='</tr>';

	gridStr += '</tbody></table>';
	
	document.getElementById("workspace").innerHTML=gridStr;
	eval(eventStr);
	
	this.buildCrumbTrail();
	
	
	}

function AssetManager_buildCrumbTrail() {
	var crumbtrail = document.getElementById("crumbtrail");
	var contents = "<table><tr>";
	
	for (i=0;i<this.crumbtrail.length;i++) {
		contents += '<td id="' + this.crumbtrail[i][0] + '" class="crumbtrail">' + this.crumbtrail[i][1] + '</td>';		
		if (i != this.crumbtrail.length -1) {
			contents += "<td>&nbsp;->&nbsp;</td>";
		}	
	}
	
	this.parentURL = "http://" + this.tools.getHostName("http://www.yahoo.com") + this.crumbtrail[this.crumbtrail.length -1][1];
	
	contents += '</tr></table>';	
	
	crumbtrail.innerHTML = contents;
			
//	for (i=0;i<this.crumbtrail.length;i++) {
		
//		var obj = document.getElementById(this.crumbtrail[i][0]);
//		this.crumbtrail
		
//		contents += '<td id="' + this.crumbtrail[i][0] + '" class="crumbtrail">' + this.crumbtrail[i][1] + '</td>';		
//		if (i != this.crumbtrail.lenght) {
//			contents += "<td>&nbsp;->&nbsp;</td>";
//		}
	
	//}
}
		
function AssetManager_getAsset(obj) {   	
   
    while (obj.tagName!=this.display.topLevelElement && obj.className != "am-grid-row") {
        obj=this.display.dom? obj.parentNode : obj.parentElement    
    }
   
	return obj.asset;   
}

function AssetManager_displayContextMenu(x,y) {

    var arr = new Array();
    
    if (this.display.overObjects.length == 1) {
	    arr[arr.length] = new ContextMenuItem("View","javascript:manager.display.contextMenu.owner.view()");
    	arr[arr.length] = new ContextMenuItem("Edit","javascript:manager.display.contextMenu.owner.edit()");
    }
    
    arr[arr.length] = new ContextMenuItem("Delete","javascript:manager.remove()");        
    arr[arr.length] = new ContextMenuItem("<img src='/Extras/assetManager/breakerLine.gif'>","");
    arr[arr.length] = new ContextMenuItem("Cut","javascript:AssetManager_getManager().cut()");        
    arr[arr.length] = new ContextMenuItem("Copy","javascript:manager.copy()");
    
    if (this.display.overObjects.length ==1) {
	    arr[arr.length] = new ContextMenuItem("<img src='/Extras/assetManager/breakerLine.gif'>","");
	    arr[arr.length] = new ContextMenuItem("Edit Tree","javascript:manager.editTree()");        
	    arr[arr.length] = new ContextMenuItem("Properties","javascript:manager.display.contextMenu.owner.displayProperties()");
	}    
//    alert("x = " + x + " y= " + y);
    
    manager.contextMenu.render(arr,x,y,this);    
}


//url + ?||& + func=editTree 				
function AssetManager_editTree() {	
	location.href = this.tools.addParamDelimiter(this.parentURL) + "func=editTree";		
}

//Moving to a new parent (move)
//----------------------
//url + ?||& + func=setParent&assetId= + assetId 		
function AssetManager_setParent(parentId) {
	location.href = this.tools.addParamDelimiter(this.parentURL) + "func=setParent&assetId="+ parentId;		
}

//Set the rank of an asset amongst its siblings (move)
//---------------------------------------------
//url + ?||& + func=setRank&rank= + newRank
function AssetManager_setRank(rank) {
	location.href = this.tools.addParamDelimiter(this.parentURL) + "func=setRank&rank="+ rank;		
}


//Copy an asset to the clipboard (copy)
//------------------------------
//url + ?||& + func=copy
function AssetManager_copy() {
	location.href = this.tools.addParamDelimiter(this.parentURL) + "func=copyList"  + this.getSelectedAssetIds();		
}

//Cut an asset to the clipboard (cut)
//-----------------------------
//url + ?||& + func=cut
function AssetManager_cut() {
	location.href = this.tools.addParamDelimiter(this.parentURL) + "func=cutList"  + this.getSelectedAssetIds();	
}

//Delete an asset. (delete)
//----------------
//url + ?||& + func=delete (do a javascript confirm on this)
function AssetManager_remove() {	
	if (window.confirm("Are you sure you want to delete this asset?  Click OK to continue, or Cancel if you made a mistake.")) {								
		location.href = this.tools.addParamDelimiter(this.parentURL) + "func=deleteList"  + this.getSelectedAssetIds();		
	}
}

function AssetManager_getSelectedAssetIds() {
	var assetIds = "";
	for (i=0;i<this.display.overObjects.length;i++) {
		assetIds += "&assetId=" + this.display.overObjects[i].assetId;
	}
	return assetIds;
}

function AssetManager_sortGrid(columnIndex) {

	var prop = this.keys[columnIndex];	

	var tableBody = document.getElementById("am_grid_body");

	//remove the arrows from the other column headers
	for (i=0;i< this.columnHeadings.length;i++) {
		if (i != columnIndex) {
			document.getElementById('am_grid.headers.' + i).innerHTML = this.columnHeadings[i];		
			document.getElementById('am_grid.headers.' + i).sortOrder = "<";
		}
	}		
	
	colHeader = document.getElementById('am_grid.headers.' + columnIndex);
	
	if (!colHeader.sortOrder) {
		colHeader.sortOrder = "<";	
	}
	
	if (colHeader.sortOrder==">") {
		colHeader.sortOrder="<";
		document.getElementById('am_grid.headers.' + columnIndex).innerHTML = this.columnHeadings[columnIndex] + " (up)";		
			
	}else {
		colHeader.sortOrder=">";
		document.getElementById('am_grid.headers.' + columnIndex).innerHTML = this.columnHeadings[columnIndex] + "(down)";				
	}	
	
	
	var rowArray = new Array();
	
	for (i=0; i<tableBody.childNodes.length; i++) {		
		if (tableBody.childNodes[i].id.indexOf("header") == -1) {
			rowArray[rowArray.length] = tableBody.childNodes[i];			
		}		
	}
	
	for (j=0;j<rowArray.length;j++) {
		for (k=0;k<rowArray.length - 1;k++) {
			var swap = eval("rowArray[k].asset." + prop + " " + colHeader.sortOrder + " " + "rowArray[k+1].asset." + prop);
			if (swap) {
				tmp = rowArray[k];
				rowArray[k] = rowArray[k+1];
				rowArray[k+1] = tmp;

			}	
		}	
	}

	for (i=0;i<rowArray.length;i++) {
		tableBody.removeChild(rowArray[i]);
	}

	for (i=0;i<rowArray.length;i++) {
		tableBody.appendChild(rowArray[i]);	
	}		
}
	