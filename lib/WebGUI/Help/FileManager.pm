package WebGUI::Help::FileManager;

our $HELP = {
	'file manager add/edit' => {
		title => 61,
		body => 71,
		related => [
			{
				tag => 'file manager template',
				namespace => 'FileManager'
			},
			{
				tag => 'file add/edit',
				namespace => 'FileManager'
			},
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
		]
	},
	'file add/edit' => {
		title => 72,
		body => 73,
		related => [
			{
				tag => 'file manager add/edit',
				namespace => 'FileManager'
			}
		]
	},
	'file manager template' => {
		title => 75,
		body => 76,
		related => [
			{
				tag => 'file manager add/edit',
				namespace => 'FileManager'
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject template',
				namespace => 'WebGUI'
			}
		]
	},
};

1;
