package WebGUI::Help::Asset_SQLReport;

our $HELP = {
	'sql report add/edit' => {
		title => '61',
		body => '71',
		fields => [
                        {
                                title => '72',
                                description => '72 description',
                                namespace => 'Asset_SQLReport',
                        },
                        {
                                title => '16',
                                description => '16 description',
                                namespace => 'Asset_SQLReport',
                        },
                        {
                                title => 'Placeholder Parameters',
                                description => 'Placeholder Parameters description',
                                namespace => 'Asset_SQLReport',
                        },
                        {
                                title => '15',
                                description => '15 description',
                                namespace => 'Asset_SQLReport',
                        },
			{
				title => 'Prequery statements',
				description => 'Prequery statements description',
				namespace => 'Asset_SQLReport',
			},
                        {
                                title => '4',
                                description => '4 description',
                                namespace => 'Asset_SQLReport',
                        },
                        {
                                title => '14',
                                description => '14 description',
                                namespace => 'Asset_SQLReport',
                        },
		],
		related => [
			{
				tag => 'sql report template',
				namespace => 'Asset_SQLReport'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'database links manage',
				namespace => 'WebGUI',
			},
		]
	},
	'sql report template' => {
		title => '72',
		body => '73',
		fields => [
		],
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'sql report add/edit',
				namespace => 'Asset_SQLReport'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
};

1;
