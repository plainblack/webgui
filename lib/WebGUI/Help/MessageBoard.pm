package WebGUI::Help::MessageBoard;

our $HELP = {
	'message board add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'forum add/edit',
				namespace => 'MessageBoard'
			},
			{
				tag => 'message board template',
				namespace => 'MessageBoard'
			},
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
		]
	},
	'message board template' => {
		title => '73',
		body => '74',
		related => [
			{
				tag => 'forum notification template',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum post form template',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum post template',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum search template',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum template',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum thread template',
				namespace => 'WebGUI'
			},
			{
				tag => 'message board add/edit',
				namespace => 'MessageBoard'
			},
			{
				tag => 'wobject template',
				namespace => 'WebGUI'
			}
		]
	},
	'forum add/edit' => {
		title => '78',
		body => '79',
		related => [
			{
				tag => 'forum discussion properties',
				namespace => 'WebGUI'
			},
			{
				tag => 'message board add/edit',
				namespace => 'MessageBoard'
			}
		]
	},
};

1;
