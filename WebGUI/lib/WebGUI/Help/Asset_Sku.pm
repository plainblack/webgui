package WebGUI::Help::Asset_Sku;
use strict;

our $HELP = {

    'sku properties' => {
        private => 1,
        title   => 'sku properties title',
        body    => '',
        isa     => [
            {   tag       => 'asset template asset variables',
                namespace => 'Asset'
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'sku', description=>'sku help'},
            { 'name' => 'description', description=>'description help' },
            { 'name' => 'displayTitle', description=>'display title help' },
            { 'name' => 'overrideTaxRate', description=>'override tax rate help' },
            { 'name' => 'taxRateOverride', description=>'tax rate override help' },
            { 'name' => 'vendorId', description=>'vendor help' },
        ],
        related => []
    },

};

1;
