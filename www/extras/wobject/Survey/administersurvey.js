/*global Survey, YAHOO */
if (typeof Survey === "undefined") {
    var Survey = {};
}

(function(){
	
	var CLASS_INVALID = 'survey-invalid'; // For elements that fail input validation
	var CLASS_INVALID_MARKER = 'survey-invalid-marker'; // For default '*' invalid field marker
	
    var multipleChoice = {
        'Multiple Choice': 1,
        'Gender': 1,
        'Yes/No': 1,
        'True/False': 1,
        'Ideology': 1,
        'Race': 1,
        'Party': 1,
        'Education': 1,
        'Scale': 1,
        'Agree/Disagree': 1,
        'Oppose/Support': 1,
        'Importance': 1,
        'Likelihood': 1,
        'Certainty': 1,
        'Satisfaction': 1,
        'Confidence': 1,
        'Effectiveness': 1,
        'Concern': 1,
        'Risk': 1,
        'Threat': 1,
        'Security': 1
    };
    var text = {
        'Text': 1,
        'Email': 1,
        'Phone Number': 1,
        'Text Date': 1,
        'Currency': 1
    };
    var slider = {
        'Slider': 1,
        'Dual Slider - Range': 1,
        'Multi Slider - Allocate': 1
    };
    var dateType = {
        'Date': 1,
        'Date Range': 1
    };
    var fileUpload = {
        'File Upload': 1
    };
    var hidden = {
        'Hidden': 1
    };
    
    var hasFile;
    var verb = 0;
    var lastSection = 'first';
    
    var toValidate;
    var sliderWidth = 500;
    var sliders;
    
    function formsubmit(event){
        var submit = 1;//boolean for if all was good or not
        for (var i in toValidate) {
            if (YAHOO.lang.hasOwnProperty(toValidate, i)) {
                var answered = 0;
                if (toValidate[i].type === 'Multi Slider - Allocate') {
                    var total = 0;
                    for (var z in toValidate[i].answers) {
                        if (YAHOO.lang.hasOwnProperty(toValidate[i].answers, z)) {
                            total += Math.round(document.getElementById(z).value);
                        }
                    }
                    if (total === toValidate[i].total) {
                        answered = 1;
                    }
                    else {
                        var amountLeft = toValidate[i].total - total;
                        alert("Please allocate the remaining " + amountLeft + ".");
                    }
                }
                else {
                    for (var z1 in toValidate[i].answers) {
                        if (YAHOO.lang.hasOwnProperty(toValidate[i].answers, z1)) {
                            var v = document.getElementById(z1).value;
                            if (YAHOO.lang.isValue(v) && v !== '') {
                                answered = 1;
                                break;
                            }
                        }
                    }
                }
				var node = document.getElementById(i + 'required');
				var q_parent_node = YAHOO.util.Dom.getAncestorByClassName(node, 'question');
                if (!answered) {
                    submit = 0;
					
					// Apply CLASS_INVALID to the parent question div for people who want to skin Survey
                    YAHOO.util.Dom.addClass(q_parent_node, CLASS_INVALID);
					
					// Insert default '*' marker (can be hidden via CSS for those who want something different)
					node.innerHTML = "<span class='" + CLASS_INVALID_MARKER + "'>*</span>";
                }
                else {
                    YAHOO.util.Dom.removeClass(q_parent_node, CLASS_INVALID);
					node.innerHTML = '';
                }
            }
        }
        if (submit) {
            YAHOO.log("Submitting");
            Survey.Comm.callServer('', 'submitQuestions', 'surveyForm', hasFile);
        }
    }
    
    //an object which creates sliders for allocation type questions and then manages their events and keeps them from overallocating
    function sliderManager(q, t){
        var total = sliderWidth;
        var step = Math.round(parseFloat(q.answers[0].step));
        var min = Math.round(parseFloat(q.answers[0].min));
        var distance = Math.round(parseFloat(q.answers[0].max) + (-1 * min));
        var scale = Math.round(sliderWidth / distance);
        for (var i in q.answers) {
            if (YAHOO.lang.hasOwnProperty(q.answers, i)) {
                var a = q.answers[i];
                var Event = YAHOO.util.Event;
                var lang = YAHOO.lang;
                var id = a.id + 'slider-bg';
                var s = YAHOO.widget.Slider.getHorizSlider(id, a.id + 'slider-thumb', 0, sliderWidth, scale * step);
                s.animate = false;
                if (YAHOO.lang.isUndefined(sliders[q.id])) {
                    sliders[q.id] = [];
                }
                sliders[q.id][a.id] = s;
                s.input = a.id;
                s.lastValue = 0;
                var check = function(){
                    var t = 0;
                    for (var x in sliders[q.id]) {
                        if (YAHOO.lang.hasOwnProperty(sliders[q.id], x)) {
                            t += sliders[q.id][x].getValue();
                        }
                    }
                    if (t > total) {
                        t -= this.getValue();
                        t = Math.round(t);
                        this.setValue(total - t);// + (scale*step));
                        document.getElementById(this.input).value = Math.round(parseFloat((((total - t) / total) * distance) + min));
                    }
                    else {
                        this.lastValue = this.getValue();
                        document.getElementById(this.input).value = this.getRealValue();
                    }
                };
                s.subscribe("change", check);
                s.subscribe("slideEnd", check);
                var manualEntry = function(e){
                    // set the value when the 'return' key is detected 
                    if (Event.getCharCode(e) === 13 || e.type === 'blur') {
                        var v = parseFloat(this.value, 10);
                        v = (lang.isNumber(v)) ? v : 0;
                        //                  v *= scale;
                        v = (((v - min) / distance)) * total;
                        // convert the real value into a pixel offset 
                        for (var sl in sliders[q.id]) {
                            if (sliders[q.id][sl].input === this.id) {
                                sliders[q.id][sl].setValue(Math.round(v));
                            }
                        }
                    }
                };
                Event.on(document.getElementById(s.input), "blur", manualEntry);
                Event.on(document.getElementById(s.input), "keypress", manualEntry);
                
                s.getRealValue = function(){
                    return Math.round(parseFloat(((this.getValue() / total) * distance) + min));
                };
                document.getElementById(s.input).value = s.getRealValue();
            }
        }
    }
    
    function sliderTextSet(event, objs){
        this.value = this.value * 1;
		this.value = YAHOO.lang.isValue(this.value) ? this.value : 0;
        sliders[this.id].setValue(Math.round(this.value * sliders[this.id].scale));
    }
    
    function handleDualSliders(q){
        var a1 = q.answers[0];
        var a2 = q.answers[1];
        var scale = sliderWidth / a1.max;
        
        var id = q.id;
        var a1id = a1.id;
        var a2id = a2.id;
        
        var a1h = document.getElementById(a1id);
        var a2h = document.getElementById(a2id);
        var a1s = document.getElementById(a1id + 'show');
        var a2s = document.getElementById(a2id + 'show');
        var s = YAHOO.widget.Slider.getHorizDualSlider(id + 'slider-bg', a1id + "slider-min-thumb", a2id + "slider-max-thumb", sliderWidth, 1 * scale, [1, sliderWidth]);
        sliders[id] = s;
        
        s.minRange = 4;
        var updateUI = function(){
            var min = Math.round(s.minVal / scale), max = Math.round(s.maxVal / scale);
            a1h.value = min;
            a1s.innerHTML = min;
            a2h.value = max;
            a2s.innerHTML = max;
        };
        
        // Subscribe to the dual thumb slider's change and ready events to 
        // report the state. 
        //           s.subscribe('ready', updateUI); 
        //s.subscribe('change', updateUI);  
        s.subscribe('slideEnd', updateUI);
    }
    
    function handleSliders(q){
        var total = sliderWidth;
        for (var i in q.answers) {
            if (YAHOO.lang.hasOwnProperty(q.answers, i)) {
                var a = q.answers[i];
                var step = Math.round(q.answers[i].step);
                var min = Math.round(parseFloat(q.answers[i].min));
                var distance = Math.round(parseFloat(q.answers[i].max) + (-1 * min));
                var scale = Math.round(sliderWidth / distance);
                var id = a.id;
                var s = YAHOO.widget.Slider.getHorizSlider(id + 'slider-bg', id + 'slider-thumb', 0, sliderWidth, (scale * step));
                s.scale = scale;
                sliders[q.Survey_questionid] = [];
                sliders[q.Survey_questionid][id] = s;
                s.input = a.id;
                s.scale = scale;
                document.getElementById(id).value = a.min;
                var check = function(){
                    var t = document.getElementById(this.input);
                    t.value = this.getRealValue();
                };
                s.getRealValue = function(){
                    return Math.round(parseFloat(((this.getValue() / total) * distance) + min));
                };
                s.subscribe("slideEnd", check);
            }
        }
    }
    
    function showCalendar(event, objs){
        objs[0].show();
    }
    
    function selectCalendar(event, args, obj){
        var id = obj[1];
        var selected = args[0];
        var date = selected[0];
        var year = date[0], month = date[1], day = date[2];
        var input = document.getElementById(id);
        input.value = month + "/" + day + "/" + year;
        obj[0].hide();
    }
    
    function buttonChanged(event, objs){
        var b = objs[0];
        var qid = objs[1];
        var maxA = objs[2];
        var butts = objs[3];
        var qsize = objs[4];
        var aid = objs[5];
        //max = parseFloat(max);
        //        clearTimeout(Survey.Form.submittimer);
        if (maxA) {
            if (b.className === 'mcbutton-selected') {
                document.getElementById(b.hid).value = 0;
                b.className = 'mcbutton';
            }
            else {
                document.getElementById(b.hid).value = 1;
                b.className = 'mcbutton-selected';
            }
            for (var i in butts) {
                if (YAHOO.lang.hasOwnProperty(butts, i)) {
                    if (butts[i] !== b) {
                        butts[i].className = 'mcbutton';
                        document.getElementById(butts[i].hid).value = '';
                    }
                }
            }
        }
        else 
            if (b.className === 'mcbutton') {
                var bscount = 0;//button selected count
                for (var ib in butts) {
                    if (butts[ib].className === 'mcbutton-selected') {
                        bscount++;
                    }
                }
                var max = maxA - bscount;//= parseFloat(document.getElementById(qid+'max').innerHTML);
                if (max === 0) {
                    b.className = 'mcbutton';
                //warn that options used up
                }
                else {
                    b.className = 'mcbutton-selected';
                    //document.getElementById(qid+'max').innerHTML = parseFloat(max-1);
                    document.getElementById(b.hid).value = 1;
                }
            }
            else {
                b.className = 'mcbutton';
                var bscount1 = 0;//button selected count
                for (var ibb in butts) {
                    if (butts[ibb].className === 'mcbutton-selected') {
                        bscount1++;
                    }
                }
                //var max = maxA - bscount1;//= parseFloat(document.getElementById(qid+'max').innerHTML);
                //            document.getElementById(qid+'max').innerHTML = parseFloat(max+1);
                document.getElementById(b.hid).value = '';
            }
        /*
         if(qsize == 1 && b.className == 'mcbutton-selected'){
         if(! document.getElementById(aid+'verbatim')){
         Survey.Form.submittimer=setTimeout("Survey.Form.formsubmit()",500);
         }
         }
         */
    }
    
    // Public API
    Survey.Form = {
        displayQuestions: function(params){
            toValidate = [];
            var qs = params.questions;
            var s = params.section;
            sliders = [];
            
            //What to show and where 
            document.getElementById('survey').innerHTML = params.html;
            //var te = document.createElement('span'); 
            //te.innerHTML = "<input type=button id=testB name='Reload Page' value='Reload Page'>";
            //document.getElementById('survey').appendChild(te);
            //YAHOO.util.Event.addListener("testB", "click", function(){Survey.Comm.callServer('','loadQuestions');});   
            
            if (qs[0]) {
                if (lastSection !== s.id || s.everyPageTitle === '1') {
                    document.getElementById('headertitle').style.display = 'block';
                }
                if (lastSection !== s.id || s.everyPageText === '1') {
                    document.getElementById('headertext').style.display = 'block';
                }
				
                if (lastSection !== s.id && s.questionsOnSectionPage !== '1') {
                    var span = document.createElement("div");
                    span.innerHTML = "<input type=button id='showQuestionsButton' value='Continue'>";
                    span.style.display = 'block';
                    
                    document.getElementById('survey-header').appendChild(span);
                    YAHOO.util.Event.addListener("showQuestionsButton", "click", function(){
                        document.getElementById('showQuestionsButton').style.display = 'none';
                        if (s.everyPageTitle !== '1') {
                            document.getElementById('headertitle').style.display = 'none';
                        }
                        if (s.everyPageText !== '1') {
                            document.getElementById('headertext').style.display = 'none';
                        }
                        document.getElementById('questions').style.display = 'inline';
                        Survey.Form.addWidgets(qs);
                    });
                }
                else {
                    document.getElementById('questions').style.display = 'inline';
                    Survey.Form.addWidgets(qs);
                }
                lastSection = s.id;
            }
            else {
                document.getElementById('headertitle').style.display = 'block';
                document.getElementById('headertext').style.display = 'block';
                document.getElementById('questions').style.display = 'inline';
                Survey.Form.addWidgets(qs);
            }
        },
        
        addWidgets: function(qs){
            hasFile = false;
            for (var i = 0; i < qs.length; i++) {
                var q = qs[i];
                var verts = '';
                for (var x in q.answers) {
                    if (YAHOO.lang.hasOwnProperty(q.answers, x)) {
                        for (var y in q.answers[x]) {
                            if (YAHOO.lang.hasOwnProperty(q.answers[x], y)) {
                                if (YAHOO.lang.isUndefined(q.answers[x][y])) {
                                    q.answers[x][y] = '';
                                }
                            }
                        }
                    }
                }
                
                //Check if this question should be validated
                if (q.required) {
                    toValidate[q.id] = [];
                    toValidate[q.id].type = q.questionType;
                    toValidate[q.id].answers = [];
                }
                
                
                if (multipleChoice[q.questionType]) {
                    var butts = [];
                    verb = 0;
                    for (var j = 0; j < q.answers.length; j++) {
                        var a = q.answers[j];
                        if (toValidate[q.id]) {
                            toValidate[q.id].answers[a.id] = 1;
                        }
                        var b = document.getElementById(a.id + 'button');
                        /*
                         b = new YAHOO.widget.Button({ type: "checkbox", label: a.answerText, id: a.id+'button', name: a.id+'button',
                         value: a.id,
                         container: a.id+"container", checked: false });
                         */
                        //                    b.on("click", buttonChanged,[b,a.id,q.maxAnswers,butts,qs.length,a.id]);
                        //                    YAHOO.util.Event.addListener(a.id+'button', "click", buttonChanged,[b,a.id,q.maxAnswers,butts,qs.length,a.id]);
                        if (a.verbatim) {
                            verb = 1;
                        }
                        YAHOO.util.Event.addListener(a.id + 'button', "click", buttonChanged, [b, a.id, q.maxAnswers, butts, qs.length, a.id]);
                        b.hid = a.id;
                        butts.push(b);
                    }
                }
                else 
                    if (dateType[q.questionType]) {
                        for (var k = 0; k < q.answers.length; k++) {
                            var ans = q.answers[k];
                            if (toValidate[q.id]) {
                                toValidate[q.id].answers[ans.id] = 1;
                            }
                            var calid = ans.id + 'container';
                            var c = new YAHOO.widget.Calendar(calid, {
                                title: 'Choose a date:',
                                close: true
                            });
                            c.selectEvent.subscribe(selectCalendar, [c, ans.id], true);
                            c.render();
                            c.hide();
                            var btn = new YAHOO.widget.Button({
                                label: "Select Date",
                                id: "pushbutton" + ans.id,
                                container: ans.id + 'button'
                            });
                            btn.on("click", showCalendar, [c]);
                        }
                    }
                    else 
                        if (slider[q.questionType]) {
                            //First run through and put up the span placeholders and find the max value for an answer, to know how big the allocation points will be.
                            var max = 0;
                            if (q.questionType === 'Dual Slider - Range') {
                                handleDualSliders(q);
                            }
                            else {
                                for (var s in q.answers) {
                                    if (YAHOO.lang.hasOwnProperty(q.answers, s)) {
                                        var a1 = q.answers[s];
                                        YAHOO.util.Event.addListener(a1.id, "blur", sliderTextSet);
                                        if (a1.max - a1.min > max) {
                                            max = a1.max - a1.min;
                                        }
                                    }
                                }
                            }
                            if (q.questionType === 'Multi Slider - Allocate') {
                                //sliderManagers[sliderManagers.length] = new this.sliderManager(q,max);
                                for (var x1 = 0; x1 < q.answers.length; x1++) {
                                    if (toValidate[q.id]) {
                                        toValidate[q.id].total = q.answers[x1].max;
                                        toValidate[q.id].answers[q.answers[x1].id] = 1;
                                    }
                                }
                                sliderManager(q, max);
                            }
                            else 
                                if (q.questionType === 'Slider') {
                                    handleSliders(q);
                                }
                        }
                        
                        else 
                            if (fileUpload[q.questionType]) {
                                hasFile = true;
                            }
                            
                            else 
                                if (text[q.questionType]) {
                                    if (toValidate[q.id]) {
                                        toValidate[q.id].answers[q.answers[x].id] = 1;
                                    }
                                }
            }
            YAHOO.util.Event.addListener("submitbutton", "click", formsubmit);
        }
    };
    
    
})();

YAHOO.util.Event.onDOMReady(function(){
    // Survey.Comm.setUrl('/' + document.getElementById('assetPath').value);
    Survey.Comm.callServer('', 'loadQuestions');
});