var taskEdit_inited = 0;
var taskEdit_pending = null;

function taskEdit_getResourceListDiv() {
	return document.getElementById('taskEdit_resourceList_div');
}

function taskEdit_searchPopup(url) {
        window.open(url, "searchWindow", 'status=1,scrollbars=1,toolbar=0,location=0,menubar=0,directories=0,resizable=1,height=350,width=400');
}

function taskEdit_getResources() {
	var elts = taskEdit_getResourceListDiv().getElementsByTagName('input');
	var resources = [];

	for (var i = 0; i < elts.length; i++) {
		if (elts[i].getAttribute('type') == 'hidden' &&
		    elts[i].getAttribute('name') == 'resources')
			resources[i] = elts[i].getAttribute('value');
	}

	return resources;
}

function taskEdit_updateExclude(id, kind, resources) {
	var elt = document.getElementById(id);
	if (!elt) return;

	var resourceIds = [];
	for (var i = 0; i < resources.length; i++) {
		var split = resources[i].split(' ', 2);
		if (split[0] == kind)
			resourceIds.push(split[1]);
	}
	var exclude = resourceIds.join(';');

	var href = elt.getAttribute('href');
	href = href.replace(/([?;&]exclude=)[^;&]*/, function(str, p1, offset, s) {
		return p1 + encodeURIComponent(exclude);
	});
	elt.setAttribute('href', href);
}

function taskEdit_updateResources(resources) {
	var div = taskEdit_getResourceListDiv();
	var savedInnerHTML = div.innerHTML;
	div.innerHTML = "<p>Please wait&#8230;</p>";

	var component = encodeURIComponent(resources.join(';'));
	var url = document.location.toString();
    url = url.replace(/[#\?].*/, '');
	url += '?func=innerHtmlOfResources;resources=' + component;
	taskEdit_updateExclude("taskEdit_resourceList_addUser_a", 'user', resources);
	taskEdit_updateExclude("taskEdit_resourceList_addGroup_a", 'group', resources);

	taskEdit_pending = [];
	
	var callback = {
		success : function(req) {
			div.innerHTML = req.responseText;
			taskEdit_doPending();
		},
		failure : function(req) {
			// ToDo: Need better error handling
			div.innerHTML = savedInnerHTML;
			taskEdit_doPending();
		}
    }
	
    var status = YAHOO.util.Connect.asyncRequest('GET',url,callback);
   
}

function taskEdit_doPending() {
	for (var i = 0; i < taskEdit_pending.length; i++) {
		taskEdit_pending[i]();
	}

	taskEdit_pending = null;
}

function taskEdit_addResource(kind, id) {
	if (taskEdit_pending != null) {
		taskEdit_pending.push(function() { taskEdit_addResource(kind, id) });
		return;
	}

	var string = kind+' '+id;
	var resources = taskEdit_getResources();
	resources.push(string);
	taskEdit_updateResources(resources);
}

function taskEdit_queueAddResource(kind, id) {
	window.setTimeout(function() { taskEdit_addResource(kind, id) }, 0);
}

function taskEdit_deleteResource(kind, id) {
	if (taskEdit_pending != null) {
		taskEdit_pending.push(function() { taskEdit_deleteResource(kind, id) });
		return;
	}

	var string = kind+' '+id;
	var resources = taskEdit_getResources();
	for (var i = 0; i < resources.length; i++) {
		if (resources[i] == string) {
			resources.splice(i, 1);
			break;
		}
	}
	taskEdit_updateResources(resources);
}
