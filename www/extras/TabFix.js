
function TabFix_keyDown(e) {    
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;    
    obj =dom? e.target : e.srcElement
    
    if (e.keyCode == 9 && obj.type && obj.type=="textarea") {
		topScroll = obj.scrollTop;
		leftScroll = obj.scrollLeft;
		var position = TabFix_insertAtCursor(obj,'\t');

		obj.focus();
		obj.selectionStart=position + 1 ;		
		obj.selectionEnd=position + 1;		
		obj.scrollTop = topScroll;
		obj.scrollLeft = leftScroll;
		return false;
    }
    return true;
}

function TabFix_keyPress(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;    
    if (e.keyCode == 9) {
	return false;
    }
    return true;
}

function TabFix_insertAtCursor(myField, myValue) {
	//IE 
	if (document.selection) {
		myField.focus();
		sel = document.selection.createRange();
		sel.text = myValue;
	}
	//MOZILLA
	else if (myField.selectionStart || myField.selectionStart == '0') {
		var startPos = myField.selectionStart;
		var endPos = myField.selectionEnd;
		myField.value = myField.value.substring(0, startPos) + myValue + myField.value.substring(endPos, myField.value.length);
		return startPos;
	} else {
		myField.value += myValue;
	}
	return 0;
}

/*
We'd uncomment the following lines if we wanted
to apply this to all text areas, which we don't

document.onkeypress=TabFix_keyPress;
document.onkeydown=TabFix_keyDown;
*/
