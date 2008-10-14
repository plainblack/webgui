YAHOO.namespace('WebGUI.Form');
YAHOO.WebGUI.Form.ColorPicker = {
    init: function() {
        // Instantiate the Dialog
        var dg = this.dialogElement = document.createElement('div');
        document.body.appendChild(dg);
        YAHOO.util.Dom.generateId(dg);
        YAHOO.util.Dom.addClass(dg, 'yui-picker-panel');
        YAHOO.util.Dom.addClass(dg, 'wg-picker-panel');
        var hd = document.createElement('div');
        YAHOO.util.Dom.addClass(hd, 'hd');
        dg.appendChild(hd);
        var bd = document.createElement('div');
        YAHOO.util.Dom.addClass(bd, 'bd');
        dg.appendChild(bd);
        var ft = document.createElement('div');
        YAHOO.util.Dom.addClass(ft, 'ft');
        dg.appendChild(ft);
        this.dialog = new YAHOO.widget.Dialog(dg, {
            width : "360px",
            visible : false,
            zIndex : 20,
            draggable: false,
            constraintoviewport : true,
            buttons : [
                { text:"Set", handler:function() { this.submit() }, isDefault:true },
                { text:"Cancel", handler:function() { this.cancel() } }
            ],
            postmethod: 'manual'
        });
        this.dialog.renderEvent.subscribe(function() { 
            if (!this.picker) { //make sure that we haven't already created our Color Picker 
                var extras = getWebguiProperty("extrasURL");
                var pickerdiv = document.createElement('div');
                YAHOO.util.Dom.addClass(pickerdiv, 'yui-picker');
                this.dialog.body.getElementsByTagName('form')[0].appendChild(pickerdiv);
                this.picker = new YAHOO.widget.ColorPicker(pickerdiv, { 
                    container: this.dialog,
                    images: { 
                        PICKER_THUMB: extras + '/yui/build/colorpicker/assets/picker_thumb.png',
                        HUE_THUMB: extras + '/yui/build/colorpicker/assets/hue_thumb.png'
                    },
                    showhexsummary: false,
                    showwebsafe: false,
                    showhexcontrols: true, // default is false 
                    showhsvcontrols: true  // default is false 
                });
            }
        }, this, true);
        this.dialog.beforeShowEvent.subscribe(function() {
            var hex = this.saveElement.value.substr(1);
            this.picker.setValue(YAHOO.util.Color.hex2rgb(hex), false);
        }, this, true);
        this.dialog.manualSubmitEvent.subscribe(function() {
            var hex = '#' + this.picker.get('hex');
            this.saveElement.value = hex;
            this.saveElement.onchange();
        }, this, true);
        this.dialog.render();
    },
    display: function(el, swatch) {
        this.saveElement = YAHOO.util.Dom.get(el);
        this.swatchElement = YAHOO.util.Dom.get(swatch);
        if (this.dialog) {
            this.dialog.cancel();
        }
        this.dialog.cfg.setProperty('context', [this.swatchElement, 'tl', 'tr']);
        this.dialog.align(YAHOO.widget.Overlay.TOP_LEFT, YAHOO.widget.Overlay.TOP_RIGHT);
        this.dialog.show();
    },
    attach: function(el, swatch) {
        YAHOO.util.Event.on(el, 'change', function(e, swatch) {
            YAHOO.util.Dom.setStyle(swatch, 'background-color', this.value);
        }, swatch);
        YAHOO.util.Event.on(swatch, 'click', function(e, objs) {
            YAHOO.util.Event.preventDefault(e);
            this.display(objs[0], objs[1]);
        }, [el, swatch], this);
    }
};
YAHOO.util.Event.onDOMReady(YAHOO.WebGUI.Form.ColorPicker.init, YAHOO.WebGUI.Form.ColorPicker, true);

