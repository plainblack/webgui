
//--------Constructor--------------------

//Creates a new asset object.
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
        this.isParent=false;
		
		//methods
        this.edit = Asset_edit;        
		this.view = Asset_view;
		this.go = Asset_go;
		this.setRank = Asset_setRank;
//		this.displayProperties = Asset_displayProperties;
		this.setParent = Asset_setParent;
}		

//---------Method Implementations -------------

//Moving to a new parent (move)
//----------------------
//url + ?||& + func=setParent&assetId= + assetId 		
function Asset_setParent(asset) {
	//parentURL
	location.href = "http://" + manager.tools.getHostName(location.href) + manager.tools.addParamDelimiter(this.url) + "func=setParent&assetId="+ asset.assetId;		
}
	
			
//Set the rank of an asset amongst its siblings (move)
//---------------------------------------------
//url + ?||& + func=setRank&rank= + newRank
function Asset_setRank(rank) {
	//to child
	location.href = "http://" + manager.tools.getHostName(location.href) + manager.tools.addParamDelimiter(this.url) + "func=setRank&rank="+ rank;		
}


//Edit the properties of an asset (edit)
//-------------------------------
//url + ?||& + func=edit
function Asset_edit() {
	location.href = "http://" + manager.tools.getHostName(location.href) + manager.tools.addParamDelimiter(this.url) + "func=edit&proceed=manageAssets";		
}

//Edit the properties of an asset (edit)
//-------------------------------
//url + ?||& + func=edit
function Asset_go() {
	location.href = "http://" + manager.tools.getHostName(location.href) + manager.tools.addParamDelimiter(this.url) + "func=manageAssets";		
}


//View an asset (view)
//-------------
//url + ?||& + func=view
function Asset_view() {
	location.href = "http://" + manager.tools.getHostName(location.href) + this.url;		
}



