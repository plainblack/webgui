package WebGUI::i18n::English::Asset_Thread;

our $I18N = {

	'thread template title' => {
		message => q|Thread Template|,
                lastUpdated => 1111253044,
        },

	'thread template body' => {
		message => q|<p>The variables below are available in the Thread template.  In addition, all variables from the Post Template can be used.  Labels for URLs for actions like <b>unlock.url</b>, <b>stick.url</b>, etc. are provided by the Collaboration Labels.  The Pagination Template variables are also available to display multiple pages of posts and threads.
</p>

<p><b>karma.transfer.form</b><br />
A variable that displays a small form that allows a user to transfer an amount of karma from their account to the thread.
</p>

<p><b>karma</b><br />
Indicates the amount of karma this thread has.
</p>

<p><b>karmaScale</b><br />
A weighting factor for difficulty, complexity, or handicap in contests.
</p>

<p><b>karmaRank</b><br />
This is karma divided by karma scale.
</p>

<p><b>thumbsUp.icon.url</b><br />
The URL to the thumbs up icon.
</p>

<p><b>thumbsDown.icon.url</b><br />
The URL to the thumbs down icon.
</p>

<p><b>user.isVisitor</b><br />
A conditional indicating that the current user is a Visitor.
</p>

<p><b>user.isModerator</b><br />
A conditional indicating that the current user is a Moderator.
</p>

<p><b>user.canPost</b><br />
A conditional indicating that the current user can add posts to this thread.
</p>

<p><b>user.canReply</b><br />
A conditional indicating that the current user can reply to posts in this thread.
</p>

<p><b>repliesAllowed</b><br />
A conditional indicating that replies are allowed in this thread.
</p>

<p><b>userProfile.url</b><br />
A URL to the profile of the owner of the Post.
</p>

<p><b>layout.nested.url</b><br />
A URL to change the layout to nest posts.  This lists all posts with indentation to show which posts
are replies to posts and which posts are new topics in a thread.
</p>

<p><b>layout.flat.url</b><br />
A URL to change the layout to flatten posts.  This lists all posts in the thread in order
of date submitted.
</p>

<p><b>layout.threaded.url</b><br />
A URL to change the layout to threaded posts.  This is the default setting. Posts will be shown one at a time.
</p>

<p><b>layout.isFlat</b><br />
A conditional indicating if the current layout is flat.
</p>

<p><b>layout.isNested</b><br />
A conditional indicating if the current layout is nested.
</p>

<p><b>layout.isThreaded</b><br />
A conditional indicating if the current layout is threaded.
</p>

<p><b>user.isSubscribed</b><br />
A conditional that is true if the current user is subscribed to the thread.
</p>

<p><b>subscribe.url</b><br />
A URL to subscribe the current user to the thread.
</p>

<p><b>unsubscribe.url</b><br />
A URL to subscribe the current user from the thread.
</p>

<p><b>isArchived</b><br />
A conditional indicating if the current thread is archived.
</p>

<p><b>archive.url</b><br />
The URL to archive this thread.
</p>

<p><b>unarchive.url</b><br />
The URL to unarchive this thread.
</p>

<p><b>isSticky</b><br />
A conditional indicating if the current thread is sticky.
</p>

<p><b>stick.url</b><br />
The URL to make this thread sticky.
</p>

<p><b>unstick.url</b><br />
The URL to unstick this thread.
</p>

<p><b>isLocked</b><br />
A conditional indicating if the current thread is locked.
</p>

<p><b>lock.url</b><br />
The URL to lock this thread.
</p>

<p><b>unlock.url</b><br />
The URL to unlock this thread.
</p>

<p><b>post_loop</b><br />
A loop containing all the posts for this thread.  Each post in the loop
also contains a set of its own Post Template variables.
</p>

<div class="helpIndent">

<p><b>isCurrent</b><br />
A conditional indicating that this Post is the one currently being viewed in the Thread.
</p>

<p><b>isThreadRoot</b><br />
A conditional indicating that this Post is the start of the Thread.
</p>

<p><b>depth</b><br />
How far away this post is from the originating post (<b>ThreadRoot</b>).
</p>

<p><b>depthX10</b><br />
The <b>depth</b> times 10.
</p>

<p><b>indent_loop</b><br />
A loop that runs <b>depth</b> times.
</p>

<div class="helpIndent">

<p><b>depth</b><br />
A number indicating the loop count of the <b>indent_loop</b>.
</p>

</div>

</div>

<p><b>add.url</b><br />
The URL to add a new thread.
</p>

<p><b>previous.url</b><br />
The URL to take you to the previous thread.
</p>

<p><b>next.url</b><br />
The URL to take you to the next thread.
</p>

<p><b>search.url</b><br />
The URL to take you to a form to search the forum.
</p>

<p><b>collaboration.url</b><br />
The URL to take you back to the collaboration system that this post is a part of.
</p>

<p><b>collaboration.title</b><br />
The title of the collaboration system that this post is a part of.
</p>

<p><b>collaboration.description</b><br />
The description of the collaboration system that this post is a part of.
</p>

|,
		lastUpdated => 1145111313,
	},

        'assetName' => {
                message => q|Thread|,
                context => q|label for Asset Manager, getName|,
                lastUpdated => 1128829674,
        },

	'new file description' => {
		message => q|Enter the path to a file, or use the "Browse" button to find a file on your local hard drive that you would like to be uploaded.|,
		lastUpdated => 1119068745
	},

};

1;
