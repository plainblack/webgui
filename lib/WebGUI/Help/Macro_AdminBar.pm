package WebGUI::Help::Macro_AdminBar;

our $HELP = {

    'admin bar' => {
		title => 'admin bar title',
		body => '',
		fields => [
		],
		variables => [
		          {
		            'name' => 'adminbar_loop',
		            'variables' => [
		                             {
		                               'name' => 'label'
		                             },
		                             {
		                               'name' => 'name'
		                             },
		                             {
		                               'name' => 'items',
		                               'variables' => [
		                                                {
		                                                  'name' => 'title'
		                                                },
		                                                {
		                                                  'name' => 'url'
		                                                },
		                                                {
		                                                  'name' => 'icon'
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
