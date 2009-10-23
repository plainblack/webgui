package WebGUI::Help::Asset;
use strict;

our $HELP = {

    'asset template' => {
        title     => 'asset template title',
        body      => '',
        variables => [ { name => 'controls', }, ],
        fields    => [],
        related   => []
    },

    'asset template asset variables' => {
        title     => 'asset template asset var title',
        body      => '',
        variables => [
            { name => 'assetId',    },
            { name => 'assetIdHex', },
            { name => 'title',     },
            { name => 'menuTitle', },
            { name => 'url',       },
            { name => 'isHidden',  },
            { name => 'newWindow', },
            { name => 'encryptPage', },
            { name => 'ownerUserId', },
            { name => 'groupIdView', },
            { name => 'groupIdEdit', },
            { name => 'synopsis',      },
            { name => 'extraHeadTags', },
            { name => 'isPackage',   },
            { name => 'isPrototype', },
            { name => 'status',    },
            { name => 'assetSize', },
            { name => 'keywords',
              description => 'keywords template var' },
        ],
        fields  => [],
        related => []
    },

};

1;
