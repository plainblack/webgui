var XmlExample = {
    init : function(){
        var schema = {
            tagName: 'Item',
            id: 'ASIN',
            fields: ['Author', 'Title', 'Manufacturer', 'ProductGroup']
        };
        dataModel = new YAHOO.ext.grid.XMLDataModel(schema);
        
        // the DefaultColumnModel expects this blob to define columns. It can be extended to provide 
        // custom or reusable ColumnModels
        var colModel = new YAHOO.ext.grid.DefaultColumnModel([
			{header: "Author", width: 120, sortable: true}, 
			{header: "Title", width: 180, sortable: true}, 
			{header: "Manufacturer", width: 115, sortable: true}, 
			{header: "Product Group", width: 100, sortable: true}
		]);
		
		// create the Grid
        var grid = new YAHOO.ext.grid.Grid('example-grid', dataModel, colModel);
        grid.autoWidth = true;
        grid.autoHeight = true;
        grid.render();

        dataModel.load('/blog/examples/sheldon.xml');
    }
}
YAHOO.ext.EventManager.onDocumentReady(XmlExample.init, XmlExample, true);
