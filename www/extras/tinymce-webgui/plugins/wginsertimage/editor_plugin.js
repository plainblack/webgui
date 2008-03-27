(function() {
    tinymce.PluginManager.requireLangPack('wginsertimage');

    tinymce.create('tinymce.plugins.WGInsertImagePlugin', {
        init : function(ed, url) {
            var page_url = document.location.protocol + "//" + document.location.hostname + (document.location.port ? ":" + document.location.port : '') + getWebguiProperty('pageURL');
            ed.addCommand('wgInsertImage', function() {
                ed.windowManager.open({
                    file : url + '/insertimage.htm',
                    width : 500 + ed.getLang('wgpagetree.delta_width', 0),
                    height : 550 + ed.getLang('wgpagetree.delta_height', 0),
                    inline : 1
                }, {
                    plugin_url  : url,
                    page_url    : page_url
                });
            });

            ed.addButton('wginsertimage', {
                title : 'wginsertimage.desc',
                cmd : 'wgInsertImage',
                image : url + '/img/insertimage.gif'
            });
        },

        getInfo : function() {
            return {
                longname : 'WebGUI Image Insert',
                author : 'Plain Black',
                authorurl : 'http://www.plainblack.com/',
                infourl : 'http://www.webgui.org/',
                version : "1.0"
            };
        }
    });

    // Register plugin
    tinymce.PluginManager.add('wginsertimage', tinymce.plugins.WGInsertImagePlugin);
})();

