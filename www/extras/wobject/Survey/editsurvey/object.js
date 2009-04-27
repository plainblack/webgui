
/*global Survey, YAHOO */
if (typeof Survey === "undefined") {
    var Survey = {};
}

Survey.ObjectTemplate = (function(){

	// Keep references to widgets here so that we can destory any instances before
	// creating new ones (to avoid memory leaks)
    var dialog, editor, resizeGotoExpression, gotoAutoComplete;

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
            
            // remove the goto expression resizer
            if (resizeGotoExpression) {
                resizeGotoExpression.destroy();
                resizeGotoExpression = null;
            }
            
            if (gotoAutoComplete) {
                gotoAutoComplete.destroy();
                gotoAutoComplete = null;
            }
            
            // Remove all hover-help
            var hovers = document.getElementsByClassName('wg-hoverhelp');
            for (i = 0; i < hovers.length; i++) {
                var hover = hovers[i];
                if (!hover) {
                    continue;
                }
                YAHOO.util.Event.purgeElement(hover, true);
                hover.parentNode.removeChild(hover);
            }
            
            // Finally, purge everything from the edit node
            YAHOO.util.Event.purgeElement('edit', true);
            
        },

        loadObject: function(html, type, gotoTargets){
            // First unload everything that already exists
            this.unloadObject();
            
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
                    Survey.Comm.loadSurvey('-');
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
            if(type === 'question'){
                btns[btns.length] = {
                    text: "Make Default Type",
                        handler: function(){
                            var name = prompt("Please change name to new type, or leave to update current type",document.forms[0].questionType.value);
                            if(name != null){
                                document.getElementById('addtype').value = name;
                                this.submit();
                        }
                    }
                }
                btns[btns.length] = {
                    text: "Remove Default Type",
                        handler: function(){
                                document.getElementById('removetype').value = 1;
                                this.submit();
                    }
                }

            } 
            dialog = new YAHOO.widget.Dialog(type, {
                width: "600px",
                context: [document.body, 'tr', 'tr'],
                visible: false,
                buttons: btns
            });
            
            dialog.callback = Survey.Comm.callback;
            dialog.render();

            resizeGotoExpression = new YAHOO.util.Resize('resize_gotoExpression_formId');
            resizeGotoExpression.on('resize', function(ev) {
                YAHOO.util.Dom.setStyle('gotoExpression_formId', 'width', (ev.width - 6) + "px");
                YAHOO.util.Dom.setStyle('gotoExpression_formId', 'height', (ev.height - 6) + "px");
            });
            
            // build the goto auto-complete widget
            if (gotoTargets && document.getElementById('goto')) {
                var ds =  new YAHOO.util.LocalDataSource(gotoTargets);
                gotoAutoComplete = new YAHOO.widget.AutoComplete('goto', 'goto-yui-ac-container', ds);
            }
            
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
            initHoverHelp(type);
        }
    };
})();
