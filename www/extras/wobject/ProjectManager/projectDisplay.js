var dayMS = 86400000;
var popTitle = "Add/Edit Task";

// To be set by template vars
var dunits, hoursPerDay, taskLength;
var extrasPath, errorMsgs;
var taskArray;

//--------------------------------------------------------------------------------------	
function parseFloatOrNA(str) {
   if (str == 'N/A') return 0.0;
   else return parseFloat(str);
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
function configureForTaskType(form) {
   var te = getTaskElements(form, '');

   switch (getTaskType(form)) {
   case 'timed':
      form.end.disabled = false; 
      form.duration.disabled = false; 
      form.lagTime.disabled = false;
      form.dependants.disabled = false;
      form.percentComplete.disabled = false;

      if (!form.duration.value || parseFloatOrNA(form.duration.value) == 0)
	 form.duration.value = (dunits == "hrs")? hoursPerDay : 1;
      if (!form.percentComplete.value || form.percentComplete.value == 'N/A')
	 form.percentComplete.value = 0;
      if (!form.lagTime.value || form.lagTime.value == 'N/A')
	 form.lagTime.value = 0;

      break;

   case 'progressive':
      form.end.value = form.start.value;
      form.end.disabled = true;
      form.duration.disabled = false;
      form.dependants.disabled = false;
      form.lagTime.value = 'N/A';
      form.lagTime.disabled = true;
      form.percentComplete.value = 'N/A';
      form.percentComplete.disabled = true;
      break;

   case 'milestone':
      form.duration.value = 0;
      form.duration.disabled = true; 
      form.lagTime.value = 'N/A';
      form.lagTime.disabled = true;
      form.end.disabled = true;
      form.dependants.disabled = true;
      form.percentComplete.value = 'N/A';
      form.percentComplete.disabled = true;
      break;
   }

   setEndFromStartDate(te);
}

//--------------------------------------------------------------------------------------
function getCheckedOfNodeList(list) {
	for (var i = 0; i < list.length; i++) {
		if (list[i].checked) { return list[i].value; }
	}
	return null;
}

//--------------------------------------------------------------------------------------
function setCheckedOfNodeList(list, value) {
	for (var i = 0; i < list.length; i++) {
		list[i].checked = (list[i].value == value);
	}
	return value;
}

// TODO: convert this whole bunch of stuff to do with task element groups
// to an actual prototype/class?
//--------------------------------------------------------------------------------------
function getTaskElements(form, suffix) {
   var te = new Object();
   var keys = ['start', 'end', 'duration', 'lagTime', 'dependants', 'origStart', 'origEnd',
	       'seqNum', 'taskType', 'orig_start', 'orig_duration', 'orig_dependants', 'orig_end'];
   for (var i = 0; i < keys.length; i++)
      te[keys[i]] = form[keys[i]+suffix];
   return te;
}

//--------------------------------------------------------------------------------------
function getTaskType(te) {
   var taskTypeElt = te.taskType;
   if (taskTypeElt.type == 'hidden') return taskTypeElt.value;
   else return getCheckedOfNodeList(taskTypeElt);
}

//--------------------------------------------------------------------------------------
function setTaskType(te, value) {
   var taskTypeElt = te.taskType;
   if (taskTypeElt.type == 'hidden') taskTypeElt.value = value;
   else setCheckedOfNodeList(taskTypeElt, value);
}

//--------------------------------------------------------------------------------------
function isTimed(te) {
   return getTaskType(te) == 'timed';
}

//--------------------------------------------------------------------------------------
function isUntimed(te) {
   return !isTimed(te);
}

//--------------------------------------------------------------------------------------
function fracDaysOfDuration(dur) {
   if (dunits == 'hrs') return dur / hoursPerDay;
   else return dur;
}

//--------------------------------------------------------------------------------------
function durationOfFracDays(days) {
   if (dunits == 'hrs') return days * hoursPerDay;
   else return days;
}

//--------------------------------------------------------------------------------------
function getDuration(te) {
   return fracDaysOfDuration(parseFloat(te.duration.value));
}

//--------------------------------------------------------------------------------------
function setDuration(te, days) {
   te.duration.value = durationOfFracDays(days);
}

//--------------------------------------------------------------------------------------
function getDateByKey(te, key) {
   var split = te[key].value.split('-');
   return new Date(split[0], split[1]-1, split[2], 0, 0, 1, 0);
}

//--------------------------------------------------------------------------------------
function getStartDate(te) {
   return getDateByKey(te, 'start');
}

//--------------------------------------------------------------------------------------
function getEndDate(te) {
   return getDateByKey(te, 'end');
}

//--------------------------------------------------------------------------------------
function setDateByKey(te, key, date) {
   te[key].value = intlDate(date);
}

//--------------------------------------------------------------------------------------
function setStartDate(te, date) {
   setDateByKey(te, 'start', date);
}

//--------------------------------------------------------------------------------------
function setEndDate(te, date) {
   setDateByKey(te, 'end', date);
}

//--------------------------------------------------------------------------------------
function setStartFromEndDate(te) {
   setStartDate(te, datePlusDays(getEndDate(te), -Math.floor(getTotalDuration(te))));
}

//--------------------------------------------------------------------------------------
function setEndFromStartDate(te) {
   setEndDate(te, datePlusDays(getStartDate(te), Math.floor(getTotalDuration(te))));
}

//--------------------------------------------------------------------------------------
function setOrigDates(te) {
   te.orig_start.value = te.start.value;
   te.orig_end.value = te.end.value;
}

//--------------------------------------------------------------------------------------
function datePlusDays(date, days) {
   var ret = new Date();
   ret.setTime(date.getTime() + days * dayMS);
   return ret;
}

//--------------------------------------------------------------------------------------
function getTotalDuration(te) {
   return fracDaysOfDuration(parseFloat(te.duration.value) +
			     parseFloatOrNA(te.lagTime.value));
}

//--------------------------------------------------------------------------------------	
function maybeDefaultTaskValues(te) {
   var todayString = intlDate(new Date());
   //var tomorrowString = intlDate(datePlusDays(new Date(), 1));
   var timed = isTimed(te);

   //if (te.duration.value == "") te.duration.value = timed? durationOfFracDays(1) : 0;
   if (te.lagTime.value == "") te.lagTime.value = 0;

   if (te.start.value == "" && te.end.value == "") {
      te.start.value = todayString;
      te.end.value = todayString;  
   } else if (te.start.value == "") {
      setEndFromStartDate(te);
   } else if (te.end.value == "") {
      setStartFromEndDate(te);
   }
   
   if(timed && te.duration.value == 0) {
      //TO DO - Calculate duration based on end date
   }

   updateTaskArray(te);
}

//--------------------------------------------------------------------------------------	
function updateTaskArray(te) {
   var seqNum = te.seqNum.value;
   if (seqNum == "") return;
   var assoc = taskArray[seqNum];
   assoc.start = te.start.value;
   assoc.end = te.end.value;
   assoc.duration = te.duration.value;
   assoc.lagTime = ''+parseInt(te.lagTime.value);
   assoc.predecessor = te.dependants.value;
   assoc.type = getTaskType(te);
}

//--------------------------------------------------------------------------------------	
function checkEditTaskForm (form) {
   if (form.name.value == "") {
      alert(errorMsgs.name);
      return;
   } else if (form.start.value == "") {
      alert(errorMsgs.start);
      return;
   } else if (isTimed(form) && form.end.value == "") {
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

//--------------------------------------------------------------------------------------x
function durationChanged(form, suffix, isTaskForm, gotDelay) {
   if (!isTaskForm && !gotDelay)
      return window.setTimeout(function() {
	 durationChanged(form, suffix, isTaskForm, true); }, 1);

   var te = getTaskElements(form, suffix);
   maybeDefaultTaskValues(te);

   // Get the new duration.
   var duration = getDuration(te);
   var totalDuration = getTotalDuration(te);
   
   // We can't have timed tasks with duration zero.  Those are called "milestones".
   if (duration <= 0 && getTaskType(te) == 'timed') {
      if (isTaskForm) {
         // Convert to milestone if desired.
         if (confirm("Zero duration tasks are considered milestones.  Do you wish to change this task to a milestone?")) {
            setTaskType(te, 'milestone');
            configureForTaskType(form);
         } else {
	    form.duration.value = form.orig_duration.value;
	    if (getDuration(te) <= 0)
	       setDuration(te, 1);
         }
      } else {
         // Do not let users zero out tasks from the quick view.
         alert("Zero duration tasks are considered Milestones.  Please edit the task by clicking the link if you wish to change this task to a milestone");
      }
   }

   switch (getTaskType(te)) {
   case 'timed':
   case 'progressive':
      setEndDate(te, datePlusDays(getStartDate(te), Math.floor(totalDuration)));
      break;

   case 'milestone':
      setEndDate(te, getStartDate(te));
      break;
   }

   te.orig_duration.value = te.duration.value;
   updateTaskArray(te);

   if (!isTaskForm) {
      updateDependantDates();
      paintGanttChart();
   }
}

//--------------------------------------------------------------------------------------
function checkPredecessorCollision(te, isTaskForm) {
   var predecessor = te.dependants.value;
   if (predecessor == "") return;
   var predAssoc = taskArray[predecessor];
   var predEnd = toDateObj(predAssoc.end);
   if (predEnd.getTime() >= getStartDate(te).getTime()) {
      setStartDate(te, predEnd);
      setEndFromStartDate(te);
   }
}

//--------------------------------------------------------------------------------------
function dateChanged(form, suffix, isTaskForm, setWhichWay, gotDelay) {
   if (!isTaskForm && !gotDelay)
      return window.setTimeout(function() {
	 dateChanged(form, suffix, isTaskForm, setWhichWay, true); }, 1);
    
   var te = getTaskElements(form, suffix);
   maybeDefaultTaskValues(te);
   setWhichWay(te);
   checkPredecessorCollision(te, isTaskForm);
   setOrigDates(te);
   updateTaskArray(te);

   if (!isTaskForm) {
      updateDependantDates();
      paintGanttChart();
   }

}

//--------------------------------------------------------------------------------------
function startDateChanged(form, suffix, isTaskForm) {
   var te = getTaskElements(form,suffix);
      
   if(isValidDate(te.start.value)) {
      dateChanged(form, suffix, isTaskForm, setEndFromStartDate);
   }
   else {
      alert("Dates must be valid and in the form yyyy-mm-dd");
      te.start.value = te.orig_start.value;
   }
}

//--------------------------------------------------------------------------------------
function endDateChanged(form, suffix, isTaskForm) {
   var te = getTaskElements(form,suffix);
   
   if(isValidDate(te.end.value)) {
      dateChanged(form, suffix, isTaskForm, setStartFromEndDate);
   }
   else {
      alert("Dates must be valid and in the form yyyy-mm-dd");
      te.start.value = te.orig_start.value;
   }
}

//--------------------------------------------------------------------------------------
function isValidDate(dt) {
   var datePat = /^(\d{4})-(\d{2})-(\d{2})$/;
   //match the date pattern
   if(!dt.match(datePat)){
      return false;
   }
   
   var split = dt.split('-');
   var yyyy = split[0];
   var mm   = split[1];
   var dd   = split[2];
      
   // if month out of range
   if ( mm < 1 || mm > 12 ) {
      return false;
   }
   
   // get last day in month
   var d = (12 == mm) ? new Date(yyyy + 1, 0, 0) : new Date(yyyy, mm + 1, 0);

   // if date out of range
   if ( dd < 1 || dd > d.getDate() ) {
      return false
   }   
   
   return true;
}

//--------------------------------------------------------------------------------------
function predecessorChanged(form, suffix, isTaskForm, gotDelay) {
   if (!isTaskForm && !gotDelay)
      return window.setTimeout(function() {
	 predecessorChanged(form, suffix, isTaskForm, true); }, 1);

   var te = getTaskElements(form, suffix);
   var seqNum = te.seqNum.value, predecessor = te.dependants.value;

   if (predecessor != "") {
      var assoc = taskArray[predecessor];
      var revert = function() { te.dependants.value = te.orig_dependants.value; return; }

      if (predecessor < 1) { alert(errorMsgs.noPredecessor); return revert(); }
      if (seqNum != "") {
	 if (predecessor == seqNum) { alert(errorMsgs.samePredecessor); return revert(); }
	 if (predecessor > seqNum) { alert(errorMsgs.previousPredecessor); return revert(); }
      }
      if (assoc["type"] != 'timed') { alert(errorMsgs.untimedPredecessor); return revert(); }
   }

   te.orig_dependants.value = te.dependants.value;
   checkPredecessorCollision(te, isTaskForm);
   updateTaskArray(te);

   if (!isTaskForm) {
      updateDependantDates();
      paintGanttChart();
   }
}

//--------------------------------------------------------------------------------------
function trim(str) {
   return str.replace(/^\s+|\s+$/, '');
}

//--------------------------------------------------------------------------------------
function updateDependantDates() {
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
   
   var callback = {
      success : function(req) { document.getElementById('gantt').innerHTML = req.responseText; },
      failure : function(req) { alert("Could not load gantt chart.  Problems with connection.  Please refresh the page and try again."); }
   }
   
   var postData = YAHOO.util.Connect.setForm(document.forms['editAll']);
   
   var status = YAHOO.util.Connect.asyncRequest('POST',getWebguiProperty("pageURL"),callback,postData);
   
   var mwidth = document.getElementById("projectTableWidth").name + "px";
   var swidth = document.getElementById("projectScrollPercentWidth").name + "%";
   document.getElementById("mastertable").style.width=mwidth;
   document.getElementById("scrolltd").style.width=swidth;
}