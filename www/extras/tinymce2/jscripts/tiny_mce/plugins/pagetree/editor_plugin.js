/* Import theme specific language pack */
tinyMCE.importPluginLanguagePack('pagetree', 'en');

/**
 * Returns the HTML contents of the emotions control.
 */
function TinyMCE_pagetree_getControlHTML(control_name) {
        switch (control_name) {
		case "pagetree":
			return tinyMCE.getButtonHTML(control_name, 'lang_link_to_page', '{$pluginurl}/images/pagetree.gif', 'wgPageTree');
	}

	return "";
}

/**
 * Executes the mceEmotion command.
 */
var tinyMceSelectedText = '';
function TinyMCE_pagetree_execCommand(editor_id, element, command, user_interface, value) {
	// Handle commands
        switch (command) {
		case "wgPageTree":
			var inst = tinyMCE.getInstanceById(editor_id);
                        var focusElm = inst.getFocusElement();
                        tinyMceSelectedText = inst.selection.getSelectedText();
			var template = new Array();
			//Check for proper get delimiter
			var seperator = '';
			if (getWebguiProperty ("pageURL").match(/\?/)) { seperator = ';' } else { seperator = '?'}
			template['file'] = "../../../../../.." + getWebguiProperty ("pageURL") + seperator + 'op=richEditPageTree';
			template['width'] = 500;
			template['height'] = 500;
			tinyMCE.openWindow(template, {editor_id : editor_id, scrollbars : "yes"} );
			return true;
	}

	// Pass to next handler in chain
	return false;
}
