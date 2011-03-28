/*global Survey, YAHOO, alert */
if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.Comm = new function(){
    var callMade = 0;

    var request = function(sQuery,callback,postData){
        YAHOO.util.Dom.setStyle('mask-all','display','block');
        if(callMade == 1){
            alert("Waiting on previous request");
        }else{
            callMade = 1;
            var url = encodeURI(location.pathname) + sQuery;
            YAHOO.util.Connect.asyncRequest('POST', url, callback, postData);
        }
    };
    this.callback = {
        success:function(o){
            YAHOO.util.Dom.setStyle('mask-all','display','none');
            callMade = 0;
            Survey.Data.loadData(YAHOO.lang.JSON.parse(o.responseText));
        },
        failure: function(o){
            YAHOO.util.Dom.setStyle('mask-all','display','none');
            callMade = 0;
            alert("Last request failed");
            Survey.Data.loadLast();
        },
        timeout: 5000
    };
    this.loadSurvey = function(p){
        var postData = "data="+p;
        var sQuery = "?func=loadSurvey";
        request(sQuery,this.callback,postData);
    };
    this.dragDrop = function(target,before){
        var p = {}; 
        p.target = target;
        p.before = before;
        var postData = "data="+YAHOO.lang.JSON.stringify(p);
        var sQuery = "?func=dragDrop";
        request(sQuery,this.callback,postData);
    };
    this.submitEdit = function(p){
        var postData = "data="+YAHOO.lang.JSON.stringify(p);
        var sQuery = "?func=submitEdit";
        request(sQuery,this.callback,postData);
    };
    this.newSection = function(){
        var sQuery = "?func=newObject";
        request(sQuery,this.callback);
    };
    this.newQuestion = function(id){
        var postData = "data="+id;
        var sQuery = "?func=newObject";
        request(sQuery,this.callback,postData);
    };
    this.newAnswer = function(id){
        var postData = "data="+id;
        var sQuery = "?func=newObject";
        request(sQuery,this.callback,postData);
    };
    this.deleteAnswer = function(id){
        var postData = "data="+id;
        var sQuery = "?func=deleteAnswer";
        request(sQuery,this.callback,postData);
    };
    this.deleteQuestion = function(id){
        var postData = "data="+id;
        var sQuery = "?func=deleteQuestion";
        request(sQuery,this.callback,postData);
    };
    this.deleteSection = function(id){
        var postData = "data="+id;
        var sQuery = "?func=deleteSection";
        request(sQuery,this.callback,postData);
    };
}();
