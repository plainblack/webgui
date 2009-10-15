package WebGUI::Help::Asset_DataForm;
use strict;

our $HELP = {
    'data form template' => {
        title  => '82',
        body   => '',
        fields => [],
        isa    => [
            {   namespace => "Asset_DataForm",
                tag       => "data form asset template variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
        ],
        variables => [
            { 'name' => 'canEdit' },
            { 'name' => 'canViewEntries' },
            { 'name' => 'entryId' },
            {   'required' => 1,
                'name'     => 'form.start'
            },
            { 'name' => 'entryList.url' },
            { 'name' => 'entryList.label' },
            { 'name' => 'export.tab.url' },
            { 'name' => 'export.tab.label' },
            { 'name' => 'delete.url' },
            { 'name' => 'delete.label' },
            { 'name' => 'javascript.confirmation.deleteOne', },
            { 'name' => 'back.url' },
            { 'name' => 'back.label' },
            { 'name' => 'addField.url' },
            { 'name' => 'addField.label' },
            { 'name' => 'addTab.url' },
            { 'name' => 'addTab.label' },
            { 'name' => 'hasEntries', },
            { 'name' => 'deleteAllEntries.url', },
            { 'name' => 'deleteAllEntries.label', },
            { 'name' => 'javascript.confirmation.deleteAll', },
            {   'required' => 1,
                'name'     => 'tab.init'
            },
            { 'name' => 'username' },
            { 'name' => 'userId' },
            { 'name' => 'date' },
            { 'name' => 'epoch' },
            { 'name' => 'ipAddress' },
            { 'name' => 'edit.url' },
            {   'name'      => 'error_loop',
                'variables' => [ { 'name' => 'error.message' } ]
            },
            {   'name'      => 'tab_loop',
                'variables' => [
                    {   'required' => 1,
                        'name'     => 'tab.start'
                    },
                    { 'name' => 'tab.sequence' },
                    { 'name' => 'tab.label' },
                    { 'name' => 'tab.tid' },
                    { 'name' => 'tab.subtext' },
                    {   'required' => 1,
                        'name'     => 'tab.controls'
                    },
                    {   'required'  => 1,
                        'name'      => 'tab.field_loop',
                        'variables' => [
                            {   'required' => 1,
                                'name'     => 'tab.field.form'
                            },
                            { 'name' => 'tab.field.name' },
                            { 'name' => 'tab.field.tid' },
                            { 'name' => 'tab.field.value' },
                            { 'name' => 'tab.field.label' },
                            { 'name' => 'tab.field.isHidden' },
                            { 'name' => 'tab.field.isDisplayed' },
                            { 'name' => 'tab.field.isRequired' },
                            { 'name' => 'tab.field.isMailField' },
                            { 'name' => 'tab.field.subtext' },
                            { 'name' => 'tab.field.controls' }
                        ]
                    },
                    {   'required' => 1,
                        'name'     => 'tab.end'
                    }
                ]
            },
            {   'name'      => 'field_loop',
                'variables' => [
                    {   'required' => 1,
                        'name'     => 'field.form'
                    },
                    { 'name' => 'field.name' },
                    { 'name' => 'field.tid' },
                    { 'name' => 'field.inTab' },
                    { 'name' => 'field.value' },
                    { 'name' => 'field.label' },
                    { 'name' => 'field.isHidden' },
                    { 'name' => 'field.isDisplayed' },
                    { 'name' => 'field.isRequired' },
                    { 'name' => 'field.isMailField' },
                    { 'name' => 'field.subtext' },
                    { 'name' => 'field.controls' }
                ]
            },
            {   'required' => 1,
                'name'     => 'form.send'
            },
            {   'required' => 1,
                'name'     => 'form.save'
            },
            {   'required' => 1,
                'name'     => 'form.end'
            },
            {
                name        => 'useCaptcha',
                required    => 1,
                description => 'helpvar useCaptcha',
            },
            {
                name        => 'form_captcha',
                required    => 1,
                description => 'helpvar form.captcha',
            },

        ],
        related => [
            {   tag       => 'data form list template',
                namespace => 'Asset_DataForm'
            },
        ]
    },

    'data form list template' => {
        title => '88',
        body  => '',
        isa   => [
            {   namespace => "Asset_DataForm",
                tag       => "data form asset template variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "WebGUI",
                tag       => "pagination template variables"
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'back.url', },
            { 'name' => 'back.label', },
            { 'name' => 'deleteAllEntries.url', },
            { 'name' => 'deleteAllEntries.label', },
            { 'name' => 'javascript.confirmation.deleteAll', },
            { 'name' => 'canEdit', },
            { 'name' => 'canViewEntries' },
            { 'name' => 'hasEntries', },
            { 'name' => 'export.tab.url', },
            { 'name' => 'export.tab.label', },
            { 'name' => 'addField.url', },
            { 'name' => 'addField.label', },
            { 'name' => 'addTab.url', },
            { 'name' => 'addTab.label', },
            {   'name'      => 'field_loop',
                'variables' => [
                    { 'name' => 'field.name', },
                    { 'name' => 'field.label', },
                    { 'name' => 'field.id' },
                    { 'name' => 'field.isMailField', },
                    { 'name' => 'field.type' }
                ],
            },
            {   'name'      => 'record_loop',
                'variables' => [
                    { 'name' => 'record.entryId' },
                    { 'name' => 'record.ipAddress' },
                    { 'name' => 'record.edit.url' },
                    { 'name' => 'record.edit.icon' },
                    { 'name' => 'record.delete.url' },
                    { 'name' => 'record.delete.icon' },
                    { 'name' => 'record.username' },
                    { 'name' => 'record.userId' },
                    { 'name' => 'record.submissionDate.epoch' },
                    { 'name' => 'record.submissionDate.human' },
                    { 'name' => 'record.noloop.', description => 'help record.noloop', },
                    {   'name'      => 'record.data_loop',
                        'variables' => [
                            { 'name' => 'record.data.name' },
                            { 'name' => 'record.data.label' },
                            { 'name' => 'record.data.value' },
                            { 'name' => 'record.data.isMailField' },
                            { 'name' => 'record_data_type' },
                        ]
                    }
                ]
            }
        ],
        related => [
            {   tag       => 'data form template',
                namespace => 'Asset_DataForm'
            },
        ]
    },

    'data form asset template variables' => {
        private => 1,
        title   => 'data form asset template variables title',
        body    => 'data form asset template variables body',
        isa     => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables"
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'templateId', },
            {   'name'        => 'acknowledgement',
                'description' => 'acknowledgement var desc',
            },
            { 'name' => 'emailTemplateId', },
            { 'name' => 'acknowlegementTemplateId', },
            { 'name' => 'listTemplateId', },
            { 'name' => 'mailData', },
            { 'name' => 'mailAttachments', },
            {   'name'        => 'defaultView',
                'description' => 'defaultView var desc',
            },
            { 'name' => 'groupToViewEntries', },
        ],
        related => []
    },
};

1;
