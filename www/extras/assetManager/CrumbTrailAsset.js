
//--------Constructor--------------------

//Creates a new asset object.
function CrumbTrailAsset() {
	var asset = new Asset();	
	
	asset.dragEnabled = false;
	asset.allowMultiSelect = false;
	
	//displays the right click context menu
asset.getContextMenu = function () {
   	var arr = new Array();    
	arr[arr.length] = new ContextMenuItem(this.labels["go"],"javascript:manager.display.contextMenu.owner.go()");
	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
	arr[arr.length] = new ContextMenuItem(this.labels["view"],"javascript:manager.display.contextMenu.owner.view()");
   	arr[arr.length] = new ContextMenuItem(this.labels["edit"],"javascript:manager.display.contextMenu.owner.edit()");    
	return arr;    
}	
	
asset.select= function() {
	this.div.className="am-crumbtrail-over";				
}

asset.deselect = function() {
	this.div.className="am-crumbtrail";				
}
								
	return asset;
	
}		

