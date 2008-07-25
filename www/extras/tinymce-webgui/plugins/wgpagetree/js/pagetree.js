var WGPageTreeDialog = {
    init : function(ed) {
        var iframe = document.getElementById('page_selecter');
        window.setTimeout(function() {
            iframe.src = tinyMCEPopup.getWindowArg('page_url') + '?op=formHelper;class=HTMLArea;sub=pageTree';
        }, 100);
    },

    setUrl : function(url) {
        document.getElementById('link_url').value = url;
    },

    update : function(form) {
        if (form.link_url.value == '') {
            alert('No URL entered!');
            return;
        }
        var ed = tinyMCEPopup.editor;

        tinyMCEPopup.execCommand("mceBeginUndoLevel");
        var elm = ed.dom.getParent(elm, "A");

        // Create new anchor elements
        if (elm == null) {
            tinyMCEPopup.execCommand("CreateLink", false, "#mce_temp_url#", {skip_undo : 1});

            elementArray = tinymce.grep(ed.dom.select("a"), function(n) {return ed.dom.getAttrib(n, 'href') == '#mce_temp_url#';});
            for (i=0; i<elementArray.length; i++) {
                elm = elementArray[i];

                // Move cursor to end
                try {
                    tinyMCEPopup.editor.selection.collapse(false);
                } catch (ex) {
                    // Ignore
                }
                setAttribs(form, elm);
            }
        }
        else {
            setAttribs(form, elm);
        }
        tinyMCEPopup.execCommand("mceEndUndoLevel");
        tinyMCEPopup.close();
    }
}

function setAttribs(form, elm) {
    var href = '^/(' + form.link_url.value + ');';
    elm.href = href;
    if (form.link_target.value == '_self') {
        elm.target = '';
    }
    else {
        elm.target = form.link_target.value;
    }
}

tinyMCEPopup.requireLangPack();
tinyMCEPopup.onInit.add(WGPageTreeDialog.init, WGPageTreeDialog);

