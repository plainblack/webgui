package WebGUI::Help::Subscription;

our $HELP = {
	'subscription add/edit' => {
		title => 'help edit subscription title',
		body => 'help edit subscription body',
		fields => [
		],
		related => [
			{
				tag		=> 'subscription manage',
				namespace	=> 'Subscription'
			},
		]
	},
	
	'subscription manage' => {
		title => 'help manage subscriptions title',
		body => 'help manage subscriptions body',
		fields => [
		],
		related => [
			{
				tag		=> 'subscription add/edit',
				namespace	=> 'Subscription'
			},
			{
				tag		=> 'subscription codes manage',
				namespace	=> 'Subscription'
			},
		]
	},

	'subscription codes manage' => {
		title => 'help manage subscription codes title',
		body => 'help manage subscription codes body',
		fields => [
		],
		related => [
			{
				tag		=> 'create batch',
				namespace	=> 'Subscription'
			},
			{
				tag		=> 'subscription manage',
				namespace	=> 'Subscription'
			},
		]
	},

	'create batch' => {
		title => 'help create batch title',
		body => 'help create batch body',
		fields => [
		],
		related => [
			{
				tag		=> 'subscription codes manage',
				namespace	=> 'Subscription'
			},
			{
				tag		=> 'manage batch',
				namespace	=> 'Subscription'
			},
		]
	},

	'manage batch' => {
		title => 'help manage batch title',
		body => 'help manage batch body',
		fields => [
		],
		related => [
			{
				tag		=> 'create batch',
				namespace	=> 'Subscription'
			},
			{
				tag		=> 'subscription codes manage',
				namespace	=> 'Subscription'
			},
		]
	},

	'redeem code' => {
		title => 'help redeem code template title',
		body => 'help redeem code template body',
		fields => [
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			},
		]
	},
	
};

1;
