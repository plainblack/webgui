package WebGUI::Forum::UI;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict qw(vars subs);
use WebGUI::DateTime;
use WebGUI::Form;
use WebGUI::FormProcessor;
use WebGUI::Forum;
use WebGUI::Forum::Post;
use WebGUI::Forum::Thread;
use WebGUI::HTML;
use WebGUI::MessageLog;
use WebGUI::Search;
use WebGUI::Session;
use WebGUI::Template;
use WebGUI::User;


=head1 NAME

Package WebGUI::Forum::UI

=head1 DESCRIPTION
                                                                                                                                                             
User interface package for forums.

=head1 SYNOPSIS
                                                                                                                                                             
 use WebGUI::Forum::UI;

 $scalar = WebGUI::Forum::UI::chopSubject($subject);
 $url = WebGUI::Forum::UI::formatApprovePostURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatDeletePostURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatDenyPostURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatEditPostURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatForumSearchURL($callback, $forumId);
 $url = WebGUI::Forum::UI::formatForumSortByURL($callback, $forumIId);
 $url = WebGUI::Forum::UI::formatForumSubscribeURL($callback, $forumId);
 $url = WebGUI::Forum::UI::formatForumUnsubscribeURL($callback, $forumId);
 $url = WebGUI::Forum::UI::formatForumURL($callback, $forumId);
 $url = WebGUI::Forum::UI::formatNextThreadURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatNewThreadURL($callback, $forumId);
 $scalar = WebGUI::Forum::UI::formatPostDate($epoch);
 $scalar = WebGUI::Forum::UI::formatPostTime($epoch);
 $url = WebGUI::Forum::UI::formatPreviousThreadURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatRatePostURL($callback, $postId, $rating);
 $url = WebGUI::Forum::UI::formatReplyPostURL($callback, $postId, $forumId);
 $scalar = WebGUI::Forum::UI::formatStatus($status);
 $scalar = WebGUI::Forum::UI::formatSubject($subject);
 $url = WebGUI::Forum::UI::formatThreadLayoutURL($callback, $postId, $layout);
 $url = WebGUI::Forum::UI::formatThreadLockURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatThreadStickURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatThreadSubscribeURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatThreadUnlockURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatThreadUnstickURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatThreadUnsubscribeURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatThreadURL($callback, $postId);
 $url = WebGUI::Forum::UI::formatUserProfileURL($userId);

 $html = WebGUI::Forum::UI::forumProperties($forumId);
 WebGUI::Forum::UI::forumPropertiesSave();

 $hashRef = WebGUI::Forum::UI::getForumTemplateVars($caller, $forum);
 $hashRef = WebGUI::Forum::UI::getPostTemplateVars($post, $thread, $forum, $caller);
 $hashRef = WebGUI::Forum::UI::getThreadTemplateVars($caller, $post);
 $arrayRef = WebGUI::Forum::UI::recurseThread($post, $thread, $forum, $depth, $caller, $postId);

 WebGUI::Forum::UI::notifySubscribers($post, $thread, $forum, $caller);
 WebGUI::Forum::UI::setPostApproved($caller, $post);
 WebGUI::Forum::UI::setPostDeleted($caller, $post);
 WebGUI::Forum::UI::setPostDenied($caller, $post);
 WebGUI::Forum::UI::setPostPending($caller, $post);
 WebGUI::Forum::UI::setPostStatus($caller, $post);
 
 $html = WebGUI::Forum::UI::forumOp($callback);
 $html = WebGUI::Forum::UI::www_approvePost($callback);
 $html = WebGUI::Forum::UI::www_deletePost($callback);
 $html = WebGUI::Forum::UI::www_deletePostConfirm($callback);
 $html = WebGUI::Forum::UI::www_denyPost($callback);
 $html = WebGUI::Forum::UI::www_forumSubscribe($callback);
 $html = WebGUI::Forum::UI::www_forumUnsubscribe($callback);
 $html = WebGUI::Forum::UI::www_nextThread($callback);
 $html = WebGUI::Forum::UI::www_post($callback);
 $html = WebGUI::Forum::UI::www_postSave($callback);
 $html = WebGUI::Forum::UI::www_previousThread($callback);
 $html = WebGUI::Forum::UI::www_ratePost($callback);
 $html = WebGUI::Forum::UI::www_search($callback);
 $html = WebGUI::Forum::UI::www_threadLock($callback);
 $html = WebGUI::Forum::UI::www_threadStick($callback);
 $html = WebGUI::Forum::UI::www_threadSubscribe($callback);
 $html = WebGUI::Forum::UI::www_threadUnlock($callback);
 $html = WebGUI::Forum::UI::www_threadUnstick($callback);
 $html = WebGUI::Forum::UI::www_threadUnsubscribe($callback);
 $html = WebGUI::Forum::UI::www_viewForum($callback);
 $html = WebGUI::Forum::UI::www_viewThread($callback);

=head1 FUNCTIONS
                                                                                                                                                             
These functions are available from this package:
                                                                                                                                                             
=cut

#-------------------------------------------------------------------

=head2 chopSubject ( subject )

Cuts a subject string off at 30 characters.

=over

=item subject

The string to format.

=back

=cut

sub chopSubject {
	return substr(formatSubject($_[0]),0,30);
}

#-------------------------------------------------------------------

=head2 formatApprovePostURL ( callback, postId )

Formats the URL to approve a post.

=over

=item callback

The url to get back to the calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatApprovePostURL {
	return WebGUI::URL::append($_[0],"forumOp=approvePost&amp;forumPostId=".$_[1]."&amp;mlog=".$session{form}{mlog});
}

#-------------------------------------------------------------------

=head2 formatDeletePostURL ( callback, postId )

Formats the url to delete a post.

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatDeletePostURL {
	return WebGUI::URL::append($_[0],"forumOp=deletePost&amp;forumPostId=".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatDenyPostURL ( callback, postId )

Formats the url to deny a post.

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatDenyPostURL {
	return WebGUI::URL::append($_[0],"forumOp=denyPost&amp;forumPostId=".$_[1]."&amp;mlog=".$session{form}{mlog});
}

#-------------------------------------------------------------------

=head2 formatEditPostURL ( callback, postId )

Formats the url to edit a post.

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatEditPostURL {
	return WebGUI::URL::append($_[0],"forumOp=post&amp;forumPostId=".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatForumSearchURL ( callback, forumId )

Formats the url to the forum search engine.

=over

=item callback

The url to get back tot he calling object.

=item forumId

The unique id for the forum.

=back

=cut

sub formatForumSearchURL {
	return WebGUI::URL::append($_[0],"forumOp=search&amp;forumId=".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatForumSortByURL ( callback, forumId, sortBy )

Formats the url to change the default sort.

=over

=item callback

The url to get back tot he calling object.

=item forumId

The unique id for the forum.

=item sortBy 

The sort by string. Can be views, rating, date replies, or lastreply.

=back

=cut

sub formatForumSortByURL {
	return WebGUI::URL::append($_[0],"forumOp=viewForum&amp;forumId=".$_[1]."&amp;sortBy=".$_[2]);
}

#-------------------------------------------------------------------

=head2 formatForumSubscribeURL ( callback, forumId )

Formats the url to subscribe to the forum.

=over

=item callback

The url to get back tot he calling object.

=item forumId

The unique id for the forum.

=back

=cut

sub formatForumSubscribeURL {
	return WebGUI::URL::append($_[0],"forumOp=forumSubscribe&amp;forumId=".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatForumUnsubscribeURL ( callback, forumId )

Formats the url to unsubscribe from the forum.

=over

=item callback

The url to get back tot he calling object.

=item forumId

The unique id for the forum.

=back

=cut

sub formatForumUnsubscribeURL {
	return WebGUI::URL::append($_[0],"forumOp=forumUnsubscribe&amp;forumId=".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatForumURL ( callback, forumId )

Formats the url to view the forum.

=over

=item callback

The url to get back tot he calling object.

=item forumId

The unique id for the forum.

=back

=cut

sub formatForumURL {
	return WebGUI::URL::append($_[0],"forumOp=viewForum&amp;forumId=".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatNextThreadURL ( callback, postId )

Formats the url to view the next thread. 

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatNextThreadURL {
	return WebGUI::URL::append($_[0],"forumOp=nextThread&amp;forumThreadId=".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatNewThreadURL ( callback, forumId )

Formats the url to start a new thread. 

=over

=item callback

The url to get back tot he calling object.

=item forumId

The unique id for the forum.

=back

=cut

sub formatNewThreadURL {
	return WebGUI::URL::append($_[0],"forumOp=post&amp;forumId=".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatPostDate ( epoch )

Formats the date as human readable according to the user's profile. 

=over

=item epoch

The date represented as the number of seconds since January 1, 1970.

=back

=cut

sub formatPostDate {
	return WebGUI::DateTime::epochToHuman($_[0],"%z");
}

#-------------------------------------------------------------------

=head2 formatPostTime ( epoch )

Formats the time as human readable according to the user's profile. 

=over

=item epoch

The date represented as the number of seconds since January 1, 1970.

=back

=cut

sub formatPostTime {
	return WebGUI::DateTime::epochToHuman($_[0],"%Z");
}

#-------------------------------------------------------------------

=head2 formatPreviousThreadURL ( callback, postId )

Formats the url to view the previous thread. 

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatPreviousThreadURL {
	return WebGUI::URL::append($_[0],"forumOp=previousThread&amp;forumThreadId=".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatRatePostURL ( callback, postId, rating )

Formats the url to rate a post. 

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=item rating

An integer between 1 and 5 (5 = best).

=back

=cut

sub formatRatePostURL {
	return WebGUI::URL::append($_[0],"forumOp=ratePost&amp;forumPostId=".$_[1]."&amp;rating=".$_[2]."#".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatReplyPostURL ( callback, postId, forumId [ , withQuote ] )

Formats the url to reply to a post.

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=item forumId

The unique id for the forum.

=item withQuote 

If specified the reply with automatically quote the parent post.

=back

=cut

sub formatReplyPostURL {
	my $url = WebGUI::URL::append($_[0],"forumOp=post&amp;parentId=".$_[1]."&amp;forumId=".$_[2]);
	$url = WebGUI::URL::append($url,"withQuote=1") if ($_[3]);
	return $url;
}

#-------------------------------------------------------------------

=head2 formatStatus ( status )

Returns an internationalized string for the status based upon the key.

=over

=item status

A string key. Can be approved, archived, deleted, denied, or pending.

=back

=cut

sub formatStatus {
        if ($_[0] eq "approved") {
                return WebGUI::International::get(560);
        } elsif ($_[0] eq "denied") {
                return WebGUI::International::get(561);
        } elsif ($_[0] eq "pending") {
                return WebGUI::International::get(562);
        } elsif ($_[0] eq "archived") {
                return WebGUI::International::get(1046);
        }
}

#-------------------------------------------------------------------

=head2 formatSubject ( subject )

Formats the subject string (removing bad stuff like HTML).

=over

=item subject 

The string to format.

=back

=cut

sub formatSubject {
	return WebGUI::HTML::filter($_[0],"all");
}

#-------------------------------------------------------------------

=head2 formatThreadLayoutURL ( callback, postId, layout )

Formats the url to change the layout of a thread.

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=item layout

A string indicating the type of layout to use. Can be flat, nested, or threaded.

=back

=cut

sub formatThreadLayoutURL {
	return WebGUI::URL::append($_[0],"forumOp=viewThread&amp;forumPostId=".$_[1]."&amp;layout=".$_[2]);
}

#-------------------------------------------------------------------

=head2 formatThreadLockURL ( callback, postId )

Formats the url to lock a thread.

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatThreadLockURL {
	return WebGUI::URL::append($_[0],"forumOp=threadLock&amp;forumPostId=".$_[1]."#".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatThreadStickURL ( callback, postId )

Formats the url to make a thread sticky.

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatThreadStickURL {
	return WebGUI::URL::append($_[0],"forumOp=threadStick&amp;forumPostId=".$_[1]."#".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatThreadSubscribeURL ( callback, postId )

Formats the url to subscribe to a thread. 

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatThreadSubscribeURL {
	return WebGUI::URL::append($_[0],"forumOp=threadSubscribe&amp;forumPostId=".$_[1]."#".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatThreadUnlockURL ( callback, postId )

Formats the url to unlock a thread.

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatThreadUnlockURL {
	return WebGUI::URL::append($_[0],"forumOp=threadUnlock&amp;forumPostId=".$_[1]."#".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatThreadUnstickURL ( callback, postId )

Formats the url to make a sticky thread no longer sticky. 

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatThreadUnstickURL {
	return WebGUI::URL::append($_[0],"forumOp=threadUnstick&amp;forumPostId=".$_[1]."#".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatThreadUnsubscribeURL ( callback, postId )

Formats the url to unsubscribe from a thread.

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatThreadUnsubscribeURL {
	return WebGUI::URL::append($_[0],"forumOp=threadUnsubscribe&amp;forumPostId=".$_[1]."#".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatThreadURL ( callback, postId )

Formats the url to view a thread.

=over

=item callback

The url to get back tot he calling object.

=item postId

The unique id for the post.

=back

=cut

sub formatThreadURL {
	return WebGUI::URL::append($_[0],"forumOp=viewThread&amp;forumPostId=".$_[1]."#".$_[1]);
}

#-------------------------------------------------------------------

=head2 formatUserProfileURL ( userId )

Formats the url to view a users profile.

=over

=item userId

The unique id for the user.

=back

=cut

sub formatUserProfileURL {
	return WebGUI::URL::page("op=viewProfile&amp;uid=".$_[0]);
}

#-------------------------------------------------------------------

=head2 forumProperties ( forumId )

Returns a forum containing the editable properties of a forum.

=over

=item forumId

The unique id of the forum.

=back

=cut

sub forumProperties {
	my ($forumId) = @_;
	my $forum = WebGUI::Forum->new($forumId);
        my $f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name=>"forumId",
		-value=>$forumId || "new"
		);
	$f->template(
		-name=>"forumTemplateId",
		-label=>WebGUI::International::get(1031),
		-namespace=>"Forum",
		-uiLevel=>5,
		-value=>$forum->get("forumTemplateId")
		);
	$f->template(
		-name=>"threadTemplateId",
		-label=>WebGUI::International::get(1032),
		-namespace=>"Forum/Thread",
		-uiLevel=>5,
		-value=>$forum->get("threadTemplateId")
		);
	$f->template(
		-name=>"postTemplateId",
		-label=>WebGUI::International::get(1033),
		-namespace=>"Forum/Post",
		-uiLevel=>5,
		-value=>$forum->get("postTemplateId")
		);
	$f->template(
		-name=>"searchTemplateId",
		-label=>WebGUI::International::get(1044),
		-namespace=>"Forum/Search",
		-uiLevel=>5,
		-value=>$forum->get("searchTemplateId")
		);
	$f->template(
		-name=>"postFormTemplateId",
		-label=>WebGUI::International::get(1034),
		-namespace=>"Forum/PostForm",
		-uiLevel=>5,
		-value=>$forum->get("postFormTemplateId")
		);
	$f->template(
		-name=>"notificationTemplateId",
		-label=>WebGUI::International::get(1035),
		-namespace=>"Forum/Notification",
		-uiLevel=>5,
		-value=>$forum->get("notificationTemplateId")
		);
        my ($interval, $units) = WebGUI::DateTime::secondsToInterval(($forum->get("archiveAfter") || 31536000));
        $f->interval(
                -name=>"archiveAfter",
                -label=>WebGUI::International::get(1043),
                -intervalValue=>$interval,
                -unitsValue=>$units,
                -uiLevel=>9
                );
        ($interval, $units) = WebGUI::DateTime::secondsToInterval(($forum->get("editTimeout") || 3600));
        $f->interval(
                -name=>"editTimeout",
                -label=>WebGUI::International::get(566),
                -intervalValue=>$interval,
                -unitsValue=>$units,
                -uiLevel=>9
                );
        $f->yesNo(
                -name=>"addEditStampToPosts",
                -label=>WebGUI::International::get(1025),
                -value=>$forum->get("addEditStampToPosts"),
                -uiLevel=>9
                );
	$f->yesNo(
		-name=>"allowRichEdit",
		-value=>$forum->get("allowRichEdit"),
		-uiLevel=>7,
		-label=>WebGUI::International::get(1026)
		);
	$f->yesNo(
		-name=>"allowReplacements",
		-value=>$forum->get("allowReplacements"),
		-uiLevel=>7,
		-label=>WebGUI::International::get(1027)
		);
        $f->filterContent(
                -name=>"filterPosts",
                -value=>$forum->get("filterPosts") || "most",
                -label=>WebGUI::International::get(1024),
                -uiLevel=>7
                );
        $f->integer(
		-name=>"postsPerPage",
		-label=>WebGUI::International::get(1042),
		-value=>$forum->get("postsPerPage")||30,
		-uiLevel=>7
		);
        if ($session{setting}{useKarma}) {
                $f->integer(
			-name=>"karmaPerPost",
			-label=>WebGUI::International::get(541),
			-value=>($forum->get("karmaPerPost") || 0),
			-uiLevel=>7
			);
        } else {
                $f->hidden(
			-name=>"karmaPerPost",
			-value=>($forum->get("karmaPerPost") || 0)
			);
        }
        $f->group(
                -name=>"groupToPost",
                -label=>WebGUI::International::get(564),
                -value=>[$forum->get("groupToPost")],
                -uiLevel=>5
                );
	$f->yesNo(
		-name=>"moderatePosts",
		-label=>WebGUI::International::get(1028),
		-uiLevel=>5,
		-value=>$forum->get("moderatePosts")
		);
	my $groupToModerate = $forum->get("groupToModerate") || 4;
        $f->group(
                -name=>"groupToModerate",
                -label=>WebGUI::International::get(565),
                -value=>[$groupToModerate],
                -uiLevel=>5
                );
        return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 forumPropertiesSave ( )

Saves all of the forum properties in $session{form}.

=cut

sub forumPropertiesSave {
	my %data = (
		forumTemplateId=>$session{form}{forumTemplateId},
		threadTemplateId=>$session{form}{threadTemplateId},
		postTemplateId=>$session{form}{postTemplateId},
		searchTemplateId=>$session{form}{searchTemplateId},
		notificationTemplateId=>$session{form}{notificationTemplateId},
		postFormTemplateId=>$session{form}{postFormTemplateId},
		editTimeout=>WebGUI::FormProcessor::interval("editTimeout"),
		archiveAfter=>WebGUI::FormProcessor::interval("archiveAfter"),
		addEditStampToPosts=>$session{form}{addEditStampToPosts},
		allowRichEdit=>$session{form}{allowRichEdit},
		allowReplacements=>$session{form}{allowReplacements},
		filterPosts=>$session{form}{filterPosts},
		postsPerPage=>$session{form}{postsPerPage},
		karmaPerPost=>$session{form}{karmaPerPost},
		groupToPost=>$session{form}{groupToPost},
		moderatePosts=>$session{form}{moderatePosts},
		groupToModerate=>$session{form}{groupToModerate}
		);
	my $forum;
	if ($session{form}{forumId} eq "new") {
		$forum = WebGUI::Forum->create(\%data);
	} else {
		$forum = WebGUI::Forum->new($session{form}{forumId});
		$forum->set(\%data);
	}
	return $forum->get("forumId");
}

#-------------------------------------------------------------------

=head2 forumOp ( caller )

Returns the output of the various www_ subroutines.

=over

=item caller

A hash reference containing information passed from the calling object. The following are hash keys that should be passed:

callback: The URL to get back to the calling object.

title: The title of the parent object for display in the forum templates.

description: The description of the parent object for display in the fourm templates.

forumId: The ID of the forum that is attached to the calling object.

=back

=cut

sub forumOp {
        my ($caller) = @_;
	if ($session{form}{forumOp} =~ /^[A-Za-z]+$/) {
		my $forumId = $session{form}{forumId};
		if ($session{form}{forumPostId}) {
			my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
			$forumId = $post->getThread->get("forumId");
		} elsif ($session{form}{forumThreadId}) {
			my $thread = WebGUI::Forum::Thread->new($session{form}{forumThreadId});
			$forumId = $thread->get("forumId");
		}
		if ($forumId != $caller->{forumId}) {
			WebGUI::ErrorHandler::security("view a forum (".$caller->{forumId}.") that does not belong to the calling object (".$caller->{callback}.")");
			return WebGUI::Privilege::insufficient();
		} 
        	my $cmd = "www_".$session{form}{forumOp};
        	return &$cmd($caller);
	} else {
		return WebGUI::ErrorHandler::security("execute an invalid forum operation: ".$session{form}{forumOp});
	}
}

#-------------------------------------------------------------------

=head2 getForumTemplateVars ( caller, forum )

Returns a hash reference compatible with WebGUI's templating system.

=over

=item caller

A hash reference containing information passed from the calling object.

=item forum

The unique id for the forum.

=back

=cut

sub getForumTemplateVars {
	my ($caller, $forum) = @_;
	my $callback = $caller->{callback};
	my (%var, @thread_loop);
	$var{'callback.url'} = $callback;
	$var{'callback.label'} = WebGUI::International::get(1039);
	$var{'user.isVisitor'} = ($session{user}{userId} == 1);
	$var{'thread.new.url'} = formatNewThreadURL($callback,$forum->get("forumId"));
	$var{'thread.new.label'} = WebGUI::International::get(1018);
	$var{'forum.description'} = $caller->{description};
	$var{'forum.title'} = $caller->{title};
	$var{'forum.search.label'} = WebGUI::International::get(364);
	$var{'forum.search.url'} = formatForumSearchURL($callback,$forum->get("forumId"));
	$var{'forum.subscribe.label'} = WebGUI::International::get(1022);
	$var{'forum.subscribe.url'} = formatForumSubscribeURL($callback,$forum->get("forumId"));
	$var{'forum.unsubscribe.label'} = WebGUI::International::get(1023);
	$var{'forum.unsubscribe.url'} = formatForumUnsubscribeURL($callback,$forum->get("forumId"));
	$var{'user.isSubscribed'} = $forum->isSubscribed;
	$var{'user.isModerator'} = $forum->isModerator;
	$var{'user.canPost'} = $forum->canPost;
	$var{'thread.sortby.date.url'} = formatForumSortByURL($callback,$forum->get("forumId"),"date");
	$var{'thread.sortby.lastreply.url'} = formatForumSortByURL($callback,$forum->get("forumId"),"lastreply");
	$var{'thread.sortby.views.url'} = formatForumSortByURL($callback,$forum->get("forumId"),"views");
	$var{'thread.sortby.replies.url'} = formatForumSortByURL($callback,$forum->get("forumId"),"replies");
	$var{'thread.sortby.rating.url'} = formatForumSortByURL($callback,$forum->get("forumId"),"rating");
	$var{'thread.subject.label'} = WebGUI::International::get(229);
	$var{'thread.date.label'} = WebGUI::International::get(245);
	$var{'thread.user.label'} = WebGUI::International::get(244);
	$var{"thread.views.label"} = WebGUI::International::get(514);
        $var{"thread.replies.label"} = WebGUI::International::get(1016);
	$var{'thread.rating.label'} = WebGUI::International::get(1020);
        $var{"thread.last.label"} = WebGUI::International::get(1017);
	my $query = "select * from forumThread where forumId=".$forum->get("forumId")." and ";
	if ($forum->isModerator) {
		$query .= "(status='approved' or status='pending')";
	} else {
		$query .= "status='approved'";
	}
	$query .= " order by isSticky desc, ";
	if ($session{scratch}{forumSortBy} eq "date") {
		$query .= "rootPostId desc";
	} elsif ($session{scratch}{forumSortBy} eq "views") {
		$query .= "views desc";
	} elsif ($session{scratch}{forumSortBy} eq "replies") {
		$query .= "replies desc";
	} elsif ($session{scratch}{forumSortBy} eq "rating") {
		$query .= "rating desc";
	} else {
		$query .= "lastPostDate desc";
	}
	my $p = WebGUI::Paginator->new(WebGUI::URL::append($callback,"forumOp=viewForum&amp;forumId=".$forum->get("forumId")),"",$forum->get("postsPerPage"));
	$p->setDataByQuery($query);
	$var{firstPage} = $p->getFirstPageLink;
        $var{lastPage} = $p->getLastPageLink;
        $var{nextPage} = $p->getNextPageLink;
        $var{pageList} = $p->getPageLinks;
        $var{previousPage} = $p->getPreviousPageLink;
        $var{multiplePages} = ($p->getNumberOfPages > 1);
        $var{numberOfPages} = $p->getNumberOfPages;
        $var{pageNumber} = $p->getPageNumber;
	my $threads = $p->getPageData;
	foreach my $thread (@$threads) {
		my $root = WebGUI::Forum::Post->new($thread->{rootPostId});
		my $last;
		if ($thread->{rootPostId} == $thread->{lastPostId}) { #saves the lookup if it's the same id
			$last = $root;
		} else {
			$last = WebGUI::Forum::Post->new($thread->{lastPostId});
		}
		my @rating_loop;
		for (my $i=0;$i<=$thread->{rating};$i++) {
			push(@rating_loop,{'thread.rating_loop.count'=>$i});
		}
		push(@thread_loop,{
			'thread.views'=>$thread->{views},
			'thread.replies'=>$thread->{replies},
			'thread.rating'=>$thread->{rating},
			'thread.rating_loop'=>\@rating_loop,
			'thread.isSticky'=>$thread->{isSticky},
			'thread.isLocked'=>$thread->{isLocked},
			'thread.root.subject'=>chopSubject($root->get("subject")),
			'thread.root.url'=>formatThreadURL($callback,$root->get("forumPostId")),
			'thread.root.epoch'=>$root->get("dateOfPost"),
			'thread.root.date'=>formatPostDate($root->get("dateOfPost")),
			'thread.root.time'=>formatPostTime($root->get("dateOfPost")),
			'thread.root.user.profile'=>formatUserProfileURL($root->get("userId")),
			'thread.root.user.name'=>$root->get("username"),
			'thread.root.user.id'=>$root->get("userId"),
			'thread.root.user.isVisitor'=>($root->get("userId") == 1),
			'thread.root.status'=>formatStatus($root->get("status")),
			'thread.last.subject'=>chopSubject($last->get("subject")),
			'thread.last.url'=>formatThreadURL($callback,$last->get("forumPostId")),
			'thread.last.epoch'=>$last->get("dateOfPost"),
			'thread.last.date'=>formatPostDate($last->get("dateOfPost")),
			'thread.last.time'=>formatPostTime($last->get("dateOfPost")),
			'thread.last.user.profile'=>formatUserProfileURL($last->get("userId")),
			'thread.last.user.name'=>$last->get("username"),
			'thread.last.user.id'=>$last->get("userId"),
			'thread.last.user.isVisitor'=>($root->get("userId") == 1),
			'thread.last.status'=>formatStatus($last->get("status"))
			});
	}
	$var{thread_loop} = \@thread_loop;
	return \%var; 
}	

#-------------------------------------------------------------------

=head2 getPostTemplateVars ( post, thread, forum, caller [, var ] )

Returns a hash reference compatible with WebGUI's templating system containing the template variables for a post.

=over

=item post

A post object.

=item thread

A thread object.

=item forum

A forum object.

=item caller

A hash reference containing information passed from the calling object.

=item var

A hash reference to be prepended to the hashref being returned.

=back

=cut

sub getPostTemplateVars {
        my ($post, $thread, $forum, $caller, $var) = @_;
	my $callback = $caller->{callback};
	$var->{'callback.url'} = $callback;
	$var->{'callback.label'} = WebGUI::International::get(1039);
	$var->{'post.subject.label'} = WebGUI::International::get(229);
        $var->{'post.subject'} = WebGUI::HTML::filter($post->get("subject"),"none");
        $var->{'post.message'} = WebGUI::HTML::filter($post->get("message"),$forum->get("filterPosts"));
	if ($post->get("contentType") eq "mixed") {
		unless ($var->{'post.message'} =~ /\<div/ig || $var->{'post.message'} =~ /\<br/ig || $var->{'post.message'} =~ /\<p/ig) {
                	$var->{'post.message'} =~ s/\n/\<br \/\>/g;
        	}
	} elsif ($post->get("contentType") eq "text") {
               	$var->{'post.message'} =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
               	$var->{'post.message'} =~ s/\n/\<br \/\>/g;
	} elsif ($post->get("contentType") eq "code") {
               	$var->{'post.message'} =~ s/&/&amp;/g;
               	$var->{'post.message'} =~ s/\</&lt;/g;
               	$var->{'post.message'} =~ s/\>/&gt;/g;
               	$var->{'post.message'} =~ s/\n/\<br \/\>/g;
               	$var->{'post.message'} =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
               	$var->{'post.message'} =~ s/ /&nbsp;/g;
               	$var->{'post.message'} = '<div style="font-family: monospace;">'.$var->{'post.message'}.'</div>';
	}
        if ($forum->get("allowReplacements")) {
                my $sth = WebGUI::SQL->read("select searchFor,replaceWith from replacements");
                while (my ($searchFor,$replaceWith) = $sth->array) {
                        $var->{'post.message'} =~ s/\Q$searchFor/$replaceWith/gs;
                }
                $sth->finish;
        }
	$var->{'user.canPost'} = $forum->canPost;
        $var->{'post.date.value'} = formatPostDate($post->get("dateOfPost"));
	$var->{'post.date.label'} = WebGUI::International::get(245);
        $var->{'post.date.epoch'} = $post->get("dateOfPost");
        $var->{'post.time.value'} = formatPostTime($post->get("dateOfPost"));
	$var->{'post.rating.value'} = $post->get("rating")+0;
	$var->{'post.rating.label'} = WebGUI::International::get(1020);
	$var->{'post.views.value'} = $post->get("views")+0;
	$var->{'post.views.label'} = WebGUI::International::get(514);
	$var->{'post.status.value'} = formatStatus($post->get("status"));
	$var->{'post.status.label'} = WebGUI::International::get(553);
	$var->{'post.isLocked'} = $thread->isLocked;
	$var->{'post.isModerator'} = $forum->isModerator;
	$var->{'post.canEdit'} = $post->canEdit($session{user}{userId});
	$var->{'post.user.isVisitor'} = ($post->get("userId") == 1);
	$var->{'post.user.label'} = WebGUI::International::get(244);
	$var->{'post.user.name'} = $post->get("username");
	$var->{'post.user.Id'} = $post->get("userId");
	$var->{'post.user.Profile'} = formatUserProfileURL($post->get("userId"));
	$var->{'post.url'} = formatThreadURL($callback,$post->get("forumPostId"));
	$var->{'post.id'} = $post->get("forumPostId");
	$var->{'post.rate.label'} = WebGUI::International::get(1021);
	$var->{'post.rate.url.1'} = formatRatePostURL($callback,$post->get("forumPostId"),1);
	$var->{'post.rate.url.2'} = formatRatePostURL($callback,$post->get("forumPostId"),2);
	$var->{'post.rate.url.3'} = formatRatePostURL($callback,$post->get("forumPostId"),3);
	$var->{'post.rate.url.4'} = formatRatePostURL($callback,$post->get("forumPostId"),4);
	$var->{'post.rate.url.5'} = formatRatePostURL($callback,$post->get("forumPostId"),5);
	$var->{'post.hasRated'} = $post->hasRated;
	$var->{'post.reply.label'} = WebGUI::International::get(577);
	$var->{'post.reply.url'} = formatReplyPostURL($callback,$post->get("forumPostId"),$forum->get("forumId"));
	$var->{'post.reply.withquote.url'} = formatReplyPostURL($callback,$post->get("forumPostId"),$forum->get("forumId"),1);
	$var->{'post.edit.label'} = WebGUI::International::get(575);
	$var->{'post.edit.url'} = formatEditPostURL($callback,$post->get("forumPostId"));
	$var->{'post.delete.label'} = WebGUI::International::get(576);
	$var->{'post.delete.url'} = formatDeletePostURL($callback,$post->get("forumPostId"));
	$var->{'post.approve.label'} = WebGUI::International::get(572);
	$var->{'post.approve.url'} = formatApprovePostURL($callback,$post->get("forumPostId"));
	$var->{'post.deny.label'} = WebGUI::International::get(574);
	$var->{'post.deny.url'} = formatDenyPostURL($callback,$post->get("forumPostId"));
	$var->{'forum.title'} = $callback->{title};
	$var->{'forum.description'} = $callback->{description};
	$var->{'post.full'} = WebGUI::Template::process(WebGUI::Template::get($forum->get("postTemplateId"),"Forum/Post"), $var); 
	return $var;
}

#-------------------------------------------------------------------

=head2 getThreadTemplateVars ( caller, post )

Returns a hash reference compatible with WebGUI's template system containing the template variables for the thread.

=over

=item caller

A hash reference containing information passed from the calling object.

=item post

A post object.

=back

=cut

sub getThreadTemplateVars {
        my ($caller, $post) = @_;
	my $callback = $caller->{callback};
        $post->markRead($session{user}{userId});
        my $thread = $post->getThread;
	unless ($post->canView) {
		$post = $thread->getPost($thread->get("rootPostId"));
	}
        my $forum = $thread->getForum;
        my $var = getPostTemplateVars($post, $thread, $forum, $caller);
        my $root = WebGUI::Forum::Post->new($thread->get("rootPostId"));
	$var->{'callback.url'} = $callback;
	$var->{'callback.label'} = WebGUI::International::get(1039);
        $var->{'user.canPost'} = $forum->canPost;
        $var->{'user.isVisitor'} = ($session{user}{userId} == 1);
        $var->{'user.isModerator'} = $forum->isModerator;
        $var->{'user.isSubscribed'} = $thread->isSubscribed;
	$var->{'thread.layout.nested.label'} = WebGUI::International::get(1045);
	$var->{'thread.layout.nested.url'} = formatThreadLayoutURL($callback,$post->get("forumPostId"),"nested");
	$var->{'thread.layout.flat.label'} = WebGUI::International::get(510);
	$var->{'thread.layout.flat.url'} = formatThreadLayoutURL($callback,$post->get("forumPostId"),"flat");
	$var->{'thread.layout.threaded.label'} = WebGUI::International::get(511);
	$var->{'thread.layout.threaded.url'} = formatThreadLayoutURL($callback,$post->get("forumPostId"),"threaded");
	my $layout = $session{scratch}{forumThreadLayout} || $session{user}{discussionLayout};
        $var->{'thread.layout.isFlat'} = ($layout eq "flat");
        $var->{'thread.layout.isNested'} = ($layout eq "nested");
        $var->{'thread.layout.isThreaded'} = ($layout eq "threaded" || !($var->{'thread.layout.isNested'} || $var->{'thread.layout.isFlat'}));
        $var->{'thread.subscribe.url'} = formatThreadSubscribeURL($callback,$post->get("forumPostId"));
        $var->{'thread.subscribe.label'} = WebGUI::International::get(873);
        $var->{'thread.unsubscribe.url'} = formatThreadUnsubscribeURL($callback,$post->get("forumPostId"));
        $var->{'thread.unsubscribe.label'} = WebGUI::International::get(874);
        $var->{'thread.isSticky'} = $thread->isSticky;
        $var->{'thread.stick.url'} = formatThreadStickURL($callback,$post->get("forumPostId"));
        $var->{'thread.stick.label'} = WebGUI::International::get(1037);
        $var->{'thread.unstick.url'} = formatThreadUnstickURL($callback,$post->get("forumPostId"));
        $var->{'thread.unstick.label'} = WebGUI::International::get(1038);
        $var->{'thread.isLocked'} = $thread->isLocked;
        $var->{'thread.lock.url'} = formatThreadLockURL($callback,$post->get("forumPostId"));
        $var->{'thread.lock.label'} = WebGUI::International::get(1040);
        $var->{'thread.unlock.url'} = formatThreadUnlockURL($callback,$post->get("forumPostId"));
        $var->{'thread.unlock.label'} = WebGUI::International::get(1041);
        $var->{post_loop} = recurseThread($root, $thread, $forum, 0, $caller, $post->get("forumPostId"));
        $var->{'thread.subject.label'} = WebGUI::International::get(229);
        $var->{'thread.date.label'} = WebGUI::International::get(245);
        $var->{'thread.user.label'} = WebGUI::International::get(244);
        $var->{'thread.new.url'} = formatNewThreadURL($callback,$thread->get("forumId"));
        $var->{'thread.new.label'} = WebGUI::International::get(1018);
        $var->{'thread.previous.url'} = formatPreviousThreadURL($callback,$thread->get("forumThreadId"));
        $var->{'thread.previous.label'} = WebGUI::International::get(513);
        $var->{'thread.next.url'} = formatNextThreadURL($callback,$thread->get("forumThreadId"));
        $var->{'thread.next.label'} = WebGUI::International::get(512);
        $var->{'thread.list.url'} = formatForumURL($callback,$forum->get("forumId"));
        $var->{'thread.list.label'} = WebGUI::International::get(1019);
	$var->{'forum.title'} = $caller->{title};
	$var->{'forum.description'} = $caller->{description};
        return $var;
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 notifySubscribers ( post, thread, forum, caller )

Send notifications to the thread and forum subscribers that a new post has been made.

=over

=item post

A post object.

=item thread

A thread object.

=item forum

A forum object.

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub notifySubscribers {
        my ($post, $thread, $forum, $caller) = @_;
	my %subscribers;
        my $sth = WebGUI::SQL->read("select userId from forumThreadSubscription where forumThreadId=".$thread->get("forumThreadId"));
	while (my ($userId) = $sth->array) { 
		$subscribers{$userId} = $userId unless ($userId == $post->get("userId"));	# make sure we don't send unnecessary messages 
	}
        $sth->finish;
        $sth = WebGUI::SQL->read("select userId from forumSubscription where forumId=".$forum->get("forumId"));
	while (my ($userId) = $sth->array) { 
		$subscribers{$userId} = $userId unless ($userId == $post->get("userId"));	# make sure we don't send unnecessary messages 
	}
        $sth->finish;
	my %lang;
	foreach my $userId (keys %subscribers) {
		my $u = WebGUI::User->new($userId);
		if ($lang{$u->profileField("language")}{message} eq "") {
			$lang{$u->profileField("language")}{var} = {
				'notify.subscription.message' => WebGUI::International::get(875,"WebGUI",$u->profileField("language"))
				};
			$lang{$u->profileField("language")}{var} = getPostTemplateVars($post, $thread, $forum, $caller, $lang{$u->profileField("language")}{var});
			$lang{$u->profileField("language")}{subject} = WebGUI::International::get(523,"WebGUI",$u->profileField("language"));
       			$lang{$u->profileField("language")}{message} = WebGUI::Template::process(
				WebGUI::Template::get($forum->get("notificationTemplateId"),"Forum/Notification"), 
				$lang{$u->profileField("language")}{var}
				);
		}
               	WebGUI::MessageLog::addEntry($userId,"",$lang{$u->profileField("language")}{subject},$lang{$u->profileField("language")}{message});
	}
}

#-------------------------------------------------------------------

=head2 recurseThread ( post, thread, forum, depth, caller, currentPost ) 

Returns an array reference with the template variables from all the posts in a thread.

=over

=item post

A post object.

=item thread

A thread object.

=item forum

A forum object.

=item depth

An integer representing the depth of the current recurrsion. Starts at 0.

=item caller

A hash reference containing information passed from the calling object.

=item currentPost

The unique id of the post that was selected by the user in this thread.

=back

=cut

sub recurseThread {
        my ($post, $thread, $forum, $depth, $caller, $currentPost) = @_;
        my @depth_loop;
        for (my $i=0; $i<$depth; $i++) {
                push(@depth_loop,{depth=>$i});
        }
        my @post_loop;
	if ($post->canView) {
        	push (@post_loop, getPostTemplateVars($post, $thread, $forum, $caller, {
                	'post.indent_loop'=>\@depth_loop,
                	'post.indent.depth'=>$depth,
                	'post.isCurrent'=>($currentPost == $post->get("forumPostId"))
                	}));
        	my $replies = $post->getReplies;
        	foreach my $reply (@{$replies}) {
                	@post_loop = (@post_loop,@{recurseThread($reply, $thread, $forum, $depth+1, $caller, $currentPost)});
        	}
	}
        return \@post_loop;
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 setPostApproved ( caller, post )

Sets the post to approved and sends any necessary notifications.

=over

=item caller

A hash reference containing information passed from the calling object.

=item post

A post object.

=back

=cut

sub setPostApproved {
	my ($caller, $post) = @_;
	$post->setStatusApproved;
	unless ($session{user}{userId} == $post->get("userId")) {
		WebGUI::MessageLog::addInternationalizedEntry($post->get("userId"),'',formatThreadURL($caller->{callback},$post->get("forumPostId")),579);
	}
	notifySubscribers($post,$post->getThread,$post->getThread->getForum,$caller);
}

#-------------------------------------------------------------------

=head2 setPostDeleted ( caller, post )

Sets the post to deleted and sends any necessary notifications.

=over

=item caller

A hash reference containing information passed from the calling object.

=item post

A post object.

=back

=cut

sub setPostDeleted {
	my ($caller, $post) = @_;
	$post->setStatusDeleted;
}

#-------------------------------------------------------------------

=head2 setPostDenied ( caller, post )

Sets the post to denied and sends any necessary notifications.

=over

=item caller

A hash reference containing information passed from the calling object.

=item post

A post object.

=back

=cut

sub setPostDenied {
	my ($caller, $post) = @_;
	$post->setStatusDenied;
	WebGUI::MessageLog::addInternationalizedEntry($post->get("userId"),'',formatThreadURL($caller->{callback},$post->get("forumPostId")),580);
}

#-------------------------------------------------------------------

=head2 setPostPending ( caller, post )

Sets the post to pending and sends any necessary notifications.

=over

=item caller

A hash reference containing information passed from the calling object.

=item post

A post object.

=back

=cut

sub setPostPending {
	my ($caller, $post) = @_;
	$post->setStatusPending;
	WebGUI::MessageLog::addInternationalizedEntry('',$post->getThread->getForum->get("groupToModerate"),
		formatThreadURL($caller->{callback},$post->get("forumPostId")),578,'WebGUI','pending');
}

#-------------------------------------------------------------------

=head2 setPostStatus ( caller, post ) 

Sets a new post's status based upon forum settings.

=over

=item caller

A hash reference containing information passed from the calling object.

=item post

A post object.

=back

=cut

sub setPostStatus {
	my ($caller, $post) = @_;
	if ($post->getThread->getForum->get("moderatePosts")) {
		setPostPending($caller,$post);
	} else {
		setPostApproved($caller,$post);
	}
}

#-------------------------------------------------------------------

=head2 www_approvePost ( caller )

The web method to approve a post.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_approvePost {
	my ($caller) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->isModerator);
	setPostApproved($caller,$post);
       	return www_viewThread($caller);
}

#-------------------------------------------------------------------

=head2 www_deletePost ( caller )

The web method to prompt a user as to whether they actually want to delete a post.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_deletePost {
	my ($caller) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->canEdit);
      	my $output = '<h1>'.WebGUI::International::get(42).'</h1>';
       	$output .= WebGUI::International::get(401).'<p>';
       	$output .= '<div align="center"><a href="'.WebGUI::URL::append($caller->{callback},"forumOp=deletePostConfirm&amp;forumPostId="
		.$session{form}{forumPostId}).'">'.WebGUI::International::get(44).'</a>';
       	$output .= ' &nbsp; <a href="'.$caller->{callback}.'">'.WebGUI::International::get(45).'</a></div>';
       	return $output;
}

#-------------------------------------------------------------------

=head2 www_deletePostConfirm ( caller )

The web method to delete a post.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_deletePostConfirm {
	my ($caller) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->canEdit);
	$post->setStatusDeleted;
       	return www_viewForum($caller,$post->getThread->get("forumId"));
}

#-------------------------------------------------------------------

=head2 www_denyPost ( caller )

The web method to deny a post.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_denyPost {
	my ($caller) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->canEdit($session{user}{userId}));
	setPostDenied($caller,$post);
       	return www_viewThread($caller);
}

#-------------------------------------------------------------------

=head2 www_forumSubscribe ( caller )

The web method to subscribe to a forum.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_forumSubscribe {
	my ($caller) = @_;
	my $forum = WebGUI::Forum->new($session{form}{forumId});
	return WebGUI::Privilege::insufficient() unless ($session{user}{userId} != 1);
	$forum->subscribe;
	return www_viewForum($caller, $session{form}{forumId});
}

#-------------------------------------------------------------------

=head2 www_forumUnsubscribe ( caller )

The web method to unsubscribe from a forum.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_forumUnsubscribe {
	my ($caller) = @_;
	my $forum = WebGUI::Forum->new($session{form}{forumId});
	return WebGUI::Privilege::insufficient() unless ($session{user}{userId} != 1);
	$forum->unsubscribe;
	return www_viewForum($caller, $session{form}{forumId});
}

#-------------------------------------------------------------------

=head2 www_nextThread ( caller )

The web method to display the next thread in the forum.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_nextThread {
	my ($caller) = @_;
	my $thread = WebGUI::Forum::Thread->new($session{form}{forumThreadId});
	my $nextThreadRoot = $thread->getNextThread->get("rootPostId");
	if (defined $nextThreadRoot) {
		return www_viewThread($caller,$nextThreadRoot);
	} else {
		return www_viewForum($caller,$thread->get("forumId"));
	}
}

#-------------------------------------------------------------------

=head2 www_post ( caller )

The web method to display the post form.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_post {
	my ($caller) = @_;
	my ($subject, $message, $forum);
	my $var;
	$var->{'newpost.header'} = WebGUI::International::get(1064);
	$var->{'newpost.isReply'} = ($session{form}{parentId} ne "");
	$var->{'newpost.isEdit'} = ($session{form}{forumPostId} ne "");
	$var->{'newpost.isNewThread'} = ($session{form}{parentId} eq "" && !$var->{'newpost.isEdit'});
	$var->{'user.isVisitor'} = ($session{user}{userId} == 1);
	$var->{'newpost.isNewMessage'} = ($var->{'newpost.isNewThread'} || $var->{'newpost.isReply'});
	$var->{'form.begin'} = WebGUI::Form::formHeader({
		action=>$caller->{callback}
		});
	my $defaultSubscribeValue = 0;
	my $contentType = "mixed";
	if ($var->{'newpost.isReply'}) {
		my $reply = WebGUI::Forum::Post->new($session{form}{parentId});
		return WebGUI::Privilege::insufficient unless ($reply->getThread->getForum->canPost);
		$var->{'form.begin'} .= WebGUI::Form::hidden({
			name=>'parentId',
			value=>$reply->get("forumPostId")
			});
		$forum = $reply->getThread->getForum;
		$var->{'form.begin'} .= WebGUI::Form::hidden({
			name=>'forumId',
			value=>$forum->get("forumId")
			});
		$message = "[quote]".$reply->get("message")."[/quote]" if ($session{form}{withQuote});
		$var = getPostTemplateVars($reply, $reply->getThread, $forum, $caller, $var);

		$subject = $reply->get("subject");
		$subject = "Re: ".$subject unless ($subject =~ /^Re:/);
	}
	if ($var->{'newpost.isNewThread'}) {
		$var->{'form.begin'} .= WebGUI::Form::hidden({
			name=>'forumId',
			value=>$session{form}{forumId}
			});
		$forum = WebGUI::Forum->new($session{form}{forumId});
		if ($forum->isModerator) {
			$var->{'sticky.label'} = WebGUI::International::get(1013);
			$var->{'sticky.form'} = WebGUI::Form::yesNo({
				name=>'isSticky',
				value=>0
				});
		}
		$defaultSubscribeValue = 1 unless ($forum->isSubscribed);
	}
	if ($var->{'newpost.isNewMessage'}) {
		$var->{'subscribe.label'} = WebGUI::International::get(873);
		return WebGUI::Privilege::insufficient unless ($forum->canPost);
		if ($forum->isModerator) {
			$var->{'lock.label'} = WebGUI::International::get(1012);
			$var->{'lock.form'} = WebGUI::Form::yesNo({
				name=>'isLocked',
				value=>0
				});
		}
		$var->{'subscribe.form'} = WebGUI::Form::yesNo({
			name=>'subscribe',
			value=>$defaultSubscribeValue
			});
		$message .= "\n\n".$session{user}{signature} if ($session{user}{signature});
	}
	if ($var->{'newpost.isEdit'}) {
		my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
		return WebGUI::Privilege::insufficient unless ($post->getThread->getForum->canPost);
		$subject = $post->get("subject");
		$message = $post->get("message");
		$forum = $post->getThread->getForum;
		$var->{'form.begin'} .= WebGUI::Form::hidden({
			name=>"forumPostId",
			value=>$post->get("forumPostId")
			});
		$contentType = $post->get("contentType");
	}
	$var->{'contentType.label'} = WebGUI::International::get(1007);
	$var->{'contentType.form'} = WebGUI::Form::contentType({
		name=>'contentType',
		value=>[$contentType]
		});
	$var->{'user.isModerator'} = $forum->isModerator;
	$var->{allowReplacements} = $forum->get("allowReplacements");
	if ($forum->get("allowRichEdit")) {
		$var->{'message.form'} = WebGUI::Form::HTMLArea({
			name=>'message',
			value=>$message
			});
	} else {
		$var->{'message.form'} = WebGUI::Form::textarea({
			name=>'message',
			value=>$message
			});
	}
	$var->{'message.label'} = WebGUI::International::get(230);
	if ($var->{'user.isVisitor'}) {
		$var->{'visitorName.label'} = WebGUI::International::get(438);
		$var->{'visitorName.form'} = WebGUI::Form::text({
			name=>'visitorName'
			});
	}
	$var->{'form.begin'} .= WebGUI::Form::hidden({
		name=>'forumOp',
		value=>'postSave'
		});
	$var->{'form.submit'} = WebGUI::Form::submit();
	$var->{'subject.label'} = WebGUI::International::get(229);
	$var->{'subject.form'} = WebGUI::Form::text({
		name=>'subject',
		value=>$subject
		});
	$var->{'form.end'} = '</form>';
	return WebGUI::Template::process(WebGUI::Template::get($forum->get("postformTemplateId"),"Forum/PostForm"), $var); 
}

#-------------------------------------------------------------------

=head2 www_postSave ( caller )

The web method to save the data from the post form.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_postSave {
	my ($caller) = @_;
	my $forumId = $session{form}{forumId};
	my $threadId = $session{form}{forumThreadId};
	my $postId = $session{form}{forumPostId};
	$session{form}{subject} = WebGUI::International::get(232) if ($session{form}{subject} eq "");
	$session{form}{subject} .= ' '.WebGUI::International::get(233) if ($session{form}{message} eq "");
	my %postData = (
		message=>$session{form}{message},
		subject=>formatSubject($session{form}{subject}),
                contentType=>$session{form}{contentType}
		);
	my %postDataNew = (
		userId=>$session{user}{userId},
		username=>($session{form}{visitorName} || $session{user}{alias})
		);
	if ($session{form}{parentId} > 0) { # reply
		%postData = (%postData, %postDataNew);
		my $parentPost = WebGUI::Forum::Post->new($session{form}{parentId});
		return WebGUI::Privilege::insufficient unless ($parentPost->getThread->getForum->canPost);
		$parentPost->getThread->subscribe($session{user}{userId}) if ($session{form}{subscribe});
		$parentPost->getThread->lock if ($session{form}{isLocked});
		$postData{forumThreadId} = $parentPost->getThread->get("forumThreadId");
		$postData{parentId} = $session{form}{parentId};
		my $post = WebGUI::Forum::Post->create(\%postData);
		setPostStatus($caller,$post);
		return www_viewThread($caller,$post->get("forumPostId"));
	}
	if ($session{form}{forumPostId} > 0) { # edit
		my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
		return WebGUI::Privilege::insufficient unless ($post->canEdit);
		if ($post->getThread->getForum->get("addEditStampToPosts")) {
			$postData{message} .= "\n\n --- (".WebGUI::International::get(1029)." "
                        .WebGUI::DateTime::epochToHuman(WebGUI::DateTime::time())." ".WebGUI::International::get(1030)
                        ." $session{user}{username}) --- \n";
		}
		$post->set(\%postData);	
		return www_viewThread($caller,$post->get("forumPostId"));
	}
	if ($forumId) { # new post
		%postData = (%postData, %postDataNew);
		my $forum = WebGUI::Forum->new($forumId);
		return WebGUI::Privilege::insufficient unless ($forum->canPost);
		my $thread = WebGUI::Forum::Thread->create({
			forumId=>$forumId,
			isSticky=>$session{form}{isSticky},
			isLocked=>$session{form}{isLocked}
			}, \%postData);
		$thread->subscribe($session{user}{userId}) if ($session{form}{subscribe});
		setPostStatus($caller,$thread->getPost($thread->get("rootPostId")));
		return www_viewForum($caller, $forumId);
	}
}

#-------------------------------------------------------------------

=head2 www_previousThread ( caller )

The web method to view the previous thread in this forum.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_previousThread {
	my ($caller) = @_;
	my $thread = WebGUI::Forum::Thread->new($session{form}{forumThreadId});
	my $previousThreadRoot = $thread->getPreviousThread->get("rootPostId");
	if (defined $previousThreadRoot) {
		return www_viewThread($caller,$previousThreadRoot);
	} else {
		return www_viewForum($caller,$thread->get("forumId"));
	}
}

#-------------------------------------------------------------------

=head2 www_ratePost ( caller )

The web method to rate a post.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_ratePost {
	my ($caller) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->canPost);
	$post->rate($session{form}{rating}) unless ($post->hasRated);
	return www_viewThread($caller,$session{form}{forumPostId});
}

#-------------------------------------------------------------------

=head2 www_search ( caller )

The web method to display and use the forum search interface.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_search {
	my ($caller) = @_;
	my $forum = WebGUI::Forum->new($session{form}{forumId});
        WebGUI::Session::setScratch("all",$session{form}{all});
        WebGUI::Session::setScratch("atLeastOne",$session{form}{atLeastOne});
        WebGUI::Session::setScratch("exactPhrase",$session{form}{exactPhrase});
        WebGUI::Session::setScratch("without",$session{form}{without});
        WebGUI::Session::setScratch("numResults",$session{form}{numResults});
	my %var;
	$var{'callback.url'} = $caller->{callback};
        $var{'callback.label'} = WebGUI::International::get(1039);
	$var{'form.begin'} = WebGUI::Form::formHeader({action=>$caller->{callback}});
	$var{'form.begin'} .= WebGUI::Form::hidden({ name=>"forumOp", value=>"search" });
	$var{'form.begin'} .= WebGUI::Form::hidden({ name=>"doit", value=>1 });
	$var{'form.begin'} .= WebGUI::Form::hidden({ name=>"forumId", value=>$session{form}{forumId} });
        $var{'search.label'} = WebGUI::International::get(364);
        $var{'all.label'} = WebGUI::International::get(530);
	$var{'all.form'} = WebGUI::Form::text({
		name=>'all',
		value=>$session{scratch}{all},
		size=>($session{setting}{textBoxSize}-5)
		});
        $var{'exactphrase.label'} = WebGUI::International::get(531);
        $var{'exactphrase.form'} = WebGUI::Form::text({
		name=>'exactPhrase',
		value=>$session{scratch}{exactPhrase},
		size=>($session{setting}{textBoxSize}-5)
		});
        $var{'atleastone.label'} = WebGUI::International::get(532);
        $var{'atleastone.form'} = WebGUI::Form::text({
		name=>'atLeastOne',
		value=>$session{scratch}{atLeastOne},
		size=>($session{setting}{textBoxSize}-5)
		});
        $var{'without.label'} = WebGUI::International::get(533);
        $var{'without.form'} = WebGUI::Form::text({
		name=>'without',
		value=>$session{scratch}{without},
		size=>($session{setting}{textBoxSize}-5)
		});
	$var{'results.label'} = WebGUI::International::get(529);
        my %results;
        tie %results, 'Tie::IxHash';
        %results = (10=>'10', 25=>'25', 50=>'50', 100=>'100');
        my $numResults = $session{scratch}{numResults} || 25;
        $var{'results.form'} = WebGUI::Form::selectList({
		name=>"numResults",
		options=>\%results,
		value=>[$numResults]
		});
	$var{'form.search'} = WebGUI::Form::submit({value=>WebGUI::International::get(170)});
	$var{'form.end'} = '</form>';
	$var{'thread.list.url'} = formatForumURL($caller->{callback},$forum->get("forumId"));
        $var{'thread.list.label'} = WebGUI::International::get(1019);
	$var{doit} = $session{form}{doit};
	if ($session{form}{doit}) {
		$var{'post.subject.label'} = WebGUI::International::get(229);
      	  	$var{'post.date.label'} = WebGUI::International::get(245);
        	$var{'post.user.label'} = WebGUI::International::get(244);
		my $query = "select a.forumPostId, a.subject, a.userId, a.username, a.dateOfPost from forumPost a left join forumThread b
			on a.forumThreadId=b.forumThreadId where b.forumId=".$forum->get("forumId")." and 
			(a.status='approved' or a.status='archived') and ".WebGUI::Search::buildConstraints([qw(a.subject a.username a.message)])
			." order by a.dateOfPost desc";
		my $p = WebGUI::Paginator->new(WebGUI::URL::append($caller->{callback},"forumOp=search&amp;doit=1&amp;forumId=".$forum->get("forumId")),
			"", $numResults);
		$p->setDataByQuery($query);
		my @post_loop;
		foreach my $row (@{$p->getPageData}) {
			push(@post_loop,{
				'post.subject'=>formatSubject($row->{subject}),
				'post.url'=>formatThreadURL($caller->{callback},$row->{forumPostId}),
				'post.user.name'=>$row->{username},
				'post.user.id'=>$row->{userId},
				'post.user.profile'=>formatUserProfileURL($row->{userId}),
				'post.epoch'=>$row->{dateOfPost},
				'post.date'=>formatPostDate($row->{dateOfPost}),
				'post.time'=>formatPostTime($row->{dateOfPost})
				});
		}
		$var{post_loop} = \@post_loop;
		$var{firstPage} = $p->getFirstPageLink;
	        $var{lastPage} = $p->getLastPageLink;
        	$var{nextPage} = $p->getNextPageLink;
        	$var{pageList} = $p->getPageLinks;
        	$var{previousPage} = $p->getPreviousPageLink;
        	$var{multiplePages} = ($p->getNumberOfPages > 1);
        	$var{numberOfPages} = $p->getNumberOfPages;
        	$var{pageNumber} = $p->getPageNumber;
	}
	return WebGUI::Template::process(WebGUI::Template::get($forum->get("searchTemplateId"),"Forum/Search"), \%var);
}

#-------------------------------------------------------------------

=head2 www_threadLock ( caller )

The web method to lock a thread.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_threadLock {
	my ($caller) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->isModerator);
	$post->getThread->lock;
	return www_viewThread($caller, $session{form}{forumPostId});
}

#-------------------------------------------------------------------

=head2 www_threadStick ( caller )

The web method to make a thread sticky.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_threadStick {
	my ($caller) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->isModerator);
	$post->getThread->stick;
	return www_viewThread($caller, $session{form}{forumPostId});
}

#-------------------------------------------------------------------

=head2 www_threadSubscribe ( caller )

The web method to subscribe to a thread.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_threadSubscribe {
	my ($caller) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($session{user}{userId} != 1);
	$post->getThread->subscribe;
	return www_viewThread($caller, $session{form}{forumPostId});
}

#-------------------------------------------------------------------

=head2 www_threadUnlock ( caller )

The web method to unlock a thread.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_threadUnlock {
	my ($caller) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->isModerator);
	$post->getThread->unlock;
	return www_viewThread($caller, $session{form}{forumPostId});
}

#-------------------------------------------------------------------

=head2 www_threadUnstick ( caller )

The web method to make a sticky thread normal again. 

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_threadUnstick {
	my ($caller) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->isModerator);
	$post->getThread->unstick;
	return www_viewThread($caller, $session{form}{forumPostId});
}

#-------------------------------------------------------------------

=head2 www_threadUnsubscribe ( caller )

The web method to unsubscribe from a thread.

=over

=item caller

A hash reference containing information passed from the calling object.

=back

=cut

sub www_threadUnsubscribe {
	my ($caller) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($session{user}{userId} != 1);
	$post->getThread->unsubscribe;
	return www_viewThread($caller, $session{form}{forumPostId});
}

#-------------------------------------------------------------------

=head2 www_viewForum ( caller [ , forumId ] )

The web method to display a forum. 

=over

=item caller

The url to get back to the calling object.

=item forumId 

Specify a forumId and call this method directly, rather than over the web.

=back

=cut

sub www_viewForum {
	my ($caller, $forumId) = @_;
	WebGUI::Session::setScratch("forumSortBy",$session{form}{sortBy});
	$forumId = $session{form}{forumId} unless ($forumId);
	my $forum = WebGUI::Forum->new($forumId);
	my $var = getForumTemplateVars($caller, $forum);
	return WebGUI::Template::process(WebGUI::Template::get($forum->get("forumTemplateId"),"Forum"), $var); 
}	

#-------------------------------------------------------------------

=head2 www_viewThread ( caller [ , postId ] )

The web method to display a thread. 

=over

=item caller

A hash reference containing information passed from the calling object.

=item postId 

Specify a postId and call this method directly, rather than over the web.

=back

=cut

sub www_viewThread {
	my ($caller, $postId) = @_;
	WebGUI::Session::setScratch("forumThreadLayout",$session{form}{layout});
	$postId = $session{form}{forumPostId} unless ($postId);
	 # If POST, cause redirect, so new post is displayed using GET instead of POST
	if ($session{env}{REQUEST_METHOD} =~ /POST/i) { 
		my $url= formatThreadURL($caller-> {callback}, $postId); 
		$session{header}{redirect} = WebGUI::Session::httpRedirect($url);
		return "";
	}
        my $post = WebGUI::Forum::Post->new($postId);
	my $var = getThreadTemplateVars($caller, $post);
	if ($post->get("forumPostId") == $post->getThread->get("rootPostId") && !$post->canView) {
		return www_viewForum($caller, $post->getThread->getForum->get("forumId"));
	} else {	
		return WebGUI::Template::process(WebGUI::Template::get($post->getThread->getForum->get("threadTemplateId"),"Forum/Thread"), $var); 
	}
}


1;

