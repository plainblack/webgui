if (typeof Survey == "undefined") {
    var Survey = {};
}

Survey.SectionTemplate = new function(){

    this.loadSection = function(params){

        for(var p in params){
            if(params[p] == undefined){params[p] = '';}
        }

        var html = "\
            <div id='section'>\
            <div class='hd'>Please enter section formation</div>\
            <div class='bd'>\
            <form name='form' method='POST' action='?func=submitSectionEdit'>\
            <p>Section Number: "+params.sequenceNumber + "\
            <input type='hidden' name='Survey_sectionId' value='"+params.Survey_sectionId+"'>\
            <p>Section Name: <input name='sectionName' value='"+params.sectionName + "' type=text>\
            <hr>\
            <p>Randomize Questions:"; 
            if(params.randomizeQuestions == 1){
                html = html+ "\
                    <input type='radio' name='randomizeQuestions' value=1 checked>Yes\
                    <input type='radio' name='randomizeQuestions' value=0>No";
            }else{
                html = html+ "\
                    <input type='radio' name='randomizeQuestions' value=1>Yes\
                    <input type='radio' name='randomizeQuestions' value=0 checked>No";
            }
            html = html + "<p>Section custom variable name:<input maxlength=35 size=10 type=text value='"+ params.sectionVariable +"' name=sectionVariable size=2></p>";
            html = html + "\
                <p>Question per Page:\
                     <select name='questionsPerPage'>";
            for(var i=1;i<=10;i++){  
                if(i == params.questionsPerPage){
                    html = html + "<option value='"+i+"' selected>"+i+"</option>";
                }else{
                    html = html + "<option value='"+i+"'/>"+i+"</option>";
                }
            }
            html = html + "</select>\
            <p>Questions on Section Page: <span id='questionsOnSectionPage'></span>";
            if(params.questionsOnSectionPage == 1){
                html = html+ "\
                    <input type='radio' name='questionsOnSectionPage' value=1 checked>Yes\
                    <input type='radio' name='questionsOnSectionPage' value=0>No";
            }else{
                html = html+ "\
                    <input type='radio' name='questionsOnSectionPage' value=1>Yes\
                    <input type='radio' name='questionsOnSectionPage' value=0 checked>No";
            }
            html = html + "\
            <hr>\
            <p>Section Text:</p> <textarea name=sectionText maxlength=2056 cols=30 rows=5>"+ params.sectionText +"</textarea>\
        ";
        html = html + "<p>Title on every page: " + this.makeRadio('everyPageTitle',[{text:'Yes',value:1},{text:'No',value:0}],params.everyPageTitle);
        html = html + "<p>Text on every page: " + this.makeRadio('everyPageText',[{text:'Yes',value:1},{text:'No',value:0}],params.everyPageText);
        html = html + "<p>Terminal section: " + this.makeRadio('terminal',[{text:'Yes',value:1},{text:'No',value:0}],params.terminal);
        html = html + "<p>  Terminal section URL: <input type=text name=terminalURL value='"+params.terminalURL+"'>";
        document.getElementById('edit').innerHTML = html;

        var butts = [ { text:"Submit", handler:function(){this.submit();}, isDefault:true }, { text:"Cancel", handler:function(){this.cancel();}} ];
        if(params.Survey_sectionId != ''){
            butts[2] = {text:"Delete", handler:function(){Survey.Comm.deleteSection(params.Survey_sectionId);}};
        }

        var form = new YAHOO.widget.Dialog("section",
           { width : "400px",
             fixedcenter : true,
             visible : false,
             constraintoviewport : true,
             buttons : butts
           } );

        form.callback = Survey.Comm.callback;
        form.render();
        form.show();
    }
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

