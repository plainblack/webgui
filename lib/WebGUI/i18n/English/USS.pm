package WebGUI::i18n::English::USS;

our $I18N = {
	1 => q|Who can approve?|,

	2 => q|Who can contribute?|,

	92 => q|Open in new window?|,

	3 => q|You have a new user submission to approve.|,

	4 => q|Your submission has been approved.|,

	85 => q|Question|,

	5 => q|Your submission has been denied.|,

	86 => q|Answer|,

	6 => q|Submissions Per Page|,

	91 => q|URL|,

	83 => q|Add a new question.|,

	84 => q|Edit Question|,

	90 => q|Edit Link|,

	12 => q|(Uncheck if you're writing an HTML submission.)|,

	89 => q|Add a new link.|,

	13 => q|Date Submitted|,

	14 => q|Status|,

	15 => q|Edit/Delete|,

	16 => q|Untitled|,

	17 => q|Are you certain you wish to delete this submission?|,

	59 => q|Next Submission|,

	18 => q|Edit User Submission System|,

	19 => q|Edit Submission|,

	20 => q|Post New Submission|,

	21 => q|Submitted By|,

	27 => q|Edit|,

	28 => q|Return To Submissions List|,

	29 => q|User Submission System|,

	31 => q|Content|,

	32 => q|Image|,

	33 => q|Attachment|,

	35 => q|Title|,

	37 => q|Delete|,

	58 => q|Previous Submission|,

	39 => q|Post a Reply|,

	41 => q|Date|,

	46 => q|Read more...|,

	47 => q|Post a Response|,

	48 => q|Allow discussion?|,

	51 => q|Display thumbnails?|,

	52 => q|Thumbnail|,

	53 => q|Layout|,

	57 => q|Responses|,

	76 => q|Submission Template|,

	77 => q|The following are the template variables used in a submission template. Submission templates are used to display the individual submissions in a user submission system.
<p/>

<b>title</b><br/>
The title of this submission.
<p/>

<b>content</b><br/>
The full text content of this submission.
<p/>

<b>user.label</b><br/>
The translated label indicating what user posted this submission.
<p/>

<b>user.profile</b><br/>
The URL to the profile of the user that posted this submission.
<p/>

<b>user.username</b><br/>
The username of the user that posted this submission.
<p/>

<b>user.id</b><br/>
The unique identifier for the user that posted this submission.
<p/>

<b>date.label</b><br/>
The translated label indicating what date this submission was posted.
<p/>

<b>date.epoch</b><br/>
The number of seconds since January 1, 1970 that this submission was posted.
<p/>

<b>date.human</b><br/>
A human readable date that displays the date and time this submission was posted.
<p/>

<b>date.updated.label</b><br/>
The translated label indicating what date this submission was last edited.
<p/>

<b>date.updated.epoch</b><br/>
The number of seconds since January 1, 1970 that this submission was last edited.
<p/>

<b>date.updated.human</b><br/>
A human readable date that displays the date and time this submission was last edited.
<p/>

<b>status.label</b><br/>
A translated label indicating the status of this submission.
<p/>

<b>status.status</b><br/>
The actual status of this submission (pending, approved, denied).
<p/>

<b>views.label</b><br/>
A translated label indicating how many times this submission has been viewed.
<p/>

<b>views.count</b><br/>
The number of times this submission has been viewed.
<p/>

<b>canPost</b><br/>
An condition indicating whether or not this user can post a new submission.
<p/>

<b>post.url</b><br/>
The URL to post a new submission.
<p/>

<b>post.label</b><br/>
A translated label for the post link.
<p/>

<b>previous.more</b><br/>
An condition indicating whether there are any posts prior to this one available for viewing.
<p/>

<b>previous.url</b><br/>
A URL to the post that came before this one.
<p/>

<b>previous.label</b><br/>
A translated label for the previous link.
<p/>

<b>next.more</b><br/>
A condition indicating whether there are any posts after this one available for viewing.
<p/>

<b>next.url</b><br/>
The URL to the post that came after this one.
<p/>

<b>next.label</b><br/>
A translated label for the next link.
<p/>

<b>canEdit</b><br/>
A condition indicating whether the current user cane edit or delete this post.
<p/>

<b>edit.url</b><br/>
The URL to edit this post.
<p/>

<b>edit.label</b><br/>
A translated label for the edit link.
<p/>

<b>delete.url</b><br/>
The URL to delete this post.
<p/>

<b>delete.label</b><br/>
A translated label for the delete link.
<p/>

<b>canChangeStatus</b><br/>
A condition indicating whether the current user has the privileges to change the status of this post.
<p/>

<b>approve.url</b><br/>
The URL to approve this post.
<p/>

<b>approve.label</b><br/>
A translated label for the approve link.
<p/>

<b>deny.url</b><br/>
The URL to deny this post.
<p/>

<b>deny.label</b><br/>
A translated label for the deny link.
<p/>

<b>leave.url</b><br/>
The URL to leave this post in it's current state.
<p/>

<b>leave.label</b><br/>
A translated label for the leave link.
<p/>

<b>canReply</b><br/>
A condition indicating whether the current user can reply to this post.
<p/>

<b>reply.url</b><br/>
The URL to reply to this post.
<p/>

<b>reply.label</b><br/>
A translated label for the reply link.
<p/>

<b>search.url</b><br/>
The URL to toggle on the WebGUI power search form.
<p/>

<b>search.label</b><br/>
A translated label for the search link.
<p/>

<b>back.url</b><br/>
The URL to return the user to the main listing.
<p/>

<b>back.label</b><br/>
A translated label for the back link.
<p/>

<b>replies</b><br/>
A complete listing of all replies to this post.
<p/>

<b>userDefined1.value - userDefined5.value</b><br />
A series of user defined values that can be used to extend the functionality of the USS.
<p>

<b>image.url</b><br>
The URL to the attached image.
<p>

<b>image.thumbnail</b><br>
The URL to the attached image's thumbnail.
<p>

<b>attachment.box</b><br>
A standard WebGUI attachment box which displays the icon for the file, and the filename, along with an attachment icon and all are linked to the file.
<p>

<b>attachment.url</b><br>
The URL to the attached file.
<p>

<b>attachment.icon</b><br>
The icon that represents the attached file's type.
<p>

<b>attachment.name</b><br>
The filename of the attached file.
<p>


|,

	30 => q|Karma Per Submission|,

	73 => q|Submission Template|,

	61 => q|User Submission System, Add/Edit|,

	71 => q|User Submission Systems (USS) are a great way to add a sense of community to any site as well as get free content from your users. The User Submission System name is misleading to some people, because they immediately think of users as visitors. However, users are also staff, or business partners, or even yourself. With the USS you can select who can add new content, and even who can moderate that content.
<br><br>
User Submission systems are so versatile that they allow you to create all kinds of applications, just by editing a few templates. Example applications are Photo Galleries, FAQs, Link Lists, Guest Books, Classifieds, and more.


<p>
<b>Submission Template</b><br/>
Choose a layout for the individual submissions.
<p/>

<b>Submission Form Template</b><br>
Choose a layout of the form users see when submitting content.
<p>


<b>Submissions Per Page</b><br>
How many submissions should be listed per page in the submissions index?
<br><br>


<b>Filter Content</b><br>
Select the level of content filtering you wish to perform on all submitted content.
<p>

<b>Sort By</b><br>
The field to sort the submission list by.
<p>

<b>Sort Order</b><br>
The direction to sort the submission list by.
<p>




<b>Who can approve?</b><br>
What group is allowed to approve and deny content?
<br><br>

<b>Who can contribute?</b><br>
What group is allowed to contribute content?
<br><br>


<b>Default Status</b><br>
Should submissions be set to <i>Approved</i>, <i>Pending</i>, or <i>Denied</i> by default?
<br><br>
<i>Note:</i> If you set the default status to Pending, then be prepared to monitor your message log for new submissions.
<p>

<b>Karma Per Submission</b><br>
How much karma should be given to a user when they contribute to this user submission system?
<p>


<b>Allow discussion?</b><br>
Checking this box will enable responses to your article much like Articles on Slashdot.org.
<p>


|,

	82 => q|Descending|,

	81 => q|Ascending|,

	80 => q|Sort Order|,

	79 => q|Sort By|,

	78 => q|Date Updated|,

	74 => q|User Submission System Template|,

	75 => q|This is the listing of template variables available in user submission system templates.
<p/>

<b>readmore.label</b><br/>
A translated label that indicates that the user should click to read more.
<p/>

<b>responses.label</b><br/>
A translated label that indicates that the user should click to view the responses to this submission.
<p/>

<b>canPost</b><br/>
A condition that indicates whether a user can add a new submission.
<p/>

<b>post.url</b><br/>
The URL to add a new submission.
<p/>

<b>post.label</b><br/>
A translated label for the post link.
<p/>

<b>addquestion.label</b><br>
A translated label that prompts the user to add a question to the USS.
<p>

<b>addlink.label</b><br>
A translated label that prompts the user to add a link to the USS.
<p>

<b>search.label</b><br/>
A translated label for the search link.
<p/>

<b>search.url</b><br/>
The URL to toggle on/off WebGUI's power search form.
<p/>

<b>search.form</b><br/>
WebGUI's power search form.
<p/>

<b>rss.url</b><br>
The URL to generate an RSS feed from the content in the USS.
<p>

<b>canModerate</b><br>
A condition indicating whether the current user has the rights to moderate posts in this USS.
<p>

<b>title.label</b><br/>
A translated label for the title column.
<p/>

<b>thumbnail.label</b><br/>
A translated label for the thumbnail column.
<p/>

<b>date.label</b><br/>
A translated label for the date column.
<p/>

<b>date.updated.label</b><br/>
The translated label indicating what date this submission was last edited.
<p/>

<b>by.label</b><br/>
A translated label stating who the submission was submitted by.
<p/>

<b>submission.edit.label</b><br>
A translated text label that prompts the user to edit a particular submission.
<p>

<b>submissions_loop</b><br/>
A loop containing each submission.
<blockquote>

<b>submission.id</b><br/>
A unique identifier for this submission.
<p/>

<b>submission.url</b><br/>
The URL to view this submission.
<p/>

<b>submission.content</b><br/>
The abbreviated text content of this submission.
<p/>

<b>submission.content.full</b><br/>
The full text content of this submission.
<p/>


<b>submission.responses</b><br/>
The number of responses to this submission.
<p/>

<b>submission.title</b><br/>
The title for this submission.
<p/>

<b>submission.userDefined1 - submission.userDefined5</b><br>
A series of user defined fields to add custom functionality to the USS.
<p>

<b>submission.userId</b><br/>
The user id of the user that posted this submission.
<p/>

<b>submission.username</b><br/>
The username of the person that posted this submission.
<p/>

<b>submission.status</b><br/>
The status of this submission (approved, pending, denied).
<p/>

<b>submission.thumbnail</b><br/>
The thumbnail of the image uploaded with this submission (if any).
<p/>

<b>submission.image</b><br>
The URL of the image attached to this submission.
<p>


<b>submission.date</b><br/>
The that this submission was posted.
<p/>

<b>submission.date.updated</b><br/>
A human readable date that displays the date and time this submission was last edited.
<p/>

<b>submission.currentUser</b><br/>
A condition indicating whether the current user is the same as the user that posted this submission.
<p/>

<b>submission.userProfile</b><br/>
The URL to the profile of the user that posted this submission.
<p/>

<b>submission.edit.url</b><br>
The URL to edit this submission.
<p>


<b>submission.secondColumn</b><br/>
A condition indicating whether or not this submission would belong in the second column, in a multi-column layout.
<p/>

<b>submission.thirdColumn</b><br/>
A condition indicating whether or not this submission would belong in the third column, in a multi-column layout.
<p/>

<b>submission.fourthColumn</b><br/>
A condition indicating whether or not this submission would belong in the fourth column, in a multi-column layout.
<p/>

<b>submission.fifthColumn</b><br/>
A condition indicating whether or not this submission would belong in the fifth column, in a multi-column layout.
<p/>

<b>submission.controls</b><br>
The administrative toolbar for each submission.
<p>

</blockquote>
<p/>

|,

	87 => q|Submission Form Template|,

	88 => q|Sequence|,

	93 => q|Submission Form Template|,

	94 => q|The following template variables are available to you when building your submission form templates.
<p>

<b>submission.isNew</b><br>
A condition indicating whether this is a new submission being contributed.
<p>

<b>link.header.label</b><br>
A header telling the user they are editing a link.
<p>

<b>question.header.label</b><br>
A header telling the user they are editing a question.
<p>

<b>submission.header.label</b><br>
A header telling the user they are editing a submission.
<p>

<b>user.isVisitor</b><br>
A condition indicating whether the current user is a visitor.
<p>

<b>visitorName.label</b><br>
A label for the visitorName.form variable.
<p>

<b>visitorName.form</b><br>
A text box that allows a visitor (non-logged in user) to enter their own name instead of submitting completely anonymously.
<p>

<b>form.header</b><br>
All the information necessary to route the form contents back to WebGUI.
<p>

<b>url.label</b><br>
A generic label for a URL field.
<p>

<b>newWindow.label</b><br>
A generic label for a field asking the user whether they would like links to pop up new windows.
<p>

<b>userDefined1.form - userDefined5.form</b><br>
A series of generic text fields that can be used to extend the functionality of the USS.
<p>

<b>userDefined1.form.yesNo - userDefined5.form.yesNo</b><br>
Yes / No versions of the user defined fields.
<p>

<b>userDefined1.form.textarea - userDefined5.form.textarea</b><br>
Textarea versions of the user defined fields.
<p>

<b>userDefined1.value - userDefined5.value</b><br>
The raw values of the user defined fields.
<p>

<b>question.label</b><br>
A label prompting the user to enter a question.
<p>

<b>title.label</b><br>
A label prompting the user to enter a title.
<p>

<b>title.form</b><br>
A text field for titles or headers for each submission.
<p>

<b>title.form.textarea</b><br>
A textarea version of the title.form field.
<p>

<b>title.value</b><br>
The raw value of the title field.
<p>

<b>body.label</b><br>
A label for the body.form variable.
<p>

<b>answer.label</b><br>
Another label for the body.form variable.
<p>

<b>description.label</b><br>
Another label for the body.form variable.
<p>

<b>body.form</b><br>
An HTML Area field allowing the user to enter descriptive content of this submission.
<p>

<b>body.value</b><br>
The raw content of the body.form field.
<p>

<b>body.form.textarea</b><br>
A textarea version of body.form.
<p>

<b>image.label</b><br>
A label for the image.form variable.
<p>

<b>image.form</b><br>
A field allowing the user to pick an image from his/her hard drive.
<p>

<b>attachment.label</b><br>
A label for the attachment.form variable.
<p>

<b>attachment.form</b><br>
A field allowing the user to pick a file from his/her hard drive to attach to this submission.
<p>

<b>contentType.label</b><br>
A label for the contentType.form variable.
<p>

<b>contentType.form</b><br>
A field allowing the user to select the type of content contained in the form.body field.
<p>

<b>form.submit</b><br>
A submit button.
<p>

<b>form.footer</b><br>
The bottom of the form.
<p>
|,

};

1;
