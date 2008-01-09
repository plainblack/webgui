var WebGUI = {
    widgetBox : {
        function retargetLinksAndForms() {

            // get all the <a> elements, change their target appropriately
            var allLinks = document.getElementsByTagName('a');
            for(var i = 0; i < allLinks.length; i++) {
                allLinks[i].target = '_blank';
            }

            // same for <form>s
            var allForms = document.getElementsByTagName('form');
            for(var i = 0; i < allForms.length; i++) {
                allForms[i].target = '_blank';
            }
        }
    }
};
YAHOO.util.Event.addListener(window, "load", WebGUI.widget.retargetLinksAndForms);
