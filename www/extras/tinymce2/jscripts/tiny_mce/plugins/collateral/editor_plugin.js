/* Import theme specific language pack */
//tinyMCE.importPluginLanguagePack('emotions', 'uk,se');

/**
 * Returns the HTML contents of the emotions control.
 */
function TinyMCE_collateral_getControlHTML(control_name) {
        switch (control_name) {
		case "collateral":
			return '<img id="{$editor_id}_collateral" src="{$pluginurl}/images/macro.gif" title="Add a WebGUI macro" width="20" height="20" class="mceButtonNormal" onmouseover="tinyMCE.switchClass(this,\'mceButtonOver\');" onmouseout="tinyMCE.restoreClass(this);" onmousedown="tinyMCE.restoreAndSwitchClass(this,\'mceButtonDown\');" onclick="tinyMCE.execInstanceCommand(\'{$editor_id}\',\'wgCollateral\');">';
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
