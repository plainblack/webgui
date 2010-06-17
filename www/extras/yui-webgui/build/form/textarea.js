
// Initialize namespace
if (typeof WebGUI == "undefined") {
    var WebGUI = {};
}
if (typeof WebGUI.Form == "undefined") {
    WebGUI.Form = {};
}
WebGUI.Form.Textarea = {};

/****************************************************************************
 *
 * WebGUI.Form.Textarea 
 * Scripts for the textarea control.
 *
 */

WebGUI.Form.Textarea.checkMaxLength
= function () {
    var maxLength       = this.getAttribute('maxlength');
    var currentLength   = this.value.length;
    if (currentLength > maxLength) {
        this.value  = this.value.substring( 0, maxLength );
        alert( "This field can only contain " + maxLength + " characters" );
    }
}

WebGUI.Form.Textarea.setMaxLength
= function () {
    var x = document.getElementsByTagName('textarea');
    for ( var i = 0; i < x.length; i++ ) {
        if (x[i].getAttribute('maxlength')) {
            YAHOO.util.Event.addListener( x[i], "change", WebGUI.Form.Textarea.checkMaxLength );
            YAHOO.util.Event.addListener( x[i], "keyup", WebGUI.Form.Textarea.checkMaxLength );
        }
    }
}

YAHOO.util.Event.onDOMReady( function () { WebGUI.Form.Textarea.setMaxLength() } );

