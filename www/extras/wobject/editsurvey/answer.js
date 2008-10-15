if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.AnswerTemplate = new function(){
    this.params;
    this.loadAnswer = function(params){
        for(var p in params){
            if(params[p] == undefined){params[p] = '';}
        }

        var html = "\
            <div id='answer'>\
            <div class='hd'>Please enter answer information</div>\
                <div class='bd'>\
\
                    <form name='form' method='POST' action='?func=submitAnswerEdit'>\
\
                    <p>Answer Number: "+params.sequenceNumber + "\
\
                    <input type='hidden' name='Survey_sectionId' value='"+params.Survey_sectionId+"'>\
                    <input type='hidden' name='Survey_questionId' value='"+params.Survey_questionId+"'>\
                    <input type='hidden' name='Survey_answerId' value='"+params.Survey_answerId+"'>";
        html = html + "<p>Answer Text:\n<textarea name='answerText'>"+params.answerText+"</textArea>\n";
        html = html + "<p>Recorded Answer\n<textarea name='recordedAnswer'>"+params.recordedAnswer+"</textArea>\n";
        html = html + "<p>Jump to Question:<input type=text value='"+params.gotoQuestion+"' name=gotoQuestion size=4>";
        html = html + "<p>Is this the correct answer:\n" + 
            this.makeRadio('isCorrect',[{text:'Yes',value:1},{text:'No',value:0}],params.isCorrect);
        html = html + "<p>Min:<input type=text value='"+params.min+"' name=min size=2>";
        html = html + "<p>Max:<input type=text value='"+params.max+"' name=max size=2>";
        html = html + "<p>Step:<input type=text value='"+params.step+"' name=step size=2>";
        html = html + "<p>Verbatim:\n" + 
            this.makeRadio('verbatim',[{text:'Yes',value:1},{text:'No',value:0}],params.verbatim);
        document.getElementById('edit').innerHTML = html;

        var butts = [{ text:"Submit", handler:function(){this.submit();}, isDefault:true },{ text:"Cancel", handler:function(){this.cancel();}} ];
        if(params.Survey_answerId != ''){
            butts[2] = { text:"Delete", handler:function(){Survey.Comm.deleteAnswer(Survey.AnswerTemplate.params.Survey_answerId);}};
        }

        var form = new YAHOO.widget.Dialog("answer",
            { width : "300px",
              fixedcenter : true,
              visible : false,
              constraintoviewport : true,
              buttons : butts
            });

        form.callback = Survey.Comm.callback;
        form.render();
        form.show();
        this.params = params;
    };

    this.makeRadio = function(name,values,checked){
        var html = '';
        for(var i in values){
            if(checked == values[i]['value']){
                html = html+ "<input type='radio' name='" + name + "' value='" + values[i]['value'] + "' checked>" + values[i]['text'];
            }else{
                html = html+ "<input type='radio' name='" + name + "' value='" + values[i]['value'] + "' >" + values[i]['text'];
            }
        }
        html = html + "\n";
        return html;
    }
}();
