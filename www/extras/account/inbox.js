YAHOO.util.Event.onDOMReady(function() {
    if(YAHOO.util.Dom.inDocument("friends")) {

        var isUserCheckBox = function ( element ) {
            if(element.name == "friend") return true;
            return false;
        }

        var removeUser = function (evt, obj) {
            YAHOO.util.Event.stopEvent(evt);
            var userId       = obj.userId;
            var checkBox     = YAHOO.util.Dom.get("friend_"+userId+"_id");
            checkBox.checked = false;
            updateUsers(evt,obj.dialog);
        }

        var updateUsers = function ( evt , dialog ) {
            YAHOO.util.Event.stopEvent(evt);
            var toElement  = YAHOO.util.Dom.get("messageTo");
            toElement.innerHTML = ""; // Clear the current stuff
            YAHOO.util.Dom.removeClass(toElement,"inbox_messageTo");
            
            var checkBoxes = YAHOO.util.Dom.getElementsBy(isUserCheckBox,"INPUT","contacts");       
            for (var i = 0; i < checkBoxes.length; i++) {
                if(checkBoxes[i].checked) {
                    var friendName = YAHOO.util.Dom.get("friend_"+checkBoxes[i].value+"_name").innerHTML;
                    var firstPart  = document.createTextNode(friendName + " ( ");
                    var link       = document.createElement("A");
                    link.setAttribute('href', '#');
                    link.innerHTML = removeText;
                    YAHOO.util.Event.addListener(link,"click",removeUser,{ userId: checkBoxes[i].value, dialog: dialog });
                    var lastPart   = document.createTextNode(" ); ");
                    toElement.appendChild(firstPart);
                    toElement.appendChild(link);
                    toElement.appendChild(lastPart);
                }
            }
            YAHOO.util.Dom.addClass(toElement,"inbox_messageTo");
            dialog.hide();        
        }

        var showUsers = function (evt, dialog) {
            YAHOO.util.Event.stopEvent(evt);
            dialog.show();
        }

        // Instantiate the Dialog
        var dialog1 = new YAHOO.widget.Dialog("friends", { 
            width : "340px",
            fixedcenter : true,
            visible : false,
            constraintoviewport : false
        });
    
        // Render the Dialog
        dialog1.render();

        YAHOO.util.Event.addListener("show_friends", "click", showUsers, dialog1);
        YAHOO.util.Event.addListener("cancel_top", "click", dialog1.hide, dialog1, true);
        YAHOO.util.Event.addListener("cancel_bottom", "click", dialog1.hide, dialog1, true);
        YAHOO.util.Event.addListener("update_top", "click", updateUsers, dialog1);
        YAHOO.util.Event.addListener("update_bottom", "click", updateUsers, dialog1);
    }
});