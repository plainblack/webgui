
//--------Constructor--------------------

//Creates a new asset object.
function ManageClipboard() {
	var asset = new Asset();	
	
	asset.dragEnabled = false;
	asset.allowMultiSelect = true;
	
	//displays the right click context menu
asset.getContextMenu = function () {
   	var arr = new Array();    
	arr[arr.length] = new ContextMenuItem(this.labels["restore"],"javascript:manager.display.contextMenu.owner.restore()");
	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
	arr[arr.length] = new ContextMenuItem(this.labels["delete"],"javascript:manager.display.contextMenu.owner.delete()");
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

