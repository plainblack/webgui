
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
		this.displayProperties = Asset_displayProperties;
}		

//---------Method Implementations -------------

		


//Edit the properties of an asset (edit)
//-------------------------------
//url + ?||& + func=edit
function Asset_edit() {
	location.href = manager.tools.addParamDelimiter(this.url) + "func=edit";		
}

//View an asset (view)
//-------------
//url + ?||& + func=view
function Asset_view() {
	location.href = manager.tools.addParamDelimiter(this.url) + "func=view";		
}

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






