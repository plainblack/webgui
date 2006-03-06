package WebGUI::Help::WebGUIProfile;

our $HELP = {
	'profile settings edit' => {
		title => '672',
		body => '627',
		fields => [
                        {
                                title => '475',
                                description => '475 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '472',
                                description => '472 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '473a',
                                description => '473a description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '897a',
                                description => '897a description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '474',
                                description => '474 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '486',
                                description => '486 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '487',
                                description => '487 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '488',
                                description => '488 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '489',
                                description => '489 description',
                                namespace => 'WebGUIProfile',
                        },
		],
		related => []
	},
	'add/edit profile settings category' => {
		title => 'user profile category add/edit title',
		body => 'user profile category add/edit body',
		fields => [
                        {
                                title => '470',
                                description => '470 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '473',
                                description => '473 description',
                                namespace => 'WebGUIProfile',
                        },
                        {
                                title => '897',
                                description => '897 description',
                                namespace => 'WebGUIProfile',
                        },
		],
		related => []
	},
	'user profile edit' => {
		title => '682',
		body => '637',
		fields => [
		],
		related => [
			{
				tag => 'users manage',
				namespace => 'WebGUI'
			}
		]
	},
};

1;
