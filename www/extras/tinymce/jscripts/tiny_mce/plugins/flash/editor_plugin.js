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

/**
 * function to convert flash object tags to img 
 * or img tags to flash object tags
 */
function TinyMCE_flash_mkCodeCleanup(action, content) 
{
	switch(action) {
		case 'insertToEditor':
			content = replace(content);
			break;
		case 'getFromEditor':
			content = restore(content);
			break;
	}
	return content;

}

/**
 * object to manage a html tag. Maintains two lists of 
 * of attribute names and values and can parse a tag
 * through the populate method.
**/  
function TagObject()
{
	this.tagName = "";
	this.attributeNames = new Array();
	this.attributeValues = new Array();
	this.spaceRemoveRegex = new RegExp('[ ]*','g');
	this.newLineRemoveRegex = new RegExp('[\n]*','g');
}
/**
 * set the name of the tag 
 */
TagObject.prototype.setTagName = function(name)
{
	this.tagName = name;
}
/**
 * get the name of the tag
 */
TagObject.prototype.getTagName = function()
{
	return this.tagName;
}
/**
 * add a attribute name/value pair to the lists.
 * does not check for duplicate attribute names
 */
TagObject.prototype.addAttribute = function(name,value)
{
	this.attributeNames[this.attributeNames.length] = name;
	this.attributeValues[this.attributeValues.length] = value;
}
/**
 * returns array of attribute names
 */ 
TagObject.prototype.getAttributeNames = function()
{
	return this.attributeNames;
}
/**
 * returns array of attribute values
 */
TagObject.prototype.getAttributeValues = function()
{
	return this.attributeValues;
}
/**
 * parses a html tag i.e. <tag attribute1=value1 attribute2=value2 ..>
 * and sets the tag name and attribute name and value lists. All attribute
 * names are converted to lowercase.
 */
TagObject.prototype.populate = function( tag )
{
	//look for starting angle bracket
	var stIndex = 0;
	while( tag.charAt(stIndex) != '<')
	{
		stIndex++;
	}
	stIndex++;
	this.tagName = tag.substring(stIndex,tag.indexOf(" "));
	stIndex = tag.indexOf(" ");
	var endIndex;

	while(true)
	{
		//hunt for first equals
		endIndex = tag.indexOf("=",stIndex);
		if ( endIndex == -1 )
			break;

		var attrName = tag.substring(stIndex,endIndex); 
		attrName = attrName.replace(this.spaceRemoveRegex,"");
		attrName = attrName.replace(this.newLineRemoveRegex,"");
		attrName = attrName.toLowerCase();

		stIndex = endIndex+1;

		//hunt for first space
		endIndex = tag.indexOf(" ",stIndex);
		if ( endIndex == -1 )
		{
			//look for terminating angle bracket
			endIndex = tag.indexOf(">",stIndex);
			if ( endIndex == -1 )
				endIndex = tag.length;
		}
		var attrValue = tag.substring(stIndex,endIndex);
		attrValue = attrValue.replace("/>","");
		attrValue = attrValue.replace(">","");

		this.addAttribute(attrName,attrValue);
		stIndex = endIndex;

	}
}
/**
 * returns the value for a given attribute name. returns null
 * if the attribute name does not exist
 */
TagObject.prototype.getAttributeValue = function( attribName )
{
	for( var i = 0; i < this.attributeNames.length; i++ )
	{
		if ( this.attributeNames[i] == attribName )
			return this.attributeValues[i];
	}
	return null;
}
/**
 * sets a value for the given attribute name. If the attribute value
 * exists, it is replaced with the new value, otherwise a attribute
 * name/value pair is created.
 */
TagObject.prototype.setAttributeValue = function( attribName, attribValue )
{
	for( var i = 0; i < this.attributeNames.length; i++ )
	{
		if ( this.attributeNames[i] == attribName )
		{
			this.attributeValues[i] = attribValue;
			return;
		}
	}
	this.addAttribute (attribName,attribValue);
}



/**
 * convert img to flash object tags for the supplied html content
 * and returns the new content. 
 */
function restore(content)
{
	//ensure img tags are consistent by removing spaces and 
	//different cases
	content = content.replace(new RegExp('<[ ]*img','gi'),'<img');

	var newContent = "";
	var startString;
	var stImgIndex;
	var endImgIndex;
	var imgString;
	var stIndex = 0;
	var tagObjs;
	while( (stImgIndex = content.indexOf('<img',stIndex)) != -1 ) 
	{
		startString = content.substring(stIndex,stImgIndex);
		newContent = newContent.concat(startString);
		endImgIndex = content.indexOf('/>',stImgIndex);
		if ( endImgIndex == -1 ) //should be well formed
			break;

		stIndex = endImgIndex+"/>".length;
		imgString = content.substring(stImgIndex,stIndex);

		var tagObj = new TagObject();
		tagObj.populate(imgString);

		if ( tagObj.getAttributeValue("name") == '"mce_plugin_flash"')
		{

			var width = tagObj.getAttributeValue("width");
			var height = tagObj.getAttributeValue("height");
			var src = tagObj.getAttributeValue("alt");


			//create object replacement tags
			var objTags = decodeAttributes(tagObj);

			var obj =  getTagByName( objTags, "object");
			obj.setAttributeValue( "width", width );
			obj.setAttributeValue( "height", height );


			var embed = getTagByName( objTags, "embed");
			embed.setAttributeValue( "width", width );
			embed.setAttributeValue( "height", height );
			embed.setAttributeValue( "src", src );


			newContent = newContent.concat( 
					objectTagsToHTML(objTags));
		}
		else
		{
			newContent = newContent.concat(imgString);  
		}
	}
	newContent = newContent.concat(content.substring(stIndex,content.length));
	return newContent;
}



/**
 * convert flash object to img tags for the given html content and
 * returns the converted html. 
 */

function replace(content)
{

	//ensure object tags are consistent by removing spaces and 
	//different cases
	content = content.replace(new RegExp('<[ ]*object','gi'),'<object');
	content = content.replace(new RegExp('<[ ]*/object[ ]*>','gi'),'</object>');


	var newContent = "";
	var startString;
	var stObjIndex;
	var endObjIndex;
	var objString;
	var stIndex = 0;
	var tagObjs;
	while( (stObjIndex = content.indexOf('<object',stIndex)) != -1 ) 
	{
		startString = content.substring(stIndex,stObjIndex);
		newContent = newContent.concat(startString);

		endObjIndex = content.indexOf('</object>',stIndex);
		if ( endObjIndex == -1 ) //should be well formed
			break;

		stIndex = endObjIndex+"</object>".length;
		objString = content.substring(stObjIndex,stIndex);
		tagObjs = getObjectTags(objString);

		if ( tagObjs.length > 0 )
		{
			var objTag = getTagByName( tagObjs, "object");
			var height = objTag.getAttributeValue("height");
			var width = objTag.getAttributeValue("width");

			var embedTag = getTagByName(tagObjs,"embed");
			var src = embedTag.getAttributeValue("src"); 

			//encode object tags into attribute values
			var imgAttr = encodeObjectTags(tagObjs);
			var imgTag = '<img width='+width+' height='+height+
				' alt='+src+' title='+src+' '+imgAttr+
			' name="mce_plugin_flash" class="mce_plugin_flash" '+
			'src="' + (tinyMCE.getParam("theme_href") + 
			'/images/spacer.gif" />');
			newContent = newContent.concat(imgTag);
		}
		else
		{
			newContent = newContent.concat(objString);
		}
	}
	newContent = newContent.concat(content.substring(stIndex,content.length));
	return newContent;
}
/**
 * returns array of TagObject corresponding to the object, param and embed
 * tags (in that order) within the html of objStr. Returns a empty array
 * if the object tag does not correspond to a flash object. 
 */
function getObjectTags(objStr)
{
	var tagObjs = new Array(); 
	var tagObject;
	var stIndex = 0; 
	var endIndex = 0; 

	stIndex = objStr.indexOf("<object");
	if ( stIndex == -1 )
		return tagObjs;
	endIndex = objStr.indexOf(">");

	tagObject = new TagObject();	
	tagObject.populate(objStr.substring(stIndex,endIndex+1));

	//make sure this is a flash object
	if ( tagObject.getAttributeValue("classid") 
			!= "clsid:D27CDB6E-AE6D-11cf-96B8-444553540000")
		return tagObjs;

	tagObjs[tagObjs.length] = tagObject;

	//ensure param and embed tags are lower case and have no leading spaces
	objStr = objStr.replace(new RegExp('<[ ]*param','gi'),'<param');
	objStr = objStr.replace(new RegExp('<[ ]*/param[ ]*>','gi'),'</param>');
	objStr = objStr.replace(new RegExp('<[ ]*embed','gi'),'<embed');
	objStr = objStr.replace(new RegExp('<[ ]*/embed[ ]*>','gi'),'</embed>');

	//pull in param tags
	stIndex = endIndex;
	while( (endIndex = objStr.indexOf("<param",stIndex)) != -1 )
	{
		stIndex = endIndex;
		endIndex = objStr.indexOf(">",stIndex);
		tagObject = new TagObject();
		tagObject.populate(objStr.substring(stIndex,endIndex+1));
		tagObjs[tagObjs.length] = tagObject;
		stIndex = endIndex;
	} 

	//pull in embed tags
	endIndex = objStr.indexOf("<embed",stIndex); 
	if ( endIndex != -1 )
	{
		stIndex = endIndex;
		endIndex = objStr.indexOf(">",stIndex);
		tagObject = new TagObject();
		tagObject.populate(objStr.substring(stIndex,endIndex+1));
		tagObjs[tagObjs.length] = tagObject;
		stIndex = endIndex;
	}
	return tagObjs;
} 
/**
 * converts array TagObject to a html string representation of the tags 
 * and returns the string. This function assumes the array contains an 
 * object tag followed by some number of param tags and a ending embed tag. 
 */
function objectTagsToHTML( objTags )
{
	var htmlStr = "";
	for( var i = 0; i < objTags.length; i++ )
	{
		var tag = objTags[i];
		var tagAttrs = tag.getAttributeNames();
		var tagValues = tag.getAttributeValues();


		htmlStr = htmlStr.concat('<',tag.getTagName(),' ');  

		for( var j = 0; j < tagAttrs.length; j++ )
		{
			htmlStr = htmlStr.concat(tagAttrs[j],'=',tagValues[j],
				(j < tagAttrs.length-1) ? ' ' : ''); 
		}

		if (tag.getTagName() == "param")
			htmlStr = htmlStr.concat(' />\n');
		else
			htmlStr = htmlStr.concat('>\n');
	}
	htmlStr = htmlStr.concat('</embed>\n');
	htmlStr = htmlStr.concat('</object>\n');
	return htmlStr;

}
/**
 * converts the object tags into specially encoded tag attributes to
 * hold the content of the original tags. This allows the original content
 * of the tags to be stored withing these attributes and later restored to the
 * original tag structure. The object tag is stored via the "obj" attribute,
 * param tags into the "param" attribute and embed tag to the "embed" 
 * attribute. Each attribute/value of the tag is encoded into a question
 * mark delimited field like "?attribute1=value1?attribute2=value2..". Since
 * the attribute values may contain ?=" characters these are encoded into
 * special html like escape sequences prior to encoding the name value pairs.
 * Param tags are handled differently than object and embed tags since a
 * param tag is structured like <param name='paramName' value='paramValue' ..>
 * and there can be multiple param tags. These are encoded like
 * ?paramName1=paramValue1?paramName2=paramValue2. 
 */
function encodeObjectTags( objTags )
{
	var equal = "&eqs;";
	var quote = "&quot;";
	var question = "&quest;";

	var equalReplace = new RegExp('=','g');
	var quoteReplace = new RegExp('"','g');
	var questionReplace = new RegExp("[\?]",'g');


	var objAttr = 'obj="';
	var paramAttr = 'param="';
	var embedAttr = 'embed="';

	for( var i = 0; i < objTags.length; i++ )
	{
		var tagObj = objTags[i];
		var attrNames = tagObj.getAttributeNames();
		var attrValues = tagObj.getAttributeValues();

		if ( tagObj.getTagName() == 'object' )
		{
			for( var j = 0; j < attrNames.length; j++ )
			{
				var v = attrValues[j];
				v = v.replace(equalReplace,equal);
				v = v.replace(quoteReplace,quote);
				v = v.replace(questionReplace,question);

				objAttr = objAttr.concat('?',
					attrNames[j],'=',v);	
			}
		}
		else if ( tagObj.getTagName() == 'param' )
		{	

			var n = tagObj.getAttributeValue("name");
			var v = tagObj.getAttributeValue("value");

			n = n.replace(quoteReplace,quote);

			v = v.replace(equalReplace,equal);
			v = v.replace(quoteReplace,quote);
			v = v.replace(questionReplace,question);

			paramAttr =  paramAttr.concat('?',n,'=',v);
			
		}
		else if ( tagObj.getTagName() == 'embed' )
		{
			for( var j = 0; j < attrNames.length; j++ )
			{
				var v = attrValues[j];
				v = v.replace(equalReplace,equal);
				v = v.replace(quoteReplace,quote);
				v = v.replace(questionReplace,question);

				embedAttr = embedAttr.concat('?',
					attrNames[j],'=',v);	
			}
		}
	}
	objAttr = objAttr.concat('"'); 
	paramAttr = paramAttr.concat('"'); 
	embedAttr = embedAttr.concat('"'); 

	var imageAttr = objAttr+" "+paramAttr+" "+embedAttr;
	return imageAttr;
}

/**
 * decodes the obj,param, and embed attributes into a array of TagObjects.
 * If the special attributes don't exist, a array of default flash objects
 * is created.
 */ 
function decodeAttributes( tagObj )
{

	var objAttr = tagObj.getAttributeValue("obj");

	if ( objAttr == null )
		return creatDefaultFlashObjectTags();

	var paramAttr = tagObj.getAttributeValue("param");
	var embedAttr = tagObj.getAttributeValue("embed");
	var pArray = new Array(objAttr,paramAttr,embedAttr);

	var tagArray = new Array();

	var equal = "&eqs;";
	var quote = "&quot;";
	var question = "&quest;";

	var equalReplace = new RegExp(equal,'g');
	var quoteReplace = new RegExp(quote,'g');
	var questionReplace = new RegExp(question,'g');

	for( var i = 0; i < pArray.length; i++ )
	{

		var tObj; 

		if ( i == 0 )
		{
			tObj = new TagObject();
			tObj.setTagName("object");
		}
		else if ( i == 2 )
		{
			tObj = new TagObject();
			tObj.setTagName("embed");
		}


		//remove first question mark and begin and end quotes  
		var attr = pArray[i].substring(2,pArray[i].length-1);
		//break up name value pairs on question mark
		var pairs = attr.split('?');

		//for each name value pair break on equal sign
		//decode 
		for( var j = 0; j < pairs.length; j++ )
		{
			var nvpair = pairs[j].split('=');

			var name = nvpair[0];
			name = name.replace(quoteReplace,'"');

			var value = nvpair[1];
			value = value.replace(equalReplace,'=');
			value = value.replace(quoteReplace,'"');
			value = value.replace(questionReplace,'?');

			if ( i == 0 || i == 2 )
			{
				tObj.addAttribute(name,value)
			}
			else
			{
				tObj = new TagObject();
				tObj.setTagName("param");
				tObj.addAttribute('name',name);
				tObj.addAttribute('value',value);
				tagArray[tagArray.length] = tObj;
			}
		}
		if ( i != 1 )
			tagArray[tagArray.length] = tObj;
	}
	return tagArray;
}
/**
 * returns a TagObject from the array whose tag name matches tag name.
 */
function getTagByName( tagObjs, tagName )
{
	for( var i = 0; i < tagObjs.length; i++ )
	{
		var tObj = tagObjs[i];
		if ( tObj.getTagName() == tagName )
			return tObj;

	}
	return null;
}
/**
 * returns a TagObject corresponding to a param tag whose parameter value
 * of the name attribute matches paramName.
 */
function getParameterTagWithName( tagObjs, paramName )
{
	paramName = paramName.toLowerCase();
	for( var i = 0; i < tagObjs.length; i++ )
	{
		var tObj = tagObjs[i];
		if ( tObj.getTagName() != 'param' )
			continue;


		var name = tObj.getAttributeValue('name');
		name = name.toLowerCase();

		if ( name != paramName )
			continue;

		return tObj;
	}
	return null;
}
/**
 * build and return a array of TagObjects corresponding to a reasonable
 * default set of object,param, and embed tags for a flash movie. Note
 * that the height,width, and src attributes need to be set on the TagObjects
 * before converting to the array into a real set of flash tags.  
 */
function creatDefaultFlashObjectTags()
{
	var tagObjs = new Array();

	var objTag = new TagObject();
	objTag.setTagName('object');
	objTag.addAttribute('classid',
		'"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"');
	objTag.addAttribute('codebase',
		'"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=6,0,40,0"');

	tagObjs[tagObjs.length] = objTag;


	var paramTag = new TagObject();
	paramTag.setTagName('param');
	paramTag.addAttribute( 'name','"quality"'); 
	paramTag.addAttribute( 'value','"high"');
	tagObjs[tagObjs.length] = paramTag;

	paramTag = new TagObject();
	paramTag.setTagName('param');
	paramTag.addAttribute( 'name','"menu"'); 
	paramTag.addAttribute( 'value','"false"');
	tagObjs[tagObjs.length] = paramTag;

	var embedTag = new TagObject();
	embedTag.setTagName('embed');
	embedTag.addAttribute( 'quality','"high"'); 
	embedTag.addAttribute( 'type','"application/x-shockwave-flash"');
	embedTag.addAttribute( 'pluginspace','"http://www.macromedia.com/go/getflashplayer"');

	tagObjs[tagObjs.length] = embedTag;

	return tagObjs;
} 
