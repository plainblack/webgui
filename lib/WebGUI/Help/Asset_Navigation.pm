package WebGUI::Help::Asset_Navigation;

our $HELP = {
	'navigation add/edit' => {
		title => '1098',
		body => '1093',
		fields => [
		],
		related => [
			{
				tag => 'navigation template',
				namespace => 'Asset_Navigation'
			},
			{
				tag => 'navigation manage',
				namespace => 'Asset_Navigation'
			},
			{
				tag => 'template add/edit',
				namespace => 'Asset_Template'
			}
		]
	},
	'navigation template' => {
		title => '1096',
		body => '1097',
		fields => [
		],
		related => [
			{
				tag => 'navigation add/edit',
				namespace => 'Asset_Navigation'
			},
			{
				tag => 'navigation manage',
				namespace => 'Asset_Navigation'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			}
		]
	},
	'navigation manage' => {
		title => '1094',
		body => '1095',
		fields => [
		],
		related => [
			{
				tag => 'navigation template',
				namespace => 'Asset_Navigation'
			},
			{
				tag => 'navigation add/edit',
				namespace => 'Asset_Navigation'
			}
		]
	},
};

1;
