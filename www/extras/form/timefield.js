
/*** The WebGUI Asset Manager 
 * Requires: YAHOO, Dom, Event
 *
 */

if ( typeof WebGUI == "undefined" ) {
    WebGUI  = {};
}
if ( typeof WebGUI.TimeField == "undefined" ) {
    WebGUI.TimeField = {};
}

WebGUI.TimeField.init = function (o) {
    WebGUI.TimeField.i18n
    = new WebGUI.i18n( { 
            namespaces  : {
                'Form_TimeField' : [
                    "invalid time"
                ]
            }
        } );
}

WebGUI.TimeField.check = function( field ) {
    var timePattern = /^(\d{1,2})(:)?(\d{1,2})?(:)?(\d{1,2})?$/;
    var matchArray = field.value.match( timePattern );
    if( matchArray == null )
        return this.reject( field );

    hour = matchArray[1];
    minute = matchArray[3];
    second = matchArray[5];
    
    if( hour < 0  || hour > 23 )
        return this.reject( field );
        
    if( minute != null && ( minute < 0 || minute > 59 ) )
        return this.reject( field );
        
    if( second != null && ( second < 0 || second > 59 ) )
        return this.reject( field );
    
    return this.accept( field );
}

WebGUI.TimeField.reject = function( field ) {
    field.style.backgroundColor = "DarkSalmon";
    return false;
}

WebGUI.TimeField.accept = function( field ) { 
    field.style.backgroundColor = "";
    return false;
}

WebGUI.TimeField.munge = function( field ) { 
    var date = new Date( "01/01/01 " + field.value );
    var hour   = date.getHours();
    var minute = date.getMinutes();
    var second = date.getSeconds();
    //var ap = "AM";
    //if (hour   > 11) { ap = "PM";             }
    //if (hour   > 12) { hour = hour - 12;      }
    //if (hour   == 0) { hour = 12;             }
    if (hour   < 10) { hour   = "0" + hour;   }
    if (minute < 10) { minute = "0" + minute; }
    if (second < 10) { second = "0" + second; }
    field.value = hour + ':' + minute + ':' + second; // + " " +ap;
    
    if( field.value.indexOf("NaN") != -1 ) {
        field.value = "12:00:00";
        alert( WebGUI.TimeField.i18n.get('Form_TimeField', 'invalid time') );
        window.setTimeout( function() {
            field.focus();
            field.select();
            }, 1 );
    }
    
    field.style.backgroundColor = ""
    
    return false;
}

WebGUI.TimeField.init();