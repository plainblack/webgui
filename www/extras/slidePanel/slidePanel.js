var slidePanelButtonHeight = 23;
var slidePanelLinkTop = slidePanelButtonHeight+2;

//add one button to a panel
function sp_addLink(img, label, action) {
  	this.img[this.img.length]=img;
  	this.lbl[this.lbl.length]=label;
  	this.act[this.act.length]=action;
  	this.sta[this.sta.length]=0;
  	return this
}

//test if scroll buttons should be visible
function sp_testScroll() {
    	var i=parseInt(this.obj.style.height);
    	var j=parseInt(this.objf.style.height);
  	var k=parseInt(this.objf.style.top);
  	if (k==slidePanelLinkTop)
    		this.objm1.style.visibility='hidden';
  	else
    		this.objm1.style.visibility='visible';
  	if ((j+k)<i)
    		this.objm2.style.visibility='hidden';
  	else
    		this.objm2.style.visibility='visible';
}

//scroll the panel content up
function sp_up(nr) {
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
function sp_down(nr) {
	this.ftop = this.ftop + 5;
    	if (this.ftop>=slidePanelLinkTop) {
      		this.ftop=slidePanelLinkTop;
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
  	this.ftop=slidePanelLinkTop;                    // actual panel scroll position
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
  	this.addLink=sp_addLink;      // add one button to panel
    	this.testScroll=sp_testScroll;    // test if scroll buttons should be visible
    	this.up=sp_up;                    // scroll panel buttons up
    	this.down=sp_down;                // scroll panel buttons down
  	this.v = this.name + "var";   // global var of 'this'
  	eval(this.v + "=this");
  	return this
}

//add one panel to the slider
function sp_addPanel(panel) {
  	panel.name=this.name+'_panel'+this.panels.length
  	this.panels[this.panels.length] = panel;
}


// Draw the slider
function sp_draw() {
	document.body.style.marginLeft = this.width+'px';	
	var i;
	var j;
	var t=0;
	var h;
	var c=3;

	//slide panel 
	document.write('<div id="slidePanel" style="width:'+this.width+'px; ');
	document.write('height:'+this.height+'px; overflow:hidden">');
    	document.write('<div class="slidePanel" id="'+this.name+'" style="left:');
    	document.write(this.xpos+'px; top:'+this.ypos+'px; width:'+this.width);
    	document.write('px; height:'+this.height+'px; ')
    	document.write('; clip:rect(0px,'+this.width+'px,'+this.height+'px,0px)">');
    	h=this.height-((this.panels.length-1)*slidePanelButtonHeight)

    	//one layer for every panel...
    	for (i=0;i<this.panels.length;i++) {
      		document.write('<div class="panel" id="'+this.name+'_panel'+i);
      		document.write('" style="top:'+t);
      		document.write('px; width:'+this.width+'px; height:'+h+'px; clip:rect(0px, ');
      		document.write(this.width+'px, '+h+'px, 0px);">');
      		t=t+slidePanelButtonHeight;

       		//one layer to host the panel links 
      		document.write('<div class="panelLinkHolder" id="'+this.name+'_panel'+i);
      		document.write('_f" style="top:'+slidePanelLinkTop+'px; width:');
      		document.write(this.width+'px; height:');
      		document.write((this.panels[i].img.length*this.buttonspace)+'px;">');
      		mtop=0

      		for (j=0;j<this.panels[i].img.length;j++) {
			document.write('<div id="'+this.name+'_panel'+i+'_b'+j+'" class="panelLinkOut" style="top:'+mtop+'px;width:'+this.width+'px;" onmouseover="this.className=\'panelLinkIn\';" onmouseup="document.location=\''+this.panels[i].act[j]+'\';" onmouseout="this.className=\'panelLinkOut\';">');
			document.write('<p style="display:inline;vertical-align:middle;"><img src="'+this.panels[i].img[j]+'" style="border: 0px; vertical-align: middle;" alt="icon" />');
			document.write(' '+this.panels[i].lbl[j]);
			document.write('</p></div>');
        		mtop=mtop+this.buttonspace;
      		}

      		document.write('</div>');

        	document.write('<div id="'+this.name+'_panel'+i+'_c" class="slidePanelButton" ');
        	document.write('onClick="javascript:'+this.v+'.showPanel('+i);
        	document.write(');" style="width:');
        	document.write((this.width-c)+'px; height:'+(slidePanelButtonHeight-c)+'px;"><a href="#" ');
        	document.write('onClick="'+this.v+'.showPanel('+i+');this.blur();');
        	document.write('return false;">');
        	document.write(this.panels[i].caption);
        	document.write('</a></div>')

      		// scroll-up
      		document.write('<div id="'+this.name+'_panel'+i);
      		document.write('_m1" class="scrollPanelUp" style="left:');
      		document.write((this.width-20)+'px;"><a href="#" onclick="');
      		document.write(this.panels[i].v+'.down(16);this.blur();return false;" >');
      		document.write('<img src="'+getWebguiProperty("extrasURL")+'/slidePanel/arrowup.gif" style="border: 0px;" alt="scroll up" />');
      		document.write('</a></div>');

		// scroll-down
      		document.write('<div class="scrollPanelDown" id="'+this.name+'_panel'+i);
      		document.write('_m2" style="top:');
      		document.write((this.height-(this.panels.length)*slidePanelButtonHeight)+'px; left:');
      		document.write((this.width-20)+'px;"><a href="#" onclick="');
      		document.write(this.panels[i].v+'.up(16);this.blur();return false">');
      		document.write('<img src="'+getWebguiProperty("extrasURL")+'/slidePanel/arrowdown.gif" style="border: 0px;" alt="scroll down" />');
      		document.write('</a></div>');

      		document.write('</div>')

    	}
    	document.write('</div></div>')

  	for (i=0;i<this.panels.length;i++) {
    		this.panels[i].obj=document.getElementById(this.name+'_panel'+i);
      		this.panels[i].obj.style.zIndex=10000;
		this.panels[i].objc=document.getElementById(this.name+'_panel'+i+'_c');
      		this.panels[i].objf=document.getElementById(this.name+'_panel'+i+'_f');
      		this.panels[i].objm1=document.getElementById(this.name+'_panel'+i+'_m1');
      		this.panels[i].objm2=document.getElementById(this.name+'_panel'+i+'_m2');
    		this.panels[i].testScroll();
  	}
  	//activate last panel
    	//actual panel is saved in a cookie
	var cookie = sp_readCookie("slidePanel");
    	if (cookie)
      		this.showPanel(cookie);
        else
      		this.showPanel(this.panels.length-1);
	//float the panel as someone scrolls
        startY = 0;
        var d = document;
        function ml(id) {
                var el=d.getElementById?d.getElementById(id):d.all?d.all[id]:d.layers[id];
                if(d.layers)el.style=el;
                el.sP=function(y){this.style.top=y+"px";};
                el.y = startY;
                return el;
        }
        window.floatSlidePanelWithScroll=function() {
		//Added to allow support for xhtml transitional
		var docElement = document.documentElement;
		if (document.compatMode && document.compatMode == "BackCompat") {
			docElement = document.body;
		}
		//var pY = document.body.scrollTop;
                var pY = docElement.scrollTop;
		ftlObj.y += (pY + startY - ftlObj.y)/1;
		if (ftlObj.y < 0) {
			ftlObj.y = 0
		}
                ftlObj.sP(ftlObj.y);
                setTimeout("floatSlidePanelWithScroll()", 10);
        }
        ftlObj = ml("slidePanel");
        floatSlidePanelWithScroll();
}



function sp_showPanel(nr) {
	var i
	var l
	var o
	sp_createCookie("slidePanel",nr,1);
  	this.aktPanel=nr;
  	l = this.panels.length;
  	for (i=0;i<l;i++) {
    		//alert(nr);		
		if (i>nr) {
      			this.panels[i].obj.style.top=this.height-((l-i)*slidePanelButtonHeight)+"px";
    		} else {
      			this.panels[i].obj.style.top=i*slidePanelButtonHeight+"px";
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
  	this.name=name;                          // name
  	this.xpos=0;                            // bar x-pos
  	this.ypos=0;                            // bar y-pos
  	this.width=160;                       // bar width
  	//this.height=((navigator.appVersion.indexOf("MSIE ") == -1)?innerHeight:document.body.offsetHeight)-10;                     // bar height
	this.height=((navigator.appVersion.indexOf("MSIE ") == -1)?innerHeight:docElement.offsetHeight)*0.95;                   // bar height
  	this.buttonspace=slidePanelButtonHeight-1;                     // distance of panel buttons
  	this.panels=new Array();                 // panels
  	this.addPanel=sp_addPanel;               // add new panel to bar
  	this.draw=sp_draw;                       // write HTML code of bar
    	this.showPanel=sp_showPanel;           // make a panel visible
  	this.v = name + "var";                  // global var of 'this'
  	eval(this.v + "=this");
  	return this;
}


function sp_createCookie(name,value,days) {
	if (days)
	{
		var date = new Date();
		date.setTime(date.getTime()+(days*24*60*60*1000));
		var expires = "; expires="+date.toGMTString();
	}
	else var expires = "";
	document.cookie = name+"="+value+expires+"; path=/";
}

function sp_readCookie(name) {
	var nameEQ = name + "=";
	var ca = document.cookie.split(';');
	for(var i=0;i < ca.length;i++)
	{
		var c = ca[i];
		while (c.charAt(0)==' ') c = c.substring(1,c.length);
		if (c.indexOf(nameEQ) == 0) return c.substring(nameEQ.length,c.length);
	}
	return null;
}

function sp_eraseCookie(name) {
	sp_createCookie(name,"",-1);
}


