
//--------Constructor--------------------

function Tools() {
    this.dom=document.getElementById&&!document.all;
    this.topLevelElement=this.dom? "HTML" : "BODY"
    this.getActivity = Tools_getActivity;
    this.debug = Tools_debug;
    this.debugEnabled = false;
    this.getElementChildren = Tools_getElementChildren;
    this.showObject = Tools_showObject;
    this.hideObject = Tools_hideObject;
    this.cancelEvent = Tools_cancelEvent;
    this.setCookie = Tools_setCookie;
    this.getCookie = Tools_getCookie;
    this.deleteCookie = Tools_deleteCookie;
    this.addParamDelimiter = Tools_addParamDelimiter;
    this.getHostName = Tools_getHostName;
    document.write('<div id="tools_debugArea" style="position: absolute; display:none; top:0; left:500;z-index:1000;">');
    document.write('<form name="tools_debug">');
    document.write('<textarea id="out" rows=15 cols=60></textarea>');
    document.write('<input type="button" name="clear" value="clear" onClick="document.tools_debug.out.value=\'\'">');
    document.write('<input type="button" name="close" value="close" onClick="document.getElementById(\'tools_debugArea\').style.display=\'none\'">');
    document.write('</form>');
    document.write('</div>');
    
    this.debugArea = document.getElementById("tools_debugArea");
}

function Tools_getHostName(url) {
	var serverParts = url.split("/");
	return serverParts[2];
}

//returns a ? or & based on contents of url
function Tools_addParamDelimiter(url) {		
	if (url.indexOf("?") == -1) {
		return url + "?";
	}else {
		return url + "&";
    }
}


//---------Method Implementations -------------

//utility method to cancle a build in event.
//ex.  Assume you do not want a link to work.  
//      var tools = new Tools();
//      document.getElementById("linkID").onclick=tools.cancleEvent
function Tools_cancelEvent() {
    return false;
}

//recurses up a tree to get any activity of className activity 
function Tools_getActivity(obj) {
   	var parts = obj.id.split(".");    	    	
   	return manager.assets[parts[0] + "." + parts[1] + "." + parts[2]];
}

//shows a positionable element by toggling the style display property
function Tools_showObject(obj) {
    if (obj) {
        obj.style.visibility="visible";
        obj.style.display="block";
    }
}

//hides a positionable element by toggling the style display property
function Tools_hideObject(obj) {
    if (obj) {
        obj.style.display="none";
    }
}

//gets the element children of a dom object
function Tools_getElementChildren(obj) {
    var myArray= new Array();
    mycnt = 0;
    for (i=0;i<obj.childNodes.length;i++) {
        if (obj.childNodes[i].nodeType==1) {
            myArray[mycnt] = obj.childNodes[i];
            mycnt++;
        }
    }
    return myArray;
}

//writes debug to the debug window written in the constructor
function Tools_debug(str) {
    if (this.debugEnabled) {
        this.debugArea.style.display = "block";
        document.tools_debug.out.value += "DEBUG: " + str + "\n";
    }
}

//set a cookie
function Tools_setCookie(name, value, expires, path, domain, secure) {
  var cookie = name + "=" + escape(value) +
      ((expires) ? "; expires=" + expires.toGMTString() : "") +
      ((path) ? "; path=" + path : "") +
      ((domain) ? "; domain=" + domain : "") +
      ((secure) ? "; secure" : "");
  document.cookie = cookie;
}

//get a cookie;
function Tools_getCookie(name) {
  var cookie = document.cookie;
  var prefix = name + "=";
  var begin = cookie.indexOf("; " + prefix);
  if (begin == -1) {
    begin = cookie.indexOf(prefix);
    if (begin != 0) return null;
  } else
    begin += 2;
  var end = document.cookie.indexOf(";", begin);
  if (end == -1)
    end = cookie.length;
  return unescape(cookie.substring(begin + prefix.length, end));
}

//delete a cookie
function Tools_deleteCookie(name, path, domain) {
  if (Tools_getCookie(name)) {
    document.cookie = name + "=" + ((path) ? "; path=" + path : "") + ((domain) ? "; domain=" + domain : "") + "; expires=Thu, 01-Jan-70 00:00:01 GMT";
  }
}



