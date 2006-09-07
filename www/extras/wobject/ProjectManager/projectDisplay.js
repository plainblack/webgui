var dayMS = 86400000;
var popTitle = "Add/Edit Task";

// To be set by template vars
var dunits, hoursPerDay, taskLength;
var extrasPath, errorMsgs;
var taskArray;

function doCalendar (fieldId) {
   Calendar.setup({ 
                     inputField : fieldId, 
                     ifFormat : "%Y-%m-%d", 
                     showsTime : false, 
                     step : 1,
                     timeFormat : "12",
                     firstDay : false
                  }); 
}

//--------------------------------------------------------------------------------------	
function buildMenuUrl (urltype,taskId) {
   if(urltype == "edit") {
      alert("edit task: "+taskId);
   } else if(urltype == "insertAbove") {
      alert("insert task above: "+taskId);
   } else if(urltype == "insertBelow") {
      alert("insert task below: "+taskId);
   } else if(urltype == "delete") {
      alert("delete task: "+taskId);
   }
}

//--------------------------------------------------------------------------------------	
function closeImage() {
   return extrasPath + '/close.gif';
}

//--------------------------------------------------------------------------------------	
function configureMilestone(box) {
   var form = box.form;
   if(box.checked==true) { 
      form.end.value=form.start.value; 
      form.duration.value=0; 
      form.duration.disabled=true; 
      form.lagTime.value=0;
      form.lagTime.disabled=true;
      form.end.disabled=true;
      form.dependants.disabled=true;
      form.resource.disabled=true;
      form.percentComplete.disabled=true;
      form.percentComplete.value=0;
   } else { 
      form.end.disabled=false; 
      form.duration.disabled=false; 
      form.lagTime.disabled=false;
      form.dependants.disabled=false;
      form.resource.disabled=false;
      form.percentComplete.disabled=false;
      form.duration.value = (dunits == "hrs")?hoursPerDay:1;
   }
}

//--------------------------------------------------------------------------------------	
function checkEditTaskForm (form) {
   if(form.name.value == "") {
      alert(errorMsgs.name);
      return;
   } else if(form.start.value == "") {
      alert(errorMsgs.start);
      return;
   } else if(form.milestone.checked==false && form.end.value == "") {
      alert(errorMsgs.end);
      return;
   }
   form.submit();
}

//--------------------------------------------------------------------------------------	
function intlDate(dateObj) {
   return dateObj.getFullYear()+"-"+pad((dateObj.getMonth()+1))+"-"+pad(dateObj.getDate());
}

//--------------------------------------------------------------------------------------	
function toDateObj(date) {
   var to = date.split("-");
   var dateObj = new Date(to[0],(to[1]-1),to[2],0,0,1,0);
   return dateObj;
}

//--------------------------------------------------------------------------------------	
function adjustTaskTimeFromDuration(start, end, duration, lagTime, isTaskForm, predecessor, origStart, origEnd, seqNum) {
   //set the form element
   var form = duration.form;
   
   //get today's date
   var today = new Date();
   var todayIntl = intlDate(today);
   //set start and end date if not already set
   if(start.value == "") start.value = todayIntl;
   if(end.value == "") end.value = todayIntl;
   
   //Convert hours to days
   var taskDuration = parseFloat(duration.value);
   var taskTotalDuration = taskDuration + parseFloat(lagTime.value);
   if(dunits == "hrs") taskTotalDuration = taskTotalDuration / hoursPerDay;
   var totalDurationFloor = Math.floor(taskTotalDuration);
   
   //Handle task form and main form seperately due to differences in the forms
   if(isTaskForm && taskDuration <= 0) {
      //Convert to milestone if task is less or equal to zero
      if(confirm("Zero duration tasks are considered Milestones.  Do you wish to change this task to a milestone?")) {
	 form.milestone.checked = true;
	 configureMilestone(form.milestone);
      } else {
	 duration.value = form.orig_duration.value;
      }
      return;
   } else if (taskDuration <= 0){
      //Do not let users zero out tasks
      alert("Zero duration tasks are considered Milestones.  Please edit the task by clicking the link if you wish to change this task to a milestone");
      return;
   }
   
   //create the start date 
   var aTo = start.value.split("-");
   var toDate = new Date(aTo[0],(aTo[1]-1),aTo[2],0,0,1,0);
   
   //add new duration days to the start date
   toDate.setDate(toDate.getDate() + totalDurationFloor);
   
   //set end date to this date
   end.value = intlDate(toDate);
   
   //Set new duration in taskArray
   taskArray[seqNum]["duration"] = taskDuration;
   //Adjust time based on new end date
   adjustTaskTimeFromDate(start, end, duration, lagTime, end, isTaskForm, predecessor, origStart, origEnd, seqNum);
}

//--------------------------------------------------------------------------------------	
function adjustTaskTimeFromDate (start, end, duration, lagTime, element, isTaskForm, predecessor, origStart, origEnd, seqNum) {
   //set the form element
   var form = element.form;
   //set original duration from task form to determine whether or not to continue to set duration
   var orig_duration;
   
   if(isTaskForm) {
      if(form.milestone.checked == true) return;
      orig_duration = form.orig_duration.value;
   }
   
   //Handle case where both start and end are empty
   if(start.value == "" && end.value == "") {
      //get today's date
      var today = new Date();
      var todayIntl = intlDate(today);
      //set start and end date if not already set
      start.value = todayIntl;
      end.value = todayIntl;
   }
   
   //Handle case where one is set and the other isn't
   if (end.value == "") end.value = start.value;
   if(start.value == "") start.value = end.value;
   
   if(isTaskForm && orig_duration == "") {
      //Set duration if this is a new record
      //Check to make sure start date comes before end date
      var startcomp = start.value.replace(/-/g,"");
      var endcomp = end.value.replace(/-/g,"");
      if(startcomp > endcomp) {
	 alert(errorMsgs.greaterthan);
	 if(element.name == "start") {
	    end.value = element.value;
	 } else {
	    start.value = element.value;
	 }
	 duration.value = (dunits == "hrs")?hoursPerDay:1;
	 lagTime.value = 0;
	 return;
      }
      
      var d = getDaysInterval(start.value,end.value);
      if(d == 0) d = 1;
      if(dunits == "hrs") {
	 d = d * hoursPerDay;
      }
      duration.value = d - lagTime.value;
   } else {
      //Set start/end if duration has been saved
      var d = parseFloat(duration.value) + parseFloat(lagTime.value); 
      if(dunits == "hrs") {
	 //Convert to days
	 d = d / hoursPerDay;
      }
      //Round off duration or set it to zero if less than 1;
      //alert("d = " + d + " floor = " + Math.floor(d));
      if(d < 1) d = 0;
      else d = Math.floor(d);
      
      if(element.name.indexOf("start") > -1) {
	 //create the date 
	 var aTo = start.value.split("-");
	 var toDate = new Date(aTo[0],(aTo[1]-1),aTo[2],0,0,1,0);
         //add duration days to the start date
         toDate.setDate(toDate.getDate() + d);
	 //set end date to this date
	 end.value = intlDate(toDate);
      } else if(element.name.indexOf("end") > -1) {
	 //create the date
	 var aFrom = end.value.split("-");
	 var fromDate = new Date(aFrom[0],(aFrom[1]-1),aFrom[2],0,0,1,0);
	 //subtract duration days from the end date
	 fromDate.setDate(fromDate.getDate() - d);
	 //set start date to this date
	 start.value = intlDate(fromDate);
      }
   }
   
   //Check Predecessors before moving stuff
   var pred = predecessor.value;
   if(pred != "") {
      //Check to make sure that the dependency requirement for this task is still valid
      //Get the predecessor end date
      var taskStart = toDateObj(start.value);
      var predTaskEnd;
      if(isTaskForm) {
	 predTaskEnd = toDateObj(taskArray[pred]["end"]);
      } else {
	 var predTaskEndId = "end_"+taskArray[pred]["id"]+"_formId"
	 predTaskEnd = toDateObj(document.getElementById(predTaskEndId).value);
      }
      
      if(taskStart.getTime() < predTaskEnd.getTime()) {
	 alert(errorMsgs.invalidMove);
	 start.value = origStart.value;
	 end.value = origEnd.value;
	 return;
      }
   }
   
   //Check all tasks past this one and move them forward if necessary (this only needs to happen on the main form)
   if(!isTaskForm) {
      arrangePredecessors(element,seqNum);
   }
   //reset orig start and end values
   origStart.value = start.value;
   origEnd.value = end.value;
   
   if(!isTaskForm) {
      //Adjust task form for 
      paintGanttChart();
   }
}

//--------------------------------------------------------------------------------------
function trim(str) {
   return str.replace(/^\s+|\s+$/, '');
}

//--------------------------------------------------------------------------------------
function arrangePredecessors (element,seqNum) {
   for (var i = 1; i <= taskLength; i++) {
      var seq = i;
      var task = taskArray[seq];
      var taskId = task["id"];
      //Calculate duration and duraiton floor
      var totalDurationInDays = parseFloat(task["duration"]) + parseFloat(task["lagTime"]);
      if(dunits == "hrs") totalDurationInDays = totalDurationInDays / hoursPerDay;
      var totalDurationFloor = Math.floor(totalDurationInDays);
      //alert("Duration Floor is: "+durationFloor);
      //Get the current elements
      var currElementStart = document.getElementById("start_"+taskId+"_formId");
      var currElementEnd = document.getElementById("end_"+taskId+"_formId");
      //alert("Current Start Date: "+currElementStart.value+"   Current End Date: "+currElementEnd.value);
      //Skip the first record as it is the record that was changed
      if(seq > 1) {
	 var predecessor = task["predecessor"];
	 //alert("predecessor for "+i+" is "+predecessor);
	 if(predecessor != "") {
	    var pred = taskArray[predecessor];
	    var predEndDate = toDateObj(pred["end"]);
	    var startDate = toDateObj(task["start"]);
	    //alert ("Pred End Date: "+intlDate(predEndDate));
	    //Make sure start date of this task is greater than the end date of the predecessor
	    if(startDate.getTime() <= predEndDate.getTime()) {
	       //Change the start and end dates of the task
	       //Get the day part of the predecessor
	       var predDayPart = parseFloat(pred["dayPart"]);
	       //alert("predDayPart: "+predDayPart);
	       if(predDayPart > 0) {
		  //The previous task took up part of a day.  Add the additional day part to the duration
		  totalDurationInDays += predDayPart;
		  totalDurationFloor = Math.floor(totalDurationInDays);
	       }
	       //alert("Duration in Days: "+durationInDays+" Duration Floor: "+durationFloor);
	       //Set the start date of this task to the end date of the predecessor
	       currElementStart.value = pred["end"];
	       //Adjust end date for change in start date and update the object - start date is actually predEndDate now, so use the existing date object
	       predEndDate.setDate(predEndDate.getDate() + totalDurationFloor);
	       currElementEnd.value = intlDate(predEndDate);
	       //alert("Set seq "+i+" to start: "+pred["end"]+" end: "+intlDate(predEndDate));
	    }
	 }
      }
      
      //Update task array with new start/end values
      taskArray[seq]["start"] = currElementStart.value;
      taskArray[seq]["end"] = currElementEnd.value;
      taskArray[seq]["dayPart"] = (totalDurationInDays - Math.floor(totalDurationInDays));
   }
}

//--------------------------------------------------------------------------------------	
function getDaysInterval(from,to) {
   var aFrom = from.split("-");
   var aTo = to.split("-");
   var fromDate = new Date(aFrom[0],(aFrom[1]-1),aFrom[2],0,0,1,0);
   var toDate = new Date(aTo[0],(aTo[1]-1),aTo[2],0,0,1,0);
   var fromEpoch = fromDate.getTime();
   var toEpoch = toDate.getTime();
   
   var seconds = toEpoch - fromEpoch;
   if(seconds == 0) return 0;
   return (seconds/dayMS);
}

//--------------------------------------------------------------------------------------	
function pad(date) {
   var str = ""+date;
   if(str.length == 1) {
      str = "0"+str;
   }
   return str;
}

//--------------------------------------------------------------------------------------	
function paintGanttChart () {
   var status = AjaxRequest.submit(document.forms['editAll'],{
                                      'onSuccess':function(req){ document.getElementById('gantt').innerHTML = req.responseText; }
                                   });
   
   var mwidth = document.getElementById("projectTableWidth").name + "px";
   var swidth = document.getElementById("projectScrollPercentWidth").name + "%";
   document.getElementById("mastertable").style.width=mwidth;
   document.getElementById("scrolltd").style.width=swidth;
}

//--------------------------------------------------------------------------------------	
function validateDependant(field,origField,seqNum,start,end,duration,lagTime,isTaskForm,origStart,origEnd) {
   var pred = field.value;
   var newTask = false;
   if(pred != "") {
      if(seqNum == "") seqNum = taskLength+1;
      if(pred < 1) {
	 alert(errorMsgs.noPredecessor);
	 field.value=origField.value;
	 return;
      }
      if(pred == seqNum) {
	 alert(errorMsgs.samePredecessor);
	 field.value=origField.value;
	 return;
      }
      if(pred > seqNum) {
	 alert(errorMsgs.previousPredecessor);
	 field.value = origField.value;
	 return; 
      }
      
      //Set defaults if it's a new record and one of the other options hasn't been checked.
      if(start.value == "" || end.value == "") {
         //get today's date
	 newTask = true;
	 duration.value = (dunits == "hrs")?hoursPerDay:1; 
      }
      //Get the predecessor end date and decide where the new start date belongs
      var taskStart = start.value;
      var taskStartObj = toDateObj(taskStart);
      var predTaskEnd = taskArray[pred]["end"];
      var predTaskEndObj = toDateObj(predTaskEnd);
      
      //Change start date if it comes before predecessor end date
      if(newTask || (taskStartObj.getTime() < predTaskEndObj.getTime())) {
	 
	 //Convert predecessor hours to days
	 var taskTotalDuration = parseFloat(duration.value) + parseFloat(lagTime.value);
	 if(dunits == "hrs") taskTotalDuration = taskTotalDuration / hoursPerDay;
	 var totalDurationFloor = Math.floor(taskTotalDuration);
	 
	 //Get the predecessor dayPart
	 var predDayPart = parseFloat(pred["dayPart"]);
	 if(predDayPart > 0) {
	    //The previous task took up part of a day.  Add the additional day part to the duration
	    taskTotalDuration += predDayPart;
	    totalDurationFloor = Math.floor(totalDurationInDays);
	 }
	 
	 //Set the start date of this task to the end date of the predecessor
	 start.value = predTaskEnd;
	 //Adjust end date for change in start date
	 adjustTaskTimeFromDate(start,end,duration,lagTime,start,isTaskForm,field,origStart,origEnd,seqNum);
	 return;
      }
   }
   
   //Repaint
   if(!isTaskForm) {
      //Set new predecessor in taskArray
      taskArray[seqNum]["predecessor"] = pred;
      paintGanttChart();
   }
}
