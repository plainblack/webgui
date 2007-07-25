/******************************************
CM_ADD-IN - hideselectboxes (last updated: 11/13/02)
IE5+ and NS6+ only - ignores the other browsers

Because of the selectbox bug in the browsers that makes 
selectboxes have the highest z-index whatever you do 
this script will check for selectboxes that interfear with
your menu items and then hide them. 

Just add this code to the coolmenus js file
or link the cm_addins.js file to your page as well.
*****************************************/
if(bw.dom&&!bw.op){
  makeCM.prototype.sel=0
  makeCM.prototype.onshow+=";this.hideselectboxes(pm,pm.subx,pm.suby,maxw,maxh,pm.lev)"
  makeCM.prototype.hideselectboxes=function(pm,x,y,w,h,l){
    var selx,sely,selw,selh,i
    if(!this.sel){
      this.sel=this.doc.getElementsByTagName("SELECT")
		  this.sel.level=0
    }
    var sel=this.sel
    for(i=0;i<sel.length;i++){
			selx=0; sely=0; var selp;
			if(sel[i].offsetParent){selp=sel[i]; while(selp.offsetParent){selp=selp.offsetParent; selx+=selp.offsetLeft; sely+=selp.offsetTop;}}
			selx+=sel[i].offsetLeft; sely+=sel[i].offsetTop
			selw=sel[i].offsetWidth; selh=sel[i].offsetHeight			
			if(selx+selw>x && selx<x+w && sely+selh>y && sely<y+h){
				if(sel[i].style.visibility!="hidden"){sel[i].level=l; sel[i].style.visibility="hidden"; if(pm){ if(!pm.mout) pm.mout=""; pm.mout+=this.name+".sel["+i+"].style.visibility='visible';"}}
      }else if(l<=sel[i].level && !(pm&&l==0)) sel[i].style.visibility="visible"
    }
  }
}
/******************************************
CM_ADD-IN - checkscrolled (last updated: 01/29/02)
This is supported by all browsers
- IE5 for MAC has some screen refreshing problems 
- Using this for non-ie browsers might slow down the page
  because the other browsers do not support the onscroll event
  so the script uses a timer.

Now with two new features.
- Set scrollstop to 1 to get another scrolling effect.
  If you do it will work the way it does on DHTMLCentral.com.
  Note that this feature is not perfect on menus not in rows.
- If you have the hideselectboxes add-in as well this function
  will now check for interfearing selectboxes when you scroll as 
  well.

Just add this code to the coolmenus js file
or link the cm_addins.js file to your page as well.
*****************************************/
if(bw.ie) makeCM.prototype.onconstruct='document.body.onscroll=new Function(c.name+".checkscrolled("+c.name+")")'
else makeCM.prototype.onconstruct='setTimeout(c.name+".checkscrolled()",200)' //REMOVE THIS LINE TO HAVE SCROLLING ON FOR EXPLORER ONLY!!
makeCM.prototype.lscroll=0
makeCM.prototype.scrollstop=0 //Set this variable to 1 for another scrolling effect. Leave at 0 to scroll regular
makeCM.prototype.checkscrolled=function(obj){
	var i;
	if(bw.mac) return //REMOVE THIS LINE TO HAVE SCROLLING ON THE MAC AS WELL - unstable!
  var c=bw.ie?obj:this, o
	if(bw.ns4 || bw.ns6 || bw.op5) c.scrollY=window.pageYOffset
	else c.scrollY=document.body.scrollTop
	if(c.scrollY!=c.lscroll){
    c.hidesub()
    if(c.scrollY>c.fromTop&&c.scrollstop){
      for(i=0;i<c.l[0].m.length;i++){o=c.m[c.l[0].m[i]].b; o.moveIt(o.x,c.scrollY)}
      if(c.useBar) c.bar.moveIt(c.bar.x,c.scrollY)
    }else{
      if(c.scrollstop){
        for(i=0;i<c.l[0].m.length;i++){o=c.m[c.l[0].m[i]].b; o.moveIt(o.x,c.fromTop)}
        if(c.useBar) c.bar.moveIt(c.bar.x,c.barY)
      }else{
        for(i=0;i<c.l[0].m.length;i++){o=c.m[c.l[0].m[i]].b; o.moveIt(o.x,o.oy+c.scrollY)}
        if(c.useBar) c.bar.moveIt(c.bar.x,c.barY+c.scrollY)
      }
    }
		c.lscroll=c.scrollY; cmpage.y=c.scrollY; cmpage.y2=cmpage.orgy+c.scrollY
		if(bw.ie){ clearTimeout(c.tim); c.isover=0; c.hidesub()}
    if(c.hideselectboxes){ //If you are using the hideselect add-in as well the script will now check for selectboxes when scrolling as well
      var x = c.useBar?c.m[c.l[0].m[0]].b.x>c.bar.x?c.bar.x:c.m[c.l[0].m[0]].b.x:c.m[c.l[0].m[0]].b.x;
      var y = c.useBar?c.m[c.l[0].m[0]].b.y>c.bar.y?c.bar.y:c.m[c.l[0].m[0]].b.y:c.m[c.l[0].m[0]].b.y;
      var maxw = c.useBar?c.bar.w:c.rows?c.totw:c.maxw; var maxh = c.useBar?c.bar.h:!c.rows?c.toth:c.maxh
      c.hideselectboxes(0,x,y,maxw,maxh,0)
    }
	}
	if(!bw.ie) setTimeout(c.name+".checkscrolled()",200)
}
/******************************************
CM_ADD-IN - pagecheck (last updated: 08/02/02)

Simple code that *tries* to keep the menus inside the
bounderies of the page.

Code updated. It's still not perfect (obviosly)
but it will now do another check to try and place 
the menus inside.


Just add this code to the coolmenus js file
or link the cm_addins.js file to your page.
*****************************************/
makeCM.prototype.onshow+=";this.pagecheck(b,pm,pm.subx,pm.suby,maxw,maxh)"
makeCM.prototype.pagecheck=function(b,pm,x,y,w,h,n){  
  var l=pm.lev+1,a=b.align; if(!n) n=1
  var ok=1
  if(x<cmpage.x) {pm.align=1; ok=0;}
  else if(x+w>cmpage.x2){ pm.align=2; ok=0;}
  else if(y<cmpage.y) { pm.align=3; ok=0;}
  else if(h+y>cmpage.y2) {pm.align=4; ok=0;}
  if(!ok) this.getcoords(pm,this.l[l-1].borderX,this.l[l-1].borderY,pm.b.x,pm.b.y,w,h,this.l[l-1].offsetX,this.l[l-1].offsetY)
  x=pm.subx; y=pm.suby
	//Added check --- still not ok? --- part of the code by Denny Caldwell (thanks) -- badly immplemented by me though
  if(x<cmpage.x) {x += cmpage.x-x;}
  else if(x+w>cmpage.x2){ x = -(x+w-cmpage.x2);}
  else if(y<cmpage.y) { y = cmpage.y-y; }
  else if(h+y>cmpage.y2) {y = -(y+h-cmpage.y2);}
  if(x<cmpage.x) {x += cmpage.x-x;}
  else if(x+w>cmpage.x2){ x = -(x+w-cmpage.x2);}
  else if(y<cmpage.y) { y = cmpage.y-y;}
  else if(h+y>cmpage.y2) {y = -(y+h-cmpage.y2);}
	b.moveIt(x,y)  
}
/******************************************
CM_ADD-IN - pagecheck (last updated: 01/26/02)
Simple code that *tries* to keep the menus inside thebounderies of
the page.A more advanced version of this code will come later.
Just add this code to the coolmenus js fileor link the cm_addins.
js file to your page as well.
*****************************************/
//makeCM.prototype.onshow+=";this.pagecheck2(b,pm,x,y,maxw,maxh)"
makeCM.prototype.pagecheck2=function(b,pm,x,y,w,h){  	
	var fixX = 0	
	var fixY = 0  
	var ok=1	
	if(x+w>cmpage.x2) {
		; 
		ok=0;
	}else if(x<cmpage.x) {
		 ok=0;
	}if(y+h>cmpage.y2){
		fixY = -(y+h-cmpage.y2);
		ok=0;
	}else if(y<cmpage.y) {
		fixY = cmpage.y-y; 
		ok=0;
	}//	self.status="x:"+x+" y:" +y+ " fixX:" +fixX+ " fixY:" +fixY  
	if(!ok) {		
		self.status = x + " - " +cmpage.x + " - " + fixX + " - " + (x+fixX)
		x+=fixX; 
		y+=fixY	  
		pm.moveIt(x,y)	
		self.status = b.css.left
	}  
}

/******************
CM_ADD-IN - filterIt (last updated: 01/26/02)

Explorer5.5+ only. Other browser will ignore it.

This function uses filters for Explorer to show 
the subitems. 
If you use this add-in you will get 1 new 
level property called "filter". You have
to specify which filter to use and what 
level to use them on. 
(this properties will also be inherited though)

Example setting:
oCMenu.level[3].filter="progid:DXImageTransform.Microsoft.Fade(duration=0.5)" 

Examples on how to use this will come later.

Just add this code to the coolmenus js file
or link the cm_addins.js file to your page as well.
*****************/
bw.filter=(bw.ie55||bw.ie6) && !bw.mac
makeCM.prototype.onshow+=";if(c.l[pm.lev].filter) b.filterIt(c.l[pm.lev].filter)"
cm_makeLevel.prototype.filter=null
cm_makeObj.prototype.filterIt=function(f){
  if(bw.filter){
    if(this.evnt.filters[0]) this.evnt.filters[0].Stop(); 
    else this.css.filter=f; 
    this.evnt.filters[0].Apply(); 
    this.showIt(); 
    this.evnt.filters[0].Play();
  }
}
/******************
CM_ADD-IN - slide (last updated: 01/26/02)

This works in all browsers, but it can be 
unstable on all other browsers then Explorer.

This function shows the submenus in a sliding
effect. If you use this add-in you get two 
new level properties called "slidepx" and
"slidetim". You have to specify this for
the levels you want this to happen on 
(these properties will also be inherited though)

slidepx is the number of pixels you want the
div to slide each setTimout, while "slidetim"
is the setTimeout speed (in milliseconds)

Example setting:
oCMenu.level[3].slidepx=10
oCMenu.level[3].slidetim=20

Just add this code to the coolmenus js file
or link the cm_addins.js file to your page as well.
*****************/
makeCM.prototype.onshow+="; if(c.l[pm.lev].slidepx){b.moveIt(x,b.y-b.h); b.showIt(); b.tim=null; b.slide(y,c.l[pm.lev].slidepx,c.l[pm.lev].slidetim,c,pm.lev,pm.name)}"
makeCM.prototype.going=0
cm_makeObj.prototype.tim=10;
cm_makeLevel.prototype.slidepx=null
cm_makeLevel.prototype.slidetim=30
cm_makeObj.prototype.slide=function(end,px,tim,c,l,name){
  if(!this.vis || c.l[l].a!=name) return
	if(this.y<end-px){
		if(this.y>(end-px*px-px) && px>1) px-=px/5; this.moveIt(this.x,this.y+px)
		this.clipTo(end-this.y,this.w,this.h,0)
		this.tim=setTimeout(this.obj+".slide("+end+","+px+","+tim+","+c.name+","+l+",'"+name+"')",tim)
	}else{this.moveIt(this.x,end)}
}
/******************
CM_ADD-IN - clipout (last updated: 01/26/02)

This works in all browsers, but it can be 
unstable on all other browsers then Explorer.

This function shows the submenus with a clipping
effect. If you use this add-in you get two 
new level properties called "clippx" and
"cliptim". You have to specify this for
the levels you want this to happen on 
(these properties will also be inherited though)

"clippx" is the number of pixels you want the
div to slide each setTimout, while "cliptim"
is the setTimeout speed (in milliseconds)

Example setting:
oCMenu.level[3].clippx=10
oCMenu.level[3].cliptim=20

Just add this code to the coolmenus js file
or link the cm_addins.js file to your page as well.

*****************/
makeCM.prototype.onshow+="if(c.l[pm.lev].clippx){h=b.h; if(!rows) b.clipTo(0,maxw,0,0,1); else b.clipTo(0,0,maxh,0,1); b.clipxy=0; b.showIt(); clearTimeout(b.tim); b.clipout(c.l[pm.lev].clippx,!rows?maxw:maxh,!rows?maxh:maxw,c.l[pm.lev].cliptim,rows)}"
cm_makeObj.prototype.tim=10;
cm_makeLevel.prototype.clippx=null
cm_makeLevel.prototype.cliptim=30
cm_makeObj.prototype.clipxy=0
cm_makeObj.prototype.clipout=function(px,w,stop,tim,rows){
	if(!this.vis) return; if(this.clipxy<stop-px){this.clipxy+=px; 
  if(!rows) this.clipTo(0,w,this.clipxy,0,1);
  else this.clipTo(0,this.clipxy,w,0,1);
  this.tim=setTimeout(this.obj+".clipout("+px+","+w+","+stop+","+tim+","+rows+")",tim)
	}else{if(bw.ns6){this.hideIt();}; if(!rows) this.clipTo(0,w,stop,0,1); else this.clipTo(0,stop,w,0,1);if(bw.ns6){this.showIt()}}
}