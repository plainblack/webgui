package WebGUI::Help::Asset_Map;
use strict;

our $HELP = {

    'view template' => {
        title => 'view template',
        body  => '',
        isa   => [
            {   namespace => 'Asset_Template',
                tag       => 'template variables'
            },
            {   namespace => 'Asset_Map',
                tag       => 'map asset template variables'
            },
        ],
        fields    => [],
        variables => [
            { name      => 'canAddPoint', },
            { name      => 'canEdit', },
            { name      => 'mapPoints', required => 1, },
            { name      => 'button_addPoint', required => 1, },
            { name      => 'button_setCenter', required => 1, },
            { name      => 'button_setCenter', selectPoint => 1, },
        ],
        related => []
    },

    'map asset template variables' => {
        private => 1,
        title   => 'map asset template variables',
        body    => '',
        isa     => [
            {   namespace => 'Asset',
                tag       => 'asset template asset variables'
            },
        ],
        fields    => [],
        variables => [
            { name      => 'groupIdAddPoint', },
            { name      => 'mapApiKey', },
            { name      => 'mapHeight', },
            { name      => 'mapWidth', },
            { name      => 'startLatitude', },
            { name      => 'startLongitude', },
            { name      => 'startZoom', },
            { name      => 'templateIdEditPoint', },
            { name      => 'templateIdView', },
            { name      => 'templateIdViewPoint', },
            { name      => 'workflowIdPoint', },
            { name      => 'canAddPoint', },
            { name      => 'canEdit', },
        ],
        related => []
    },

};

1;
