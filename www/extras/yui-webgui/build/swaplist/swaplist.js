
// Initialize namespace
if (typeof WebGUI == "undefined") {
    var WebGUI = {};
}
if (typeof WebGUI.Form == "undefined") {
    WebGUI.Form = {};
}
if (typeof WebGUI.Form.SwapList == "undefined") {
    WebGUI.Form.SwapList = {};
}


/**
 * This object contains the functions necessary for operation of the 
 * WebGUI::Form::SwapList form control
 */

/****************************************************************************
 * WebGUI.Form.SwapList.addSelected(form, swapListName)
 * Adds the selected options in the "available" list to the "selected" list
 * form is a reference to the form containing the SwapList. swapListName is 
 * the name of the SwapList control
 */
WebGUI.Form.SwapList.addSelected = function (form, swapListName) {
    var fromList    = form[swapListName + "_available"];
    var toList      = form[swapListName + "_selected"];
    WebGUI.Form.SwapList.swapSelectedOptions(fromList, toList);
    WebGUI.Form.SwapList.updateHiddenValue(form, swapListName);
};

/****************************************************************************
 * WebGUI.Form.SwapList.removeSelected(form, swapListName)
 * Removes the selected options from the "selected" list and puts them in the
 * "available" list again.
 * form is a reference to the form containing the SwapList. swapListName is 
 * the name of the SwapList control
 */
WebGUI.Form.SwapList.removeSelected = function (form, swapListName) {
    var fromList    = form[swapListName + "_selected"];
    var toList      = form[swapListName + "_available"];
    WebGUI.Form.SwapList.swapSelectedOptions(fromList, toList);
    WebGUI.Form.SwapList.updateHiddenValue(form, swapListName);
};

/****************************************************************************
 * WebGUI.Form.SwapList.swapSelectedOptions(fromList, toList)
 * Adds the selected options in the "available" list to the "selected" list
 * fromList and toList are HTML element references
 */
WebGUI.Form.SwapList.swapSelectedOptions = function (fromList, toList) {
    // First add all the selected options
    for (var i = 0; i < fromList.options.length; i++) {
        if (fromList.options[i].selected) {
            var newOption           = fromList.options[i].cloneNode(true);
            newOption.selected      = false;
            toList.appendChild( newOption );
        }
    }

    // Next remove all the selected options
    // backwards so that the indexes don't get thrown off
    for (var i = fromList.options.length - 1; i >= 0; i--) {
        if (fromList.options[i].selected) {
            fromList.removeChild( fromList.options[i] );
        }
    }
};

/****************************************************************************
 * WebGUI.Form.SwapList.updateHiddenValue(form, swapListName)
 * Update the true "VALUE" of the SwapList. Since when the form is submitted
 * no options will really be selected, we stick them in a hidden form element.
 */
WebGUI.Form.SwapList.updateHiddenValue = function (form, swapListName) {
    var selected        = new Array();
    var selectedList    = form[swapListName + "_selected"];
    for (var i = 0; i < selectedList.options.length; i++) {
        selected.push( selectedList.options[i].value );
    }
    form[swapListName].value    = selected.join("\n");
};
