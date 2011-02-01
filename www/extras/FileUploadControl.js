//constructor for a new file upload control object.  The object generates file upload boxes based on user
//input.  Each file upload input is named "file"  the control must be rendered in a form.  The
//Workspace id is the id of the div in the html page to render the control in.

function FileUploadControl(fieldName, imageArray, removeLabel, fileLimit, size) {


        // Remove the existing field
        var replace = document.getElementById( fieldName );
        replace.parentNode.removeChild( replace );

	this.images = imageArray;
	this.fileLimit = fileLimit;
	this.fileCount = 1;
	this.fieldName = fieldName;
	workspaceId = fieldName+"_fileUploadControl";
	this.workspaceId = workspaceId;
	this.dom=document.getElementById&&!document.all;
	this.topLevelElement=this.dom? "HTML" : "BODY"
	document.write('<div id="'+workspaceId+'"> </div>');	
	var workspace = document.getElementById(workspaceId);
	
	var str = '<table border="0" cellspacing="0" cellpadding="0"><tbody id="' + workspaceId + '.fileUpload.body">';			
	str += '</tbody></table>';
	
	str +='<table style="display: none;">'
	
	str += '<tr id="' + workspaceId + '.template" class="fileUploadRow"><td style="display:none;"><img src="' + imageArray["unknown"] + '" style="visibility: hidden;" /></td>';
	str +='<td colspan="2"><input type="file" name="'+fieldName+'" ';
        str += ' size="'+ size + '" ';
    str +=' onchange="FileUploadControl_valueChange(event)"></td><td><input type="button" value="' + removeLabel + '" onclick="FileUploadControl_removeButtonClick(event)" alt="unknown filetype" /></td></tr>';
	
	str += '</table>';
	
	workspace.innerHTML = str;

	this.tbody = document.getElementById(workspaceId + '.fileUpload.body');
	this.tbody.fileUploadControl = this;
	this.rowTemplate = document.getElementById(workspaceId + ".template");
	this.removeRow = FileUploadControl_removeRow;
	this.addRow = FileUploadControl_addRow;
	this.swapImage = FileUploadControl_swapImage;
	this.getRow = FileUploadControl_getRow;
}

//Searches up the object tree to find the control that owns this object
function FileUploadControl_getControl(firedobj){
	var dom=document.getElementById&&!document.all;
	var topLevelElement=dom? "HTML" : "BODY"

    //traverse up the dom tree until you find the asset    
    while (firedobj.tagName!=topLevelElement && !firedobj.fileUploadControl) {
        firedobj=dom? firedobj.parentNode : firedobj.parentElement    
    }    		

	if (firedobj.fileUploadControl) {
		return firedobj.fileUploadControl;
	}else {
		return null;
	}
}

//traverses up the object tree to find the row associated with firedobj
function FileUploadControl_getRow(firedobj) {
    while (firedobj.tagName!=this.topLevelElement && firedobj.className!="fileUploadRow") {
        firedobj=this.dom? firedobj.parentNode : firedobj.parentElement    
    }    		

	return firedobj;
}

//uses the image array passed into the constructor to set the src on the image for the row.
function FileUploadControl_swapImage(firedobj) {
	
	var parts = firedobj.value.split('.');
	var imgPath = this.images["unknown"];
    var alternative;
	
	if (parts.length !=1) {
			var extension = parts[parts.length -1].toLowerCase();
			if (this.images[extension]) {
				imgPath = this.images[extension];
                alternative = extension;
			}
	}		
	var row = this.getRow(firedobj);
	
	row.childNodes[0].style.display='';
	row.childNodes[1].colSpan=1;
	var img = row.childNodes[0].childNodes[0];
	img.src = imgPath;
	img.style.visibility="visible";
    img.alt = alternative;
}

//removes a row from the control
function FileUploadControl_removeRow(firedobj) {    
    var row = this.getRow(firedobj);
	this.tbody.removeChild(row);
}

//adds a row to the control
function FileUploadControl_addRow() {
	var row = this.rowTemplate.cloneNode(true);	
    row.id = "id";
	row.id += new Date().getTime();	
	this.tbody.appendChild(row);
}

//event handlers
//called on click of the remove button
function FileUploadControl_removeButtonClick(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
    var firedobj =dom? e.target : e.srcElement

	var control = FileUploadControl_getControl(firedobj);
  	if (control.tbody.childNodes[control.tbody.childNodes.length -1] == control.getRow(firedobj)) {
		control.addRow();
        } else {
		control.fileCount--;
	}
	control.removeRow(firedobj);

}

//called on change of the upload inputs
function FileUploadControl_valueChange(e) {
    var dom = document.getElementById&&!document.all;
    e=dom? e : event;
    var firedobj =dom? e.target : e.srcElement

	var control = FileUploadControl_getControl(firedobj);

	if (control.tbody.childNodes[control.tbody.childNodes.length -1].childNodes[1].childNodes[0].value != "") {
		if (control.fileCount < control.fileLimit) {
			control.addRow();
			control.fileCount++;
		}
	}
	
	control.swapImage(firedobj);
}
