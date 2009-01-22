
/*global Survey, YAHOO */
if (typeof Survey === "undefined") {
    var Survey = {};
}

(function(){

    var callMade = 0;
    var request = function(sUrl, callback, postData, form, hasFile){
        if (form) {
            if (hasFile) {
                YAHOO.util.Connect.setForm(form, true);
                //YAHOO.log('set file was true');
            }
            else {
                //YAHOO.log('set file was false');
                YAHOO.util.Connect.setForm(form);
            }
            //YAHOO.log('setForm was true');
        }
        if (callMade) {
            alert("Waiting on previous request");
        }
        else {
            callMade = 1;
            YAHOO.log(sUrl);
            YAHOO.util.Connect.asyncRequest('POST', sUrl, callback, postData);
        }
    };
    
    
    Survey.Comm = {
        callback: {
            upload: function(o){
                callMade = 0;
                Survey.Comm.callServer('', 'loadQuestions');
            },
            success: function(o){
                window.scrollTo(0, 0);
                callMade = 0;
                var response = '';
                response = YAHOO.lang.JSON.parse(o.responseText);
                if (response.type === 'displayquestions') {
                    Survey.Form.displayQuestions(response);
                }
                else 
                    if (response.type === 'forward') {
                        //YAHOO.log("going to "+response.url);
                        location.href = response.url;
                    }
                    else {
                        alert("bad response");
                    }
            },
            failure: function(o){
                callMade = 0;
                if (o.status === -1) {
                    alert("Last request timed out, please try again");
                }
                else {
                    alert("Last request failed " + o.statusText);
                }
            }
        },
        callServer: function(data, functionName, form, hasFile){
            var postData;
            if (!form) {
                postData = "data=" + YAHOO.lang.JSON.stringify(data, data);
            }
            //var sUrl = this.url + "?func="+functionName;
            var sUrl = "?func=" + functionName;
            request(sUrl, this.callback, postData, form, hasFile);
        }
    };
})();
