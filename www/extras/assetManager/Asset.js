
//--------Constructor--------------------

//Creates a new asset object.
/*********************Configuring Assets**********************

To create a new asset, the Asset object must be extended.
The following example creates an asset with the same properties and methods as the Asset object.

function MyNewAsset() {
   var asset = new Asset();                                     return asset;
}      
To change the new asset object, properties and methods can be added or overriden

The following example overrides the getContextMenu method, adds a new retore method, and sets the dragEnabled property to false

function MyNewAsset) {
   var asset = new Asset();        asset.dragEnabled = false;
  asset.getContextMenu = function () {
      var arr = new Array();      arr[arr.length] = new ContextMenuItem(this.labels["cut"],"javascript:" + this.evalReference() + ".cut()");
   arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
   arr[arr.length] = new ContextMenuItem(this.labels["purge"],"javascript:" + this.evalReference() + ".purge()");
   return arr;   }     asset.restore = function() {
   location.href = this.parent.getWrappedURL() + "func=postList"  + AssetManager_getManager().getSelectedAssetIds();   }
         return asset;
  }      
*************availble asset properties *********************

dragEnabled - Enables or disables making the asset dragable. Defaults to true
allowMultiSelect - Enables or disables multiselection of the asset. Defaults to true;


***************Notes*********************

1. The asset class contains a getWrappedURL()  method that return the asset.url property wrapped in "http://hostname" and the paramenter delimiter
2. asset.parent will return the parent asset (on the crumbtrail)
3. The AssetManager_getManager().getSelectedAssetsIds() method will return a parameter string containing all the selected asset Id's
*/

//Constructor
function Asset() {
		//properties
        this.url = "";
        this.rank = 1;
        this.labels = new Array();
        this.assetId = "";
		this.type = "";
		this.parent = null;
        this.title = "";
        this.size = 0;
        this.lastUpdate = "";
        this.icon = "";
        this.div = null;
        this.dragEnabled = true;
        this.allowMultiSelect = true;
        this.isParent=false;
		
//---------Method Implementations -------------

this.registerEvents = function() {		

    //if there is a div associated with the asset, register event handlers	
    if (this.div) {
		this.div.ondblclick=Asset_doubleClick;	
		this.div.onmousedown=Asset_mouseDown;	
		this.div.oncontextmenu=Asset_rightClick;	
    }
}

//Moving to a new parent (move)
//----------------------
//url + ?||& + func=setParent&assetId= + assetId 		
this.setParent = function(asset) {
	//parentURL
	location.href = this.getWrappedURL() + "func=setParent&assetId="+ asset.assetId;		
}
	
			
//Set the rank of an asset amongst its siblings (move)
//---------------------------------------------
//url + ?||& + func=setRank&rank= + newRank
this.setRank = function(rank) {
	//to child
	location.href = this.getWrappedURL() + "func=setRank&rank="+ rank;		
}


//url + ?||& + func=editTree 				
this.editTree = function() {	
	//parentURL
	location.href = this.getWrappedURL() + "func=editTree";		
}


//Edit the properties of an asset (edit)
//-------------------------------
//url + ?||& + func=edit
this.edit = function() {
	location.href = this.getWrappedURL() + "func=edit&proceed=manageAssets";		
}

//Edit the properties of an asset (edit)
//-------------------------------
//url + ?||& + func=edit
this.go = function() {
	location.href = this.getWrappedURL() + "func=manageAssets";		
}

//View an asset (view)
//-------------
//url + ?||& + func=view
this.view = function() {
	location.href = this.getWrappedURL();		
}

//returns a string that returns a reference to the asset when evaled
this.evalReference = function() {
	return "document.getElementById('" + this.div.id + "').asset";
}

//displays the right click context menu
this.getContextMenu = function () {
    var arr = new Array();    
    if (AssetManager_getManager().display.overObjects.length == 1) {
    	arr[arr.length] = new ContextMenuItem(this.labels["go"],"javascript:" + this.evalReference() + ".go()");
   	 	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
	    arr[arr.length] = new ContextMenuItem(this.labels["view"],"javascript:" + this.evalReference() + ".view()");
    	arr[arr.length] = new ContextMenuItem(this.labels["edit"],"javascript:" + this.evalReference() + ".edit()");
    }
    
	arr[arr.length] = new ContextMenuItem(this.labels["delete"],"javascript:" + this.evalReference() + ".remove()");        
 	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
  	arr[arr.length] = new ContextMenuItem(this.labels["cut"],"javascript:" + this.evalReference() + ".cut()");        
   	arr[arr.length] = new ContextMenuItem(this.labels["copy"],"javascript:" + this.evalReference() + ".copy()");
    
   	if (AssetManager_getManager().display.overObjects.length ==1) {
    	arr[arr.length] = new ContextMenuItem("<img src='/extras/assetManager/breakerLine.gif'>","");
    	arr[arr.length] = new ContextMenuItem(this.labels["editTree"],"javascript:" + this.evalReference() + ".editTree()");        
	}    

	return arr;    
}

this.select= function() {
	this.div.className="am-grid-row-over";				
}

this.deselect = function() {
	this.div.className="am-grid-row";				
}

//Copy an asset to the clipboard (copy)
//------------------------------
//url + ?||& + func=copy
this.copy = function() {
	location.href = this.parent.getWrappedURL() + "func=copyList"  + AssetManager_getManager().getSelectedAssetIds();		
}

//Cut an asset to the clipboard (cut)
//-----------------------------
//url + ?||& + func=cut
this.cut = function() {
	location.href = this.parent.getWrappedURL() + "func=cutList"  + AssetManager_getManager().getSelectedAssetIds();	
}

//Delete an asset. (delete)
//----------------
//url + ?||& + func=delete (do a javascript confirm on this)
this.remove = function() {	
	if (window.confirm("Are you sure you want to delete this asset?  Click OK to continue, or Cancel if you made a mistake.")) {								
		location.href = this.parent.getWrappedURL() + "func=deleteList"  + AssetManager_getManager().getSelectedAssetIds();		
	}
}

//adds http, the hostname, and a trailing parameter delimiter to the url
this.getWrappedURL = function() {
	if (this.url.indexOf("?") == -1) {
		return "http://" + AssetManager_getManager().tools.getHostName(location.href) + this.url + "?";
	}else {
		return "http://" + AssetManager_getManager().tools.getHostName(location.href) + this.url + "&";
    }
}

}//end object		

//Staic Methods
function Asset_doubleClick(e) {
    var dom = document.getElementById&&!document.all;
    var e=dom? e : event;
    var obj =dom? e.target : e.srcElement
   	
   	AssetManager_getManager().getAsset(obj).go();   	
}

function Asset_rightClick(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
    
    if (!dom) { 
        e.cancelBubble = true;
        e.returnValue = false;
    }

    var asset = manager.getAsset(obj);

    if (asset) {
		manager.display.contextMenu.owner = asset;
    	manager.displayContextMenu(e.clientX,e.clientY,asset);            
    }    

    
    return false;
} 

function Asset_mouseDown(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;

	//Display_adjustScrollBars(e);

    if (e.button==2) {
	    //this is a hack to get the context menu stuff to work right in IE
   	 	if (!dom) {
     	      e.cancelBubble = true;
        	e.returnValue = false;
    	      EventManager_documentMouseDown(e);
	}
    }    

    return false;
} 


