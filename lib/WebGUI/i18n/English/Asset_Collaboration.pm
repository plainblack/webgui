package WebGUI::i18n::English::Asset_Collaboration;

our $I18N = {

	'archive' => {
		message => q|Archive|,
		lastUpdated => 0,
		context => q|thread link|
		},

	'unarchive' => {
		message => q|Unarchive|,
		lastUpdated => 0,
		context => q|thread link|
		},

	'require subscription for email posting' => {
		message => q|Require subscription for email posts?|,
		lastUpdated => 0,
		context => q|field label for mail setting|
		},

	'require subscription for email posting help' => {
		message => q|If this is set to yes, then the user not only has to be in the group to post, but must also be subscribed to the collaboration system or thread in order to post to it.|,
		lastUpdated => 0,
		context => q|help for mail setting field label|
		},

	'auto subscribe to thread' => {
		message => q|Auto subscribe to thread?|,
		lastUpdated => 0,
		context => q|field label for mail setting|
		},

	'auto subscribe to thread help' => {
		message => q|If the user is not subscribed to a thread, nor the collaboration system, and they post to the CS via email, should the be subscribed to the thread? If this is set to yes, they will be. Note that this option only works if the 'Require subscription for email posts?' field is set to 'no'.|,
		lastUpdated => 0,
		context => q|help for mail setting field label|
		},

	'mail prefix' => {
		message => q|Prefix|,
		lastUpdated => 0,
		context => q|field label for mail setting|
		},

	'mail prefix help' => {
		message => q|This string will be prepended to the subject line of all emails sent out from this collaboration system.|,
		lastUpdated => 0,
		context => q|help for mail setting field label|
		},

	'get mail interval' => {
		message => q|Check Mail Every|,
		lastUpdated => 0,
		context => q|field label for mail setting|
		},

	'get mail interval help' => {
		message => q|How often should we check for mail on the server?|,
		lastUpdated => 0,
		context => q|help for mail setting field label|
		},

	'mail password' => {
		message => q|Password|,
		lastUpdated => 0,
		context => q|field label for mail setting|
		},

	'mail password help' => {
		message => q|The password of the account to log in to the server with.|,
		lastUpdated => 0,
		context => q|help for mail setting field label|
		},

	'mail address' => {
		message => q|Address|,
		lastUpdated => 0,
		context => q|field label for mail setting|
		},

	'mail address help' => {
		message => q|The email address that users can send messages to in order to post messages.|,
		lastUpdated => 0,
		context => q|help for mail setting field label|
		},

	'mail account' => {
		message => q|Account|,
		lastUpdated => 0,
		context => q|field label for mail setting|
		},

	'mail account help' => {
		message => q|The account name (username / email address) to use to log in to the mail server.|,
		lastUpdated => 0,
		context => q|help for mail setting field label|
		},

	'mail server' => {
		message => q|Server|,
		lastUpdated => 0,
		context => q|field label for mail setting|
		},

	'mail server help' => {
		message => q|The hostname or IP address of the mail server to fetch mail from.|,
		lastUpdated => 0,
		context => q|help for mail setting field label|
		},

	'get mail' => {
		message => q|Get mail?|,
		lastUpdated => 0,
		context => q|field label for mail setting|
		},

	'get mail help' => {
		message => q|Do you want to have this Collaboration System fetch posts from an email account?|,
		lastUpdated => 0,
		context => q|help for mail setting field label|
		},

	'mail' => {
		message => q|Mail|,
		lastUpdated => 0,
		context => q|the name of the email settings tab|
		},

	'rejected' => {
		message => q|Rejected|,
		lastUpdated => 0,
		context => q|prepended to subject line in rejection emails|
		},

	'rejected because no user account' => {
		message => q|You are not allowed to post messages because we could not find your user account. Perhaps you do not have this email address associated with your user account.|,
		lastUpdated => 0,
		context => q|rejection letter for posting when a user account could not be looked up|
		},

	'rejected because not allowed' => {
		message => q|You are not allowed to post messages because you either have insufficient privileges, or you are not subscribed to this discussion.|,
		lastUpdated => 0,
		context => q|rjection letter for posting when not subscribed or not in group to post|
		},

	'get cs mail' => {
		message => q|Get Collaboration System Mail|,
		lastUpdated => 0,
		context => q|Title of CS Get Mail workflow activity|
		},

	'visitor cache timeout' => {
		message => q|Visitor Cache Timeout|,
		lastUpdated => 0
		},

	'visitor cache timeout help' => {
		message => q|Since all visitors will see this asset the same way, we can cache it to increase performance. How long should we cache it?|,
		lastUpdated => 0
		},

	'karma rank' => {
		message => q|Karma Rank|,
		context => q|a label used in sorting threads by karma divided by karma scale|,
		lastUpdated => 0,
	},

	'default karma scale' => {
		message => q|Default Karma Scale|,
		context => q|a label indicating the default scale of all threads in the system|,
		lastUpdated => 0,
	},

	'default karma scale help' => {
		message => q|This is the default value that will be assigned to the karma scale field in threads. Karma scale is a weighting mechanism for karma sorting that can be used for handicaps, difficulty, etc.|,
		context => q|hover help for the default karma scale field|,
		lastUpdated => 0,
	},

	'assetName' => {
		message => q|Collaboration System|,
		context => q|label for Asset Manager|,
		lastUpdated => 1128831039,
	},

	'preview' => {
		message => q|preview|,
		lastUpdated => 0,
	},

	'karma spent to rate' => {
		message => q|Karma Spent To Rate|,
		lastUpdated => 0,
	},

	'karma rating multiplier' => {
		message => q|Karma Given To Poster on Rating|,
		lastUpdated => 1141142205,
	},

	'display last reply' => {
		message => q|Display last reply?|,
		lastUpdated => 1109618544,
	},

	'sequence' => {
		message => q|Sequence|,
		lastUpdated => 1113761865,
	},

	'date updated' => {
		message => q|Date Updated|,
		lastUpdated => 1113761865,
	},

	'date submitted' => {
		message => q|Date Submitted|,
		lastUpdated => 1113761865,
	},

	'user defined 1' => {
		message => q|User Defined 1|,
		lastUpdated => 1109618544,
	},

	'user defined 2' => {
		message => q|User Defined 2|,
		lastUpdated => 1109618544,
	},

	'user defined 3' => {
		message => q|User Defined 3|,
		lastUpdated => 1109618544,
	},

	'user defined 4' => {
		message => q|User Defined 4|,
		lastUpdated => 1109618544,
	},

	'user defined 5' => {
		message => q|User Defined 5|,
		lastUpdated => 1109618544,
	},

	'ascending' => {
		message => q|Ascending|,
		lastUpdated => 1113673328,
	},

	'descending' => {
		message => q|Descending|,
		lastUpdated => 1113673330,
	},

	'add' => {
		message => q|Add|,
		lastUpdated => 1109618544,
	},

	'addlink' => {
		message => q|Add a link|,
		lastUpdated => 1109618544,
	},

	'addquestion' => {
		message => q|Add a question|,
		lastUpdated => 1109618544,
	},

	'answer' => {
		message => q|Answer|,
		lastUpdated => 1109618544,
	},

	'attachment' => {
		message => q|Attachment|,
		lastUpdated => 1109618544,
	},

	'by' => {
		message => q|By|,
		lastUpdated => 1109618544,
	},

	'body' => {
		message => q|Body|,
		lastUpdated => 1109618544,
	},

	'back' => {
		message => q|Back|,
		lastUpdated => 1109618544,
	},

	'contentType' => {
		message => q|Content Type|,
		lastUpdated => 1109618544,
	},

	'open' => {
		message => q|Open|,
		lastUpdated => 1109618544,
	},

	'closed' => {
		message => q|Closed|,
		lastUpdated => 1109618544,
	},

	'transfer karma' => {
		message => q|Transfer Karma|,
		lastUpdated => 1109618544,
	},

	'karma scale' => {
		message => q|Karma Scale|,
		lastUpdated => 1109618544,
	},

	'close' => {
		message => q|Close|,
		lastUpdated => 1109618544,
	},

	'critical' => {
		message => q|Critical (mostly not working)|,
		lastUpdated => 1109618544,
	},

	'cosmetic' => {
		message => q|Cosmetic (misspelling, formatting problems)|,
		lastUpdated => 1109618544,
	},

	'minor' => {
		message => q|Minor (annoying, but not harmful)|,
		lastUpdated => 1109618544,
	},

	'fatal' => {
		message => q|Fatal (can't continue until this is resolved)|,
		lastUpdated => 1109618544,
	},

	'severity' => {
		message => q|Severity|,
		lastUpdated => 1109618544,
	},

	'date' => {
		message => q|Date|,
		lastUpdated => 1109618544,
	},

	'delete' => {
		message => q|Delete|,
		lastUpdated => 1109618544,
	},

	'description' => {
		message => q|Description|,
		lastUpdated => 1109618544,
	},

	'edit' => {
		message => q|Edit|,
		lastUpdated => 1109618544,
	},

	'flatLayout' => {
		message => q|Flat|,
		lastUpdated => 1109618544,
	},

	'image' => {
		message => q|Image|,
		lastUpdated => 1109618544,
	},

	'edit link' => {
		message => q|Edit Link|,
		lastUpdated => 1109697313,
	},

	'lastReply' => {
		message => q|Last Reply|,
		lastUpdated => 1109618544,
	},

	'lock' => {
		message => q|Lock|,
		lastUpdated => 1109618544,
	},

	'layout' => {
		message => q|Layout|,
		lastUpdated => 1109618544,
	},

	'edit message' => {
		message => q|Edit Message|,
		lastUpdated => 1109696027,
	},

	'message' => {
		message => q|Message|,
		lastUpdated => 1109696029,
	},

	'next' => {
		message => q|Next|,
		lastUpdated => 1109696029,
	},

	'new window' => {
		message => q|Open in new window?|,
		lastUpdated => 1109696029,
	},

	'nested' => {
		message => q|Nested|,
		lastUpdated => 1109696029,
	},

	'previous' => {
		message => q|Previous|,
		lastUpdated => 1109696029,
	},

	'post' => {
		message => q|Post|,
		lastUpdated => 1109697351,
	},

	'question' => {
		message => q|Question|,
		lastUpdated => 1109696720,
	},

	'edit question' => {
		message => q|Edit Question|,
		lastUpdated => 1109696722,
	},

	'rating' => {
		message => q|Rating|,
		lastUpdated => 1109696029,
	},

	'rate' => {
		message => q|Rate|,
		lastUpdated => 1109696029,
	},

	'reply' => {
		message => q|Reply|,
		lastUpdated => 1109696029,
	},

	'replies' => {
		message => q|Replies|,
		lastUpdated => 1109696029,
	},

	'read more' => {
		message => q|Read More|,
		lastUpdated => 1109696029,
	},

	'responses' => {
		message => q|Responses|,
		lastUpdated => 1109696029,
	},

	'search' => {
		message => q|Search|,
		lastUpdated => 1109696029,
	},

	'subject' => {
		message => q|Subject|,
		lastUpdated => 1109696029,
	},

	'subscribe' => {
		message => q|Subscribe|,
		lastUpdated => 1109696029,
	},

	'edit submission' => {
		message => q|Edit Submission|,
		lastUpdated => 1109696029,
	},

	'edit job' => {
		message => q|Edit Job Posting|,
		lastUpdated => 1109696029,
	},

	'job description' => {
		message => q|Job Description|,
		lastUpdated => 1109696029,
	},

	'job title' => {
		message => q|Job Title|,
		lastUpdated => 1109696029,
	},

	'job requirements' => {
		message => q|Job Requirements|,
		lastUpdated => 1109696029,
	},

	'location' => {
		message => q|Location|,
		lastUpdated => 1109696029,
	},

	'compensation' => {
		message => q|Compensation|,
		lastUpdated => 1109696029,
	},

	'synopsis' => {
		message => q|Summary|,
		lastUpdated => 1109696029,
	},

	'sticky' => {
		message => q|Make Sticky|,
		lastUpdated => 1109697033,
	},

	'status' => {
		message => q|Status|,
		lastUpdated => 1109697030,
	},

	'thumbnail' => {
		message => q|Thumbnail|,
		lastUpdated => 1109696029,
	},

	'title' => {
		message => q|Title|,
		lastUpdated => 1109696029,
	},

	'unlock' => {
		message => q|Unlock|,
		lastUpdated => 1109696029,
	},

	'unstick' => {
		message => q|Unstick|,
		lastUpdated => 1109696029,
	},

	'unsubscribe' => {
		message => q|Unsubscribe|,
		lastUpdated => 1109696029,
	},

	'url' => {
		message => q|URL|,
		lastUpdated => 1109696029,
	},

	'user' => {
		message => q|User|,
		lastUpdated => 1109696029,
	},

	'views' => {
		message => q|Views|,
		lastUpdated => 1109696029,
	},

	'visitor' => {
		message => q|Visitor Name|,
		lastUpdated => 1109696029,
	},

	'system template' => {
		message => q|Collaboration System Template|,
		lastUpdated => 1109698614,
	},

	'thread template' => {
		message => q|Thread Template|,
		lastUpdated => 1109698614,
	},

	'post template' => {
		message => q|Post Form Template|,
		lastUpdated => 1109698614,
	},

	'search template' => {
		message => q|Search Template|,
		lastUpdated => 1109698614,
	},

	'notification template' => {
		message => q|Notification Template|,
		lastUpdated => 1109698614,
	},

	'rss template' => {
		message => q|RSS Template|,
		lastUpdated => 1109698614,
	},

	'who posts' => {
		message => q|Who can post?|,
		lastUpdated => 1109698614,
	},

	'threads/page' => {
		message => q|Threads Per Page|,
		lastUpdated => 1109698614,
	},

	'posts/page' => {
		message => q|Posts Per Page|,
		lastUpdated => 1109698614,
	},

	'karma/post' => {
		message => q|Karma Per Post|,
		lastUpdated => 1109698614,
	},

	'filter code' => {
		message => q|Filter Code|,
		lastUpdated => 1109698614,
	},

	'sort by' => {
		message => q|Sort By|,
		lastUpdated => 1109698614,
	},

	'sort order' => {
		message => q|Sort Order|,
		lastUpdated => 1109698614,
	},

	'archive after' => {
		message => q|Archive After|,
		lastUpdated => 1109698614,
	},

	'attachments/post' => {
		message => q|Attachments Per Post|,
		lastUpdated => 1109698614,
	},

	'edit timeout' => {
		message => q|Edit Timeout|,
		lastUpdated => 1109698614,
	},

	'allow replies' => {
		message => q|Allow Replies|,
		lastUpdated => 1109698614,
	},

	'edit stamp' => {
		message => q|Add edit stamp to posts?|,
		lastUpdated => 1109698614,
	},

	'rich editor' => {
		message => q|Rich Editor|,
		lastUpdated => 0,
	},

	'content filter' => {
		message => q|Use content filter?|,
		lastUpdated => 1109698614,
	},

	'use preview' => {
		message => q|Use preview?|,
		lastUpdated => 1109698614,
	},

	'collaboration template labels title' => {
		message => q|Collaboration Template Labels|,
                lastUpdated => 1111520746,
        },

	'word' => {
		context => q|Helper phrase for autogenerated documentation for labels|,
		message => q|The word|,
                lastUpdated => 1111533791,
        },

	'phrase' => {
		context => q|Helper phrase for autogenerated documentation for labels|,
		message => q|The phrase|,
                lastUpdated => 1111533788,
        },

	'collaboration template labels body' => {
		context => q|Note to translators, this text is largely autogenerated.  Please just translate the paragraph at the beginning of the message and leave the rest.|,
		message => q|<p>These labels are available in the templates of several Assets and Wobjects, but all of them may not be useful.   Please consult the template documentation for the Asset or Wobject to see which are used.
</p>

<p><b>add.label</b><br />
^International("word","Asset_Collaboration"); "^International("add","Asset_Collaboration");".
</p>

<p><b>addlink.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("addlink","Asset_Collaboration");".
</p>

<p><b>addquestion.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("addquestion","Asset_Collaboration");".
</p>

<p><b>answer.label</b><br />
^International("word","Asset_Collaboration"); "^International("answer","Asset_Collaboration");".
</p>

<p><b>attachment.label</b><br />
^International("word","Asset_Collaboration"); "^International("attachment","Asset_Collaboration");".
</p>

<p><b>by.label</b><br />
^International("word","Asset_Collaboration"); "^International("by","Asset_Collaboration");".
</p>

<p><b>body.label</b><br />
^International("word","Asset_Collaboration"); "^International("body","Asset_Collaboration");".
</p>

<p><b>back.label</b><br />
^International("word","Asset_Collaboration"); "^International("back","Asset_Collaboration");".
</p>

<p><b>compensation.label</b><br />
^International("word","Asset_Collaboration"); "^International("compensation","Asset_Collaboration");".
</p>

<p><b>open.label</b><br />
^International("word","Asset_Collaboration"); "^International("open","Asset_Collaboration");".
</p>

<p><b>close.label</b><br />
^International("word","Asset_Collaboration"); "^International("close","Asset_Collaboration");".
</p>

<p><b>closed.label</b><br />
^International("word","Asset_Collaboration"); "^International("closed","Asset_Collaboration");".
</p>

<p><b>critical.label</b><br />
^International("word","Asset_Collaboration"); "^International("critical","Asset_Collaboration");".
</p>

<p><b>minor.label</b><br />
^International("word","Asset_Collaboration"); "^International("minor","Asset_Collaboration");".
</p>

<p><b>cosmetic.label</b><br />
^International("word","Asset_Collaboration"); "^International("cosmetic","Asset_Collaboration");".
</p>

<p><b>fatal.label</b><br />
^International("word","Asset_Collaboration"); "^International("fatal","Asset_Collaboration");".
</p>

<p><b>severity.label</b><br />
^International("word","Asset_Collaboration"); "^International("severity","Asset_Collaboration");".
</p>

<p><b>date.label</b><br />
^International("word","Asset_Collaboration"); "^International("date","Asset_Collaboration");".
</p>

<p><b>delete.label</b><br />
^International("word","Asset_Collaboration"); "^International("delete","Asset_Collaboration");".
</p>

<p><b>description.label</b><br />
^International("word","Asset_Collaboration"); "^International("description","Asset_Collaboration");".
</p>

<p><b>edit.label</b><br />
^International("word","Asset_Collaboration"); "^International("edit","Asset_Collaboration");".
</p>

<p><b>image.label</b><br />
^International("word","Asset_Collaboration"); "^International("image","Asset_Collaboration");".
</p>

<p><b>job.header.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("edit job","Asset_Collaboration");".
</p>

<p><b>job.title.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("job title","Asset_Collaboration");".
</p>

<p><b>job.description.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("job description","Asset_Collaboration");".
</p>

<p><b>job.requirements.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("job requirements","Asset_Collaboration");".
</p>

<p><b>location.label</b><br />
^International("word","Asset_Collaboration"); "^International("location","Asset_Collaboration");".
</p>

<p><b>layout.flat.label</b><br />
^International("word","Asset_Collaboration"); "^International("flatLayout","Asset_Collaboration");".
</p>

<p><b>link.header.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("edit link","Asset_Collaboration");".
</p>

<p><b>lastReply.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("lastReply","Asset_Collaboration");".
</p>

<p><b>lock.label</b><br />
^International("word","Asset_Collaboration"); "^International("lock","Asset_Collaboration");".
</p>

<p><b>layout.label</b><br />
^International("word","Asset_Collaboration"); "^International("layout","Asset_Collaboration");".
</p>

<p><b>message.header.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("edit message","Asset_Collaboration");".
</p>

<p><b>message.label</b><br />
^International("word","Asset_Collaboration"); "^International("message","Asset_Collaboration");".
</p>

<p><b>next.label</b><br />
^International("word","Asset_Collaboration"); "^International("next","Asset_Collaboration");".
</p>

<p><b>newWindow.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("new window","Asset_Collaboration");".
</p>

<p><b>layout.nested.label</b><br />
^International("word","Asset_Collaboration"); "^International("nested","Asset_Collaboration");".
</p>

<p><b>previous.label</b><br />
^International("word","Asset_Collaboration"); "^International("previous","Asset_Collaboration");".
</p>

<p><b>post.label</b><br />
^International("word","Asset_Collaboration"); "^International("post","Asset_Collaboration");".
</p>

<p><b>question.label</b><br />
^International("word","Asset_Collaboration"); "^International("question","Asset_Collaboration");".
</p>

<p><b>question.header.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("edit question","Asset_Collaboration");".
</p>

<p><b>rating.label</b><br />
^International("word","Asset_Collaboration"); "^International("rating","Asset_Collaboration");".
</p>

<p><b>rate.label</b><br />
^International("word","Asset_Collaboration"); "^International("rate","Asset_Collaboration");".
</p>

<p><b>reply.label</b><br />
^International("word","Asset_Collaboration"); "^International("reply","Asset_Collaboration");".
</p>

<p><b>replies.label</b><br />
^International("word","Asset_Collaboration"); "^International("replies","Asset_Collaboration");".
</p>

<p><b>readmore.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("read more","Asset_Collaboration");".
</p>

<p><b>responses.label</b><br />
^International("word","Asset_Collaboration"); "^International("responses","Asset_Collaboration");".
</p>

<p><b>search.label</b><br />
^International("word","Asset_Collaboration"); "^International("search","Asset_Collaboration");".
</p>

<p><b>subject.label</b><br />
^International("word","Asset_Collaboration"); "^International("subject","Asset_Collaboration");".
</p>

<p><b>subscribe.label</b><br />
^International("word","Asset_Collaboration"); "^International("subscribe","Asset_Collaboration");".
</p>

<p><b>submission.header.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("edit submission","Asset_Collaboration");".
</p>

<p><b>stick.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("sticky","Asset_Collaboration");".
</p>

<p><b>status.label</b><br />
^International("word","Asset_Collaboration"); "^International("status","Asset_Collaboration");".
</p>

<p><b>synopsis.label</b><br />
^International("word","Asset_Collaboration"); "^International("synopsis","Asset_Collaboration");".
</p>

<p><b>thumbnail.label</b><br />
^International("word","Asset_Collaboration"); "^International("thumbnail","Asset_Collaboration");".
</p>

<p><b>title.label</b><br />
^International("word","Asset_Collaboration"); "^International("title","Asset_Collaboration");".
</p>

<p><b>unlock.label</b><br />
^International("word","Asset_Collaboration"); "^International("unlock","Asset_Collaboration");".
</p>

<p><b>unstick.label</b><br />
^International("word","Asset_Collaboration"); "^International("unstick","Asset_Collaboration");".
</p>

<p><b>unsubscribe.label</b><br />
^International("word","Asset_Collaboration"); "^International("unsubscribe","Asset_Collaboration");".
</p>

<p><b>url.label</b><br />
^International("word","Asset_Collaboration"); "^International("url","Asset_Collaboration");".
</p>

<p><b>user.label</b><br />
^International("word","Asset_Collaboration"); "^International("user","Asset_Collaboration");".
</p>

<p><b>views.label</b><br />
^International("word","Asset_Collaboration"); "^International("views","Asset_Collaboration");".
</p>

<p><b>visitorName.label</b><br />
^International("phrase","Asset_Collaboration"); "^International("visitor","Asset_Collaboration");".
</p>

|,
		lastUpdated => 1146153770
	},
	
	'collaboration add/edit title' => {
		message => q|Collaboration, Add/Edit|,
		lastUpdated => 1113673895,
	},

	'collaboration add/edit body' => {
		message => q|<p>This Asset is used to hold a collection of Posts submitted by users and content managers.  Based on how it is configured and which templates it uses, it can be used to build message boards, photo galleries, weblogs, FAQ lists and many more tools for your website.</p>
<p>When a Post is deleted from a Collaboration Asset, it goes into the trash and all replies or children
of that post are removed from the Collaboration Asset, and the reply counter is decremented.  The Post
you deleted may be restored from the Trash.  This will also restore all the replies to that Post.
However, it is not possible to restore the children of the Post directly, without restoring the
Post that was originally deleted.
</p>

<p>Collaboration Assets have the properties of Assets and Wobjects, as well as the
properties listed below:</p>
                |,
		lastUpdated => 1113974026,
	},

        'display last reply description' => {
                message => q|If set to Yes, template variables will be added to allow the display the last Post.|,
                lastUpdated => 1119070429,
        },

        'system template description' => {
                message => q|This is the master template for the Collaboration Asset.|,
                lastUpdated => 1119070429,
        },

        'thread template description' => {
                message => q|The template to display a thread.|,
                lastUpdated => 1119070429,
        },

        'post template description' => {
                message => q|The template for an individual post.|,
                lastUpdated => 1119070429,
        },

        'search template description' => {
                message => q|The template for this Collaboration Asset"s search form and results.|,
                lastUpdated => 1119070429,
        },

        'notification template description' => {
                message => q|The template used to generate emails for users who have subscribed to this Asset.|,
                lastUpdated => 1119070429,
        },
        'rss template description' => {
                message => q|The template used to generate the xml for an rss feed based on this Asset.|,
                lastUpdated => 1119070429,
        },

        'approval workflow description' => {
                message => q|Choose a workflow to be executed on each post as it gets submitted.|,
                lastUpdated => 0,
        },

        'approval workflow' => {
                message => q|Approval Workflow|,
                lastUpdated => 0,
        },

        'who posts description' => {
                message => q|The group allowed to submit posts to this Asset.|,
                lastUpdated => 1119070429,
        },

        'threads/page description' => {
                message => q|The number of threads displayed on each page in the system template.
Setting this number very high can slow the generation of the page.|,
                lastUpdated => 1119070429,
        },

        'posts/page description' => {
                message => q|The number of posts displayed on each page in the thread template.
Setting this number very high can slow the generation of the page.|,
                lastUpdated => 1119070429,
        },

        'karma/post description' => {
                message => q|If Karma is enabled on your site, the amount of Karma added for each Post
submitted by a user.|,
                lastUpdated => 1119070429,
        },

        'karma spent to rate description' => {
                message => q|If karma is enabled on your site, this amount will be subtracted from the user rating a post as sort of a cost of rating posts. It is meant to keep users in check from just rating everything without thinking about the rating.|,
                lastUpdated => 1119070429,
        },

        'karma rating multiplier description' => {
                message => q|If karma is enabled on your site, this will be the amount of karma the original author of the post receives when another user rates the post.|,
                lastUpdated => 1141142205,
        },

        'filter code description' => {
                message => q|Sets the level of HTML filtering done on each Post.|,
                lastUpdated => 1119070429,
        },

        'sort by description' => {
                message => q|By default, all posts are displayed in a sorted order.  Use this
field to choose by what property they are sorted.  Multiple properties
may be selected.|,
                lastUpdated => 1119070429,
        },

        'sort order description' => {
                message => q|Sort in ascending or descending order.|,
                lastUpdated => 1119070429,
        },

        'archive after description' => {
                message => q|The time, after which a Post is last updated, it will be archived.|,
                lastUpdated => 1119070429,
        },

        'attachments/post description' => {
                message => q|How many attachments may be added to each post?|,
                lastUpdated => 1119070429,
        },

        'edit timeout description' => {
                message => q|After this timeout is reached, the Post can no longer be edited by
the original poster.|,
                lastUpdated => 1132355854,
        },

        'allow replies description' => {
                message => q|Select "No" to prevent people from replying to this Post.|,
                lastUpdated => 1119070429,
        },

        'edit stamp description' => {
                message => q|Select "Yes" to add a stamp to each Post saying when it was last edited.|,
                lastUpdated => 1119070429,
        },

        'rich editor description' => {
                message => q|Select "Yes" to enable Rich Editing of content in Posts.|,
                lastUpdated => 1119070429,
        },

        'content filter description' => {
                message => q|Select "Yes" to filter the content in each Post with the Replacements System.|,
                lastUpdated => 1119070429,
        },

        'use preview description' => {
                message => q|Select "Yes" to display a preview of the Post to the user before submitting it.  While
the preview is displayed, the Post can either be edited or canceled.|,
                lastUpdated => 1119070429,
        },

	'collaboration post list template variables title' => {
		message => q|Collaboration, Post List Template Variables|,
		lastUpdated => 1113673895,
	},

	'collaboration post list template variables body' => {
		message => q|<p>These variables are available in several of the templates
used by Collaboration Assets:</p>

<p><b>post_loop</b><br />
A list of posts for this Collateral Asset.
</p>

<div class="helpIndent">

<p><b>Asset variables</b><br />
The variables common to all Assets, such as <b>title</b>, <b>menuTitle</b>, etc.
</p>

<p><b>Post variables</b><br />
All template variables from the Post template.  Some of those variables will be duplicates
of the ones below.
</p>

<p><b>id</b><br />
The AssetId of this Post.
</p>

<p><b>url</b><br />
The URL of this Post.
</p>

<p><b>rating_loop</b><br />
A loop that runs once for each point of <b>rating</b> that the Post has
</p>

<div class="helpIndent">

<p><b>rating_loop.count</b><br />
The index variable for the <b>rating_loop</b>.
</p>

</div>

<p><b>content</b><br />
The formatted content of this Post.
</p>

<p><b>status</b><br />
The status of this Post.
</p>

<p><b>thumbnail</b><br />
If this Post has attachments, the URL for the thumbnail of the first image attachment.
</p>

<p><b>image.url</b><br />
If this Post has attachments, the URL for the first image attachment.
</p>

<p><b>dateSubmitted.human</b><br />
The date this Post was submitted, in a human readable format.
</p>

<p><b>dateUpdated.human</b><br />
The date this Post was last updated, in a human readable format.
</p>

<p><b>timeSubmitted.human</b><br />
The time this Post was submitted, in a human readable format.
</p>

<p><b>timeUpdated.human</b><br />
The time this Post was last updated, in a human readable format.
</p>

<p><b>userProfile.url</b><br />
The URL to the Profile of the User who submitted this Post.
</p>

<p><b>user.isVisitor</b><br />
A conditional that is true if the poster is a visitor.
</p>

<p><b>edit.url</b><br />
The URL to edit this Post.
</p>

<p><b>controls</b><br />
A set of editing icons to delete or re-order this Post.
</p>

<p><b>isSecond</b><br />
A conditional indicating that is true if this Post is the second in this Collaboration Asset.
</p>

<p><b>isThird</b><br />
A conditional indicating that is true if this Post is the third in this Collaboration Asset.
</p>

<p><b>isFourth</b><br />
A conditional indicating that is true if this Post is the fourth in this Collaboration Asset.
</p>

<p><b>isFifth</b><br />
A conditional indicating that is true if this Post is the fifth in this Collaboration Asset.
</p>

<p><b>user.isPoster</b><br />
A conditional indicating that is true if the current user submitted this Post.
</p>

<p><b>user.hasRead</b><br />
A conditional indicating whether a user has read this thread.
</p>

<p><b>avatar.url</b><br />
A URL to the avatar for the owner of the Post, if avatars are enabled and the
user has an avatar.
</p>

<p><b>lastReply.*</b><br />
These variables are only defined if the <b>Display last reply</b> property is set to true
in the Collaboration Asset.
</p>

<p><b>lastReply.url</b><br />
The URL to the last reply to this Post.
</p>

<p><b>lastReply.title</b><br />
The title of the last reply.
</p>

<p><b>lastReply.user.isVisitor</b><br />
A conditional that is true if the poster of the last reply is a visitor.
</p>

<p><b>lastReply.username</b><br />
The name of user who submitted the last reply.
</p>

<p><b>lastReply.userProfile.url</b><br />
The URL to the Profile of the User who submitted this Post.
</p>

<p><b>lastReply.dateSubmitted.human</b><br />
The date the last reply was submitted, in a human readable format.
</p>

<p><b>lastReply.timeSubmitted.human</b><br />
The time the last reply was submitted, in a human readable format.
</p>

</div>

                |,
		lastUpdated => 1120083131,
	},

	'collaboration template title' => {
		message => q|Collaboration Template|,
		lastUpdated => 1114466567,
	},

	'collaboration template body' => {
		message => q|<p>These variables are available in the Collaboration Template:</p>

<p><b>user.canPost</b><br />
A conditional that is true if the current user can add posts to this Collaboration Asset.
</p>

<p><b>user.isModerator</b><br />
A conditional that is true if the current user is a moderator for this Asset.
</p>

<p><b>user.isVisitor</b><br />
A conditional that is true if the current user is a Visitor.
</p>

<p><b>user.isSubscribed</b><br />
A conditional that is true if the current user is subscribed to this Collaboration Asset.
</p>

<p><b>add.url</b><br />
A URL for adding a new thread.
</p>

<p><b>rss.url</b><br />
A URL for downloading the RSS summary of this Asset.
</p>

<p><b>search.url</b><br />
A URL for accessing the search form for this Collaboration Asset.
</p>

<p><b>subscribe.url</b><br />
A URL for subscribing the current user to this Collaboration Asset.  When new content is submitted to
the Collaboration Asset, the user will be notified.
</p>

<p><b>unsubscribe.url</b><br />
A URL for unsubscribing the current user from this Asset.
</p>

<p><b>karmaIsEnabled</b><br />
A boolean indicating whether the use of karma is enabled or not.
</p>

<p><b>sortby.karmaRank.url</b><br />
A URL for sorting and displaying the list of posts by the amount of karma users have transfered to the thread.
</p>

<p><b>sortby.title.url</b><br />
A URL for sorting and displaying the list of posts by title.
</p>

<p><b>sortby.username.url</b><br />
A URL for sorting and displaying the list of posts by username.
</p>

<p><b>sortby.date.url</b><br />
A URL for sorting and displaying the list of posts by the date they were submitted.
</p>

<p><b>sortby.lastreply.url</b><br />
A URL for sorting and displaying the list of posts by the date they were last updated.
</p>

<p><b>sortby.views.url</b><br />
A URL for sorting and displaying the list of posts by the number of times each has been read.
</p>

<p><b>sortby.replies.url</b><br />
A URL for sorting and displaying the list of posts by the number of replies to the post.
</p>

<p><b>sortby.rating.url</b><br />
A URL for sorting and displaying the list of posts by their ratings.
</p>

                |,
		lastUpdated => 1146762019,
	},

	'collaboration search template title' => {
		message => q|Collaboration Search Template|,
		lastUpdated => 1114467745,
	},

	'collaboration search template body' => {
		message => q|<p>These variables are available in the Collaboration Search Template:</p>

<p><b>form.header</b><br />
HTML and javascript required to make the form work.
</p>


<p><b>query.form</b><br />
HTML form for adding a field where all input has to be in matched pages.
</p>

<p><b>form.search</b><br />
A button to add to the form to begin searching.
</p>

<p><b>back.url</b><br />
A URL for returning to the main view for this Collaboration Asset.
</p>

<p><b>unsubscribe.url</b><br />
A URL for unsubscribing the current user from this Asset.
</p>

<p><b>sortby.title.url</b><br />
A URL for sorting and displaying the list of posts by title.
</p>

<p><b>sortby.username.url</b><br />
A URL for sorting and displaying the list of posts by username.
</p>

<p><b>sortby.date.url</b><br />
A URL for sorting and displaying the list of posts by the date they were submitted.
</p>

<p><b>sortby.lastreply.url</b><br />
A URL for sorting and displaying the list of posts by the date they were last updated.
</p>

<p><b>sortby.views.url</b><br />
A URL for sorting and displaying the list of posts by the number of times each has been read.
</p>

<p><b>sortby.replies.url</b><br />
A URL for sorting and displaying the list of posts by the number of replies to the post.
</p>

<p><b>sortby.rating.url</b><br />
A URL for sorting and displaying the list of posts by their ratings.
</p>

                |,
		lastUpdated => 1145039922,
	},

	'enable avatars' => {
		message => q|Enable Avatars?|,
		lastUpdated => 1131432414,
	},

	'enable avatars description' => {
		message => q|<p>Select "Yes" to display Avatars for users in the Collaboration System.  The Avatar field inthe User Profile has to be enabled, and users will need to upload an Avatar image to display.</p><p>Using Avatars will slow down the performance of Collaboration Systems.</p>|,
		lastUpdated => 1131432717,
	},

	'collaboration rss template title' => {
		message => q|Collaboration RSS Template|,
		lastUpdated => 1114467745,
	},

	'collaboration rss template body' => {
		message => q|<p>The Collaboration RSS template is available to allow configuration of the XML produced as an RSS feed for a collaboration.  To produce a valid rss feed, this template must adhere to the <a href="http://blogs.law.harvard.edu/tech/rss">RSS 2.0 Specification.</a>  These variables are available in the Collaboration RSS Template:</p>

<p><b>title</b><br />
The title of the rss feed (comes from the collaboration title).
</p>

<p><b>link</b><br />
The url to the collaboration.
</p>

<p><b>description</b><br />
The description of the rss feed (comes from the collaboration description).
</p>

<p><b>generator</b><br />
The program used to generate the rss feed, i.e. WebGUI plus version information. (optional field)
</p>

<p><b>webMaster</b><br />
The email address of the person responsible for the technical issues relating to this rss feed. (optional field)
</p>

<p><b>docs</b><br />
The url of documentation about the format of this file, RSS 2.0 (optional field)
</p>

<p><b>lastBuildDate</b><br />
The date that this feed was last updated. (optional field)
</p>

<p><b>item_loop</b><br />
Loops over the posts to be transmitted in this RSS feed.
</p>

<div class="helpIndent">

<p><b>author</b><br />
The username of the person who submitted the post.
</p>

<p><b>title</b><br />
The title of the item (post).
</p>

<p><b>link</b><br />
The url to the full text of the item.
</p>

<p><b>description</b><br />
A synopsis of the item.
</p>

<p><b>guid</b><br />
A unique identifier for this item.
</p>

<p><b>pubDate</b><br />
The date the item was published.
</p>

<p><b>attachmentLoop</b><br />
A loop containg all attachements to this item (post).
</p>

<div class="helpIndent">

<p><b>attachment.url</b><br />
The URL to this attachment.
</p>

<p><b>attachment.path</b><br />
The path in the filesystem to this attachment.
</p>

<p><b>attachment.length</b><br />
The length in this attachment, in bytes.
</p>

</div>

</div>

                |,
		lastUpdated => 1146762108,
	},


};

1;
