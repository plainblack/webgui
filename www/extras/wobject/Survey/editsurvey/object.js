
/*global Survey, YAHOO */
if (typeof Survey === "undefined") {
    var Survey = {};
}

Survey.ObjectTemplate = (function(){

    var editor;
    var dialog;

    return {

        loadObject: function(html, type){

            document.getElementById('edit').innerHTML = html;

            var btns = [{
                text: "Submit",
                handler: function(){
                    editor.saveHTML();
                    this.submit();
                },
                isDefault: true
            }, {
                text: "Copy",
                handler: function(){
                    document.getElementById('copy').value = 1;
                    this.submit();
                }
            }, {
                text: "Cancel",
                handler: function(){
                    this.cancel();
                }
            }, {
                text: "Delete",
                handler: function(){
                    document.getElementById('delete').value = 1;
                    this.submit();
                }
            }];

            dialog = new YAHOO.widget.Dialog(type, {
                width: "600px",
                context: [document.body, 'tr', 'tr'],
                visible: false,
                constraintoviewport: true,
                buttons: btns
            });

            if (type !== 'answer') {
                btns.push({
                    text: "Preview",
                    handler: function(){
                        window.location.search = 'func=jumpTo;id=' + dialog.getData().id;
                    }
                });
            }

            dialog.callback = Survey.Comm.callback;
            dialog.render();

            var textareaId = type + 'Text';
            var textarea = YAHOO.util.Dom.get(textareaId);

            var height = YAHOO.util.Dom.getStyle(textarea, 'height');
            if (!height) {
                height = '300px';
            }
            editor = new YAHOO.widget.SimpleEditor(textareaId, {
                height: height,
                width: '100%',
                dompath: false //Turns on the bar at the bottom
            });

            if (editor.get('toolbar')) {
                editor.get('toolbar').titlebar = false;
            }
            editor.render();

            dialog.show();
        }
    };
})();

