WebguiStyleDesigner = function () {
    var Dom=YAHOO.util.Dom;
    var themeColors = [
        {
        "pageBackgroundColor"       : "#503020",
        "linkColor"                 : "#aaccff",
        "visitedLinkColor"          : "#aaccff",
        "utilityBackgroundColor"    : "#000000",
        "utilityTextColor"          : "#ffffff",
        "headerBackgroundColor"     : "#ffffff",
        "headerTextColor"           : "#000000",
        "navigationBackgroundColor" : "#443322",
        "navigationTextColor"       : "#aaccff",
        "contentBackgroundColor"    : "#805040",
        "contentTextColor"          : "#ffffff",
        "footerBackgroundColor"     : "#ffffff",
        "footerTextColor"           : "#000000"
         },
        {
        "pageBackgroundColor"       : "#A10101",
        "linkColor"                 : "#FFCACA",
        "visitedLinkColor"          : "#FFCACA",
        "utilityBackgroundColor"    : "#4A0000",
        "utilityTextColor"          : "#ffffff",
        "headerBackgroundColor"     : "#ffffff",
        "headerTextColor"           : "#000000",
        "navigationBackgroundColor" : "#FFF6F6",
        "navigationTextColor"       : "#FF0101",
        "contentBackgroundColor"    : "#888888",
        "contentTextColor"          : "#ffffff",
        "footerBackgroundColor"     : "#ffffff",
        "footerTextColor"           : "#000000"
         },
        {
        "pageBackgroundColor"       : "#000000",
        "linkColor"                 : "#cccccc",
        "visitedLinkColor"          : "#dddddd",
        "utilityBackgroundColor"    : "#000000",
        "utilityTextColor"          : "#ffffff",
        "headerBackgroundColor"     : "#ffffff",
        "headerTextColor"           : "#000000",
        "navigationBackgroundColor" : "#444444",
        "navigationTextColor"       : "#cccccc",
        "contentBackgroundColor"    : "#888888",
        "contentTextColor"          : "#ffffff",
        "footerBackgroundColor"     : "#ffffff",
        "footerTextColor"           : "#000000"
         },
        {
        "pageBackgroundColor"       : "#FFCC3D",
        "linkColor"                 : "#0000B3",
        "visitedLinkColor"          : "#0000B3",
        "utilityBackgroundColor"    : "#FFB300",
        "utilityTextColor"          : "#ffffff",
        "headerBackgroundColor"     : "#ffffff",
        "headerTextColor"           : "#000000",
        "navigationBackgroundColor" : "#D57F1C",
        "navigationTextColor"       : "#FFFFFF",
        "contentBackgroundColor"    : "#FFD683",
        "contentTextColor"          : "#000000",
        "footerBackgroundColor"     : "#ffffff",
        "footerTextColor"           : "#000000"
         }
        ];

    var drawThemeSwatch = function ( themeNumber ) {
        return '<a href="#" id="theme_'+themeNumber+'" class="themeSwatch"></a>';
    }
        
    var colorPickerFieldNames = {
        "pageBackgroundColor"       : "Page Background",
        "linkColor"                 : "Links",
        "visitedLinkColor"          : "Visited Links",
        "utilityBackgroundColor"    : "Utility Background",
        "utilityTextColor"          : "Utility Text",
        "headerBackgroundColor"     : "Header Background",
        "headerTextColor"           : "Header Text",
        "contentBackgroundColor"    : "Content Background",
        "contentTextColor"          : "Content Text",
        "navigationBackgroundColor" : "Navigation Background",
        "navigationTextColor"       : "Navigation Links",
        "footerBackgroundColor"     : "Footer Background",
        "footerTextColor"           : "Footer Text Color"
        };

     var colorPickerFieldOrder = [
        "pageBackgroundColor",
        "linkColor",
        "visitedLinkColor",
        "utilityBackgroundColor",
        "utilityTextColor",
        "headerBackgroundColor",
        "headerTextColor",
        "contentBackgroundColor",
        "contentTextColor",
        "footerBackgroundColor",
        "footerTextColor",
        "navigationBackgroundColor",
        "navigationTextColor"
        ];


    var drawColorPickerField = function (fieldName, fieldLabel) {
        var output = '<div class="fieldLabel">'+fieldLabel + '</div><a class="colorPickerFormSwatch" href="#" id="' + fieldName + '_swatch"></a>';
        output += '<input maxlength="7" name="' + fieldName + '" type="text" size="8" value="#000000" id="' + fieldName + '" /><br />'
        return output;
    }
    return {
        draw: function (companyName, logoUrl) {
            var output = ' <div id="themeContainer"> <div style="float: left; margin: 5px;">Themes: </div> ';
            for (var i in themeColors) {
                output += drawThemeSwatch(i);
            }
            output += ' <div class="endFloat"></div> </div>';
            output += '<div id="colorOptions">';
            for (var i in colorPickerFieldOrder) {
                fieldName = colorPickerFieldOrder[i];
                output += drawColorPickerField(fieldName, colorPickerFieldNames[fieldName]);
            }
            output += '</div>';
            output += '<div id="body"> <div id="pageWidthContainer"> <div id="pageUtilityContainer"> <div id="utilityLinksContainer"><a href="#">Admin</a> :: <a href="#">Logout</a> :: <a href="#">Print!</a></div> <div id="editToggleContainer"><a href="#">Turn Admin On</a></div> <div class="clearFloat"></div> </div> <div id="pageHeaderContainer"> <div id="companyNameContainer">'+ companyName + '</div> <div id="pageHeaderLogoContainer"><a href="#"><img src="'+ logoUrl +'" id="logo" alt="logo" /></a></div> <div class="clearFloat"></div> </div> <div id="pageBodyContainer"> <div id="mainNavigationContainer"><p><a href="#">Contact Us</a><br /><a href="#">About Us</a><br /><a href="#">Products</a><br /><a href="#">Services</a><br /><a href="#">Training</a><br /><a href="#">Store</a><br /></p></div> <div id="mainBodyContentContainer"> <p> Morbi quis erat et metus laoreet pretium. Aenean ultrices mi in magna. Duis mattis neque sed sem dignissim mollis.  Vestibulum eleifend luctus enim. Mauris laoreet <a href="#">lorem convallis sapien</a>.  Integer ut tellus sit amet augue tincidunt eleifend. Cras eu velit. Fusce feugiat. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos hymenaeos. Donec semper arcu tristique orci.  Suspendisse potenti. Vivamus tempus mattis enim. Duis leo elit, interdum ac, pretium nec, porta a, nisi. Nulla pellentesque est ut nunc. Phasellus nonummy purus non nulla.  </p> </div> <div class="clearFloat"></div> </div> <div id="pageFooterContainer"> <div id="copyrightContainer">&copy 2001 '+ companyName + '. All Rights Reserved.</div> <div class="clearFloat"></div> </div> </div> </div>';
            return output;
        },
        init: function () {
            for (var i in colorPickerFieldOrder) {
                fieldName = colorPickerFieldOrder[i];
                var field = Dom.get(fieldName);
                var swatch = Dom.get(fieldName+"_swatch");
                swatch.style.backgroundColor = field.value;
                swatch.onclick = function () {
                    var id = this.id.replace(/(\w+)_swatch/,"$1");
                    YAHOO.WebGUI.Form.ColorPicker.display(id, this.id);
                    return false;
                }
                field.onchange = function () {
                    Dom.get(this.id+"_swatch").style.backgroundColor = this.value;
                    switch(this.id) {
                        case "pageBackgroundColor": Dom.get("body").style.backgroundColor = this.value; break;
                        case "linkColor": document.linkColor = this.value; break;
                        case "visitedLinkColor": document.vlinkColor = this.value; break;
                        case "utilityBackgroundColor": Dom.get("pageUtilityContainer").style.backgroundColor = this.value; break;
                        case "utilityTextColor": Dom.get("pageUtilityContainer").style.color = this.value; break;
                        case "headerBackgroundColor": Dom.get("pageHeaderContainer").style.backgroundColor = this.value; 
                            Dom.get("pageHeaderLogoContainer").style.backgroundColor = this.value; break;
                        case "headerTextColor": Dom.get("pageHeaderContainer").style.color = this.value; break;
                        case "contentBackgroundColor": Dom.get("pageBodyContainer").style.backgroundColor = this.value; break;
                        case "contentTextColor": Dom.get("pageBodyContainer").style.color = this.value; break;
                        case "navigationBackgroundColor": Dom.get("mainNavigationContainer").style.backgroundColor = this.value; break;
                        case "navigationTextColor": 
                            var tags = Dom.get("mainNavigationContainer").getElementsByTagName("a");
                            for (var i = 0; i < tags.length; i++) { 
                                tags[i].style.color = this.value;
                                tags[i].style.linkColor = this.value;
                                tags[i].style.vlinkColor = this.value;
                            }
                            break;
                        case "footerBackgroundColor": Dom.get("pageFooterContainer").style.backgroundColor = this.value; break;
                        case "footerTextColor": Dom.get("pageFooterContainer").style.color = this.value; break;
                    }
                }
            }
            for (var i in themeColors) {
                theme = Dom.get("theme_" + i);
                themeColorSet = themeColors[i];
                theme.style.backgroundColor = themeColorSet["pageBackgroundColor"];
                theme.style.borderColor = themeColorSet["linkColor"];
                theme.onclick = function () {
                    var id = this.id.replace(/theme_(\d+)/,"$1");
                    var themeColorSet = themeColors[id];
                    for (var j in themeColorSet) {
                        var field = Dom.get(j);
                        field.value = themeColorSet[j];
                        field.onchange(); 
                    }
                } 
            }
            Dom.get("theme_0").onclick();
        }
    }
}();


YAHOO.util.Event.on(window, "load", WebguiStyleDesigner.init);


