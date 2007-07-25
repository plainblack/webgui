/* Import theme specific language pack */
tinyMCE.importPluginLanguagePack('collateral', 'en');

/**
 * Returns the HTML contents of the emotions control.
 */
function TinyMCE_collateral_getControlHTML(control_name) {
        switch (control_name) {
		case "collateral":
			return tinyMCE.getButtonHTML(control_name, 'lang_insert_macro', '{$pluginurl}/images/macro.gif', 'wgCollateral');
	}

	return "";
}

/**
 * Executes the mceEmotion command.
 */
function TinyMCE_collateral_execCommand(editor_id, element, command, user_interface, value) {
	// Handle commands
        switch (command) {
		case "wgCollateral":
			var template = new Array();

			template['file'] = '../../plugins/collateral/collateral.html'; // Relative to theme
			template['width'] = 600;
			template['height'] = 50;

			tinyMCE.openWindow(template, {editor_id : editor_id});

			return true;
	}

	// Pass to next handler in chain
	return false;
}
