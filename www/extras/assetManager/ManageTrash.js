//--------Constructor--------------------

//Creates a new asset object.
function ManageTrash() {
	var asset = new Asset();	
	asset.dragEnabled = false;
	asset.allowMultiSelect = true;
	//displays the right click context menu
asset.getContextMenu = function () {
   	var arr = new Array();    
	arr[arr.length] = new ContextMenuItem(this.labels["restore"],"javascript:" + this.evalReference() + ".restore()");
	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
	arr[arr.length] = new ContextMenuItem(this.labels["purge"],"javascript:" + this.evalReference() + ".purge()");
	return arr;    
}	
	
		
asset.purge = function() {
	location.href = this.parent.getWrappedURL() + "func=purgeList"  + AssetManager_getManager().getSelectedAssetIds();	
}
								
asset.restore = function() {
	location.href = this.parent.getWrappedURL() + "func=restoreList"  + AssetManager_getManager().getSelectedAssetIds();	
}
								
	return asset;
	
}		

