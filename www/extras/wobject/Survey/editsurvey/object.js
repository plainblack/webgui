
/*global Survey, YAHOO */
if (typeof Survey === "undefined") {
    var Survey = {};
}

Survey.ObjectTemplate = (function(){

	// Keep references to widgets here so that we can destory any instances before
	// creating new ones (to avoid memory leaks)
    var dialog;
    var editor;

    return {
    
        unloadObject: function(){
            // First destory the editor..
            if (editor) {
				editor.destroy();
				editor = null;
			}
            
            // And then the Dialog that contains it.
            if (dialog) {
				dialog.destroy();
				dialog = null;
			}
        },

        loadObject: function(html, type){
            // Make sure we purge any event listeners before overwrite innerHTML..
            YAHOO.util.Event.purgeElement('edit', true);
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
            }, {
                text: "Preview",
                handler: function(){
                    if (type === 'answer') {
                        alert('Sorry, preview is only supported for Sections and Questions, not Answers');
                    }
                    else {
                        var msg = 'This will delete any Survey responses you have made under this ' +
                        'user account and redirect you to the Take Survey page starting at the selected item. ' +
                        "\n\nAre you sure you want to continue?";
                        if (confirm(msg)) {
                            window.location.search = 'func=jumpTo;id=' + dialog.getData().id;
                        }
                    }
                }
            }];
            
            dialog = new YAHOO.widget.Dialog(type, {
                width: "600px",
                context: [document.body, 'tr', 'tr'],
                visible: false,
                constraintoviewport: true,
                buttons: btns
            });
            
            dialog.callback = Survey.Comm.callback;
            dialog.render();
            
            var textareaId = type + 'Text';
            var textarea = YAHOO.util.Dom.get(textareaId);
            
            var height = YAHOO.util.Dom.getStyle(textarea, 'height');
            if (!height) {
                height = '300px';
            }

			// N.B. SimpleEditor has a memory leak so this eats memory on every instantiation
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
