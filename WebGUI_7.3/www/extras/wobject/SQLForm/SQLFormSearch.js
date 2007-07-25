function switchField(id, switchOn) {

	e = document.getElementById(id);
	if (!e) {
		alert("Not a valid id: ["+id+"]");
	}

	if (switchOn) {
		document.getElementById(id).disabled = false;
		document.getElementById(id).style.display = '';
	} else {
		document.getElementById(id).disabled = true;
		document.getElementById(id).style.display = 'none';
	}
}

function switchListField(conditional, id) {
	if (conditional == '') {
		switchField(id+'-1', false);
		switchField(id+'-2', false);
	} else {
		if (conditional == 100 || conditional == 101) {
			switchField(id+'-1', true);
			switchField(id+'-2', false);
		} else {
			switchField(id+'-1', false);
			switchField(id+'-2', true);
		}
	}
}

function switchNumberField(conditional, id) {
	if (conditional == '') {
		switchField(id+'-1', false);
		switchField(id+'-2', false);
	} else {
		if (conditional == 10) {
			switchField(id+'-1', true);
			switchField(id+'-2', true);
		} else {
			switchField(id+'-1', true);
			switchField(id+'-2', false);
		}
	}
}

function switchTemporalField(conditional, id) {
	if (conditional == '') {
		switchField(id+'-1', false);
		switchField(id+'-2', false);
	} else {
		if (conditional == 10) {
			switchField(id+'-1', true);
			switchField(id+'-2', true);
		} else {
			switchField(id+'-1', true);
			switchField(id+'-2', false);
		}
	}
}	

function switchTextField(conditional, id) {
	if (conditional == '') {
		switchField(id+'-1', false);
	} else {
		switchField(id+'-1', true);
	}
}

