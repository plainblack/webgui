var WGInsertImageDialog = {
    init : function(ed) {
        var iframe = document.getElementById('image-manager');
        window.setTimeout(function() {
            iframe.src = tinyMCEPopup.getWindowArg('page_url') + '?op=formHelper;class=HTMLArea;sub=imageTree';
        }, 100);
    },

    setUrl : function(url, thumburl) {
        document.getElementById('image-url').value = url;
        var iframe = document.getElementById('image-preview');
        iframe.src = thumburl;
    },

    update : function(form) {
        if(!form.imageurl.value) {
            alert("Image URL must be specified.");
            form.imageurl.focus();
            return;
        }
        if (form.imagehspace.value && !checkNumber(form.imagehspace.value)) {
            alert("Horizontal spacing must be a number between 0 and 999.");
            form.imagehspace.focus();
            return;
        }
        if (form.imagevspace.value && !checkNumber(form.imagevspace.value)) {
            alert("Vertical spacing must be a number between 0 and 999.");
            form.imagevspace.focus();
            return;
        }
        if(form.imageborder.value && !checkNumber(form.imageborder.value)) {
            alert("Border thickness must be a number between 0 and 999.");
            form.imageborder.focus();
            return;
        }
        if(form.imageurl.value.length > 2040) {
            form.imageurl.value = form.imageurl.value.substring(0,2040);
        }
        var img = "<img"
            + " src=\"" + form.imageurl.value + '"'
            + " alt=\"" + form.imagealt.value + '"';
        if (form.imagehspace.value != "") {
            img += ' hspace="' + parseInt(form.imagehspace.value) + '"';
        }
        if (form.imagevspace.value != "") {
            img += ' vspace="' + parseInt(form.imagevspace.value) + '"';
        }
        if (form.imageborder.value != "") {
            img += ' border="' + parseInt(form.imageborder.value) + '"';
        }
        if (form.imagealign.value != "") {
            img += ' align="' + form.imagealign.value + '"';
        }
        img += ' />';
        var ed = tinyMCEPopup.editor;
        ed.execCommand('mceInsertContent', false, img);
        tinyMCEPopup.close();
    }
}

function checkNumber(num) {
    num = parseInt(num);
    if (isNaN(num) || num < 0 || num > 999) {
        return false;
    }
    return true;
}

tinyMCEPopup.requireLangPack();
tinyMCEPopup.onInit.add(WGInsertImageDialog.init, WGInsertImageDialog);

