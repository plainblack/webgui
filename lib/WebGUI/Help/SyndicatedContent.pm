package WebGUI::Help::SyndicatedContent;

our $HELP = {
	'syndicated content add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'syndicated content template',
				namespace => 'SyndicatedContent'
			},
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
		]
	},
	'syndicated content template' => {
		title => '72',
		body => '73',
		related => [
			{
				tag => 'syndicated content add/edit',
				namespace => 'SyndicatedContent'
			}
		]
	},
};

1;
