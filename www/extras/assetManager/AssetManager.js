//--------Constructor--------------------

function AssetManager(assetArrayData,headerArrayData,labels,crumbtrail) {	
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
			
	this.labels = labels;
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


	var gridStr = '<table border="0" cellspacing="0" id="am_grid" class="am-grid"><tbody id="am_grid_body"><tr id="am_grid.headers" class="am-grid-headers">';
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
			gridStr+= '<td id="' + id  + '" class="am-grid-col-' + k +'">';
			
			if (k == 1) {
				gridStr +='<img src="' + asset.icon + '" border="0"/>';				
			}
			gridStr+=this.assetArrayData[i][k] + '</td>';	
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
	var contents = '<table><tr>';
	
	var parentAssets = new Array();
	
	for (i=0;i<this.crumbtrail.length;i++) {
		contents += '<td id="' + this.crumbtrail[i][0] + '" class="am-crumbtrail">' + this.crumbtrail[i][2] + '</td>';		
		if (i != this.crumbtrail.length -1) {
			contents += "<td>&nbsp;/&nbsp;</td>";
		}	
	}
	
	this.parentURL = "http://" + this.tools.getHostName(location.href) + this.crumbtrail[this.crumbtrail.length -1][1];
	
	contents += '</tr></table>';	
	
	crumbtrail.innerHTML = contents;
			
	//build assets attach the div properties
	for (i=0; i< this.crumbtrail.length; i++ ) {
		var asset = new Asset();		
		asset.title = this.crumbtrail[i][2];
		asset.url = this.crumbtrail[i][1];
		asset.assetId = this.crumbtrail[i][0];


		asset.div = document.getElementById(this.crumbtrail[i][0]);

		asset.div.ondblclick=AssetManager_getManager().eventManager.assetDoubleClick;	
		asset.div.onmousedown=AssetManager_getManager().eventManager.assetMouseDown;	
		asset.div.oncontextmenu=AssetManager_getManager().eventManager.assetRightClick;	

		asset.isParent = true;
		document.getElementById(this.crumbtrail[i][0]).asset = asset;
		this.assets[this.assets.length] = asset;
		
	}		
			
}
		
function AssetManager_getAsset(obj) {   	
   
    while (obj.tagName!=this.display.topLevelElement && !obj.asset) {
        obj=this.display.dom? obj.parentNode : obj.parentElement    
    }
   
	return obj.asset;   
}

function AssetManager_displayContextMenu(x,y,asset) {

    var arr = new Array();
    
    if (this.display.overObjects.length == 1) {
    	arr[arr.length] = new ContextMenuItem(this.labels["go"],"javascript:manager.display.contextMenu.owner.go()");
   	 	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
	    arr[arr.length] = new ContextMenuItem(this.labels["view"],"javascript:manager.display.contextMenu.owner.view()");
    	arr[arr.length] = new ContextMenuItem(this.labels["edit"],"javascript:manager.display.contextMenu.owner.edit()");
    }
    
	if (!asset.isParent) {
		arr[arr.length] = new ContextMenuItem(this.labels["delete"],"javascript:manager.remove()");        
   	 	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
    	arr[arr.length] = new ContextMenuItem(this.labels["cut"],"javascript:AssetManager_getManager().cut()");        
    	arr[arr.length] = new ContextMenuItem(this.labels["copy"],"javascript:manager.copy()");
    
    	if (this.display.overObjects.length ==1) {
	    	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
	    	arr[arr.length] = new ContextMenuItem(this.labels["editTree"],"javascript:manager.editTree()");        
		}    
    }
    
    manager.contextMenu.render(arr,x,y,asset);    
}


//url + ?||& + func=editTree 				
function AssetManager_editTree() {	
	//parentURL
	location.href = this.tools.addParamDelimiter(this.parentURL) + "func=editTree";		
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
		document.getElementById('am_grid.headers.' + columnIndex).innerHTML = this.columnHeadings[columnIndex] + ' <img src="/extras/assetManager/up.gif" />';		
			
	}else {
		colHeader.sortOrder=">";
		document.getElementById('am_grid.headers.' + columnIndex).innerHTML = this.columnHeadings[columnIndex] + ' <img src="/extras/assetManager/down.gif" />';				
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
	