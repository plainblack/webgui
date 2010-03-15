/*global Survey, YAHOO, alert */
if (typeof Survey === "undefined") {
    var Survey = {};
}

Survey.Data = (function(){

    var lastDataSet = {};
    var focus;
    var lastId = -1;
	
	// Keep references to widgets here so that we can destory any instances before
	// creating new ones (to avoid memory leaks)
	var sButton, qButton, aButton;

    return {
        ddContainer:null,
        dragDrop: function(did){
            YAHOO.log('In drag drop');
			var type = did.className.match("section")  ? 'section'
                     : did.className.match("question") ? 'question'
                     :                                   'answer';

            var first = {
                id: did.id, // pre-drag index of item
                type: type
            };
			var before = YAHOO.util.Dom.getPreviousSiblingBy( document.getElementById(did.id), function(node){
				return node.id; // true iff node has a non-empty id
			});

            var data = {
                id: '',
                type: ''
            };

            if (before) {
                type = before.className.match("section")  ? 'section'
                     : before.className.match("question") ? 'question'
                     :                                      'answer';
                data = {
                    id: before.id,
                    type: type
                };
            }
            YAHOO.log(first.id + ' ' + data.id);
            Survey.Comm.dragDrop(first, data);
        },

        clicked: function(){
            Survey.Comm.loadSurvey(this.id);
        },

        loadData: function(d){
            focus = d.address;//What is the current highlighted item.
            var warnings = ""; 
            for(var w in d.warnings){
                if (YAHOO.lang.hasOwnProperty(d.warnings, w)) {
                    warnings += "<div class='warning'>" + d.warnings[w] + "</div>"; 
                }
            }
            if (document.getElementById('warnings')) {
                if (warnings !== "") {
                    document.getElementById('warnings').innerHTML = warnings;
                    YAHOO.util.Dom.setStyle('warnings-outer', 'display', 'block');
                }
                else {
                    YAHOO.util.Dom.setStyle('warnings-outer', 'display', 'none');
                }
            }
            var showEdit = 1;
            if (lastId.toString() === d.address.toString()) {
                showEdit = 0;
                lastId = -1;
            }
            else {
                lastId = d.address;
            }
            
            if (!Survey.Data.ddContainer) {
                
                // Calculate the bottom of the warnings div (with a little padding)
                var warningsBottom = YAHOO.util.Dom.getRegion('warnings-outer').bottom + 5;
                warningsBottom = YAHOO.lang.isValue(warningsBottom) ? warningsBottom : 50;
                
                // Calculate the bottom of the viewport (with a little padding)
                var viewPortBottom = YAHOO.util.Dom.getViewportHeight() - 10;
                
                // Panel has height from bottom of warnings div to bottom of viewport,
                // but no smaller than 400
                var panelHeight = viewPortBottom - warningsBottom;
                panelHeight = panelHeight < 400 ? 400 : panelHeight;
                
                Survey.Data.ddContainer = new YAHOO.widget.Panel("sections-panel", {
                    width: "400px",
                    height: panelHeight + 'px',
                    visible: true,
                    y: warningsBottom,
                    draggable: true
                });
                
                Survey.Data.ddContainer.setHeader(Survey.i18n.get('Asset_Survey','Survey Objects'));
                Survey.Data.ddContainer.setBody(d.ddhtml);
                Survey.Data.ddContainer.setFooter(document.getElementById("buttons"));
                Survey.Data.ddContainer.render();
            }
            else {
                var children = document.getElementById('sections-panel').childNodes;
                for( i in children){
                    if(children[i].className == 'bd'){
                        YAHOO.util.Event.purgeElement(children[i], true);
                    }
                }
                Survey.Data.ddContainer.setBody(d.ddhtml);
                //Survey.Data.ddContainer.setFooter(document.getElementById("buttons"));
            }
            
            // (re)Add resize handler
            if (Survey.Data.ddContainerResize) {
                Survey.Data.ddContainerResize.destroy();
            }
            Survey.Data.ddContainerResize = new YAHOO.util.Resize('sections-panel', {
                proxy: true,
                minWidth: 300, 
                minHeight: 100
            });
            Survey.Data.ddContainerResize.on('resize', function(args){
                Survey.Data.ddContainer.cfg.setProperty("height", args.height + "px");
            });
            
            //add event handlers for if a tag is clicked
            for (var x in d.ids) {
				if (YAHOO.lang.hasOwnProperty(d.ids, x)) {
	                YAHOO.log('adding handler for ' + d.ids[x]);
	                YAHOO.util.Event.addListener(d.ids[x], "click", this.clicked);
	                var _s = new Survey.DDList(d.ids[x], "sections");
				}
            }
            
            // Toggle class on selected item
            var selectedId = focus.join('-');
            selectedId = selectedId === 'undefined' ? "0" : selectedId;
            if (document.getElementById(selectedId)) {
                YAHOO.util.Dom.addClass(selectedId, 'selected');
            }

			if (!sButton) {
                sButton = new YAHOO.widget.Button({
                    label: Survey.i18n.get('Asset_Survey','add section'),
                    id: "addSection",
                    container: "addSection"
                });
                sButton.on("click", this.addSection);
			}

			if (!qButton) {
                qButton = new YAHOO.widget.Button({
                    label: Survey.i18n.get('Asset_Survey', 'add question'),
                    id: "addQuestion",
                    container: "addQuestion"
                });
                qButton.on("click", this.addQuestion, d.buttons.question);
			}
            qButton.removeListener("click", this.addQuestion);
            qButton.on("click", this.addQuestion, d.buttons.question);

            if (d.buttons.answer) {
                YAHOO.util.Dom.setStyle('addAnswer', 'display', 'inline');
				if (!aButton) {
                    aButton = new YAHOO.widget.Button({
                        label: Survey.i18n.get('Asset_Survey',"add answer"),
                        id: "addAnswer",
                        container: "addAnswer"
                    });
				}
                aButton.removeListener("click", this.addAnswer);
                aButton.on("click", this.addAnswer, d.buttons.answer);
            }else{
                YAHOO.util.Dom.setStyle('addAnswer', 'display', 'none');
            }

            if (showEdit == 1) {
                this.loadObjectEdit(d.edithtml, d.type, d.gotoTargets);
            }
            lastDataSet = d;
        },

        addSection: function(){
            Survey.Comm.newSection();
        },

        addQuestion: function(e, id){
            Survey.Comm.newQuestion(id);
        },

        addAnswer: function(e, id){
            Survey.Comm.newAnswer(id);
        },

        loadObjectEdit: function(edit, type, gotoTargets){
            if (edit) {
                Survey.ObjectTemplate.loadObject(edit, type, gotoTargets);
            }
        },

        loadLast: function(){
            this.loadData(lastDataSet);
        }
    };
})();

//  Initialize survey
YAHOO.util.Event.onDOMReady(function(){
	//var ddTarget = new YAHOO.util.DDTarget("sections", "sections");
    Survey.i18n = new WebGUI.i18n( {
        'namespaces' : {
            'Asset_Survey' : [
                'Make Default Type',
                'Remove Default Type',
                'cancel',
                'add question',
                'add answer',
                'add section',
                'Survey Objects'
            ],
            'Asset' : [
                'Copy'
            ],
            'WebGUI' : [
                'submit',
                'preview',
                '576'
            ]
        },
        onpreload   : {
            fn       : function () {
                            Survey.ObjectTemplate.initObjectEditor();
                            Survey.Comm.loadSurvey();
                       }
        }
    } );
});
