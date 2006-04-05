package WebGUI::i18n::English::Asset_MessageBoard;

our $I18N = {
	'visitor cache timeout' => {
		message => q|Visitor Cache Timeout|,
		lastUpdated => 0
		},

	'visitor cache timeout help' => {
		message => q|Since all visitors will see this asset the same way, we can cache it to increase performance. How long should we cache it?<br /> <br /><b>UI Level: 8</b>|,
		lastUpdated => 0
		},

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
The default label for the title column.
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

<b>forum.lastpost.user.alias</b><br>
The current alias of the last poster.
<p>

<b>forum.lastpost.user.profile</b><br>
The url to the last poster's profile.
<p>

<b>forum.lastpost.user.isVisitor</b><br>
A conditional indicating whether the last poster was a visitor.
<p>

<b>forum.user.canView</b><br>
A conditional indicating whether the user can view this forum.
<p>

<b>forum.user.canPost</b><br>
A conditional indicating whether the user can post to this forum.
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
The editing controls for the default forum.
<p>

<b>areMultipleForums</b><br>
A conditional indicating whether there is more than one forum.
<p>
|,
		lastUpdated => 1101773945
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
		message => q|Message boards can contain one or more Forums and/or Discussion Boards, are a great way to add community to any site or intranet. Many companies use message boards internally to collaborate on projects.
<br><br>
|,
		lastUpdated => 1100231686
	},

	'61' => {
		message => q|Message Board, Add/Edit|,
		lastUpdated => 1066584548
	},

	'assetName' => {
		message => q|Message Board|,
		lastUpdated => 1128831826
	},

	'73' => {
		message => q|Message Board Template|,
		lastUpdated => 1066584179
	},

	'73 description' => {
		message => q|Choose a template to display your message board|,
		lastUpdated => 1119411673
	},

	'76' => {
		message => q|Are you certain you wish to delete this forum and all the posts it contains?|,
		lastUpdated => 1066055963
	},

	'title' => {
		message => q|Title|,
		lastUpdated => 1109806115,
	},

	'views' => {
		message => q|Views|,
		lastUpdated => 1109806115,
	},

	'rating' => {
		message => q|Rating|,
		lastUpdated => 1109806115,
	},

	'threads' => {
		message => q|Threads|,
		lastUpdated => 1109806115,
	},

	'replies' => {
		message => q|Replies|,
		lastUpdated => 1109806115,
	},

	'lastpost' => {
		message => q|Last Post|,
		lastUpdated => 1109806115,
	},

};

1;
