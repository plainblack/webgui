package WebGUI::Help::Asset_SyndicatedContent;

our $HELP = {
	'syndicated content add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'syndicated content template',
				namespace => 'Asset_SyndicatedContent'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		]
	},
	'syndicated content template' => {
		title => '72',
		body => '73',
		related => [
			{
				tag => 'syndicated content add/edit',
				namespace => 'Asset_SyndicatedContent'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
};

1;
