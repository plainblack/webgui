
//--------Constructor--------------------

function Asset() {
		//properties
        this.url = "";
        this.rank = 1;
        this.assetId = "";
		this.type = "";
        this.title = "";
        this.size = 0;
        this.lastUpdate = "";
        this.icon = "";
        this.div = null;
		
		//methods
        this.edit = Asset_edit;        
		this.view = Asset_view;
		this.editTree=Asset_editTree;
		this.setParent=Asset_setParent;
		this.setRank=Asset_setRank;
		this.remove = Asset_remove;
		this.cut = Asset_cut;
		this.copy = Asset_copy;
		this.displayContextMenu = Asset_displayContextMenu;  
		this.displayProperties = Asset_displayProperties;
}		

//---------Method Implementations -------------

		
//url + ?||& + func=editTree 				
function Asset_editTree() {	
	location.href = manager.tools.addParamDelimiter(this.url) + "func=editTree";		
}

//Moving to a new parent (move)
//----------------------
//url + ?||& + func=setParent&assetId= + assetId 		
function Asset_setParent(parentId) {
	location.href = manager.tools.addParamDelimiter(this.url) + "func=setParent&assetId="+ parentId;		
}

//Set the rank of an asset amongst its siblings (move)
//---------------------------------------------
//url + ?||& + func=setRank&rank= + newRank
function Asset_setRank(rank) {
	alert("setting rank");
	location.href = manager.tools.addParamDelimiter(this.url) + "func=setRank&rank="+ rank;		
}

//View an asset (view)
//-------------
//url + ?||& + func=view
function Asset_view() {
	location.href = manager.tools.addParamDelimiter(this.url) + "func=view";		
}

//Copy an asset to the clipboard (copy)
//------------------------------
//url + ?||& + func=copy
function Asset_copy() {
	location.href = manager.tools.addParamDelimiter(this.url) + "func=copyList&assetId=" + this.assetId;		
}

//Cut an asset to the clipboard (cut)
//-----------------------------
//url + ?||& + func=cut
function Asset_cut() {
	location.href = manager.tools.addParamDelimiter(this.url) + "func=cutList&assetId=" + this.assetId;		
}

//Edit the properties of an asset (edit)
//-------------------------------
//url + ?||& + func=edit
function Asset_edit() {
	location.href = manager.tools.addParamDelimiter(this.url) + "func=edit";		
}

//Delete an asset. (delete)
//----------------
//url + ?||& + func=delete (do a javascript confirm on this)
function Asset_remove() {	
	if (window.confirm("Are you sure you want to delete this asset?  Click OK to continue, or Cancel if you made a mistake.")) {
		location.href = manager.tools.addParamDelimiter(this.url) + "func=deleteList&assetId=" + this.assetId;		
	}
}

//Constructs a properties window for this BpmNode and passes to the Diplay object for rendering.
function Asset_displayProperties() {
    html = "<table border='0'><tr><td class=\"propertiesMenuName\">Title:</td><td class=\"propertiesMenuValue\">" + this.title + "</td></tr>";
    html+="<tr><td class=\"propertiesMenuName\">Rank:</td><td class=\"propertiesMenuValue\">" + this.rank + "</td></tr>"
    html+="<tr><td class=\"propertiesMenuName\">Asset ID:</td><td class=\"propertiesMenuValue\">" + this.assetId + "</td></tr>"
    html+="<tr><td class=\"propertiesMenuName\">Asset Type:</td><td class=\"propertiesMenuValue\">" + this.type + "</td></tr>"
    html+="<tr><td class=\"propertiesMenuName\">Size:</td><td class=\"propertiesMenuValue\">" + this.size + "</td></tr>"
    html+="<tr><td class=\"propertiesMenuName\">Last Updated:</td><td class=\"propertiesMenuValue\">" + this.lastUpdate + "</td></tr>"
    html+="</table>";   
    manager.display.displayPropertiesWindow(html);
}

function Asset_displayContextMenu(x,y) {

    var arr = new Array();
    arr[arr.length] = new ContextMenuItem("View","javascript:manager.display.contextMenu.owner.view()");
    arr[arr.length] = new ContextMenuItem("Edit","javascript:manager.display.contextMenu.owner.edit()");
    arr[arr.length] = new ContextMenuItem("Delete","javascript:manager.display.contextMenu.owner.remove()");        
    arr[arr.length] = new ContextMenuItem("<img src='breakerLine.gif'>","");
    arr[arr.length] = new ContextMenuItem("Cut","javascript:manager.display.contextMenu.owner.cut()");        
    arr[arr.length] = new ContextMenuItem("Copy","javascript:manager.display.contextMenu.owner.copy()");
    arr[arr.length] = new ContextMenuItem("<img src='breakerLine.gif'>","");
    arr[arr.length] = new ContextMenuItem("Edit Tree","javascript:manager.display.contextMenu.owner.editTree()");        
    arr[arr.length] = new ContextMenuItem("Properties","javascript:manager.display.contextMenu.owner.displayProperties()");
    
//    alert("x = " + x + " y= " + y);
    
    manager.contextMenu.render(arr,x,y,this);    
}






