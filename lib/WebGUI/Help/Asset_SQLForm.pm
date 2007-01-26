package WebGUI::Help::Asset_SQLForm;

our $HELP = {
	'sql form add/edit' => {
		title => 'edit sqlform',
		body => 'sqlform description',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject add/edit"
			},
		],
		fields => [
                        {
                                title => 'gef table name',
                                description => 'gef table name description',
                                namespace => 'Asset_SQLForm',
                        },
			
			{
				title => 'gef import table',
				description => 'gef import table description',
				namespace => 'Asset_SQLForm',
			},

			{
                                title => 'gef database to use',
                                description => 'gef database to use description',
                                namespace => 'Asset_SQLForm',
                        },
    
			{
                                title => 'gef max file size',
                                description => 'gef max file size description',
                                namespace => 'Asset_SQLForm',
                        },

			{
                                title => 'gef send mail to',
                                description => 'gef send mail to description',
                                namespace => 'Asset_SQLForm',
                        },

			{
                                title =>'gef show meta data',
                                description => 'gef show meta data description',
                                namespace => 'Asset_SQLForm',
                        },

			{
                                title => 'gef edit template',
                                description => 'gef edit template description',
                                namespace => 'Asset_SQLForm',
                        },

			{
                                title => 'gef search template',
                                description => 'gef search template description',
                                namespace => 'Asset_SQLForm',
                        },

                        {
				title => 'gef default view',
				description => 'gef default view description',
                                namespace => 'Asset_SQLForm',
                        },


 			{
                                title => 'gef submit group',
                                description => 'gef submit group description',
                                namespace => 'Asset_SQLForm',
                        },
		],
		related => [
			{
				tag => 'manage fields',
				namespace => 'Asset_SQLForm',
			},
			
			{
				tag => 'manage field types',
				namespace => 'Asset_SQLForm'
			},

			{
				tag => 'manage regexes',
				namespace => 'Asset_SQLForm',
			},
		],
	},

	'edit field' => {
		title => 'edit field title',
		body => 'edit field description',
		fields => [
 			{
                                title => 'ef field name',
                                description => 'ef field name description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef display name',
                                description => 'ef display name description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef field type',
                                description => 'ef field type description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef signed',
                                description => 'ef signed description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef autoincrement',
                                description => 'ef autoincrement description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef form height',
                                description => 'ef form height description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef max field length',
                                description => 'ef max field length description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef max field length',
                                description => 'ef max field length description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef regex',
                                description => 'ef regex description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef required',
                                description => 'ef required description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef read only',
                                description => 'ef read only description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef default value',
                                description => 'ef default value description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef field constraint',
                                description => 'ef field constraint description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef searchable',
                                description => 'ef searchable description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef fulltext',
                                description => 'ef fulltext description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef show in search',
                                description => 'ef show in search description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef summary length',
                                description => 'ef summary length description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef populate keys',
                                description => 'ef populate keys description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef populate values',
                                description => 'ef populate values description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef join selector',
                                description => 'ef join selector description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef join constraint',
                                description => 'ef join constraint description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef join keys',
                                description => 'ef join keys description',
                                namespace => 'Asset_SQLForm',
                        },

 			{
                                title => 'ef join values',
                                description => 'ef join values description',
                                namespace => 'Asset_SQLForm',
                        },

		],
		related => [
			{
				tag => 'manage field types',
				namespace => 'Asset_SQLForm'
			},

			{
				tag => 'manage regexes',
				namespace => 'Asset_SQLForm',
			},
		],
	},

	'edit field type' => {
		title => 'edit field type title',
		body => 'edit field type description',
		fields => [
 			{
                                title => 'eft db field type',
                                description => 'eft db field type description',
                                namespace => 'Asset_SQLForm',
                        },
 			{
                                title => 'eft form field type',
                                description => 'eft form field type description',
                                namespace => 'Asset_SQLForm',
                        },
		],
		related => [

			{
				tag => 'manage fields',
				namespace => 'Asset_SQLForm'
			},
		],
	},

	'edit regex' => {
		title =>'edit regex title',
		body => 'edit regex description',
		fields =>[ 
 			{
                                title => 'er name',
                                description => 'er name description',
                                namespace => 'Asset_SQLForm',
                        },
 			{
                                title => 'er regex',
                                description => 'er regex description',
                                namespace => 'Asset_SQLForm',
                        },
		],
		related => [
			{
				tag => 'manage fields',
				namespace => 'Asset_SQLForm'
			},
		],
	},

	'manage fields' => {
		title =>'manage fields title',
		body => 'edit field description',
		related => [
			{
				tag => 'edit field',
				namespace => 'Asset_SQLForm',
			},
			{
				tag => 'manage field types',
				namespace => 'Asset_SQLForm'
			},

			{
				tag => 'manage regexes',
				namespace => 'Asset_SQLForm',
			},
		],
	},
	
	'manage field types' => {
		title => 'manage field types title',
		body => 'edit field type description',
		related => [
			{
				tag => 'edit field type',
				namespace => 'Asset_SQLForm',
			},
			{
				tag => 'manage fields',
				namespace => 'Asset_SQLForm'
			},
		],
	},

	'manage regexes' => {
		title =>'manage regexes title',
		body => 'edit regex description',
		related => [
			{
				tag => 'edit regex',
				namespace => 'Asset_SQLForm',
			},
			{
				tag => 'manage fields',
				namespace => 'Asset_SQLForm'
			},
		],
	},

	'search record template' => {
		title => 'search template help title',
		body => 'search template help',
		isa => [
			{
				namespace => "Asset_SQLForm",
				tag => "sql form asset template variables"
			},
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
			{
				namespace => "Asset",
				tag => "asset template"
			},
		],
		variables => [
		          {
		            'name' => 'showFieldsDefined'
		          },
		          {
		            'name' => 'searchForm'
		          },
		          {
		            'name' => 'searchFormHeader'
		          },
		          {
		            'name' => 'searchFormTrash.label'
		          },
		          {
		            'name' => 'searchFormMode.label'
		          },
		          {
		            'name' => 'searchFormMode.form'
		          },
		          {
		            'name' => 'searchFormQuery.label'
		          },
		          {
		            'name' => 'searchFormSearchIn.label'
		          },
		          {
		            'name' => 'searchFormSearchIn.form'
		          },
		          {
		            'name' => 'searchFormType.label'
		          },
		          {
		            'name' => 'searchFormType.form'
		          },
		          {
		            'name' => 'searchFormFooter'
		          },
		          {
		            'name' => 'searchFormSubmit'
		          },
		          {
		            'name' => 'searchFormJavascript'
		          },
		          {
		            'name' => 'searchForm.field_loop',
		            'variables' => [
		                             {
		                               'name' => 'field.label',
		                             },
		                             {
		                               'name' => 'field.conditionalForm'
		                             },
		                             {
		                               'name' => 'field.conditional'
		                             },
		                             {
		                               'name' => 'field.searchForm1'
		                             },
		                             {
		                               'name' => 'field.searchForm2'
		                             },
		                             {
		                               'name' => 'field.formValue1'
		                             },
		                             {
		                               'name' => 'field.formValue2'
		                             },
		                             {
		                               'name' => 'field.__FIELDNAME__.id'
		                             }
		                           ]
		          },
		          {
		            'name' => 'headerLoop',
		            'variables' => [
		                             {
		                               'name' => 'header.title'
		                             },
		                             {
		                               'name' => 'header.sort.url'
		                             },
		                             {
		                               'name' => 'header.sort.onThis'
		                             },
		                             {
		                               'name' => 'header.sort.ascending'
		                             }
		                           ]
		          },
		          {
		            'name' => 'searchResults.header'
		          },
		          {
		            'name' => 'searchResults.footer'
		          },
		          {
		            'name' => 'searchResults.actionButtons'
		          },
		          {
		            'name' => 'searchResults.recordLoop',
		            'variables' => [
		                             {
		                               'name' => 'record.controls',
		                             },
		                             {
		                               'name' => 'record.deletionDate'
		                             },
		                             {
		                               'name' => 'record.deletedBy'
		                             },
		                             {
		                               'name' => 'record.updateDate'
		                             },
		                             {
		                               'name' => 'record.updatedBy'
		                             },
		                             {
		                               'name' => 'record.valueLoop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'record.value'
		                                                },
		                                                {
		                                                  'name' => 'record.value.isFile'
		                                                },
		                                                {
		                                                  'name' => 'record.value.isImage'
		                                                },
		                                                {
		                                                  'name' => 'record.value.downloadUrl'
		                                                }
		                                              ]
		                             }
		                           ]
		          },
		          {
		            'name' => 'superSearch.url'
		          },
		          {
		            'name' => 'superSearch.label'
		          },
		          {
		            'name' => 'normalSearch.url'
		          },
		          {
		            'name' => 'normalSearch.label'
		          },
		          {
		            'name' => 'showMetaData'
		          },
		          {
		            'name' => 'managementLinks',
		          },
		          {
		            'name' => 'errorOccurred',
		          },
		          {
		            'name' => 'errorLoop',
		            'variables' => [
		                             {
		                               'name' => 'error.message',
		                             }
		                           ],
		          }
		],
		related => [
			{
				tag => 'sql form add/edit',
				namespace => 'Asset_SQLForm',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		],
	},

	'edit record template' => {
		title => 'edit template help title',
		body => 'edit template help',
		isa => [
			{
				namespace => "Asset_SQLForm",
				tag => "sql form asset template variables"
			},
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
			{
				namespace => "Asset",
				tag => "asset template"
			},
		],
		variables => [
		          {
		            'name' => 'completeForm'
		          },
		          {
		            'name' => 'formLoop',
		            'variables' => [
		                             {
		                               'name' => 'field.label'
		                             },
		                             {
		                               'name' => 'field.formElement'
		                             },
		                             {
		                               'name' => 'field.value'
		                             }
		                           ]
		          },
		          {
		            'name' => 'field.__FIELDNAME__.formElement'
		          },
		          {
		            'name' => 'field.__FIELDNAME__.label'
		          },
		          {
		            'name' => 'field.__FIELDNAME__.value'
		          },
		          {
		            'name' => 'formHeader'
		          },
		          {
		            'name' => 'formFooter'
		          },
		          {
		            'name' => 'errorOccurred'
		          },
		          {
		            'name' => 'errorLoop',
		            'variables' => [
		                             {
		                               'name' => 'error.message'
		                             }
		                           ]
		          },
		          {
		            'name' => 'isNew'
		          },
		          {
		            'name' => 'viewHistory.url'
		          },
		          {
		            'name' => 'viewHistory.label'
		          },
		          {
		            'name' => 'managementLinks'
		          },
		          {
		            'name' => 'record.controls'
		          }
		],
		related => [
			{
				tag => 'sql form add/edit',
				namespace => 'Asset_SQLForm',
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template',
			},
		],
	},

	'sql form asset template variables' => {
		title => 'sql form asset template variables title',
		body => 'sql form asset template variables body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject template variables"
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'formId'
		          },
		          {
		            'name' => 'tableName'
		          },
		          {
		            'name' => 'maxFileSize'
		          },
		          {
		            'name' => 'sendMailTo'
		          },
		          {
		            'name' => 'showMetaData'
		          },
		          {
		            'name' => 'searchTemplateId'
		          },
		          {
		            'name' => 'editTemplateId'
		          },
		          {
		            'name' => 'submitGroupId'
		          },
		          {
		            'name' => 'alterGroupId'
		          },
		          {
		            'name' => 'databaseLinkId'
		          },
		          {
		            'name' => 'defaultView'
		          },
		        ],
		related => [
			{
				tag => 'article add/edit',
				namespace => 'Asset_Article'
			},
		]
	},

};

1;

