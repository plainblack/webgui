//----------------------------------------------------------------------
function deleteState (e,entryId) {
	//Do nothing with e
	paint('delete',entryId);
}


//----------------------------------------------------------------------
function addState () {
	if(document.getElementById('stateChooser_formId').value == "Select State") {
		alert("You have not selected a state"); //optional
		return;
	}
	if(document.getElementById('taxRate_formId').value == "") {
		alert("You have not entered a tax rate"); //optional
		return;
	}
	paint('add');
}


//----------------------------------------------------------------------
function paint (submitType,entryId) {
	AjaxRequest.post({
		'op':'salesTaxTable',
		'addDelete':submitType,
		'taxRate':document.getElementById('taxRate_formId').value,
		'entryId':entryId,
		'addStateId':document.getElementById('stateChooser_formId').value,
		'onSuccess':function(req){
			document.getElementById('salesTaxFormDiv').innerHTML = req.responseText;
		}
	});
}




