//--------Constructor--------------------

//Manages an array of assets.

//*****************Configuring the asset manager.*****************

//to create a new asset manager
//var manager = new AssetManager(assets,columnHeadings,labels,crumbtrail); 
//manager.renderAssets();

//available properties.  Properties should be set prior to the render asset call.

//*********************************************************
//assetType - defaults to "Asset"

//The following example starts the asset manager with a different asset type.

//var manager = new AssetManager(assets,columnHeadings,labels,crumbtrail); 
//manager.assetType="MyNewAsset"
//manager.renderAssets();

//*********************************************************
//sortEnabled = true - enables or disables sorting of the grid.  Defaults to true

//The following example starts the asset manager with sorting disabled.

//var manager = new AssetManager(assets,columnHeadings,labels,crumbtrail); 
//manager.sortEnabled=false;
//manager.renderAssets();

//*********************************************************
//displayCrumbTrail = Enables or disables display of the crumbtrail. Defaults to true

//The following example starts the asset manager with the crumb trail disabled

//var manager = new AssetManager(assets,columnHeadings,labels,crumbtrail); 
//manager.displayCrumbTrail=false;
//manager.renderAssets();
      
//**********************************************************
//To disable display item in the grid,  the disableDisplay function can be called on the asset manager.  The function takes the index of the item to disable from the columnHeadings array.

//The following example disables the rank and title

//var manager = new AssetManager(assets,columnHeadings,labels,crumbtrail); 
//manager.disableDisplay(0);
//manager.disableDisplay(1);
//manager.renderAssets();

//Constructor
function AssetManager(assetArrayData,headerArrayData,labels,crumbtrail) {	

	//create all the objects used by the manager
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

	this.assetType = "Asset";
	this.sortEnabled = true;
	this.displayCrumbTrail = true;		
				
	this.labels = labels;
	this.crumbtrail = crumbtrail;		
	this.renderAssets = AssetManager_renderAssets;
	this.assetArrayData = assetArrayData;
	this.columnHeadings = headerArrayData;
	this.assets = new Array();
	this.getAsset= AssetManager_getAsset;
	this.buildCrumbTrail = AssetManager_buildCrumbTrail;
	this.displayContextMenu = AssetManager_displayContextMenu;
	this.sortGrid = AssetManager_sortGrid;
	this.getSelectedAssetIds = AssetManager_getSelectedAssetIds;
	this.disabledDisplayItems = new Array();

	this.disableDisplay = function(headerIndex) {
		this.disabledDisplayItems[this.disabledDisplayItems.length] = headerIndex;
	}

}

//returns a reference to the asset manager
function AssetManager_getManager() {
	return manager;	
}

//renders the full asset manager
function AssetManager_renderAssets() {
	
	var parent = this.buildCrumbTrail();		
										
	var gridStr = '<table border="0" cellspacing="0" id="am_grid" class="am-grid"><tbody id="am_grid_body"><tr id="am_grid.headers" class="am-grid-headers">';
	var eventStr='';
	var id = "";
		
	for (i=0;i<this.columnHeadings.length;i++) {
		var disabled = false;
		for (j = 0; j<this.disabledDisplayItems.length;j++) {
			if (i == this.disabledDisplayItems[j]) {
				disabled = true;
			}
		}
		
		if (disabled) continue;
		
		id = 'am_grid.headers.' + i;				
		gridStr+= '<td id="' + id + '" class="am-grid-header-' + i + '">' + this.columnHeadings[i] + '</td>';	
		if (this.sortEnabled) {
			eventStr += 'document.getElementById("' + id + '").onclick=AssetManager_getManager().eventManager.gridHeaderClick;';			
			eventStr += 'document.getElementById("' + id + '").onmouseover=AssetManager_getManager().eventManager.gridHeaderMouseOver;';			
			eventStr += 'document.getElementById("' + id + '").onmouseout=AssetManager_getManager().eventManager.gridHeaderMouseOut;';			
		}
	}

	gridStr+= '</tr>';
	for (i=0;i<this.assetArrayData.length;i++) {
		id = 'am_grid.row.'+ i;
		gridStr += '<tr id="'+ id + '" class="am-grid-row">';
				
		asset = eval("new " + this.assetType + "()");		
		asset.rank = this.assetArrayData[i][0];
		asset.title = this.assetArrayData[i][1];
		asset.type = this.assetArrayData[i][2];
		asset.lastUpdate = this.assetArrayData[i][3];
		asset.size = this.assetArrayData[i][4];
		asset.url = this.assetArrayData[i][5];
		asset.assetId = this.assetArrayData[i][6];
		asset.icon = this.assetArrayData[i][7];
		asset.parent = parent;
		asset.labels = this.labels;
		var assetIndex = this.assets.length;
		this.assets[assetIndex]=asset;


		eventStr += 'document.getElementById("' + id + '").asset = AssetManager_getManager().assets[' + assetIndex + '];';
		eventStr += 'AssetManager_getManager().assets[' + assetIndex + '].div = document.getElementById("' + id + '");';
					
		for (k=0;k<this.columnHeadings.length;k++) {
			var disabled = false;
			for (j = 0; j<this.disabledDisplayItems.length;j++) {
				if (k == this.disabledDisplayItems[j]) {
					disabled = true;
				}
			}
		
			if (disabled) continue;

			id = 'am_grid.row' + '.' + i + '.col.' + k;
			gridStr+= '<td id="' + id  + '" class="am-grid-col-' + k +'">';
			
			if (k == 1) {
				gridStr +='<img src="' + asset.icon + '" border="0"/>';				
			}
			gridStr+=this.assetArrayData[i][k] + '</td>';	
		}
		gridStr+='</tr>';
    }
	gridStr += '</tbody></table>';
	
	document.getElementById("workspace").innerHTML=gridStr;
	eval(eventStr);
	for (i=0; i< this.assets.length; i++) {
		this.assets[i].registerEvents();
	}	
}


//builds the asset crumb trail
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
		
	contents += '</tr></table>';	
	
	if (this.displayCrumbTrail) {
		crumbtrail.innerHTML = contents;
	}
	
	//build assets attach the div properties
	var lastAsset = null;
	for (i=0; i< this.crumbtrail.length; i++ ) {
		var asset = new CrumbTrailAsset();		
		asset.title = this.crumbtrail[i][2];
		asset.url = this.crumbtrail[i][1];
		asset.assetId = this.crumbtrail[i][0];
		asset.parent = lastAsset;
		lastAsset = asset;
		asset.isParent = true;
		asset.labels = this.labels;
		if (this.displayCrumbTrail) {
			asset.div = document.getElementById(this.crumbtrail[i][0]);
			document.getElementById(this.crumbtrail[i][0]).asset = asset;
		}
		this.assets[this.assets.length] = asset;		
	}					

	return this.assets[this.assets.length -1];
}
		
//returns an asset based on a div object
function AssetManager_getAsset(obj) {   	   
    while (obj.tagName!=this.display.topLevelElement && !obj.asset) {
        obj=this.display.dom? obj.parentNode : obj.parentElement    
    }   
	return obj.asset;   
}

//displays the right click context menu
function AssetManager_displayContextMenu(x,y,asset) {    
    manager.contextMenu.render(asset.getContextMenu(),x,y,asset);    
}

//returns the asset IDS of all selected assets
function AssetManager_getSelectedAssetIds() {	
	var assetIds = "";
	for (i=0;i<this.display.overObjects.length;i++) {
		assetIds += "&assetId=" + this.display.overObjects[i].assetId;
	}
	return assetIds;
}

//Sorts the asset grid based on a column index
function AssetManager_sortGrid(columnIndex) {
	var prop = this.keys[columnIndex];	

	var tableBody = document.getElementById("am_grid_body");

	//remove the arrows from the other column headers
	for (i=0;i< this.columnHeadings.length;i++) {
		if (i != columnIndex && document.getElementById('am_grid.headers.' + i)) {						
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
	