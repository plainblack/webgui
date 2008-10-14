(function() {
    tinymce.PluginManager.requireLangPack('wgpagetree');

    tinymce.create('tinymce.plugins.WGPageTreePlugin', {
        init : function(ed, url) {
            var page_url = document.location.protocol + "//" + document.location.hostname + (document.location.port ? ":" + document.location.port : '') + getWebguiProperty('pageURL');
            ed.addCommand('wgPageTree', function() {
                ed.windowManager.open({
                    file : url + '/pagetree.htm',
                    width : 400 + ed.getLang('wgpagetree.delta_width', 0),
                    height : 500 + ed.getLang('wgpagetree.delta_height', 0),
                    inline : 1
                }, {
                    plugin_url  : url,
                    page_url    : page_url
                });
            });

            ed.addButton('wgpagetree', {
                title : 'wgpagetree.desc',
                cmd : 'wgPageTree',
                image : url + '/img/pagetree.gif'
            });
        },

        getInfo : function() {
            return {
                longname : 'WebGUI Page Tree',
                author : 'Plain Black',
                authorurl : 'http://www.plainblack.com/',
                infourl : 'http://www.webgui.org/',
                version : "1.0"
            };
        }
    });

    // Register plugin
    tinymce.PluginManager.add('wgpagetree', tinymce.plugins.WGPageTreePlugin);
})();

