if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.ObjectTemplate = new function(){

    this.loadObject = function(html,type){

        document.getElementById('edit').innerHTML = html;

        var butts = [ 
                { text:"Submit", handler:function(){this.submit();}, isDefault:true }, 
                { text:"Copy", handler:function(){document.getElementById('copy').value = 1; this.submit();}},
                { text:"Cancel", handler:function(){this.cancel(); Survey.Comm.loadSurvey('-');}}, 
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
        form.show();
        initHoverHelp(type);
    }
}();

