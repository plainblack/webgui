/**
 * viewport.js 
 * by Garrett Smith 
 */
function getViewportHeight() {
	if(window.innerHeight)
		return window.innerHeight;
		
	if(typeof window.document.documentElement.clientHeight == "number")
		return window.document.documentElement.clientHeight;
		
	return window.document.body.clientHeight;
}

function getViewportWidth() {
	if(window.innerWidth)
		return window.innerWidth -16;
		
	if(typeof window.document.documentElement.clientWidth == "number")
		return window.document.documentElement.clientWidth;
		
	return window.document.body.clientWidth;
}
function getScrollLeft(){
	if(typeof window.pageXOffset == "number")
		return window.pageXOffset;
		
	if(document.documentElement.scrollLeft) 
		return Math.max(document.documentElement.scrollLeft, document.body.scrollLeft);
		
	else if(document.body.scrollLeft != null)
		return document.body.scrollLeft;
	return 0;
}
function getScrollTop(){
	if(typeof window.pageYOffset == "number")
		return window.pageYOffset;
		
	if(document.documentElement.scrollTop) 
		return Math.max(document.documentElement.scrollTop, document.body.scrollTop);
		
	else if(document.body.scrollTop != null)
		return document.body.scrollTop;
	return 0;
}