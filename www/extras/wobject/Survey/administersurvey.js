if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.Form = new function() {
   
    var multipleChoice = {'Multiple Choice':1,'Gender':1,'Yes/No':1,'True/False':1,'Agree/Disagree':1,'Oppose/Support':1,'Importance':1,
        'Likelihood':1,'Certainty':1,'Satisfaction':1,'Confidence':1,'Effectiveness':1,'Concern':1,'Risk':1,'Threat':1,'Security':1,'Ideology':1,
        'Race':1,'Party':1,'Education':1};
    var text = {'Text':1, 'Email':1, 'Phone Number':1, 'Text Date':1, 'Currency':1};
    var slider = {'Slider':1, 'Dual Slider - Range':1, 'Multi Slider - Allocate':1};
    var dateType = {'Date':1,'Date Range':1};
    var fileUpload = {'File Upload':1};
    var hidden = {'Hidden':1};

    var hasFile;

    this.displayQuestions = function(params){
        
        var qs = params.questions;
        var s = params.section;
       

        //What to show and where 
        document.getElementById('survey').innerHTML = params.html; 
var te = document.createElement('span'); 
te.innerHTML = "<input type=button id=testB name='Reload Page' value='Reload Page'>";
document.getElementById('survey').appendChild(te);
YAHOO.util.Event.addListener("testB", "click", function(){Survey.Comm.callServer('','loadQuestions');});   

        if(qs[0] != undefined){
            if(qs[0].sequenceNumber == '1' || s.everyPageTitle > 0){
                document.getElementById('headertitle').style.display='block';
            }
            if(qs[0].sequenceNumber == '1' || s.everyPageText > 0){
                document.getElementById('headertext').style.display = 'block';
            }

            if(qs[0].sequenceNumber == '1' && s.questionsOnSectionPage != '1'){
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
                    });   
            }else{
                document.getElementById('questions').style.display='inline';
            }
        }else{
            document.getElementById('headertitle').style.display='block';
            document.getElementById('headertext').style.display = 'block';
            document.getElementById('questions').style.display='inline';
        }

        //Display questions

        var html;
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

            html += "<hr>";
            html += "<div class='question'>Q"+q.sequenceNumber+": "+q.questionText+"</div>";

            if(multipleChoice[q.questionType]){
                var butts = new Array();   
                for(var x = 0; x < q.answers.length; x++){
                    var a = q.answers[x];
                    var b = new YAHOO.widget.Button({ type: "checkbox", label: a.answerText, id: a.Survey_answerId+'button', name: a.Survey_answerId+'button',
                         value: a.Survey_answerId, 
                        container: a.Survey_answerId+"container", checked: false });
                    b.on("click", this.buttonChanged,[b,a.Survey_questionId,q.maxAnswers,butts,qs.length]);
                    b.hid = a.Survey_answerId;
                    butts.push(b);
                }
            }
            else if(dateType[q.questionType]){
                for(var x = 0; x < q.answers.length; x++){
                    var a = q.answers[x];
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
                        if(a.max - a.min > max){max = a.max - a.min;}
                    }
                }
                if(q.questionType == 'Multi Slider - Allocate'){
                    //sliderManagers[sliderManagers.length] = new this.sliderManager(q,max);
                    new this.sliderManager(q,max);
                }
                else if(q.questionType == 'Slider'){
                    new this.sliders(q); 
                }
            }
            else if(fileUpload[q.questionType]){
                hasFile = true;
            }
        }
        YAHOO.util.Event.addListener("submitbutton", "click", this.formsubmit);   
    }


    this.formsubmit = function(){
        Survey.Comm.callServer('','submitQuestions','surveyForm',hasFile);
    }




    this.dualSliders = function(q){
        var total = 200; 
        var sliders = new Array();
            var a1 = q.answers[0];
            var a2 = q.answers[1];
            var scale = 200/a1.max;

            var id = q.Survey_questionId;
            var a1id = a1.Survey_answerId;
            var a2id = a2.Survey_answerId;

            var a1h = document.getElementById(a1id);
            var a2h = document.getElementById(a2id);
            var a1s = document.getElementById(a1id+'show');
            var a2s = document.getElementById(a2id+'show');
            var s = YAHOO.widget.Slider.getHorizDualSlider(id+'slider-bg', 
                a1id+"slider-min-thumb", a2id+"slider-max-thumb", 
                200, 1*scale, [1,200]);

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
        var total = 200; 
        for(var i in q.answers){
            var a = q.answers[i];
            var step = q.answers[i].step; 
            var scale = 200/q.answers[i].max;
            var Event = YAHOO.util.Event;
            var lang  = YAHOO.lang;
            var id = a.Survey_answerId;
            var s = YAHOO.widget.Slider.getHorizSlider(id+'slider-bg', id+'slider-thumb', 
                0, 200, (scale*step));
            //    0, 200, 1);
            s.max = a.max*scale; 
            s.input = a.Survey_answerId; 
            s.scale = scale;
            document.getElementById(id).value = a.min;
            var check = function() {
                var t = document.getElementById(this.input);
                var tshow = document.getElementById(this.input+'show');
                t.value = this.getRealValue();
                tshow.innerHTML = this.getRealValue();
            };
            s.getRealValue = function() {
                return this.getValue() / this.scale; 
            }
            s.subscribe("slideEnd", check);
            s.subscribe("change", check);
        }
    }
    //an object which creates sliders for allocation type questions and then manages their events and keeps them from overallocating
    this.sliderManager = function(q,t){
        var total = 200; 
        var step = q.answers[0].step; 
        var scale = 200/q.answers[0].max;
        var sliders = new Array();

        for(var i in q.answers){
            var a = q.answers[i];
            var Event = YAHOO.util.Event;
            var lang  = YAHOO.lang;
            var id = a.Survey_answerId+'slider-bg';
            var s = YAHOO.widget.Slider.getHorizSlider(id, a.Survey_answerId+'slider-thumb', 
                0, 200, scale*step);
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
                    this.setValue(total-t + scale*step);
                }else{ 
                    this.lastValue = this.getValue();
                    document.getElementById(this.input).value = this.getRealValue();
                    document.getElementById(this.input+'show').innerHTML = this.getRealValue();
                }
            };
            s.subscribe("slideEnd", check);
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
            Event.on(document.getElementById(s.input), "keydown", manualEntry);
            Event.on(document.getElementById(s.input), "blur", manualEntry);
            
            s.getRealValue = function() { 
                return Math.round(this.getValue() / scale); 
            }
            sliders.push(s);
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
    this.buttonChanged = function(event,objs){
        var b = objs[0];
        var qid = objs[1];
        var maxA = objs[2];
        var butts = objs[3];
        var qsize = objs[4];
        max = parseInt(max);
        if(maxA == 1){
            for(var i in butts){
                butts[i].set('checked',false);
                document.getElementById(butts[i].hid).value = '';
            }
            b.set('checked',true);
            document.getElementById(b.hid).value = 1;
        } 
        else if(b.get('checked')){
            var max = parseInt(document.getElementById(qid+'max').innerHTML);
                if(max == 0){
                    b.set('checked',false);
                    //warn that options used up
                }
                else{
                    document.getElementById(qid+'max').innerHTML = parseInt(max-1);
                    document.getElementById(b.hid).value = '';
                }
        }else{
            var max = parseInt(document.getElementById(qid+'max').innerHTML);
            document.getElementById(qid+'max').innerHTML = parseInt(max+1);
            document.getElementById(b.hid).value = 1;
        }
        if(qsize == 1){
            Survey.Form.formsubmit();
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
