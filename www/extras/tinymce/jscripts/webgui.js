// WebGUI Specific javascript functions for TinyMCE

function tinyMCE_WebGUI_URLConvertor(url, node, on_save) {
	// Use default URL convertor, old 1.43 else 1.44+
        if (typeof(TinyMCE_convertURL) != "undefined")
        	url = TinyMCE_convertURL(url, node, on_save);
        else
                url = tinyMCE.convertURL(url, node, on_save);
        // Do custom WebUI convertion, replace back ^();
        url = url.replace(new RegExp("%5E", "g"), "^");
        url = url.replace(new RegExp("%3B", "g"), ";");
        url = url.replace(new RegExp("%28", "g"), "(");
        url = url.replace(new RegExp("%29", "g"), ")");
        return url;
}


