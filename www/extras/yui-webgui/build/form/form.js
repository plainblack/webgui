
// Initialize namespace
if (typeof WebGUI == "undefined") {
    var WebGUI = {};
}
if (typeof WebGUI.Form == "undefined") {
    WebGUI.Form = {};
}

/**
 * This object contains generic form modification functions
 */

/***********************************************************************************
   * @description This method assembles the form label and value pairs and
   * constructs an encoded string.
   * @method buildQueryString
   * @public
   * @static
   * @param {string || object} form id or name attribute, or form object.
   * @param {object} object containing array of form elements to exclude. { id:[], name:[], classNames:[], type:[] }  
   * @return {string} string of the HTML form field name and value pairs.
   */

WebGUI.Form.buildQueryString = function ( formId, excludes ) {
    
    var _isInArray = function ( value, array) {
        if(!array || !value) return 0;
        if(typeof array != 'object') return 0;
        
        for(var i = 0; i < array.length; i++) {
            if(array[i] == value) return 1;
        }
        return 0;
    };	
    
    var oForm = (document.getElementById(formId) || document.forms[formId]);
	var oElement, oName, oValue, oDisabled;
    var sFormData = "";

    if(!excludes) {
        excludes = {};
    }

	// Iterate over the form elements collection to construct the label-value pairs.
	for (var i=0; i<oForm.elements.length; i++){

		oElement  = oForm.elements[i];
		oDisabled = oElement.disabled;
		oName     = oElement.name;
		oValue    = oElement.value;
        oId       = oElement.id;
        oClass    = oElement.className;
        oType     = oElement.type;

        // Do not submit fields that are disabled or do not have a name attribute value.
        if(oDisabled || oName == "") continue;
        
        //Filter any excludes passed in
        if(_isInArray(oClass,excludes.classNames)) continue;
        if(_isInArray(oId,excludes.id)) continue;
        if(_isInArray(oName,excludes.name)) continue;
        if(_isInArray(oType,excludes.type)) continue;

        switch(oType) {
			case 'select-one':
			case 'select-multiple':
				for(var j=0; j<oElement.options.length; j++){
					if(oElement.options[j].selected){
						if(window.ActiveXObject){
							sFormData += encodeURIComponent(oName) + '=' + encodeURIComponent(oElement.options[j].attributes['value'].specified?oElement.options[j].value:oElement.options[j].text) + ";";
						}
						else{
							sFormData += encodeURIComponent(oName) + '=' + encodeURIComponent(oElement.options[j].hasAttribute('value')?oElement.options[j].value:oElement.options[j].text) + ";";
						}
					}
				}
				break;
			case 'radio':
			case 'checkbox':
				if(oElement.checked){
					sFormData += encodeURIComponent(oName) + '=' + encodeURIComponent(oValue) + ";";
				}
				break;
			case 'file':
				// stub case as XMLHttpRequest will only send the file path as a string.
			case undefined:
				// stub case for fieldset element which returns undefined.
			case 'reset':
				// stub case for input type reset button.
			default:
				sFormData += encodeURIComponent(oName) + '=' + encodeURIComponent(oValue) + ";";
		}
    }
	sFormData = sFormData.substr(0, sFormData.length - 1);
	return sFormData;
};

/***********************************************************************************
   * @description This method clears all the values of the form.  This is different than reset which will restore default values
   * @method clearForm
   * @public
   * @static
   * @param {string || object} id or object of the form element to clear values for.
   * @param {object} object containing array of form elements to exclude. { id:[], name:[], classNames:[], type:[] } 
   */

WebGUI.Form.clearForm = function ( oElement, excludes ) {

    var _isInArray = function ( value, array) {
        if(!array || !value) return 0;
        if(typeof array != 'object') return 0;

        for(var i = 0; i < array.length; i++) {
            if(array[i] == value) return 1;
        }
        return 0;
    };

    if(typeof oElement != 'object') oElement = document.getElementById(oElement);

    for (i = 0; i < oElement.length; i++) {
        var oType  = oElement[i].type.toLowerCase();
        var oClass = oElement[i].className;
        var oName  = oElement[i].name;
        var oId    = oElement[i].id;

        if(_isInArray(oClass,excludes.classNames)) continue;
        if(_isInArray(oId,excludes.id)) continue;
        if(_isInArray(oName,excludes.name)) continue;
        if(_isInArray(oType,excludes.type)) continue;

        switch (oType) {
            case "text":
            case "password":
            case "textarea":
            case "hidden":
                oElement[i].value = "";
                break;
            case "radio":
            case "checkbox":
                if (oElement[i].checked) {
                    oElement[i].checked = false;
                }
                break;
            case "select-one":
            case "select-multi":
                oElement[i].selectedIndex = -1;
                break;
            default:
                break;
        }
    }

    return;
};

/***********************************************************************************
   * @description This method gets the proper value of the form element passed in
   * @method getFormValue
   * @public
   * @static
   * @param {string || object} id or object of the form element to get the value of.
   */

WebGUI.Form.getFormValue = function ( oElement ) {

    if(typeof oElement != 'object') oElement = document.getElementById(oElement);

    var oType   = oElement.type;
	var oValue  = "";

    switch(oType) {
		case 'select-one':
		case 'select-multiple':
			for(var i=0; i<oElement.options.length; i++){
				if(oElement.options[i].selected){
					if(window.ActiveXObject){
						oValue = oElement.options[i].attributes['value'].specified?oElement.options[i].value:oElement.options[i].text;
					}
					else{
						oValue = oElement.options[i].hasAttribute('value')?oElement.options[i].value:oElement.options[i].text;
					}
				}
			}
			break;
        case 'radio':
		case 'checkbox':
			var form = oElement.form;
            var elem = null;
            for(var i = 0; i < form.length; i++) {
                if(form.elements[i].checked == true) {
                    oValue = form.elements[i].value;
                }
            }
			break;
		default:
			oValue = oElement.value;
	}

    return oValue;
};


/****************************************************************************
 * WebGUI.Form.toggleAllCheckboxesInForm ( formElement [, checkboxesName] )
 * Toggles all the checkboxes in the form, optionally limited by name.
 * Will automatically set them all to "checked" the first time
 */
WebGUI.Form.toggleAllCheckboxesInForm 
    = function (formElement, checkboxesName) {
        // Get the state to set
        var oldState    = WebGUI.Form.toggleAllCheckboxesState[formElement+checkboxesName]
        var state       = oldState ? "" : "checked";

        for (var i = 0; i < formElement.elements.length; i++) {
            var input = formElement.elements[i];
            if (!/^check/.test(input.type))
                continue;
            if (checkboxesName && input.name != checkboxesName) 
                continue;

            // Change the state
            input.checked = state;
            // Run the appropriate scripts
            if ( input.onchange )
                input.onchange();
        }

        // Update the saved state
        WebGUI.Form.toggleAllCheckboxesState[formElement+checkboxesName] = state;
    };


/*
 * WebGUI.Form.toggleAllCheckboxesState
 * An object containing a hash of <formname>+<checkboxesName> : 0|1 to save
 * the state of the toggled checkboxes. You can use this to set what the 
 * first run of toggleAllCheckboxesInForm will do.
 */
WebGUI.Form.toggleAllCheckboxesState = {};

