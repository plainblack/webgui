var WGMacroDialog = {
    init : function(ed) {
    },

    update : function(form) {
        var ed = tinyMCEPopup.editor;

        var inputs = form.elements;
        for (var i = 0; i <= inputs.length; i++) {
            var input = inputs[i];
            if (input.name != 'macrolist') {
                continue;
            }
            if (input.value.length > 0) {
                ed.execCommand("mceInsertContent", false, input.value);
                tinyMCEPopup.close();
                return;
            }
        }
        tinyMCEPopup.close();
        return;
    }
};

tinyMCEPopup.requireLangPack();
tinyMCEPopup.onInit.add(WGMacroDialog.init, WGMacroDialog);

