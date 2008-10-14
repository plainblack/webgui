/* changeDownloadType(Element type)
 *	Disables/Enables/Hides/Shows the
 *		downloadFilename
 *		downloadTemplateId
 *		downloadMimeType
 *	form elements whenever the downloadType element is 
 *	changed.
 */
function changeDownloadType(type) {
	file		= document.getElementById("downloadFilename_formId");
	while (file.nodeName.toLowerCase() != "tr")
		file = file.parentNode;
	template	= document.getElementById("downloadTemplateId_formId").parentNode;
	while (template.nodeName.toLowerCase() != "tr")
		template = template.parentNode;
	mimeType	= document.getElementById("downloadMimeType_formId").parentNode;
	while (mimeType.nodeName.toLowerCase() != "tr")
		mimeType = mimeType.parentNode;
	
	if (type.value == "none") { 
		file.style.display	= "none"; 
		template.style.display 	= "none"; 
		mimeType.style.display	= "none"; 
	} else if (type.value == "template") { 
		file.style.display	= ""; 
		template.style.display 	= ""; 
		mimeType.style.display 	= ""; 
	} else {
		file.style.display	= "";
		template.style.display 	= "none"; 
		mimeType.style.display 	= "none"; 
	}
}

// Add a window.onload event to handle hiding the inappropriate form values

// addLoadEvent(function)
// Adds an event to window.onload without overriding events already there.
// Taken from http://simon.incutio.com/archive/2004/05/26/addLoadEvent
function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}

addLoadEvent(function() {
	// Find out which radio button is checked by default
	for (i=0;i<document.forms[0].downloadType.length;i++) {
		if (document.forms[0].downloadType[i].checked) {
			changeDownloadType(document.forms[0].downloadType[i]);
		}
	}
});



