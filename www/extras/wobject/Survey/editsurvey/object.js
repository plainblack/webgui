if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.ObjectTemplate = new function(){

    this.loadObject = function(html,type){

        document.getElementById('edit').innerHTML = html;

	var myTextarea;

	var handleSubmit = function(){
		myTextarea.saveHTML(); 
		this.submit();
	}

        var butts = [ 
                { text:"Submit", handler:handleSubmit, isDefault:true }, 
                { text:"Copy", handler:function(){document.getElementById('copy').value = 1; this.submit();}},
                { text:"Cancel", handler:function(){this.cancel();}}, 
                { text:"Delete", handler:function(){document.getElementById('delete').value = 1; this.submit();}}
            ];

        var form = new YAHOO.widget.Dialog(type,
           { 
             width : "500px",
             fixedcenter : true,
             visible : false,
             constraintoviewport : true,
             buttons : butts
           } );

        form.callback = Survey.Comm.callback;
        form.render();

	if(type == 'question'){
	var resize = new YAHOO.util.Resize('resize_randomWords_formId');
	resize.on('resize', function(ev) {
		YAHOO.util.Dom.setStyle('randomWords_formId', 'width', (ev.width - 6) + "px");
		YAHOO.util.Dom.setStyle('randomWords_formId', 'height', (ev.height - 6) + "px");
	});
	}

	if(type == 'answer'){
	var resize = new YAHOO.util.Resize('resize_gotoExpression_formId');
	resize.on('resize', function(ev) {
		YAHOO.util.Dom.setStyle('gotoExpression_formId', 'width', (ev.width - 6) + "px");
		YAHOO.util.Dom.setStyle('gotoExpression_formId', 'height', (ev.height - 6) + "px");
	});
	}
	
	var textareaId = type+'Text';
	var textarea = YAHOO.util.Dom.get(textareaId);
	var height = YAHOO.util.Dom.getStyle(textarea,'height');
	if (height == ''){
 	height = '300px';
	}
	var width = YAHOO.util.Dom.getStyle(textarea,'width');
	if (width == ''){
		width = '500px';
	}
	myTextarea = new YAHOO.widget.SimpleEditor(textareaId, {
		height: height,
		width: width,
		dompath: false //Turns on the bar at the bottom
	});
	myTextarea.render();

        form.show();
    }
}();

