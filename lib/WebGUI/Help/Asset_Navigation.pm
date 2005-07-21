package WebGUI::Help::Asset_Navigation;

our $HELP = {
	'navigation add/edit' => {
		title => '1098',
		body => '1093',
		fields => [
                        {
                                title => '1096',
                                description => '1096 description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => 'Start Point Type',
                                description => 'Start Point Type description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => 'Start Point',
                                description => 'Start Point description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => 'Ancestor End Point',
                                description => 'Ancestor End Point description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => 'Relatives To Include',
                                description => 'Relatives To Include description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => 'Descendant End Point',
                                description => 'Descendant End Point description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => '30',
                                description => '30 description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => '31',
                                description => '31 description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => '32',
                                description => '32 description',
                                namespace => 'Asset_Navigation',
                        },
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
