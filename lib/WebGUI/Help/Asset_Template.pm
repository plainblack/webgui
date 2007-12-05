package WebGUI::Help::Asset_Template;
use strict;

our $HELP = {

    'template variables' => {
        title     => 'template variable title',
        body      => '',
        fields    => [],
        variables => [
            { 'name' => 'webgui.version' },
            { 'name' => 'webgui.status' },
            { 'name' => 'session.user.username' },
            { 'name' => 'session.user.firstDayOfWeek' },
            { 'name' => 'session.config.extrasurl' },
            { 'name' => 'session.var.adminOn' },
            { 'name' => 'session.setting.companyName' },
            { 'name' => 'session.setting.anonymousRegistration' },
            { 'name' => 'session form variables' },
            { 'name' => 'session scratch variables' },
        ],
        related => []
    },

};

1;
