package WebGUI::Forum::UI;

use strict qw(vars subs);
use WebGUI::DateTime;
use WebGUI::Form;
use WebGUI::FormProcessor;
use WebGUI::Forum;
use WebGUI::Forum::Post;
use WebGUI::Forum::Thread;
use WebGUI::HTML;
use WebGUI::MessageLog;
use WebGUI::Session;
use WebGUI::Template;


sub chopSubject {
	return substr(formatSubject($_[0]),0,30);
}

sub formatApprovePostURL {
	return WebGUI::URL::append($_[0],"forumOp=approvePost&amp;forumPostId=".$_[1]."&amp;mlog=".$session{form}{mlog});
}

sub formatDeletePostURL {
	return WebGUI::URL::append($_[0],"forumOp=deletePost&amp;forumPostId=".$_[1]);
}

sub formatDenyPostURL {
	return WebGUI::URL::append($_[0],"forumOp=denyPost&amp;forumPostId=".$_[1]."&amp;mlog=".$session{form}{mlog});
}

sub formatEditPostURL {
	return WebGUI::URL::append($_[0],"forumOp=post&amp;forumPostId=".$_[1]);
}

sub formatForumURL {
	return WebGUI::URL::append($_[0],"forumOp=viewForum&amp;forumId=".$_[1]);
}

sub formatForumSubscribeURL {
	return WebGUI::URL::append($_[0],"forumOp=forumSubscribe&amp;forumId=".$_[1]);
}

sub formatForumUnsubscribeURL {
	return WebGUI::URL::append($_[0],"forumOp=forumUnsubscribe&amp;forumId=".$_[1]);
}

sub formatNextThreadURL {
	return WebGUI::URL::append($_[0],"forumOp=nextThread&amp;forumThreadId=".$_[1]);
}

sub formatNewThreadURL {
	return WebGUI::URL::append($_[0],"forumOp=post&amp;forumId=".$_[1]);
}

sub formatPostDate {
	return WebGUI::DateTime::epochToHuman($_[0],"%z");
}

sub formatPostTime {
	return WebGUI::DateTime::epochToHuman($_[0],"%Z");
}

sub formatPreviousThreadURL {
	return WebGUI::URL::append($_[0],"forumOp=previousThread&amp;forumThreadId=".$_[1]);
}

sub formatRatePostURL {
	return WebGUI::URL::append($_[0],"forumOp=ratePost&amp;forumPostId=".$_[1]."&amp;rating=".$_[2]);
}

sub formatReplyPostURL {
	return WebGUI::URL::append($_[0],"forumOp=post&amp;parentId=".$_[1]);
}

sub formatSubject {
	return WebGUI::HTML::filter($_[0],"all");
}

sub formatStatus {
        if ($_[0] eq "approved") {
                return WebGUI::International::get(560);
        } elsif ($_[0] eq "denied") {
                return WebGUI::International::get(561);
        } elsif ($_[0] eq "pending") {
                return WebGUI::International::get(562);
        }
}

sub formatThreadLockURL {
	return WebGUI::URL::append($_[0],"forumOp=threadLock&amp;forumPostId=".$_[1]);
}

sub formatThreadUnlockURL {
	return WebGUI::URL::append($_[0],"forumOp=threadUnlock&amp;forumPostId=".$_[1]);
}

sub formatThreadStickURL {
	return WebGUI::URL::append($_[0],"forumOp=threadStick&amp;forumPostId=".$_[1]);
}

sub formatThreadSubscribeURL {
	return WebGUI::URL::append($_[0],"forumOp=threadSubscribe&amp;forumPostId=".$_[1]);
}

sub formatThreadUnstickURL {
	return WebGUI::URL::append($_[0],"forumOp=threadUnstick&amp;forumPostId=".$_[1]);
}

sub formatThreadUnsubscribeURL {
	return WebGUI::URL::append($_[0],"forumOp=threadUnsubscribe&amp;forumPostId=".$_[1]);
}

sub formatThreadURL {
	return WebGUI::URL::append($_[0],"forumOp=viewThread&amp;forumPostId=".$_[1]."#".$_[1]);
}

sub formatUserProfileURL {
	return WebGUI::URL::page("op=viewProfile&amp;uid=".$_[0]);
}

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
		-uiLevel=>5
		);
	$f->template(
		-name=>"threadTemplateId",
		-label=>WebGUI::International::get(1032),
		-namespace=>"Forum/Thread",
		-uiLevel=>5
		);
	$f->template(
		-name=>"postTemplateId",
		-label=>WebGUI::International::get(1033),
		-namespace=>"Forum/Post",
		-uiLevel=>5
		);
	$f->template(
		-name=>"postFormTemplateId",
		-label=>WebGUI::International::get(1034),
		-namespace=>"Forum/PostForm",
		-uiLevel=>5
		);
	$f->template(
		-name=>"notificationTemplateId",
		-label=>WebGUI::International::get(1035),
		-namespace=>"Forum/Notification",
		-uiLevel=>5
		);
        my ($interval, $units) = WebGUI::DateTime::secondsToInterval(($forum->get("editTimeout") || 3600));
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
        if ($session{setting}{useKarma}) {
                $f->integer(
			-name=>"karmaPerPost",
			-label=>WebGUI::International::get(541),
			-value=>$forum->get("karmaPerPost"),
			-uiLevel=>7
			);
        } else {
                $f->hidden(
			-name=>"karmaPerPost",
			-value=>$forum->get("karmaPerPost")
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

sub forumPropertiesSave {
	my %data = (
		editTimeout=>WebGUI::FormProcessor::interval("editTimeout"),
		addEditStampToPosts=>$session{form}{addEditStampToPosts},
		allowRichEdit=>$session{form}{allowRichEdit},
		allowReplacements=>$session{form}{allowReplacements},
		filterPosts=>$session{form}{filterPosts},
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

sub forumOp {
        my ($callback) = @_;
	if ($session{form}{forumOp} =~ /^[A-Za-z]+$/) {
        	my $cmd = "www_".$session{form}{forumOp};
        	return &$cmd($callback);
	} else {
		WebGUI::ErrorHandler::security("execute an invalid forum operation: ".$session{form}{forumOp});
	}
}

sub getForumTemplateVars {
	my ($callback, $forum) = @_;
	my (%var, @thread_loop);
	$var{'callback.url'} = $callback;
	$var{'callback.label'} = WebGUI::International::get(1039);
	$var{'user.isVisitor'} = ($session{user}{userId} == 1);
	$var{'thread.new.url'} = formatNewThreadURL($callback,$forum->get("forumId"));
	$var{'thread.new.label'} = WebGUI::International::get(1018);
	$var{'forum.subscribe.label'} = WebGUI::International::get(1022);
	$var{'forum.subscribe.url'} = formatForumSubscribeURL($callback,$forum->get("forumId"));
	$var{'forum.unsubscribe.label'} = WebGUI::International::get(1023);
	$var{'forum.unsubscribe.url'} = formatForumUnsubscribeURL($callback,$forum->get("forumId"));
	$var{'user.isSubscribed'} = $forum->isSubscribed;
	$var{'user.canPost'} = $forum->canPost;
	$var{'thread.subject.label'} = WebGUI::International::get(229);
	$var{'thread.date.label'} = WebGUI::International::get(245);
	$var{'thread.user.label'} = WebGUI::International::get(244);
	$var{"thread.views.label"} = WebGUI::International::get(514);
        $var{"thread.replies.label"} = WebGUI::International::get(1016);
	$var{'thread.rating.label'} = WebGUI::International::get(1020);
        $var{"thread.last.label"} = WebGUI::International::get(1017);
	my $p = WebGUI::Paginator->new($callback);
	$p->setDataByQuery("select * from forumThread where forumId=".$forum->get("forumId")." order by isSticky desc, lastPostDate desc");
	$var{firstPage} = $p->getFirstPageLink;
        $var{lastPage} = $p->getLastPageLink;
        $var{nextPage} = $p->getNextPageLink;
        $var{pageList} = $p->getPageLinks;
        $var{previousPage} = $p->getPreviousPageLink;
        $var{multiplePages} = ($p->getNumberOfPages > 1);
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

sub getPostTemplateVars {
        my ($post, $thread, $forum, $callback, $var) = @_;
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
               	$var->{'post.message'} =~ s/ /&nbsp;/g;
               	$var->{'post.message'} =~ s/\n/\<br \/\>/g;
	} elsif ($post->get("contentType") eq "code") {
               	$var->{'post.message'} =~ s/&/&amp;/g;
               	$var->{'post.message'} =~ s/\</&lt;/g;
               	$var->{'post.message'} =~ s/\>/&gt;/g;
               	$var->{'post.message'} =~ s/\n/\<br \/\>/g;
               	$var->{'post.message'} =~ s/\t/&nbsp;&nbsp;&nbsp;&nbsp;/g;
               	$var->{'post.message'} =~ s/ /&nbsp;/g;
               	$var->{'post.message'} = '<div style="font-family: fixed;">'.$var->{'post.message'}.'</div>';
	}
        if ($forum->get("allowReplacements")) {
                my $sth = WebGUI::SQL->read("select pattern,replaceWith from forumReplacement");
                while (my ($pattern,$replaceWith) = $sth->array) {
                        $var->{'post.message'} =~ s/\Q$pattern/$replaceWith/g;
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
	$var->{'post.reply.url'} = formatReplyPostURL($callback,$post->get("forumPostId"));
	$var->{'post.edit.label'} = WebGUI::International::get(575);
	$var->{'post.edit.url'} = formatEditPostURL($callback,$post->get("forumPostId"));
	$var->{'post.delete.label'} = WebGUI::International::get(576);
	$var->{'post.delete.url'} = formatDeletePostURL($callback,$post->get("forumPostId"));
	$var->{'post.approve.label'} = WebGUI::International::get(572);
	$var->{'post.approve.url'} = formatApprovePostURL($callback,$post->get("forumPostId"));
	$var->{'post.deny.label'} = WebGUI::International::get(574);
	$var->{'post.deny.url'} = formatDenyPostURL($callback,$post->get("forumPostId"));
	$var->{'post.full'} = WebGUI::Template::process(WebGUI::Template::get($forum->get("postTemplateId"),"Forum/Post"), $var); 
	return $var;
}

sub getThreadTemplateVars {
        my ($callback, $post) = @_;
        $post->markRead($session{user}{userId});
        my $thread = $post->getThread;
        my $forum = $thread->getForum;
        my $var = getPostTemplateVars($post, $thread, $forum, $callback);
        my $root = WebGUI::Forum::Post->new($thread->get("rootPostId"));
	$var->{'callback.url'} = $callback;
	$var->{'callback.label'} = WebGUI::International::get(1039);
        $var->{'user.canPost'} = $forum->canPost;
        $var->{'user.isVisitor'} = ($session{user}{userId} == 1);
        $var->{'user.isModerator'} = $forum->isModerator;
        $var->{'user.isSubscribed'} = $thread->isSubscribed;
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
        $var->{post_loop} = recurseThread($root, $thread, $forum, 0, $callback, $post->get("forumPostId"));
        $var->{'thread.layout.isFlat'} = ($session{user}{discussionLayout} eq "flat");
        $var->{'thread.layout.isNested'} = ($session{user}{discussionLayout} eq "nested");
        $var->{'thread.layout.isThreaded'} = ($session{user}{discussionLayout} eq "threaded" || !($var->{'thread.layout.isNested'} || $var->{'thread.layout.isFlat'}));
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
        return $var;
}
                                                                                                                                                             

sub notifySubscribers {
        my ($post, $thread, $forum, $callback) = @_;
	my %subscribers;
        my $sth = WebGUI::SQL->read("select userId from forumThreadSubscription where forumThreadId=".$thread->get("forumThreadId"));
	while (my ($userId) = $sth->array) { 
		$subscribers{$userId} = $userId unless ($userId == $post->get("userId"));	# make sure we don't send unnecessary messages 
	}
        $sth->finish;
        my $sth = WebGUI::SQL->read("select userId from forumSubscription where forumId=".$forum->get("forumId"));
	while (my ($userId) = $sth->array) { 
		$subscribers{$userId} = $userId unless ($userId == $post->get("userId"));	# make sure we don't send unnecessary messages 
	}
        $sth->finish;
	my $var = {
		'notify.subscription.message' => WebGUI::International::get(875)
		};
	$var = getPostTemplateVars($post, $thread, $forum, $callback, $var);
	my $subject = WebGUI::International::get(523);
       	my $message = WebGUI::Template::process(WebGUI::Template::get($forum->get("notificationTemplateId"),"Forum/Notification"), $var);
	foreach my $userId (keys %subscribers) {
               	WebGUI::MessageLog::addEntry($userId,"",$subject,$message);
	}
}

sub recurseThread {
        my ($post, $thread, $forum, $depth, $callback, $currentPost) = @_;
        my @depth_loop;
        for (my $i=0; $i<$depth; $i++) {
                push(@depth_loop,{depth=>$i});
        }
        my @post_loop;
        push (@post_loop, getPostTemplateVars($post, $thread, $forum, $callback, {
                'post.indent_loop'=>\@depth_loop,
                'post.indent.depth'=>$depth,
                'post.isCurrent'=>($currentPost == $post->get("forumPostId"))
                }));
        my $replies = $post->getReplies;
        foreach my $reply (@{$replies}) {
                @post_loop = (@post_loop,@{recurseThread($reply, $thread, $forum, $depth+1, $callback, $currentPost)});
        }
        return \@post_loop;
}
                                                                                                                                                             
sub www_approvePost {
	my ($callback) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->isModerator);
	$post->setStatusApproved;
       	return www_viewThread($callback);
}

sub www_deletePost {
	my ($callback) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->canEdit);
      	my $output = '<h1>'.WebGUI::International::get(42).'</h1>';
       	$output .= WebGUI::International::get(401).'<p>';
       	$output .= '<div align="center"><a href="'.WebGUI::URL::append($callback,"forumOp=deletePostConfirm&amp;forumPostId="
		.$session{form}{forumPostId}).'">'.WebGUI::International::get(44).'</a>';
       	$output .= ' &nbsp; <a href="'.$callback.'">'.WebGUI::International::get(45).'</a></div>';
       	return $output;
}

sub www_deletePostConfirm {
	my ($callback) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->isModerator);
	$post->setStatusDeleted;
       	return www_viewForum($callback,$post->getThread->get("forumId"));
}

sub www_denyPost {
	my ($callback) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->canEdit($session{user}{userId}));
	$post->setStatusDenied;
       	return www_viewThread($callback);
}

sub www_forumSubscribe {
	my ($callback) = @_;
	my $forum = WebGUI::Forum->new($session{form}{forumId});
	return WebGUI::Privilege::insufficient() unless ($forum->canPost && $session{user}{userId} != 1);
	$forum->subscribe;
	return www_viewForum($callback, $session{form}{forumId});
}

sub www_forumUnsubscribe {
	my ($callback) = @_;
	my $forum = WebGUI::Forum->new($session{form}{forumId});
	return WebGUI::Privilege::insufficient() unless ($session{user}{userId} != 1);
	$forum->unsubscribe;
	return www_viewForum($callback, $session{form}{forumId});
}

sub www_nextThread {
	my ($callback) = @_;
	my $thread = WebGUI::Forum::Thread->new($session{form}{forumThreadId});
	my $nextThreadRoot = $thread->getNextThread->get("rootPostId");
	if (defined $nextThreadRoot) {
		return www_viewThread($callback,$nextThreadRoot);
	} else {
		return www_viewForum($callback,$thread->get("forumId"));
	}
}

sub www_post {
	my ($callback) = @_;
	my ($subject, $message, $forum);
	my $var;
	$var->{'newpost.header'} = 'Post a Message';
	$var->{'newpost.isNewThread'} = ($session{form}{forumId} ne "");
	$var->{'newpost.isReply'} = ($session{form}{parentId} ne "");
	$var->{'newpost.isEdit'} = ($session{form}{forumPostId} ne "");
	$var->{'user.isVisitor'} = ($session{user}{userId} == 1);
	$var->{'newpost.isNewMessage'} = ($var->{'newpost.isNewThread'} || $var->{'newpost.isReply'});
	$var->{'form.begin'} = WebGUI::Form::formHeader({
		action=>$callback
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
		$var = getPostTemplateVars($reply, $reply->getThread, $forum, $callback, $var);

		$subject = $reply->get("subject");
		$subject = "Re: ".$subject unless ($subject =~ /^Re:/);
	}
	if ($var->{'newpost.isNewThread'}) {
		$var->{'form.begin'} .= WebGUI::Form::hidden({
			name=>'forumId',
			value=>$session{form}{forumId}
			});
		$forum = WebGUI::Forum->new($session{form}{forumId});
		return WebGUI::Privilege::insufficient unless ($forum->canPost);
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

sub www_postSave {
	my ($callback) = @_;
	my $forumId = $session{form}{forumId};
	my $threadId = $session{form}{forumThreadId};
	my $postId = $session{form}{forumPostId};
	my %postData = (
		message=>$session{form}{message},
		subject=>$session{form}{subject},
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
		notifySubscribers($post,$post->getThread,$post->getThread->getForum,$callback);
		return www_viewThread($callback,$post->get("forumPostId"));
	}
	if ($session{form}{forumPostId} > 0) { # edit
		my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
		return WebGUI::Privilege::insufficient unless ($post->getThread->getForum->canPost);
		if ($post->getThread->getForum->get("addEditStampToPosts")) {
			$postData{message} .= "\n\n --- (".WebGUI::International::get(1029)." "
                        .WebGUI::DateTime::epochToHuman(WebGUI::DateTime::time())." ".WebGUI::International::get(1030)
                        ." $session{user}{username}) --- \n";
		}
		$post->set(\%postData);	
		return www_viewThread($callback,$post->get("forumPostId"));
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
		return www_viewForum($callback, $forumId);
	}
}

sub www_previousThread {
	my ($callback) = @_;
	my $thread = WebGUI::Forum::Thread->new($session{form}{forumThreadId});
	my $previousThreadRoot = $thread->getPreviousThread->get("rootPostId");
	if (defined $previousThreadRoot) {
		return www_viewThread($callback,$previousThreadRoot);
	} else {
		return www_viewForum($callback,$thread->get("forumId"));
	}
}

sub www_ratePost {
	my ($callback) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->canPost);
	$post->rate($session{form}{rating}) unless ($post->hasRated);
	return www_viewThread($callback,$session{form}{forumPostId});
}

sub www_threadLock {
	my ($callback) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->isModerator);
	$post->getThread->lock;
	return www_viewThread($callback, $session{form}{forumPostId});
}

sub www_threadUnlock {
	my ($callback) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->isModerator);
	$post->getThread->unlock;
	return www_viewThread($callback, $session{form}{forumPostId});
}

sub www_threadStick {
	my ($callback) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->isModerator);
	$post->getThread->stick;
	return www_viewThread($callback, $session{form}{forumPostId});
}

sub www_threadSubscribe {
	my ($callback) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($session{user}{userId} != 1 && $post->getThread->getForum->canPost);
	$post->getThread->subscribe;
	return www_viewThread($callback, $session{form}{forumPostId});
}

sub www_threadUnstick {
	my ($callback) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->isModerator);
	$post->getThread->unstick;
	return www_viewThread($callback, $session{form}{forumPostId});
}

sub www_threadUnsubscribe {
	my ($callback) = @_;
	my $post = WebGUI::Forum::Post->new($session{form}{forumPostId});
	return WebGUI::Privilege::insufficient() unless ($session{user}{userId} != 1);
	$post->getThread->unsubscribe;
	return www_viewThread($callback, $session{form}{forumPostId});
}

sub www_viewForum {
	my ($callback, $forumId) = @_;
	$forumId = $session{form}{forumId} unless ($forumId);
	my $forum = WebGUI::Forum->new($forumId);
	my $var = getForumTemplateVars($callback, $forum);
	return WebGUI::Template::process(WebGUI::Template::get($forum->get("forumTemplateId"),"Forum"), $var); 
}	

sub www_viewThread {
	my ($callback, $postId) = @_;
	$postId = $session{form}{forumPostId} unless ($postId);
        my $post = WebGUI::Forum::Post->new($postId);
	my $var = getThreadTemplateVars($callback, $post);
	return WebGUI::Template::process(WebGUI::Template::get($post->getThread->getForum->get("threadTemplateId"),"Forum/Thread"), $var); 
}


1;

