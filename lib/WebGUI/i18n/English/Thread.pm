package WebGUI::i18n::English::Thread;

our $I18N = {

	'thread template title' => {
		message => q|Thread Template|,
                lastUpdated => 1111253044,
        },

	'thread template body' => {
		message => q|The following variables are available in the Thread template.
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

|,
		lastUpdated => 1111709371,
	},

};

1;
