package WebGUI::i18n::English::Asset_Collaboration;
use strict;

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

	'max image size' => {
		message => q|Maximum Image Size|,
		lastUpdated => 0,
		context => q|field label for image on display tab|
		},

	'max image size help' => {
		message => q|Set the size of the image attachments for this Collaboration System. If you set it to 0 then the default size set in the master settings will be used. Also, changing this setting does not retroactively change the size of images already in the CS. You'll have to re-save each post to get the size to change.|,
		lastUpdated => 0,
		context => q|help for display setting label|
		},

	'thumbnail size' => {
		message => q|Thumbnail Size|,
		lastUpdated => 0,
		context => q|field label for thumbnails on display tab|
		},

	'thumbnail size help' => {
		message => q|Set the size of the thumbnails for this Collaboration System. If you set it to 0 then the default size set in the master settings will be used. Also, changing this setting does not retroactively change the size of thumbnails already in the CS. You'll have to re-save each post to get the size to change.|,
		lastUpdated => 0,
		context => q|help for display setting label|
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

	'date posted' => {
		message => q|Date Posted|,
		lastUpdated => 1229907194,
        context => q|i18n lable for Collaboration template|,
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
		message => q|Collaboration System, Thread Template|,
		lastUpdated => 1167186381,
	},

	'post template' => {
		message => q|Collaboration System, Post Form Template|,
		lastUpdated => 1167186383,
	},

	'search template' => {
		message => q|Collaboration System, Search Template|,
		lastUpdated => 1167186384,
	},

	'notification template' => {
		message => q|Collaboration System, Notification Template|,
		lastUpdated => 1167186386,
	},

	'rss template' => {
		message => q|Collaboration System, RSS Template|,
		lastUpdated => 1167186387,
	},

	'who posts' => {
		message => q|Who can post?|,
		lastUpdated => 1109698614,
	},

	'who threads' => {
		message => q|Who can post a thread?|,
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

	'reply filter code' => {
		message => q|Reply Filter Code|,
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

	'reply rich editor' => {
		message => q|Reply Rich Editor|,
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
		message => q|Collaboration Template Variable Labels|,
        lastUpdated => 1184905426,
    },

	'add.label' => {
		message => q|The word "Add".|,
		lastUpdated => 1150169037,
	},

	'addlink.label' => {
		message => q|The phrase "Add a link".|,
		lastUpdated => 1150169037,
	},

	'addquestion.label' => {
		message => q|The phrase "Add a question".|,
		lastUpdated => 1150169037,
	},

	'answer.label' => {
		message => q|The word "Answer".|,
		lastUpdated => 1150169037,
	},

	'attachment.label' => {
		message => q|The word "Attachment".|,
		lastUpdated => 1150169037,
	},

	'by.label' => {
		message => q|The word "By".|,
		lastUpdated => 1150169037,
	},

	'body.label' => {
		message => q|The word "Body".|,
		lastUpdated => 1150169037,
	},

	'back.label' => {
		message => q|The word "Back".|,
		lastUpdated => 1150169037,
	},

	'compensation.label' => {
		message => q|The word "Compensation".|,
		lastUpdated => 1150169037,
	},

	'open.label' => {
		message => q|The word "Open".|,
		lastUpdated => 1150169037,
	},

	'close.label' => {
		message => q|The word "Close".|,
		lastUpdated => 1150169037,
	},

	'closed.label' => {
		message => q|The word "Closed".|,
		lastUpdated => 1150169037,
	},

	'critical.label' => {
		message => q|The word "Critical (mostly not working)".|,
		lastUpdated => 1150169037,
	},

	'minor.label' => {
		message => q|The word "Minor (annoying, but not harmful)".|,
		lastUpdated => 1150169037,
	},

	'cosmetic.label' => {
		message => q|The word "Cosmetic (misspelling, formatting problems)".|,
		lastUpdated => 1150169037,
	},

	'fatal.label' => {
		message => q|The word "Fatal (can't continue until this is resolved)".|,
		lastUpdated => 1150169037,
	},

	'severity.label' => {
		message => q|The word "Severity".|,
		lastUpdated => 1150169037,
	},

	'date.label' => {
		message => q|The word "Date".|,
		lastUpdated => 1150169037,
	},

	'delete.label' => {
		message => q|The word "Delete".|,
		lastUpdated => 1150169037,
	},

	'description.label' => {
		message => q|The word "Description".|,
		lastUpdated => 1150169037,
	},

	'edit.label' => {
		message => q|The word "Edit".|,
		lastUpdated => 1150169037,
	},

	'image.label' => {
		message => q|The word "Image".|,
		lastUpdated => 1150169037,
	},

	'job.header.label' => {
		message => q|The phrase "Edit Job Posting".|,
		lastUpdated => 1150169037,
	},

	'job.title.label' => {
		message => q|The phrase "Job Title".|,
		lastUpdated => 1150169037,
	},

	'job.description.label' => {
		message => q|The phrase "Job Description".|,
		lastUpdated => 1150169037,
	},

	'job.requirements.label' => {
		message => q|The phrase "Job Requirements".|,
		lastUpdated => 1150169037,
	},

	'location.label' => {
		message => q|The word "Location".|,
		lastUpdated => 1150169037,
	},

	'layout.flat.label' => {
		message => q|The word "Flat".|,
		lastUpdated => 1150169037,
	},

	'link.header.label' => {
		message => q|The phrase "Edit Link".|,
		lastUpdated => 1150169037,
	},

	'lastReply.label' => {
		message => q|The phrase "Last Reply".|,
		lastUpdated => 1150169037,
	},

	'lock.label' => {
		message => q|The word "Lock".|,
		lastUpdated => 1150169037,
	},

	'layout.label' => {
		message => q|The word "Layout".|,
		lastUpdated => 1150169037,
	},

	'message.header.label' => {
		message => q|The phrase "Edit Message".|,
		lastUpdated => 1150169037,
	},

	'message.label' => {
		message => q|The word "Message".|,
		lastUpdated => 1150169037,
	},

	'next.label' => {
		message => q|The word "Next".|,
		lastUpdated => 1150169037,
	},

	'newWindow.label' => {
		message => q|The phrase "Open in new window?".|,
		lastUpdated => 1150169037,
	},

	'layout.nested.label' => {
		message => q|The word "Nested".|,
		lastUpdated => 1150169037,
	},

	'previous.label' => {
		message => q|The word "Previous".|,
		lastUpdated => 1150169037,
	},

	'post.label' => {
		message => q|The word "Post".|,
		lastUpdated => 1150169037,
	},

	'question.label' => {
		message => q|The word "Question".|,
		lastUpdated => 1150169037,
	},

	'question.header.label' => {
		message => q|The phrase "Edit Question".|,
		lastUpdated => 1150169037,
	},

	'rating.label' => {
		message => q|The word "Rating".|,
		lastUpdated => 1150169037,
	},

	'rate.label' => {
		message => q|The word "Rate".|,
		lastUpdated => 1150169037,
	},

	'reply.label' => {
		message => q|The word "Reply".|,
		lastUpdated => 1150169037,
	},

	'replies.label' => {
		message => q|The word "Replies".|,
		lastUpdated => 1150169037,
	},

	'readmore.label' => {
		message => q|The phrase "Read More".|,
		lastUpdated => 1150169037,
	},

	'responses.label' => {
		message => q|The word "Responses".|,
		lastUpdated => 1150169037,
	},

	'search.label' => {
		message => q|The word "Search".|,
		lastUpdated => 1150169037,
	},

	'subject.label' => {
		message => q|The word "Subject".|,
		lastUpdated => 1150169038,
	},

	'subscribe.label' => {
		message => q|The word "Subscribe".|,
		lastUpdated => 1150169038,
	},

	'submission.header.label' => {
		message => q|The phrase "Edit Submission".|,
		lastUpdated => 1150169038,
	},

	'stick.label' => {
		message => q|The phrase "Make Sticky".|,
		lastUpdated => 1150169038,
	},

	'status.label' => {
		message => q|The word "Status".|,
		lastUpdated => 1150169038,
	},

	'synopsis.label' => {
		message => q|The word "Summary".|,
		lastUpdated => 1150169038,
	},

	'thumbnail.label' => {
		message => q|The word "Thumbnail".|,
		lastUpdated => 1150169038,
	},

	'title.label' => {
		message => q|The word "Title".|,
		lastUpdated => 1150169038,
	},

	'unlock.label' => {
		message => q|The word "Unlock".|,
		lastUpdated => 1150169038,
	},

	'unstick.label' => {
		message => q|The word "Unstick".|,
		lastUpdated => 1150169038,
	},

	'unsubscribe.label' => {
		message => q|The word "Unsubscribe".|,
		lastUpdated => 1150169038,
	},

	'url.label' => {
		message => q|The word "URL".|,
		lastUpdated => 1150169038,
	},

	'user.label' => {
		message => q|The word "User".|,
		lastUpdated => 1150169038,
	},

	'views.label' => {
		message => q|The word "Views".|,
		lastUpdated => 1150169038,
	},

	'visitorName.label' => {
		message => q|The phrase "Visitor Name".|,
		lastUpdated => 1150169038,
	},

	'transferkarma.label' => {
		message => q|The phrase "Transfer Karma".|,
		lastUpdated => 1150169038,
	},

	'karmascale.label' => {
		message => q|The phrase "Karma Scale".|,
		lastUpdated => 1150169038,
	},

	'karmaRank.label' => {
		message => q|The phrase "Karma Rank".|,
		lastUpdated => 1150169038,
	},

	'captcha_label' => {
		message => q|The word "Captcha".|,
		lastUpdated => 1150169038,
	},

	'keywords.label' => {
		message => q|The word "Keywords".|,
		lastUpdated => 1150169038,
	},

        'display last reply description' => {
                message => q|If set to Yes, template variables will be added to allow the display of the last reply in this Thread.|,
                lastUpdated => 1165449294,
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
                message => q|Post Workflow|,
                lastUpdated => 0,
        },

        'thread approval workflow description' => {
                message => q|Choose a workflow to be executed on each thread as it gets submitted.|,
                lastUpdated => 0,
        },

        'thread approval workflow' => {
                message => q|Thread Approval Workflow|,
                lastUpdated => 0,
        },

        'who posts description' => {
                message => q|The group allowed to submit posts to this Asset.|,
                lastUpdated => 1119070429,
        },

        'who threads description' => {
                message => q|The group allowed to start a thread in this Asset.|,
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
                message => q|Sets the level of HTML filtering done on each Post (the start of each thread).|,
                lastUpdated => 1119070429,
        },

        'reply filter code description' => {
                message => q|Sets the level of HTML filtering done on each Reply.|,
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
                message => q|Select which Rich Editor to use for the content of Posts (the start of each thread).|,
                lastUpdated => 1187991394,
        },

        'reply rich editor description' => {
                message => q|Select which Rich Editor to use for the content of Replies.|,
                lastUpdated => 1187991394,
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

	'post_loop' => {
		message => q|A list of posts for this Collateral Asset.|,
		lastUpdated => 1149655722,
	},

	'id' => {
		message => q|The AssetId of this Post.|,
		lastUpdated => 1149655722,
	},

	'tmplVar url' => {
		message => q|The URL of this Post.|,
		lastUpdated => 1149655722,
	},

	'rating_loop' => {
		message => q|A loop that runs once for each point of <b>rating</b> that the Post has|,
		lastUpdated => 1149655722,
	},

	'rating_loop.count' => {
		message => q|The index variable for the <b>rating_loop</b>.|,
		lastUpdated => 1149655722,
	},

	'content' => {
		message => q|The formatted content of this Post.|,
		lastUpdated => 1149655722,
	},

	'tmplVar status' => {
		message => q|The status of this Post.|,
		lastUpdated => 1149655722,
	},

	'tmplVar thumbnail' => {
		message => q|If this Post has attachments, the URL for the thumbnail of the first image attachment.|,
		lastUpdated => 1149655722,
	},

	'image.url' => {
		message => q|If this Post has attachments, the URL for the first image attachment.|,
		lastUpdated => 1149655722,
	},

	'dateSubmitted.human' => {
		message => q|The date this Post was submitted, in a human readable format.|,
		lastUpdated => 1149655722,
	},

	'dateUpdated.human' => {
		message => q|The date this Post was last updated, in a human readable format.|,
		lastUpdated => 1149655722,
	},

	'timeSubmitted.human' => {
		message => q|The time this Post was submitted, in a human readable format.|,
		lastUpdated => 1149655722,
	},

	'timeUpdated.human' => {
		message => q|The time this Post was last updated, in a human readable format.|,
		lastUpdated => 1149655722,
	},

	'userProfile.url' => {
		message => q|The URL to the Profile of the User who submitted this Post.|,
		lastUpdated => 1149655722,
	},

	'post_loop_user.isVisitor' => {
		message => q|A conditional that is true if the poster is a visitor.|,
		lastUpdated => 1149655722,
	},

	'user.isVisitor' => {
		message => q|A conditional that is true if the current user is a visitor.|,
		lastUpdated => 1149655722,
	},

	'hideProfileUrl' => {
		message => q|A conditional that is true if the poster is a visitor, or the current user is a visitor.  In the first case, Visitor's profile is not visible to any user.  In the second case, Visitor is not allowed to view any user's profile|,
		lastUpdated => 1254506340,
	},

	'edit.url' => {
		message => q|The URL to edit this Post.|,
		lastUpdated => 1149655722,
	},

	'controls' => {
		message => q|A set of editing icons to delete or re-order this Post.|,
		lastUpdated => 1149655722,
	},

	'isSecond' => {
		message => q|A conditional indicating that is true if this Post is the second in this Collaboration Asset.|,
		lastUpdated => 1149655722,
	},

	'isThird' => {
		message => q|A conditional indicating that is true if this Post is the third in this Collaboration Asset.|,
		lastUpdated => 1149655722,
	},

	'isFourth' => {
		message => q|A conditional indicating that is true if this Post is the fourth in this Collaboration Asset.|,
		lastUpdated => 1149655722,
	},

	'isFifth' => {
		message => q|A conditional indicating that is true if this Post is the fifth in this Collaboration Asset.|,
		lastUpdated => 1149655722,
	},

	'user.isPoster' => {
		message => q|A conditional indicating that is true if the current user submitted this Post.|,
		lastUpdated => 1149655722,
	},

	'user.hasRead' => {
		message => q|A conditional indicating whether a user has read this thread.|,
		lastUpdated => 1149655722,
	},

	'avatar.url' => {
		message => q|A URL to the avatar for the owner of the Post, if avatars are enabled and the
user has an avatar.|,
		lastUpdated => 1149655722,
	},

	'lastReply.url' => {
		message => q|The URL to the last reply to this Post.|,
		lastUpdated => 1149655722,
	},

	'lastReply.title' => {
		message => q|The title of the last reply.|,
		lastUpdated => 1149655722,
	},

	'lastReply.user.isVisitor' => {
		message => q|A conditional that is true if the poster of the last reply is a visitor.|,
		lastUpdated => 1149655722,
	},

	'lastReply.hideProfileUrl' => {
		message => q|A conditional that is true if the poster of the last reply is a visitor, or the current user is a visitor.  In the first case, Visitor's profile is not visible to any user.  In the second case, Visitor is not allowed to view any user's profile|,
		lastUpdated => 1254506340,
	},

	'lastReply.username' => {
		message => q|The name of user who submitted the last reply.|,
		lastUpdated => 1149655722,
	},

	'lastReply.userProfile.url' => {
		message => q|The URL to the Profile of the User who submitted this Post.|,
		lastUpdated => 1149655722,
	},

	'lastReply.dateSubmitted.human' => {
		message => q|The date the last reply was submitted, in a human readable format.|,
		lastUpdated => 1149655722,
	},

	'lastReply.timeSubmitted.human' => {
		message => q|The time the last reply was submitted, in a human readable format.|,
		lastUpdated => 1149655722,
	},

	'collaboration template title' => {
		message => q|Collaboration Template Variables|,
		lastUpdated => 1114466567,
	},

	'user.canPost' => {
		message => q|A conditional that is true if the current user can add posts to this Collaboration Asset.|,
		lastUpdated => 1149655833,
	},

	'user.canStartThread' => {
		message => q|A conditional that is true if the current user can add Threads to this Collaboration Asset.|,
		lastUpdated => 1149655833,
        context => q|Template variable help|,
	},

	'displayLastReply' => {
		message => q|A conditional that is true if the Collaboration System was configured to display the last reply.  If this variable is true, then in the Collaboration Template, the lastReply.* variables will be enabled.|,
		lastUpdated => 1149655833,
	},

	'user.isModerator' => {
		message => q|A conditional that is true if the current user is a moderator for this Asset.|,
		lastUpdated => 1149655833,
	},

	'user.isSubscribed' => {
		message => q|A conditional that is true if the current user is subscribed to this Collaboration Asset.|,
		lastUpdated => 1149655833,
	},

	'add.url' => {
		message => q|A URL for adding a new thread.|,
		lastUpdated => 1149655833,
	},

	'rss.url' => {
		message => q|A URL for downloading the RSS summary of this Asset.|,
		lastUpdated => 1149655833,
	},

	'search.url' => {
		message => q|A URL for accessing the search form for this Collaboration Asset.|,
		lastUpdated => 1149655833,
	},

	'subscribe.url' => {
		message => q|A URL for subscribing the current user to this Collaboration Asset.  When new content is submitted to
the Collaboration Asset, the user will be notified.|,
		lastUpdated => 1149655833,
	},

	'unsubscribe.url' => {
		message => q|A URL for unsubscribing the current user from this Asset.|,
		lastUpdated => 1149655833,
	},

	'karmaIsEnabled' => {
		message => q|A boolean indicating whether the use of karma is enabled or not.|,
		lastUpdated => 1149655833,
	},

	'sortby.karmaRank.url' => {
		message => q|A URL for sorting and displaying the list of posts by the amount of karma users have transfered to the thread.|,
		lastUpdated => 1149655833,
	},

	'sortby.title.url' => {
		message => q|A URL for sorting and displaying the list of posts by title.|,
		lastUpdated => 1149655833,
	},

	'sortby.username.url' => {
		message => q|A URL for sorting and displaying the list of posts by username.|,
		lastUpdated => 1149655833,
	},

	'sortby.date.url' => {
		message => q|A URL for sorting and displaying the list of posts by the date they were submitted.|,
		lastUpdated => 1149655833,
	},

	'sortby.lastreply.url' => {
		message => q|A URL for sorting and displaying the list of posts by the date they were last updated.|,
		lastUpdated => 1149655833,
	},

	'sortby.views.url' => {
		message => q|A URL for sorting and displaying the list of posts by the number of times each has been read.|,
		lastUpdated => 1149655833,
	},

	'sortby.replies.url' => {
		message => q|A URL for sorting and displaying the list of posts by the number of replies to the post.|,
		lastUpdated => 1149655833,
	},

	'sortby.rating.url' => {
		message => q|A URL for sorting and displaying the list of posts by their ratings.|,
		lastUpdated => 1149655833,
	},

	'collaboration search template title' => {
		message => q|Collaboration Search Template Variables|,
		lastUpdated => 1184905531,
	},

	'form.header' => {
		message => q|HTML and javascript required to make the form work.|,
		lastUpdated => 1149655909,
	},

	'query.form' => {
		message => q|HTML form for adding a field where all input has to be in matched pages.|,
		lastUpdated => 1149655909,
	},

	'form.search' => {
		message => q|A button to add to the form to begin searching.|,
		lastUpdated => 1149655909,
	},

	'form.footer' => {
		message => q|HTML required to end the search form.|,
		lastUpdated => 1149655909,
	},

	'back.url' => {
		message => q|A URL for returning to the main view for this Collaboration Asset.|,
		lastUpdated => 1149655909,
	},

	'doit' => {
		message => q|A boolean that is true if a search has just been submitted|,
		lastUpdated => 1149655909,
	},

	'enable avatars' => {
		message => q|Enable Avatars?|,
		lastUpdated => 1131432414,
	},

	'enable avatars description' => {
		message => q|<p>Select "Yes" to display Avatars for users in the Collaboration System.  The Avatar field in the User Profile has to be enabled, and users will need to upload an Avatar image to display.</p><p>Using Avatars will slow down the performance of Collaboration Systems.</p>|,
		lastUpdated => 1165449336,
	},

	'enable metadata' => {
		message => q|Enable MetaData in Posts?|,
		lastUpdated => 1180759718,
	},

	'enable metadata description' => {
		message => q|<p>Select "Yes" to enable Posts to have MetaData and to be passively profiled.  This will impact the performance of the Collaboration System.  MetaData must also be enabled sitewide in the site settings.</p>|,
		lastUpdated => 1180759724,
	},

	'collaborationAssetId' => {
		message => q|The assetId of this Collaboration System.  Unlike the variable assetId, this one will not be overridden by the assetIds inside of Threads or Posts.|,
		lastUpdated => 1170543345,
	},
    
    'subscription group label' => {
        message => q|Subscription Group|,
        lastUpdated => 1170543345,
    },
    
    'subscription group hoverHelp' => {
        message => q|Manage the users in the subscription group for this Collaboration System|,
        lastUpdated => 1170543345,
    },

    'group to edit label' => {
        message => q|Group to Edit Posts|,
        lastUpdated => 1206733328,
    },
    'group to edit hoverhelp' => {
        message => q|A group that is allowed to edit posts after they have been submitted.|,
        lastUpdated => 1269283819,
    },
    
    'use captcha label' => {
        message => q|Use Post Captcha|,
        lastUpdated => 1170543345,
    },

    'use captcha hover help' => {
        message => q|Choose whether or not to make users verify their humnanity before being able to post to this collaboration system|,
        lastUpdated => 1170543345,
    },
    
    'captcha label' => {
        message => q|Verify your humanity|,
        lastUpdated => 1170543345,
    },

    'editForm archiveEnabled label' => {
        message     => q{Enable Archiving?},
        lastUpdated => 0,
        context     => q{Label for asset property},
    },

    'editForm archiveEnabled description' => {
        message     => q{If Yes, Threads will be automatically hidden after a certain interval},
        lastUpdated => 0,
        context     => q{Hover help for asset property},
    },

    'keywords label' => {
        message => q|Keywords|,
        lastUpdated => 1170543345,
    },
    
    'asset not committed' => {
		message => q{<h1>Error!</h1><p>You need to commit this collaboration system before you can create a new thread</p>},
        lastUpdated => 1166848379,
    },

    'post received template' => {
        message => q|Post received template|,
        lastUpdated => 1221247761,
    },

    'post received template hoverHelp' => {
        message => q|The template for the message received when a user makes a post.|,
        lastUpdated => 1221247761,
    },

    'Link Description' => {
        message => q|Link Description|,
        context => q|i18n label for the link list collaboration template.|,
        lastUpdated => 1221247761,
    },

    'Link URL' => {
        message => q|Link URL|,
        context => q|i18n label for the link list collaboration template.|,
        lastUpdated => 1221247761,
    },

    'List All Links' => {
        message => q|List All Links|,
        context => q|i18n label for the link list collaboration template.|,
        lastUpdated => 1221247761,
    },

    'has posted to one of your subscriptions' => {
        message => q|has posted to one of your subscriptions|,
        context => q|i18n label for the notification template.  "user" has posted..|,
        lastUpdated => 1229910435,
    },

    'unarchive all' => {
        message     => q{Unarchive All Threads},
        context     => q{Label for link to unarchive all threads},
        lastUpdated => 0,
    },

    'unarchive confirm' => {
        message     => q{Are you sure? Any threads past the 'Archive After' interval will be re-archived.},
        context     => q{Text for pop-up dialog to confirm unarchive all threads},
        lastUpdated => 0,
    },

};

1;
