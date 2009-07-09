
// Requires YUI Connection and JSON

if ( typeof WebGUI == "undefined" ) {
    WebGUI  = {};
}
if ( typeof WebGUI.ShipDriver == "undefined" ) {
    WebGUI.ShipDriver = {};
}
if ( typeof WebGUI.ShipDriver.UPS == "undefined" ) {
    WebGUI.ShipDriver.UPS = {};
}

WebGUI.ShipDriver.UPS.changeServices
= function ( newService, elementId ) {
    
    var el      = document.getElementById(elementId);
    //Delete old options
    var wasSelected = el.options[el.selectedIndex].value;
    while ( el.options.length >= 1 ) {
        el.remove(0);
    }
    var fields  = {};
    switch (newService) {
        case 'us domestic'      : fields = WebGUI.ShipDriver.UPS.US_Domestic;
                                  break;
        case 'us international' : fields = WebGUI.ShipDriver.UPS.US_International;
                                  break;
        default                 : fields = WebGUI.ShipDriver.UPS.US_Domestic;
    }
    //Add new options to the same form element
    for ( var key in fields ) {
        var isSelected = key == wasSelected ? true : false;
        el.options[el.options.length]
            = new Option( fields[key], key, isSelected, isSelected );
    }
};


/*---------------------------------------------------------------------------
    WebGUI.ShipDriver.UPS.initI18n ( )
    Initialize the i18n interface
*/
WebGUI.ShipDriver.UPS.initI18n = function (o) {
    WebGUI.ShipDriver.UPS.i18n
    = new WebGUI.i18n( { 
            namespaces  : {
                'ShipDriver_UPS' : [
                    "us domestic 01",
                    "us domestic 02",
                    "us domestic 03",
                    "us domestic 12",
                    "us domestic 13",
                    "us domestic 14",
                    "us domestic 59",
                    "us international 07",
                    "us international 08",
                    "us international 11",
                    "us international 54",
                    "us international 65",
                ]
            },
            onpreload   : {
                fn       : WebGUI.ShipDriver.UPS.initServiceTables
            }
        } );
};

WebGUI.ShipDriver.UPS.initServiceTables = function () {
    //These objects provide dropdown list labels and values.  The values
    //are API defined UPS Service codes.
    WebGUI.ShipDriver.UPS.US_Domestic = {
        '01' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 01'),
        '02' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 02'),
        '03' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 03'),
        '12' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 12'),
        '13' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 13'),
        '14' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 14'),
        '59' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 59')
    };

    WebGUI.ShipDriver.UPS.US_International = {
        '01' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 01'     ),
        '02' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 02'     ),
        '03' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 03'     ),
        '07' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us international 07'),
        '08' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us international 08'),
        '11' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us international 11'),
        '12' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 12'     ),
        '14' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 14'     ),
        '54' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us international 54'),
        '59' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us domestic 59'     ),
        '65' : WebGUI.ShipDriver.UPS.i18n.get('ShipDriver_UPS', 'us international 65')
    };

    var shipType     = document.getElementById('shipType_formId');
    var selectedType = shipType.options[shipType.selectedIndex].value;
    WebGUI.ShipDriver.UPS.changeServices(selectedType, 'shipService_formId');

}
