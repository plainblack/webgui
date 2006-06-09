package WebGUI::Help::Asset_Post;

our $HELP = {
	'post add/edit template' => {
		title => 'add/edit post template title',
		body => 'add/edit post template body',
		fields => [
		],
		variables => [
		          {
		            'required' => 1,
		            'name' => 'form.header'
		          },
		          {
		            'name' => 'isNewPost'
		          },
		          {
		            'name' => 'isReply'
		          },
		          {
		            'name' => 'reply.title'
		          },
		          {
		            'name' => 'reply.synopsis'
		          },
		          {
		            'name' => 'reply.content'
		          },
		          {
		            'name' => 'reply.userDefinedN'
		          },
		          {
		            'name' => 'subscribe.form'
		          },
		          {
		            'name' => 'isNewThread'
		          },
		          {
		            'name' => 'sticky.form'
		          },
		          {
		            'name' => 'lock.form'
		          },
		          {
		            'name' => 'isThread'
		          },
		          {
		            'name' => 'isEdit'
		          },
		          {
		            'name' => 'preview.title'
		          },
		          {
		            'name' => 'preview.synopsis'
		          },
		          {
		            'name' => 'preview.content'
		          },
		          {
		            'name' => 'preview.userDefinedN'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.footer'
		          },
		          {
		            'required' => 1,
		            'name' => 'usePreview'
		          },
		          {
		            'name' => 'user.isModerator'
		          },
		          {
		            'name' => 'user.isVisitor'
		          },
		          {
		            'name' => 'visitorName.form'
		          },
		          {
		            'name' => 'userDefinedN.form'
		          },
		          {
		            'name' => 'userDefinedN.form.yesNo'
		          },
		          {
		            'name' => 'userDefinedN.form.textarea'
		          },
		          {
		            'name' => 'userDefinedN.form.htmlarea'
		          },
		          {
		            'name' => 'userDefinedN.form.float'
		          },
		          {
		            'name' => 'title.form'
		          },
		          {
		            'name' => 'title.form.textarea'
		          },
		          {
		            'name' => 'synopsis.form'
		          },
		          {
		            'name' => 'content.form'
		          },
		          {
		            'name' => 'form.submit'
		          },
		          {
		            'name' => 'karmaScale.form'
		          },
		          {
		            'name' => 'karmaIsEnabled'
		          },
		          {
		            'name' => 'form.preview'
		          },
		          {
		            'name' => 'attachment.form'
		          },
		          {
		            'name' => 'contentType.form'
		          }
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'post template variables',
				namespace => 'Asset_Post'
			},
		]
	},

	'post template variables' => {
		title => 'post template variables title',
		body => 'post template variables body',
		fields => [
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'collaboration template labels',
				namespace => 'Asset_Collaboration'
			},
		]
	},

	'notification template' => {
		title => 'notification template title',
		body => 'notification template body',
		fields => [
		],
		variables => [
		          {
		            'name' => 'url',
		            'description' => 'notify url'
		          },
		          {
		            'name' => 'notification.subscription.message'
		          }
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'post template variables',
				namespace => 'Asset_Post'
			},
		]
	},

};

1;
