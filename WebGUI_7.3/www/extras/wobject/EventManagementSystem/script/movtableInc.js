/*****************************************************************
 Page : movtableinc.js
 Description : main javascript 
 Date : 20/04/05
 Authors:Alessandro Viganò (avigano@Movinfo.it) / Filippo Zanardo (fzanardo@MOViNFO.it)
 Copyright (C) 2005-2006 MOViNFO

MovTable is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public
modify it under the terms of the GNU General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

MovTable is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
General Public License for more details.

You should have received a copy of the GNU General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
******************************************************************/

var selectedText;
var selectedElem;
var targetElm;
var myTable;
var hiddenCols;
var activeHeaders= null;
var moveColumn=null;
var dragHeaderDiv=null;
var topElement=null;
var topElementByTag=null;
var originalOnSelect;
var eventProcessed=false;

/**
* Initializing function, to be called on document onload
*
*/
function sortableInit()
{
	initjsDOMenu();
	myTable=new table(tableClass);
	document.onmousedown=mouseDown;
}

/**
* Function called by jsDOMenu. It creates the dynamic context menus and it passes them back
*
*/
function getPopUpMenuObj(e)
{
  
	targetElm = (e.target) ? e.target : e.srcElement;
  
  	if (targetElm.nodeType==3) //Text Node returned by Konqueror
  		targetElm=targetElm.parentNode;
  	if (targetElm.parentNode.tagName=='TH') targetElm=targetElm.parentNode;
  
  
  if (targetElm.tagName=='TD' || targetElm.tagName=='TH') {
  	selectedText=selectElement(targetElm);
	cursorMenu1 = new jsDOMenu(210);
	var colID=getColID(targetElm);
	//filterurl=baseurl+'&filterByIndexCol='+myTable.columns.getColByID(colID).index+"&filterByIndexRow="+ (getRow(targetElm)-1);
   	//removeFilter=baseurl+"&removefilter";
	//sorturl=baseurl+'&sortByIndexCol='+myTable.columns.getColByID(colID).index;
	//alert(colID);
	//alert(myTable.columns.getColByID(colID).id);
	if (targetElm.tagName=='TH') {
		
		hiddenCols=myTable.columns.listInvisible();
		//Controlla se rimane visibile solo 1 colonna
		if (JScolhide==1)
			if ((myTable.columns.item.length-hiddenCols.length)==1) 
				cursorMenu1.addMenuItem(new menuItem("Hide Column", "", "",false));
			else
				//cursorMenu1.addMenuItem(new menuItem("Nascondi Colonna", "", "code:myTable.columns.item["+getCellIndex(targetElm)+"].hideColumn()"));
				cursorMenu1.addMenuItem(new menuItem("Hide Column", "", "code:myTable.columns.getColByID('"+colID+"').hideColumn()"));
			
		//Controlla se ci sono colonne nascoste
		if (myTable.columns.hidden()) {
			cursorMenu1.addMenuItem(new menuItem("Show Columns", "mColonne", "code:myTable.columns.listInvisible()"));
			columnsMenu= new jsDOMenu(210);
			
			for (var x=0;x<hiddenCols.length;x++) {
				columnsMenu.addMenuItem(new menuItem(hiddenCols[x].displayName,"","code:hiddenCols["+x+"].showColumn()"));
			}
			
			if (hiddenCols.length > 1) {
				columnsMenu.addMenuItem(new menuItem("-"));
				columnsMenu.addMenuItem(new menuItem("All","","code:myTable.columns.show()"));
			}	
			
			cursorMenu1.items["mColonne"].setSubMenu(columnsMenu);
		}
		else
			cursorMenu1.addMenuItem(new menuItem("Show Columns", "mColonne", "code:myTable.columns.listInvisible()",false));
		
		//cursorMenu1.addMenuItem(new menuItem("Debug", "", "code:debug()"));
	}
	if (targetElm.tagName=='TD') {
	   var editUrl = "";
	   var transferUrl = "";
	   var terminateUrl = "";
	   var tr = targetElm.parentNode;
	   var len=tr.childNodes.length;
	   var lastElem = tr.childNodes[len-1];
	   var lastElemLen = lastElem.childNodes.length;
       for (var i=0; i < lastElemLen; i++){
          var lastElemNode = lastElem.childNodes[i];
		  if(lastElemNode.tagName == "A") {
		     if(lastElemNode.id.indexOf("edit") > -1) {
			    editUrl = lastElemNode.href;
			 }else if(lastElemNode.id.indexOf("transfer") > -1) {
			    transferUrl = lastElemNode.href;
			 }else if(lastElemNode.id.indexOf("terminate") > -1) {
			    terminateUrl = lastElemNode.href;
			 }
          }
	   }
	   //alert(editUrl)
	   //alert(transferUrl);
	   //alert(terminateUrl);
	   
		if (myTable.columns.getColByID(colID).filterable)
		{
			cursorMenu1.addMenuItem(new menuItem("Edit Employee", "", editUrl));
			cursorMenu1.addMenuItem(new menuItem("Transfer Employee", "", transferUrl));
			cursorMenu1.addMenuItem(new menuItem("Terminate Employee", "", terminateUrl));
		}
		else
		{
			cursorMenu1.addMenuItem(new menuItem("Edit Employee", "", "",false));
			cursorMenu1.addMenuItem(new menuItem("Transfer Employee", "", "",false));
			cursorMenu1.addMenuItem(new menuItem("Terminate Employee", "", "",false));
		}			
		//if (filtered) 
		//	cursorMenu1.addMenuItem(new menuItem(getText("Rimuovi filtro"), "", removeFilter));
		//else
	//		cursorMenu1.addMenuItem(new menuItem(getText("Rimuovi filtro"), "", removeFilter,false));
		cursorMenu1.addMenuItem(new menuItem("-"));
	}

	//Sort menu items
	if (myTable.columns.getColByID(colID).sortable) {
	   var colVars = colID.split("_");
	   var sortASCurl = "javascript:void(sortFields('"+colVars[1]+"','asc'));";
	   var sortDESCurl = "javascript:void(sortFields('"+colVars[1]+"','desc'));";
	   cursorMenu1.addMenuItem(new menuItem("Sort Ascending", "",sortASCurl));
	   cursorMenu1.addMenuItem(new menuItem("Sort Descending", "",sortDESCurl));
	}
	else
	{	
		cursorMenu1.addMenuItem(new menuItem("Sort Ascending", "", "",false));
		cursorMenu1.addMenuItem(new menuItem("Sort Descending", "", "",false));
  	}
	//cursorMenu1.addMenuItem(new menuItem(getText("Copia"), "", "code:copyElement(selectedText)"));
	return cursorMenu1;
  }
  else 
  	return null;
}

function debug()
{
	var colOrder='';
	var rows=myTable.table.getElementsByTagName('TBODY')[0].getElementsByTagName('TR');
	var cols=rows[0].getElementsByTagName('TH');
	
	for (var x=0;x<cols.length;x++)
	{
		window.alert(myTable.columns.getColByID(cols[x].id).index);
	}
}	

/**
* Needed by JSdomenu. Acrivates the popup menu
*
*/
function createjsDOMenu() {
	if (isOpera() || isKonqueror() || isSafari())
		activatePopUpMenuBy(0,0);
	else
	    activatePopUpMenuBy(1, 2);
}

function hideVisibleCallback() {
	if ((isOpera() || isKonqueror() || isSafari()) && selectedElem)
	{	
		selectedElem.className='';
		selectedElem=null;
	}
}
/**
* Simple function to get the row index of tablecell element
* @param {tableCell} element A TH element
* @return {int} Row Index
*/
function getRow(element) {
	return element.parentNode.rowIndex;
}

/**
* Function to select text of a HTML element
* @param {HTMLElement} element An HTML element
* @return {string} Selected Text
*/
function selectElement(element) {
	
	if (isIE()) {
		var oRange=document.body.createTextRange();
		oRange.moveToElementText(element);
		oRange.select();
		return oRange.text;
	}
	if (isOpera() || isSafari() ||isKonqueror())
	{
		element.className='tdSelected';	
		selectedElem=element;
		return;
	}
	
	if (window.getSelection())
	{
		//Selezione dell'elemento scelto- Mozilla
		var oRange=document.createRange();
		oRange.selectNodeContents(element);
		var oSelection=window.getSelection();
		oSelection.removeAllRanges();
		oSelection.addRange(oRange); 
		return oSelection.toString(); 	
	}
}

/**
* Function to copy some text to clipboard
* @param {string} copyText Text to copy
*/
function copyElement (copyText) {
 		if (isIE()) {
			if (window.clipboardData) { // IE send-to-clipboard method.
				window.clipboardData.setData('Text', copyText);
			}
 		}
 		else {	
			// You have to sign the code to enable this or allow the action in about:config by changing user_pref("signed.applets.codebase_principal_support", true);
			netscape.security.PrivilegeManager.enablePrivilege('UniversalXPConnect');
			
			// Store support string in an object.
			var str = Components.classes["@mozilla.org/supports-string;1"].createInstance(Components.interfaces.nsISupportsString);
			if (!str) return false;
			str.data=copyText;
			
			// Make transferable.
			var trans = Components.classes["@mozilla.org/widget/transferable;1"].createInstance(Components.interfaces.nsITransferable);
			if (!trans) return false;
			
			// Specify what datatypes we want to obtain, which is text in this case.
			trans.addDataFlavor("text/unicode");
			trans.setTransferData("text/unicode",str,copyText.length*2);
			
			var clipid=Components.interfaces.nsIClipboard;
			var clip = Components.classes["@mozilla.org/widget/clipboard;1"].getService(clipid);
			if (!clip) return false;
			
			clip.setData(trans,null,clipid.kGlobalClipboard);	
 		}
}

/**
* Function to get the display name of a columns
* @param {tableCell} element A TH element
* @property {string} displayName
*/
function columnGetName (element)
{
	var anchors=element.getElementsByTagName("A");
	//Check the existance of A tags
	if (anchors.length > 0) 
		element=anchors[0];
	
	return element.innerHTML;
}

/**
* @class Representation of a column
* @param {tableCell} th TH element
* @param {columns} parent columns object
*/
function column (th,parent)
{
	//FIELDS
	
	/**
	*The column display name
	*@type string
	*/
	this.displayName=columnGetName(th);
	
	/**
	*The HTML element object
	*@type HTMLelement
	*/
	this.element=th; 
	
	/**
	*The real field name
	*@type string
	*/
	this.fieldName=this.element.id.slice(9); 
	
	/**
	*Original display order index
	*@type int
	*/
	this.index=getCellIndex(th);
	
	/**
	*Reference to columns object
	*@type columns
	*/
	this.parent=parent;
	
	/**
	*Reference to table object
	*@type table
	*/
	this.table=this.parent.parent;
	
	/**
	*Column is sortable
	*@type boolean
	*/
	this.sortable=sortable[this.index];
	
	/**
	*Column is filterable
	*@type boolean
	*/
	this.filterable=filterable[this.index];
	
	/**
	*Column is visible
	*@type boolean
	*/
	this.visible=true;
	
	
	//METHODS
	this.hideColumn=column_hideColumn;
	this.showColumn=column_showColumn;
	this.setVisible=column_setVisible;
	this.setWidth=column_setWidth;
	this.retrieveStatus=column_retrieveStatus;
	this.getAbsoluteIndx=column_getAbsoluteIndx;
	this.getRelativeIndx=column_getRelativeIndx;
	//constructor code
	this.retrieveStatus();
}

/**
* It return the right cell index, fixing the IE explorer behaviour
* @return {int} The absolute cell index
*/
function column_getAbsoluteIndx()
{
	if (isIE()) {
		var x=0;
		while (this.table.rows[0].getElementsByTagName('TH')[x].id != this.element.id)	
			x++;
		return x;
	}
	else
		if (isKonqueror() || isSafari()) 
			return getKCellIndex(this.element);
		else
			return this.element.cellIndex;
}

/**
* It return the relative cell index, as displayed on screen (as IE does)
* @return {int} The relative cell index
*/
function column_getRelativeIndx()
{
	if (isIE()) 
		return this.element.cellIndex;
	else
	{	
		if (isKonqueror() || isSafari()) 
			var colIndx=getKCellIndex(this.element);
		else
			var colIndx=this.element.cellIndex;
			
		var stop=colIndx;
		
		for (var x=0;x<stop;x++) {
			if (this.table.rows[0].getElementsByTagName('TH')[x].style.display=='none')
				colIndx=colIndx-1;
		}
		return colIndx;
	}
}
	
/**
* Read width and visible information from cookies
*/
function column_retrieveStatus()
{
	var status=getCookie(tableClass+"."+this.fieldName);
	if (status=='true' || status==null)
		this.visible=true;
	else
	{
		this.visible=false;
		this.hideColumn();
	}
	
	var width=getCookie(tableClass+"."+this.fieldName+".width");
	if (width != null && this.visible==true)
	{	
		this.element.style.width=width;
		this.table.table.getElementsByTagName('colgroup')[0].getElementsByTagName('col')[this.getRelativeIndx()].width=width;
	}
		
}

/**
* Write visible information to cookies
* @param {boolean} state TRUE=visible
*/
function column_setVisible(state) {
	this.visible=state;
	if (state) 
		document.cookie= tableClass+"."+this.fieldName+"=true";
	else
		document.cookie= tableClass+"."+this.fieldName+"=false";
}

/**
* Write width information to cookies
* @param {string} width The width of the colum. Ex '100px'
*/
function column_setWidth(width) {
	document.cookie= tableClass+"."+this.fieldName+".width="+width;
}

/**
* Hide the column
*/
function column_hideColumn () {
	//window.alert(this.nome+":"+getCellIndex(this.element)+":"+this.element.innerHTML);
	//var toBeRemoved=this.table.table.getElementsByTagName('colgroup')[0].getElementsByTagName('col')[this.getRelativeIndx()];
	var toBeRemoved=this.table.table.getElementsByTagName('colgroup')[0].getElementsByTagName('col')[0];
	this.table.table.getElementsByTagName('colgroup')[0].removeChild(toBeRemoved);
	var col=document.getElementById('movTable_'+this.fieldName);
	//Se le colonne non sono ancora state taggate allora sicuramente non sono ancora state mosse => l'indice è quello originale
	var displayIndex= (col != null) ? getCellIndex(col) : this.index;
	var rows=this.table.rows;
	for (var x=0;x<rows.length;x++) {

		if (x>0)
			var cols=rows[x].getElementsByTagName('TD');
		else
			var cols=rows[x].getElementsByTagName('TH');
		
		cols[displayIndex].style.display='none';

	}
	
	this.setVisible(false);
	if (isKonqueror() || isSafari())
		this.parent.resetSize();
}

/**
* Show the column
*/
function column_showColumn() {
	var rows=this.table.rows;
	var displayIndex= this.getAbsoluteIndx();
	for (var x=0;x<rows.length;x++) {

		if (x>0)
			var cols=rows[x].getElementsByTagName('TD');
		else
			var cols=rows[x].getElementsByTagName('TH');
		
		if (isKonqueror() || isSafari())
			cols[displayIndex].style.display='table-cell';
		else
			cols[displayIndex].removeAttribute('style');

	}
	this.setVisible(true);
	var colEl= document.createElement("COL");
	this.table.table.getElementsByTagName('colgroup')[0].appendChild(colEl);
	
	if (isKonqueror() || isSafari())
		this.parent.resetSize();
}

/**
* @class Representation of columns
* @param {tableRow} tr TR element
* @param {table} parent table object
*/
function columns (tr,parent)
{
	//FIELDS
	/**
	* Collection of column objects
	* @type array of column
	*/
	this.item= new Array();
	/**
	* Reference to table object
	* @type table
	*/
	this.parent= parent;
	
	//METHODS
	this.listInvisible=columns_listInvisible;
	this.hidden=columns_hidden;
	this.show=columns_show;
	this.getColByID=columns_getColByID;
	this.recol=columns_recol;
	this.setOrder=columns_setOrder;
	this.resetSize=columns_resetSize;

	//Constructor Code
	var cols=tr.getElementsByTagName('TH');
	
	for (var x=0;x<cols.length;x++) {
		this.item[x]=new column(cols[x],this);
	}

	//Controlliamo che almeno una colonna sia visibile
	if (this.listInvisible().length==this.item.length) 
	{	
		this.item[0].showColumn();
	}
}

function columns_resetSize()
{
	var visibleCols=this.parent.table.getElementsByTagName('colgroup')[0].getElementsByTagName('col').length;
	var aColWidth=Math.floor(this.parent.table.offsetWidth / visibleCols);
	for (var x=0;x<visibleCols;x++)
	{
		this.parent.table.getElementsByTagName('colgroup')[0].getElementsByTagName('col')[x].style.width=aColWidth+'px';
	}
}

		
/**
* Get a column object by id attribute
* @param {string} id id
* @return {column} column object
*/
function columns_getColByID(id)
{
	for (var x=0;x<this.item.length;x++)
		if (this.item[x].element.id==id)
			return this.item[x];
	
	return null;
}

/**
* Return an array of column objects which have invisible status
* @return {array of column} Array of column with invisible status
*/
function columns_listInvisible ()
{
	var hiddenColumns=new Array();
	for (var x=0;x<this.item.length;x++)
	{
		if (this.item[x].visible==false) 
			hiddenColumns[hiddenColumns.length]=this.item[x];
	}
	return hiddenColumns;
}

/**
* Check if there are hidden columns
* @return {boolean} true=there are hidden columns
*/
function columns_hidden ()
{
	var status=false;
	for (var x=0;x<this.item.length;x++)
	{
		if (this.item[x].visible==false) 
			status=true;
	}
	return status;
}

/**
* Show all columns
*/
function columns_show ()
{
	var invisible=this.listInvisible();
	var x;
	for (var x=0;x<invisible.length;x++)
	{
		invisible[x].showColumn();
	}
}

/**
* Write column order cookie
*/
function columns_setOrder ()
{
	var colOrder='';
	rows=this.parent.table.getElementsByTagName('TBODY')[0].getElementsByTagName('TR');
	var cols=rows[0].getElementsByTagName('TH');
	
	for (var x=0;x<cols.length;x++)
	{
		colOrder+=this.getColByID(cols[x].id).fieldName;
		if (x<(cols.length-1)) 
			colOrder+=':';
	}
	
	document.cookie= tableClass+"."+"colOrder="+colOrder;
}

/**
* Reorder columns
* @param {int} ncol start column
* @param {int} tocol end column
*/
function columns_recol(ncol, tocol) {
	var itocol   = parseInt(tocol) ;
	var incol    = parseInt(ncol)  ;
	
	if (itocol==incol) 
		return 0;
	
	var oTable    = this.parent.table;
	var nbRows    = oTable.getElementsByTagName('TR').length;
	var cols;
	//var firstNode = oTable.children(0); // the first node will be reference.
	for (var i=1; i<nbRows+1; i++) {
		var curNode   = oTable.getElementsByTagName('TR')[i-1];
	 	if (i==1) 
	 		cols=curNode.getElementsByTagName('TH');
	 	else
	 		cols=curNode.getElementsByTagName('TD');
	 	
		 var numTDs=cols.length;
		
		 var fstTDNode = cols[itocol];
		 var curTDNode = cols[incol];
		 
		 if(itocol<incol)  
		 	curNode.insertBefore(curTDNode, fstTDNode);
		 else {
		 	var fstTDNode = cols[itocol];
		    var curTDNode = cols[incol];
		    DOMNode_insertAfter(curTDNode, fstTDNode);
		 }    
	 
	}
	this.setOrder(); 		
}

/**
* @class Representation of table
* @param {table} tableName Table element
*/
function table (tableName)
{
	/**
	* Reference to HTML table element
	* @type tableElement
	*/
	this.table=document.getElementById(tableName);
	/**
	* Reference to tableRow element
	* @type tableRow
	*/
	this.rows=this.table.getElementsByTagName('TBODY')[0].getElementsByTagName('TR');
	/**
	* @type columns
	*/
	this.columns=new columns(this.rows[0],this);
}
	
//Cookie Functions

function getCookieVal (offset) {
	var endstr = document.cookie.indexOf (';', offset);
	if (endstr == -1)
		endstr = document.cookie.length;
	return unescape(document.cookie.substring(offset, endstr));
}

/**
 * Gets the value of the specified cookie.
 * @param {string} name  Name of the desired cookie.
 * @return {string}  Returns a string containing value of specified cookie, or null if cookie does not exist.
 */
function getCookie (name) {
	var arg = name + '=';
	var alen = arg.length;
	var clen = document.cookie.length;
	var i = 0;
	while (i < clen) {
		var j = i + alen;
		if (document.cookie.substring(i, j) == arg)
			return getCookieVal (j);
		i = document.cookie.indexOf(' ', i) + 1;
		if (i == 0) break;
	}
	return null;
}

/**
 * Mouse Down Event handler
*/
function mouseDown(e)
{
	if (isIE()) 
		e=window.event;

	var el = (e.target) ? e.target : e.srcElement;
	//window.alert(el.tagName);
	var x = (e.target) ? e.pageX : (window.event.clientX)+document.body.scrollLeft;
	//X è la posizione x assoluta
	checkHeaderResize(el, x);
	if ((activeHeaders) && (el.tagName == 'TH') && JScolresize) {
		/*
		 * Cursor is near the edge of a header cell and the
		 * left mouse button is down, start resize operation.
		 */
		activeHeaders[0] = true;
		//if (this.bodyColResize) { this._sizeBodyAccordingToHeader(); }
	}
	else if (el.tagName == 'TH' && JScolmove) {
		moveColumn=el;
		originalOnSelect=document.onselectstart;
		document.onselectstart=new Function ("return false");
		return false;
	}
};

/**
 * Mouse UP Event handler
*/
function mouseUp (e) {
	var el = (e.target) ? e.target : e.srcElement;
	var x = (e.target) ? e.pageX : (window.event.clientX)+document.body.scrollLeft;
	var y = (e.target) ? e.pageY : (window.event.clientY)+document.body.scrollTop;

	if (activeHeaders) {
		if (activeHeaders[0]) {
			//Scriviamo i cookies
			myTable.columns.item[activeHeaders[1].cellIndex].setWidth(myTable.columns.item[activeHeaders[1].cellIndex].element.style.width);
			checkHeaderResize(el, x);
		}
		activeHeaders = null;
	}
	
	//Click su colonna e mouse mosso= drag
	if (moveColumn && dragHeaderDiv) {
		efpi(document.body,x,y,'TH');
		document.body.removeChild(dragHeaderDiv);
		dragHeaderDiv=null;
		
		if (topElementByTag != null)
		{
			myTable.columns.recol(getCellIndex(moveColumn),getCellIndex(topElementByTag));
			topElementByTag=null;
		}
			
		moveColumn = null;
		document.onselectstart=originalOnSelect;
		if (isKonqueror() || isSafari())
			myTable.columns.resetSize();
	}
	else if (moveColumn) //Click su colonna
	{
		moveColumn = null;
		document.onselectstart=originalOnSelect;
	}
}

/**
 * Mouse Move Event handler
*/
function mouseMove(e)
{
	var el = (e.target) ? e.target : e.srcElement;
	//window.alert(el.tagName);
	var x = (e.target) ? e.pageX : (window.event.clientX)+document.body.scrollLeft;
	if ((activeHeaders) && (activeHeaders[0])) {
		/*
		 * User is resizing a column, determine and set new size
		 * based on the original size and the difference between
		 * the current mouse position and the one that was recorded
		 * once the resize operation was started.
		 */
		var w = activeHeaders[2] + x - activeHeaders[3];
		var tw = ((w - activeHeaders[2]) + activeHeaders[4]) + 1;
		myTable.table.style.width = tw + 'px';
		if (w > 5) {
			activeHeaders[1].style.width = w + 'px';
			myTable.table.style.width = tw + 'px';
			
			var colIndx=myTable.columns.getColByID(activeHeaders[1].id).getRelativeIndx();
			myTable.table.getElementsByTagName('colgroup')[0].getElementsByTagName('col')[colIndx].style.width = w + 'px';
		}	
	}
	else if (moveColumn)
	{
		var y = (e.target) ? e.pageY : (window.event.clientY)+document.body.scrollTop;
			
		if(dragHeaderDiv) 
		{	
			dragHeaderDiv.style.left = x+'px';
		}
		else
		{	
			var debug=moveColumn;
			dragHeaderDiv = document.createElement("DIV"); 
			dragHeaderDiv.id = "dragHeaderDiv";
			dragHeaderDiv.className = "thDrag";
			dragHeaderDiv.style.position = "absolute";
			dragHeaderDiv.style.left = x+'px';
			dragHeaderDiv.style.top = getTopPos(moveColumn)+'px';
			
			dragHeaderDiv.style.width = moveColumn.offsetWidth+'px';
			dragHeaderDiv.style.height = moveColumn.offsetHeight+'px';
			dragHeaderDiv.innerHTML=moveColumn.innerHTML;
			dragHeaderDiv.style.zIndex = 10000;
			dragHeaderDiv.style.MozOpacity = 0.7;
			dragHeaderDiv.style.filter = "alpha(opacity=70)";
			dragHeaderDiv.style.backgroundColor ="white";
			document.body.appendChild(dragHeaderDiv);
		}
	}
	else if (el.tagName == 'TH') {
		/*
		 * The cursor is on top of a header cell, check if it's near the edge,
		 * and in that case set the mouse cursor to 'e-resize'.
		 */
		checkHeaderResize(el, x);
	}
};

	
/**
* Checks if the mouse cursor is near the edge of a header
* cell, in that case the cursor is set to 'e-resize' and
* the _activeHeaders collection is created containing a
* references to the active header cell, the current mouse
* position and the cells original width.
* @param {htmlElement} el
* @param {int} x X coordinate
*/
function checkHeaderResize(el, x) {
	/*
	 * Checks if the mouse cursor is near the edge of a header
	 * cell, in that case the cursor is set to 'e-resize' and
	 * the _activeHeaders collection is created containing a
	 * references to the active header cell, the current mouse
	 * position and the cells original width.
	 */
	if (el.tagName != 'TH' || !JScolresize) 
		return;
	//window.alert('ok');
	if (el.tagName == 'IMG') { el = el.parentNode; }
	//var prev = el.previousSibling;
	window.status=el.id;
	var prev = getPreviosSiblingByTagName(el,'TH')
	var next = el.nextSibling;
	var left = getLeftPos(el);
	var right = left + el.offsetWidth;
	var l = (x - 5) - left;
	var r = right - x;
	if ((l < 5) && (prev)) {
		//window.alert('ok');
		el.style.cursor = 'e-resize'; 
		activeHeaders = [false, prev, prev.offsetWidth - 5, x, myTable.table.offsetWidth];
	}
	else if (r < 5) {
		el.style.cursor = 'e-resize';
		activeHeaders = [false, el, el.offsetWidth - 5, x, myTable.table.offsetWidth];
	}
	else if (activeHeaders) {
		activeHeaders = null;
		el.style.cursor = 'default';
		el.style.backgroundColor = '';
	}	
};

/**
* Function to get the absolute left position of an HTML element
* @param {HTMLelement} _el
* @return {int} absolute left position
*/
function getLeftPos(_el) {
	var x = 0;
	for (var el = _el; el; el = el.offsetParent) {
		x += el.offsetLeft;
	}
	return x;
}

/**
* Function to get the absolute top position of an HTML element
* @param {HTMLelement} _el
* @return {int} absolute top position
*/
function getTopPos(_el) {
	var y= 0;
	for (var el = _el; el; el = el.offsetParent) {
		y += el.offsetTop;
	}
	return y;
}

/**
* Return the previous sibling that has the specified tagName
* @param {HTMLelement} el
* @param {string} tagName tagName to find
* @return {HTMLelment} sibling that has the specified tagName
*/
function getPreviosSiblingByTagName(el,tagName) {
	var sib=el.previousSibling;
	while (sib) {
		if ((sib.tagName==tagName) && (sib.style.display!='none')) return sib;
		sib=sib.previousSibling;
	}
	return null;
}

/**
* Return the parent HTML element that has the specified tagName
* @param {HTMLelement} el
* @param {string} tagName tagName to find
* @return {HTMLelment} the parent HTML element that has the specified tagName
*/
function getParentByTagName(el,tagName) {
	var par=el.parentNode;
	while (par) {
		if (par.tagName==tagName) return par;
		par=par.parentNode;
	}
	return null;
}

/**
* This function return the HTML element at coordinate x,y that has the specified tagname.
* It sets two global variables topElement and topElementByTag
* @param {HTMLelement} from The starting element of the search, generally DOCUMENT.BODY
* @param {int} x X coordinate
* @param {int} x Y coordinate
* @param {string} tag tagName
*/
function efpi(from, x,y, tag)
{
	var n,i;

	for(i=0;i<from.childNodes.length;i++)
	{
		n=from.childNodes[i];
				
		//window.alert("non dentro:"+n.tagName);

		//window.alert(Node.TEXT_NODE);
		//Node.TEXT_NODE=3
		//Node.COMMENT=8
		if( n.nodeType != 3 && n.nodeType != 8 && n.style.display != 'none' )
		{
			
			var sx = getLeftPos(n); 
			var sy = getTopPos(n);
			
			
			
			//offsetWidth dei tbody=0 in opera
			if ((isOpera() || isKonqueror() || isSafari()) && n.tagName=='TBODY')
			{
				var ex = sx + n.parentNode.offsetWidth; 
				var ey = sy + n.parentNode.offsetHeight;
			}
			else
			{
				var ex = sx + n.offsetWidth; 
				var ey = sy + n.offsetHeight;
			}

			if ((isKonqueror() || isSafari()) &&n.tagName=='TR')
			{
				var ex = sx + n.parentNode.parentNode.offsetWidth; 
				var ey = sy + n.parentNode.parentNode.offsetHeight;
			}
				//window.alert(sx+"."+sy+"."+ex+"."+ey);
				
			if ( x > sx && x < ex && y > sy && y < ey)
			{
				//window.alert(n.tagName);
				topElement=n;
				if (n.tagName==tag) 
				{
					topElementByTag=n;
				}
				efpi(n,x,y,tag);
			}
		}
	}
}

function DOMNode_insertAfter(newChild,refChild)
//Post condition: if childNodes[n] is refChild, than childNodes[n+1] is newChild.
{
  var parentx=refChild.parentNode;
  if(parentx.lastChild==refChild) { return parentx.appendChild(newChild);}
  else {return parentx.insertBefore(newChild,refChild.nextSibling);}
}


/** 
* This function correct the different behaviour between IE and Firefox
* Firefox .cellindex always return the absolute index of a cell, instead IE only consider the visible cells
* ATTENTION: getCellIndex doesn't work if you try the index of a hidden cell
* @param {tableCell} el the table cell to get the index from
* @return {int} the absolute cell index
*/
function getCellIndex(el)
{
	if (isIE()) {
		var table=getParentByTagName(el,'TABLE');
		var temp=getAbsoluteIndex(table.rows(0),el.cellIndex);	
		return temp;
	}
	
	if (isKonqueror() || isSafari())
	{
		var temp=getKCellIndex(el);
		return temp;
	}

	//Other browsers
	return el.cellIndex;
}

/** 
* This function return the CellIndex for konqueror based browsers
*
* @param {tableCell} el the table cell to get the index from
* @return {int} the absolute cell index
*/
function getKCellIndex(el)
{
	var count=0;
	while (el.previousSibling)
	{
		count++;
		el=el.previousSibling;
	}
	return count;
}
/**
* IE specific function to get the absolute cell index of a tableCell
* @param {tr} t An HTML table row
* @param {int} relIndex The relative cell index returned by .cellIndex in IE
* @return {int} The absolute cell index
*/
function getAbsoluteIndex(t,relIndex)
{
	var countnotvisible=0;
	var countvisible=0;
	for (var i=0;i<t.cells.length;i++) {
		var cell=t.cells(i);
		if (cell.style.display=='none') countnotvisible++; else countvisible++;
		if (countvisible>relIndex) 
		{
			return i;
		}
	}
	return i;
} 

/*
* Function to get the ID of a TH element starting from a TD element.
* @param {tableCell} el A TH or TD element
* @return {string} The ID of the TH element
*/
function getColID(el) 
{
	if (el.tagName=='TH')
		return el.id;
	else
		var table=getParentByTagName(el,'TABLE');
		var realIndex=getCellIndex(el);
		return table.getElementsByTagName('TBODY')[0].getElementsByTagName('TR')[0].getElementsByTagName('TH')[realIndex].id;
}

//Menu parameters configuration
allExceptFilter = new Array(							"BUTTON.*", 
														"IMG.*", 
														"INPUT.*", 
														"OBJECT.*", 
														"OPTION.*", 
														"SELECT.*", 
														"TEXTAREA.*");
/*
* Tranlation helper function
* @param (string) stringa original string
* @return {string} translated string
*/
function getText(stringa)
{
	if (typeof (getTextStrings) == "undefined")
		return stringa;
	var translated= getTextStrings[stringa] != '' ? getTextStrings[stringa] : stringa;
	return translated;
}
