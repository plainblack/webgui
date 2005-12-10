package WebGUI::Help::Asset_InOutBoard;

our $HELP = {
	'in out board add/edit' => {
		title => '18',
		body => '19',
		related => [
			{
				tag => '2',
				namespace => 'Asset_InOutBoard'
			},
			{
				tag => 'wobject add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
		]
	},
	'2' => {
		title => '20',
		body => '21',
		related => [
			{
				tag => 'in out board add/edit',
				namespace => 'Asset_InOutBoard'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject template',
				namespace => 'WebGUI'
			}
		]
	},
	'3' => {
		title => '22',
		body => '23',
		related => [
			{
				tag => 'in out board add/edit',
				namespace => 'Asset_InOutBoard'
			},
			{
				tag => '2',
				namespace => 'Asset_InOutBoard'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			}
		]
	},
};

1;

