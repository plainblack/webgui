

/**
 * WebGUI.Layout -- Handle drag/drop of assets inside of layouts
 */

bind = function ( scope, func ) {
    return function() { func.apply( scope, arguments ) }
};

if ( typeof WebGUI == "undefined" ) {
    WebGUI = {};
}
/**
 * Initialize the layout positions and drag/drop inside the given element
 * cfg is an object of configuration:
 *      url     = the URL to save the layout to
 *
 */
WebGUI.Layout = function (elem, cfg) {
    this.elem       = elem;
    this.cfg        = cfg;

    // Some special vars
    this.scrollJump = 50;

    // Init layout positions
    var positions   = this.getPositions();
    for ( var i = 0; i < positions.length; i++ ) {
        var pos = positions[i];
        var children = this.getPositionElements( pos );
        if ( children.length == 0 ) {
            // No child nodes, create an empty target
            this.addBlankTarget(pos);
        }
        else {
            // Check the child nodes for the right IDs to initialize dragdrop
            for ( var x = 0; x < children.length; x++ ) {
                var elem = children[x];
                if ( elem.id.match(/wg-content-asset-(.{22})/) ) {
                    new WebGUI.LayoutItem( elem, null, null, this );
                }
            }
        }
    }
};

/**
 * Get all the position wrapper elements
 */
WebGUI.Layout.prototype.getPositions
= function () {
    return YAHOO.util.Dom.getElementsByClassName( 'wg-content-position', '*', this.elem );
};

/**
 * Get all the elements inside of a given position
 */
WebGUI.Layout.prototype.getPositionElements
= function ( pos ) {
    return pos.getElementsByTagName( '*' );
};

/**
 * Adjust the scrollbars to keep the content visible
 */
WebGUI.Layout.prototype.adjustScroll
= function (e) {
    scrY=0;
    scrX=0;

    // Y scroll
    if (e.clientY > document.body.clientHeight-this.scrollJump) {
        if (e.clientY + document.body.scrollTop < pageHeight - (this.scrollJump + 60)) {
            scrY=this.scrollJump;
            window.scroll(document.body.scrollLeft,document.body.scrollTop + scrY);
            y-=scrY;
        }
    }else if (e.clientY < this.scrollJump) {
        if (document.body.scrollTop < this.scrollJump) {
            scrY = document.body.scrollTop;
        }else {
            scrY=this.scrollJump;
        }
        window.scroll(document.body.scrollLeft,document.body.scrollTop - scrY);
        y+=scrY;
    }

    // X scroll
    if (e.clientX > document.body.clientWidth-this.scrollJump) {
        if (e.clientX + document.body.scrollLeft < pageWidth - (this.scrollJump + 60)) {
            scrX=this.scrollJump;
            window.scroll(document.body.scrollLeft + scrX,document.body.scrollTop);
            x-=scrX;
        } 
    }else if (e.clientX < this.scrollJump) {
        if (document.body.scrollLeft < this.scrollJump) {
            scrX = document.body.scrollLeft;
        }else {
            scrX=this.scrollJump;
        }
        window.scroll(document.body.scrollLeft - scrX,document.body.scrollTop);
        x+=scrX;
    }
};

/**
 * Add a blank drag target to an area. Used to provide a position with no children a
 * a place to make babies
 */
WebGUI.Layout.prototype.addBlankTarget
= function ( el ) {
    var blank = document.createElement("div");
    blank.className="blank";
    blank.id = "blank" + new Date().getTime() + blankCount++;
    el.appendChild(blank);
    blank.style.top     = 0+"px";
    blank.style.left    = 0+"px";

    // Add child for target
    var empty = document.createElement("div");
    blank.appendChild( empty );
    empty.className = "empty";

    return new YAHOO.util.DDTarget(blank);
};

/**
 * Move the content
 */
WebGUI.Layout.prototype.move
= function (from,to,position) {
    if (from!=to && from && to) {
        var fromParent = from.parentNode;
        fromParent.removeChild(from);

        // If we've removed the last one, add a blank element
        if ( this.getPositionElements(fromParent).length == 0) {
            this.addBlankTarget(fromParent);
        }

        var toParent = to.parentNode;
        var toChildren = this.getPositionElements(toParent);

        if ( this.isBlank( toChildren[0] ) ) {
            toParent.removeChild(toChildren[0]);
            toParent.appendChild(from);
        }
        else if (position == "top") {
            toParent.insertBefore( from, to );
        }
        else {
            children = this.getPositionElements(toParent);
            i=0;
            while (children[i] != to && i < children.length) {
                i++;
            }

            if (i == children.length - 1) {
                toParent.appendChild(from);
            }
            else {
                toParent.insertBefore(from,children[i+1]);
            }
        }
    }
};

/**
 * Check if a layout position is blank
 */
WebGUI.Layout.prototype.isBlank
= function ( obj ) {
    return obj.className.indexOf( "blank" ) == -1;
};

/**
 * Save the new layout to the server, using the configured URL
 */
WebGUI.Layout.prototype.save
= function () {
    // Create the content map
    contentMap = "";
    contentCount=1;
    var contentArea = document.getElementById("position1");
    while (contentArea) {
        if ((contentMap != "") || ( contentCount == 2 )) {
            contentMap+=".";
        }

        //get down to the tr area
        children = dragable_getElementChildren(contentArea);
        children=dragable_getElementChildren(children[0]);
        for (i=0;i<children.length;i++) {
            if (contentMap != "" && (contentMap.lastIndexOf(".") != contentMap.length-1)) {
                contentMap+=",";
            }

            if ( !this.isBlank( children[i] ) ) {
                contentMap+=children[i].id.replace(/^wg-content-asset-/,"");
            }
        }

        contentCount++;
        contentArea = document.getElementById("position" + contentCount);
    }

    // Send it off!
    YAHOO.util.Connect.asyncRequest( this.cfg.url + '?' + contentMap, {} );
};

/****************************************************************************
 * WebGUI.LayoutItem -- a single item in a layout
 */
WebGUI.LayoutItem
= function(elem, sGroup, config, layout) {
    this.elem   = elem;
    this.layout = layout;

    WebGUI.LayoutItem.superclass.constructor.call(this, elem, sGroup, config);
    // Add a dragger control
    var dragger    = document.createElement( 'div' );
    dragger.className = "draggable";
    var dragTrigger = document.createElement( 'div' );
    dragTrigger.className = "dragTrigger dragTriggerWrap";
    var icon    = document.createElement( 'img' );
    icon.src = getWebguiProperty( 'extrasURL' ) + 'icon/arrow_out.png';
    dragTrigger.appendChild( icon );
    dragger.appendChild( dragTrigger );
    elem.insertBefore( dragger, elem.firstChild );
};
YAHOO.extend(WebGUI.LayoutItem, YAHOO.util.DDProxy);

/**
 * Function called when starting a drag
 */
WebGUI.LayoutItem.prototype.startDrag
= function(x, y) {
    // make the proxy look like the source element
    var dragEl = this.getDragEl();
    var clickEl = this.getEl();
    Dom.setStyle(clickEl, "visibility", "hidden");

    dragEl.innerHTML = clickEl.innerHTML;

    Dom.setStyle(dragEl, "color", Dom.getStyle(clickEl, "color"));
    Dom.setStyle(dragEl, "backgroundColor", Dom.getStyle(clickEl, "backgroundColor"));
    Dom.setStyle(dragEl, "border", "2px solid gray");
};


/**
 * Function called when stopping a drag outside of a dropzone
 */
WebGUI.LayoutItem.prototype.onDragOut
= function (e, id) {
    var obj = Dom.get(id);
    if ( this.layout.isBlank(obj) ) {
        document.getElementById(id).className="blank";
    }else if (obj.className == 'draggedOverTop' || obj.className == 'draggedOverBottom') {
        document.getElementById(id).className="dragable";
    }
};

/**
 * Called when the drag is over, either success or fail
 */
WebGUI.LayoutItem.prototype.endDrag
= function (e) {
    var srcEl = this.getEl();
    var proxy = this.getDragEl();

    // Show the proxy element and animate it to the src element's location
    Dom.setStyle(proxy, "visibility", "");
    var a = new YAHOO.util.Motion( 
        proxy, { 
            points: { 
                to: Dom.getXY(srcEl)
            }
        }, 
        0.2, 
        YAHOO.util.Easing.easeOut 
    )
    var proxyid = proxy.id;
    var thisid = this.id;

    // Hide the proxy and show the source element when finished with the animation
    a.onComplete.subscribe(function() {
            Dom.setStyle(proxyid, "visibility", "hidden");
            Dom.setStyle(thisid, "visibility", "");
        });
    a.animate();
};

/**
 * Called when the item is dropped on a drag target.
 * Update the item and update the content positions
 */
WebGUI.LayoutItem.prototype.onDragDrop
= function (e, id) {
    var position;
    if (this.goingUp) {
        position = "top";
    }
    else{
        position = "bottom";
    }
    var target = this.getEl().parentNode.parentNode;
    var destination = Dom.get(id);
    if ( !this.layout.isBlank( destination ) ){
        destination.className = "dragable";
        destination = Dom.get(id).parentNode.parentNode;
    }
    this.layout.move(target, destination, position);
    //this.layout.save();
};

/**
 * Called periodically while we are dragging an element
 */
WebGUI.LayoutItem.prototype.onDrag
= function (e) {
    // Keep track of the direction of the drag for use during onDragOver
    var y = Event.getPageY(e);
    if (y < this.lastY) {
        this.goingUp = true;
    } else if (y > this.lastY) {
        this.goingUp = false;
    }
    this.lastY = y;
    this.layout.adjustScroll(e);
},

/**
 * Called when a dragging item is over a drag target
 */
WebGUI.LayoutItem.prototype.onDragOver
= function (e, id) {
    var srcEl = this.getEl();
    if(srcEl.id == id){return;}

    var obj = Dom.get(id);
    // We are only concerned with list items, we ignore the dragover
    // notifications for the list.
    if ( this.layout.isBlank( obj ) ) {
        document.getElementById(id).className="blankOver";
    }else if (this.goingUp) {
        document.getElementById(id).className="draggedOverTop";
    }else {
        document.getElementById(id).className="draggedOverBottom";
    }
}

