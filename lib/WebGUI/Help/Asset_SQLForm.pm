package WebGUI::Help::Asset_SQLForm;
use strict

our $HELP = {
    'search record template' => {
        title => 'search template help title',
        body  => '',
        isa   => [
            {   namespace => "Asset_SQLForm",
                tag       => "sql form asset template variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
        ],
        variables => [
            { 'name' => 'showFieldsDefined' },
            { 'name' => 'searchForm' },
            { 'name' => 'searchFormHeader' },
            { 'name' => 'searchFormTrash.label' },
            { 'name' => 'searchFormTrash.form' },
            { 'name' => 'searchFormMode.label' },
            { 'name' => 'searchFormMode.form' },
            { 'name' => 'searchFormQuery.label' },
            { 'name' => 'searchFormSearchIn.label' },
            { 'name' => 'searchFormSearchIn.form' },
            { 'name' => 'searchFormType.label' },
            { 'name' => 'searchFormType.form' },
            { 'name' => 'searchFormFooter' },
            { 'name' => 'searchFormSubmit' },
            { 'name' => 'searchFormJavascript' },
            {   'name'      => 'searchForm.field_loop',
                'variables' => [
                    { 'name' => 'field.label', },
                    { 'name' => 'field.conditionalForm' },
                    { 'name' => 'field.conditional' },
                    { 'name' => 'field.searchForm1' },
                    { 'name' => 'field.searchForm2' },
                    { 'name' => 'field.formValue1' },
                    { 'name' => 'field.formValue2' },
                    { 'name' => 'field.__FIELDNAME__.id' }
                ]
            },
            {   'name'      => 'headerLoop',
                'variables' => [
                    { 'name' => 'header.title' },
                    { 'name' => 'header.sort.url' },
                    { 'name' => 'header.sort.onThis' },
                    { 'name' => 'header.sort.ascending' }
                ]
            },
            { 'name' => 'searchResults.header' },
            { 'name' => 'searchResults.footer' },
            { 'name' => 'searchResults.actionButtons' },
            {   'name'      => 'searchResults.recordLoop',
                'variables' => [
                    { 'name' => 'record.id', },
                    { 'name' => 'record.controls', },
                    { 'name' => 'record.deletionDate' },
                    { 'name' => 'record.deletedBy' },
                    { 'name' => 'record.updateDate' },
                    { 'name' => 'record.updatedBy' },
                    {   'name'      => 'record.valueLoop',
                        'variables' => [
                            { 'name' => 'record.value' },
                            { 'name' => 'record.value.isFile' },
                            { 'name' => 'record.value.isImage' },
                            { 'name' => 'record.value.downloadUrl' }
                        ]
                    }
                ]
            },
            { 'name' => 'superSearch.url' },
            { 'name' => 'superSearch.label' },
            { 'name' => 'normalSearch.url' },
            { 'name' => 'normalSearch.label' },
            { 'name' => 'showMetaData' },
            { 'name' => 'managementLinks', },
            { 'name' => 'errorOccurred', },
            {   'name'      => 'errorLoop',
                'variables' => [ { 'name' => 'error.message', } ],
            }
        ],
        related => [],
    },

    'advanced search record template' => {
        title => 'advanced search template help title',
        body  => '',
        isa   => [
            {   namespace => "Asset_SQLForm",
                tag       => "sql form asset template variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
        ],
        variables => [
            {   'name'      => 'headerLoop',
                'variables' => [
                    { 'name' => 'header.title' },
                    { 'name' => 'header.sort.url' },
                    { 'name' => 'header.sort.onThis' },
                    { 'name' => 'header.sort.ascending' }
                ]
            },
            {   'name'      => 'searchResults.recordLoop',
                'variables' => [
                    { 'name' => 'record.id', },
                    { 'name' => 'record.controls', },
                    { 'name' => 'record.deletionDate' },
                    { 'name' => 'record.deletedBy' },
                    { 'name' => 'record.updateDate' },
                    { 'name' => 'record.updatedBy' },
                    {   'name'      => 'record.valueLoop',
                        'variables' => [
                            { 'name' => 'record.value' },
                            { 'name' => 'record.value.isFile' },
                            { 'name' => 'record.value.isImage' },
                            { 'name' => 'record.value.downloadUrl' }
                        ]
                    }
                ]
            },
            { 'name' => 'superSearch.url' },
            { 'name' => 'superSearch.label' },
            { 'name' => 'normalSearch.url' },
            { 'name' => 'normalSearch.label' },
            { 'name' => 'showFieldsDefined' },
            { 'name' => 'searchResults.header' },
            { 'name' => 'searchResults.footer' },
            { 'name' => 'searchResults.actionButtons' },
            { 'name' => 'showMetaData' },
            { 'name' => 'managementLinks', },
            { 'name' => 'searchFormTrash.label' },
            { 'name' => 'searchFormTrash.form' },
            { 'name' => 'searchFormType.label' },
            { 'name' => 'searchFormType.form' },
            { 'name' => 'searchFormHeader' },
            { 'name' => 'searchFormFooter' },
            { 'name' => 'searchFormSubmit' },
            { 'name' => 'searchFormJavascript' },
            {   'name'      => 'searchForm.field_loop',
                'variables' => [
                    { 'name' => 'field.label', },
                    { 'name' => 'field.conditionalForm' },
                    { 'name' => 'field.conditional' },
                    { 'name' => 'field.searchForm1' },
                    { 'name' => 'field.searchForm2' },
                    { 'name' => 'field.formValue1' },
                    { 'name' => 'field.formValue2' },
                    { 'name' => 'field.__FIELDNAME__.id' }
                ]
            },
            { 'name' => 'searchForm' },
        ],
        related => [],
    },

    'edit record template' => {
        title => 'edit template help title',
        body  => '',
        isa   => [
            {   namespace => "Asset_SQLForm",
                tag       => "sql form asset template variables"
            },
            {   namespace => "Asset_Template",
                tag       => "template variables"
            },
            {   namespace => "Asset",
                tag       => "asset template"
            },
        ],
        variables => [
            { 'name' => 'completeForm' },
            {   'name'      => 'formLoop',
                'variables' => [
                    { 'name' => 'field.label' }, { 'name' => 'field.formElement' }, { 'name' => 'field.value' }
                ]
            },
            { 'name' => 'field.__FIELDNAME__.formElement' },
            { 'name' => 'field.__FIELDNAME__.label' },
            { 'name' => 'field.__FIELDNAME__.value' },
            { 'name' => 'formHeader' },
            { 'name' => 'formFooter' },
            { 'name' => 'errorOccurred' },
            {   'name'      => 'errorLoop',
                'variables' => [ { 'name' => 'error.message' } ]
            },
            { 'name' => 'isNew' },
            { 'name' => 'viewHistory.url' },
            { 'name' => 'viewHistory.label' },
            { 'name' => 'managementLinks' },
            { 'name' => 'record.controls' }
        ],
        related => [],
    },

    'sql form asset template variables' => {
        private => 1,
        title   => 'sql form asset template variables title',
        body    => '',
        isa     => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables"
            },
        ],
        fields    => [],
        variables => [
            { 'name' => 'formId' },
            { 'name' => 'tableName' },
            { 'name' => 'maxFileSize' },
            { 'name' => 'sendMailTo' },
            { 'name' => 'showMetaData' },
            { 'name' => 'searchTemplateId' },
            { 'name' => 'editTemplateId' },
            { 'name' => 'submitGroupId' },
            { 'name' => 'alterGroupId' },
            { 'name' => 'databaseLinkId' },
            { 'name' => 'defaultView' },
        ],
        related => []
    },

};

1;

