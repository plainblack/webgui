package WebGUI::i18n::English::Asset_Post;
use strict;

our $I18N = {
	'add/edit post template title' => {
		message => q|Post Add/Edit Template|,
                lastUpdated => 1111253044,
        },

	'relativeUrl' => {
		message => q|Provides the URL of the post relative to the server (/path/to/post) rather than fully qualified (http://host/path/to/post), which is the default.|,
		lastUpdated => 1149829706,
	},

	'form.header' => {
		message => q|Code required to start the form for the Post.|,
		lastUpdated => 1149829706,
	},

	'isNewPost' => {
		message => q|A conditional that is true if the user is adding a new Post, as opposed to
editing an existing Post.|,
		lastUpdated => 1149829706,
	},

	'isReply' => {
		message => q|A conditional that is true if the user is replying to an existing Post.|,
		lastUpdated => 1149829706,
	},

	'reply.title' => {
		message => q|The title of the Post that is being replied to.|,
		lastUpdated => 1149829706,
	},

	'reply.synopsis' => {
		message => q|The synopsis of the Post that is being replied to.  If no synopsis has been set, then it will try to grab text from the description, up to the &#94;-; marker.  If no marker is found, then it takes everything up to the first newline in the description|,
		lastUpdated => 1175746663,
	},

	'reply.content' => {
		message => q|The content of the Post that is being replied to.|,
		lastUpdated => 1149829706,
	},

	'reply.userDefinedN' => {
		message => q|The contents of user defined fields for the Post that is being replied to, where N is from 1 to 5.|,
		lastUpdated => 1149829706,
	},

	'subscribe.form' => {
		message => q|A yes/no button to allow the user to subscribe to the thread this post belongs to.|,
		lastUpdated => 1149829706,
	},

	'isNewThread' => {
		message => q|A conditional that is true if the user is adding a new thread.|,
		lastUpdated => 1149829706,
	},

	'archive.form' => {
		message => q|A yes/no button to archive the thread when you submit this reply. This is only available to moderators.|,
		lastUpdated => 1149829706,
	},

	'sticky.form' => {
		message => q|A yes/no button to set the thread to be sticky, so that it stays at the top of the forum listing.|,
		lastUpdated => 1149829706,
	},

	'lock.form' => {
		message => q|A yes/no button to lock the thread, so that no posts can be added or edited.|,
		lastUpdated => 1149829706,
	},

	'isThread' => {
		message => q|A conditional that is true if the user is editing the main post for a thread, as opposed to
a reply in the thread.|,
		lastUpdated => 1149829706,
	},

	'isEdit' => {
		message => q|A conditional that is true if the user is editing an existing post.|,
		lastUpdated => 1149829706,
	},

	'preview.title' => {
		message => q|The web safe title for previewing a post.|,
		lastUpdated => 1149829706,
	},

	'preview.synopsis' => {
		message => q|The synopsis when previewing a post.  If no synopsis has been set, then it will try to grab text from the description, up to the &#94;-; marker.  If no marker is found, then it takes everything up to the first newline in the description|,
		lastUpdated => 1175746627,
	},

	'preview.content' => {
		message => q|The content when previewing a post.|,
		lastUpdated => 1149829706,
	},

	'preview.userDefinedN' => {
		message => q|The contents of user defined fields for the Post without WebGUI Macros being processed, where N is from 1 to 5.|,
		lastUpdated => 1149829706,
	},

	'form.footer' => {
		message => q|Code for the end of the form.|,
		lastUpdated => 1149829706,
	},

	'usePreview' => {
		message => q|A conditional indicating that posts to the thread will be previewed before being submitted.|,
		lastUpdated => 1149829706,
	},

	'user.isModerator' => {
		message => q|A conditional indicating if the current user is a moderator.|,
		lastUpdated => 1149829706,
	},

	'user.isVisitor' => {
		message => q|A conditional indicating if the current user is a visitor.|,
		lastUpdated => 1149829706,
	},

	'visitorName.form' => {
		message => q|A form where the user can enter their name, even if they are a visitor.|,
		lastUpdated => 1149829706,
	},

	'userDefinedN.form' => {
		message => q|For each of the 5 User Defined fields, a form widget for a single line of text.|,
		lastUpdated => 1149829706,
	},

	'userDefinedN.form.yesNo' => {
		message => q|For each of the 5 User Defined fields, a form widget for a a yes/no field.|,
		lastUpdated => 1149829706,
	},

	'userDefinedN.form.textarea' => {
		message => q|For each of the 5 User Defined fields, a form widget for a text area.|,
		lastUpdated => 1149829706,
	},

	'userDefinedN.form.htmlarea' => {
		message => q|For each of the 5 User Defined fields, a form widget for a WYSIWIG HTML area.|,
		lastUpdated => 1149829706,
	},

	'userDefinedN.form.float' => {
		message => q|For each of the 5 User Defined fields, a form widget for a float.|,
		lastUpdated => 1149829706,
	},

	'title.form' => {
		message => q|A 1-line text form field to enter or edit the title, stripped of all HTML and macros disabled.
Use this <b>OR</b> title.form.textarea.|,
		lastUpdated => 1149829706,
	},

	'title.form.textarea' => {
		message => q|A text area field to enter or edit the title, stripped of all HTML and macros disabled.
Use this <b>OR</b> title.form.|,
		lastUpdated => 1149829706,
	},

	'synopsis.form' => {
		message => q|A form field to enter or edit the synopsis.|,
		lastUpdated => 1149829706,
	},

	'content.form' => {
		message => q|A field to enter or edit the content, with all macros disabled.  If the discussion
board allows rich content, then this will be a WYSIWIG HTML area.  Otherwise it
will be a plain text area.|,
		lastUpdated => 1149829706,
	},

	'skipNotification.form' => {
		message => q|A field to that allows a user with the correct editing privileges to skip email notification|,
		lastUpdated => 1269289137,
	},

	'Skip notification' => {
		message => q|Skip notification|,
		lastUpdated => 1269289137,
	},

	'form.submit' => {
		message => q|A button to submit the post.|,
		lastUpdated => 1149829706,
	},
	
	'form.cancel' => {
		message => q|A button to cancel the post.|,
		lastUpdated => 1270240208,
	},
	'karmaScale.form' => {
		message => q|A form element that allows moderators to set the scale of an individual thread. This is only available for threads.|,
		lastUpdated => 1149829706,
	},

	'karmaIsEnabled' => {
		message => q|A conditional that is true if karma has been enabled in the WebGUI settings in the Admin Console for this site.|,
		lastUpdated => 1149829706,
	},

	'form.preview' => {
		message => q|A button to preview the post.|,
		lastUpdated => 1149829706,
	},

	'attachment.form' => {
		message => q|Code to allow an attachment to be added to the post.|,
		lastUpdated => 1149829706,
	},

	'contentType.form' => {
		message => q|A form field that will describe how the content of the post is formatted, HTML, text, code or mixed.
Defaults to mixed.|,
		lastUpdated => 1149829706,
	},

	'post template variables title' => {
		message => q|Post Template Variables|,
                lastUpdated => 1111253044,
        },

	'userId' => {
		message => q|The User ID of the owner of the Post.|,
		lastUpdated => 1150167057,
	},

	'user.isPoster' => {
		message => q|A conditional that is true if the current user is the owner of this Post.|,
		lastUpdated => 1150167057,
	},

	'avatar.url' => {
		message => q|A URL to the avatar for the owner of the Post, if avatars are enabled in the parent
Collaboration System and the user has an avatar.|,
		lastUpdated => 1150167057,
	},

	'userProfile.url' => {
		message => q|A URL to the profile of the owner of the Post.|,
		lastUpdated => 1150167057,
	},

	'dateSubmitted.human' => {
		message => q|The date that the post was sumbitted, in a readable format.|,
		lastUpdated => 1150167057,
	},

	'dateUpdated.human' => {
		message => q|The date that the post was last updated, in a readable format.|,
		lastUpdated => 1150167057,
	},

	'title.short' => {
		message => q|The title of the Post, limited to 30 characters. |,
		lastUpdated => 1150167057,
	},

	'content' => {
		message => q|The content of the post, if a thread containing the Post exists.|,
		lastUpdated => 1150167057,
	},

	'formatted.content' => {
		message => q|The formatted and filtered content of the post, if a thread containing the Post exists.  This variable will override any other variables with this name in the list of template variables.|,
		lastUpdated => 1164424431,
	},

	'user.canEdit' => {
		message => q|A conditional that is true if the user is adding a new Post, as opposed to
editing an existing Post, and a thread containing the Post exists.|,
		lastUpdated => 1150167057,
	},

	'delete.url' => {
		message => q|A URL to delete this Post.|,
		lastUpdated => 1150167057,
	},

	'edit.url' => {
		message => q|A URL to edit this Post.|,
		lastUpdated => 1150167057,
	},

	'status' => {
		message => q|The status of this Post: "Approved", "Pending" or "Archived".|,
		lastUpdated => 1150167057,
	},

	'reply.url' => {
		message => q|The URL to reply to this Post without quoting it.|,
		lastUpdated => 1150167057,
	},

	'reply.withQuote.url' => {
		message => q|The URL to initiate a quoted reply to this Post.|,
		lastUpdated => 1150167057,
	},

	'url' => {
		message => q|The URL for this Post.|,
		lastUpdated => 1150167057,
	},

	'rating.value' => {
		message => q|The current rating for this Post.|,
		lastUpdated => 1150167057,
	},

	'rate.url.thumbsUp' => {
		message => q|A positive rating.|,
		lastUpdated => 1150167057,
	},

	'rate.url.thumbsDown' => {
		message => q|A negative rating.|,
		lastUpdated => 1150167057,
	},

	'hasRated' => {
		message => q|A conditional that is true if the user has already rated this Post.|,
		lastUpdated => 1150167057,
	},

	'image.url' => {
		message => q|The URL to the first image attached to the Post.|,
		lastUpdated => 1150167057,
	},

	'image.thumbnail' => {
		message => q|A thumbnail for the image attached to the Post.|,
		lastUpdated => 1150167057,
	},

	'attachment.url' => {
		message => q|The URL to download the first attachment attached to the Post.|,
		lastUpdated => 1150167057,
	},

	'attachment.icon' => {
		message => q|An icon showing the file type of this attachment.|,
		lastUpdated => 1150167057,
	},

	'attachment.name' => {
		message => q|The name of the first attachment found on the Post.|,
		lastUpdated => 1150167057,
	},

	'attachment_loop' => {
		message => q|A loop containing all file and image attachments to this Post.|,
		lastUpdated => 1150167057,
	},

	'url' => {
		message => q|The URL to download this attachment.|,
		lastUpdated => 1150167057,
	},

	'icon' => {
		message => q|The icon representing the file type of this attachment.|,
		lastUpdated => 1150167057,
	},

	'filename' => {
		message => q|The name of this attachment.|,
		lastUpdated => 1150167057,
	},

	'thumbnail' => {
		message => q|A thumbnail of this attachment, if applicable.|,
		lastUpdated => 1150167057,
	},

	'isImage' => {
		message => q|A conditional indicating whether this attachment is an image.|,
		lastUpdated => 1150167057,
	},

	'storageId' => {
		message => q|The Asset ID of the storage node for the Post, where the attachments are kept.|,
		lastUpdated => 1150167057,
	},

	'threadId' => {
		message => q|The ID of the thread that contains this Post.|,
		lastUpdated => 1150167057,
	},

	'dateSubmitted' => {
		message => q|The date the Post was submitted, in epoch format.|,
		lastUpdated => 1150167057,
	},

	'dateUpdated' => {
		message => q|The date the Post was last updated, in epoch format.|,
		lastUpdated => 1150167057,
	},

	'username' => {
		message => q|The name of the user who last updated or submitted the Post.|,
		lastUpdated => 1150167057,
	},

	'rating' => {
		message => q|Another name for <b>rating.value</b>|,
		lastUpdated => 1150167057,
	},

	'views' => {
		message => q|The number of times that this post has been viewed.|,
		lastUpdated => 1150167057,
	},

	'contentType' => {
		message => q|The type of content in the post, typically "code", "text", "HTML", "mixed".|,
		lastUpdated => 1150167057,
	},

	'content' => {
		message => q|The content, or body, of the Post.|,
		lastUpdated => 1150167057,
	},

	'title' => {
		message => q|The title of the Post.|,
		lastUpdated => 1150167057,
	},

	'menuTitle' => {
		message => q|The menu title of the Post, often used in navigation.|,
		lastUpdated => 1150167057,
	},

	'synopsis' => {
		message => q|The synopsis of the Post.  If no synopsis has been set, then it will try to grab text from the description, up to the &#94;-; marker.  If no marker is found, then it takes everything up to the first newline in the description|,
		lastUpdated => 1175746674,
	},

	'extraHeadTags' => {
		message => q|Extra tags that the user requested by added to the HTML header.|,
		lastUpdated => 1150167057,
	},

	'groupIdEdit' => {
		message => q|The ID of the group with permission to edit this Post.|,
		lastUpdated => 1150167057,
	},

	'groupIdView' => {
		message => q|The ID of the group with permission to view this Post.|,
		lastUpdated => 1150167057,
	},

	'ownerUserId' => {
		message => q|An alias for <b>userId</b>.|,
		lastUpdated => 1150167057,
	},

	'assetSize' => {
		message => q|The formatted size of this Post.|,
		lastUpdated => 1150167057,
	},

	'isPackage' => {
		message => q|A conditional indicating whether this Post is a package.|,
		lastUpdated => 1150167057,
	},

	'isPrototype' => {
		message => q|A conditional indicating whether this Post is a Content Prototype.|,
		lastUpdated => 1150167057,
	},

	'isHidden' => {
		message => q|A conditional indicating whether this Post should be hidden from navigation.|,
		lastUpdated => 1150167057,
	},

	'newWindow' => {
		message => q|A conditional indicating whether this Post should be opened in a new window.|,
		lastUpdated => 1150167057,
	},

	'userDefined1' => {
		message => q|The value contained in the first user defined variable.|,
		lastUpdated => 1150167057,
	},

	'userDefined2' => {
		message => q|The value contained in the second user defined variable.|,
		lastUpdated => 1150167057,
	},

	'userDefined3' => {
		message => q|The value contained in the third user defined variable.|,
		lastUpdated => 1236354498,
	},

	'userDefined4' => {
		message => q|The value contained in the fourth user defined variable.|,
		lastUpdated => 1150167057,
	},

	'userDefined5' => {
		message => q|The value contained in the fifth user defined variable.|,
		lastUpdated => 1150167057,
	},

	'post asset variables title' => {
		message => q|Post Asset Template Variables|,
                lastUpdated => 1164425086,
        },

	'post received' => {
		message => q|Your post has been received and is being processed so it can be added to the site. Please be patient.|,
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

	'notify url' => {
		message => q|The URL to the post that triggered the notification.|,
		lastUpdated => 1149829885,
	},

    'notify.subscription.message' => {
        message => q|Internationalized message that a new message has been posted to a thread that the
user subscribed to.|,
        lastUpdated => 1184174234,
    },

	'notification template body' => {
		message => q|<p>In addition to the common Post Template variables, the Notification Template has these variables:
</p>
|,
		lastUpdated => 1149829939,
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

	'meta_loop' => {
		message => q|A loop containing metadata lables and fields for this Post.  If metadata is not enabled for the site, or if metadata is not enabled for this CS, or if there's no metadata defined for the site, the loop will be empty.|,
		lastUpdated => 1180928713
	},

	'field' => {
		message => q|The form for this metadata field.|,
		lastUpdated => 1180928713
	},

	'name' => {
		message => q|The label for this metadata field.  Metadata labels are not internationalized.|,
		lastUpdated => 1180928713
	},

	'value' => {
		message => q|The value of this metadata field for this post.|,
		lastUpdated => 1180928713
	},

	'meta_X_form' => {
		message => q|The form for a particular metadata field, picked by name.  X is the name of the metadata field, where any spaces in the name have been changed into underscores.|,
		lastUpdated => 1180929142
	},

	'meta_X_value' => {
		message => q|The value for a particular metadata field, picked by name.  X is the name of the metadata field, where any spaces in the name have been changed into underscores.|,
		lastUpdated => 1180931029
	},

	'unsubscribeUrl' => {
		message => q|The URL for the user to unsubscribe.|,
		lastUpdated => 1184174298
	},

	'unsubscribeLinkText' => {
		message => q|The internationalized word "Unsubscribe", to be used a text for the link to unsubscribe.|,
		lastUpdated => 1184174365
	},

    'help url.raw' => {
        message     => 'The URL to the post asset without the #id... at the end. Useful for performing other functions on the post like func=promote or func=demote',
        lastUpdated => 0,
        context     => "Help for the 'url.raw' template var.",
    }
};

1;
