/* Import theme specific language pack */
tinyMCE.importPluginLanguagePack('advlink', 'uk,se,de');

/**
 * Insert link template function.
 */
function TinyMCE_advlink_getInsertLinkTemplate() {
    var template = new Array();
    template['file']   = '../../plugins/advlink/link.htm';
    template['width']  = 440;
    template['height'] = 420;

    // Language specific width and height addons
    template['width']  += tinyMCE.getLang('lang_insert_link_delta_width', 0);
    template['height'] += tinyMCE.getLang('lang_insert_link_delta_height', 0);

    return template;
} 