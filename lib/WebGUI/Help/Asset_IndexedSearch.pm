package WebGUI::Help::Asset_IndexedSearch;

our $HELP = {
	'indexed search add/edit' => {
		title => '26',
		body => '27',
		fields => [
		],
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'indexed search template',
				namespace => 'Asset_IndexedSearch'
			}
		]
	},
	'indexed search template' => {
		title => '29',
		body => '28',
		fields => [
		],
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			},
			{
				tag => 'indexed search add/edit',
				namespace => 'Asset_IndexedSearch'
			}
		]
	},
};

1;
