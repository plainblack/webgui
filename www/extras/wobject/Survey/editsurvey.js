if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.Data = new function(){
    var lastDataSet = {};
    var focus;
    var lastId = -1;

    this.dragDrop = function(did){
        var type;
YAHOO.log('In drag drop');
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
YAHOO.log(first.id+' '+data.id);
        Survey.Comm.dragDrop(first,data);
    }



    this.clicked = function(){
        Survey.Comm.loadSurvey(this.id);
    }



    this.loadData = function(d){
        focus = d.address;//What is the current highlighted item.
        var showEdit = 1;
        if(lastId.toString() == d.address.toString()){
            showEdit = 0;
            lastId = -1;
        }else{
            lastId = d.address;
        }
        document.getElementById('sections').innerHTML=d.ddhtml;
        
        //add event handlers for if a tag is clicked
        for(var x in d.ids){
YAHOO.log('adding handler for '+ d.ids[x]);
            YAHOO.util.Event.addListener(d.ids[x], "click", this.clicked); 
            new Survey.DDList(d.ids[x],"sections");
        }
        
        //add the add object buttons
//        if(d.buttons['section']){
            document.getElementById('addSection').innerHTML = '';
            document.getElementById('addQuestion').innerHTML = '';
            document.getElementById('addAnswer').innerHTML = '';
            var button = new YAHOO.widget.Button({ label:"Add Section", id:"addsection", container:"addSection" });
            button.on("click", this.addSection); 
//        }
//        if(d.buttons['question']){
            var button = new YAHOO.widget.Button({ label:"Add Question", id:"addquestion", container:"addQuestion" });
            button.on("click", this.addQuestion,d.buttons['question']); 
//        }
        if(d.buttons['answer']){
            var button = new YAHOO.widget.Button({ label:"Add Answer", id:"addanswer", container:"addAnswer" });
            button.on("click", this.addAnswer,d.buttons['answer']); 
        }

        if(showEdit == 1){
            this.loadObjectEdit(d.edithtml,d.type);
        }else{
            document.getElementById('edit').innerHTML = "";
        }
        lastDataSet = d;
    }

    this.addSection = function(){
        Survey.Comm.newSection();
    }


    this.addQuestion = function(e,id){
        Survey.Comm.newQuestion(id);
    }

    this.addAnswer = function(e,id){
        Survey.Comm.newAnswer(id);
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
