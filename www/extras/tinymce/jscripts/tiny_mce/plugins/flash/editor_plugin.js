/* Import theme specific language pack */
tinyMCE.importPluginLanguagePack('flash', 'uk,se,de');

function TinyMCE_flash_getControlHTML(control_name) {
    switch (control_name) {
        case "flash":
            return '<img id="{$editor_id}_flash" src="{$pluginurl}/images/flash.gif" title="{$lang_insert_flash}" width="20" height="20" class="mceButtonNormal" onmouseover="tinyMCE.switchClass(this,\'mceButtonOver\');" onmouseout="tinyMCE.restoreClass(this);" onmousedown="tinyMCE.restoreAndSwitchClass(this,\'mceButtonDown\');" onclick="tinyMCE.execInstanceCommand(\'{$editor_id}\',\'mceFlash\');" />';
    }
    return "";
}

/**
 * Executes the mceFlash command.
 */
function TinyMCE_flash_execCommand(editor_id, element, command, user_interface, value) {
    // Handle commands
    switch (command) {
        case "mceFlash":
            var template = new Array();
            template['file']   = '../../plugins/flash/flash.htm'; // Relative to theme
            template['width']  = 400;
            template['height'] = 180;
            var name = "", swffile = "", swfwidth = "", swfheight = "", mceDo = "insert";
            if (tinyMCE.selectedElement != null && tinyMCE.selectedElement.nodeName.toLowerCase() == "img"){
                tinyMCE.flashElement = tinyMCE.selectedElement;
                if (tinyMCE.flashElement) {
                    name    = tinyMCE.flashElement.getAttribute('name') ? tinyMCE.flashElement.getAttribute('name') : "";
                    if (name!='mce_plugin_flash')
                        return;
                    swfwidth   = tinyMCE.flashElement.getAttribute('width') ? tinyMCE.flashElement.getAttribute('width') : "";
                    swfheight  = tinyMCE.flashElement.getAttribute('height') ? tinyMCE.flashElement.getAttribute('height') : "";
                    swffile     = tinyMCE.flashElement.getAttribute('alt') ? tinyMCE.flashElement.getAttribute('alt') : "";
                    mceDo = "update";
                }
            }
            tinyMCE.openWindow(template, {editor_id : editor_id, swffile : swffile, swfwidth : swfwidth, swfheight : swfheight, mceDo : mceDo});                   
       return true;
   }
   // Pass to next handler in chain
   return false;
}

/**
 * Called when content cleanup is performed.
 */
function TinyMCE_flash_cleanup(type, content) {
	// Handle custom cleanup
	switch (type) {
		// Called when editor is filled with content
		case "insert_to_editor":
			return TinyMCE_flash_mkCodeCleanup('insertToEditor', content);

		// Called when editor is pass out content
		case "get_from_editor":
			return TinyMCE_flash_mkCodeCleanup('getFromEditor', content);
	}

	// Pass through to next handler in chain
	return content;
}

function TinyMCE_flash_handleNodeChange(editor_id, node, undo_index, undo_levels, visual_aid, any_selection) {
	function getAttrib(elm, name) {
		return elm.getAttribute(name) ? elm.getAttribute(name) : "";
	}

	tinyMCE.switchClassSticky(editor_id + '_flash', 'mceButtonNormal');

	do {
		if (node.nodeName.toLowerCase() == "img" && getAttrib(node, 'name').indexOf('mce_plugin_flash') == 0)
			tinyMCE.switchClassSticky(editor_id + '_flash', 'mceButtonSelected');
	} while ((node = node.parentNode));

	return true;
}

/* Custom cleanup functions for the Flash support */

/**/
// added 2004 by Michael Keck <me@michaelkeck.de>
// why such a thing?
// - okay it's needed to have a weelformated code for better searching
//   and replacement of some elements
function TinyMCE_flash_mkAttribOrder(content) {
    var attribOrder = new Array(
        'src','href','target','width','height','face','size','maxlength','border','align','valign',
        'cellpadding','cellspacing','colspan','rowspan','bgcolor','background','color','class','style',
        'alt','title','name','id','classid','codebase','menu','quality','pluginspage','type','value',
        'checked','disabled','readonly','selected','method','enctype',
        'onmouseover','onmouseout','onclick','onfocus','onblur','onchange','noshade'
    );
    var tagArray = new Array();
    tagArray = content.split('<');
    var orgTags = new Array();
    var newTags = new Array();
    tagCount = -1;
    for (var i=1; i<tagArray.length; i++) {
        if (tagArray[i].substring(0,1)!='/' && tagArray[i]!='') {
            tmpTag = tagArray[i].split('>');
            tagCount++;
            orgTags[tagCount] = '<' + tmpTag[0] + '>';
        }
    }
    for (var i=0; i<orgTags.length; i++) {
        newAttributesString = "";
        savedSlash = '>';
        var attribVals = new Array();
        if (orgTags[i].lastIndexOf('/>')!=-1) {
            savedSlash=' />';
        }
        if (orgTags[i].indexOf(" ")!=-1) {
            for (var j=0; j<attribOrder.length; j++) {
                if (orgTags[i].indexOf(' ' + attribOrder[j] + '="')!=-1) {
                   tmpAttrib    = orgTags[i].split(attribOrder[j]+'="');
                   if (typeof(tmpAttrib[1])!='undefined') {
                       tmpArrAttrib = tmpAttrib[1].split('"');
                       attribVals[attribOrder[j]]=tmpArrAttrib[0];
                   }
                }
            }
            for (var j=0; j<attribOrder.length; j++) {
                if (typeof(attribVals[attribOrder[j]])!='undefined') {
                    newAttributesString += ' ' + attribOrder[j] + '="' + attribVals[attribOrder[j]] + '"';
                }
            }
            savedTag   = '' + orgTags[i].substring(0,orgTags[i].indexOf(" ")) + newAttributesString + savedSlash + '';
            newTags[i] = savedTag;
        } else {
            newTags[i] = '' + orgTags[i] + '';
        }
    }
    for (var i=0; i<orgTags.length; i++){
         content = content.replace(orgTags[i],newTags[i]);
    }
    return content;
}

function TinyMCE_flash_mkCodeCleanup(action, content) {
// some code removes and replaces
    content = content.replace(new RegExp('\r\n','gi'),'\n');
    content = content.replace(new RegExp('>\n','gi'),'>');
    content = content.replace(new RegExp('\n<','gi'),'<');
    content = content.replace(new RegExp('<param value="[^"]*" name="Quality" />','gi'),'<param name="quality" value="high" />');
    content = content.replace(new RegExp('<param value="[^"]*" name="Menu" />','gi'),'<param name="menu" value="false" />');
    content = content.replace(new RegExp('<param value="([^"]*)" name="src" \/>','gi'),'<param name="src" value="$1" />');
    content = content.replace(new RegExp('<param value[^>]*>','gi'),'');
    content = content.replace(new RegExp('strong>','gi'),'b>');
    content = content.replace(new RegExp('em>','gi'),'em>');
    content = TinyMCE_flash_mkAttribOrder(content);
// a special order in attrib list is needed
    swfObjSearch = new RegExp('<object width="([^"]*)" height="([^"]*)" '
        + 'classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" '
        + 'codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0">'
        + '<param name="src" value="([^"]*)" />'
        + '<param name="quality" value="high" />'
        + '<param name="menu" value="false" />'
        + '</object>','gi');
    swfObjReplace = '<object width="$1" height="$2" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" '
        + 'codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0">'
        + '<param name="src" value="$3" /><param name="quality" value="high" /><param name="menu" value="false" />'
        + '<embed src="$3" width="$1" height="$2" menu="false" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" '
        + 'type="application/x-shockwave-flash"></embed></object>';
    content = content.replace(swfObjSearch,swfObjReplace);
    switch(action) {
        case 'insertToEditor':
            objSearch = new RegExp('<object width="([^"]*)" height="([^"]*)" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" '
                + 'codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0">'
                + '<param name="src" value="([^"]*)" /><param name="quality" value="high" /><param name="menu" value="false" />'
                + '<embed src="([^"]*)" width="([^"]*)" height="([^"]*)" menu="false" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" '
                + 'type="application/x-shockwave-flash"></embed></object>','gi');
            objReplace = '<img src="' + (tinyMCE.getParam("theme_href") + "/images/spacer.gif") + '" width="$1" height="$2" border="0" class="mce_plugin_flash" alt="$3" title="$3" name="mce_plugin_flash" />';
            content = content.replace(objSearch,objReplace);
        break;
        case 'getFromEditor':
            objSearch = new RegExp('<img src="([^"]*)" width="([^"]*)" height="([^"]*)" border="([^"]*)" class="mce_plugin_flash" alt="([^"]*)" title="([^"]*)" name="mce_plugin_flash" />','gi');
            objReplace = '<object width="$2" height="$3" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" '
                + 'codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,29,0">'
                + '<param name="src" value="$5" /><param name="quality" value="high" /><param name="menu" value="false" />'
                + '<embed src="$5" width="$2" height="$3" menu="false" quality="high" pluginspage="http://www.macromedia.com/go/getflashplayer" '
                + 'type="application/x-shockwave-flash"></embed></object>';
            content = content.replace(objSearch,objReplace);
        break;
    }
    content = content.replace(new RegExp('\r\n','gi'),'\n');
    content = content.replace(new RegExp('>\n','gi'),'>');
    content = content.replace(new RegExp('\n<','gi'),'<');
    content = TinyMCE_flash_mkAttribOrder(content);
    content = content.replace(new RegExp('\r\n','gi'),'\n');
    content = content.replace(new RegExp('>\n','gi'),'>');
    content = content.replace(new RegExp('\n<','gi'),'<');
    return content;
/**/
}

