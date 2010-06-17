package WebGUI::Help::Asset_AdSku;

use strict; 

our $HELP = { 

    'view template' => {
        title => 'view template title',
        body => '',
        isa => [
        ],
        variables => [
            { name => 'formHeader',          },
            { name => 'formFooter',          },
            { name => 'formSubmit',          },
            { name => 'error_msg',           },
            { name => 'hasAddedToCart',      },
            { name => 'continueShoppingUrl', },
            { name => 'manageLink',          },
            { name => 'adSkuTitle',          },
            { name => 'adSkuDescription',    },
            { name => 'formTitle',    },
            { name => 'formLink',    },
            { name => 'formImage',    },
            { name => 'formClicks',    },
            { name => 'formImpressions',    },
            { name => 'formAdId',    },
            { name => 'clickPrice',    },
            { name => 'impressionPrice',    },
            { name => 'minimumClicks',    },
            { name => 'minimumImpressions',    },
            { name => 'clickDiscount',    },
            { name => 'impressionDiscount',    },
        ],
        related => [
        ],
    },

    'manage template' => {
        title => 'manage template title',
        body => '',
        isa => [
        ],
        variables => [
            {
                name      => 'myAds',
                variables => [
                    { name => 'rowTitle',       },
                    { name => 'rowClicks',      },
                    { name => 'rowImpressions', },
                    { name => 'rowRenewLink',   },
                ],
            },
        ],
        related => [
        ],
    },

};

1;
#vim:ft=perl
