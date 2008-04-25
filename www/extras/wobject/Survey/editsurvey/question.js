if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.QuestionTemplate = new function(){

    this.loadQuestion = function(params){

        for(var p in params){
            if(params[p] == undefined){params[p] = '';}
        } 

        var html = "\
            <div id='question'>\
                <div class='hd'>Please enter question information</div>\
                <div class='bd'>\
\
                    <form name='form' method='POST' action='?func=submitQuestionEdit'>\
                    <p>Question Number: "+params.sequenceNumber + "\
\
                    <input type='hidden' name='Survey_sectionId' value='"+params.Survey_sectionId+"'>\
                    <input type='hidden' name='Survey_questionId' value='"+params.Survey_questionId+"'>\
                    <p>Question Text:\n";
        if(params.questionText == ''){
            html = html + "<textarea name='questionText'>Enter Text Here</textArea>\n";
        }
        else{
            html = html + "<textarea name='questionText'>"+params.questionText+"</textArea>\n";
        }
        html = html + "<p>Question custom variable name:<input maxlength=35 size=10 type=text value='"+ params.questionVariable +"' name=questionVariable size=2></p>";
        html = html + "<p>Randomize answers:";
 
        html = html+ this.makeRadio('randomizeAnswers',[{text:'Yes',value:1},{text:'No',value:0}],params.randomizeAnswers);
        html = html + "<p>Question type:";
        var questions = ['Agree/Disagree','Certainty','Concern','Confidence','Currency','Date','Date Range','Dual Slider - Range','Education','Effectiveness',
            'Email','File Upload','Gender','Hidden','Ideology','Importance','Likelihood','Multi Slider - Allocate','Multiple Choice','Oppose/Support',
            'Party','Phone Number','Race','Risk','Satisfaction','Scale','Security','Slider','Text','Text Date','Threat','True/False','Yes/No'];
//        var questions = ['Multiple Choice','Gender','Yes/No','True/False','Agree/Disagree','Oppose/Support','Importance','Likelihood','Certainty','Satisfaction',
//            'Confidence','Effectiveness','Concern','Risk','Threat','Security','Ideology','Race','Party','Education',
//            'Text', 'Email', 'Phone Number', 'Text Date', 'Currency',
//            'Slider','Dual Slider - Range','Multi Slider - Allocate', 'Date','Date Range', 'File Upload','Hidden'];

        html = html + this.makeMenu('questionType',questions,questions,params.questionType);
        
        html = html + "\
                    <p>Randomized words:\
                        <textarea name=randomizedWords>"+params.randomizedWords+"</textArea>\
                    <p>Vertical display:";

        html = html+ this.makeRadio('verticalDisplay',[{text:'Yes',value:1},{text:'No',value:0}],params.verticalDisplay);
        html = html + "<p>Allow comment:";
        html = html + this.makeRadio('allowComment',[{text:'Yes',value:1},{text:'No',value:0}],params.allowComment);
        html = html + "<span id='commentParams'><p>&nbsp;&nbsp; Cols:<input type=text size=2 value='"+params.commentCols+"' name=commentCols> Rows: \
            <input type=text size=2 value='"+params.commentRows+"' name=commentRows> </p></span>";
        html = html + "<p>Maximum number of answers:<input type=text value='"+params.maxAnswers+"' name=maxAnswers size=2>";
        html = html + "<p>Required:";
        html = html+ this.makeRadio('required',[{text:'Yes',value:1},{text:'No',value:0}],params.required);
        html = html + "\
                    </form>\
                </div>\
            </div>\
        ";

        document.getElementById('edit').innerHTML = html;


        var butts = [ { text:"Submit", handler:function(){this.submit();}, isDefault:true }, { text:"Cancel", handler:function(){this.cancel();}} ];
        if(params.Survey_questionId != ''){
            butts[2] = {text:"Delete", handler:function(){Survey.Comm.deleteQuestion(params.Survey_questionId);}};
        }

        var form = new YAHOO.widget.Dialog("question", 
            { width : "315px",
              fixedcenter : true,
              visible : false, 
              constraintoviewport : true,
              buttons : butts
             } ); 

        form.callback = Survey.Comm.callback;
        form.render();
        form.show();

    }
    this.makeMenu = function(name,values,text,selected){
        var html = "<select name='"+name+"'>\n";
        for(var i in values){
            if(values[i] == selected){
                html = html + "<option value='"+values[i]+"' selected>"+text[i]+"</option>\n";
            }else{
                html = html + "<option value='"+values[i]+"' >"+text[i]+"</option>\n";
            }
        }
        html = html + "</select>\n";
        return html;
    }
    this.makeRadio = function(name,values,checked){
        var html = '';
        for(var i in values){
            if(checked == values[i]['value']){
                html = html+ "<input type='radio' id='"+name+"' name='" + name + "' value='" + values[i]['value'] + "' checked>" + values[i]['text'];
            }else{
                html = html+ "<input type='radio' id='"+name+"' name='" + name + "' value='" + values[i]['value'] + "' >" + values[i]['text'];
            }
        }
        html = html + "\n";
        return html;
    }

}();
