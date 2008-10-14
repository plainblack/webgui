
/**
 * Initializes popup code on load.	
 */
function initPopUp() {
   // Add onclick handlers to 'a' elements of class submodal or submodal-width-height
   var elms = document.getElementsByTagName('a');
   for (i = 0; i < elms.length; i++) {
      if (elms[i].className.indexOf("submodal") == 0) { 
		 YAHOO.util.Event.addListener(elms[i], "click", showPopWin);
	  }
	}
}

function getProjectFromId(id) {
   var parts = id.split("~~");
   return parts[0];
}

function getTaskFromId(id) {
   var parts = id.split("~~");
   return parts[1];
}

function getInsertAtFromId(id) {
   var parts = id.split("~~");
   if(parts.length < 3) return null;
   var pos = parts[2];
   if(pos == "") return null;
   return pos;
}

function hidePopWin() {
   var taskDialog = document.getElementById("popupInner");
   var parent = taskDialog.parentNode;
   parent.removeChild(taskDialog);
   initPopUp();
}


function showPopWin( e ) {
   
   YAHOO.util.Event.stopEvent(e);
   var link = YAHOO.util.Event.getTarget(e);
   
   if(link == "") {
      alert ("Could not get target from event.  Pop up failed. Please refresh the page and try again.");
      return;
   }
   
   var id       = link.id;
   var url      = getWebguiProperty("pageURL");
   var dataPart = "func=editTask&projectId=" + getProjectFromId(id) + "&taskId=" + getTaskFromId(id);
   var insertAt = getInsertAtFromId(id);
   if(insertAt) {
      dataPart += "&insertAt="+insertAt;
   }

   this.success  = true;
   this.taskDialog = null;
   
   var callback = {
      success : doDialog,
      failure : function(req) { this.success = false; }
   }
   
   if(this.success == false) {
      alert("Could not retrieve task form due to a connection error.  Pop up failed.  Please refresh the page and try again.");
   }
    
      
   var status = YAHOO.util.Connect.asyncRequest('POST',url,callback,dataPart);
   
}

function doDialog (req) {
   var contentArea = document.getElementById("PMproject");
   contentArea.innerHTML = "" + contentArea.innerHTML + req.responseText;
   var taskDialog = document.getElementById("popupInner");
   
   // Instantiate the Dialog
   var dialog = new YAHOO.widget.Dialog(taskDialog, {
      width : "400px",
      fixedcenter : false,
      visible : true, 
      constraintoviewport : false,
      modal : false,
      x : 200,
      y : 200
   });
   
   // Render the Dialog
   dialog.render();
}

YAHOO.util.Event.onDOMReady(initPopUp);


