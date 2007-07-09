// This is a modified version of the accordion tutorial from www.webthreads.de


/* 

var myAccordion = new Accordion(id [, height]);

	id: The id of the div that contains the accordion structure.

	height: An integer representing the height that the accordion should be drawn in pixels. Defaults to the viewport height minus one header width.

*/

function Accordion(id, accordionHeight) {
  	// pointer to the accordion container
  	this.accContainer = document.getElementById(id);

  	// all items with class = accordionItem
  	this.accItems = YAHOO.util.Dom.getElementsByClassName("accordionItem", "div", this.accContainer);
  
	// scale the acccordion to the appropriate height
	this.accordionHeight = 0;
	var headerHeight = YAHOO.util.Dom.getElementsByClassName("accordionHeader", "div", this.accItems[0])[0].offsetHeight;
	if (accordionHeight > 0) {
		this.accordionHeight = accordionHeight;
	} else {
		this.accordionHeight = YAHOO.util.Dom.getViewportHeight() - headerHeight;
	}	
	this.accContainer.style.height = this.accordionHeight + "px";
	var bodyHeight = this.accordionHeight - (headerHeight * this.accItems.length);
	YAHOO.util.Dom.getElementsByClassName("accordionBody", "div", this.accItems[0])[0].style.height = bodyHeight + "px";
	
  	// set the default accordion body height 
  	this.accItemBodyHeight = 0;
  
  	// iterate over all the accordian elements and store them in an array
  	for (var i=0; i<this.accItems.length; i++) {
    		// set current accordion element as parent to header and body
    		this.accItems[i].parent = this;
    		// set current accordion element's header and body	
    		this.accItems[i].header = YAHOO.util.Dom.getElementsByClassName("accordionHeader", "div", this.accItems[i])[0];
    		this.accItems[i].body = YAHOO.util.Dom.getElementsByClassName("accordionBody", "div", this.accItems[i])[0];
   
		// determine and set the active accordion element 
    		if (this.accItems[i].body.offsetHeight > this.accItemBodyHeight) {
      			this.accItemBodyHeight = this.accItems[i].body.offsetHeight;
      			this.activeItem = this.accItems[i];
      			this.activeItem.body.style.height = this.accItemBodyHeight + "px";
    		}
    
    		// register the click event on the header for changing the active element in the accordion
    		YAHOO.util.Event.addListener(this.accItems[i].header, "click", function(){
      			// do nothing if they click on the active header
	      		if(this.parent.activeItem == this){
        			return;
      			}

	      		// shrink animation
      			var shrinkLastAccAnim = new YAHOO.util.Anim(this.parent.activeItem.body, {height:{from:this.parent.accItemBodyHeight, to:0}}, 0.1);
		    
      			// expand animation
      			var expandNewActiveAccAnim = new YAHOO.util.Anim(this.body, {height:{from:0, to:this.parent.accItemBodyHeight}}, 0.1);
		    	
      			// set the selected element as active
      			expandNewActiveAccAnim.onStart.subscribe(function() { this.parent.activeItem = this; }, this, true);
		
      			// execute the animation
      			shrinkLastAccAnim.animate();
      			expandNewActiveAccAnim.animate();
    			}, this.accItems[i], true);
  	}
  
	// only the active element remains expanded
  	for(var i=0; i<this.accItems.length; i++){
    		if(this.activeItem != this.accItems[i]){
      			this.accItems[i].body.style.height = 0 + "px";
    		}
  	}
};
