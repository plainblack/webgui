
//--------Constructor--------------------

//Creates a new asset object.
function ManageAssets() {
	var asset = new Asset();	

asset.getContextMenu = function () {
        var arr = new Array();
        arr[arr.length] = new ContextMenuItem(this.labels["go"],"javascript:" + this.evalReference() + ".go()");
        arr[arr.length] = new ContextMenuItem(this.labels["view"],"javascript:" + this.evalReference() + ".view()");
        arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
        arr[arr.length] = new ContextMenuItem(this.labels["edit"],"javascript:" + this.evalReference() + ".edit()");
        arr[arr.length] = new ContextMenuItem(this.labels["editTree"],"javascript:" + this.evalReference() + ".editBranch()");
        arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
        arr[arr.length] = new ContextMenuItem(this.labels["cut"],"javascript:" + this.evalReference() + ".cut()");
        arr[arr.length] = new ContextMenuItem(this.labels["copy"],"javascript:" + this.evalReference() + ".copy()");
        arr[arr.length] = new ContextMenuItem(this.labels["shortcut"],"javascript:" + this.evalReference() + ".shortcut()");
        arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
        arr[arr.length] = new ContextMenuItem(this.labels["delete"],"javascript:" + this.evalReference() + ".remove()");
        return arr;
}


asset.shortcut = function() {
        location.href = this.getWrappedURL() + "func=createShortcut&proceed=manageAssets";
}

	return asset;
	
}		

