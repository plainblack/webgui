package WebGUI::Help::Asset_Article;

our $HELP = {
	'article add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'article template',
				namespace => 'Asset_Article'
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
	'article template' => {
		title => '72',
		body => '73',
		related => [
			{
				tag => 'article add/edit',
				namespace => 'Asset_Article'
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
};

1;
