package WebGUI::Asset::Thread;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset;
use WebGUI::Asset::Template;
use WebGUI::Asset::Post;
use WebGUI::DateTime;
use WebGUI::Grouping;
use WebGUI::International;
use WebGUI::MessageLog;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;

our @ISA = qw(WebGUI::Asset);


#-------------------------------------------------------------------
sub canSubscribe {
	my $self = shift;
	return ($session{user}{userId} ne "1" && $self->canView);
}

#-------------------------------------------------------------------
sub createSubscriptionGroup {
	my $self = shift;
	my $group = WebGUI::Group->new("new");
	$group->name($self->getId);
	$group->description("The group to store subscriptions for the collaboration system ".$self->getId);
	$group->isEditable(0);
	$group->showInForms(0);
	$group->deleteGroups([3]); # admins don't want to be auto subscribed to this thing
	$self->update({
		subscriptionGroupId=>$group->groupId
		});
}

#-------------------------------------------------------------------

=head2 decrementReplies ( )

Deccrements this reply counter.

=cut

sub decrementReplies {
        my $self = shift;
	$self->update({replies=>$self->get("replies")-1});
	$self->getParent->decrementReplies;
}

#-------------------------------------------------------------------
sub definition {
	my $class = shift;
        my $definition = shift;
        push(@{$definition}, {
                tableName=>'Thread',
                className=>'WebGUI::Asset::Thread',
                properties=>{
			subscriptionGroupId => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			status => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			rating => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			replies => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			views => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			isSticky => {
				fieldType=>"yesNo",
				defaultValue=>0
				},
			isLocked => {
				fieldType=>"yesNo",
				defaultValue=>0
				},
			lastPostId => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			lastPostDate => {
				fieldType=>"hidden",
				defaultValue=>undef
				}
			},
		});
        return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

sub DESTROY {
	my $self = shift;
	$self->{_next}->DESTROY if (exists $self->{_next});
	$self->{_previous}->DESTROY if (exists $self->{_previous});
	$self->SUPER::DESTROY;
}


#-------------------------------------------------------------------

=head2 getFlatThread ( post, thread, forum, caller, currentPost )

Returns an array reference with the template variables from all the posts in a thread in flat mode. In flat mode
messages are ordered by submission date, so threading is not maintained.

=head3 post

A post object.

=head3 thread

A thread object.

=head3 forum

A forum object.

=head3 caller

A hash reference containing information passed from the calling object.

=head3 currentPost

The unique id of the post that was selected by the user in this thread.

=cut

sub getFlatThread {
        my ($post, $thread, $forum, $caller, $currentPost) = @_;
         my (@post_loop, @posts, $OR);
        unless ($post->getThread->getForum->isModerator) {
                $OR = " and not (status='denied' OR status='pending')";
        }
        @posts = WebGUI::SQL->buildArray("SELECT forumPostId FROM forumPost WHERE forumThreadId=".quote($thread->get("forumThreadId"))." $OR ORDER BY dateOfPost");
        foreach my $postId (@posts){
                my $post = WebGUI::Forum::Post->new($postId);
                push (@post_loop, getPostTemplateVars($post,$thread, $forum, $caller, {
                        'post.isCurrent'=>($currentPost eq $post->get("forumPostId"))
                        }));
        }
        return \@post_loop;
}


#-------------------------------------------------------------------
sub getIcon {
	my $self = shift;
	my $small = shift;
	return $session{config}{extrasURL}.'/assets/small/thread.gif' if ($small);
	return $session{config}{extrasURL}.'/assets/thread.gif';
}

#-------------------------------------------------------------------
sub getName {
        return "Thread";
}

#-------------------------------------------------------------------

=head2 getLayoutUrl ( layout [, postId] )

Formats the url to change the layout of a thread.

=head3 layout

A string indicating the type of layout to use. Can be flat, nested, or threaded.

=head3 postId

The asset id of the post to position on. Defaults to the root post of the thread.

=cut

sub getLayoutUrl {
	my $self = shift;
	my $layout = shift;
	my $postId = shift || $self->get("rootPostId");
	return $self->getUrl("layout=".$layout."#".$postId);
}

#-------------------------------------------------------------------

=head2 getLockUrl ( [ postId ] )

Formats the url to lock a thread.

=head3 postId

The asset id of the post to position on. Defaults to the root post of the thread.

=cut

sub getLockUrl {
	my $self = shift;
	my $postId = shift || $self->get("rootPostId");
	$self->getUrl("fucn=lock#">$postId);
}

#-------------------------------------------------------------------

=head2 getNextThread ( )

Returns a thread object for the next (newer) thread in the same forum.

=cut

sub getNextThread {
	my $self = shift;
        unless (exists $self->{_next}) {
		$self->{_next} = WebGUI::Asset::Post->newByPropertyHashRef(
			WebGUI::SQL->quickHashRef("
				select asset.*,Post.* 
				from Thread
				left join asset on asset.parentId=Thread.assetId 
				left join Post on Post.assetId=asset.assetId 
				where Thread.parentId=".quote($self->get("parentId"))." 
					and asset.state='published' 
					and ".$self->getParent->getValue("sortBy").">".quote($self->get($self->getParent->getValue("sortBy")))." 
					and (userId=".quote($self->get("ownerUserId"))." or Post.status='approved') 
				order by ".$self->getParent->getValue("sortBy")." asc 
				",WebGUI::SQL->getSlave)
			);
	};
	return $self->{_next};
}



#-------------------------------------------------------------------

=head2 getPreviousThread ( )

Returns a thread object for the previous (older) thread in the same forum.

=cut

sub getPreviousThread {
	my $self = shift;
        unless (exists $self->{_previous}) {
		$self->{_previous} = WebGUI::Asset::Post->newByPropertyHashRef(
			WebGUI::SQL->quickHashRef("
				select asset.*,Post.* 
				from Thread
				left join asset on asset.parentId=Thread.assetId 
				left join Post on Post.assetId=asset.assetId 
				where Thread.parentId=".quote($self->get("parentId"))." 
					and asset.state='published' 
					and ".$self->getParent->getValue("sortBy")."<".quote($self->get($self->getParent->getValue("sortBy")))." 
					and (userId=".quote($self->get("ownerUserId"))." or Post.status='approved') 
				order by ".$self->getParent->getValue("sortBy")." desc
				",WebGUI::SQL->getSlave)
			);
	};
	return $self->{_previous};
}


#-------------------------------------------------------------------

=head2 getStickUrl ( [ postId ] )

Formats the url to make a thread sticky.

=head3 postId

The asset id of the post to position on. Defaults to the root post of the thread.

=cut

sub getStickUrl {
	my $self = shift;
	my $postId = shift || $self->get("rootPostId");
	return $self->getUrl("func=stick#".$postId);
}

#-------------------------------------------------------------------

=head2 getSubscribeUrl ( [ postId ] )

Formats the url to subscribe to the thread

=head3 postId

The asset id of the post to position on. Defaults to the root post of the thread.

=cut

sub getSubscribeUrl {
	my $self = shift;
	my $postId = shift || $self->get("rootPostId");
	return $self->getUrl("func=subscribe#".$postId);
}


#-------------------------------------------------------------------

=head2 getThreadTemplateVars ( caller, post )

Returns a hash reference compatible with WebGUI's template system containing the template variables for the thread.

=head3 caller

A hash reference containing information passed from the calling object.

=head3 post

A post object.

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
        $var->{'user.isVisitor'} = ($session{user}{userId} eq '1');
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
        my $p = WebGUI::Paginator->new(WebGUI::URL::append($callback,"forumOp=viewThread&amp;forumPostId=".$post->get("forumPostId")."&amp;layout=$layout"),$forum->get("postsPerPage"));
        if($layout eq "flat"){
                $p->setDataByArrayRef(getFlatThread($root, $thread, $forum, $caller, $post->get("forumPostId")));
                $var->{post_loop} = $p->getPageData();
        }else{
                $p->setDataByArrayRef(recurseThread($root, $thread, $forum, 0, $caller, $post->get("forumPostId")));
                $var->{post_loop} = $p->getPageData();
        }
        $var->{firstPage} = $p->getFirstPageLink;
        $var->{lastPage} = $p->getLastPageLink;
        $var->{nextPage} = $p->getNextPageLink;
        $var->{pageList} = $p->getPageLinks;
        $var->{previousPage} = $p->getPreviousPageLink;
        $var->{multiplePages} = ($p->getNumberOfPages > 1);
        $var->{numberOfPages} = $p->getNumberOfPages;
        $var->{pageNumber} = $p->getPageNumber;

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

=head2 getUnlockUrl ( [ postId ] )

Formats the url to unlock the thread

=head3 postId

The asset id of the post to position on. Defaults to the root post of the thread.

=cut

sub getUnlockUrl {
	my $self = shift;
	my $postId = shift || $self->get("rootPostId");
	return $self->getUrl("func=unlock#".$postId);
}


#-------------------------------------------------------------------

=head2 getUnstickUrl ( [ postId ] )

Formats the url to unstick the thread

=head3 postId

The asset id of the post to position on. Defaults to the root post of the thread.

=cut

sub getUnstickUrl {
	my $self = shift;
	my $postId = shift || $self->get("rootPostId");
	return $self->getUrl("func=unstick#".$postId);
}

#-------------------------------------------------------------------

=head2 getUnsubscribeUrl ( [ postId ] )

Formats the url to unsubscribe from the thread

=head3 postId

The asset id of the post to position on. Defaults to the root post of the thread.

=cut

sub getUnsubscribeUrl {
	my $self = shift;
	my $postId = shift || $self->get("rootPostId");
	return $self->getUrl("func=unsubscribe#".$postId);
}


#-------------------------------------------------------------------

=head2 isLocked ( )

Returns a boolean indicating whether this thread is locked from new posts and other edits.

=cut

sub isLocked {
        my ($self) = @_;
        return $self->get("isLocked");
}


#-------------------------------------------------------------------

=head2 incrementReplies ( lastPostDate, lastPostId )

Increments the replies counter for this thread.

=head3 lastPostDate

The date of the reply that caused the replies counter to be incremented.

=head3 lastPostId

The id of the reply that caused the replies counter to be incremented.

=cut

sub incrementReplies {
        my ($self, $dateOfReply, $replyId) = @_;
        $self->update({replies=>$self->get("replies")+1, lastPostId=>$replyId, lastPostDate=>$dateOfReply});
        $self->getParent->incrementReplies($dateOfReply,$replyId);
}

#-------------------------------------------------------------------

=head2 incrementViews ( )

Increments the views counter for this thread.

=cut

sub incrementViews {
        my ($self) = @_;
        $self->update({views=>$self->get("views")+1});
        $self->getParent->incrementViews;
}

#-------------------------------------------------------------------

=head2 isSticky ( )

Returns a boolean indicating whether this thread should be "stuck" a the top of the forum and not be sorted with the rest of the threads.

=cut

sub isSticky {
        my ($self) = @_;
        return $self->get("isSticky");
}


#-------------------------------------------------------------------

=head2 isSubscribed ( )

Returns a boolean indicating whether the user is subscribed to this thread.

=cut

sub isSubscribed {
	my $self = shift;
	return WebGUI::Grouping::isInGroup($self->get("subscriptionGroupId"));
}

#-------------------------------------------------------------------

=head2 lock ( )

Sets this thread to be locked from edits.

=cut

sub lock {
        my ($self) = @_;
        $self->update({isLocked=>1});
}



#-------------------------------------------------------------------

=head2 recalculateRating ( )

Recalculates the average rating of this thread based upon all of the posts in the thread.

=cut

sub recalculateRating {
        my ($self) = @_;
        my ($count) = WebGUI::SQL->quickArray("select count(*) from Post left join asset on Post.assetId=asset.assetId 
		where Post.threadId=".quote($self->getId)." and Post.rating>0");
        $count = $count || 1;
        my ($sum) = WebGUI::SQL->quickArray("select sum(Post.rating) from Post left join asset on Post.assetId=asset.assetId
		where Post.threadId=".quote($self->getId)." and Post.rating>0");
        my $average = round($sum/$count);
        $self->update({rating=>$average});
        $self->getParent->recalculateRating;
}

#-------------------------------------------------------------------

=head2 setLastPost ( lastPostDate, lastPostId )

Sets the pertinent details for the last post. Can also be done directly using the set method.

=head3 lastPostDate

The epoch date of the post.

=head3 lastPostId

The unique id of the post.

=cut

sub setLastPost {
        my ($self, $postDate, $postId) = @_;
        $self->update({
                lastPostId=>$postId,
                lastPostDate=>$postDate
                });
        $self->getParent->setLastPost($postDate, $postId);
}

#-------------------------------------------------------------------

=head2 setStatusApproved ( )

Sets the status of this thread to approved.

=cut

sub setStatusApproved {
        my ($self) = @_;
        $self->update({status=>'approved'});
}

#-------------------------------------------------------------------

=head2 setStatusArchived ( )

Sets the status of this thread to archived.

=cut

sub setStatusArchived {
        my ($self) = @_;
        $self->update({status=>'archived'});
}


#-------------------------------------------------------------------

=head2 setStatusDenied ( )

Sets the status of this thread to denied.

=cut

sub setStatusDenied {
        my ($self) = @_;
        $self->update({status=>'denied'});
}

#-------------------------------------------------------------------

=head2 setStatusPending ( )

Sets the status of this thread to pending.

=cut

sub setStatusPending {
        my ($self) = @_;
        $self->update({status=>'pending'});
}

#-------------------------------------------------------------------

=head2 stick ( )

Makes this thread sticky.

=cut

sub stick {
        my ($self) = @_;
        $self->update({isSticky=>1});
}

#-------------------------------------------------------------------

=head2 subscribe (  )

Subscribes the user to this thread.

=cut

sub subscribe {
	my $self = shift;
	unless ($self->isSubscribed) {
                WebGUI::Grouping::addUsersToGroups([$session{user}{userId}],[$self->get("subscriptionGroupId")]);
        }
}

#-------------------------------------------------------------------

=head2 unlock ( )

Negates the lock method.

=cut

sub unlock {
        my ($self) = @_;
        $self->update({isLocked=>0});
}

#-------------------------------------------------------------------

=head2 unstick ( )

Negates the stick method.

=cut

sub unstick {
        my ($self) = @_;
        $self->update({isSticky=>0});
}

#-------------------------------------------------------------------

=head2 unsubscribe (  )

Negates the subscribe method.

=cut

sub unsubscribe {
	my $self = shift;
	if ($self->isSubscribed) {
                WebGUI::Grouping::deleteUsersFromGroups([$session{user}{userId}],[$self->get("subscriptionGroupId")]);
        }
}


#-------------------------------------------------------------------
sub view {
	my $self = shift;
	my %var;
	#my $callback = WebGUI::URL::gateway($parentsPage->get("urlizedTitle"),"func=viewSubmission&amp;wid=".$self->wid."&amp;sid=".$submission->{USS_submissionId});
#	if ($session{form}{forumOp} ne "" && $session{form}{forumOp} ne "viewForum") {	
#		return WebGUI::Forum::UI::forumOp({
#			callback=>$callback,
#			title=>$submission->{title},
#			forumId=>$submission->{forumId}
#			});
#	}
	$self->update({views=>$self->get("views")+1});
	$var{content} = WebGUI::HTML::filter($self->get("content"),$self->get("filterContent"));
	$var{content} = WebGUI::HTML::format($var{content},"USS");
        $var{"user.label"} = WebGUI::International::get(21,"USS");
	$var{"userProfile.url"} = $self->getUrl('op=viewProfile&uid='.$self->get("ownerUserId"));
	$var{"userId"} = $self->get("ownerUserId");
	$var{"username"} = $self->get("username");
	$var{"dateSubmitted.label"} = WebGUI::International::get(13,"USS");
	$var{"dateSubmitted.human"} = epochToHuman($self->get("dateSubmitted"));
	$var{"dateUpdated.label"} = WebGUI::International::get(78,"USS");
	$var{"dateUpdated.human"} = epochToHuman($self->get("dateUpdated"));
	$var{"status.label"} = WebGUI::International::get(14,"USS");
	$var{"status.status"} = $self->getParent->status($self->get("status"));
	$var{"views.label"} = WebGUI::International::get(514);
        $var{canPost} = $self->canContribute;
        $var{"post.url"} = $self->getUrl("func=edit");
        $var{"post.label"} = WebGUI::International::get(20,"USS");
	my $previous = $self->getPreviousThread;
	$var{"previous.more"} = defined $previous;
	$var{"previous.url"} = $previous->getUrl if ($var{"previous.more"});
	$var{"previous.label"} = WebGUI::International::get(58,"USS");
	my $next = $self->getNextThread;
	$var{"next.more"} = defined $next;
	$var{"next.url"} = $next->getUrl if ($var{"next.more"});
	$var{"next.label"} = WebGUI::International::get(59,"USS");
        $var{canEdit} = $self->canEdit;
        $var{"delete.url"} = $self->getUrl("func=delete");
	$var{"delete.label"} = WebGUI::International::get(37,"USS");
        $var{"edit.url"} = $self->getUrl("func=edit");
	$var{"edit.label"} = WebGUI::International::get(27,"USS");
        $var{canChangeStatus} = $self->canModerate;
        $var{"approve.url"} = $self->getUrl("func=approve&mlog=".$session{form}{mlog});
	$var{"approve.label"} = WebGUI::International::get(572);
        $var{"leave.url"} = $self->getUrl('op=viewMessageLog');
	$var{"leave.label"} = WebGUI::International::get(573);
        $var{"deny.url"} = $self->getUrl("func=deny&mlog=".$session{form}{mlog});
	$var{"deny.label"} = WebGUI::International::get(574);
	$var{"canReply"} = $self->get("allowDiscussion");
#	$var{"reply.url"} = WebGUI::Forum::UI::formatNewThreadURL($callback,$submission->{forumId});
#	$var{"reply.label"} = WebGUI::International::get(47,"USS");
	$var{"search.url"} = WebGUI::Search::toggleURL("",$self->getParent->get("url"));
	$var{"search.label"} = WebGUI::International::get(364);
        $var{"back.url"} = $self->getThread->getParent->getUrl;
	$var{"back.label"} = WebGUI::International::get(28,"USS");
	$var{'userDefined1.value'} = $self->get("userDefined1");
	$var{'userDefined2.value'} = $self->get("userDefined2");
	$var{'userDefined3.value'} = $self->get("userDefined3");
	$var{'userDefined4.value'} = $self->get("userDefined4");
	$var{'userDefined5.value'} = $self->get("userDefined5");
#	if ($submission->{image} ne "") {
#		$file = WebGUI::Attachment->new($submission->{image},$self->wid,$submissionId);
#		$var{"image.url"} = $file->getURL;
#		$var{"image.thumbnail"} = $file->getThumbnail;
#	}
#	if ($submission->{attachment} ne "") {
#		$file = WebGUI::Attachment->new($submission->{attachment},$self->wid,$submissionId);
#		$var{"attachment.box"} = $file->box;
#		$var{"attachment.url"} = $file->getURL;
#		$var{"attachment.icon"} = $file->getIcon;
#		$var{"attachment.name"} = $file->getFilename;
 #       }	
	if ($self->get("allowDiscussion")) {
#		$var{"replies"} = WebGUI::Forum::UI::www_viewForum(
#			{callback=>$callback,title=>$submission->{title},forumId=>$submission->{forumId}},
#			$submission->{forumId});
	}
	return $self->processTemplate(\%var,$self->getParent->get("submissionTemplateId"));
}

#-------------------------------------------------------------------
sub www_edit {
	my $self = shift;
	return WebGUI::Privilege::insufficient() unless ($self->canEdit);
	my %var;
	if ($session{form}{func} eq "add") {
		$self->{_properties}{contentType} = "mixed";
		$var{'isNew'} = 1;
	}
	$var{'link.header.label'} = WebGUI::International::get(90,"USS");
	$var{'question.header.label'} = WebGUI::International::get(84,"USS");
        $var{'submission.header.label'} = WebGUI::International::get(19,"USS");
	$var{'user.isVisitor'} = ($session{user}{userId} eq '1');
        $var{'visitorName.label'} = WebGUI::International::get(438);
	$var{'visitorName.form'} = WebGUI::Form::text({
		name=>"visitorName"
		});
        $var{'form.header'} = WebGUI::Form::formHeader()
		.WebGUI::Form::hidden({
                	name=>"func",
			value=>"editSave"
			});
	if ($self->getId eq "new") {
		$var{'form.header'} .= WebGUI::Form::hidden({
			name=>"assetId",
			value=>"new"
			}).WebGUI::Form::hidden({
			name=>"class",
			value=>$session{form}{class}
			});
	}
        $var{'url.label'} = WebGUI::International::get(91,"USS");
        $var{'newWindow.label'} = WebGUI::International::get(92,"USS");
	for my $x (1..5) {
		$var{'userDefined'.$x.'.form'} = WebGUI::Form::text({
			name=>"userDefined".$x,
			value=>$self->get("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.yesNo'} = WebGUI::Form::yesNo({
			name=>"userDefined".$x,
			value=>$self->get("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.textarea'} = WebGUI::Form::textarea({
			name=>"userDefined".$x,
			value=>$self->get("userDefined".$x)
			});
		$var{'userDefined'.$x.'.form.textarea'} = WebGUI::Form::HTMLArea({
			name=>"userDefined".$x,
			value=>$self->get("userDefined".$x)
			});
	}
	$var{'question.label'} = WebGUI::International::get(85,"USS");
	$var{'title.label'} = WebGUI::International::get(35,"USS");
	$var{'title.form'} = WebGUI::Form::text({
		name=>"title",
		value=>$self->get("title")
		});
	$var{'title.form.textarea'} = WebGUI::Form::textarea({
		name=>"title",
		value=>$self->get("title")
		});
        $var{'body.label'} = WebGUI::International::get(31,"USS");
	$var{'answer.label'} = WebGUI::International::get(86,"USS");
        $var{'description.label'} = WebGUI::International::get(85);
	$var{'contet.form'} = WebGUI::Form::HTMLArea({
		name=>"content",
		value=>$self->get("content")
		});
	$var{'content.form.textarea'} = WebGUI::Form::textarea({
		name=>"content",
		value=>$self->get("content")
		});
#	$var{'image.label'} = WebGUI::International::get(32,"USS");
 #       if ($submission->{image} ne "") {
#		$var{'image.form'} = '<a href="'.WebGUI::URL::page('func=deleteFile&amp;file=image&amp;wid='.$session{form}{wid}
#			.'&amp;sid='.$submission->{USS_submissionId}).'">'.WebGUI::International::get(391).'</a>';
 #       } else {
#		$var{'image.form'} = WebGUI::Form::file({
#			name=>"image"
#			});
 #       }
#	$var{'attachment.label'} = WebGUI::International::get(33,"USS");
 #       if ($submission->{attachment} ne "") {
#		$var{'attachment.form'} = '<a href="'.WebGUI::URL::page('func=deleteFile&amp;file=attachment&amp;wid='
#			.$session{form}{wid}.'&amp;sid='.$submission->{USS_submissionId}).'">'.WebGUI::International::get(391).'</a>';
 #       } else {
#		$var{'attachment.form'} = WebGUI::Form::file({
#			name=>"attachment"
#			});
 #       }
	$var{'contentType.label'} = WebGUI::International::get(1007);
        $var{'contentType.form'} = WebGUI::Form::contentType({
                name=>'contentType',
                value=>$self->get("contentType") || "mixed"
                });
	$var{'startDate.label'} = WebGUI::International::get(497);
	$var{'endDate.label'} = WebGUI::International::get(498);
	$var{'startDate.form'} = WebGUI::Form::dateTime({
		name  => 'startDate',
		value => $self->get("startDate")
		});
	$var{'endDate.form'} = WebGUI::Form::dateTime({
		name  => 'endDate',
		value => $self->get("startDate")
		});
	$var{'form.submit'} = WebGUI::Form::submit();
	$var{'form.footer'} = WebGUI::Form::formFooter();
	return $self->getParent->processStyle($self->processTemplate(\%var,$self->getParent->get("submissionFormTemplateId")));
}

#-------------------------------------------------------------------

=head2 www_lock (  )

The web method to lock a thread.

=cut

sub www_lock {
	my $self = shift;
	$self->lock if $self->getParent->canModerate;
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_stick ( )

The web method to make a thread sticky.

=cut

sub www_stick {
	my $self = shift;
	$self->stick if $self->getParent->canModerate;
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_subscribe ( )

The web method to subscribe to a thread.

=cut

sub www_subscribe {
	my $self = shift;
	$self->subscribe if $self->canSubscribe;
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_unlock ( )

The web method to unlock a thread.

=cut

sub www_unlock {
	my $self = shift;
	$self->unlock if $self->getParent->canModerate;
	return $self->www_view;
}

#-------------------------------------------------------------------

=head2 www_unstick (  )

The web method to make a sticky thread normal again.

=cut

sub www_unstick {
	my $self = shift;
	$self->unstick if $self->getParent->canModerate;
	$self->www_view;
}

#-------------------------------------------------------------------

=head2 www_threadUnsubscribe ( )

The web method to unsubscribe from a thread.

=cut

sub www_unsubscribe {
	my $self = shift;
	$self->unsubscribe if $self->canSubscribe;
	return $self->www_view;
}

#-------------------------------------------------------------------
sub www_view {
	my $self = shift;
	return $self->getParent->processStyle(WebGUI::Privilege::noAccess()) unless $self->canView;
	return $self->getParent->processStyle($self->view);
}

#-------------------------------------------------------------------

=head2 www_viewThread ( caller [ , postId ] )

The web method to display a thread.

=head3 caller

A hash reference containing information passed from the calling object.

=head3 postId

Specify a postId and call this method directly, rather than over the web.

=cut

sub www_viewThread {
        my ($caller, $postId) = @_;
        WebGUI::Session::setScratch("forumThreadLayout",$session{form}{layout});
        $postId = $session{form}{forumPostId} unless ($postId);
        my $post = WebGUI::Forum::Post->new($postId);
        return WebGUI::Privilege::insufficient() unless ($post->getThread->getForum->canView);
        my $var = getThreadTemplateVars($caller, $post);
        if ($post->get("forumPostId") eq $post->getThread->get("rootPostId") && !$post->canView) {
                return www_viewForum($caller, $post->getThread->getForum->get("forumId"));
        } else {
                return WebGUI::Template::process($post->getThread->getForum->get("threadTemplateId"),"Forum/Thread", $var);
        }
}


1;

