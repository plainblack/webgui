if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.Data = new function(){
    var lastDataSet = {};
    var focus;


    this.dragDrop = function(did){
        var type;

        if(did.className.match("section")){type = 'section';}
        else if(did.className.match("question")){type = 'question';}
        else{ type = 'answer';}

        var first = {id:did.id,type:type};
        var before = document.getElementById(did.id).previousSibling;

        while(1){
            if( before == undefined || (before.id != undefined && before.id != '') ){
                break;
            }
            var before = before.previousSibling;
        }

        var data = {id:'',type:''};

        if(before != undefined && before.id != undefined && before.id != ''){
            if(before.className.match("section")){type = 'section';}
            else if(before.className.match("question")){type = 'question';}
            else{ type = 'answer';}
            data = {id:before.id,type:type};
        }

        Survey.Comm.dragDrop(first,data);
    }



    this.clicked = function(){
        Survey.Comm.loadSurvey(this.id);
    }



    this.loadData = function(d){
        focus = d.address;//What is the current highlighted item.
        document.getElementById('sections').innerHTML=d.ddhtml;
        
        //add event handlers for if a tag is clicked
        for(var x in d.ids){
            YAHOO.util.Event.addListener(d.ids[x], "click", this.clicked); 
        }
        
        //add the add object buttons
        if(d.buttons['section']){
            var button = new YAHOO.widget.Button({ label:"Add Section", id:"addsection", container:"newSection" });
            button.on("click", this.addSection); 
        }
        if(d.buttons['question']){
            var button = new YAHOO.widget.Button({ label:"Add Question", id:"addquestion", container:"newQuestion" });
            button.on("click", this.addQuestion,d.buttons['question']); 
        }
        if(d.buttons['answer']){
            var button = new YAHOO.widget.Button({ label:"Add Answer", id:"addanswer", container:"newAnswer" });
            button.on("click", this.addQuestion,d.buttons['answer']); 
        }

        this.loadObjectEdit(d.edithtml,d.type);
        lastDataSet = d;
    }

    this.addSection = function(){
        Survey.Comm.newSection();
    }


    this.addQuestion = function(e,sid){
        Survey.Comm.newQuestion(sid);
    }

    this.addAnswer = function(e,ids){
        Survey.Comm.newAnswer(ids[0],ids[1]);
    }

    this.loadObjectEdit = function(edit,type){
        if(edit){
            Survey.ObjectTemplate.loadObject(edit,type);
        }
    }


    this.loadLast = function(){
        this.loadData(lastDataSet);
    }
}();


//----------------------------------------------------------------
//
//      Initialize survey 
//
//----------------------------------------------------------------
Survey.OnLoad = function() {
    var e = YAHOO.util.Event;
    return {
        init: function() { 
            e.onDOMReady(this.initHandler);
        },
        initHandler: function(){
            new YAHOO.util.DDTarget("sections","sections");
            Survey.Comm.loadSurvey();
        },
    }
}();

Survey.OnLoad.init();
