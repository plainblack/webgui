
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

        for (var i in formElement.elements) {
            var input = formElement.elements[i];
            if (!/^check/.test(input.type))
                continue;
            if (checkboxesName && input.name != checkboxesName) 
                continue;

            input.checked = state;
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

