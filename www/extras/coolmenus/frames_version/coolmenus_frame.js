/*********************************************************************
Function to find a spesified frame - loops all frames 3 levels deep 
(should be enough in most cases, I was to lazy to make a proper one)
*********************************************************************/
function cm_findFrame(frameName){
	obj=top; var frameObj=0;
	for(i=0;i<obj.frames.length;i++){
		if(obj.frames[i].name==frameName){frameObj=obj.frames[i]; break;}; ln=obj.frames[i].frames.length
		for(j=0;j<ln;j++){
			if(obj.frames[i].frames[j].name==frameName){frameObj=obj.frames[i].frames[j];  break}; ln2=obj.frames[i].frames[j].frames.length
			for(a=0;a<ln2;a++){
				if(obj.frames[i].frames[j].frames[a].name==frameName){frameObj=obj.frames[i].frames[j].frames[a]; break}
			}
		}
	}return frameObj
}
/*********************************************************************
Reload function
*********************************************************************/
function cm_reload(sep){
  self.location.href=self.location.href+sep+"reload_coolmenus"
}
/*********************************************************************
Getting the menuobjects
*********************************************************************/
function cm_getItems(menu,orgframe){
  var add,ok = 0, frame
  if(top.name==self.name){
    //We are not in a frameset, so there's no need to do anything at all.
    //This could maybe be used to load the menu directly into the page if
    //the frame didn't exist. That could be nice :)
    // return 
  }
  frame = cm_findFrame(orgframe)
  if(!frame){ //The spesified menu frame doesn't exist
    self.status="CoolMenu error: Missing menu frame. Frame name: "+orgframe
    //return
  }
  if(frame[menu]){//Checking menu object
    if(frame[menu].constructed){//Checking if it's constructed
      frame[menu].makeObjects(0,self)
      self[menu] = frame[menu] //Making a local copy of the menu object
      ok = 1
    }
  }
  if(!ok){
    //This means that we could not find the menus - what to do ??
    //We try to reload this page in a little while to check again.
    search = self.location.search
    //First we check that we haven't already tried:
    if(search.substr(1).indexOf("reload_coolmenus")==-1){
      //We haven't tried, so let's try that.
      if(search.slice(0,1)=="?") sep="&"
      else sep="?"
      //This will override the usuall onload
      //shouldn't use onload, but NS4 didn't like it any other way.
      //I will have another look later on.
      self.onload=new Function('setTimeout("cm_reload(\''+sep+'\')",1000)')
    }
	}
  self.status=ok
}

/*Getting items -- arguments:

menu: The name of the menu object to use
frame: The name of the frame

*/
cm_getItems("oCMenu","frmMenu")

