var WebGUI = {
    
    widgetBox : {
        
        parentNodeId : null,
        url          : null,
        
           
        widget : function( url, parentId, width, height, templateId ) {
            if(url == "") {
                return "<iframe scrolling='no'><body>No content available from "+url+"</body></iframe>";
            }

            if(width == undefined) {
                width = 600;
            }
            if(height == undefined) {
                height = 400;
            }

            this.url = url + "?func=widgetView&templateId=" + templateId;
            
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
        }
    }
}
