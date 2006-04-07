var textCompareList = {
                        "eq":"equals",
						"like":"contains",
						"ne":"is not",
						"notlike":"not like",
			            "starts":"starts with",
			            "ends":"ends with"
                      };

var numericCompareList = {
                       "eq":"=",
					   "ne":"is not",
			           "gt":">",
					   "lt":"<",
					   "gte":">=",
					   "lte":"<="
                      };
var booleanCompareList = {
                       "eq":"is",
					   "ne":"is not"
                      };
function addField() {
   var tb = document.getElementById('filterbody');
   filterCount++;
      
   var newtr = document.createElement('tr');
   newtr.setAttribute("id","cfilter_id"+filterCount);
   //Create right table data
   var newtd1 = document.createElement('td');
   newtd1.className="searchDisplay";
   //Add fields to choose from
   var newDD = newtd1.appendChild(addFilterSelect());
   
   //Create left table data
   var newtd2 = document.createElement('td');
   newtd2.className="searchDisplay";
   newtd2.setAttribute("id","cfilter_td_"+filterCount);
   //Add default compare select list
   var compareSelect = addSelectList('cfilter_c'+filterCount,textCompareList);
   compareSelect.className="compare-select";
   newtd2.appendChild(compareSelect);
   //Add default filter field
   var filterText = addTextField('cfilter_t'+filterCount);
   filterText.className="filter-text";
   newtd2.appendChild(filterText);
   //Add remove button
   var filterButton = addButton('cbutton_'+filterCount,'-');
   filterButton.className="button";
   filterButton.onclick = removeField;
   newtd2.appendChild(filterButton);
   //Add tds to trs
   newtr.appendChild(newtd1);
   newtr.appendChild(newtd2);
   //Add trs to tbody
   tb.appendChild(newtr);
   return newDD;
}


function getTarget(e) {
   var targ;
   if (!e) var e = window.event;
   if (e.target) targ = e.target;
   else if (e.srcElement) targ = e.srcElement;
   if (targ.nodeType == 3) // defeat Safari bug
   targ = targ.parentNode;
   return targ
}

function getFilterId(button) {
   if(button == null) return;
   var name = button.name;
   var strs = name.split("_");
   var end = strs[1];
   if(isNaN(end)) {
      end = end.substring(1,end.length);
   }
   return end;
}

function removeField (event) {
   var button = getTarget(event);
   var filterId = getFilterId(button);
   var idName = "cfilter_id"+filterId;
   removeElement('filterbody',idName);
}

function changeField (event) {
   var button = getTarget(event);
   var filterId = getFilterId(button);
   var idName = 'cfilter_s'+filterId+'_id';
   var sel = document.getElementById(idName);
   
   var field = sel.options[sel.selectedIndex].value;
   changeToType(field,filterId);
}

function changeToType(field,filterId) {
   var fieldType = filterList[field]["type"];
   var fieldCompare = filterList[field]["compare"];
   var tr = document.getElementById("cfilter_id"+filterId);
   var td = document.getElementById("cfilter_td_"+filterId);
   //Remove old td
   tr.removeChild(td);
   //Create new td
   var newtd = document.createElement('td');
   newtd.className="searchDisplay";
   newtd.setAttribute("id","cfilter_td_"+filterId);
   
   //Add default compare select list
   var arr;
   if(fieldCompare == "text") {
   	arr = textCompareList;
   } else if(fieldCompare == "numeric") {
   	arr = numericCompareList;
   } else if(fieldCompare == "boolean") {
   	arr = booleanCompareList;
   }
   var compareSelect = addSelectList('cfilter_c'+filterId,arr);
   compareSelect.className="compare-select";
   newtd.appendChild(compareSelect);
   
   var filterFieldName = 'cfilter_t'+filterId;
      
   if(fieldType == "text") {
      var filterField = addTextField(filterFieldName);
      filterField.className="filter-text";
      newtd.appendChild(filterField);
   } else if(fieldType == "select") {
      var filterField = addSelectList(filterFieldName,filterList[field]["list"]);
	  filterField.className="filter-text";
	  newtd.appendChild(filterField);
   } else if(fieldType == "date") {
      var filterField = addTextField(filterFieldName); 
      //filterField.setAttribute("id",dateFieldId);
	  filterField.className="filter-text";
	  newtd.appendChild(filterField);
   } else if(fieldType == "dateTime") {
      var filterField = addTextField(filterFieldName); 
      //filterField.setAttribute("id",dateFieldId);
	  filterField.className="filter-text";
	  newtd.appendChild(filterField);
   }
   
   //Add remove button
   var filterButton = addButton('cbutton_'+filterId,'-');
   filterButton.className="button";
   filterButton.onclick = removeField;
   newtd.appendChild(filterButton);
   
   //Add new td to tr
   tr.appendChild(newtd);
   if(fieldType == "date") {
      var dateFieldId = filterFieldName+"_id";
	  Calendar.setup({ 
	                   "inputField":dateFieldId, 
					   "ifFormat": "%Y-%m-%d", 
					   "showsTime": false, 
					   "timeFormat": "12", 
					   "mondayFirst": false 
					});  
   }
   if(fieldType == "dateTime") {
      var dateFieldId = filterFieldName+"_id";
	  Calendar.setup({ 
	                   "inputField":dateFieldId, 
					   "ifFormat": "%Y-%m-%d %H:%M:%S", 
					   "showsTime": true,
					   "step": 1,
					   "timeFormat": "12", 
					   "mondayFirst": false 
					});  
   }
}



function addFilterSelect() {
   var sel = document.createElement("select");
   sel.setAttribute('name','cfilter_s'+filterCount);
   sel.setAttribute('id','cfilter_s'+filterCount+'_id');
   sel.className="filter-select";
   sel.onchange=changeField;
   //one way to write a function... you have to write it yourself!
   //myOnChange = new Function("e", "location.href=myselect.options[myselect.selectedIndex].value");
   //first option
   for (var word in filterList) {
      //listString += items[word] + ", ";
      var opt = document.createElement("option");
	  opt.setAttribute("value",word);
	  opt.appendChild(document.createTextNode(filterList[word]["name"]));
      sel.appendChild(opt);
   }
   return sel;
}

function addSelectList(fieldName,array) {
   var sel = document.createElement("select");
   sel.setAttribute('name',fieldName);
   sel.setAttribute("id",fieldName+"_id");
   for (var word in array) {
      var opt = document.createElement("option");
	  opt.setAttribute("value",word);
	  opt.appendChild(document.createTextNode(array[word]));
      sel.appendChild(opt);
   }
   return sel;
}

function addTextField(fieldName) {
   var text = document.createElement("input");
   text.setAttribute('type','text');
   text.setAttribute('name',fieldName);
   text.setAttribute("id",fieldName+"_id");
   return text;
}

function addButton(name,value) {
   var button = document.createElement('input');
   button.setAttribute('type','button');
   button.setAttribute('value',value);
   button.setAttribute('name',name);
   return button;
}

function removeElement(parent,child) {
   var p = document.getElementById(parent);
   var c = document.getElementById(child);
   p.removeChild(c);
}
