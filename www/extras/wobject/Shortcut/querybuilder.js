function wgCriteriaDisable ( form, toDisable ) {
    var new_state = toDisable ? false : true;
    var elements  = YAHOO.util.Dom.getElementsByClassName('qbselect');
    var buttons   = YAHOO.util.Dom.getElementsByClassName('qbButton');
    form.resolveMultiples.disabled = new_state;
    form.shortcutCriteria.disabled = new_state;
    for(idx=0; idx < elements.length; idx++) {
        elements[idx].disabled = new_state;
    }
    for(idx=0; idx < buttons.length; idx++) {
        buttons[idx].disabled = new_state;
    }
}

function addCriteria ( fieldname, opform, valform ) {
   var form = opform.form;
   var operator = getValue(opform);
   var value = getValue(valform);
   var criteria = form.shortcutCriteria.value;
   var conjunction = "";
   if (form.shortcutCriteria.disabled == true) {
       return;
   }
   if(! /^\s*$/.test(criteria)) {
   		conjunction = " " + getValue(form.conjunction) + " ";
   }
   //handle quotes
   if(/\s+/.test(fieldname)) {
	fieldname = '"' + fieldname + '"';
   }
   if(/^\D*$/.test(value)) {
	value = '"' + value + '"';
   }
   var statement = fieldname + " " + operator + " " + value;
   form.shortcutCriteria.value = criteria + conjunction + statement;
}

function getValue(sel) {
   if(sel.type == "text") {
      return sel.value;
   }
   for(i=0;i<sel.length;i++) {
      if(sel[i].type == "radio") { 
         if(sel[i].checked) {
            return sel[i].value;
         }
      } else {
         if(sel.options[i].selected) {
            return sel.options[i].value;
         }
      }
   }
   return "";
}

