package WebGUI::i18n::English::Asset_AssetReport;

use strict; 

our $I18N = { 
	'assetName' => {
		message     => q{Asset Report},
		lastUpdated => 0,
	},

    'templateId label' => {
        message     => q{Asset Report Template},
        lastUpdated => 1226174617,
        context     => q{Label for asset edit screen},
    },

    'templateId description' => {
        message     => q{Select a template to display your asset report.},
        lastUpdated => 1226174619,
        context     => q{Hover help for asset edit screen},
    },
    
    'paginateAfter label' => {
        message     => q{Assets Per Page},
        lastUpdated => 1226174617,
        context     => q{Label for asset edit screen},
    },

    'paginateAfter description' => {
        message     => q{Choose the number of assets to display per page.},
        lastUpdated => 1226174619,
        context     => q{Hover help for asset edit screen},
    },

    'help_asset_report_template' => {
        message     => q{Asset Report Template Help},
        lastUpdate  => 1226174619,
        context     => q{Title for Asset Report Template Help},
    },

    'help_asset_report_template' => {
        message     => q{Asset Report Template Help},
        lastUpdate  => 1226174619,
        context     => q{Title for Asset Report Template Help},
    },

    'help_asset_report_body' => {
        message     => q{<p>The following template variables are available for asset report templates.</p>},
        lastUpdate  => 1226174619,
        context     => q{Body for Asset Report Template Help},
    },

    'asset_loop' => {
        message     => q|A loop containing the assets returned by this report.|,
        lastUpdated => 0,
        context     => q|Description of the asset_loop tmpl_loop for the template help.|
    },
    'asset_info' => {
        message     => q|General Asset information returned for the asset.  See WebGUI Asset Template Help for more details.|,
        lastUpdated => 0,
        context     => q|Description of the asset_loop tmpl_loop for the template help.|
    },
    'creation_date' => {
        message     => q{Creation Date},
        lastUpdate  => 1226174619,
        context     => q{Label for Creation Date inside template},
    },
    'created_by' => {
        message     => q{Created By},
        lastUpdate  => 1226174619,
        context     => q{Label for Created By inside template},
    },    

};

1;
