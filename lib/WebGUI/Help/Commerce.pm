package WebGUI::Help::Commerce;

our $HELP = {
	'commerce manage' => {
		title => 'help manage commerce title',
		body => 'help manage commerce body',
		fields => [
			{
                                title => 'confirm checkout template',
                                description => 'confirm checkout template description',
                                namespace => 'Commerce',
                        },
                        {
                                title => 'transaction error template',
                                description => 'transaction error template description',
                                namespace => 'Commerce',
                        },
                        {
                                title => 'checkout canceled template',
                                description => 'checkout canceled template description',
                                namespace => 'Commerce',
                        },
                        {
                                title => 'checkout select payment template',
                                description => 'checkout select payment template description',
                                namespace => 'Commerce',
                        },
                        {
                                title => 'checkout select shipping template',
                                description => 'checkout select shipping template description',
                                namespace => 'Commerce',
                        },
                        {
                                title => 'view shopping cart template',
                                description => 'view shopping cart template description',
                                namespace => 'Commerce',
                        },
                        {
                                title => 'daily report email',
                                description => 'daily report email description',
                                namespace => 'Commerce',
                        },
                        {
                                title => 'payment plugin',
                                description => 'payment plugin description',
                                namespace => 'Commerce',
                        },
                        {
                                title => 'shipping plugin label',
                                description => 'shipping plugin label description',
                                namespace => 'Commerce',
                        },
                        {
                                title => 'enable sales tax',
                                description => 'enable sales tax description',
                                namespace => 'Commerce',
                        },
		],
		related => [
		]
	},

	'list pending transactions' => {
		title => 'help manage pending transactions title',
		body => 'help manage pending transactions body',
		fields => [
		],
		related => [
		]
	},

	'cancel template' => {
		title => 'help cancel checkout template title',
		body => 'help cancel checkout template body',
		variables => [
		          {
		            'name' => 'message'
		          }
		],
		fields => [
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},

	'confirm template' => {
		title => 'help checkout confirm template title',
		body => 'help checkout confirm template body',
		fields => [
		],
		variables => [
		          {
		            'name' => 'title'
		          },
		          {
		            'name' => 'normalItems'
		          },
		          {
		            'name' => 'normalItemLoop',
		            'variables' => [
		                             {
		                               'name' => 'quantity'
		                             },
		                             {
		                               'name' => 'period'
		                             },
		                             {
		                               'name' => 'name'
		                             },
		                             {
		                               'name' => 'salesTax'
		                             },
		                             {
		                               'name' => 'price'
		                             },
		                             {
		                               'name' => 'totalPrice'
		                             }
		                           ]
		          },
		          {
		            'name' => 'recurringItems'
		          },
		          {
		            'name' => 'recurringItemLoop'
		          },
		          {
		            'name' => 'form'
		          },
		          {
		            'name' => 'salesTaxRate'
		          },
		          {
		            'name' => 'totalSalesTax'
		          },
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		],
	},

	'error template' => {
		title => 'help checkout error template title',
		body => 'help checkout error template body',
		fields => [
		],
		variables => [
		          {
		            'name' => 'title',
		          },
		          {
		            'name' => 'statusExplanation'
		          },
		          {
		            'name' => 'resultLoop',
		            'variables' => [
		                             {
		                               'name' => 'purchaseDescription'
		                             },
		                             {
		                               'name' => 'status'
		                             },
		                             {
		                               'name' => 'error'
		                             },
		                             {
		                               'name' => 'errorCode'
		                             }
		                           ]
		          }
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},

	'select payment gateway template' => {
		title => 'help select payment template title',
		body => 'help select payment template body',
		fields => [
		],
		variables => [
		          {
		            'name' => 'message',
		            'description' => 'gateway message'
		          },
		          {
		            'name' => 'pluginsAvailable'
		          },
		          {
		            'name' => 'noPluginsMessage'
		          },
		          {
		            'name' => 'formHeader'
		          },
		          {
		            'name' => 'formFooter'
		          },
		          {
		            'name' => 'formSubmit'
		          },
		          {
		            'name' => 'pluginLoop',
		            'variables' => [
		                             {
		                               'name' => 'name',
		                               'description' => 'plugin name'
		                             },
		                             {
		                               'name' => 'namespace'
		                             },
		                             {
		                               'name' => 'formElement'
		                             }
		                           ]
		          }
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},

};

1;
