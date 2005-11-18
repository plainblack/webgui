package WebGUI::Help::Subscription;

our $HELP = {
	'subscription add/edit' => {
		title => 'help edit subscription title',
		body => 'help edit subscription body',
		fields => [
                        {
                                title => 'subscription name',
                                description => 'subscription name description',
                                namespace => 'Subscription',
                        },
                        {
                                title => 'subscription price',
                                description => 'subscription price description',
                                namespace => 'Subscription',
                        },
                        {
                                title => 'subscription description',
                                description => 'subscription description description',
                                namespace => 'Subscription',
                        },
                        {
                                title => 'subscription group',
                                description => 'subscription group description',
                                namespace => 'Subscription',
                        },
                        {
                                title => 'subscription duration',
                                description => 'subscription duration description',
                                namespace => 'Subscription',
                        },
                        {
                                title => 'execute on subscription',
                                description => 'execute on subscription description',
                                namespace => 'Subscription',
                        },
                        {
                                title => 'subscription karma',
                                description => 'subscription karma description',
                                namespace => 'Subscription',
                        },
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
                        {
                                title => 'noc',
                                description => 'noc description',
                                namespace => 'Subscription',
                        },
                        {
                                title => 'code length',
                                description => 'code length description',
                                namespace => 'Subscription',
                        },
                        {
                                title => 'codes expire',
                                description => 'codes expire description',
                                namespace => 'Subscription',
                        },
                        {
                                title => 'association',
                                description => 'association description',
                                namespace => 'Subscription',
                        },
                        {
                                title => 'batch description',
                                description => 'batch description description',
                                namespace => 'Subscription',
                        },
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
