var classArray = [];

//-----------------------------------------------------------------------------------   
function addRow(row,ttbody,countId,data) {
    //Get the count
    var count   = getCount(countId);

    //Set default data
    if(data == null) data = {};

    //Clone The Row
    var tr      = row.cloneNode(true);

    //Get the row type
    var rowType = getRowType(tr.id);

    //Set the rowId
    tr.id  = rowType + '_' + count;
      
    //Reset Row Props
    var rowLen = tr.childNodes.length;
    for (var i = 0; i < rowLen; i++) {
        var td = tr.childNodes[i];
        if(td.nodeType != 1) continue;
          
        var colLen = td.childNodes.length;
        for( var j = 0; j < colLen; j++) {
            var node = td.childNodes[j];
            if(node.nodeType != 1) continue;
            var result = node.name.match(/([a-zA-Z]+)_(\d+)/);
            if(result != null) {
                node.name = result[1] + "_" + count;
                node.id   = result[1] + "_" + count + "_formId";
                var nodeValue = data[result[1]];
                var isSelect = node.type.indexOf("select") > -1
                if(nodeValue) {
                    if(isSelect) {
                        selectValue(node,nodeValue);
                    }
                    else if(node.type != "button") {
                        node.value = nodeValue;
                    }
                }
                else {
                    if(isSelect) {
                        selectValue(node,"");
                    }
                    else if(node.type != "button") {
                        node.value = "";
                    }
                }
                if(result[1] == "deleteButton" || result[1] == "orderDelButton") {
                    node.onclick = new Function('deleteRow(document.getElementById("' + rowType + '_' + count + '"),document.getElementById("' + ttbody.id + '"));');
                }
            }
        }
    }

    ttbody.appendChild(tr);
    incrementCount(countId);
}

//-----------------------------------------------------------------------------------   
function getPropCount() {
    return getCount("propCount_id");
}

//-----------------------------------------------------------------------------------   
function getOrderCount() {
    return getCount("orderCount_id");
}

//-----------------------------------------------------------------------------------   
function getCount(id) {
    var count = document.getElementById(id);
    return count.value;
}

//-----------------------------------------------------------------------------------   
function getRowType(id) {
    var parts = id.split("_");
    return parts[0];
}

//-----------------------------------------------------------------------------------   
function incrementCount(id) {
    var count = document.getElementById(id);
    var value = parseInt(count.value);
    value++;
    count.value = value;
    return value;
}

//-----------------------------------------------------------------------------------   
function incrementOrderCount() {
    return incrementCount("orderCount_id");
}

//-----------------------------------------------------------------------------------   
function incrementPropCount() {
    return incrementCount("propCount_id");
}

//-----------------------------------------------------------------------------------   
function deleteRow(row,ttbody) {
    var rowId   = row.id;
    var rowType = getRowType(rowId);
    var row1    = rowType + "_1";
    if(rowId != row1) {
        ttbody.removeChild(row);
        return;
    }
    alert(first_row_error_msg);
    return;
}

//-----------------------------------------------------------------------------------   
function getClasses() {
    if(classArray.length > 0) {
        return classArray;
    }
    for (var key in classValues) {
        classArray.push(key);
    }
    classArray.sort();
    return classArray;
}

//-----------------------------------------------------------------------------------   
function getClassValue() {
    var className = document.getElementById("className_formId");
    return className.value;
}

//-----------------------------------------------------------------------------------   
function getFirstChild(node) {
    var rowLen = node.childNodes.length;
    for (var i = 0; i < rowLen; i++) {
        if(node.childNodes[i].nodeType != 1) continue;
        return node.childNodes[i];
    }
    return null;
}  

//-----------------------------------------------------------------------------------   
function loadClasses(selectBox) {
    var classes = getClasses();
    var value   = "";
    if(dataValues.isNew != "true") {
        value = dataValues.className;
    }
    populateSelect(selectBox,classes,value);
    return;
}

//-----------------------------------------------------------------------------------   
function loadClassName (className) {
    //Delete Where Rows
    var propCount = getPropCount();
    for(var i = 2; i < propCount; i++) {
        var row = document.getElementById("row_" + i);
        if(row != null) {
            deleteRow(row,document.getElementById("whereBody"));
        }
    }
    //Delete Order Rows
    var orderCount = getOrderCount();
    for(var i = 2; i < orderCount; i++) {
        var row = document.getElementById("order_" + i);
        if(row != null) {
            deleteRow(row,document.getElementById("orderBody"));
        }
    }
            
    //Load the new properties from the classes
    var propSel  = document.getElementById("propSelect_1_formId");
    var orderSel = document.getElementById("orderSelect_1_formId");
    
    emptySelect(propSel);
    emptySelect(orderSel);

    var classValue = getClassValue();
    var propOpts   = classValues[classValue];
            
    populateSelect( propSel, propOpts, null, true );
    populateSelect( orderSel, propOpts, null, true );

    //Reset the counts
    setCount("propCount_id",2);
    setCount("orderCount_id",2);
            
    return;
}

//-----------------------------------------------------------------------------------   
function loadWhereRows(tbody) {
    var propCount     = getPropCount();
    //Change the names and ids of the default row
    var tr            = getFirstChild(tbody);
    tr.id             = "row_" + propCount;
            
    var propSelect    = document.getElementById("propSelect_formId");
    propSelect.name   = "propSelect_" + propCount;
    propSelect.id     = "propSelect_" + propCount + "_formId";
    var classValue    = getClassValue();
    var propOpts      = classValues[classValue];

    var opSelect      = document.getElementById("opSelect_formId");
    opSelect.name     = "opSelect_" + propCount;
    opSelect.id       = "opSelect_" + propCount + "_formId";

    var valText       = document.getElementById("valText_formId");
    valText.name      = "valText_" + propCount;
    valText.id        = "valText_" + propCount + "_formId";

    var deleteButton  = document.getElementById("deleteButton_formId");
    deleteButton.name = "deleteButton_" + propCount;
    deleteButton.id   = "deleteButton_" + propCount + "_formId";
    deleteButton.onclick = new Function('deleteRow(document.getElementById("row_'+propCount+'"),document.getElementById("whereBody"));');

    if(dataValues.isNew == "true") {
        // Build the default row
        populateSelect(propSelect,propOpts,null,true);
        incrementPropCount();
    }
    else {
        // Build existing rows
        var whereData  = dataValues.where;
        //Handle case where user chooses no constraints.
        var whereValue  = null;
        var selValue    = null;
        var valValue    = null;
        if(whereData[1] != null) {
            whereValue = whereData[1].propSelect;
            selValue   = whereData[1].opSelect;
            valValue   = whereData[1].valText;
        }
        //Populate the data
        populateSelect(propSelect,propOpts,whereValue,true);
        selectValue(opSelect,selValue);
        valText.value = valValue;

        incrementPropCount();
        for (var key in whereData) {
            if(key > 1) {
                addRow(tr,tbody,"propCount_id",whereData[key]);
            }
        }
    }
}

//-----------------------------------------------------------------------------------   
function selectValue (list, value) {
    for ( var i = 0; i < list.options.length; i++ ) {
        if(list.options[i].value == value) {
            list.options[i].selected = true;
            return;
        }
    }
}

//-----------------------------------------------------------------------------------   
function loadOrder(tbody) {
    var orderCount     = getOrderCount();
    //Change the names and ids of the default row
    var tr             = getFirstChild(tbody);
    tr.id              = "order_" + orderCount;
    
    var orderSelect    = document.getElementById("orderSelect_formId");
    orderSelect.name   = "orderSelect_" + orderCount;
    orderSelect.id     = "orderSelect_" + orderCount + "_formId";
    // Build the default row
    var classValue = getClassValue();
    var orderOpts   = classValues[classValue];

    var dirSelect      = document.getElementById("dirSelect_formId");
    dirSelect.name     = "dirSelect_" + orderCount;
    dirSelect.id       = "dirSelect_" + orderCount + "_formId";

    var deleteButton = document.getElementById("orderDelButton_formId");
    deleteButton.name = "orderDelButton_" + orderCount;
    deleteButton.id   = "orderDelButton_" + orderCount + "_formId";
    deleteButton.onclick = new Function('deleteRow(document.getElementById("order_' + orderCount + '"),document.getElementById("orderBody"));');

    if(dataValues.isNew == "true") {
        populateSelect(orderSelect,propOpts,null,true);
        incrementOrderCount();
    }
    else {
        // Build existing rows
        var orderData  = dataValues.order;
        //Handle case where user chooses no order.
        var orderValue  = null;
        var dirValue    = null;
        if(orderData[1] != null) {
            orderValue = orderData[1].orderSelect;
            dirValue   = orderData[1].dirSelect;
        }
        //Populate data
        populateSelect(orderSelect,orderOpts,orderValue,true);
        selectValue(dirSelect,dirValue);

        incrementOrderCount();
        for (var key in orderData) {
            if(key > 1) {
                addRow(tr,tbody,"orderCount_id",orderData[key]);
            }
        }
    }            
}

//-----------------------------------------------------------------------------------   
function populateSelect( list, data, value, isHash ) {
    if(isHash) {
        for ( var key in data ) {
            var opt = document.createElement("option");
            opt.setAttribute("value",key);
            if(key == value ) opt.setAttribute("selected",true);
            opt.appendChild(document.createTextNode(data[key]));
            list.appendChild(opt);
        }
    }
    else {
        for ( var i = 0; i < data.length; i++ ) {
            var opt = document.createElement("option");
            opt.setAttribute("value",data[i]);
            if(data[i] == value ) opt.setAttribute("selected",true);
            opt.appendChild(document.createTextNode(data[i]));
            list.appendChild(opt);
        }
    }

    //Fix IE Bug which causes dymamic repopulation to fail
    var newList = list;
    var col     = list.parentNode;
    col.removeChild(list);
    col.appendChild(newList);

    return;
}

//-----------------------------------------------------------------------------------   
function emptySelect ( list ) {
    //Remove all options from list except first one
    while (list.options.length > 1) {
        var elem = list.options[1];
        list.removeChild(elem);
    }
}

//-----------------------------------------------------------------------------------   
function setCount(id,value) {
    var count = document.getElementById(id);
    count.value = value;
}


YAHOO.util.Event.onDOMReady( function () {
    loadClasses(document.getElementById("className_formId"));
    loadWhereRows(document.getElementById("whereBody"));
    loadOrder(document.getElementById("orderBody"));
};


});

