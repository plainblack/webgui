package WebGUI::Help::Navigation;

our $HELP = {
	'navigation add/edit' => {
		title => '1098',
		body => '1093',
		related => [
			{
				tag => 'navigation template',
				namespace => 'Navigation'
			},
			{
				tag => 'navigation manage',
				namespace => 'Navigation'
			},
			{
				tag => 'template add/edit',
				namespace => 'Template'
			}
		]
	},
	'navigation template' => {
		title => '1096',
		body => '1097',
		related => [
			{
				tag => 'navigation add/edit',
				namespace => 'Navigation'
			},
			{
				tag => 'navigation manage',
				namespace => 'Navigation'
			},
			{
				tag => 'template language',
				namespace => 'Template'
			}
		]
	},
	'navigation manage' => {
		title => '1094',
		body => '1095',
		related => [
			{
				tag => 'navigation template',
				namespace => 'Navigation'
			},
			{
				tag => 'navigation add/edit',
				namespace => 'Navigation'
			}
		]
	},
};

1;
