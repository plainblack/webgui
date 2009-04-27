//YAHOO.util.Event.addListener(window, "load", function() {
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

    var newItem_textarea = document.createElement('textarea');
    newItem_textarea.id = 'item'+newItemNumber;
    newItem_textarea.name = 'item_'+newItemNumber;
    newItem_textarea.className = 'carouselItemText';

    var newItem_id_span = document.createElement('span');
    newItem_id_span.innerHTML = 'ID: <input type="text" id="newItem_id" name="itemId" value="">';
    items_td.appendChild(newItem_id_span);

    var newItem_id = document.getElementById('newItem_id');
    newItem_id.type = 'text';
    newItem_id.id = 'itemId'+newItemNumber;
    newItem_id.name = 'itemId_'+newItemNumber;
    newItem_id.value = 'carousel_item_'+newItemNumber;

    items_td.appendChild(newItem_textarea);

    var newItem_break = document.createElement('br');
    items_td.appendChild(newItem_break);

    var myEditor = new YAHOO.widget.SimpleEditor('item'+newItemNumber, myConfig);
    myEditor.render();
    }
//});