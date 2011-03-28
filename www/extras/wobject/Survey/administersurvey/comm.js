/*global Survey, YAHOO, alert, window */
if (typeof Survey === "undefined") {
    var Survey = {};
}

(function(){

    var callMade = 0;
    var request = function(sQuery, callback, postData, form, hasFile){
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
            alert("Your previous action is still being processed. Please try again.");
        }
        else {
            callMade = 1;
            YAHOO.log(sQuery);
            var url = encodeURI(location.pathname) + sQuery;
            YAHOO.util.Connect.asyncRequest('POST', url, callback, postData);
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
                try { 
                    response = YAHOO.lang.JSON.parse(o.responseText);
                }
                catch (err) { 
                    YAHOO.log(err);
                    alert("Oops.. A problem was encountered. Please try again.");
                    return;
                }
                if (response.type === 'displayquestions') {
                    Survey.Form.displayQuestions(response);
                }
                else{ 
                    if (response.type === 'forward') {
                        var url;
                        if(response.url.match(/http/)){
                            url = response.url;
                        }else{
                            url = location.protocol+"//"+location.host+"/"+response.url;
                        }
                        window.location = url;
                    }
                    else if(response.type === 'summary'){
                        Survey.Summary.showSummary(response.summary,response.html);    
                    }
                    else {
                        alert("bad response");
                    }
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
        submitSummary: function(data,functionName){
            var sQuery = "?func=loadQuestions;shownSummary=1";
            var revision = Survey.Comm.getRevision();
            if (revision) {
                sQuery += ";revision=" + revision;
            }
            
            request(sQuery, this.callback, null, null, null);
        },
        
        getRevision: function() {
            // Use the appropriate Survey response revision
            var revision = parseInt(document.getElementById('surveyResponseRevision').value, 10);
            if (!revision) {
                YAHOO.log("Revision not found, bad template?");
            }
            return revision;
            
        },
        
        callServer: function(data, functionName, form, hasFile){
            var postData;
            if (!form) {
                postData = "data=" + YAHOO.lang.JSON.stringify(data, data);
            }
            
            //var sQuery = this.url + "?func="+functionName;
            var sQuery = "?func=" + functionName;
            
            var revision = Survey.Comm.getRevision();
            if (revision) {
                sQuery += ";revision=" + revision;
            }
            
            request(sQuery, this.callback, postData, form, hasFile);
        }
    };
})();
