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

<b>isNewThread</b><br>
A conditional that is true if the user is adding a new thread.
<p>

<b>sticky.form</b><br>
A yes/no button to set the thread to be sticky.
<p>

<b>lock.form</b><br>
A yes/no button to lock the thread.
<p>

<b>isEdit</b><br>
A conditional that is true if the user is editing an existing post.
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

<b>preview.userDefined.<i>N</i></b><br>
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

<b>userDefined.<i>N</i>.{form,yesNo,textarea,htmlarea}</b><br>
For each of the 5 User Defined fields, form widgets for a single line of text, a yes/no
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

<b>startDate.form</b><br>
A form that will set when the post starts to be available.
<p>

<b>endDate.form</b><br>
A form that will set when the post stops being available.
<p>

|,
		lastUpdated => 1111388442,
	},

	'post template variables title' => {
		message => q|Post Template Variables|,
                lastUpdated => 1111253044,
        },

	'post template variables body' => {
		message => q|The following variables are available in all Post templates:
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
The status of this Post, typically "Approved", "Denied", or "Pending".
<p>

<b>approve.url</b><br>
The URL to approve this Post, if it's moderated.
<p>

<b>deny.url</b><br>
The URL to deny this Post, if it's moderated.
<p>

<b>reply.url</b><br>
The URL to reply to this Post and quote it in your reply.
<p>

<b>reply.withoutQuote.url</b><br>
The URL to reply to this Post without quoting it.
<p>

<b>url</b><br>
The URL for this Post.
<p>

<b>rating.value</b><br>
The current rating for this Post.
<p>

<b>rate.url.<i>N</i></b><br>
URLs that are used to rate this post.  N goes from 1 to 5.
<p>

<b>hasRated</b><br>
A conditional that is true if the user has already rated this Post.
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

<b>image.url</b><br>
The URL to the image.
<p>

<b>image.thumbnail</b><br>
A thumbnail for the image.
<p>

<b>attachment.url</b><br>
The URL to download the attachment.
<p>

<b>attachment.icon</b><br>
An icon showing the file type of this attachment.
<p>

<b>attachment.name</b><br>
The name of this attachment.
<p>

</blockquote>

|,
		lastUpdated => 1111447237,
	},

	'approved' => {
		message => q|Approved|,
		lastUpdated => 1031514049,
	},

	'denied' => {
		message => q|Denied|,
		lastUpdated => 1031514049
	},

	'pending' => {
		message => q|Pending|,
		lastUpdated => 1031514049
	},


};

1;
