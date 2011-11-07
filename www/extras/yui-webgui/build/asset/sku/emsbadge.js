
// Initialize namespace
if (typeof WebGUI == "undefined") {
    var WebGUI = {};
}
if (typeof WebGUI.Asset == "undefined") {
    WebGUI.Asset = {};
}
if(typeof WebGUI.Asset.Sku == "undefined") {
    WebGUI.Asset.Sku = {};
}
if(typeof WebGUI.Asset.Sku.EMSBadge == "undefined") {
    WebGUI.Asset.Sku.EMSBadge = {};
}

var timeout       = null;
var searchResults = [];

WebGUI.Asset.Sku.EMSBadge = {

    delayLookup     : function( ) {
        if(timeout != null) {
            clearTimeout(timeout);
        }
        timeout = setTimeout(WebGUI.Asset.Sku.EMSBadge.lookupAddress,300);
    },

    initForm        : function( ) {
        var addressCol = document.getElementById("emsbadge_container");
        var divs = addressCol.getElementsByTagName('div');
        for( var i = 0; i < divs.length; i++ ) {
            WebGUI.Asset.Sku.EMSBadge.setHoverStates( divs[i] );
            YAHOO.util.Event.addListener( divs[i], "click", WebGUI.Asset.Sku.EMSBadge.setAddress );
        }

        var formTbl = document.getElementById("emsbadge_form_tbl");
        var inputs  = formTbl.getElementsByTagName('input');
        for( var i = 0; i < inputs.length; i++ ) {
            var inputEl = inputs[i];
            YAHOO.util.Event.addListener(inputEl, "keydown", WebGUI.Asset.Sku.EMSBadge.delayLookup);
        }

    },

    lookupAddress   : function( ) {
        timeout = null;
        var url = searchUrl + ";" + WebGUI.Form.buildQueryString("emsbadge_form",{ name: ['func'] });

        YAHOO.util.Connect.asyncRequest('GET', url, {
            success: function(o) {
                searchResults = YAHOO.lang.JSON.parse(o.responseText);
                for( var i = 1; i <= 3; i++ ) {
                    document.getElementById('emsbadge_address_' + i).style.display='none';
                }
                
                for( var i = 0; i < searchResults.length; i++ ) {
                    if(i > 3) break;
                    var addressEl  = document.getElementById('emsbadge_address_' + (i+1));
                    var address    = searchResults[i];
                    var addressStr = "<span style='color:blue'>" + address.username + "</span>"
                        + "<br />";
                    addressStr += address.firstName + " " + address.lastName
                        + "<br />"
                        + address.address1
                        + "<br />";
                    if(address.state) {
                        addressStr += address.city + ", " + address.state + " " + address.code;
                    }
                    else {
                        addressStr += address.city + ", " + address.country;
                    }
                    if(address.email) {
                        addressStr += "<br />" + address.email;
                    }
                    addressEl.innerHTML = addressStr;
                    addressEl.style.display = '';
                }
            },
            failure: function(o) {}
        });
        
    },

    setAddress : function ( e ) {
        var el          = YAHOO.util.Event.getTarget(e);
        if(el.tagName == "SPAN") {
            el = el.parentNode;
        }
        var divClicked  = el.id;
        var parts       = divClicked.split("_");
        var index       = parseInt(parts[2]);
        var result      = searchResults[(index -1)];
        if( result == null ) return;
        document.getElementById('name_formId').value = result.firstName + " " + result.lastName;
        document.getElementById('organization_formId').value = result.organization;
        document.getElementById('address1_formId').value = result.address1;
        document.getElementById('address2_formId').value = result.address2;
        document.getElementById('address3_formId').value = result.address3;
        document.getElementById('city_formId').value = result.city;
        document.getElementById('state_formId').value = result.state;
        document.getElementById('zipcode_formId').value = result.code;
        document.getElementById('country_formId').value = result.country;
        document.getElementById('phone_formId').value = result.phoneNumber;
        document.getElementById('email_formId').value = result.email;
    },

    setHoverStates  : function( el ) {
        el.setAttribute("oldclass", el.className);
        el.onmouseover = function() { this.className = this.getAttribute("oldclass") + "_on"; };
        el.onmouseout  = function() { this.className = this.getAttribute("oldclass"); };
    }
}

YAHOO.util.Event.onDOMReady( function () {
    WebGUI.Asset.Sku.EMSBadge.initForm();
});


