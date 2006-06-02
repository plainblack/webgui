package WebGUI::Help::Macro_SubscriptionItem;

our $HELP = {

        'subscription item' => {
		title => 'subscription item title',
		body => 'subscription item body',
		variables => [
		          {
		            'name' => 'url'
		          },
		          {
		            'name' => 'name'
		          },
		          {
		            'name' => 'description'
		          },
		          {
		            'name' => 'price'
		          }
		],
		fields => [
		],
		related => [
			{
				tag => 'macros using',
				namespace => 'Macros'
			},
		]
	},

};

1;
