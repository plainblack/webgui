var a=new Array(22);

function getFormNum (formName) {
	var formNum =-1;
	for (i=0;i<document.forms.length;i++){
		tempForm = document.forms[i];
		if (formName == tempForm) {
			formNum = i;
			break;
		}
	}
	return formNum;
}

var catsIndex = -1;
var itemsIndex;

function newCat(){
	catsIndex++;
	a[catsIndex] = new Array();
	itemsIndex = 0;
}

function O(txt,value) {
	a[catsIndex][itemsIndex]=new myOptions(txt,value);
	itemsIndex++;
}

function myOptions(text,value){
	this.text = text;
	this.value = value;
}

function relate(list1,list2) {
        var j = list1.selectedIndex;
		for(i=list2.options.length-1;i>0;i--) list2.options[i] = null; // null out in reverse order (bug workarnd)
		for(i=0;i<a[j].length;i++){
			list2.options[i] = new Option(a[j][i].text,a[j][i].value); 
		}
		list2.options[0].selected = true;
}



function IEsetup(){
	if(!document.all) return;
	IE5 = navigator.appVersion.indexOf("5.")!=-1;
	if(!IE5) {
		for (i=0;i<document.forms.length;i++) {
			document.forms[i].reset();
		}
	}
}

window.onload = IEsetup;
