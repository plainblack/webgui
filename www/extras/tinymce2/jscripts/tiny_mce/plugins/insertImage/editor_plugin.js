/* Import theme specific language pack */
tinyMCE.importPluginLanguagePack('insertImage', 'en');

/**
 * Returns the HTML contents of the emotions control.
 */
function TinyMCE_insertImage_getControlHTML(control_name) {
        switch (control_name) {
		case "insertImage":
			case "insertdate":
				return tinyMCE.getButtonHTML(control_name, 'lang_insert_webgui_image', '{$pluginurl}/images/insertImage.gif', 'insertImage');
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
