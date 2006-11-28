
// create the HelloWorld application (single instance)
var HelloWorld = function(){
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
                dialog = new YAHOO.ext.BasicDialog("hello-dlg", { 
                        //modal:true,
                        autoTabs:true,
                        width:500,
                        height:300,
                        shadow:true,
                        minWidth:300,
                        minHeight:250,
                        proxyDrag: true
                });
                dialog.addKeyListener(27, dialog.hide, dialog);
                dialog.addButton('Close', dialog.hide, dialog);
                dialog.addButton('Submit', dialog.hide, dialog).disable();
            }
            dialog.show(showBtn.dom);
        }
    };
}();

// using onDocumentReady instead of window.onload initializes the application
// when the DOM is ready, without waiting for images and other resources to load
YAHOO.ext.EventManager.onDocumentReady(HelloWorld.init, HelloWorld, true);