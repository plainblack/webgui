if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.Comm= new function(){


    this.url = '';
    this.setUrl = function(u){this.url = u;}
    var callMade = 0; 
    var request = function(sUrl,callback,postData,form, hasFile){
        if(form != undefined){
            if(hasFile){
                YAHOO.util.Connect.setForm(form,true);
                //console.log('set file was true');
            }else{
                //console.log('set file was false');
                YAHOO.util.Connect.setForm(form);
            }
            //console.log('setForm was true');
        }
        if(callMade == 1){
            alert("Waiting on previous request");
        }else{
            callMade = 1;
            YAHOO.util.Connect.asyncRequest('POST', sUrl, callback, postData);
        }
    }


    this.callback = {
        window.scrollTo(0, 0); 
        upload:function(o){
            callMade = 0;
            Survey.Comm.callServer('','loadQuestions');
        },
        success:function(o){
            callMade = 0;
            var response = '';
            response = YAHOO.lang.JSON.parse(o.responseText);
            if(response.type == 'displayquestions'){
                Survey.Form.displayQuestions(response);
            }else if(response.type == 'forward'){
//console.log("going to "+response.url);
                location.href=response.url;
            }else{
                alert("bad response");
            }
        },
        failure: function(o){
            callMade = 0;
            if(o.status == -1){
                alert("Last request timed out, please try again");
            }else{
                alert("Last request failed "+o.statusText);
            }
        },
        timeout: 15000
    };

    this.callServer = function(data,functionName,form,hasFile){
        var postData;
        if(form == undefined){
            postData = "data="+YAHOO.lang.JSON.stringify(data,data);
            //console.log(postData);
        }
        var sUrl = this.url + "?func="+functionName;
        request(sUrl,this.callback,postData,form,hasFile);
    }

     

}();
