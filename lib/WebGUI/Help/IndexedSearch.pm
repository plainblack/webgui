package WebGUI::Help::IndexedSearch;

our $HELP = {
	'search add/edit' => {
		title => 26,
		body => 27,
		related => [
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			},
			{
				tag => 'search template',
				namespace => 'IndexedSearch'
			}
		]
	},
	'search template' => {
		title => 29,
		body => 28,
		related => [
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			},
			{
				tag => 'search add/edit',
				namespace => 'IndexedSearch'
			}
		]
	},
};

1;
