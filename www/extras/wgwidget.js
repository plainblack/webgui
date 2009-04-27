if (typeof WebGUI == 'undefined') {
    WebGUI = {};
}

if(typeof WebGUI.widgetBox == 'undefined') {
    WebGUI.widgetBox = {};
}

WebGUI.widgetBox = {
        
    parentNodeId : null,
    url          : null,
    
        // this function courtesy of http://www-128.ibm.com/developerworks/web/library/wa-ie2mozgd/
        // lots of reformatting to be easier to read
        
    getWidgetFrame : function( frameId ) { 
        var widgetFrame = null; 

        // standards compliant, i.e. gecko et al.
        if (document.getElementById(frameId).contentDocument) { 
            widgetFrame = document.getElementById(frameId).contentDocument; 
        }
        // not compliant, i.e. IE
        else { 
            //widgetFrame = document.frames[frameId].document; 
            widgetFrame = document.getElementById(frameId).document; 
        } 

        return widgetFrame; 
    },

    widget : function( url, parentId, width, height, templateId, styleTemplateId ) {
        if(url == "") {
            return "<iframe scrolling='no'><body>No content available from "+url+"</body></iframe>";
        }

        if(width == undefined) {
            width = 600;
        }
        if(height == undefined) {
            height = 400;
        }

        if(templateId == undefined) {
            this.url = url + "?func=ajaxInlineView";
        }
        else {
            this.url = url + "?func=widgetView&templateId=" + templateId;
            this.url += ";width=" + width;
            this.url += ";height=" + height;
            this.url += ";styleTemplateId=" + styleTemplateId;
        }
        
        this.parentNodeId = parentId;

        this.markup  = "";
        this.markup += "<iframe scrolling='no' frameborder='0' id = '";
        this.markup += this.parentNodeId;
        this.markup += "' src='";
        this.markup += this.url;
        this.markup += "' width='";
        this.markup += width;
        this.markup += "' height='";
        this.markup += height;
        this.markup += "'>";
        this.markup += "</iframe>";

        return this.markup;
    },

    retargetLinksAndForms : function() {

        // get all the <a> elements, change their target appropriately
        var allLinks = document.getElementsByTagName('a');
        for(var i = 0; i < allLinks.length; i++) {
            // skip the gear links for widgets
            if( allLinks[i].href.search(/#/) != -1 && allLinks[i].name.search(/^show/) != -1 ) {
                continue;
            }
            else {
                allLinks[i].target = '_blank';
            }
        }

        // same for <form>s
        var allForms = document.getElementsByTagName('form');
        for(var i = 0; i < allForms.length; i++) {
            allForms[i].target = '_blank';
        }
    },

    doTemplate : function(elementId) {
        document.body.innerHTML = TrimPath.processDOMTemplate(elementId, data);
    },

    initButton : function(first, second) {

        // for some unknown reason (God do I love JS), either the first or
        // second argument to initButton may have the params we sent it.
        // hurray. work around this by checking to see which object holds our
        // information and then setting a known name to hold our values.

        var params;
        if(!first.fullUrl) {
            params = second;
        }
        else {
            params = first;
        }

        var jsCode = ""; 
        jsCode += "&lt;script type='text/javascript' src='" + params.wgWidgetPath + "'&gt; &lt;/script&gt;";
        jsCode += "&lt;script type='text/javascript'&gt;";
        jsCode += "document.write(WebGUI.widgetBox.widget('" + params.fullUrl + "', '" + params.assetId + "', " + params.width + ", " + params.height + ", '" + params.templateId + "', '" + params.styleTemplateId + "')); &lt;/script&gt;";

        // Instantiate the Dialog 
        codeGeneratorButton = new YAHOO.widget.SimpleDialog("codeGeneratorButton", {
            width: "500px",
            height: "200px",
            fixedcenter: true,
            visible: false,
            draggable: true,
            close: true,
            text: "<textarea id='jsWidgetCode' rows='5' cols='50'>" + jsCode + "</textarea>",
            icon: YAHOO.widget.SimpleDialog.ICON_INFO,
            constraintoviewport: true,
            modal: true,
            zIndex: 9999,
            buttons: [{text: "Dismiss", handler:WebGUI.widgetBox.dismissButton, isDefault: true}]
            }
        );
        codeGeneratorButton.setHeader("Widget code");

        // Render the Dialog
        codeGeneratorButton.render(document.body);

        YAHOO.util.Event.addListener("show" + params.assetId, "click", WebGUI.widgetBox.handleButtonShow, codeGeneratorButton, true);
    },
    handleButtonShow : function(e) {
        e.preventDefault();
        codeGeneratorButton.show();
        var tag = document.getElementById('jsWidgetCode');
        tag.focus();
        tag.select();
    },
    dismissButton : function () {
        this.hide();
    }
}
