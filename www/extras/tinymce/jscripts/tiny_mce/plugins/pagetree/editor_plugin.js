/* Import theme specific language pack */

/**
 * Returns the HTML contents of the emotions control.
 */
function TinyMCE_pagetree_getControlHTML(control_name) {
        switch (control_name) {
		case "pagetree":
			return '<img id="{$editor_id}_collateral" src="{$pluginurl}/images/pagetree.gif" title="Link to a page in the WebGUI page tree" width="20" height="20" class="mceButtonNormal" onmouseover="tinyMCE.switchClass(this,\'mceButtonOver\');" onmouseout="tinyMCE.restoreClass(this);" onmousedown="tinyMCE.restoreAndSwitchClass(this,\'mceButtonDown\');" onclick="tinyMCE.execInstanceCommand(\'{$editor_id}\',\'wgPageTree\');">';
	}

	return "";
}

/**
 * Executes the mceEmotion command.
 */
function TinyMCE_pagetree_execCommand(editor_id, element, command, user_interface, value) {
	// Handle commands
        switch (command) {
		case "wgPageTree":
			var template = new Array();
						
			//alert(getWebguiProperty("pageURL"));

			template['file'] = "../../../../../.." + getWebguiProperty ("pageURL") + '?op=richEditPageTree';
			
		//	alert(template['file']);
			template['width'] = 500;
			template['height'] = 500;

			tinyMCE.openWindow(template, {editor_id : editor_id});

			return true;
	}

	// Pass to next handler in chain
	return false;
}
