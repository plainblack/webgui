package WebGUI::Help::Asset_Dashboard;
use strict;

our $HELP = {

    'dashboard template' => {
        title => 'Dashboard Template Variables',
        isa   => [
            {   namespace => "Asset_Dashboard",
                tag       => "dashboard asset template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
        ],
        fields    => [],
        variables => [
            {   name      => 'dragger.init' },
            {   name      => 'fullUrl' },
            {   name      => 'canEdit' },
            {   name      => 'positionN_loop',
                variables => [
                    { 'name' => 'id' },
                    { 'name' => 'content' },
                    { 'name' => 'dashletTitle' },
                    { 'name' => 'shortcutUrl' },
                    { 'name' => 'dashletUrl' },
                    { 'name' => 'canDelete' },
                    { 'name' => 'canMove' },
                    { 'name' => 'canPersonalize' },
                    { 'name' => 'showReloadIcon' },
                    { 'name' => 'canEditUserPrefs' },
                    { 'name' => 'editFormUrl' },
                ]
            },
        ],
        related => []
    },

    'dashboard asset template variables' => {
        private => 1,
        title   => 'dashboard asset template variables title',
        isa     => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables"
            },
        ],
        fields    => [],
        variables => [
            { name => 'templateId' },
            { name => 'adminsGroupId' },
            { name => 'usersGroupId' },
            { name => 'isInitialized' },
        ],
        related => []
    },

};

1;
