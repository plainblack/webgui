//--------Constructor--------------------

function AssetManager(assetArrayData,headerArrayData,lables,crumbtrail) {	
	this.tools = new Tools();
	this.contextMenu = new ContextMenu();
	this.display = new Display();
	this.eventManager = new EventManager();
			
	this.lables = lables;
	this.crumbtrail = crumbtrail;		
			
	this.renderAssets = AssetManager_renderAssets;
	this.assetArrayData = assetArrayData;
	this.columnHeadings = headerArrayData;
	this.assets = new Array();
	this.assetKeys = new Array();
	this.registerAsset = AssetManager_registerAsset;
	this.getAsset= AssetManager_getAsset;
	this.setEventHandlers = AssetManager_setEventHandlers;
	this.buildCrumbTrail = AssetManager_buildCrumbTrail;
}

function AssetManager_getManager() {
	return manager;	
}

function AssetManager_renderAssets() {

		var obj = new Active.Controls.Grid;
		obj.setColumnTemplate(new Active.Templates.Image, 1);
		
		obj.setRowProperty("count",this.assetArrayData.length);
		obj.setColumnProperty("count",this.columnHeadings.length );

		//obj.setDataProperty("text", function(i, j){return assetArray[i][j]});
		obj.setDataProperty("text", function(i, j){return AssetManager_getManager().assetArrayData[i][j]});
		obj.setDataProperty("image", function(i, j){return AssetManager_getManager().assetArrayData[i][7]});

		obj.setColumnProperty("text", function(i){return AssetManager_getManager().columnHeadings[i]});

		//	set headers width/height
		obj.setRowHeaderWidth("0px");
		obj.setColumnHeaderHeight("20px");
		obj.sort(0);	
							
		this.buildCrumbTrail();
		document.getElementById("workspace").innerHTML="<table border='1' width=600 height=200><tr><td>" + obj; + "</td></tr></table>"

		//document.getElementById("workspace").innerHTML=obj;
//		document.getElementById("myArea").value=obj;
		
		this.setEventHandlers();
	}

function AssetManager_buildCrumbTrail() {
	var crumbtrail = document.getElementById("crumbtrail");
	var contents = "<table><tr>";
	
	for (i=0;i<this.crumbtrail.length;i++) {
		contents += '<td id="' + this.crumbtrail[i][0] + '" class="crumbtrail">' + this.crumbtrail[i][1] + '</td>';		
		if (i != this.crumbtrail.lenght) {
			contents += "<td>&nbsp;->&nbsp;</td>";
		}
	
	}
	
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
	
function AssetManager_setEventHandlers() {
		var obj = null;
		var asset=null;
		for (i=0;i<this.assetArrayData.length;i++) {
			var key = "tag50.data.item:" + i;
			
	/* rank, title, type, lastUpdate, size, url, assetId */
			
			
			asset = new Asset();
			asset.key= key
			asset.rank = this.assetArrayData[i][0];
			asset.title = this.assetArrayData[i][1];
			asset.type = this.assetArrayData[i][2];
			asset.lastUpdate = this.assetArrayData[i][3];
			asset.size = this.assetArrayData[i][4];
			asset.url = this.assetArrayData[i][5];
			asset.assetId = this.assetArrayData[i][6];
			asset.icon = this.assetArrayData[i][7];

//			obj = document.getElementById(key + ".item:1");
			obj = document.getElementById(key);
		    obj.ondblclick=AssetManager_getManager().eventManager.activityDoubleClick;
    		obj.oncontextmenu=AssetManager_getManager().eventManager.activityRightClick;
    		obj.onmousedown=AssetManager_getManager().eventManager.activityMouseDown;

			asset.div = obj;
			this.registerAsset(asset,i);
		}		
}	
	
function AssetManager_registerAsset(asset,i) {
	this.assets[asset.div.id] = asset;		
	this.assetKeys[i] = asset.div.id;
}
	
function AssetManager_getAsset(obj) {   	
   	var parts = obj.id.split(".");    	    	
   	return manager.assets[parts[0] + "." + parts[1] + "." + parts[2]];
}



	