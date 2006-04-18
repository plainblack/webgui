function updateFormFields() {
//alert(fieldCombo);
	var fieldTypeList = document.getElementById('SQLFormFieldType');

	if (fieldTypeList.selectedIndex < 0) {
		fieldTypeList.selectedIndex = 0;
	}

	var re = fieldTypeList.options[fieldTypeList.selectedIndex].text.match(/^[^\/]+\/([^\/]+)$/);
	
	var fieldType = RegExp.$1;

	var fieldProperties = fieldTypes[fieldType];

	// Hanlde sign field
	if (fieldProperties['hasSign'] == 1) {
		enableField('SQLFormSigned');
	} else {
		disableField('SQLFormSigned');
	}

	// Handle autoincrement field
	if (fieldProperties['canAutoIncrement'] == 1) {
		enableField('SQLFormAutoIncrement');
	} else {
		disableField('SQLFormAutoIncrement');
	}

	// Handle regex field
	if (
		(fieldProperties['canAutoIncrement'] && document.getElementById('autoIncrementField')) || 
		(document.getElementById('SQLFormReadOnly') == 1)
	) {
		disableField('SQLFormRegex');
	} else {
		enableField('SQLFormRegex');
	}

	// Handle Field constraints section
	if (document.getElementById('SQLFormFieldConstraintType').value > 0) {
		enableField('SQLFormFieldConstraintTarget');
		if (document.getElementById('SQLFormFieldConstraintTarget').value == 'value') {
			enableField('SQLFormFieldConstraintValue');
		} else {
			disableField('SQLFormFieldConstraintValue');
		}
	} else {
		disableField('SQLFormFieldConstraintTarget');
		disableField('SQLFormFieldConstraintValue');
	}
}

function enableField(id) {
	var e = document.getElementById(id);

	if (e) {
		e.disabled = false;
		e.style.display = '';
	}

	// also hide row if applicable
	var tr = document.getElementsByTagName("tr");
	if (tr == null) return;
	for (i=0; i < tr.length; i++) {
   		if(tr[i].className == id+'Row') {
   			tr[i].style.display = '';
		}
	}

//	document.getElementById(id+'row').style.display = '';
}

function disableField(id) {
	var e = document.getElementById(id);

	if (e) {
		e.disabled = true;
		e.style.display = 'none';
	}

	var tr = document.getElementsByTagName("tr");
	if (tr == null) return;
	for (i=0; i < tr.length; i++) {
  		if(tr[i].className == id+'Row') {
   			tr[i].style.display = 'none';
		}
	}

//	document.getElementById(id+'row').style.display = 'none';
}

