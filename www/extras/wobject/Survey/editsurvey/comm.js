if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.Comm = new function(){
    var callMade = 0;

    var request = function(sUrl,callback,postData){
        if(callMade == 1){
            alert("Waiting on previous call");
        }else{
            callMade = 1;
            YAHOO.util.Connect.asyncRequest('POST', sUrl, callback, postData);
        }
    }
    this.callback = {
        success:function(o){
            callMade = 0;
            Survey.Data.loadData(YAHOO.lang.JSON.parse(o.responseText));
        },
        failure: function(o){
            callMade = 0;
            alert("Last request failed");
            Survey.Data.loadLast();
        },
        timeout: 5000
    };
    this.loadSurvey = function(p){
        var postData = "data="+p;
        var sUrl = "?func=loadSurvey";
        request(sUrl,this.callback,postData);
    }
    this.dragDrop = function(target,before){
        var p = {}; 
        p['target'] = target;
        p['before'] = before;
        var postData = "data="+YAHOO.lang.JSON.stringify(p);
        var sUrl = "?func=dragDrop";
        request(sUrl,this.callback,postData);
    }
    this.submitEdit = function(p){
        var postData = "data="+YAHOO.lang.JSON.stringify(p);
        var sUrl = "?func=submitEdit";
        request(sUrl,this.callback,postData);
    }
    this.newSection = function(){
        var sUrl = "?func=newSection";
        request(sUrl,this.callback);
    }
    this.newQuestion = function(sid){
        var postData = "data="+sid;
        var sUrl = "?func=newQuestion";
        request(sUrl,this.callback,postData);
    }
    this.newAnswer = function(sid,qid){
        var postData = "data="+YAHOO.lang.JSON.stringify([sid,qid]);
        var sUrl = "?func=newAnswer";
        request(sUrl,this.callback,postData);
    }
    this.deleteAnswer = function(id){
        var postData = "data="+id;
        var sUrl = "?func=deleteAnswer";
        request(sUrl,this.callback,postData);
    }
    this.deleteQuestion = function(id){
        var postData = "data="+id;
        var sUrl = "?func=deleteQuestion";
        request(sUrl,this.callback,postData);
    }
    this.deleteSection = function(id){
        var postData = "data="+id;
        var sUrl = "?func=deleteSection";
        request(sUrl,this.callback,postData);
    }
}();
