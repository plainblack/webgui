if ( typeof WebGUI.Form == "undefined" ) {
    WebGUI.Form = {};
}

if ( typeof WebGUI.Form.GroupManager == "undefined" ) {
    WebGUI.Form.GroupManager = {};
    WebGUI.Form.GroupManager.users_added    = new Array();
    WebGUI.Form.GroupManager.users_deleted  = new Array();
    WebGUI.Form.GroupManager.groups_added   = new Array();
    WebGUI.Form.GroupManager.groups_deleted = new Array();
    WebGUI.Form.GroupManager.last_groupId   = '';
    WebGUI.Form.GroupManager.last_userId    = '';
}

WebGUI.Form.GroupManager.handleCancel = function () {
    this.cancel();
}

YAHOO.util.Event.onDOMReady(function () {
    WebGUI.Form.GroupManager.i18n = new WebGUI.i18n( {
        namespaces : {
            'WebGUI' : [
                'submit', 'Cancel', '84', '89', '149'
            ],
            'Form_Group' : [
                'Group Manager', 'Add Group...', 'Add User...', 'New Group'
            ]
        },
        onpreload : {
            fn : WebGUI.Form.GroupManager.initDialog
        }
    });

});

var groupId = "";

WebGUI.Form.GroupManager.initDialog = function () {
	var tabWrapper = document.getElementById('application_workarea');
	document.body.className= "yui-skin-sam";
	
	var headID = document.getElementsByTagName("head")[0];         

	var dialogBox = document.createElement('div');
	dialogBox.id= "dialog1";
	dialogBox.className= "yui-pe-content";
	dialogBox.innerHTML = '<div class=\'hd\'>' + WebGUI.Form.GroupManager.i18n.get('Form_Group','Group Manager') + '</div>'
	+ '<div class=\'bd\'>'
	+ '<div id=\'groupManagerContainer\'>'
	+ '<form method="POST" action=\'?op=formHelper;class=Group;method=saveGroup;\' id=\'groupManagerForm\'>'
	+ '<input type=\'hidden\' name=\'groupId\' id=\'groupManager_groupId\' />'
	+' <div id=\'groupManagerTable\'>'
	+ '<div id=\'groupNameRow\'><input type=\'textbox\' name=\'groupName\' id=\'groupName\' /></div><div id=\'createNewGroupRow\'><a href=\'#\' onClick=\'WebGUI.Form.GroupManager.createNewGroup()\'><img src=\'/extras/yui-webgui/build/form/assets/new_group.png\' border=\'0\' style=\'width: 24px; height 24px; \' />' + WebGUI.Form.GroupManager.i18n.get('Form_Group','New Group') + '</a></div>'
	+ '<div class=\'groupLabel\'><label for=\'group_lookup\'>'+WebGUI.Form.GroupManager.i18n.get('WebGUI','89')+'</label></div>'
	+ '<div id=\'groupEntry\'><div class=\'addBtn\'><a href="#" id="addGroupBtn" onClick="WebGUI.Form.GroupManager.addGroups()"><img src=\'/extras/yui-webgui/build/form/assets/add.png\' border=\'0\' style=\'width: 16px; height 16px; \' /></a></div><div class=\'entryInput\'><input type=\'textbox\' id=\'group_lookup\' onclick=\'WebGUI.Form.GroupManager.showAutocomplete("group_lookup")\' value=\''+WebGUI.Form.GroupManager.i18n.get('Form_Group','Add Group...')+'\' class=\'yui-ac-input\' autocomplete=\'off\' /></div><div id=\'groupResultsContainer\' class=\'yui-ac-container\'></div></div>'
	+ '<div id=\'groupsAdded_row\'><ul id=\'list_of_groups\'></ul></div>'
	+ '<div class=\'groupLabel\'><label for=\'user_lookup\'>'+WebGUI.Form.GroupManager.i18n.get('WebGUI','149')+'</label></div>'
	+ '<div id=\'userEntry\'><div class=\'addBtn\'><a href="#" id="addGroupBtn" onClick="WebGUI.Form.GroupManager.addUsers()"><img src=\'/extras/yui-webgui/build/form/assets/add.png\' border=\'0\' style=\'width: 16px; height 16px; \' /></a></div><div class=\'entryInput\'><input type=\'textbox\' id=\'user_lookup\' onclick=\'WebGUI.Form.GroupManager.showAutocomplete("user_lookup")\' value=\''+WebGUI.Form.GroupManager.i18n.get('Form_Group','Add Group...')+'\' class=\'yui-ac-input\' autocomplete=\'off\' /></div><div id=\'userResultsContainer\' class=\'yui-ac-container\'></div></div>'
	+ '<div id=\'usersAdded_row\'><ul id=\'list_of_users\'></ul></div>'
	+ '</div>'
    + '<div id=\'gm_form_target\'></div>'
	+ '</form></div></div>';

	tabWrapper.appendChild(dialogBox);

    // Define various event handlers for Dialog
    var handleSubmit = function() {
        this.cancel();
		var url = "?op=formHelper;class=Group;sub=saveGroup;";

        var form_target = document.getElementById("gm_form_target");
		for(var i=0; i < WebGUI.Form.GroupManager.users_added.length; i++) {
            var formlet = document.createElement('input');
            formlet.setAttribute('name', 'usersAdded');
            formlet.setAttribute('type', 'hidden');
            formlet.setAttribute('value', WebGUI.Form.GroupManager.users_added[i]);
            form_target.appendChild(formlet);
		}
		for(var i=0; i < WebGUI.Form.GroupManager.users_deleted.length; i++) {
            var formlet = document.createElement('input');
            formlet.setAttribute('name', 'usersDeleted');
            formlet.setAttribute('type', 'hidden');
            formlet.setAttribute('value', WebGUI.Form.GroupManager.users_deleted[i]);
            form_target.appendChild(formlet);
		}
		for(var i=0; i < WebGUI.Form.GroupManager.groups_added.length; i++) {
            var formlet = document.createElement('input');
            formlet.setAttribute('name', 'groupsAdded');
            formlet.setAttribute('type', 'hidden');
            formlet.setAttribute('value', WebGUI.Form.GroupManager.groups_added[i]);
            form_target.appendChild(formlet);
		}
		for(var i=0; i < WebGUI.Form.GroupManager.groups_deleted.length; i++) {
            var formlet = document.createElement('input');
            formlet.setAttribute('name', 'groupsDeleted');
            formlet.setAttribute('type', 'hidden');
            formlet.setAttribute('value', WebGUI.Form.GroupManager.groups_deleted[i]);
            form_target.appendChild(formlet);
		}
		YAHOO.util.Connect.setForm('groupManagerForm', false);
		YAHOO.util.Connect.asyncRequest('POST', url,{
			success: function (o) {
                var groupObj = YAHOO.lang.JSON.parse(o.responseText);
                var dropdown = document.getElementById(WebGUI.Form.GroupManager.original_form);
                if (groupObj.originalGroupId === 'new') {
                    //Insert this option into the list in the right place, and make it the selected option.
                    var groupOption = new Option(groupObj.groupName, groupObj.groupId, false, true);
                    var groupInserted = false;
                    for(var i=0, dlen = dropdown.options.length; i < dlen; i++) {
                        var gOption = dropdown.options[i];
                        gOption.defaultSelected = false;
                        if(gOption.text > groupObj.groupName && !groupInserted) {
                            groupInserted = true;
                            dropdown.add(groupOption, gOption);
                        }
                    }
                }
                else {
                    dropdown.options[dropdown.selectedIndex].innerHTML = groupObj.groupName;
                }
			}
		});

    };
    var handleCancel = function() {
        this.cancel();
    };

    var handleSuccess = function(o) {
    };
    var handleFailure = function(o) {
        alert("Submission failed: " + o.status);
    };


    // Remove progressively enhanced content class, just before creating the module
    YAHOO.util.Dom.removeClass("dialog1", "yui-pe-content");

    // Instantiate the Dialog
    WebGUI.Form.GroupManager.dialog = new YAHOO.widget.Dialog("dialog1", 
                            { width : "40em",
                              fixedcenter : true,
                              visible : false, 
                              //constraintoviewport : true,
                              buttons : [ { text:WebGUI.Form.GroupManager.i18n.get('WebGUI', 'submit'), handler:handleSubmit, isDefault:true },
                               	  { text:WebGUI.Form.GroupManager.i18n.get('WebGUI', 'Cancel'), handler:handleCancel } ]
                            });

    // Wire up the success and failure handlers
    WebGUI.Form.GroupManager.dialog.callback = { success: handleSuccess,
                             failure: handleFailure };

    // Render the Dialog
    WebGUI.Form.GroupManager.dialog.render();

};

WebGUI.Form.GroupManager.show_dialog = function(formName, isNew) {	
	var e = document.getElementById(formName + "_formId");
	groupId = e.options[e.selectedIndex].value;
    WebGUI.Form.GroupManager.original_form  = formName + "_formId";

    //Clear out all stored data.
    WebGUI.Form.GroupManager.users_added    = new Array();
    WebGUI.Form.GroupManager.users_deleted  = new Array();
    WebGUI.Form.GroupManager.groups_added   = new Array();
    WebGUI.Form.GroupManager.groups_deleted = new Array();
    WebGUI.Form.GroupManager.last_userId    = '';
    WebGUI.Form.GroupManager.last_groupId   = '';

    var form_target = document.getElementById("gm_form_target");
    form_target.innerHTML = '';

	var groupsAdded = document.getElementById("list_of_groups");
	var usersAdded = document.getElementById("list_of_users");
	var groupTextbox = document.getElementById("group_lookup");
	var userTextbox = document.getElementById("user_lookup");

	groupsAdded.innerHTML = "";
	usersAdded.innerHTML = "";
	
	userTextbox.value  = WebGUI.Form.GroupManager.i18n.get('Form_Group','Add User...');
	groupTextbox.value = WebGUI.Form.GroupManager.i18n.get('Form_Group','Add Group...');

    //TODO: groupFilter and userFilter never change.  They don't depend on which group is being added or
    //edited.  Move them into init to prevent memory leaks.
	//GROUPS AUTOCOMPLETE
	var groupFilter = { }; 

	groupFilter.dataSource = new YAHOO.util.XHRDataSource( '?op=formHelper;class=Group;sub=searchGroups;');
	groupFilter.dataSource.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;
	groupFilter.dataSource.responseSchema = {
		resultsList : "results",
		fields : [ 'groupName', 'groupId' ]
	};

    // Function to create an autocomplete field
    var createGroupAutocomplete = function ( groupFilter ) {
        groupFilter.autocomplete = new YAHOO.widget.AutoComplete("group_lookup", "groupResultsContainer", groupFilter.dataSource );
        groupFilter.autocomplete.queryQuestionMark = false;
        groupFilter.autocomplete.animVert = true;
        groupFilter.autocomplete.animSpeed = 0.1;
        groupFilter.autocomplete.minQueryLength = 1;
        groupFilter.autocomplete.queryDelay = 0.2;
        groupFilter.autocomplete.typeAhead = true;
        groupFilter.autocomplete.resultTypeList = false;
        groupFilter.autocomplete.applyLocalFilter = true;
        var getGroupId = function (sType, args) {
            var oData = args[2];
            WebGUI.Form.GroupManager.last_groupId = oData.groupId;
        }
        groupFilter.autocomplete.itemSelectEvent.subscribe(getGroupId);
        //This will override any of the functions that work with the default filterResults method
        groupFilter.autocomplete.filterResults = function ( sQuery , oFullResponse , oParsedResponse , oCallback ) {
            var allResults = oParsedResponse.results;
            var uniqueResults = [];
            for(var i=0, len=allResults.length; i<len; i++) {
                var oResult = allResults[i];
                var foundGroup = false;
                for(var j=0, len2=WebGUI.Form.GroupManager.groups_added.length; j<len2; j++) {
                    if(oResult.groupId === WebGUI.Form.GroupManager.groups_added[j]) {
                        foundGroup = true;
                    }
                }
                if (! foundGroup) {
                    uniqueResults.push(oResult);
                }
            }
            oParsedResponse.results = uniqueResults;
            return oParsedResponse;
        };
    };

	createGroupAutocomplete( groupFilter );

	groupFilter.autocomplete.formatResult = function ( result, query, match ) {
		return '<div class="autocomplete_value">' + result.groupName + "</div>";
	};

    //TODO: groupFilter and userFilter never change.  They don't depend on which group is being added or
    //edited.  Move them into init to prevent memory leaks.
	//USERS AUTOCOMPLETE
	var userFilter = { }; 

	userFilter.dataSource = new YAHOO.util.XHRDataSource( '?op=formHelper;class=User;sub=searchUsers;');
	userFilter.dataSource.responseType = YAHOO.util.XHRDataSource.TYPE_JSON;
	userFilter.dataSource.responseSchema = {
		resultsList : "results",
		fields : [ 'username', 'userId' ]
	};

    // Function to create an autocomplete field
    var createUserAutocomplete = function ( userFilter ) {
        userFilter.autocomplete = new YAHOO.widget.AutoComplete("user_lookup", "userResultsContainer", userFilter.dataSource );
        userFilter.autocomplete.queryQuestionMark = false;
        userFilter.autocomplete.animVert = true;
        userFilter.autocomplete.animSpeed = 0.1;
        userFilter.autocomplete.minQueryLength = 1;
        userFilter.autocomplete.queryDelay = 0.2;
        userFilter.autocomplete.typeAhead = true;
        userFilter.autocomplete.resultTypeList = false;
        userFilter.autocomplete.applyLocalFilter = true;
        var getUserId = function (sType, args) {
            var oData = args[2];
            WebGUI.Form.GroupManager.last_userId = oData.userId;
        }
        userFilter.autocomplete.itemSelectEvent.subscribe(getUserId);
        //This will override any of the functions that work with the default filterResults method
        userFilter.autocomplete.filterResults = function ( sQuery , oFullResponse , oParsedResponse , oCallback ) {
            var allResults = oParsedResponse.results;
            var uniqueResults = [];
            for(var i=0, len=allResults.length; i<len; i++) {
                var oResult = allResults[i];
                var foundUser = false;
                for(var j=0, len2=WebGUI.Form.GroupManager.users_added.length; j<len2; j++) {
                    if(oResult.userId === WebGUI.Form.GroupManager.users_added[j]) {
                        foundUser = true;
                    }
                }
                if (! foundUser) {
                    uniqueResults.push(oResult);
                }
            }
            oParsedResponse.results = uniqueResults;
            return oParsedResponse;
        };
    };

	createUserAutocomplete( userFilter );

	userFilter.autocomplete.formatResult = function ( result, query, match ) {
		return '<div class="autocomplete_value">' + result.username + '</div>';

		var user_lookup = document.getElementById ("user_lookup");
		user_lookup.setAttribute("name", result.userId);
	};

    if (isNew != "new") {
        var requestUrl = "?op=formHelper;class=Group;sub=groupMembers;groupId=" + groupId;
        var callback    = {
            failure : function ( o ) {
                // TODO: YUI logger for this
            },
            success : function ( o ) {
                var responseObj = YAHOO.lang.JSON.parse( o.responseText );
                //Insert groupname into the group field
                WebGUI.Form.GroupManager.dialog.form.groupName.value = responseObj[ 'groupName' ];
				
					var responseObj = YAHOO.lang.JSON.parse( o.responseText );
					var groups = responseObj.groups;
					var users = responseObj.users;
					
					for (var i = 0; i < groups.length; i++){
						var groupId = responseObj.groups[i].groupId;
						var groupsAdded = document.getElementById("list_of_groups");
						var groupsAddedRow = document.getElementById("groupsAdded_row");
						groupsAddedRow.style.cssText= "min-height: 27px !important; height: auto !important; display: block !important;";
						
						var newGroup = document.createElement('li');
						newGroup.setAttribute('id', 'gm_groupId_'+groupId)
						newGroup.innerHTML = '<a href=\'#\' onClick=\'WebGUI.Form.GroupManager.removeGroups("'+groupId+'")\' class=\'removeLink\'><img src=\'/extras/yui-webgui/build/form/assets/remove.png\' border=\'0\' style=\'width: 16px; height 16px; \' /></a>' + responseObj.groups[i].groupName;
						groupsAdded.appendChild(newGroup);
					}
					
					for (var i = 0; i < users.length; i++){
						var userId = responseObj.users[i].userId;
						var usersAdded  = document.getElementById("list_of_users");
						var usersAddedRow = document.getElementById("usersAdded_row");
						usersAddedRow.style.cssText= "min-height: 27px !important; height: auto !important; display: block !important;";
						
						var newUser = document.createElement('li');
						newUser.setAttribute('id', 'gm_userId_'+userId)
						newUser.innerHTML = '<a href=\'#\' onClick=\'WebGUI.Form.GroupManager.removeUsers("'+userId+'")\' class=\'removeLink\'><img src=\'/extras/yui-webgui/build/form/assets/remove.png\' border=\'0\' style=\'width: 16px; height 16px; \' /></a>' + responseObj.users[i].username;
						usersAdded.appendChild(newUser);
					}
					

            }
        };

		var groupIdHidden = document.getElementById("groupManager_groupId");
		groupIdHidden.setAttribute("value", groupId);

        YAHOO.util.Connect.asyncRequest( "POST", requestUrl, callback );
    } 
    else {
        WebGUI.Form.GroupManager.dialog.form.groupName.value = '';
		var groupIdHidden = document.getElementById("groupManager_groupId");
		groupIdHidden.setAttribute("value", "new");
    }
    WebGUI.Form.GroupManager.dialog.show();

};


//ADD GROUPS
WebGUI.Form.GroupManager.addGroups = function() {
	var groupTextbox = document.getElementById("group_lookup");
	var groupsAdded = document.getElementById("list_of_groups");
	var groupsAddedRow = document.getElementById("groupsAdded_row");

	if (groupTextbox.value !== "" && groupTextbox.value !== WebGUI.Form.GroupManager.i18n.get('Form_Group','Add Group...') && WebGUI.Form.GroupManager.last_groupId !== '') {
        var last_groupId = WebGUI.Form.GroupManager.last_groupId;
		WebGUI.Form.GroupManager.last_groupId = '';
		groupsAddedRow.style.cssText= "min-height: 27px !important; height: auto !important; display: block !important;";

        var newGroup = document.createElement('li');
        newGroup.setAttribute('id', 'gm_groupId_'+last_groupId)
        newGroup.innerHTML = '<a href=\'#\' onClick=\'WebGUI.Form.GroupManager.removeGroups("'+last_groupId+'")\' class=\'removeLink\'><img src=\'/extras/yui-webgui/build/form/assets/remove.png\' border=\'0\' style=\'width: 16px; height 16px; \' /></a>' +groupTextbox.value;
        groupsAdded.appendChild(newGroup);
		groupTextbox.value = WebGUI.Form.GroupManager.i18n.get('Form_Group','Add Group...');

        var groupDeleted = false;
		for(var i=0; i < WebGUI.Form.GroupManager.groups_deleted.length; i++) {
            if(WebGUI.Form.GroupManager.groups_deleted[i] == last_groupId) {
                WebGUI.Form.GroupManager.groups_deleted.splice(i,1);				
                groupDeleted = true;
            }
		}
		
        if (! groupDeleted) {
            WebGUI.Form.GroupManager.groups_added.push(last_groupId);
        }
	}
}

//REMOVE GROUPS
WebGUI.Form.GroupManager.removeGroups = function(groupId) {
	var groupsAdded = document.getElementById("list_of_groups");

    var group = document.getElementById('gm_groupId_'+groupId);
    groupsAdded.removeChild(group);

    var groupAdded = false;
	for(var i = WebGUI.Form.GroupManager.groups_added.length-1; i >= 0; i--){ 
		if(WebGUI.Form.GroupManager.groups_added[i] == groupId) {
			WebGUI.Form.GroupManager.groups_added.splice(i,1);				
            groupAdded = true;
		}
	}
    if (! groupAdded) {
        WebGUI.Form.GroupManager.groups_deleted.push(groupId);
    }

	if (groupsAdded.innerHTML == "") {
		groupsAdded.setAttribute("style", "display: none !important;");
	}
}

//ADD USERS
WebGUI.Form.GroupManager.addUsers = function() {
	var userTextbox = document.getElementById("user_lookup");
	var usersAdded  = document.getElementById("list_of_users");
	var userssAddedRow = document.getElementById("usersAdded_row");

	if (userTextbox.value !== "" && userTextbox.value !== WebGUI.Form.GroupManager.i18n.get('Form_Group','Add User...') && WebGUI.Form.GroupManager.last_userId !== '') {
        var last_userId = WebGUI.Form.GroupManager.last_userId;
		WebGUI.Form.GroupManager.last_userId = '';
		userssAddedRow.style.cssText= "min-height: 27px !important; height: auto !important; display: block !important;"

        var newUser = document.createElement('li');
        newUser.setAttribute('id', 'gm_userId_'+last_userId)
        newUser.innerHTML = '<a href=\'#\' onClick=\'WebGUI.Form.GroupManager.removeUsers("'+last_userId+'")\' class=\'removeLink\'><img src=\'/extras/yui-webgui/build/form/assets/remove.png\' border=\'0\' style=\'width: 16px; height 16px; \' /></a>' +userTextbox.value;
        usersAdded.appendChild(newUser);
		userTextbox.value = WebGUI.Form.GroupManager.i18n.get('Form_Group','Add User...');
        var userDeleted = false;
        for(var i = WebGUI.Form.GroupManager.users_deleted.length-1; i >= 0; i--){ 
            if(WebGUI.Form.GroupManager.users_deleted[i] == last_userId) {
                WebGUI.Form.GroupManager.users_deleted.splice(i,1);				
                userDeleted = true;
            }
        }
        if (! userDeleted) {
            WebGUI.Form.GroupManager.users_added.push(last_userId);
        }
	}

}

//REMOVE USERS
WebGUI.Form.GroupManager.removeUsers = function(userId) {
	var usersAdded = document.getElementById("list_of_users");

    var user = document.getElementById('gm_userId_'+userId);
    usersAdded.removeChild(user);

    //Keep the lists up to date.  If this user was added, then take them out of the
    //added list, and do not add them to the deleted list since the group doesn't know
    //about it yet.
    var userAdded = false;
	for(var i = WebGUI.Form.GroupManager.users_added.length-1; i >= 0; i--){ 
		if(WebGUI.Form.GroupManager.users_added[i] == userId) {
			WebGUI.Form.GroupManager.users_added.splice(i,1);				
            userAdded = true;
		}
	}
    if (! userAdded) {
        WebGUI.Form.GroupManager.users_deleted.push(userId);
    }

	if (usersAdded.innerHTML == "") {
		usersAdded.setAttribute("style", "display: none !important;");
	}
}

//CREATE NEW GROUP
WebGUI.Form.GroupManager.createNewGroup = function() {
	WebGUI.Form.GroupManager.dialog.form.groupName.value = '';
	var groupIdHidden = document.getElementById("groupManager_groupId");
	groupIdHidden.setAttribute("value", "new");
	
    WebGUI.Form.GroupManager.users_added    = new Array();
    WebGUI.Form.GroupManager.users_deleted  = new Array();
    WebGUI.Form.GroupManager.groups_added   = new Array();
    WebGUI.Form.GroupManager.groups_deleted = new Array();
    WebGUI.Form.GroupManager.last_groupId   = '';
    WebGUI.Form.GroupManager.last_userId    = '';
    
    var form_target = document.getElementById("gm_form_target");
    form_target.innerHTML = '';

	var groupsAdded = document.getElementById("list_of_groups");
	var usersAdded = document.getElementById("list_of_users");
	var groupTextbox = document.getElementById("group_lookup");
	var userTextbox = document.getElementById("user_lookup");

	groupsAdded.innerHTML = "";
	usersAdded.innerHTML = "";
	
	userTextbox.value  = WebGUI.Form.GroupManager.i18n.get('Form_Group','Add User...');
	groupTextbox.value = WebGUI.Form.GroupManager.i18n.get('Form_Group','Add Group...');
	
	var groupName = document.getElementById("groupName");
	groupName.focus();
	
	var groupsAddedRow = document.getElementById("groupsAdded_row");
	groupsAddedRow.setAttribute("style", "display: none; visibility: hidden;");
	
	var usersAddedRow = document.getElementById("usersAdded_row");
	usersAddedRow.setAttribute("style", "display: none; visibility: hidden;");

	var createNewGroupRow = document.getElementById('createNewGroupRow');
	createNewGroupRow.setAttribute("style", "display: none; visibility: hidden;");
}


WebGUI.Form.GroupManager.showAutocomplete = function(showWhat) {
	var textInput = document.getElementById(showWhat);
	textInput.value = "";
	
	var groupsDiv = document.getElementById("groupResultsContainer");
	var usersDiv = document.getElementById("userResultsContainer");

	switch (showWhat) {
		case "group_lookup":
			groupsDiv.setAttribute("style", "display: block;");
			usersDiv.setAttribute("style", "display: none;");
		break;
		case "user_lookup":
			usersDiv.setAttribute("style", "display: block;");
			groupsDiv.setAttribute("style", "display: none;");
		break;
	}
}
