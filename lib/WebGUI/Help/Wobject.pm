package WebGUI::Help::Wobject;

our $HELP = {

	'wobjects using' => {
		title => '671',
		body => '626',
		related => [
			{
				tag => 'macros using',
				namespace => 'WebGUI'
			},
			{
				tag => 'style sheets using',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject add/edit',
				namespace => 'Wobject'
			},
			{
				tag => 'wobject delete',
				namespace => 'Wobject'
			}
		]
	},

	'wobject add/edit' => {
		title => '677',
		body => '632',
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			}
		]
	},

	'wobject delete' => {
		title => '664',
		body => '619',
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			}
		]
	},

	'wobject template' => {
		title => '827',
		body => '828',
		related => [
			{
				tag => 'article template',
				namespace => 'Article'
			},
			{
				tag => 'data form template',
				namespace => 'DataForm'
			},
			{
				tag => 'events calendar template',
				namespace => 'EventsCalendar'
			},
			{
				tag => 'message board template',
				namespace => 'MessageBoard'
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'poll template',
				namespace => 'Poll'
			},
			{
				tag => 'product template',
				namespace => 'Product'
			},
			{
				tag => 'survey template',
				namespace => 'Survey'
			},
			{
				tag => 'syndicated content template',
				namespace => 'SyndicatedContent'
			},
			{
				tag => 'template language',
				namespace => 'Template'
			},
			{
				tag => 'templates manage',
				namespace => 'Template'
			},
		]
	},
};

1;
