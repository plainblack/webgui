var panelButtonHeight = 23;
var panelLinkTop = 25;



//create a crossbrowser layer object
function createLayerObject(name) {
  	this.name=name;
  	this.obj=document.getElementById(name);
  	this.cssobj.style;
  	this.x=parseInt(this.css.left);
  	this.y=parseInt(this.css.top);
  	this.show=b_show;
  	this.hide=b_hide;
  	this.moveTo=b_moveTo;
  	this.moveBy=b_moveBy;
  	this.writeText=b_writeText;
  	return this;
}

//crossbrowser show
function b_show(){
  	this.css.visibility='visible';
}

//crossbrowser hide
function b_hide(){
  	this.css.visibility='hidden';
}

//crossbrowser move absolute
function b_moveTo(x,y){
	this.x = x;
  	this.y = y;
  	this.css.left=x;
  	this.css.top=y;
}

//crossbrowser move relative
function b_moveBy(x,y){
  	this.moveTo(this.x+x, this.y+y)
}

//write text into a layer
function b_writeText(text) {
     	this.obj.innerHTML=text;
}

//add one button to a panel
function b_addLink(img, label, action) {
  	this.img[this.img.length]=img;
  	this.lbl[this.lbl.length]=label;
  	this.act[this.act.length]=action;
  	this.sta[this.sta.length]=0;
  	return this
}

//test if scroll buttons should be visible
function b_testScroll() {
    	var i=parseInt(this.obj.style.height);
    	var j=parseInt(this.objf.style.height);
  	var k=parseInt(this.objf.style.top);
  	if (k==panelLinkTop)
    		this.objm1.style.visibility='hidden';
  	else
    		this.objm1.style.visibility='visible';
  	if ((j+k)<i)
    		this.objm2.style.visibility='hidden';
  	else
    		this.objm2.style.visibility='visible';
}

//scroll the panel content up
function b_up(nr) {


	this.ftop = this.ftop - 5;
    	this.objf.style.top=(this.ftop+'px');
    	//this.objf.style.zIndex=1;
	nr--;
    	if (nr>0)
      		setTimeout(this.v+'.up('+nr+');',10);
    	else
      		this.testScroll();
}



//scroll the panel content down
function b_down(nr) {
	this.ftop = this.ftop + 5;
    	if (this.ftop>=panelLinkTop) {
      		this.ftop=panelLinkTop;
      		nr=0;
    	}
    	this.objf.style.top=(this.ftop+'px');
    	nr--;
    	if (nr>0)
      		setTimeout(this.v+'.down('+nr+');',10);
    	else
      		this.testScroll();
}

//create one panel
function createPanel(name,caption) {
  	this.name=name;                  // panel layer ID
  	this.ftop=panelLinkTop;                    // actual panel scroll position
  	this.obj=null;                   // panel layer object
  	this.objc=null;                  // caption layer object
  	this.objf=null;                  // panel field layer object
  	this.objm1=null;                 // scroll button up
  	this.objm2=null;                 // scroll button down
  	this.caption=caption;            // panel caption
  	this.img=new Array();            // button images
  	this.lbl=new Array();            // button labels
  	this.act=new Array();            // button actions
  	this.sta=new Array();            // button status (internal)
  	this.addLink=b_addLink;      // add one button to panel
    	this.testScroll=b_testScroll;    // test if scroll buttons should be visible
    	this.up=b_up;                    // scroll panel buttons up
    	this.down=b_down;                // scroll panel buttons down
  	this.v = this.name + "var";   // global var of 'this'
  	eval(this.v + "=this");
  	return this
}

//add one panel to the slider
function b_addPanel(panel) {
  	panel.name=this.name+'_panel'+this.panels.length
  	this.panels[this.panels.length] = panel;
}


// Draw the slider
function b_draw() {
	document.body.style.marginLeft = '160px';	
	var i;
	var j;
	var t=0;
	var h;
	var c=3;

	//slide panel bar
	var slidemenu_width='160px' //specify width of menu (in pixels)
	var slidemenu_reveal='15px' //specify amount that menu should protrude initially
	var slidemenu_top='0px'   //specify vertical offset of menu on page
	//document.write('<div id="slidePanelBar" style="left:'+((parseInt(slidemenu_width)-parseInt(slidemenu_reveal))*-1)+'px; top:'+slidemenu_top+'px; width:'+slidemenu_width+'px;" onmouseover="pullSlidePanelBar()" onmouseout="pushSlidePanelBar()">');
	document.write('<div id="slidePanelBar" style="left:0px; top:'+slidemenu_top+'px; width:'+slidemenu_width+'px"/ >');
	//document.write('<div id="slidePanelBarHandle">&raquo;<br />&raquo;<br />&raquo;<br />&raquo;<br />&raquo;<br /></div>');

    	//slide panel .
    	document.write('<div class="slidePanel" id="'+this.name+'" style="left:');
    	document.write(this.xpos+'px; top:'+this.ypos+'px; width:'+this.width);
    	document.write('px; height:'+this.height+'px; ')
    	document.write('; clip:rect(0px,'+this.width+'px,'+this.height+'px,0px)">');
    	h=this.height-((this.panels.length-1)*panelButtonHeight)

    	//one layer for every panel...
    	for (i=0;i<this.panels.length;i++) {
      		document.write('<div class="panel" id="'+this.name+'_panel'+i);
      		document.write('" style="top:'+t);
      		document.write('px; width:'+this.width+'px; height:'+h+'px; clip:rect(0px, ');
      		document.write(this.width+'px, '+h+'px, 0px);">');
      		t=t+panelButtonHeight;

       		//one layer to host the panel links 
      		document.write('<div class="panelLinkHolder" id="'+this.name+'_panel'+i);
      		document.write('_f" style="top:'+panelLinkTop+'px; width:');
      		document.write(this.width+'px; height:');
      		document.write((this.panels[i].img.length*this.buttonspace)+'px;">');
      		mtop=0

      		for (j=0;j<this.panels[i].img.length;j++) {
			document.write('<div id="'+this.name+'_panel'+i+'_b'+j+'" class="panelLinkOut" style="top:'+mtop+'px;width:'+this.width+'px;" onmouseover="this.className=\'panelLinkIn\';" onmouseup="document.location=\''+this.panels[i].act[j]+'\';" onmouseout="this.className=\'panelLinkOut\';">');
			document.write('<img src="'+this.panels[i].img[j]+'" align="middle" border="0px" alt="icon" />');
			document.write(' '+this.panels[i].lbl[j]);
			document.write('</div>');
        		mtop=mtop+this.buttonspace;
      		}

      		document.write('</div>');

        	document.write('<div id="'+this.name+'_panel'+i+'_c" class="panelButton" ');
        	document.write('onClick="javascript:'+this.v+'.showPanel('+i);
        	document.write(');" style="width:');
        	document.write((this.width-c)+'px; height:'+(panelButtonHeight-c)+'px;"><a href="#" ');
        	document.write('onClick="'+this.v+'.showPanel('+i+');this.blur();');
        	document.write('return false;">');
        	document.write(this.panels[i].caption);
        	document.write('</a></div>')

      		// scroll-up
      		document.write('<div id="'+this.name+'_panel'+i);
      		document.write('_m1" class="scrollPanelUp" style="left:');
      		document.write((this.width-20)+'px;"><a href="#" onclick="');
      		document.write(this.panels[i].v+'.down(16);this.blur();return false;" >');
      		document.write('<img src="'+getWebguiProperty("extrasURL")+'/slidePanel/arrowup.gif" border="0px" alt="scroll up" />');
      		document.write('</a></div>');

		// scroll-down
      		document.write('<div class="scrollPanelDown" id="'+this.name+'_panel'+i);
      		document.write('_m2" style="top:');
      		document.write((this.height-(this.panels.length)*panelButtonHeight)+'px; left:');
      		document.write((this.width-20)+'px;"><a href="#" onclick="');
      		document.write(this.panels[i].v+'.up(16);this.blur();return false">');
      		document.write('<img src="'+getWebguiProperty("extrasURL")+'/slidePanel/arrowdown.gif" border="0px" alt="scroll down" />');
      		document.write('</a></div>');

      		document.write('</div>')

    	}
    	document.write('</div>');

  	for (i=0;i<this.panels.length;i++) {
    		this.panels[i].obj=document.getElementById(this.name+'_panel'+i);
      		this.panels[i].obj.style.zIndex=10000;
		this.panels[i].objc=document.getElementById(this.name+'_panel'+i+'_c');
      		this.panels[i].objf=document.getElementById(this.name+'_panel'+i+'_f');
      		this.panels[i].objm1=document.getElementById(this.name+'_panel'+i+'_m1');
      		this.panels[i].objm2=document.getElementById(this.name+'_panel'+i+'_m2');
    		this.panels[i].testScroll();
  	}
	rightboundary=0
	leftboundary=(parseInt(slidemenu_width)-parseInt(slidemenu_reveal))*-1

	document.write('</div>')
	themenu=document.getElementById("slidePanelBar").style;

  	//activate last panel
    	//actual panel is saved in a cookie
    	if (document.cookie)
      		this.showPanel(document.cookie);
        else
      		this.showPanel(0);
	//float the panel as someone scrolls
        startY = 0;
        var d = document;
        function ml(id)
        {
                var el=d.getElementById?d.getElementById(id):d.all?d.all[id]:d.layers[id];
                if(d.layers)el.style=el;
                el.sP=function(y){this.style.top=y;};
                el.y = startY;
                return el;
        }
        window.floatBarWithScroll=function()
        {
                
		//Added to allow support for xhtml transitional
		var docElement = document.documentElement;
    
		if (document.compatMode && document.compatMode == "BackCompat") {
			docElement = document.body;
		}

		
		//var pY = document.body.scrollTop;
                var pY = docElement.scrollTop;
		ftlObj.y += (pY + startY - ftlObj.y)/8;
                ftlObj.sP(ftlObj.y);
                setTimeout("floatBarWithScroll()", 10);
        }
        ftlObj = ml("slidePanelBar");
        floatBarWithScroll();
}



function b_showPanel(nr) {
	var i
	var l
	var o
  //	document.cookie=nr;
  	this.aktPanel=nr;
  	l = this.panels.length;
  	for (i=0;i<l;i++) {
    		//alert(nr);		
		if (i>nr) {
      			this.panels[i].obj.style.top=this.height-((l-i)*panelButtonHeight)+"px";
    		} else {
      			this.panels[i].obj.style.top=i*panelButtonHeight+"px";
    		}
  	}
}

function createSlidePanelBar(name) {
	//Added to allow support for xhtml transitional
	var docElement = document.documentElement;
    
	if (document.compatMode && document.compatMode == "BackCompat") {
		docElement = document.body;
	}  	
	
	
	this.aktPanel=0;                        // last open panel
  	this.name=name                          // name
  	this.xpos=0;                            // bar x-pos
  	this.ypos=0;                            // bar y-pos
  	this.width=160;                       // bar width
  	//this.height=((navigator.appVersion.indexOf("MSIE ") == -1)?innerHeight:document.body.offsetHeight)-10;                     // bar height
	this.height=((navigator.appVersion.indexOf("MSIE ") == -1)?innerHeight:docElement.offsetHeight)-10;                     // bar height
  	this.buttonspace=22                     // distance of panel buttons
  	this.panels=new Array()                 // panels
  	this.addPanel=b_addPanel;               // add new panel to bar
  	this.draw=b_draw;                       // write HTML code of bar
    	this.showPanel=b_showPanel;           // make a panel visible
  	this.v = name + "var";                  // global var of 'this'
  	eval(this.v + "=this");
  	return this
}


function pullSlidePanelBar(){
	if (window.drawit)
		clearInterval(drawit);
	pullit=setInterval("pullengine()",10);
	document.getElementById("slidePanelBarHandle").innerHTML="";
}

function pushSlidePanelBar(){
	clearInterval(pullit);
	drawit=setInterval("drawengine()",10);
	document.getElementById("slidePanelBarHandle").innerHTML="&raquo;<br />&raquo;<br />&raquo;<br />&raquo;<br />&raquo;<br />";
}

function pullengine(){
	if (parseInt(themenu.left)<rightboundary)
		themenu.left=parseInt(themenu.left)+10+"px";
	else if (window.pullit){
		themenu.left=0;
		clearInterval(pullit);
	}
}

function drawengine(){
	if (parseInt(themenu.left)>leftboundary)
		themenu.left=parseInt(themenu.left)-10+"px";
	else if (window.drawit){
		themenu.left=leftboundary;
		clearInterval(drawit);
	}
}

