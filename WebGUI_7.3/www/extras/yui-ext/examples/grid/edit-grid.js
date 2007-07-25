EditorExample = function(){
    var dataModel;
    var grid;
    var colModel;
    
    var formatMoney = function(value){
        value -= 0;
        value = (Math.round(value*100))/100;
        value = (value == Math.floor(value)) ? value + '.00' : ( (value*10 == Math.floor(value*10)) ? value + '0' : value);
        return "$" + value;  
    };
    
    var formatBoolean = function(value){
        return value ? 'Yes' : 'No';  
    };
    
    var formatDate = function(value){
        return value.dateFormat('M d, Y');  
    };
    
    var parseDate = function(value){
        return new Date(Date.parse(value));  
    };
    
    return {
        init : function(){
            var yg = YAHOO.ext.grid;
            var cols = [{ 
                   header: "Common Name", 
                   width: 160, 
                   editor: new yg.TextEditor({allowBlank: false})
                },{
                   header: "Light", 
                   width: 130, 
                   editor: new yg.SelectEditor('light')
                },{
                   header: "Price", 
                   width: 70, 
                   renderer: formatMoney, 
                   editor: new yg.NumberEditor({allowBlank: false, allowNegative: false, maxValue: 10})
                },{
                   header: "Available", 
                   width: 95, 
                   renderer: formatDate, 
                   editor: new yg.DateEditor({format: 'm/d/y', minValue: '01/01/06', disabledDays: [0, 6], 
                                            disabledDaysText: 'Plants are not available on the weekends', 
                                            disabledDates : ['^07', '04/15', '12/02/06'],
                   disabledDatesText : 'The plants are pollinating on %0, choose a different date.'})
                },{
                   header: "Indoor?", 
                   width: 55,
                   renderer: formatBoolean, 
                   editor: new yg.CheckboxEditor()
                }];
            colModel = new YAHOO.ext.grid.DefaultColumnModel(cols); 
    		colModel.defaultSortable = true;
    		
    		var schema = {
                tagName: 'plant',
                id: 'use-index',
                fields: ['common', 'light', 'price', 'availability', 'indoor']
            };
            dataModel = new YAHOO.ext.grid.XMLDataModel(schema);
            dataModel.addPreprocessor(2, parseFloat);
            dataModel.addPreprocessor(3, parseDate);
            dataModel.addPreprocessor(4, Boolean);
            dataModel.setDefaultSort(colModel, 0, "ASC");
    		
    		grid = new YAHOO.ext.grid.EditorGrid('editor-grid', dataModel, colModel);
    		// to use double click to edit:
    		//grid.getSelectionModel().clicksToActivateCell = 2;
    		grid.render();
    		
    		dataModel.load('plants.xml'); 
        },
        
        // filtering support, regex, function or text match
        filter : function(e){
            var mfilter = function(value){
                return (value == 'Shade');
            }
            dataModel.filter({0: /^B.*/i, 1: mfilter});
        },
        
        // hide columns
        hide : function(e){
            colModel.setHidden(1, true);
        }
    };  
}();

YAHOO.ext.EventManager.onDocumentReady(EditorExample.init, EditorExample, true);