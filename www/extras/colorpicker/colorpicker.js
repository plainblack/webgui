WebguiColorPicker = function() {
    var Slider=YAHOO.widget.Slider;
    var Color=YAHOO.util.Color;
    var Dom=YAHOO.util.Dom;

    var pickerSize=180;
    
    var hue,picker,panel;

    // hue, int[0,359]
    var getH = function() {
        var h = (pickerSize - hue.getValue()) / pickerSize;
        h = Math.round(h*360);
        return (h == 360) ? 0 : h;
    }

    // saturation, int[0,1], left to right
    var getS = function() {
        return picker.getXValue() / pickerSize;
    }

    // value, int[0,1], top to bottom
    var getV = function() {
        return (pickerSize - picker.getYValue()) / pickerSize;
    }

    var swatchUpdate = function() {
        var h=getH(), s=getS(), v=getV();

        Dom.get("hval").value = h;
        Dom.get("sval").value = Math.round(s*100);
        Dom.get("vval").value = Math.round(v*100);

        var rgb = Color.hsv2rgb(h, s, v);

        var styleDef = "rgb(" + rgb.join(",") + ")";
        Dom.setStyle("swatch", "background-color", styleDef);

        Dom.get("rval").value = rgb[0];
        Dom.get("gval").value = rgb[1];
        Dom.get("bval").value = rgb[2];

        Dom.get("hexval").value = Color.rgb2hex(rgb[0], rgb[1], rgb[2]);
    };

    var hueUpdate = function(newOffset) {
        var rgb = Color.hsv2rgb(getH(), 1, 1);
        var styleDef = "rgb(" + rgb.join(",") + ")";
        Dom.setStyle("pickerDiv", "background-color", styleDef);

        swatchUpdate();
    };

    pickerUpdate = function(newOffset) {
        swatchUpdate();
    };
    var currentColorField = "";

    return {
        init: function () {
            var ddPicker = document.createElement('div');
            ddPicker.id = "ddPicker";
            ddPicker.style.display = "none";
            document.body.appendChild(ddPicker);
        },

        setColor: function () {
            var color = "#"+document.getElementById("hexval").value;
            currentColorField.value = color;
            currentColorField.onchange();
            ddPicker = Dom.get("ddPicker");
            ddPicker.innerHTML = "";
            ddPicker.style.display = "none";
        
        },

        display: function (field) {
            currentColorField = document.getElementById(field); 
            var extras = getWebguiProperty("extrasURL");
            ddPicker = Dom.get("ddPicker");
            ddPicker.style.top = YAHOO.util.Dom.getY(currentColorField) + "px";
            ddPicker.style.left = YAHOO.util.Dom.getX(currentColorField) + "px";
            ddPicker.style.display = "block";
            ddPicker.innerHTML = ' <div id="pickerHandle">&nbsp;</div> <div id="pickerDiv" tabindex="-1" hidefocus="true"> <img id="pickerbg" src="' + extras + 'colorpicker/pickerbg.png" alt="" /> <div id="selector"><img src="' + extras + 'colorpicker/select.gif" /></div> </div> <div id="hueBg" tabindex="-1" hidefocus="true"> <div id="hueThumb"><img src="' + extras + 'colorpicker/hline.png" /></div> </div> <div id="valdiv"> <form name="rgbform"> <br /> R <input autocomplete="off" name="rval" id="rval" type="text" value="0" size="3" maxlength="3" /> H <input autocomplete="off" name="hval" id="hval" type="text" value="0" size="3" maxlength="3" /> <br />G <input autocomplete="off" name="gval" id="gval" type="text" value="0" size="3" maxlength="3" /> S <input autocomplete="off" name="gsal" id="sval" type="text" value="0" size="3" maxlength="3" /> <br /> B <input autocomplete="off" name="bval" id="bval" type="text" value="0" size="3" maxlength="3" /> V <input autocomplete="off" name="vval" id="vval" type="text" value="0" size="3" maxlength="3" /> <br /> <br /> # <input autocomplete="off" name="hexval" id="hexval" type="text" value="0" size="6" maxlength="6" /> <br /> <input type="button" value="Set" onclick="WebguiColorPicker.setColor()" /> </form> </div> <div id="swatch">&nbsp;</div> ';
            hue = Slider.getVertSlider("hueBg", "hueThumb", 0, pickerSize);
            hue.subscribe("change", hueUpdate);

            picker = Slider.getSliderRegion("pickerDiv", "selector", 0, pickerSize, 0, pickerSize);
            picker.subscribe("change", pickerUpdate);
            hueUpdate(0);
            panel = new YAHOO.util.DD("ddPicker");
            panel.setHandleElId("pickerHandle");

            // set field color
            var color = currentColorField.value; 
            color = color.substring(1,7);
            var hsv = Color.hex2hsv(color);
            hue.setValue(pickerSize -  Math.round((hsv["h"] * pickerSize)/360));
            //picker.setRegionValue(hsv["s"] * pickerSize, pickerSize - Math.round(hsv["v"]*100/pickerSize) );
            picker.setRegionValue(hsv["s"] * pickerSize, pickerSize - Math.round(hsv["v"]*128/pickerSize) +1);
            Dom.get("hexval").value = color;
        },
    }
}();

YAHOO.util.Event.on(window, "load", WebguiColorPicker.init);

function correctPNG() // correctly handle PNG transparency in Win IE 5.5 or higher.
   {
   for(var i=0; i<document.images.length; i++)
      {
      var img = document.images[i]
      var imgName = img.src.toUpperCase()
      if (imgName.substring(imgName.length-3, imgName.length) == "PNG")
         {
         var imgID = (img.id) ? "id='" + img.id + "' " : ""
         var imgClass = (img.className) ? "class='" + img.className + "' " : ""
         var imgTitle = (img.title) ? "title='" + img.title + "' " : "title='" + img.alt + "' "
         var imgStyle = "display:inline-block;" + img.style.cssText 
         if (img.align == "left") imgStyle = "float:left;" + imgStyle
         if (img.align == "right") imgStyle = "float:right;" + imgStyle
         if (img.parentElement.href) imgStyle = "cursor:hand;" + imgStyle       
         var strNewHTML = "<span " + imgID + imgClass + imgTitle
         + " style=\"" + "width:" + img.width + "px; height:" + img.height + "px;" + imgStyle + ";"
         + "filter:progid:DXImageTransform.Microsoft.AlphaImageLoader"
         + "(src=\'" + img.src + "\', sizingMethod='scale');\"></span>" 
         img.outerHTML = strNewHTML
         i = i-1
         }
      }
   }

if (navigator.appName == 'Microsoft Internet Explorer') {
    YAHOO.util.Event.addListener(window, "load", correctPNG);
}
