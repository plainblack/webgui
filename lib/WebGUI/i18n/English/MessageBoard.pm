package WebGUI::i18n::English::MessageBoard;

our $I18N = {
	'74' => {
		message => q|The following is the list of template variables available in message board templates.
<p/>

<b>forum.add.url</b><br>
A url that will add a forum to this message board.
<p>

<b>forum.add.label</b><br>
The default label for forum.add.url.
<p>

<b>title.label</b><br>
The default label for the title columnn.
<p>

<b>views.label</b><br>
The default label for the views column.
<p>

<b>rating.label</b><br>
The default label for the ratings column.
<p>

<b>threads.label</b><br>
The default label for the threads column.
<p>

<b>replies.label</b><br>
The default label for the replies column.
<p>

<b>lastpost.label</b><br>
The default label for the last post column.
<p>


<b>forum_loop</b><br>
A loop containing the data for each of the forums contained in this message board.
<p>

<blockquote>

<b>forum.controls</b><br>
The editing controls for this forum.
<p>

<b>forum.count</b><br>
An integer displaying the forum count as it goes through the loop.
<p>

<b>forum.title</b><br>
The title of this forum.
<p>

<b>forum.description</b><br>
The description of this forum.
<p>

<b>forum.replies</b><br>
The number of replies all the threads in this forum have received.
<p>

<b>forum.rating</b><br>
The average rating of all the posts in the forum.
<p>

<b>forum.views</b><br>
The total number of views of all the posts in the forum.
<p>

<b>forum.threads</b><br>
The total number of threads in this forum.
<p>

<b>forum.url</b><br>
The url to view this forum.
<p>

<b>forum.lastpost.url</b><br>
The url to view the last post in this forum.
<p>

<b>forum.lastpost.date</b><br>
The human readable date of the last post in this forum.
<p>

<b>forum.lastpost.time</b><br>
The human readable time of the last post in this forum.
<p>

<b>forum.lastpost.epoch</b><br>
The epoch date of the last post in this forum.
<p>

<b>forum.lastpost.subject</b><br>
The subject of the last post in this forum.
<p>

<b>forum.lastpost.user.id</b><br>
The userid of the last poster.
<p>

<b>forum.lastpost.user.name</b><br>
The username of the last poster.
<p>

<b>forum.lastpost.user.profile</b><br>
The url to the last poster's profile.
<p>

<b>forum.lastpost.user.isVisitor</b><br>
A condition indicating where the last poster was a visitor.
<p>


</blockquote>
<p>

<b>default.listing</b><br>
A full forum rendered using the forum template.
<p>

<b>default.description</b><br>
The description of the default forum.
<p>

<b>default.title</b><br>
The title of the default forum.
<p>

<b>default.controls</b><br>
The controls for the default forum.
<p>

<b>areMultipleForums</b><br>
A condition indicating whether there is more than one forum.
<p>
|,
		lastUpdated => 1066584179
	},

	'6' => {
		message => q|Edit Message Board|,
		lastUpdated => 1031514049
	},

	'75' => {
		message => q|Add a forum|,
		lastUpdated => 1066038194
	},

	'71' => {
		message => q|Message boards, also called Forums and/or Discussions, are a great way to add community to any site or intranet. Many companies use message boards internally to collaborate on projects.
<br><br>
|,
		lastUpdated => 1066584548
	},

	'61' => {
		message => q|Message Board, Add/Edit|,
		lastUpdated => 1066584548
	},

	'78' => {
		message => q|Forum, Add/Edit|,
		lastUpdated => 1066584480
	},

	'2' => {
		message => q|Message Board|,
		lastUpdated => 1031514049
	},

	'79' => {
		message => q|A message board can contain one or more forums. The following is the list of properties attached to each forum.

<p>

<b>Title</b><br>
The title of the forum.
<p>

<b>Description</b><br>
The description of the forum.
<p>

<b>NOTE:</b> All of the properties of the forum system are also here. See that help page for details.|,
		lastUpdated => 1066584480
	},

	'77' => {
		message => q|Edit Forum|,
		lastUpdated => 1066061199
	},

	'73' => {
		message => q|Message Board Template|,
		lastUpdated => 1066584179
	},

	'76' => {
		message => q|Are you certain you wish to delete this forum and all the posts it contains?|,
		lastUpdated => 1066055963
	},
	'90' => {
		message => q|Move Forum|,
		lastUpdated =>1093435103
	},
	'91' => {
		message => q|<br>Select the Message Board you want to move the forum to.|,
		lastUpdated =>1093435103
	},
	'92' => {
		message => q|--- No Change ---|,
		lastUpdated =>1093435103
	}
};

1;
