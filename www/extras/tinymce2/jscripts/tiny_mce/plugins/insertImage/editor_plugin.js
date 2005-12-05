/* Import theme specific language pack */

/**
 * Returns the HTML contents of the emotions control.
 */
function TinyMCE_insertImage_getControlHTML(control_name) {
        switch (control_name) {
		case "insertImage":
			return '<img id="{$editor_id}_insertImage" src="{$pluginurl}/images/insertImage.gif" title="Insert a WebGUI collateral image" width="20" height="20" class="mceButtonNormal" onmouseover="tinyMCE.switchClass(this,\'mceButtonOver\');" onmouseout="tinyMCE.restoreClass(this);" onmousedown="tinyMCE.restoreAndSwitchClass(this,\'mceButtonDown\');" onclick="tinyMCE.execInstanceCommand(\'{$editor_id}\',\'insertImage\');">';
	}

	return "";
}

/**
 * Executes the mceEmotion command.
 */
function TinyMCE_insertImage_execCommand(editor_id, element, command, user_interface, value) {
	// Handle commands
        switch (command) {
		case "insertImage":
			var template = new Array();

			template['file'] = '../../plugins/insertImage/insertImage.html'; // Relative to theme
			template['width'] = 505;
			template['height'] = 520;

			tinyMCE.openWindow(template, {editor_id : editor_id});

			return true;
	}

	// Pass to next handler in chain
	return false;
}
