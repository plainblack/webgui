if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.Form = new function() {
   
    var multipleChoice = {'Multiple Choice':1,'Gender':1,'Yes/No':1,'True/False':1,'Ideology':1, 'Race':1,'Party':1,'Education':1
            ,'Scale':1,'Agree/Disagree':1,'Oppose/Support':1,'Importance':1,
            'Likelihood':1,'Certainty':1,'Satisfaction':1,'Confidence':1,'Effectiveness':1,'Concern':1,'Risk':1,'Threat':1,'Security':1};
    var text = {'Text':1, 'Email':1, 'Phone Number':1, 'Text Date':1, 'Currency':1};
    var slider = {'Slider':1, 'Dual Slider - Range':1, 'Multi Slider - Allocate':1};
    var dateType = {'Date':1,'Date Range':1};
    var fileUpload = {'File Upload':1};
    var hidden = {'Hidden':1};

    var hasFile;
    var verb = 0; 
    var lastSection = 'first';

    var toValidate;

    var sliderWidth = 500;

    var sliders;


    this.displayQuestions = function(params){
        
        toValidate = new Array();//clear array
        var qs = params.questions;
        var s = params.section;
        sliders = new Array();

        //What to show and where 
        document.getElementById('survey').innerHTML = params.html; 
//var te = document.createElement('span'); 
//te.innerHTML = "<input type=button id=testB name='Reload Page' value='Reload Page'>";
//document.getElementById('survey').appendChild(te);
//YAHOO.util.Event.addListener("testB", "click", function(){Survey.Comm.callServer('','loadQuestions');});   

        if(qs[0] != undefined){
            if(lastSection != s.Survey_sectionId || s.everyPageTitle > 0){
                document.getElementById('headertitle').style.display='block';
            }
            if(lastSection != s.Survey_sectionId || s.everyPageText > 0){
                document.getElementById('headertext').style.display = 'block';
            }

            if(lastSection != s.Survey_sectionId && s.questionsOnSectionPage != '1'){
                var span = document.createElement("div"); 
                span.innerHTML = "<input type=button id='showQuestionsButton' value='Continue'>";
                span.style.display = 'block';
            
                document.getElementById('header').appendChild(span);
                YAHOO.util.Event.addListener("showQuestionsButton", "click", 
                    function(){ 
                        document.getElementById('showQuestionsButton').style.display = 'none';
                        if(s.everyPageTitle == 0){
                            document.getElementById('headertitle').style.display = 'none';
                        }
                        if(s.everyPageText == 0){
                            document.getElementById('headertext').style.display = 'none';
                        }
                        document.getElementById('questions').style.display='inline';
                        Survey.Form.addWidgets(qs);             
                    });   
            }else{
                document.getElementById('questions').style.display='inline';
                Survey.Form.addWidgets(qs);             
            }
            lastSection = s.Survey_sectionId;
        }else{
            document.getElementById('headertitle').style.display='block';
            document.getElementById('headertext').style.display = 'block';
            document.getElementById('questions').style.display='inline';
            Survey.Form.addWidgets(qs);             
        }
    }
        //Display questions
    this.addWidgets = function(qs){ 
        hasFile = false;
        for(var i = 0; i < qs.length; i++){
            var q = qs[i];
            var verts = '';
            var verte = '';
            for(var x in q.answers){
                for(var y in q.answers[x]){
                    if(q.answers[x][y] == undefined){q.answers[x][y] = '';}
                }
            }

            //Check if this question should be validated
            if(q.required == 1){
               toValidate[q.Survey_questionId] = new Array();
               toValidate[q.Survey_questionId]['type'] = q.questionType;
               toValidate[q.Survey_questionId]['answers'] = new Array();
            } 
            

            if(multipleChoice[q.questionType]){
                var butts = new Array(); 
                verb = 0; 
                for(var x = 0; x < q.answers.length; x++){
                    var a = q.answers[x];
                    if(toValidate[a.Survey_questionId]){
                        toValidate[a.Survey_questionId]['answers'][a.Survey_answerId] = 1; 
                    }
                    var b = document.getElementById(a.Survey_answerId+'button');
                    /*
                        b = new YAHOO.widget.Button({ type: "checkbox", label: a.answerText, id: a.Survey_answerId+'button', name: a.Survey_answerId+'button',
                        value: a.Survey_answerId, 
                        container: a.Survey_answerId+"container", checked: false });
                    */
//                    b.on("click", this.buttonChanged,[b,a.Survey_questionId,q.maxAnswers,butts,qs.length,a.Survey_answerId]);
//                    YAHOO.util.Event.addListener(a.Survey_answerId+'button', "click", this.buttonChanged,[b,a.Survey_questionId,q.maxAnswers,butts,qs.length,a.Survey_answerId]);
                    if(a.verbatim == 1){
                        verb = 1;
                    }
                    YAHOO.util.Event.addListener(a.Survey_answerId+'button', "click", this.buttonChanged,[b,a.Survey_questionId,q.maxAnswers,butts,qs.length,a.Survey_answerId]);
                    b.hid = a.Survey_answerId;
                    butts.push(b);
                }
            }
            else if(dateType[q.questionType]){
                for(var x = 0; x < q.answers.length; x++){
                    var a = q.answers[x];
                    if(toValidate[a.Survey_questionId]){
                        toValidate[a.Survey_questionId]['answers'][a.Survey_answerId] = 1; 
                    }
                    var calid = a.Survey_answerId+'container';
                    var c = new YAHOO.widget.Calendar(calid,{title:'Choose a date:', close:true});
                    c.selectEvent.subscribe(this.selectCalendar,[c,a.Survey_answerId],true);
                    c.render();
                    c.hide();
                    var b = new YAHOO.widget.Button({  label:"Select Date",  id:"pushbutton"+a.Survey_answerId, container:a.Survey_answerId+'button' });
                    b.on("click", this.showCalendar,[c]);
                }
            }
            else if(slider[q.questionType]){
                //First run through and put up the span placeholders and find the max value for an answer, to know how big the allocation points will be.
                var max = 0;
                if(q.questionType == 'Dual Slider - Range'){
                    new this.dualSliders(q);
                }else{
                    for(var s in q.answers){
                        var a = q.answers[s];
                        YAHOO.util.Event.addListener(a.Survey_answerId, "blur", this.sliderTextSet);   
                        if(a.max - a.min > max){max = a.max - a.min;}
                    }
                }
                if(q.questionType == 'Multi Slider - Allocate'){
                    //sliderManagers[sliderManagers.length] = new this.sliderManager(q,max);
                    for(var x = 0; x < q.answers.length; x++){
                        var a = q.answers[x];
                        if(toValidate[a.Survey_questionId]){
                            toValidate[a.Survey_questionId]['total'] =  a.max; 
                            toValidate[a.Survey_questionId]['answers'][a.Survey_answerId] = 1; 
                        }
                    }
                    new this.sliderManager(q,max);
                }
                else if(q.questionType == 'Slider'){
                    new this.sliders(q); 
                }
            }

            else if(fileUpload[q.questionType]){
                hasFile = true;
            }

            else if(text[q.questionType]){
                var a = q.answers[x];
                if(toValidate[a.Survey_questionId]){
                    toValidate[a.Survey_questionId]['answers'][a.Survey_answerId] = 1; 
                }
            }
        }
        YAHOO.util.Event.addListener("submitbutton", "click", this.formsubmit);   
    }


    this.formsubmit = function(){
        var submit = 1;//boolean for if all was good or not
        for(var i in toValidate){
            var answered = 0;
            if(toValidate[i]['type'] == 'Multi Slider - Allocate'){
                var total = 0;
                for(var z in toValidate[i]['answers']){
                    total += Math.round(document.getElementById(z).value);
                }
console.log(total+" and "+ toValidate[i]['total']);
                if(total == toValidate[i]['total']){answered = 1;}
            }else{
                for(var z in toValidate[i]['answers']){
                    var v = document.getElementById(z).value;
                    if(v != '' && v != undefined){
                        answered = 1;
                        break;
                    }
                    else{
                        console.log(z+' was not answered');
                    }
                }
            }
            if(answered == 0){
                submit = 0;
                document.getElementById(i+'required').innerHTML = "<font color=red>*</font>";
            }else{
                document.getElementById(i+'required').innerHTML = "";
            }
        }
        if(submit == 1){
            Survey.Comm.callServer('','submitQuestions','surveyForm',hasFile);
        }
    }




    this.dualSliders = function(q){
        var total = sliderWidth; 
//        var sliders = new Array();
            var a1 = q.answers[0];
            var a2 = q.answers[1];
            var scale = sliderWidth/a1.max;

            var id = q.Survey_questionId;
            var a1id = a1.Survey_answerId;
            var a2id = a2.Survey_answerId;

            var a1h = document.getElementById(a1id);
            var a2h = document.getElementById(a2id);
            var a1s = document.getElementById(a1id+'show');
            var a2s = document.getElementById(a2id+'show');
            var s = YAHOO.widget.Slider.getHorizDualSlider(id+'slider-bg', 
                a1id+"slider-min-thumb", a2id+"slider-max-thumb", 
                sliderWidth, 1*scale, [1,sliderWidth]);
            sliders[id] = s;

            s.minRange = 4; 
            var updateUI = function () { 
               var min = Math.round(s.minVal/scale), 
                   max = Math.round(s.maxVal/scale); 
               a1h.value = min;  
               a1s.innerHTML = min;  
               a2h.value = max;  
               a2s.innerHTML = max;  
           }; 
   
           // Subscribe to the dual thumb slider's change and ready events to 
           // report the state. 
//           s.subscribe('ready', updateUI); 
           s.subscribe('change', updateUI);  
    }
    this.sliders = function(q){
        var total = sliderWidth; 
        for(var i in q.answers){
            var a = q.answers[i];
            var step = q.answers[i].step; 
            var scale = sliderWidth/q.answers[i].max;
            var Event = YAHOO.util.Event;
            var lang  = YAHOO.lang;
            var id = a.Survey_answerId;
            var s = YAHOO.widget.Slider.getHorizSlider(id+'slider-bg', id+'slider-thumb', 
                0, sliderWidth, (scale*step));
            s.scale = scale;
            sliders[id] = s;
            s.max = a.max*scale; 
            s.input = a.Survey_answerId; 
            s.scale = scale;
            document.getElementById(id).value = a.min;
            var check = function() {
                var t = document.getElementById(this.input);
                t.value = this.getRealValue();
            };
            s.getRealValue = function() {
                return this.getValue() / this.scale; 
            }
            s.subscribe("slideEnd", check);
        }
    }
    //an object which creates sliders for allocation type questions and then manages their events and keeps them from overallocating
    this.sliderManager = function(q,t){
        var total = sliderWidth; 
        var step = q.answers[0].step; 
        var scale = sliderWidth/q.answers[0].max;

        for(var i in q.answers){
            var a = q.answers[i];
            var Event = YAHOO.util.Event;
            var lang  = YAHOO.lang;
            var id = a.Survey_answerId+'slider-bg';
            var s = YAHOO.widget.Slider.getHorizSlider(id, a.Survey_answerId+'slider-thumb', 
                0, sliderWidth, scale*step);
            sliders[a.Survey_answerId] = s;
            s.input = a.Survey_answerId;
            s.lastValue = 0;
            var check = function() {
                var t = 0;
                for(var x in sliders){
                    t+= sliders[x].getValue();
                }
                if(t > total){
                    t -= this.getValue();
                    t = Math.round(t);
                    this.setValue(total-t);// + (scale*step));
                }else{ 
                    this.lastValue = this.getValue();
                    document.getElementById(this.input).value = this.getRealValue();
                }
            };
            s.subscribe("change", check);
            var manualEntry = function(e){
              // set the value when the 'return' key is detected 
              if (Event.getCharCode(e) === 13 || e.type == 'blur') { 
                  var v = parseFloat(this.value, 10); 
                  v = (lang.isNumber(v)) ? v : 0; 
                  v *= scale;
   
                  // convert the real value into a pixel offset 
                  for(var sl in sliders){
                    if(sliders[sl].input == this.id){
                        sliders[sl].setValue(Math.round(v)); 
                    }
                  }
              } 
            }
            Event.on(document.getElementById(s.input), "blur", manualEntry);
            
            s.getRealValue = function() { 

                return Math.round(parseInt(this.getValue()) / scale); 
            }
            document.getElementById(s.input).value = s.getRealValue();
        }
    }

    this.selectCalendar = function(event,args,obj){
        var id = obj[1];
        var selected = args[0]; 
        var date = selected[0];
        var year = date[0], month = date[1], day = date[2];
        var input = document.getElementById(id);
        input.value = month + "/" + day + "/" + year;
        obj[0].hide();
    }


    this.showCalendar = function(event,objs){
        objs[0].show();
    }

    this.sliderTextSet = function(event,objs){
        this.value = this.value * 1;
        if(this.value == 'NaN'){this.value = 0;}
        sliders[this.id].setValue(Math.round(this.value * sliders[this.id].scale)); 
    }

    this.buttonChanged = function(event,objs){
        var b = objs[0];
        var qid = objs[1];
        var maxA = objs[2];
        var butts = objs[3];
        var qsize = objs[4];
        var aid = objs[5];
        max = parseInt(max);
        if(maxA == 1){
            if(b.getAttribute('class') == 'mcbutton-selected'){
                document.getElementById(b.hid).value = 0;
                b.setAttribute('class','mcbutton');
            }else{
                document.getElementById(b.hid).value = 1;
                b.setAttribute('class','mcbutton-selected');
            }
            for(var i in butts){
                if(butts[i] != b){
                    butts[i].setAttribute('class','mcbutton');
                    document.getElementById(butts[i].hid).value = '';
                }
            }
        } 
        else if(b.getAttribute('class') == 'mcbutton'){
            var max = parseInt(document.getElementById(qid+'max').innerHTML);
            if(max == 0){
                b.setAttribute('class','mcbutton');
                //warn that options used up
            }
            else{
                b.setAttribute('class','mcbutton-selected');
                document.getElementById(qid+'max').innerHTML = parseInt(max-1);
                document.getElementById(b.hid).value = 1;
            }
        }else{
            b.setAttribute('class','mcbutton');
            var max = parseInt(document.getElementById(qid+'max').innerHTML);
            document.getElementById(qid+'max').innerHTML = parseInt(max+1);
            document.getElementById(b.hid).value = '';
        }
        if(qsize == 1){
            if(! document.getElementById(aid+'verbatim')){
                Survey.Form.formsubmit();
            }
        }
    }
}();




//----------------------------------------------------------------
//
//      Initialize survey 
//
//----------------------------------------------------------------
Survey.OnLoad = new function() {
    var e = YAHOO.util.Event;
    this.init = function() {
        e.onDOMReady(this.initHandler);
    }
    this.initHandler = function(){
        Survey.Comm.setUrl('/'+document.getElementById('assetPath').value);
        Survey.Comm.callServer('','loadQuestions');
    }
}();

Survey.OnLoad.init();
