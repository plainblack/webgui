package WebGUI::i18n::English::Post;

our $I18N = {
	'add/edit post template title' => {
		message => q|Post Add/Edit Template|,
                lastUpdated => 1111253044,
        },

	'add/edit post template body' => {
		message => q|The following variables are available in the template to add or edit Posts:
<p>
! : This variable is required for the Data Form to function correctly.<p/>
<p>

<b>form.header</b> !<br>
Code required to start the form for the Post.
<p>

<b>isNewPost</b><br>
A conditional that is true if the user is adding a new Post, as opposed to
editing an existing Post.
<p>

<b>isReply</b><br>
A conditional that is true if the user is replying to an existing Post.
<p>

<b>reply.title</b><br>
The title of the Post that is being replied to.
<p>

<b>reply.synopsis</b><br>
The synopsis of the Post that is being replied to.
<p>

<b>reply.content</b><br>
The content of the Post that is being replied to.
<p>

<b>subscribe.form</b><br>
A yes/no button to allow the user to subscribe to the thread this post belongs to.
<p>

|,
		lastUpdated => 1111252633,
	},

};

1;
