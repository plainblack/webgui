function addCriteria ( fieldname, opform, valform ) {
   var form = opform.form;
   var operator = getValue(opform);
   var value = getValue(valform);
   var criteria = form.proxyCriteria.value;
   var conjunction = "";
   var re = /^\s*$/;
   if(! re.test(criteria)) {
   		conjunction = " " + getValue(form.conjunction) + " ";
   	}
   if(/\s+/.test(fieldname)) {
	fieldname = '"' + fieldname + '"';
   }
   var statement = fieldname + " " + operator + " " + '"' + value + '"';
   form.proxyCriteria.value = criteria + conjunction + statement;
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

