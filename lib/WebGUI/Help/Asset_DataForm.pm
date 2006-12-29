package WebGUI::Help::Asset_DataForm;

our $HELP = {
	'data form add/edit' => {
		title => '61',
		body => '71',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject add/edit"
			},
		],
		fields => [
                        {
                                title => '82',
                                description => '82 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '80',
                                description => '80 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '81',
                                description => '81 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '87',
                                description => '87 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => 'defaultView',
                                description => 'defaultView description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '16',
                                description => '16 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '74',
                                description => '74 description',
                                namespace => 'Asset_DataForm',
                        },
			{
				title => 'mail attachments',
				description => 'mail attachments description',
				namespace => 'Asset_DataForm',
			},
                        {
                                title => '744',
                                description => '744 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '76',
                                description => '76 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '105',
                                description => '105 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '86',
                                description => '86 description',
                                namespace => 'Asset_DataForm',
                        },
                ],
		related => [
			{
				tag => 'data form fields add/edit',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'data form list template',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'data form template',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			},
		]
	},

	'data form fields add/edit' => {
		title => '62',
		body => '72',
		fields => [
                        {
                                title => '104',
                                description => '104 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '77',
                                description => '77 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '79',
                                description => '79 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '21',
                                description => '21 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '22',
                                description => '22 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '23',
                                description => '23 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '8',
                                description => '8 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '27',
                                description => '27 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => 'editField vertical label',
                                description => 'editField vertical label description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => 'editField extras label',
                                description => 'editField extras label description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '24',
                                description => '24 description',
                                namespace => 'Asset_DataForm',
                        },
                        {
                                title => '25',
                                description => '25 description',
                                namespace => 'Asset_DataForm',
                        },
		],
		related => [
			{
				tag => 'data form template',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'data form add/edit',
				namespace => 'Asset_DataForm'
			}
		]
	},

	'data form template' => {
		title => '82',
		body => '83',
		fields => [
		],
		isa => [
			{
				namespace => "Asset_DataForm",
				tag => "data form asset template variables"
			},
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
			{
				tag => 'wobject template variables',
				namespace => 'Asset_Wobject'
			}
		],
		variables => [
		          {
		            'name' => 'canEdit'
		          },
		          {
		            'name' => 'entryId'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.start'
		          },
		          {
		            'name' => 'entryList.url'
		          },
		          {
		            'name' => 'entryList.label'
		          },
		          {
		            'name' => 'export.tab.url'
		          },
		          {
		            'name' => 'export.tab.label'
		          },
		          {
		            'name' => 'delete.url'
		          },
		          {
		            'name' => 'delete.label'
		          },
		          {
		            'name' => 'javascript.confirmation.deleteOne',
		          },
		          {
		            'name' => 'back.url'
		          },
		          {
		            'name' => 'back.label'
		          },
		          {
		            'name' => 'addField.url'
		          },
		          {
		            'name' => 'addField.label'
		          },
		          {
		            'name' => 'addTab.url'
		          },
		          {
		            'name' => 'addTab.label'
		          },
		          {
		            'name' => 'hasEntries',
		          },
		          {
		            'name' => 'deleteAllEntries.url',
		          },
		          {
		            'name' => 'deleteAllEntries.label',
		          },
		          {
		            'name' => 'javascript.confirmation.deleteAll',
		          },
		          {
		            'required' => 1,
		            'name' => 'tab.init'
		          },
		          {
		            'name' => 'username'
		          },
		          {
		            'name' => 'userId'
		          },
		          {
		            'name' => 'date'
		          },
		          {
		            'name' => 'epoch'
		          },
		          {
		            'name' => 'ipAddress'
		          },
		          {
		            'name' => 'edit.url'
		          },
		          {
		            'name' => 'error_loop',
		            'variables' => [
		                             {
		                               'name' => 'error.message'
		                             }
		                           ]
		          },
		          {
		            'name' => 'tab_loop',
		            'variables' => [
		                             {
		                               'required' => 1,
		                               'name' => 'tab.start'
		                             },
		                             {
		                               'name' => 'tab.sequence'
		                             },
		                             {
		                               'name' => 'tab.label'
		                             },
		                             {
		                               'name' => 'tab.tid'
		                             },
		                             {
		                               'name' => 'tab.subtext'
		                             },
		                             {
		                               'required' => 1,
		                               'name' => 'tab.controls'
		                             },
		                             {
		                               'required' => 1,
		                               'name' => 'tab.field_loop',
		                               'variables' => [
		                                                {
		                                                  'required' => 1,
		                                                  'name' => 'tab.field.form'
		                                                },
		                                                {
		                                                  'name' => 'tab.field.name'
		                                                },
		                                                {
		                                                  'name' => 'tab.field.tid'
		                                                },
		                                                {
		                                                  'name' => 'tab.field.value'
		                                                },
		                                                {
		                                                  'name' => 'tab.field.label'
		                                                },
		                                                {
		                                                  'name' => 'tab.field.isHidden'
		                                                },
		                                                {
		                                                  'name' => 'tab.field.isDisplayed'
		                                                },
		                                                {
		                                                  'name' => 'tab.field.isRequired'
		                                                },
		                                                {
		                                                  'name' => 'tab.field.isMailField'
		                                                },
		                                                {
		                                                  'name' => 'tab.field.subtext'
		                                                },
		                                                {
		                                                  'name' => 'tab.field.controls'
		                                                }
		                                              ]
		                             },
		                             {
		                               'required' => 1,
		                               'name' => 'tab.end'
		                             }
		                           ]
		          },
		          {
		            'name' => 'field_loop',
		            'variables' => [
		                             {
		                               'required' => 1,
		                               'name' => 'field.form'
		                             },
		                             {
		                               'name' => 'field.name'
		                             },
		                             {
		                               'name' => 'field.tid'
		                             },
		                             {
		                               'name' => 'field.inTab'
		                             },
		                             {
		                               'name' => 'field.value'
		                             },
		                             {
		                               'name' => 'field.label'
		                             },
		                             {
		                               'name' => 'field.isHidden'
		                             },
		                             {
		                               'name' => 'field.isDisplayed'
		                             },
		                             {
		                               'name' => 'field.isRequired'
		                             },
		                             {
		                               'name' => 'field.isMailField'
		                             },
		                             {
		                               'name' => 'field.subtext'
		                             },
		                             {
		                               'name' => 'field.controls'
		                             }
		                           ]
		          },
		          {
		            'required' => 1,
		            'name' => 'form.send'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.save'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.end'
		          }
		],
		related => [
			{
				tag => 'data form list template',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'data form add/edit',
				namespace => 'Asset_DataForm'
			},
		]
	},

	'data form list template' => {
		title => '88',
		body => '89',
		isa => [
			{
				namespace => "Asset_DataForm",
				tag => "data form asset template variables"
			},
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
			{
				tag => 'wobject template variables',
				namespace => 'Asset_Wobject'
			}
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'back.url',
		          },
		          {
		            'name' => 'back.label',
		          },
		          {
		            'name' => 'deleteAllEntries.url',
		          },
		          {
		            'name' => 'deleteAllEntries.label',
		          },
		          {
		            'name' => 'javascript.confirmation.deleteAll',
		          },
		          {
		            'name' => 'canEdit',
		          },
		          {
		            'name' => 'hasEntries',
		          },
		          {
		            'name' => 'export.tab.url',
		          },
		          {
		            'name' => 'export.tab.label',
		          },
		          {
		            'name' => 'addField.url',
		          },
		          {
		            'name' => 'addField.label',
		          },
		          {
		            'name' => 'addTab.url',
		          },
		          {
		            'name' => 'addTab.label',
		          },
		          {
		            'name' => 'field_loop',
		            'variables' => [
		                             {
		                               'name' => 'field.name',
		                             },
		                             {
		                               'name' => 'field.label',
		                             },
		                             {
		                               'name' => 'field.id'
		                             },
		                             {
		                               'name' => 'field.isMailField',
		                             },
		                             {
		                               'name' => 'field.type'
		                             }
		                           ],
		          },
		          {
		            'name' => 'record_loop',
		            'variables' => [
		                             {
		                               'name' => 'record.entryId'
		                             },
		                             {
		                               'name' => 'record.ipAddress'
		                             },
		                             {
		                               'name' => 'record.edit.url'
		                             },
		                             {
		                               'name' => 'record.edit.icon'
		                             },
		                             {
		                               'name' => 'record.delete.url'
		                             },
		                             {
		                               'name' => 'record.delete.icon'
		                             },
		                             {
		                               'name' => 'record.username'
		                             },
		                             {
		                               'name' => 'record.userId'
		                             },
		                             {
		                               'name' => 'record.submissionDate.epoch'
		                             },
		                             {
		                               'name' => 'record.submissionDate.human'
		                             },
		                             {
		                               'name' => 'record.data_loop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'record.data.name'
		                                                },
		                                                {
		                                                  'name' => 'record.data.label'
		                                                },
		                                                {
		                                                  'name' => 'record.data.value'
		                                                },
		                                                {
		                                                  'name' => 'record.data.isMailField'
		                                                }
		                                              ]
		                             }
		                           ]
		          }
		],
		related => [
			{
				tag => 'data form template',
				namespace => 'Asset_DataForm'
			},
			{
				tag => 'data form add/edit',
				namespace => 'Asset_DataForm'
			},
		]
	},

	'data form asset template variables' => {
		title => 'data form asset template variables title',
		body => 'data form asset template variables body',
		isa => [
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'templateId',
		          },
		          {
		            'name' => 'emailTemplateId',
		          },
		          {
		            'name' => 'acknowlegementTemplateId',
		          },
		          {
		            'name' => 'listTemplateId',
		          },
		          {
		            'name' => 'acknowledgement',
		            'description' => 'acknowledgement var desc',
		          },
		          {
		            'name' => 'mailAttachments',
		          },
		          {
		            'name' => 'groupToViewEntries',
		          },
		],
		related => [
		]
	},
};

1;
