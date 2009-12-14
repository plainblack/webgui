/*global Survey, YAHOO, alert, initHoverHelp, window */
if (typeof Survey === "undefined") {
    var Survey = {};
}

Survey.ObjectTemplate = (function(){

	// Keep references to widgets here so that we can destory any instances before
	// creating new ones (to avoid memory leaks)
    var dialog, editor, resizeGotoExpression, gotoAutoComplete, editing;
        
    return {
        hideEditor: function(){
            YAHOO.util.Dom.setStyle("editor_container","visibility","hidden");
        },
        showEditor: function(){
            editor.get('element').value = YAHOO.util.Dom.get('texteditortarget').value;
            editor.setEditorHTML(YAHOO.util.Dom.get('texteditortarget').value);
            YAHOO.util.Dom.setStyle("editor_container","visibility","visible");
            YAHOO.util.Dom.setXY("editor_container",YAHOO.util.Dom.getXY(YAHOO.util.Dom.get("texteditortarget").id));
        },

        initObjectEditor: function() {
            editor = new YAHOO.widget.SimpleEditor("editor", {
                height: '100px',
                width: '570px',
                dompath: false 
            });

            if (editor.get('toolbar')) {
                editor.get('toolbar').titlebar = false;
            }
            editor.render();
        },
 
        unloadObject: function(){
            
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
            var hovers = YAHOO.util.Dom.getElementsByClassName('wg-hoverhelp');
            for (var i = 0; i < hovers.length; i++) {
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
                text: Survey.i18n.get('WebGUI',"submit"),
                handler: function(){
                    editor.saveHTML();
                    YAHOO.util.Dom.get('texteditortarget').value = editor.getEditorHTML();
                    Survey.ObjectTemplate.hideEditor();
                    this.submit();
                },
                isDefault: true
            }, {
                text: Survey.i18n.get('Asset',"Copy"),
                handler: function(){
                    document.getElementById('copy').value = 1;
                    this.submit();
                }
            }, {
                text: Survey.i18n.get('Asset_Survey',"cancel"),
                handler: function(){
                    this.cancel();
                    Survey.Comm.loadSurvey('-');
                }
            }, {
                text: Survey.i18n.get('WebGUI',"576"),
                handler: function(){
                    document.getElementById('delete').value = 1;
                    this.submit();
                }
            }, {
                text: Survey.i18n.get('WebGUI',"preview"),
                handler: function(){
                    if (type === 'answer') {
                        alert('Sorry, preview is only supported for Sections and Questions, not Answers');
                    }
                    else {
                        var msg = 'This will delete any in-progress Survey responses you have made under this ' +
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
                    text: Survey.i18n.get('Asset_Survey',"Make Default Type"),
                        handler: function(){
                            var name = prompt("Please change name to new type, or leave to update current type",document.forms[0].questionType.value);
                            if(name != null){
                                document.getElementById('addtype').value = name;
                                this.submit();
                        }
                    }
                };
                btns[btns.length] = {
                    text: Survey.i18n.get('Asset_Survey',"Remove Default Type"),
                    handler: function(){
                            document.getElementById('removetype').value = 1;
                            this.submit();
                    }
                };

            } 
            dialog = new YAHOO.widget.Dialog(type, {
                width: "600px",
                context: [document.body, 'tr', 'tr'],
                visible: false,
                buttons: btns,
                constrainToViewport: true
            });

            dialog.callback = Survey.Comm.callback;

            dialog.hideEvent.subscribe(Survey.ObjectTemplate.hideEditor);
            dialog.dragEvent.subscribe(Survey.ObjectTemplate.showEditor);

            dialog.render();

            resizeGotoExpression = new YAHOO.util.Resize('resize_gotoExpression_formId');
            resizeGotoExpression.on('resize', function(ev) {
                YAHOO.util.Dom.setStyle('gotoExpression_formId', 'width', (ev.width - 6) + "px");
                YAHOO.util.Dom.setStyle('gotoExpression_formId', 'height', (ev.height - 6) + "px");
                
                // Resizing the gotoExpression box can cause the texteditor to move, so update its position
                YAHOO.util.Dom.setXY("editor_container",YAHOO.util.Dom.getXY(YAHOO.util.Dom.get("texteditortarget").id));
            });
            
            // build the goto auto-complete widget
            if (gotoTargets && document.getElementById('goto')) {
                var ds =  new YAHOO.util.LocalDataSource(gotoTargets);
                gotoAutoComplete = new YAHOO.widget.AutoComplete('goto', 'goto-yui-ac-container', ds);
            }
            
            var textareaId = type + 'Text';
            var textarea = YAHOO.util.Dom.get(textareaId);

            dialog.show();
            initHoverHelp(type);
            Survey.ObjectTemplate.showEditor();
        }
    };
})();
