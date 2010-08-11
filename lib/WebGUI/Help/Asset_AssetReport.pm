package WebGUI::Help::Asset_AssetReport;
use strict;

our $HELP = {

    'asset report template' => {
        title => 'help_asset_report_template',
        body  => 'help_asset_report_body',
        isa     => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables",
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
            {   tag       => 'pagination template variables',
                namespace => 'WebGUI'
            },
        ],
        variables => [
            {   'name'      => 'asset_loop',
                'variables' => [
                    {   'name'          => 'asset_info'  },
                ],
            },
        ],
        related => [],
    },
};

1;
