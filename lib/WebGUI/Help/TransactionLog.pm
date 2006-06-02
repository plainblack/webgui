package WebGUI::Help::TransactionLog;

our $HELP = {
	'purchase history' => {
		title => 'help purchase history template title',
		body => 'help purchase history template body',
		fields => [
		],
		variables => [
		          {
		            'name' => 'errorMessage'
		          },
		          {
		            'name' => 'historyLoop',
		            'variables' => [
		                             {
		                               'name' => 'amount',
		                               'description' => 'amount.template'
		                             },
		                             {
		                               'name' => 'recurring'
		                             },
		                             {
		                               'name' => 'canCancel'
		                             },
		                             {
		                               'name' => 'cancelUrl'
		                             },
		                             {
		                               'name' => 'initDate'
		                             },
		                             {
		                               'name' => 'completionDate'
		                             },
		                             {
		                               'name' => 'status',
		                               'description' => 'status.template'
		                             },
		                             {
		                               'name' => 'lastPayedTerm'
		                             },
		                             {
		                               'name' => 'gateway'
		                             },
		                             {
		                               'name' => 'gatewayId'
		                             },
		                             {
		                               'name' => 'transactionId'
		                             },
		                             {
		                               'name' => 'userId'
		                             },
		                             {
		                               'name' => 'itemLoop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'amount',
		                                                  'description' => 'amount.template'
		                                                },
		                                                {
		                                                  'name' => 'itemName'
		                                                },
		                                                {
		                                                  'name' => 'itemId'
		                                                },
		                                                {
		                                                  'name' => 'itemType'
		                                                },
		                                                {
		                                                  'name' => 'quantity'
		                                                }
		                                              ]
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

