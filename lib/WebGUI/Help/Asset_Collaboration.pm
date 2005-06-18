package WebGUI::Help::Asset_Collaboration;

our $HELP = {
	'collaboration add/edit' => {
		title => 'collaboration add/edit title',
		body => 'collaboration add/edit body',
		fields => [
                        {
                                title => 'display last reply',
                                description => 'display last reply description'
                        },
                        {
                                title => 'system template',
                                description => 'system template description'
                        },
                        {
                                title => 'thread template',
                                description => 'thread template description'
                        },
                        {
                                title => 'post template',
                                description => 'post template description'
                        },
                        {
                                title => 'search template',
                                description => 'search template description'
                        },
                        {
                                title => 'notification template',
                                description => 'notification template description'
                        },
                        {
                                title => 'who moderates',
                                description => 'who moderates description'
                        },
                        {
                                title => 'who posts',
                                description => 'who posts description'
                        },
                        {
                                title => 'threads/page',
                                description => 'threads/page description'
                        },
                        {
                                title => 'posts/page',
                                description => 'posts/page description'
                        },
                        {
                                title => 'karma/post',
                                description => 'karma/post description'
                        },
                        {
                                title => 'karma spent to rate',
                                description => 'karma spent to rate description'
                        },
                        {
                                title => 'karma rating multiplier',
                                description => 'karma rating multiplier description'
                        },
                        {
                                title => 'filter code',
                                description => 'filter code description'
                        },
                        {
                                title => 'sort by',
                                description => 'sort by description'
                        },
                        {
                                title => 'sort order',
                                description => 'sort order description'
                        },
                        {
                                title => 'archive after',
                                description => 'archive after description'
                        },
                        {
                                title => 'attachments/post',
                                description => 'attachments/post description'
                        },
                        {
                                title => 'editTimeout',
                                description => 'editTimeout description'
                        },
                        {
                                title => 'allow replies',
                                description => 'allow replies description'
                        },
                        {
                                title => 'edit stamp',
                                description => 'edit stamp description'
                        },
                        {
                                title => 'rich edit',
                                description => 'rich edit description'
                        },
                        {
                                title => 'content filter',
                                description => 'content filter description'
                        },
                        {
                                title => 'use preview',
                                description => 'use preview description'
                        },
                        {
                                title => 'moderate',
                                description => 'moderate description'
                        },
		],
		related => [
			{
				tag => 'content filtering',
				namespace => 'WebGUI'
			},
		]
	},

	'collaboration template labels' => {
		title => 'collaboration template labels title',
		body => 'collaboration template labels body',
		fields => [
		],
		related => [
		]
	},

	'collaboration post list template variables' => {
		title => 'collaboration post list template variables title',
		body => 'collaboration post list template variables body',
		fields => [
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		]
	},

	'collaboration template' => {
		title => 'collaboration template title',
		body => 'collaboration template body',
		fields => [
		],
		related => [
			{
		   		tag => 'collaboration template labels',
				namespace => 'Asset_Collaboration',
			},
			{
		   		tag => 'collaboration post list template variables',
				namespace => 'Asset_Collaboration',
			},
		]
	},

	'collaboration search template' => {
		title => 'collaboration search template title',
		body => 'collaboration search template body',
		fields => [
		],
		related => [
			{
		   		tag => 'collaboration post list template variables',
				namespace => 'Asset_Collaboration',
			},
		]
	},

};

1;
