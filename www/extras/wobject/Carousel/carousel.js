function addItem () {
    var items_td = document.getElementById('items_td');
    var textAreas = items_td.getElementsByClassName('carouselItemText');
    var textAreaCount = textAreas.length;
    var newItemNumber = textAreaCount + 1;

    var Dom = YAHOO.util.Dom;
    var myConfig = {
        height: '80px',
        width: '500px',
	handleSubmit: true
    };

    var newItem_div = document.createElement('div');
    newItem_div.id = 'item_div'+newItemNumber;
    newItem_div.name = 'item_div_'+newItemNumber;
    items_td.appendChild(newItem_div);

    var newItem_textarea = document.createElement('textarea');
    newItem_textarea.id = 'item'+newItemNumber;
    newItem_textarea.name = 'item_'+newItemNumber;
    newItem_textarea.className = 'carouselItemText';

    var newItem_id_span = document.createElement('span');
    newItem_id_span.innerHTML = 'ID: <input type="text" id="newItem_id" name="itemId" value="">';
    newItem_div.appendChild(newItem_id_span);

    var newItem_id = document.getElementById('newItem_id');
    newItem_id.type = 'text';
    newItem_id.id = 'itemId'+newItemNumber;
    newItem_id.name = 'itemId_'+newItemNumber;
    newItem_id.value = 'carousel_item_'+newItemNumber;

    var newItem_deleteButton = document.createElement('input');
    newItem_deleteButton.type = 'button';	
    newItem_deleteButton.id = 'deleteItem'+newItemNumber;
    newItem_deleteButton.value = 'Delete this item';
    newItem_deleteButton.onclick = function(){deleteItem(this.id)};
    newItem_div.appendChild(newItem_deleteButton);

    newItem_div.appendChild(newItem_textarea);

    var newItem_break = document.createElement('br');
    newItem_div.appendChild(newItem_break);

    var myEditor = new YAHOO.widget.SimpleEditor('item'+newItemNumber, myConfig);
    myEditor.render();
}
function resetItemIds() {
    var items_td = document.getElementById('items_td');
    var textAreas = items_td.getElementsByClassName('carouselItemText');
    for (i=0;i<textAreas.length;i=i+1) {
	var oldId = textAreas[i].id.substring(4);
	var newId = i + 1;
	if(newId != oldId){
		var newTextareaId = 'item' + newId;
		var newTextareaName = 'item_' + newId;
		document.getElementById('item'+oldId).name = newTextareaName;
		document.getElementById('item'+oldId).id = newTextareaId;

		var newIdInputId = 'itemId' + newId;
		var newIdInputName = 'itemId_' + newId;
		document.getElementById('itemId'+oldId).name = newIdInputName;
		document.getElementById('itemId'+oldId).id = newIdInputId;

		var newDivId = 'item_div' + newId;
		document.getElementById('item_div'+oldId).id = newDivId;
		textAreas[i].id = newId;
	}
    }	
}
function deleteItem(deleteId){
    var itemDiv = document.getElementById(deleteId).parentNode;
    itemDiv.parentNode.removeChild(itemDiv);
    resetItemIds();	
}

