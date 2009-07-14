package WebGUI::Help::WebGUI;
use strict;

our $HELP = {

    'style template' => {
        title     => '1073',
        body      => '',
        variables => [ { 'name' => 'body.content' }, { 'name' => 'head.tags' }, { 'name' => 'head_attachments' }, { 'name' => 'body_attachments' } ],
        fields    => [],
        related   => []
    },

    'admin console' => {
        title     => 'admin console template variables',
        body      => '',
        variables => [
            { name => 'formHeader' },
            { name => 'application.workarea' },
            { name => 'application.title'  },
            { name => 'application.icon'   },
            { name => 'application.canUse' },
            { name => 'application.url'    },
            { name => 'application_loop',
              'variables' => [
                { name => 'title',
                  description => 'application.title', 
                },
                { name => 'url',
                  description => 'application.url', 
                },
                { name => 'canUse',
                  description => 'application.canUse', 
                },
                { name => 'icon',
                  description => 'application.icon', 
                },
                { name => 'icon.small',
                  description => 'application.icon.small', 
                },
              ],
            },
            { name => 'backtosite.label'   },
            { name => 'backtosite.url'     },
            { name => 'toggle.on.label'    },
            { name => 'toggle.off.label'   },
            { name => 'console.title'  },
            { name => 'console.icon'   },
            { name => 'console.canUse' },
            { name => 'console.url'    },
            { name => 'help.url'    },
            { name => 'submenu_loop',
              'variables' => [
                { name => 'label',
                  description => 'submenu.label', 
                },
                { name => 'url',
                  description => 'submenu.url', 
                },
                { name => 'extras',
                  description => 'submenu.extras', 
                },
              ],
            },
            { name => 'versionTags',
              'variables' => [
                { name => 'title',
                  description => 'versionTags.title', 
                },
                { name => 'url',
                  description => 'versionTags.url', 
                },
                { name => 'icon',
                  description => 'versionTags.icon', 
                },
              ],
            },
            { name => 'formFooter' },
        ],
        fields    => [],
        related   => []
    },

    'pagination template variables' => {
        title     => '1085',
        body      => '',
        variables => [
            { 'name' => 'pagination.firstPage' },
            { 'name' => 'pagination.firstPageUrl' },
            { 'name' => 'pagination.firstPageText' },
            { 'name' => 'pagination.isFirstPage' },
            { 'name' => 'pagination.lastPage' },
            { 'name' => 'pagination.lastPageUrl' },
            { 'name' => 'pagination.lastPageText' },
            { 'name' => 'pagination.isLastPage' },
            { 'name' => 'pagination.nextPage' },
            { 'name' => 'pagination.nextPageUrl' },
            { 'name' => 'pagination.nextPageText' },
            { 'name' => 'pagination.previousPage' },
            { 'name' => 'pagination.previousPageUrl' },
            { 'name' => 'pagination.previousPageText' },
            { 'name' => 'pagination.pageNumber' },
            { 'name' => 'pagination.pageCount' },
            { 'name' => 'pagination.pageCount.isMultiple' },
            { 'name' => 'pagination.pageList', },
            {   'name'      => 'pagination.pageLoop',
                'variables' => [ { 'name' => 'pagination.url' }, { 'name' => 'pagination.text' }, { 'name' => 'pagination.range' }, { 'name' => 'pagination.activePage' }, ]
            },
            { 'name' => 'pagination.pageList.upTo20' },
            {   'name'      => 'pagination.pageLoop.upTo20',
                'variables' => [ { 'name' => 'pagination.url' }, { 'name' => 'pagination.text' }, { 'name' => 'pagination.range' }, { 'name' => 'pagination.activePage' }, ]
            },
            { 'name' => 'pagination.pageList.upTo10' },
            {   'name'      => 'pagination.pageLoop.upTo10',
                'variables' => [ { 'name' => 'pagination.url' }, { 'name' => 'pagination.text' }, { 'name' => 'pagination.range' }, { 'name' => 'pagination.activePage' }, ]
            }
        ],
        fields  => [],
        related => [
            {   tag       => 'wobject template',
                namespace => 'Asset_Wobject'
            }
        ]
    },

    'account options' => {
        title     => 'account options template variables',
        body      => '',
        variables => [
            {
                'name' => 'account.options',
                'variables' => [
                    { 'name' => 'options.display' }
                ],
            },
        ],
    },

};

1;
