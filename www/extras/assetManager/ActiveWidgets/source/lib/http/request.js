/*****************************************************************

	ActiveWidgets Grid 1.0.0 (Free Edition).
	Copyright (C) 2004 ActiveWidgets Ltd. All Rights Reserved. 
	More information at http://www.activewidgets.com/

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

*****************************************************************/

Active.HTTP.Request = Active.System.Model.subclass();

Active.HTTP.Request.create = function(){

/****************************************************************

	Generic HTTP request class.

*****************************************************************/

	var obj = this.prototype;

/****************************************************************

	Sets or retrieves the remote data URL.

*****************************************************************/

	obj.defineProperty("URL");

/****************************************************************

	Indicates whether asynchronous download is permitted.

*****************************************************************/

	obj.defineProperty("async", true);

/****************************************************************

	Specifies HTTP request method.

*****************************************************************/

	obj.defineProperty("requestMethod", "GET");

/****************************************************************

	Allows to send data with the request.

*****************************************************************/

	obj.defineProperty("requestData", "");

/****************************************************************

	Returns response text.

*****************************************************************/

	obj.defineProperty("responseText", function(){return this._http ? this._http.responseText : ""});

/****************************************************************

	Returns response XML.

*****************************************************************/

	obj.defineProperty("responseXML", function(){return this._http ? this._http.responseXML : ""});

/****************************************************************

	Sets or retrieves the user name.

*****************************************************************/

	obj.defineProperty("username", null);

/****************************************************************

	Sets or retrieves the password.

*****************************************************************/

	obj.defineProperty("password", null);

/****************************************************************

	Allows to specify namespaces for use in XPath expressions.

	@param name (String) The namespace alias.
	@param value (String) The namespace URL.

*****************************************************************/

	obj.setNamespace = function(name, value){
		this._namespaces += " xmlns:" + name + "=\"" + value + "\"";
	};

	obj._namespaces = "";

/****************************************************************

	Allows to specify the request arguments/parameters.

	@param name (String) The parameter name.
	@param value (String) The parameter value.

*****************************************************************/

	obj.setParameter = function(name, value){
		this["_" + name + "Parameter"] = value;
		if (!this._parameters.match(name)) {this._parameters += " " + name}
	};

	obj._parameters = "";

/****************************************************************

	Sets HTTP request header.

	@param name (String) The request header name.
	@param value (String) The request header value.

*****************************************************************/

	obj.setRequestHeader = function(name, value){
		this["_" + name + "Header"] = value;
		if (!this._headers.match(name)) {this._headers += " " + name}
	};

	obj._headers = "";

	obj.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");

/****************************************************************

	Returns HTTP response header (for example "Content-Type").

*****************************************************************/

	obj.getResponseHeader = function(name){
		return this._http ? this._http.getResponseHeader(name) : "";
	};


/****************************************************************

	Sends the request.

*****************************************************************/

	obj.request = function(){
		var self = this;

		this._ready = false;

		var i, name, value, data = "", params = this._parameters.split(" ");
		for (i=1; i<params.length; i++){
			name = params[i];
			value = this["_" + name + "Parameter"];
			if (typeof value == "function") { value = value(); }
			data += name + "=" + encodeURIComponent(value) + "&";
		}

		var URL = this._URL;

		if ((this._requestMethod != "POST") && data) {
			URL += "?" + data;
			data = null;
		}

		this._http = window.ActiveXObject ? new ActiveXObject("MSXML2.XMLHTTP") : new XMLHttpRequest;
		this._http.open(this._requestMethod, URL, this._async, this._username, this._password);

		var headers = this._headers.split(" ");
		for (i=1; i<headers.length; i++){
			name = headers[i];
			value = this["_" + name + "Header"];
			if (typeof value == "function") { value = value(); }
			this._http.setRequestHeader(name, value);
		}

		this._http.send(data);

		if (this._async) {
			this.timeout(wait, 200);
		}
		else {
			returnResult();
		}

		function wait(){
			if (self._http.readyState == 4) {
				self._ready = true;
				returnResult();
			}
			else {
				self.timeout(wait, 200);
			}
		}

		function returnResult(){
			if (self._http.responseXML && self._http.responseXML.hasChildNodes()) {
				self.response(self._http.responseXML);
			}
			else {
				self.response(self._http.responseText);
			}
		}
	};

/****************************************************************

	Allows to process the received data.

	@param result (Object) The downloaded data (XML DOMDocument object).

*****************************************************************/

	obj.response = function(result){
		if (this.$owner) {this.$owner.refresh()}
	};

/****************************************************************

	Indicates whether the request is already completed.

*****************************************************************/

	obj.isReady = function(){
		return this._ready;
	};

};

Active.HTTP.Request.create();