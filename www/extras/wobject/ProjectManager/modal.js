
/**
 * Initializes popup code on load.	
 */
function initPopUp() {
   // Add onclick handlers to 'a' elements of class submodal or submodal-width-height
   var elms = document.getElementsByTagName('a');
   for (i = 0; i < elms.length; i++) {
      if (elms[i].className.indexOf("submodal") == 0) { 
		 YAHOO.util.Event.addListener(elms[i], "click", showEditWindow);
	  }
	}
}

function showEditWindow(e) {
   var link = YAHOO.util.Event.getTarget(e);
   
   if(link == "") {
      alert ("Could not get target from event.  Pop up failed. Please refresh the page and try again.");
      return;
   }
   
   var id  = link.id;
   var url = getWebguiProperty("pageURL");
   url += "?func=editTask";
   url += ";projectId="+getProjectFromId(id);
   url += ";taskId="+getTaskFromId(id);
   
   window.open(url, "task", 'status=1,scrollbars=0,toolbar=0,location=0,menubar=0,directories=0,resizable=1,height=600,width=400');

   return false;
}

function getProjectFromId(id) {
   var parts = id.split("~~");
   return parts[0];
}

function getTaskFromId(id) {
   var parts = id.split("~~");
   return parts[1];
}


function showPopWin( e ) {
   
   var link = YAHOO.util.Event.getTarget(e);
   
   if(link == "") {
      alert ("Could not get target from event.  Pop up failed. Please refresh the page and try again.");
      return;
   }
   
   var urlpart = link.href.split("?");
   
   this.success  = true;
   this.taskDialog = null;
   
   var callback = {
      success : doDialog,
      failure : function(req) { this.success = false; }
   }
    
      
   var status = YAHOO.util.Connect.asyncRequest('POST',urlpart[0],callback,urlpart[1]);
   
}

function doDialog (req) {
   var contentArea = document.getElementById("contentArea");
   alert(contentArea);
   contentArea.innerHTML = "" + contentArea.innerHTML + req.responseText;
   this.taskDialog = document.getElementById("taskDialog");
   
   // Instantiate the Dialog
   var dialog = new YAHOO.widget.Dialog(this.taskDialog, {
      width : "400px",
      fixedcenter : true,
      visible : false, 
      constraintoviewport : true,
      modal : true,
      buttons : [
         { text:"Submit", handler:this.handleSubmit, isDefault:true },
         { text:"Cancel", handler:this.handleCancel } ]
      }
   );
   
   // Wire up the success and failure handlers
   dialog.callback = {
      success: handleSuccess,
      failure: handleFailure
   };
   
   // Render the Dialog
   dialog.render();
}

function handleSubmit(e) {
   document.editTaskForm.submit();
};
   
function handleCancel(e) {
   document.editTaskForm.cancel();
};
   
function handleSuccess(e) {
   //var response = o.responseText;
   //response = response.split("<!")[0];
   //document.getElementById("resp").innerHTML = response;
   alert("SUCCESS!!");
};
   
function handleFailure(e) {
   alert("Submission failed: " + o.status);
};




