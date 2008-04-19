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
        focus = d.focus;//What is the current highlighted item.
        var lastType = '';//What was the last type created.
        var lastId = {'section': '', 'question': '', 'answer': ''};//what is the last id of each type placed, so we know a child's parent.
        var buttons = {'question':0,'answer':0,'section':0}; //array of bools on if buttons put down
        document.getElementById('sections').innerHTML='';
        var scount = 1;
        var qcount = 1;
        var acount = 1;
        for(var x in d.data){
            //Now check to see if this is where an add button goes.
            //Add addAnswer when we go from answer to question or section or end
            //Add addQuestion when we go from question to section or end

            if(lastType == 'answer' && d.data[x].type == 'question'){
                this.addAnswerButton(lastId['section'],lastId['question']);
                buttons['answer'] = 1;
                acount = 1;
            } 
            else if(lastType == 'answer' && d.data[x].type == 'section'){
                this.addAnswerButton(lastId['section'],lastId['question']);
                buttons['answer'] = 1;
                this.addQuestionButton(lastId['section']);
                buttons['question'] = 1;
                acount = 1;
                qcount = 1;
            } 
            else if(lastType == 'question' && d.data[x].type == 'section'){
                if(!buttons['answer']){
                    this.addAnswerButton(lastId['section'],lastId['question']);
                    buttons['answer']=1;
                }
                this.addQuestionButton(lastId['section']);
                buttons['question'] = 1;
                acount = 1;
                qcount = 1;
            }
            else if(d.data[x].type == 'section' && lastType == 'section' && lastId['section'] == focus){
                this.addQuestionButton(lastId['section']);
                buttons['question'] = 1;
                acount = 1;
                qcount = 1;
            }
            else if(d.data[x].type != 'answer' && lastType == 'question' && lastId['section'] + '||||'+ lastId['question'] == focus){
                this.addAnswerButton(lastId['section'],lastId['question']);
                buttons['answer']=1;
                acount = 1;
                qcount = 1;
            }

            var node = document.createElement('li');
            if(focus != undefined && focus.indexOf(d.data[x].id) > -1){
                node.className = "s"+d.data[x].type;
            }else{
                node.className = d.data[x].type;
            }
            if(d.data[x].text == undefined){//== 'null'){
                d.data[x].text = '<empty>';
            }
            var id = '';
            var delim = "||||";
            var pre;
            if(d.data[x].type == 'section'){
                pre = 'S'+ scount++ +':';
                id = d.data[x].id;
            }
            else if(d.data[x].type == 'question'){
                pre = 'Q'+ qcount++ +':';
                id = lastId['section'] + delim + d.data[x].id;
            }
            else if(d.data[x].type == 'answer'){
                if(d.data[x].recordedAnswers != null){
                }
                pre = 'A'+ acount++ +':';
                id = lastId['section'] + delim + lastId['question'] + delim + d.data[x].id;
            }
            node.innerHTML = pre + ' ' + d.data[x].text;
            node.id = id;
            new Survey.DDList(node.id,"sections");
            document.getElementById('sections').appendChild(node);
            YAHOO.util.Event.addListener(id, "click", this.clicked); 

            lastType = d.data[x].type;
            lastId[d.data[x].type] = d.data[x].id;
        }
        if(lastType == 'answer' && ! buttons['answer']){
            this.addAnswerButton(lastId['section'],lastId['question']);
            this.addQuestionButton(lastId['section']);
        }
        if(lastType == 'question' && ! buttons['question']){
            this.addAnswerButton(lastId['section'],lastId['question']);
        }
        if(lastType == 'question' || lastType == 'section' && ! buttons['question']){
            this.addQuestionButton(lastId['section']);
        } 

        this.addSectionButton(); 
        
        this.loadObjectEdit(d.edit);
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


    this.addSectionButton = function(){
        var node = document.createElement('li');
        node.innerHTML = "<span id='newSection'></span>";
        document.getElementById('sections').appendChild(node);
        var button = new YAHOO.widget.Button({ label:"Add Section", id:"addsection", container:"newSection" });
        button.on("click", this.addSection); 
    }


    this.addQuestionButton = function(sid){
        var node = document.createElement('li');
        node.className = 'newQuestion';
        node.innerHTML = "<span id='newQuestion'></span>";
        document.getElementById('sections').appendChild(node);
        var button = new YAHOO.widget.Button({ label:"Add Question", id:'addquestion', container:"newQuestion"});//, onclick:{fn:this.addQuestion} });
        button.on("click", this.addQuestion,sid); 
    }


    this.addAnswerButton = function(sid,qid){
        var node = document.createElement('li');
        node.id = 'newAnswer';
        node.className = 'newAnswer';
        document.getElementById('sections').appendChild(node);
        var button = new YAHOO.widget.Button({ label:"Add Answer", id:'addanswer', container:"newAnswer" });
        button.on("click", this.addAnswer,[sid,qid]); 
    }


    this.loadObjectEdit = function(edit){
        if(edit){
            if(edit.type == "loadSection"){
                Survey.SectionTemplate.loadSection(edit.params);
            }
            else if(edit.type == "loadQuestion"){
                Survey.QuestionTemplate.loadQuestion(edit.params);
            }
            else if(edit.type == "loadAnswer"){
                Survey.AnswerTemplate.loadAnswer(edit.params);
            }
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
