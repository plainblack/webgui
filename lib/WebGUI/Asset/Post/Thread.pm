package WebGUI::Asset::Post::Thread;

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

our @ISA = qw(WebGUI::Asset::Post);


#-------------------------------------------------------------------
sub canReply {
	my $self = shift;
	return !$self->isLocked && $self->getParent->get("allowReplies") && $self->getParent->canPost;
}

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
                className=>'WebGUI::Asset::Post::Thread',
                properties=>{
			subscriptionGroupId => {
				fieldType=>"hidden",
				defaultValue=>undef
				},
			replies => {
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
				select * 
				from Thread
				left join asset on asset.assetId=Thread.assetId 
				left join Post on Post.assetId=asset.assetId 
				where asset.parentId=".quote($self->get("parentId"))." 
					and asset.state='published' 
					and asset.className='WebGUI::Asset::Post::Thread'
					and ".$self->getParent->getValue("sortBy").">".quote($self->get($self->getParent->getValue("sortBy")))." 
					and (
						Post.status in ('approved','archived')
						or (asset.ownerUserId=".quote($session{user}{userId})." and asset.ownerUserId<>'1')
						)
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
			WebGUI::SQL->quickHashRef(" select * 
				from Thread
				left join asset on asset.assetId=Thread.assetId 
				left join Post on Post.assetId=asset.assetId 
				where asset.parentId=".quote($self->get("parentId"))." 
					and asset.state='published' 
					and asset.className='WebGUI::Asset::Post::Thread'
					and ".$self->getParent->getValue("sortBy")."<".quote($self->get($self->getParent->getValue("sortBy")))." 
					and (
						Post.status in ('approved','archived')
						or (asset.ownerUserId=".quote($session{user}{userId})." and asset.ownerUserId<>'1')
						)
				order by ".$self->getParent->getValue("sortBy")." desc ",WebGUI::SQL->getSlave)
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
sub getThread {
	return shift;
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

=head2 isMarkedRead ( )

Returns a boolean indicating whether this thread is marked read for the user.

=cut

sub isMarkedRead {
        my $self = shift;
	return 1 if $self->isPoster;
        my ($isRead) = WebGUI::SQL->quickArray("select count(*) from Post_read where userId=".quote($session{user}{userId})." and threadId=".quote($self->getId));
        return $isRead;
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

=head2 rate ( rating )

Stores a rating against this post.

=head3 rating

An integer between 1 and 5 (5 being best) to rate this post with.

=cut

sub rate {
        my $self = shift;
        my $rating = shift;
        unless ($self->hasRated) {
                WebGUI::SQL->write("insert into Post_rating (assetId,userId,ipAddress,dateOfRating,rating) values ("
                        .quote($self->getId).", ".quote($session{user}{userId}).", ".quote($session{env}{REMOTE_ADDR}).",
                        ".WebGUI::DateTime::time().", $rating)");
        	my ($count) = WebGUI::SQL->quickArray("select count(*) from Post left join asset on Post.assetId=asset.assetId 
			where Post.threadId=".quote($self->getId)." and Post.rating>0");
        	$count = $count || 1;
        	my ($sum) = WebGUI::SQL->quickArray("select sum(Post.rating) from Post left join asset on Post.assetId=asset.assetId
			where Post.threadId=".quote($self->getId)." and Post.rating>0");
        	my $average = round($sum/$count);
        	$self->update({rating=>$average});
        	$self->getParent->recalculateRating;
        }
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
        $self->markRead;
        $self->incrementViews;
        WebGUI::Session::setScratch("discussionLayout",$session{form}{layout});
        my $var = $self->getTemplateVars;
	$self->getParent->appendTemplateLabels($var);

        $var->{'user.isVisitor'} = ($session{user}{userId} eq '1');
        $var->{'user.isModerator'} = $self->getParent->canModerate;
        $var->{'user.canPost'} = $self->getParent->canPost;
        $var->{'user.canReply'} = $self->canReply;

        $var->{'layout.nested.url'} = $self->getLayoutUrl("nested");
        $var->{'layout.flat.url'} = $self->getLayoutUrl("flat");
        $var->{'layout.threaded.url'} = $self->getLayoutUrl("threaded");
        my $layout = $session{scratch}{discussionLayout} || $session{user}{discussionLayout};
        $var->{'layout.isFlat'} = ($layout eq "flat");
        $var->{'layout.isNested'} = ($layout eq "nested");
        $var->{'layout.isThreaded'} = ($layout eq "threaded" || !($var->{'thread.layout.isNested'} || $var->{'thread.layout.isFlat'}));

        $var->{'user.isSubscribed'} = $self->isSubscribed;
        $var->{'subscribe.url'} = $self->getSubscribeUrl;
        $var->{'unsubscribe.url'} = $self->getUnsubscribeUrl;

        $var->{'isSticky'} = $self->isSticky;
        $var->{'stick.url'} = $self->getStickUrl;
        $var->{'unstick.url'} = $self->getUnstickUrl;

        $var->{'isLocked'} = $self->isLocked;
        $var->{'lock.url'} = $self->getLockUrl;
        $var->{'unlock.url'} = $self->getUnlockUrl;

        my $p = WebGUI::Paginator->new($self->getUrl,$self->getParent->get("postsPerPage"));
	my $sql = "select * from asset 
		left join Post on Post.assetId=asset.assetId
		left join Thread on Thread.assetId=asset.assetId
		where asset.lineage like ".quote($self->get("lineage").'%')."
			and asset.assetId<>".quote($self->getId)."
			and (
				Post.status in ('approved','archived')";
	$sql .= "		or Post.status='pending'" if ($self->getParent->canModerate);
	$sql .= "		or (asset.ownerUserId=".quote($session{user}{userId})." and asset.ownerUserId<>'1')
				)
		order by ";
	if ($layout eq "flat") {
		$sql .= "Post.dateSubmitted";
	} else {
		$sql .= "asset.lineage";
	}
	$p->setDataByQuery($sql);
	foreach my $dataSet (@{$p->getPageData()}) {
		my $reply = WebGUI::Asset::Post->newByPropertyHashRef($dataSet);
		$reply->{_thread} = $self; # caching thread for better performance
		my $replyVars = $reply->getTemplateVars;
		$replyVars->{isCurrent} = $session{asset}->getId eq $reply->getId;
		$replyVars->{depth} = $reply->getLineageLength - $self->getLineageLength - 1;
        	my @depth_loop;
        	for (my $i=0; $i<$replyVars->{depth}; $i++) {
                	push(@{$replyVars->{indent_loop}},{depth=>$i});
        	}
		push (@{$var->{post_loop}}, $replyVars);
	}		
	$p->appendTemplateVars($var);
        $var->{'add.url'} = $self->getParent->getNewThreadUrl;
 
	my $previous = $self->getPreviousThread;
	$var->{"previous.url"} = $previous->getUrl if (defined $previous);
	my $next = $self->getNextThread;
	$var->{"next.url"} = $next->getUrl if (defined $next);

	$var->{"search.url"} = $self->getParent->getSearchUrl;
        $var->{"collaboration.url"} = $self->getThread->getParent->getUrl;
	return $self->processTemplate($var,$self->getParent->get("threadTemplateId"));
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


1;

