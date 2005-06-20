/* 
	WebGUI Asset Manager Table
	based upon the sortable table by Matt Kruse
	http://www.mattkruse.com/
*/

var sort_object;
var sort_column;
var reverse=0;

// Constructor for AssetManager object
function AssetManager() {
	// Properties
	this.name = 'assetManager';
	this.sortcolumn="";
	this.dosort=true;
	this.tablecontainsforms=false;
	// Methods
	this.AddLine = AssetManager_AddLine;
	this.AddColumn = AssetManager_AddColumn;
	this.AddButton = AssetManager_AddButton;
	this.Write = AssetManager_Write;
	this.SortRows = AssetManager_SortRows;
	this.AddLineSortData = AssetManager_AddLineSortData;
	// Structure
	this.Columns = new Array();
	this.Lines = new Array();
	this.Buttons = new Array();
	}
// Add a line to the grid
function AssetManager_AddLine() {
	var index = this.Lines.length;
	this.Lines[index] = new Array();
	for (var i=0; i<arguments.length; i++) {
		this.Lines[index][i] = new Object();
		this.Lines[index][i].text = arguments[i];
		this.Lines[index][i].data = arguments[i];
		}
	}

// Add a button to the form
function AssetManager_AddButton(label,func) {
	var index = this.Buttons.length;
	this.Buttons[index] = new Object();
	this.Buttons[index].label = label;
	this.Buttons[index].func = func;
}

// Define sorting data for the last line added
function AssetManager_AddLineSortData() {
	var index = this.Lines.length-1;
	for (var i=0; i<arguments.length; i++) {
		if (arguments[i] != '') {
			this.Lines[index][i].data = arguments[i];
			}
		}
	}

// Add a column definition to the table
// Arguments:
//   name = name of the column
//   td   = any arguments to go into the <TD> tag for this column (ex: BGCOLOR="red")
//   align= Alignment of data in cells
//   type = type of data in this column (numeric, money, etc) - default alphanumeric
function AssetManager_AddColumn(name,td,align,type) {
	var index = this.Columns.length;
	this.Columns[index] = new Object;
	this.Columns[index].name = name;
	this.Columns[index].td   = td;
	this.Columns[index].align=align;
	this.Columns[index].type = type;
	if (type == "form") {
		 this.tablecontainsforms=true; 
		}
	}
// Print out the table
function AssetManager_Write() {
	var open_div = "";
	var close_div =	"";
	document.write('<form method="post" name="assetManagerForm"><input type="hidden" name="func" />');
	document.write('<table class="am-table">');
	document.write('<thead><tr class="am-headers">');
	for (var i=0; i<this.Columns.length; i++) {
		document.write('<td class="am-header"><a class="sort" href="javascript:AssetManager_SortRows(assetManager,'+i+');">'+this.Columns[i].name+'</a></td>');
	}
	document.write('</tr><tbody>');
	for (var i=0; i<this.Lines.length; i++) {
		document.write('<tr class="am-row">');
		for (var j=0; j<this.Columns.length; j++) {
			var div_name = "d"+this.name+"-"+i+"-"+j;

				if (this.Columns[j].align != '') {
					var align = ' class="am-'+this.Columns[j].align+'"';
					}
				else {
					var align = "";
					}
				open_div = "<div id=\""+div_name+"\" "+align+">";
				close_div= "</div>";
			
			document.write("<td "+this.Columns[j].td+">"+open_div+this.Lines[i][j].text+close_div+"</td>");
		}
		document.write("</tr>");
	}
	document.write('</tbody></table>');
	for (var j=0; j<this.Buttons.length; j++) {
		document.write('<input type="button" onclick="'+this.Buttons[j].func+'" value="'+this.Buttons[j].label+'" />');
	}
	document.write('</form>');
}
	
// Sort the table and re-write the results to the existing table
function AssetManager_SortRows(table,column) {
	sort_object = table;
	if (!sort_object.dosort) { return; }
	if (sort_column == column) { reverse=1-reverse; }
	else { reverse=0; }
	sort_column = column;

	// Save all form column contents into a temporary object
	// This is a nasty hack to keep the current values of form elements intact
	if (table.tablecontainsforms) {
		var iname="1";
		var tempcolumns = new Object();
		var tempcheckboxes = new Object();
		for (var i=0; i<table.Lines.length; i++) {
			for (var j=0; j<table.Columns.length; j++) {
				if(table.Columns[j].type == "form") {
					var cell_name = "d"+table.name+"-"+i+"-"+j;
					tempcolumns[iname] = document.getElementById(cell_name).innerHTML;
					// Okay, this is an even nastier hack...
					// Other temporary arrays could be created to hold other attribute states.
					var inputboxes = document.getElementById(cell_name).getElementsByTagName('input');
					for(k = 0; k < inputboxes.length; k++) {
						tempcheckboxes[iname] = inputboxes[k].checked;
						}
					table.Lines[i][j].text = iname;
					iname++;
					}
				}
			}
		}
	
	if (table.Columns[column].type == "numeric") {
		// Sort by Float
		table.Lines.sort(	function by_name(a,b) {
									if (parseFloat(a[column].data) < parseFloat(b[column].data) ) { return -1; }
									if (parseFloat(a[column].data) > parseFloat(b[column].data) ) { return 1; }
									return 0;
									}
								);
		}
	else if (table.Columns[column].type == "money") {
		// Sort by Money
		table.Lines.sort(	function by_name(a,b) {
									if (parseFloat(a[column].data.substring(1)) < parseFloat(b[column].data.substring(1)) ) { return -1; }
									if (parseFloat(a[column].data.substring(1)) > parseFloat(b[column].data.substring(1)) ) { return 1; }
									return 0;
									}
								);
		}
	else if (table.Columns[column].type == "date") {
		// Sort by Date
		table.Lines.sort(	function by_name(a,b) {
									if (Date.parse(a[column].data) < Date.parse(b[column].data) ) { return -1; }
									if (Date.parse(a[column].data) > Date.parse(b[column].data) ) { return 1; }
									return 0;
									}
								);
		}

	else {
		// Sort by alphanumeric
		table.Lines.sort(	function by_name(a,b) {
									if (a[column].data+"" < b[column].data+"") { return -1; }
									if (a[column].data+"" > b[column].data+"") { return 1; }
									return 0;
									}
								);
		}

	if (reverse) { table.Lines.reverse(); }
	for (var i=0; i<table.Lines.length; i++) {
		for (var j=0; j<table.Columns.length; j++) {
			var cell_name = "d"+table.name+"-"+i+"-"+j;
	
				if(table.Columns[j].type == "form") {
					var iname = table.Lines[i][j].text;
					document.getElementById(cell_name).innerHTML = tempcolumns[iname];
					var inputboxes = document.getElementById(cell_name).getElementsByTagName('input');
					for(k = 0; k < inputboxes.length; k++) {
						inputboxes[k].checked = tempcheckboxes[iname];
						}
					}
				else {
					document.getElementById(cell_name).innerHTML = table.Lines[i][j].text;
					}
	
			}
		}
	}
