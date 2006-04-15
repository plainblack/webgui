package WebGUI::i18n::English::Asset_Post;

our $I18N = {
	'add/edit post template title' => {
		message => q|Post Add/Edit Template|,
                lastUpdated => 1111253044,
        },

	'add/edit post template body' => {
		message => q|In addition to the common Post Template variables, the Add/Edit Post Template has these variables:
<p>
! : This variable is required for the Post to function correctly.<p/>
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

<b>reply.userDefined<i>N</i></b><br>
The contents of user defined fields for the Post that is being replied to, where N is from 1 to 5.
<p>

<b>subscribe.form</b><br>
A yes/no button to allow the user to subscribe to the thread this post belongs to.
<p>

<b>isNewThread</b><br>
A conditional that is true if the user is adding a new thread.
<p>

<b>sticky.form</b><br>
A yes/no button to set the thread to be sticky, so that it stays at the top of the forum listing.
<p>

<b>lock.form</b><br>
A yes/no button to lock the thread, so that no posts can be added or edited.
<p>

<b>isEdit</b><br>
A conditional that is true if the user is editing an existing post.
<p>

<b>karmaScale.form</b><br>
A form element that allows moderators to set the scale of an individual thread. This is only available for threads.
<p>

<b>preview.title</b><br>
The web safe title for previewing a post.
<p>

<b>preview.synopsis</b><br>
The synopsis when previewing a post.
<p>

<b>preview.content</b><br>
The content when previewing a post.
<p>

<b>preview.userDefined<i>N</i></b><br>
The contents of user defined fields for the Post without WebGUI Macros being processed, where N is from 1 to 5.
<p>

<b>form.footer</b> !<br>
Code for the end of the form.
<p>

<b>usePreview</b> !<br>
A conditional indicating that posts to the thread will be previewed before being submitted.
<p>

<b>user.isModerator</b><br>
A conditional indicating if the current user is a moderator.
<p>

<b>user.isVisitor</b><br>
A conditional indicating if the current user is a visitor.
<p>

<b>visitorName.form</b><br>
A form where the user can enter their name.
<p>

<b>userDefined<i>N</i>.{form,form.yesNo,form.textarea,form.htmlarea}</b><br>
For each of the 5 User Defined fields, which can be form widgets for a single line of text, a yes/no
field, a text area, or a WYSIWIG HTML area.
<p>

<b>title.form</b><br>
A form field to enter or edit the title, stripped of all HTML and macros disabled.
<p>

<b>title.form.textarea</b><br>
A text field to enter or edit the title, stripped of all HTML and macros disabled.
<p>

<b>synopsis.form</b><br>
A form field to enter or edit the synopsis.
<p>

<b>content.form</b><br>
A field to enter or edit the content, with all macros disabled.  If the discussion
board allows rich content, then this will be a WYSIWIG HTML area.  Otherwise it
will be a plain text area.
<p>

<b>form.submit</b><br>
A button to submit the post.
<p>

<b>form.preview</b><br>
A button to preview the post.
<p>

<b>attachment.form</b><br>
Code to allow an attachment to be added to the post.
<p>

<b>contentType.form</b><br>
A form field that will describe how the content of the post is formatted, HTML, text, code or mixed.
Defaults to mixed.
<p>

|,
		lastUpdated => 1134670945,
	},

	'post template variables title' => {
		message => q|Post Template Variables|,
                lastUpdated => 1111253044,
        },

	'post template variables body' => {
		message => q|The following variables are available in all Post templates.  Internationalized labels
		for the action URLs (reply, delete, etc.)  are provided in the set of Collaboration Template labels.
<p>

<b>userId</b><br>
The User ID of the owner of the Post.
<p>

<b>user.isPoster</b><br>
A conditional that is true if the current user is the owner of this Post.
<p>

<b>userProfile.url</b><br>
A URL to the profile of the owner of the Post.
<p>

<b>dateSubmitted.human</b><br>
The date that the post was sumbitted, in a readable format.
<p>

<b>dateUpdated.human</b><br>
The date that the post was last updated, in a readable format.
<p>

<b>title.short</b><br>
The title of the Post, limited to 30 characters. 
<p>

<b>content</b><br>
The content of the post, if a thread containing the Post exists.
<p>

<b>user.canEdit</b><br>
A conditional that is true if the user is adding a new Post, as opposed to
editing an existing Post, and a thread containing the Post exists.
<p>

<b>delete.url</b><br>
A URL to delete this Post.
<p>

<b>edit.url</b><br>
A URL to edit this Post.
<p>

<b>status</b><br>
The status of this Post: "Approved", "Pending" or "Archived".
<p>

<b>reply.url</b><br>
The URL to reply to this Post without quoting it.
<p>

<b>reply.withQuote.url</b><br>
The URL to initiate a quoted reply to this Post.
<p>

<b>url</b><br>
The URL for this Post.
<p>

<b>rating.value</b><br>
The current rating for this Post.
<p>

<b>rate.url.thumbsUp</b><br>
A positive rating.
<p>

<b>rate.url.thumbsDown</b><br>
A negative rating.
<p>

<b>hasRated</b><br>
A conditional that is true if the user has already rated this Post.
<p>

<b>image.url</b><br>
The URL to the first image attached to the Post.
<p>

<b>image.thumbnail</b><br>
A thumbnail for the image attached to the Post.
<p>

<b>attachment.url</b><br>
The URL to download the first attachment attached to the Post.
<p>

<b>attachment.icon</b><br>
An icon showing the file type of this attachment.
<p>

<b>attachment.name</b><br>
The name of the first attachment found on the Post.
<p>

<b>attachment_loop</b><br>
A loop containing all file and image attachments to this Post.
<p>

<blockquote>

<b>url</b><br>
The URL to download this attachment.
<p>

<b>icon</b><br>
The icon representing the file type of this attachment.
<p>

<b>filename</b><br>
The name of this attachment.
<p>

<b>thumbnail</b><br>
A thumbnail of this attachment, if applicable.
<p>

<b>isImage</b><br>
A conditional indicating whether this attachment is an image.
<p>

</blockquote>

<b>storageId</b><br>
The Asset ID of the storage node for the Post, where the attachments are kept.
<p>

<b>threadId</b><br>
The ID of the thread that contains this Post.
<p>

<b>dateSubmitted</b><br>
The date the Post was submitted, in epoch format.
<p>

<b>dateUpdated</b><br>
The date the Post was last updated, in epoch format.
<p>

<b>username</b><br>
The name of the user who last updated or submitted the Post.
<p>

<b>rating</b><br>
Another name for <b>rating.value</b>
<p>

<p>
<b>avatar.url</b><br>
A URL to the avatar for the owner of the Post, if avatars are enabled in the parent
Collaboration System and the user has an avatar.

<b>views</b><br>
The number of times that this post has been viewed.
<p>

<b>contentType</b><br>
The type of content in the post, typically "code", "text", "HTML", "mixed".
<p>

<b>userDefined<i>N</i></b><br>
The contents of the user defined properties, from 1 to 5.
<p>

<b>content</b><br>
The content, or body, of the Post.
<p>

<b>title</b><br>
The title of the Post.
<p>

<b>menuTitle</b><br>
The menu title of the Post, often used in navigation.
<p>

<b>synopsis</b><br>
The synopsis of the Post.
<p>

<b>extraHeadTags</b><br>
Extra tags that the user requested by added to the HTML header.
<p>

<b>groupIdEdit</b><br>
The ID of the group with permission to edit this Post.
<p>

<b>groupIdView</b><br>
The ID of the group with permission to view this Post.
<p>

<b>ownerUserId</b><br>
An alias for <b>userId</b>.
<p>

<b>assetSize</b><br>
The formatted size of this Post.
<p>

<b>isPackage</b><br>
A conditional indicating whether this Post is a package.
<p>

<b>isPrototype</b><br>
A conditional indicating whether this Post is a Content Prototype.
<p>

<b>isHidden</b><br>
A conditional indicating whether this Post should be hidden from navigation.
<p>

<b>newWindow</b><br>
A conditional indicating whether this Post should be opened in a new window.
<p>

<b>userDefined1, userDefined2, userDefined3, userDefined4, userDefined5</b><br>
You can use up to 5 user defined fields. The fields are
called "userDefined1" through "userDefined5". In the
Post Form template you can use those variables like
this to collect data:

<blockquote>
&lt;tmpl_var userDefined1.form&gt; (text)<br>

&lt;tmpl_var userDefined1.form.yesNo&gt; (yes / no) <br>

&lt;tmpl_var userDefined1.form.textarea&gt; (textarea) <br>

&lt;tmpl_var userDefined1.form.htmlarea&gt; (rich edit box) <br>

</blockquote>

Then in the Thread and Main CS templates you can call
back the data with a simple &lt;tmpl_var userDefined1&gt;. 

<p>

|,
		lastUpdated => 1145111051,
	},

	'post received' => {
		message => q|Your post has been received and is pending approval.|,
		context => q|Displayed after someone posts a new message.|,
		lastUpdated => 0,
	},

	'approved' => {
		message => q|Approved|,
		lastUpdated => 1031514049,
	},

	'pending' => {
		message => q|Pending|,
		lastUpdated => 1031514049
	},

	'archived' => {
		message => q|Archived|,
		lastUpdated => 1111464988,
	},

	'Edited_on' => {
		message => q|Edited on|,
		lastUpdated => 1116259200
	},

	'By' => {
		message => q| by |,
		lastUpdated => 1116259200,
	},

	'notification template title' => {
		message => q|Notification Template|,
                lastUpdated => 1111253044,
        },

	'notification template body' => {
		message => q|In addition to the common Post Template variables, the Notification Template has these variables:
<p>

All variables from the Post Template Variables.
<p>

<b>url</b><br>
The URL to the post that triggered the notification.
<p>

<b>notification.subscription.message</b><br>
Internationalized message that a new message has been posted to a thread that the
user subscribed to.
<p>

|,
		lastUpdated => 1111465141,
	},

        '875' => {
                message => q|A new message has been posted to one of your subscriptions.|,
                lastUpdated => 1111470216,
        },

	'523' => {
		message => q|Notification|,
		lastUpdated => 1031514049
	},

        'assetName' => {
                message => q|Post|,
                context => q|label for Asset Manager, getName|,
                lastUpdated => 1128829703,
        },
                                                                                                                              
	'new file description' => {
		message => q|Enter the path to a file, or use the "Browse" button to find a file on your local hard drive that you would like to be uploaded.|,
		lastUpdated => 1119068745
	},

};

1;
