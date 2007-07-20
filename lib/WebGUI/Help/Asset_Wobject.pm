package WebGUI::Help::Asset_Wobject;

our $HELP = {

	'wobject template' => {
		title => '827',
		body => '',
		fields => [
		],
		variables => [
			{
				'name' => 'title'
			},
			{
				'name' => 'displayTitle'
			},
			{
				'name' => 'description'
			},
			{
				'name' => 'assetId'
			},
		],
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
		]
	},

	'wobject template variables' => {
		private => 1,
		title => 'wobject template variables title',
		body => '',
		isa => [
			{
				tag => 'asset template asset variables',
				namespace => 'Asset'
			},
		],
		fields => [
		],
		variables => [
			{
				'name' => 'displayTitle'
			},
			{
				'name' => 'description'
			},
			{
				'name' => 'styleTemplateId'
			},
			{
				'name' => 'printableStyleTemplateId'
			},
		],
		related => [
		]
	},

};

1;
