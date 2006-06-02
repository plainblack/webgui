package WebGUI::Help::Macro_H_homeLink;

our $HELP = {

        'home link' => {
		title => 'home link title',
		body => 'home link body',
		variables => [
		          {
		            'name' => 'homeLink.url'
		          },
		          {
		            'name' => 'homeLink.text'
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
