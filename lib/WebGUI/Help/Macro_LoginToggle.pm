package WebGUI::Help::Macro_LoginToggle;

our $HELP = {

    'login toggle' => {
		isa => [
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
		],
		title => 'login toggle title',
		body => '',
		variables => [
              {
                'name' => 'toggle.url'
              },
              {
                'name' => 'toggle.text'
              },
		],
		fields => [
		],
		related => [
		]
	},

};

1;
