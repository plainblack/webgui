
var color;
var formObj;

function boldText(obj) {
	obj.value = obj.value+'<b>'+prompt("Enter the text to bold:", "")+'</b>';
}

function centerText(obj) {
	obj.value = obj.value+'<div align="center">'+prompt("Enter the text to center:", "")+'</div>';
}

function colorText(obj) {
	formObj = obj;
	window.open("/extras/colorPicker.html","colorPicker","width=438,height=258");
}

function copyright(obj) {
        obj.value = obj.value+'&copy;';
}

function email(obj) {
	var email = prompt("Enter the Email address:", "");
	obj.value = obj.value+'<a href="mailto:'+email+'">'+email+'</a>';
}

function getShowMeText() {
	return formObj.value;
}

function imageAdd(obj) {
	obj.value = obj.value+'<img src="'+prompt("Enter the image URL:", "http://somesite.com/image.jpg")+'" border="0">';
}

function italicText(obj) {
	obj.value = obj.value+'<i>'+prompt("Enter the text to italicize:", "")+'</i>';
}

function list(obj) {
	var item;
	obj.value = obj.value+'<ul>';
	obj.value = obj.value+'<li>'+prompt("Enter the first item in the list:", "");
	while (item = prompt("Enter the next item in the list (cancel when done):", "")) {
		obj.value = obj.value+'<li>'+item;
	}
	obj.value = obj.value+'</ul>';
}

function registered(obj) {
        obj.value = obj.value+'&reg;';
}

function setColor(remoteColor) {
	formObj.value = formObj.value+'<span style="color: #'+remoteColor+';">'+prompt("Enter the text to color:","")+'</span>';	
}

function showMe(obj) {
	formObj = obj;
	window.open("/extras/viewer.html","showMeViewer","width=500,height=300,scrollbars=1");
}

function trademark(obj) {
        obj.value = obj.value+'<font size="-2"><sup>TM</sup></font>';
}

function url(obj) {
	obj.value = obj.value+'<a href="'+prompt("Enter the URL of the link:", "http://www.google.com")+'">'+prompt("Enter the title of the link:", "Google")+'</a>';
}

