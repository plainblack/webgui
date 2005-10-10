package WebGUI::i18n::English::Asset_Thread;

our $I18N = {

	'thread template title' => {
		message => q|Thread Template|,
                lastUpdated => 1111253044,
        },

	'thread template body' => {
		message => q|The variables below are available in the Thread template.  In addition, all variables from the Post Template can be used.  Labels for URLs for actions like <b>unlock.url</b>, <b>stick.url</b>, etc. are provided by the Collaboration Labels.  The Pagination Template variables are also available to display multiple pages of posts and threads.
<p>

<b>user.isVisitor</b><br>
A conditional indicating that the current user is a Visitor.
<p>

<b>user.isModerator</b><br>
A conditional indicating that the current user is a Moderator.
<p>

<b>user.canPost</b><br>
A conditional indicating that the current user can add posts to this thread.
<p>

<b>user.canReply</b><br>
A conditional indicating that the current user can reply to posts in this thread.
<p>

<b>repliesAllowed</b><br>
A conditional indicating that replies are allowed in this thread.
<p>

<b>userProfile.url</b><br>
A URL to the profile of the owner of the Post.
<p>

<b>layout.nested.url</b><br>
A URL to change the layout to nest posts.  This lists all posts with indentation to show which posts
are replies to posts and which posts are new topics in a thread.
<p>

<b>layout.flat.url</b><br>
A URL to change the layout to flatten posts.  This lists all posts in the thread in order
of date submitted.
<p>

<b>layout.threaded.url</b><br>
A URL to change the layout to threaded posts.  This is the default setting. Posts will be shown one at a time.
<p>

<b>layout.isFlat</b><br>
A conditional indicating if the current layout is flat.
<p>

<b>layout.isNested</b><br>
A conditional indicating if the current layout is nested.
<p>

<b>layout.isThreaded</b><br>
A conditional indicating if the current layout is threaded.
<p>

<b>user.isSubscribed</b><br>
A conditional that is true if the current user is subscribed to the thread.
<p>

<b>subscribe.url</b><br>
A URL to subscribe the current user to the thread.
<p>

<b>unsubscribe.url</b><br>
A URL to subscribe the current user from the thread.
<p>

<b>isSticky</b><br>
A conditional indicating if the current thread is sticky.
<p>

<b>stick.url</b><br>
The URL to make this thread sticky.
<p>

<b>unstick.url</b><br>
The URL to unstick this thread.
<p>

<b>isLocked</b><br>
A conditional indicating if the current thread is locked.
<p>

<b>lock.url</b><br>
The URL to lock this thread.
<p>

<b>unlock.url</b><br>
The URL to unlock this thread.
<p>

<b>post_loop</b><br>
A loop containing all the posts for this thread.  Each post in the loop
also contains a set of its own Post Template variables.
<p>

<blockquote>

<b>isCurrent</b><br>
A conditional indicating that this Post is the one currently being viewed in the Thread.
<p>

<b>isThreadRoot</b><br>
A conditional indicating that this Post is the start of the Thread.
<p>

<b>depth</b><br>
How far away this post is from the originating post (<b>ThreadRoot</b>).
<p>

<b>depthX10</b><br>
The <b>depth</b> times 10.
<p>

<b>indent_loop</b><br>
A loop that runs <b>depth</b> times.
<p>

<blockquote>

<b>depth</b><br>
A number indicating the loop count of the <b>indent_loop</b>.
<p>

</blockquote>

</blockquote>

<b>add.url</b><br>
The URL to add a new thread.
<p>

<b>previous.url</b><br>
The URL to take you to the previous thread.
<p>

<b>next.url</b><br>
The URL to take you to the next thread.
<p>

<b>search.url</b><br>
The URL to take you to a form to search the forum.
<p>

<b>collaboration.url</b><br>
The URL to take you back to the collaboration system that this post is a part of.
<p>

<b>collaboration.title</b><br>
The title of the collaboration system that this post is a part of.
<p>

<b>collaboration.description</b><br>
The description of the collaboration system that this post is a part of.
<p>

|,
		lastUpdated => 1111768115,
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
