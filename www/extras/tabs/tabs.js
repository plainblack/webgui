/**
 * tabs.js 
 * by Garrett Smith 
 * http://dhtmlkitchen.com/
 */

if(!window.TabParams)
window.TabParams = {
	useClone         : false,
	alwaysShowClone  : false,
	eventType        : "click",
	tabTagName       : "*"
};

var tabDisplayNone = Browser.id.OP5 ? "" : "none";
var contentInheritVis =  Browser.id.OP5 ? "visible" : "inherit";

TabSystem = function TabSystem(el, tabsDiv){
	if(arguments.length == 0) return;
	this.souper = TabSystem.souper;
	this.souper(el);

	if(typeof tabsDiv.onselectstart != "undefined")
		tabsDiv.onselectstart = function(){return false;};
	
	this.el.onChange = this.el.onchange = function(){};
	this.el.onBeforeChange = function(){};

	this.defaultActiveTab = null;
	this.activeTab = null;
	this.relatedTab = null;
	this.nextTab = null;
	
	this.tabsDiv = tabsDiv;
	this.tabParams = this.getTabParams();
	this.tabArray = get_elements_with_class_from_classList(this.tabsDiv,
														   this.tabParams.tabTagName,
														    ["tab", "tabActive"]);
	this.tabsClone = null;
	this.tabs = new Array(0);
	
	if(!TabSystem.list[this.id])
		TabSystem.list[this.id] = this;
};

TabSystem.list = new Object; 
TabSystem.extend(EventQueue);

TabSystem.prototype.parentSystem = function(){
	
	var root = TabSystem.list["body"];
	if(root = this) return null;
	
	var parent = findAncestorWithClass(this.el, "content");
	if(parent != null)
		return TabSystem.list[parent.id];
	return root;
};

TabSystem.prototype.getTabParams = function(){

	if(!this.tabParams){
		this.tabParams = new Object;
		var parentSystem = this.parentSystem();
		parentTp = (parentSystem == null) ? 
			TabParams : parentSystem.getTabParams();

		for(var param in parentTp)
			this.tabParams[param] = parentTp[param];
	}
	return this.tabParams;
};

TabSystem.prototype.setEventType = function(eventType) {
	
	var params = this.getTabParams();
	if(params.eventType == eventType) return;
	
	for(var i = 0, len = this.tabArray.length; i < len; i++){
		var tab = Tab.list[this.tabArray[i].id];
		tab.removeEventListener("on"+params.eventType, tab.depressTab);
		tab.addEventListener("on"+eventType, tab.depressTab);
	}
	
	params.eventType = eventType;
};

function removeTabs(ts){

	ts.tabsDiv.style.display = "none";
	if(ts.tabsClone)
		ts.tabsClone.style.display = "none";

	var cs = getElementsWithClass(ts.el, "div", "content");
	for(var i = 0; i < cs.length; i++){
		cs[i].style.visibility='visible';
		cs[i].style.display='block';
	}
}

function undoRemoveTabs(ts){
		ts.tabsDiv.style.display = "block";
		if(ts.tabsClone)
			ts.tabsClone.style.display = "block";
		isTabLayout = true;
	for(var i = 0; i < ts.tabs.length; i++)
		if(ts.tabs[i] != ts.activeTab){
			ts.tabs[i].content.style.display = "none";
			ts.tabs[i].content.style.visibility = "hidden";
	}
}

TabSystem.prototype.setAlwaysShowClone = function(flag) {
	this.getTabParams().alwaysShowClone = flag;
	this.showTabsCloneIfNecessary();
};

TabSystem.prototype.addClone = function() {
	
	if(!this.tabsDiv.cloneNode) return;
	
	this.getTabParams().useClone = true;
	this.tabsClone = this.tabsDiv.cloneNode(true);
	if(!this.tabsClone) return;
	this.tabsClone.className = "tabs tabsClone";
	this.el.appendChild(this.tabsClone);
	
	for(var i = 0; i < this.tabArray.length; i++){
		var cont = Tab.list[this.tabArray[i].id];
		var bt = getDescendantById(this.tabsClone, cont.id);
		bt.id = "Bottom" + bt.id;
		cont.bottomTab = new BottomTab(bt, cont);
		
	}
	this.addEventListener("onchange", updateTabsClonePosition);
	if(Browser.id.MAC_IE5) 
		window.setInterval("updateTabsClonePosition()", 300);
	contentPane.addEventListener("onresize", updateTabsClonePosition);
	this.showTabsCloneIfNecessary();
	
};


tabInit = function tabInit(){
	
	if(!Browser.isSupported())
		return;
	
	
	var tabsDivs = getElementsWithClass(document.body, "div", "tabs");
	
	if(tabsDivs.length == 0) {// back compat.
		var tabsDiv0 = document.getElementById("tabs");
		if(tabsDiv0)
			tabsDivs = [tabsDiv0];
		else return;
	}
	var tabToDepress;
	for(var i = 0; i < tabsDivs.length; i++){
		var cnt = findAncestorWithClass(tabsDivs[i], "content") || document.body;
		if(!cnt.id)
			cnt.id = "body";
		var ts = new TabSystem(cnt, tabsDivs[i]);
		var len = ts.tabArray.length;
		for(var j = 0; j < len; new ControllerTab(ts.tabArray[j++], ts));
	}
	var activeTabs = getCookie("activeTabs"+escape(getFilename()));
	if(activeTabs != null){
		var activeTabArray = activeTabs.split(",");
		for(var i = 0, len = activeTabArray.length; i < len; i++){
			var tab = Tab.list[activeTabArray[i]];
			if(tab)
				tab.depressTab();			
		}
	}

	
	
	if(Browser.id.MAC_IE5){
		fixDocHeight = function(){
				document.documentElement.style.height = 
				document.body.style.height = 
				document.body.clientHeight + "px";
			};
		contentPane.addEventListener("onresize", fixDocHeight);
		setTimeout("fixDocHeight()", 500);
		
	}
	
	// hash overrides cookie.
	handleHashNavigation();
	
	deletePageCookie("activeTabs"+escape(getFilename()));
	for(id in TabSystem.list){
		var ts = TabSystem.list[id];
		if(ts.tabParams.useClone)
			ts.addClone();
		if(ts.activeTab == null && ts.defaultActiveTab != null)
			ts.defaultActiveTab.depressTab();
	}
	if(Browser.id.MOZ)
		repaintFix(document.body);
};
window.id = "window";
contentPane = new EventQueue(window);
//contentPane.addEventListener("onload", initTabs);

function handleHashNavigation(){
	var id = window.location.hash;
	if(id){
		var el = document.getElementById(id.substring(1));
		if(el) {
			var contentEl;
			if(hasToken(el.className, "content"))
				contentEl = el;
			else contentEl = findAncestorWithClass(el, "content");
			if(contentEl)
				switchTabs("tab"+contentEl.id.substring("content".length), null, false);
		}
	}
}


/**
 * Tab base class
 */
Tab = function Tab(el, ts){

	if(arguments.length == 0) return;
	this.souper = Tab.souper;
	this.souper(el);
	this.content = null;
	this.tabSystem = ts;
	this.properties = new Object;
	
	this.el.onActivate = function(){};
	
	this.addEventListener("onmouseover", this.hoverTab);
	this.addEventListener("onmouseout", this.hoverOff);
	this.addEventListener("on"+ this.tabSystem.getTabParams().eventType, this.depressTab);
	
	if(Browser.id.IE5_0)
		positionTabEl(this);
	if(!Tab.list[this.id])
		Tab.list[this.id] = this;
};
Tab.extend(EventQueue);

Tab.list = new Object;

Tab.prototype.setProperty = function(name, value){
	this.properties[name] = value;
};


Tab.prototype.getContent = function(){
	if(this.content == null){
		var id = this.id.substring(3);
		this.content = document.getElementById("content"+id);
		if(!this.content){
			alert("tab.id = "+this.id +"\n"
				  + "content"+id+" does not exist!");
		}
	}
	return this.content;
};

Tab.prototype.getTabSystem = function(){ return this.tabSystem; };

hoverTab = function hoverTab() {
	
	var tab = Tab.list[this.id];
	
	var activeTab = tab.tabSystem.activeTab;
		if(activeTab && activeTab.id == tab.id)	return;
	
	tab.setClassName("tabHover tab");
	
	if(tab.hoversrc)
		tab.el.src = tab.hoversrc;
};

hoverOff = function hoverOff() {

	var tab = Tab.list[this.id];

	var activeTab = tab.tabSystem.activeTab;
		if(activeTab && activeTab.id == tab.id)	return;
	
	tab.setClassName("tab");
	
	if(tab.normalsrc) 
		tab.el.src = tab.normalsrc;
};


Tab.prototype.toString = function(){return this.id;};

/** Resets a tab to default state.
 */
function resetTab(tab) {

	tab.setClassName("tab");

	if(tab.normalsrc)
		tab.el.src = tab.normalsrc;
	
	tab.getContent().style.display = tabDisplayNone;
		
	tab.getContent().style.visibility = "hidden";
}



/**
 * ControllerTab class
 */
ControllerTab = function ControllerTab(el, ts){

	if(arguments.length == 0) return;

	this.souper(el, ts);
		
	if(el.tagName.toLowerCase() == "img"){
	
		this.normalsrc = el.src;
		this.hoversrc = el.getAttribute("hoversrc");
		this.activesrc = el.getAttribute("activesrc");
		
	}
	
	if(hasToken(el.className, "tabActive")){
	
		this.depressTab();
		this.tabSystem.defaultActiveTab = this;
		
	}
	else { 
		this.getContent().style.display = tabDisplayNone;
		this.getContent().style.visibility = "hidden";
		if(Browser.id.OP5)setTimeout('Tab.list.'+this.id+'.content.style.position = "absolute";',50);
	}
	this.tabSystem.tabs[this.tabSystem.tabs.length] = this;
};
ControllerTab.extend(Tab);


ControllerTab.prototype.setClassName = function(klass){

	this.el.className = klass;
	if(this.bottomTab)
		this.bottomTab.el.className = klass;
};

/** ControllerTab Event Handler Methods
 *
 *  hoverTab()    - called from el onmouseover and invoked by bottomTab.
 *  hoverOff()    - called from el onmouseout and invoked by bottomTab.
 *
 * 
 *  depressTab(e) - called with "on"+eventType
 */
ControllerTab.prototype.hoverTab = hoverTab;
ControllerTab.prototype.hoverOff = hoverOff;

ControllerTab.prototype.depressTab = function depressTab(e) {
	
	var tab = Tab.list[this.id];
	var tabSystem = tab.tabSystem;
	
	tabSystem.nextTab = tab;
	
	if(tabSystem.activeTab == tab) return;
	
	tabSystem.relatedTab = tabSystem.activeTab;

	if(false == tabSystem.el.onBeforeChange()) return;
	
	tab.el.onActivate();

	tab.setClassName("tab tabActive");

	if(tab.activesrc)
		tab.el.src = tab.activesrc;
		
	if(tabSystem.activeTab)
		resetTab(tabSystem.activeTab);

	tabSystem.activeTab = tab;
	tabSystem.el.onchange();
	
	if(tabSystem.relatedTab)
		tabSystem.relatedTab.getContent().style.display = "none";
	tab.getContent().style.display = "block";
	
	tab.getContent().style.visibility = contentInheritVis;

	tabSystem.nextTab = null;
			
	if(tabSystem.tabsClone)
		tabSystem.showTabsCloneIfNecessary();
	if(Browser.id.MOZ)
		updateTabsClonePosition(1);
};


/**
 * BottomTab class
 */
BottomTab = function BottomTab(el, controllerTab) {
	if(arguments.length == 0) return;

	this.souper(el, controllerTab.tabSystem);
	
	this.controllerTab = controllerTab;	
};
BottomTab.extend(Tab);


/** BottomTab Event Handler Methods
 *
 *  hoverTab()    - called from el onmouseover and invokes controllerTab.hoverTab
 *  hoverOff()    - called from el onmouseout and invokes controllerTab.hoverOff.
 *
 * 
 *  depressTab(e) - called with "on"+eventType
 */
BottomTab.prototype.hoverTab = function(){ this.controllerTab.hoverTab(); };
BottomTab.prototype.hoverOff = function(){ this.controllerTab.hoverOff(); };


BottomTab.prototype.depressTab = function depressClonedTab(e){

	var tabSystem = this.tabSystem;

	if(tabSystem.activeTab == this.controllerTab) return;
	
	this.controllerTab.depressTab(e);
	this.controllerTab.setClassName("tab tabActive");
	window.scrollTo(0, (tabSystem.tabsClone.offsetTop + this.el.offsetHeight) - getViewportHeight());
};



/** switchTabs(id, e, bReturn)
 *
 * USAGE: 
 * [a href='#elmID' onclick='return switchTabs("tab2", event, true);']
 *
 * Will switch to tab2 and then scroll elemId into view.
 *
 * switchTabs(tabId, event, bReturn);
 */
function switchTabs(id, e, bReturn) {

	if(!Browser.isSupported())
		return true;

	try{
		var tab = Tab.list[id];
		tab.depressTab(e);
	}catch(ex){
		//alert(ex);
	}
	if(!bReturn)
		window.scrollTo(0,0);
		
	return bReturn;
}

/**
 * updating and positioning a tabsClone
 */
updateTabsClonePosition = function updateTabsClonePosition(delay){
	for(var id in TabSystem.list)
		if(TabSystem.list[id].tabParams.useClone)
			setTimeout("TabSystem.list."+id+".setTabsClonePosition();", delay || 500);
};
	
	
TabSystem.prototype.setTabsClonePosition = function(){
	
	if(!this.activeTab) return;
	
	var adjustment = 0;
	var contentEl = this.activeTab.content;
	if(Browser.id.IE5_0 || Browser.id.MAC_IE5)
		adjustment = 0;
	else
		adjustment = 2;
		
	this.tabsClone.style.top = (contentEl.offsetHeight + contentEl.offsetTop + adjustment)+px;
};

TabSystem.prototype.showTabsCloneIfNecessary = function(){
	
	if(!this.activeTab) return;

 	var contentEl = this.activeTab.content;
	
	var contentBottom = contentEl.offsetTop + contentEl.offsetHeight;
	var visibility =
		(contentBottom > getViewportHeight() || this.getTabParams().alwaysShowClone) ?
		 "inherit" : "hidden";
	this.tabsClone.style.visibility = visibility;
	this.setTabsClonePosition();
	
	if(Browser.id.MOZ){
	// what's that grey blank on the screen?
		window.scrollBy(0, 1);
		window.scrollBy(0,-1);
	}
	
};


function saveTabSystemState(){
	
	var activeTabList = getElementsWithClass(document.body, TabParams.tabTagName, "tabActive");
	for(var i = 0; i < activeTabList.length; i++){
		if(!activeTabList[i].id) continue;
		activeTabList[i] = activeTabList[i].id;
		setPageCookie("activeTabs"+escape(getFilename()), activeTabList);
	}
};

contentPane.addEventListener("onunload", saveTabSystemState);



function positionTabEl(tab){
// add the width of previous tab plus padding

	var tabs = tab.el.parentNode;
	if(tab.tagName == "IMG" || tab.id.indexOf("Bottomtab") == 0)
		return;
	
	if(!tabs.tabOffset)
		tabs.tabOffset = 0;
	var tabWidth = Math.round(tab.el.offsetWidth*1.1)+15;

	var sty = tab.el.style;

	sty.left = tabs.tabOffset +px;
	
	//add 9px padding to l and r sides
	sty.width = tabWidth +px;
	sty.textAlign = "center";
	sty.display= "block";
	sty.position= "absolute";
	
	
	// add the width of previous tab plus tab-spacing (4)
	tabs.tabOffset += parseInt(tab.el.offsetWidth) + 4;
}
if(Browser.id.OP5)window.document.write("<style>.content{position:absolute;}</style>");