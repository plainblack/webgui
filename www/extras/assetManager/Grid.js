

function Grid(headerArray, dataArray,gridId) {
	this.headerArray = headerArray;
	this.dataArray = dataArray;
	this.render = Grid_render;
	this.sortColumn = Grid_sortColumn;
	this.gridId = gridId;
	this.attachEvents = Grid_attachEvents;
	//this.attachRowProperty = Grid_attachRowProperty;
	//this.attachRowEvent = Grid_attachRowEvent;

}

function Grid_render(div) {


//			obj = document.getElementById(key);
//		    obj.ondblclick=AssetManager_getManager().eventManager.activityDoubleClick;
 //   		obj.oncontextmenu=AssetManager_getManager().eventManager.activityRightClick;
  //  		obj.onmousedown=AssetManager_getManager().eventManager.activityMouseDown;


	var gridStr = '<table border="1" id="grid.' + this.gridId + '"><tr id="grid.' + this.gridId + '.headers">';
	var eventStr='';
	var id = "";
	
	
	for (i=0;i<this.headerArray.length;i++) {
		id = 'grid.' + this.gridId + '.headers.' + i;		
		gridStr+= '<td id="' + id + '">' + this.headerArray[i] + '</td>';	
		eventStr += 'document.getElementById("' + id + '").onclick=Grid_headerClicked;';	
	}

	gridStr+= '</tr>';
//['Rank','Title','Type','Last Updated','Size'];
	for (i=0;i<this.dataArray.length;i++) {
		id = 'grid.' + this.gridId + '.row.' + '.' + i;
		gridStr += '<tr id="'+ id + '">';
		eventStr += 'document.getElementById("' + id + '").onclick=Grid_rowClicked;';	
		eventStr += 'document.getElementById("' + id + '").onmouseover=Grid_rowMouseOver;';	
		eventStr += 'document.getElementById("' + id + '").onmouseout=Grid_rowMouseOut;';	
		eventStr += 'document.getElementById("' + id + '").ondblclick=Grid_rowDoubleClick;';	
		eventStr += 'document.getElementById("' + id + '").onmousedown=Grid_rowMouseDown;';	
		eventStr += 'document.getElementById("' + id + '").oncontextmenu=Grid_rowContextMenu;';	
						
		for (k=0;k<this.headerArray.length;k++) {
			gridStr+= '<td id="grid.' + this.gridId + '.row.' + '.' + i + '.col.' + k + '">' + this.dataArray[i][k] + '</td>';	
		}
	}
		gridStr+='</tr>';

	gridStr += '</table>';
	
	div.innerHTML = grid();
	
	
}

function Grid_rowClicked(e) {

}

function Grid_rowMouseOver(e) {

}

function Grid_rowMouseOut(e) {

}

function Grid_rowDoubleClick(e) {

}

function Grid_rowMouseDown(e) {

}

function Grid_rowContextMenu(e) {

}

function Grid_sortColumn() {

}