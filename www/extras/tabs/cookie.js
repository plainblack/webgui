/**
 * cookie.js 
 * by Garrett Smith 
 * Updated 11-29-2002
 *
 * getCookie function based upon:
 * Cookie API  v1.0
 * http://www.dithered.com/javascript/cookies/index.html
 * maintained by Chris Nott (chris@NOSPAMdithered.com - remove NOSPAM)
 */

// Write a cookie value based on the current directory.
function setPageCookie(name, value) {
	document.cookie = name + "=" + escape(value) + "; path=" + getPath();
}

// Retrieve a named cookie value
function getCookie(name) {
	var dc = document.cookie;
	
	// find beginning of cookie value in document.cookie
	var prefix = name + "=";
	var begin = dc.lastIndexOf(prefix);
	if (begin == -1) return null;
	
	// find end of cookie value
	var end = dc.indexOf(";", begin);
	if (end == -1) end = dc.length;
	
	// return cookie value
	return unescape(dc.substring(begin + prefix.length, end));
}

function deletePageCookie(name, path) {
	var value = getCookie(name);
	if (value != null)
		document.cookie = 
			name + "=" 
				 + "; path=" + getPath() 
				 + "; expires=Thu, 01-Jan-70 00:00:01 GMT";
	return value;
}


function getFilename(){
	var href = window.location.href;
	var file = href.substring(href.lastIndexOf("/") +1);
	return file;
}

function getPath(){
	var href = window.location.href;
	var path = href.substring(href.indexOf("//")+2);
		path = path.substring(path.indexOf("/"));
		path = path.substring(0, path.lastIndexOf("/")+1);
	
	return path;
}