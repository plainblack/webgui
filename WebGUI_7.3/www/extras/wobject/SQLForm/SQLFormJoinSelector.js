// databaseMap is use to store the available db's
var databaseMap = new Object;

// tableMap is used to cache array of table options. This could lessen the 
// number of requests to the server.
var tableMap = new Object;

// columnMap will hold the columnnames (including db and tablename) for each 
// joinselector
var columnMap = new Object;

var resultList1, resultList2 = null

function initDatabaseMap(databases) {
	databaseMap = databases;
}

function setResultFields(field1, field2) {
	resultList1 = field1;
	resultList2 = field2;
}

//-----------------------------------------------------------------------------
function setAvailableDatabaseOptions(zup) {
	zup.options[zup.options.length] = new Option('Please select a database', '');
	for (var i = 0; i < databaseMap.length; i++) {
		zup.options[zup.options.length] = new Option(databaseMap[i].key, databaseMap[i].value);
	}
}

// Processes <Option><Key>Key</Key><Value>Value</Value></Option> XML
//-----------------------------------------------------------------------------
function processAjaxXml(req, selectList, cache, prepend) {
	var options = req.responseXML.getElementsByTagName("Option");

	if (!prepend) {
		prepend = '';
	}

	for (var i = 0; i < options.length; i++) {
		var optionKey = prepend + options[i].getElementsByTagName("Key")[0].firstChild.nodeValue;
		var optionValue = prepend + options[i].getElementsByTagName("Value")[0].firstChild.nodeValue;

		if (cache) {
			cache[cache.length] = {
				key	: optionKey,
				value	: optionValue
			};	
		}
		if (selectList) {
			selectList.options[selectList.options.length] = new Option(optionKey, optionValue); //currentOption;
		}
	}
}

//-----------------------------------------------------------------------------
function addJoinButtonRow(tableId, rowNumber) {
	table = document.getElementById(tableId);

	//rowNumber = table.rows.length - 1;
	// Create join button
	tr = table.insertRow(table.rows.length);
	tr.id = 'joinButtonRow';
	td = tr.insertCell(tr.cells.length);
	td.innerHTML = '<input type="button" id="joinButton'+rowNumber+'" value="Join with another table" />';
	td.colSpan = 7;
	document.getElementById('joinButton'+rowNumber).onclick = function() {
		hideElement('joinButton'+rowNumber);
		table.deleteRow(table.rows.length - 1);	// Delete row with button
		addSelectorRow(tableId);
	}
	hideElement('joinButton'+rowNumber);
}

//-----------------------------------------------------------------------------
function deleteRows(tableId, stopAtRow) {
	table = document.getElementById(tableId);

	for (var i = table.rows.length; i > stopAtRow; i--) {
		table.deleteRow(table.rows.length - 1);
	}
	
	addJoinButtonRow(tableId, stopAtRow);
}

//-----------------------------------------------------------------------------
function hideElement(elementId) {
	element = document.getElementById(elementId);
	
	if (element) {
		element.style.display = 'none';
		element.disabled = true;
	}

}

//-----------------------------------------------------------------------------
function unhideElement(elementId) {
	element = document.getElementById(elementId);
	
	if (element) {
		element.style.display = '';
		element.disabled = false;
	}

}

//-----------------------------------------------------------------------------
function hideJoinConstraints(rowNumber) {
	hideElement('on'+rowNumber);
	hideElement('joinFunction'+rowNumber);
	hideElement('joinOnA'+rowNumber);
	hideElement('joinOnB'+rowNumber);
}

//-----------------------------------------------------------------------------
function unhideJoinConstraints(rowNumber) {
	unhideElement('on'+rowNumber);
	unhideElement('joinFunction'+rowNumber);
	unhideElement('joinOnA'+rowNumber);
	unhideElement('joinOnB'+rowNumber);
}

//-----------------------------------------------------------------------------
function addSelectorRow(tableId, formDatabase, formTable, formJoinOnA, formJoinOnB, formJoinFunction) {
	var table = document.getElementById(tableId);
	var tr, selectName, tds = '';

	if (!table) {
		alert('Fatal error: tableId does not exist.');
	}

	var rowNumber = table.rows.length + 1;

	// Insert a row
	tr = table.insertRow(table.rows.length);

	// Table label
	tr.insertCell(tr.cells.length).innerHTML = '<b>table'+rowNumber+'</b>';
	
	// Create database selector
	selectName = 'database'+rowNumber;
	td = tr.insertCell(tr.cells.length);
	td.innerHTML = '<select id="'+selectName+'" name="'+selectName+'"></select>';
	s = document.getElementById(selectName);
	setAvailableDatabaseOptions(s);
	s.onchange = function() {
		setTablesInSelectList(rowNumber, s.value);
		deleteRows(tableId, rowNumber);
		hideJoinConstraints(rowNumber);
		unhideElement('table'+rowNumber);
		toggleJoinButton(rowNumber);
	};
	if (formDatabase) {
		s.value = formDatabase;
	}

	// Create table selector
	selectName = 'table'+rowNumber;
	td = tr.insertCell(tr.cells.length);
	td.innerHTML = '<select id="'+selectName+'" name="'+selectName+'"></select>';
	document.getElementById(selectName).onchange = function() {
		setJoinOnA(rowNumber);
		setJoinOnB(rowNumber);
		updateFields(rowNumber);
		deleteRows(tableId, rowNumber);
		if (rowNumber > 1) {
			unhideJoinConstraints(rowNumber);
		}
		toggleJoinButton(rowNumber);
	}
	if (formDatabase) {
		setTablesInSelectList(rowNumber, formDatabase);
		document.getElementById(selectName).value = formTable;
	} else {
		hideElement(selectName);
	}
		
	// Create on word
	td = tr.insertCell(tr.cells.length);
	td.innerHTML = ' on ';
	td.id = 'on'+rowNumber;

	// Create first join selector
	selectName = 'joinOnA'+rowNumber;
	td = tr.insertCell(tr.cells.length);
	td.innerHTML = '<select id="'+selectName+'" name="'+selectName+'"></select>';
	document.getElementById(selectName).onchange = function() {
		toggleJoinButton(rowNumber);
	}

	// Create joinFunction thingy
	selectName = 'joinFunction'+rowNumber;
	td = tr.insertCell(tr.cells.length);
	td.innerHTML = '<select id="'+selectName+'" name="'+selectName+'"></select>';
	document.getElementById(selectName).options[0] = new Option('Intersect on', 'intersection');
	document.getElementById(selectName).options[1] = new Option('Difference on', 'difference');

	// Create second join selector
	selectName = 'joinOnB'+rowNumber;
	td = tr.insertCell(tr.cells.length);
	td.innerHTML = '<select id="'+selectName+'" name="'+selectName+'"></select>';
	document.getElementById(selectName).onchange = function() {
		toggleJoinButton(rowNumber);
	}


	if (formDatabase && formTable) {
		setJoinOnA(rowNumber, formJoinOnA, formDatabase, formTable);
		setJoinOnB(rowNumber);
		document.getElementById('joinOnA'+rowNumber).value = formJoinOnA;
		document.getElementById('joinOnB'+rowNumber).value = formJoinOnB;
		document.getElementById('joinFunction'+rowNumber).value = formJoinFunction;
	} else {
		// Hide the join constraint controls
		hideJoinConstraints(rowNumber);
	}
	if (rowNumber == 1) {
		hideJoinConstraints(rowNumber);
	}

	// Finally add a row containing a hidden 'join with' button
	if (!(formDatabase || formTable || formJoinOnA || formJoinOnB)) {
		addJoinButtonRow(tableId, rowNumber);
	}
}

//-----------------------------------------------------------------------------
function setJoinOnA(rowNumber) {
	var databaseName = document.getElementById('database'+rowNumber).value;
	var tableName = document.getElementById('table'+rowNumber).value;
	var prepend = 'table' + rowNumber + '.';
	var s = document.getElementById('joinOnA'+rowNumber);
	
	s.length = 0;
	s.options[s.options.length] = new Option('Please select a column', '');
	columnMap[rowNumber] = [ ];

	// Do AJAX request
	var r = new AjaxRequest;
	var params = {
		'parameters'	: { 
			'func'		: 'processAjaxRequest',
			'dbName'	: databaseName,
			'tName'		: tableName
		},
		'async'		: false,  
		'onSuccess'	: function(req) { processAjaxXml(req, s, columnMap[rowNumber], prepend); }
	};

	r.method = 'POST';
	r.handleArguments(params);
	r.process();
	r.onCompleteInternal();
}

//-----------------------------------------------------------------------------
function setJoinOnB(rowNumber) {
	if (rowNumber > 1) {
		var s = document.getElementById('joinOnB'+rowNumber);
		s.length = 0;
		s.options[s.options.length] = new Option('Please select a column', '');
		
		for (var currentRow = 1; currentRow < rowNumber; currentRow++) {
			if (currentRow == 1 || document.getElementById('joinFunction'+currentRow).value != 'difference') {
				for (var i = 0; i < columnMap[currentRow].length; i++) {
					s.options[s.options.length] = new Option(columnMap[currentRow][i].key, columnMap[currentRow][i].value);
				}
			}
		}
	}
}

//-----------------------------------------------------------------------------
function updateFields(rowNumber,value1,value2, ccValue, fcValue) {
	var s1 = document.getElementById(resultList1);
	s1.length = 0;
	s1.options[s1.options.length] = new Option('Please select a column', '');
	
	var s2 = document.getElementById(resultList2);
	s2.length = 0;
	s2.options[s2.options.length] = new Option('Please select a column', '');

	var cc = document.getElementById('joinConstraintColumn');
	cc.length = 0;
	cc.options[cc.options.length] = new Option('Please select a column', '');

	var fc = document.getElementById('SQLFormFieldConstraintTarget');
	fc.length = 0;
	fc.options[fc.options.length] = new Option('Custom value', 'value');

	for (var currentRow = 1; currentRow <= rowNumber; currentRow++) {
		if (columnMap[currentRow] && (currentRow == 1 || document.getElementById('joinFunction'+currentRow).value != 'difference')) {
			for (var i = 0; i < columnMap[currentRow].length; i++) {
				s1.options[s1.options.length] = new Option(columnMap[currentRow][i].key, columnMap[currentRow][i].value);
				s2.options[s2.options.length] = new Option(columnMap[currentRow][i].key, columnMap[currentRow][i].value);
				cc.options[cc.options.length] = new Option(columnMap[currentRow][i].key, columnMap[currentRow][i].value);
				fc.options[fc.options.length] = new Option(columnMap[currentRow][i].key, columnMap[currentRow][i].value);
			}
		}
	}
	if (value1) {
		s1.value = value1;
	}
	if (value2) {
		s2.value = value2;
	}
	if (ccValue) {
		cc.value = ccValue;
	}
	if (fcValue) {
		fc.value = fcValue;
	}
}

//-----------------------------------------------------------------------------
function setTablesInSelectList(rowNumber, database) {
	var s = document.getElementById('table'+rowNumber);

	if (!s) {
		alert('Fatal error: selectList (table'+rowNumber+') does not exist.');
	}

	// Empty select list.
	s.length = 0;
	s.options[s.options.length] = new Option('Please select a table', '');

	// If the tables aren't cached in tableMap yet, fetch them using AJAX.
	if (!tableMap[database]) {
		tableMap[database] = [ ];
		
		// Do AJAX request
		var r = new AjaxRequest;
		var params = {
			'parameters'	: { 
				'func'		: 'processAjaxRequest',
				'dbName'	: database
			},
			'async'			: false,
			'onSuccess'		: function(req) { processAjaxXml(req, s, tableMap[database]); }
		};

		r.method = 'POST';
		r.handleArguments(params);
		r.process();
		// Must run this by hand because in sync-mode the internal event handlers are not called.
		r.onCompleteInternal();
	// If they are cached then put them in the select list.
	} else { 
		for (var i = 0; i < tableMap[database].length; i++) {
			s.options[s.options.length] = new Option(tableMap[database][i].key, tableMap[database][i].value);
		}
	}
}

//-----------------------------------------------------------------------------
function toggleJoinButton(rowNumber) {
	if (document.getElementById('database'+rowNumber) && document.getElementById('table'+rowNumber)) {
	if (
		(document.getElementById('database'+rowNumber).selectedIndex > 0) &&
		(document.getElementById('table'+rowNumber).selectedIndex > 0) &&
		(
			(rowNumber == 1) ||
			(
				(document.getElementById('joinOnA'+rowNumber).selectedIndex > 0) &&
			 	(document.getElementById('joinOnB'+rowNumber).selectedIndex > 0)
			)
		)
	) {
		unhideElement('joinButton'+rowNumber);
	} else {
		hideElement('joinButton'+rowNumber);
	}
	}
}
