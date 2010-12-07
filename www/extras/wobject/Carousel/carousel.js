
if ( typeof WebGUI == 'undefined' ) {
    WebGUI = {};
}
if ( typeof WebGUI.Carousel == 'undefined' ) {
    WebGUI.Carousel = {};
}

WebGUI.Carousel.Editor
= function ( id, mceConfig, items, i18n ) {
    this.id         = id;
    this.mceConfig  = mceConfig;
    this.items      = items;
    this.i18n       = i18n;

    // Initialize a tabview
    this.tabView    = new YAHOO.widget.TabView( this.id, {
        orientation     : "left"
    } );

    // Add a tab for each item
    for ( var i = 0; i < this.items.length; i++ ) {
        this.addTab( this.items[i] );
    }

    // We're new!
    if ( this.items.length == 0 ) {
        this.addTab( );
    }

    // Find the form and eventize it!
    var form    = document.getElementById( this.id );
    while ( form.tagName != "FORM" ) {
        form = form.parentNode;
    }
    YAHOO.util.Event.on( form, 'submit', this.handleSubmit, this, true );
};

WebGUI.Carousel.Editor.prototype.addTab
= function ( data ) {
    var num = this.tabView.get('tabs').length + 1;
    if ( !data ) {
        data    = { text : "", itemId : 'carousel_item_' + num };
    }

    var tab = new YAHOO.widget.Tab( {
        label       : num,
        content     : ''
    } );
    this.tabView.addTab( tab );
    this.tabView.selectTab( num - 1 );

    var el = tab.get('contentEl');

    var delBtn  = document.createElement( 'input' );
    delBtn.type = "button";
    delBtn.style.cssFloat = "right";
    delBtn.value = this.i18n['delete'];
    YAHOO.util.Event.on( delBtn, "click", function(){ 
        this.tabView.removeTab( tab );
    }, this, true );
    el.appendChild( delBtn );

    var input   = document.createElement( 'input' );
    input.type = "text";
    input.value = data.itemId;
    el.appendChild( document.createTextNode( "ID: " ) );
    el.appendChild( input );

    var ta  = document.createElement( 'textarea' );
    ta.className    = "carouselInput";
    ta.name         = "carouselInput" + num;
    ta.id           = ta.name;
    ta.style.height = "300px";
    ta.appendChild( document.createTextNode( data.text ) );
    el.appendChild( ta );

    var conf    = this.mceConfig;
    conf.mode = "exact";
    conf.elements = ta.name;

    tinyMCE.init( conf );
};

WebGUI.Carousel.Editor.prototype.handleSubmit
= function ( ) {
    var tabs = this.tabView.get('tabs');
    var items = [];
    for ( var i = 0; i < tabs.length; i++ ) {
        var item    = { };
        var tab     = tabs[i];
        var elem    = tab.get('contentEl');

        var id      = elem.getElementsByTagName( 'input' )[1];
        item.itemId = id.value;

        var text    = elem.getElementsByTagName( 'textarea' )[0];
        item.text   = text.value;

        item.sequenceNumber = i;

        items.push( item );
    }
    var json = YAHOO.lang.JSON.stringify( items );
    document.getElementById( 'items_formId' ).value = json;
};

