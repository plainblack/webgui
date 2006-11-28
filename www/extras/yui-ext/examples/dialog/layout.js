
// create the LayoutExample application (single instance)
var LayoutExample = function(){
    // everything in this space is private and only accessible in the HelloWorld block
    
    // define some private variables
    var dialog, showBtn;
    
    var toggleTheme = function(){
        getEl(document.body, true).toggleClass('ytheme-gray');
    };
    // return a public interface
    return {
        init : function(){
             showBtn = getEl('show-dialog-btn');
             // attach to click event
             showBtn.on('click', this.showDialog, this, true);
             
             getEl('theme-btn').on('click', toggleTheme);
        },
        
        showDialog : function(){
            if(!dialog){ // lazy initialize the dialog and only create it once
                dialog = new YAHOO.ext.LayoutDialog("hello-dlg", { 
                        modal:true,
                        width:600,
                        height:400,
                        shadow:true,
                        minWidth:300,
                        minHeight:300,
                        west: {
	                        split:true,
	                        initialSize: 150,
	                        minSize: 100,
	                        maxSize: 250,
	                        titlebar: true,
	                        collapsible: true,
	                        animate: true
	                    },
	                    center: {
	                        autoScroll:true,
	                        tabPosition: 'top',
	                        closeOnTab: true,
	                        alwaysShowTabs: true
	                    }
                });
                dialog.addKeyListener(27, dialog.hide, dialog);
                dialog.addButton('Close', dialog.hide, dialog);
                dialog.addButton('Submit', dialog.hide, dialog);
                
                var layout = dialog.getLayout();
                dialog.beginUpdate();
                layout.add('west', new YAHOO.ext.ContentPanel('west', {title: 'West'}));
	            layout.add('center', new YAHOO.ext.ContentPanel('center', {title: 'Inner Tab'}));
	            dialog.endUpdate();
            }
            dialog.show(showBtn.dom);
        }
    };
}();

// using onDocumentReady instead of window.onload initializes the application
// when the DOM is ready, without waiting for images and other resources to load
YAHOO.ext.EventManager.onDocumentReady(LayoutExample.init, LayoutExample, true);