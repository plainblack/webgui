package WebGUI::Help::Asset_Collaboration;

our $HELP = {
	'collaboration add/edit' => {
		title => 'collaboration add/edit title',
		body => 'collaboration add/edit body',
		fields => [
                        {
                                title => 'visitor cache timeout',
                                namespace => 'Asset_Collaboration',
                                description => 'visitor cache timeout help',
				uiLevel => 8,
                        },
                        {
                                title => 'display last reply',
                                description => 'display last reply description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'thumbnail size',
                                description => 'thumbnail size help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'max image size',
                                description => 'max image size help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'system template',
                                description => 'system template description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'thread template',
                                description => 'thread template description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'post template',
                                description => 'post template description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'search template',
                                description => 'search template description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'notification template',
                                description => 'notification template description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'rss template',
                                description => 'rss template description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'who posts',
                                description => 'who posts description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'approval workflow',
                                description => 'approval workflow description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'threads/page',
                                description => 'threads/page description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'posts/page',
                                description => 'posts/page description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'default karma scale',
                                description => 'default karma scale help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'karma/post',
                                description => 'karma/post description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'karma spent to rate',
                                description => 'karma spent to rate description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'karma rating multiplier',
                                description => 'karma rating multiplier description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'filter code',
                                description => 'filter code description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'sort by',
                                description => 'sort by description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'sort order',
                                description => 'sort order description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'archive after',
                                description => 'archive after description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'attachments/post',
                                description => 'attachments/post description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'edit timeout',
                                description => 'edit timeout description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'allow replies',
                                description => 'allow replies description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'edit stamp',
                                description => 'edit stamp description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'rich editor',
                                description => 'rich editor description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'content filter',
                                description => 'content filter description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'use preview',
                                description => 'use preview description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'enable avatars',
                                description => 'enable avatars description',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'get mail',
                                description => 'get mail help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'display last reply',
                                description => 'display last reply help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'mail server',
                                description => 'mail server help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'mail account',
                                description => 'mail account help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'mail password',
                                description => 'mail password help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'mail address',
                                description => 'mail address help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'get mail interval',
                                description => 'get mail interval help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'mail prefix',
                                description => 'mail prefix help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'auto subscribe to thread',
                                description => 'auto subscribe to thread help',
                                namespace => 'Asset_Collaboration',
                        },
                        {
                                title => 'require subscription for email posting',
                                description => 'require subscription for email posting help',
                                namespace => 'Asset_Collaboration',
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
		variables => [
		          {
		            'name' => 'add.label'
		          },
		          {
		            'name' => 'addlink.label'
		          },
		          {
		            'name' => 'addquestion.label'
		          },
		          {
		            'name' => 'answer.label'
		          },
		          {
		            'name' => 'attachment.label'
		          },
		          {
		            'name' => 'by.label'
		          },
		          {
		            'name' => 'body.label'
		          },
		          {
		            'name' => 'back.label'
		          },
		          {
		            'name' => 'compensation.label'
		          },
		          {
		            'name' => 'open.label'
		          },
		          {
		            'name' => 'close.label'
		          },
		          {
		            'name' => 'closed.label'
		          },
		          {
		            'name' => 'critical.label'
		          },
		          {
		            'name' => 'minor.label'
		          },
		          {
		            'name' => 'cosmetic.label'
		          },
		          {
		            'name' => 'fatal.label'
		          },
		          {
		            'name' => 'severity.label'
		          },
		          {
		            'name' => 'date.label'
		          },
		          {
		            'name' => 'delete.label'
		          },
		          {
		            'name' => 'description.label'
		          },
		          {
		            'name' => 'edit.label'
		          },
		          {
		            'name' => 'image.label'
		          },
		          {
		            'name' => 'job.header.label'
		          },
		          {
		            'name' => 'job.title.label'
		          },
		          {
		            'name' => 'job.description.label'
		          },
		          {
		            'name' => 'job.requirements.label'
		          },
		          {
		            'name' => 'location.label'
		          },
		          {
		            'name' => 'layout.flat.label'
		          },
		          {
		            'name' => 'link.header.label'
		          },
		          {
		            'name' => 'lastReply.label'
		          },
		          {
		            'name' => 'lock.label'
		          },
		          {
		            'name' => 'layout.label'
		          },
		          {
		            'name' => 'message.header.label'
		          },
		          {
		            'name' => 'message.label'
		          },
		          {
		            'name' => 'next.label'
		          },
		          {
		            'name' => 'newWindow.label'
		          },
		          {
		            'name' => 'layout.nested.label'
		          },
		          {
		            'name' => 'previous.label'
		          },
		          {
		            'name' => 'post.label'
		          },
		          {
		            'name' => 'question.label'
		          },
		          {
		            'name' => 'question.header.label'
		          },
		          {
		            'name' => 'rating.label'
		          },
		          {
		            'name' => 'rate.label'
		          },
		          {
		            'name' => 'reply.label'
		          },
		          {
		            'name' => 'replies.label'
		          },
		          {
		            'name' => 'readmore.label'
		          },
		          {
		            'name' => 'responses.label'
		          },
		          {
		            'name' => 'search.label'
		          },
		          {
		            'name' => 'subject.label'
		          },
		          {
		            'name' => 'subscribe.label'
		          },
		          {
		            'name' => 'submission.header.label'
		          },
		          {
		            'name' => 'stick.label'
		          },
		          {
		            'name' => 'status.label'
		          },
		          {
		            'name' => 'synopsis.label'
		          },
		          {
		            'name' => 'thumbnail.label'
		          },
		          {
		            'name' => 'title.label'
		          },
		          {
		            'name' => 'unlock.label'
		          },
		          {
		            'name' => 'unstick.label'
		          },
		          {
		            'name' => 'unsubscribe.label'
		          },
		          {
		            'name' => 'url.label'
		          },
		          {
		            'name' => 'user.label'
		          },
		          {
		            'name' => 'views.label'
		          },
		          {
		            'name' => 'visitorName.label'
		          }
		],
		fields => [
		],
		related => [
		]
	},

	'collaboration post list template variables' => { ##from appendPostListTemplateVars
		title => 'collaboration post list template variables title',
		body => 'collaboration post list template variables body',
		fields => [
		],
		variables => [
		          {
		            'name' => 'post_loop',
		            'variables' => [
		                             {
		                               'name' => 'id'
		                             },
		                             {
		                               'name' => 'url',
		                               'description' => 'tmplVar url'
		                             },
		                             {
		                               'name' => 'rating_loop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'rating_loop.count'
		                                                }
		                                              ]
		                             },
		                             {
		                               'name' => 'content'
		                             },
		                             {
		                               'name' => 'status',
		                               'description' => 'tmplVar status'
		                             },
		                             {
		                               'name' => 'thumbnail',
		                               'description' => 'tmplVar thumbnail'
		                             },
		                             {
		                               'name' => 'image.url'
		                             },
		                             {
		                               'name' => 'dateSubmitted.human'
		                             },
		                             {
		                               'name' => 'dateUpdated.human'
		                             },
		                             {
		                               'name' => 'timeSubmitted.human'
		                             },
		                             {
		                               'name' => 'timeUpdated.human'
		                             },
		                             {
		                               'name' => 'userProfile.url'
		                             },
		                             {
		                               'name' => 'user.isVisitor'
		                             },
		                             {
		                               'name' => 'edit.url'
		                             },
		                             {
		                               'name' => 'controls'
		                             },
		                             {
		                               'name' => 'isSecond'
		                             },
		                             {
		                               'name' => 'isThird'
		                             },
		                             {
		                               'name' => 'isFourth'
		                             },
		                             {
		                               'name' => 'isFifth'
		                             },
		                             {
		                               'name' => 'user.isPoster'
		                             },
		                             {
		                               'name' => 'user.hasRead'
		                             },
		                             {
		                               'name' => 'avatar.url'
		                             },
		                             {
		                               'name' => 'lastReply.url'
		                             },
		                             {
		                               'name' => 'lastReply.title'
		                             },
		                             {
		                               'name' => 'lastReply.user.isVisitor'
		                             },
		                             {
		                               'name' => 'lastReply.username'
		                             },
		                             {
		                               'name' => 'lastReply.userProfile.url'
		                             },
		                             {
		                               'name' => 'lastReply.dateSubmitted.human'
		                             },
		                             {
		                               'name' => 'lastReply.timeSubmitted.human'
		                             }
		                           ]
		          }
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'post template variables',
				namespace => 'Asset_Post'
			},
		]
	},

	'collaboration template' => {
		title => 'collaboration template title',
		body => 'collaboration template body',
		fields => [
		],
		variables => [
		          {
		            'name' => 'displayLastReply'
		          },
		          {
		            'name' => 'user.canPost'
		          },
		          {
		            'name' => 'user.isModerator'
		          },
		          {
		            'name' => 'user.isVisitor',
		          },
		          {
		            'name' => 'user.isSubscribed'
		          },
		          {
		            'name' => 'add.url'
		          },
		          {
		            'name' => 'rss.url'
		          },
		          {
		            'name' => 'search.url'
		          },
		          {
		            'name' => 'subscribe.url'
		          },
		          {
		            'name' => 'unsubscribe.url'
		          },
		          {
		            'name' => 'karmaIsEnabled'
		          },
		          {
		            'name' => 'sortby.karmaRank.url'
		          },
		          {
		            'name' => 'sortby.title.url'
		          },
		          {
		            'name' => 'sortby.username.url'
		          },
		          {
		            'name' => 'sortby.date.url'
		          },
		          {
		            'name' => 'sortby.lastreply.url'
		          },
		          {
		            'name' => 'sortby.views.url'
		          },
		          {
		            'name' => 'sortby.replies.url'
		          },
		          {
		            'name' => 'sortby.rating.url'
		          }
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
		variables => [
		          {
		            'name' => 'form.header'
		          },
		          {
		            'name' => 'query.form'
		          },
		          {
		            'name' => 'form.search'
		          },
		          {
		            'name' => 'back.url'
		          },
		          {
		            'name' => 'unsubscribe.url',
		          },
		          {
		            'name' => 'sortby.title.url',
		          },
		          {
		            'name' => 'sortby.username.url',
		          },
		          {
		            'name' => 'sortby.date.url',
		          },
		          {
		            'name' => 'sortby.lastreply.url',
		          },
		          {
		            'name' => 'sortby.views.url',
		          },
		          {
		            'name' => 'sortby.replies.url',
		          },
		          {
		            'name' => 'sortby.rating.url',
		          }
		],
		related => [
			{
		   		tag => 'collaboration post list template variables',
				namespace => 'Asset_Collaboration',
			},
		]
	},

	'collaboration rss template' => {
		title => 'collaboration rss template title',
		body => 'collaboration rss template body',
		fields => [
		],
		variables => [
		          {
		            'name' => 'title',
		            'description' => 'feed title'
		          },
		          {
		            'name' => 'link',
		            'description' => 'collab link'
		          },
		          {
		            'name' => 'description',
		            'description' => 'feed description'
		          },
		          {
		            'name' => 'generator'
		          },
		          {
		            'name' => 'webMaster'
		          },
		          {
		            'name' => 'docs'
		          },
		          {
		            'name' => 'lastBuildDate'
		          },
		          {
		            'name' => 'item_loop',
		            'variables' => [
		                             {
		                               'name' => 'author'
		                             },
		                             {
		                               'name' => 'title',
		                               'description' => 'post title'
		                             },
		                             {
		                               'name' => 'link',
		                               'description' => 'full text link'
		                             },
		                             {
		                               'name' => 'description',
		                               'description' => 'item description'
		                             },
		                             {
		                               'name' => 'guid'
		                             },
		                             {
		                               'name' => 'pubDate'
		                             },
		                             {
		                               'name' => 'attachmentLoop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'attachment.url'
		                                                },
		                                                {
		                                                  'name' => 'attachment.path'
		                                                },
		                                                {
		                                                  'name' => 'attachment.length'
		                                                }
		                                              ]
		                             }
		                           ]
		          }
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
