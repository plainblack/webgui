
//--------Constructor--------------------

//Creates a new asset object.
function ManageTrash() {
	var asset = new Asset();	
	
	asset.dragEnabled = false;
	asset.allowMultiSelect = true;
	
	//displays the right click context menu
asset.getContextMenu = function () {
   	var arr = new Array();    
	arr[arr.length] = new ContextMenuItem(this.labels["cut"],"javascript:manager.display.contextMenu.owner.cut()");
	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
	arr[arr.length] = new ContextMenuItem(this.labels["purge"],"javascript:manager.display.contextMenu.owner.purge()");
	return arr;    
}	
	
								
	return asset;
	
}		

