// WebGUI Specific javascript functions for TinyMCE

function tinyMCE_WebGUI_URLConvertor(url, node, on_save) {
    url = tinyMCE.convertURL(url, node, on_save);
    // Do custom WebGUI convertion, replace back ^();

    // turn escaped macro characters back into the real thing
    url = url.replace(new RegExp("%5E", "g"), "^");
    url = url.replace(new RegExp("%3B", "g"), ";");
    url = url.replace(new RegExp("%28", "g"), "(");
    url = url.replace(new RegExp("%29", "g"), ")");

    // if there is a macro in the line, remove everything in front of the macro
    url = url.replace(/^.*(\^.*)$/,"$1");

    return url;
}

function tinyMCE_WebGUI_Cleanup(type,value) {
    switch (type) {
        case "get_from_editor":
            value = value.replace(/&quot;/g, '"');
            break;
    }
    return value;
}

