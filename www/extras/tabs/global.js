/**
 * global.js 
 * by Garrett Smith 
 * Provides functionality for extending custom classes.
 *
 * ElementWrapper is a simple wrapper class.
 *
 * EventQueue provides Event Listener Functionality.
 */


/** Provides functionality for extending classes. 
 *  
 */
Function.prototype.extend = function(souper) {
	this.prototype = new souper;
	this.prototype.constructor = this;
	this.souper = souper;
	this.prototype.souper = souper;
};
/** Generic Element Wrapper 
 *  
 */
ElementWrapper = function ElementWrapper(el){
	if(arguments.length == 0) return;
	this.el = el;
	this.id = el.id;
	if(!ElementWrapper.list[this.id])
		ElementWrapper.list[this.id] = this;
};

ElementWrapper.list = new function(){};

ElementWrapper.getWrapper = function(id){
	return ElementWrapper.list[id];
};


/** EventQueue class Provides Event Listener Functionality.
 *
 * Instance Methods: 
 *
 *   addEventListener(etype, pointer)
 *   
 * 
 */
EventQueue = function EventQueue(eventObj){
	if(arguments.length == 0) return;
	this.souper = EventQueue.souper;
	this.souper(eventObj);
	
	this.addToPool();
};

EventQueue.extend(ElementWrapper);

EventQueue.prototype.addEventListener = function(etype, pointer){
	var list = this.eventHandlerList(etype);
	return list[list.length++] = pointer;
};

EventQueue.prototype.eventHandlerList = function(etype){
	
	if(!this[etype])
		this[etype] = new EventQueue.EventHandler(this, etype);
	
	return this[etype];
};

EventQueue.prototype.removeEventListener = function(etype, pointer){
	var list = this[etype];
	var len = list.length;
	if(len == 0) return null;
	
	var newList = new Array(len-1);
	var rtn = null;
	for(var i = 0; i < len; i++)
		if(list[i] != pointer)
			newList[i] = list[i];
		else rtn = pointer;
		
	this[etype] = newList;
	return rtn;
};
	

EventQueue.prototype.handleEvent = function(e){
	
	var rtn = true;
	for(var i = 0, len = this[e].length; i < len; i++){
			this.tempFunction = this[e][i];
			if(rtn != false)	
				rtn = this.tempFunction();
		}
	return rtn;
};
	
EventQueue.prototype.addToPool = function(){
	if(!EventQueue.list[this.id])
		EventQueue.list[this.id] = this;
};


/** EventQueue.EventHandler is private to EventQueue class.
 *  Instantiation and method calls are made automatically from
 *  EventQueue constructor and instance methods. 
 */
EventQueue.EventHandler = function EventHandler(wrapper, etype){
	this.etype = etype;
	this.length = 0;
	this.id = wrapper.id;
	wrapper.el[etype] = new Function("return EventQueue.fireEvent('"+wrapper.id+"', '"+etype+"')");
};

EventQueue.fireEvent = function(id, e){	
	var wrapper = EventQueue.list[id];
	if(!wrapper) return false;
	var r = wrapper.handleEvent(e);
	return r;
	
};
EventQueue.EventHandler.prototype.toString = function toString(){
	return this.id +"." +this.etype;
};

EventQueue.list = new Object;
