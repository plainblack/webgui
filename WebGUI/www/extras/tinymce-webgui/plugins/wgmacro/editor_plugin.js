(function() {
    tinymce.PluginManager.requireLangPack('wgmacro');

    tinymce.create('tinymce.plugins.WGMacroPlugin', {
        init : function(ed, url) {
            ed.addCommand('wgInsertMacro', function() {
                ed.windowManager.open({
                    file : url + '/macro.htm',
                    width : 400 + ed.getLang('wgmacro.delta_width', 0),
                    height : 125 + ed.getLang('wgmacro.delta_height', 0),
                    inline : 1
                }, {
                    plugin_url : url
                });
            });

            ed.addButton('wgmacro', {
                title : 'wgmacro.desc',
                cmd : 'wgInsertMacro',
                image : url + '/img/macro.gif'
            });
        },

        getInfo : function() {
            return {
                longname : 'WebGUI Macro Inserter',
                author : 'Plain Black',
                authorurl : 'http://www.plainblack.com/',
                infourl : 'http://www.webgui.org/',
                version : "1.0"
            };
        }
    });

    // Register plugin
    tinymce.PluginManager.add('wgmacro', tinymce.plugins.WGMacroPlugin);
})();

