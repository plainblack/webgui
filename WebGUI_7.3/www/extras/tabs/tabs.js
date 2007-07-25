function hoverOn(){
        this.className = 'tab tabHover';
}

function hoverOff(){
        this.className = 'tab';
}

function toggleTab(i){
        if (document.getElementById){
                for (f=1;f<numberOfTabs+1;f++){
                        document.getElementById('tabcontent'+f).style.display='none';
                        document.getElementById('tab'+f).className = 'tab';
	 		document.getElementById('tab'+f).onmouseover = hoverOn;
	 		document.getElementById('tab'+f).onmouseout = hoverOff;
                }
                document.getElementById('tabcontent'+i).style.display='block';
                document.getElementById('tab'+i).className = 'tab tabActive';
	 	document.getElementById('tab'+i).onmouseover = '';
	 	document.getElementById('tab'+i).onmouseout = '';
//		fixFckEditor();
        }
}

function initTabs () {
        toggleTab(1);
}

function fixFckEditor() {
	if ( !document.all && FCKeditorAPI) {
		for ( var o in FCKeditorAPI.__Instances ) {
			var oEditor = FCKeditorAPI.__Instances[ o ] ;
			if ( oEditor.EditMode == FCK_EDITMODE_WYSIWYG ) {
				oEditor.SwitchEditMode() ;
				//oEditor.SwitchEditMode() ;
			}
		}
	}
}


