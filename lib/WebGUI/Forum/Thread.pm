package WebGUI::Forum::Thread;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::DateTime;
use WebGUI::Forum;
use WebGUI::Forum::Post;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Forum::Thread

=head1 DESCRIPTION
                                                                                                                                                             
Data management class for forum threads.
                                                                                                                                                             
=head1 SYNOPSIS
                                                                                                                                                             
 use WebGUI::Forum;
 $thread = WebGUI::Forum::Thread->create(\%params);
 $thread = WebGUI::Forum::Thread->new($threadId);

 $scalar = $thread->get($param);
 $obj = $thread->getForum;
 $obj = $thread->getNextThread;
 $obj = $thread->getPost($postId);
 $obj = $thread->getPreviousThread;
 $boolean = $thread->isLocked;
 $boolean = $thread->isSticky;
 $boolean = $thread->isSubscribed;

 $thread->decrementReplies;
 $thread->incrementReplies($postDate, $postId);
 $thread->incrementViews;
 $thread->lock;
 $thread->recalculateRating;
 $thread->set(\%data);
 $thread->setLastPost($postDate,$postId);
 $thread->setStatusApproved;
 $thread->setStatusArchived;
 $thread->setStatusDeleted;
 $thread->setStatusDenied;
 $thread->setStatusPending;
 $thread->stick;
 $thread->subscribe;
 $thread->unlock;
 $thread->unstick;
 $thread->unsubscribe;
                                                                                                                                                             
=head1 METHODS
                                                                                                                                                             
These methods are available from this class:
                                                                                                                                                             
=cut

#-------------------------------------------------------------------

=head2 create ( data, postData )

Creates a new thread, including the root post in that thread.

=over

=item data

The properties of this thread. See the forumThread table for details.

=item postData

The properties of the root post in this thread. See the forumPost table and the WebGUI::Forum::Post->create method for details.

=back

=cut

sub create {
	my ($self, $data, $postData) = @_;
	$data->{forumThreadId} = "new";
	$postData->{forumThreadId} = WebGUI::SQL->setRow("forumThread","forumThreadId", $data);
	$self = WebGUI::Forum::Thread->new($postData->{forumThreadId});
	$postData->{parentId} = 0;
	my $post = WebGUI::Forum::Post->create($postData);
	$self->set({
		rootPostId=>$post->get("forumPostId"),
		lastPostId=>$post->get("forumPostId"),
		lastPostDate=>$post->get("dateOfPost")
		});
	$self->{_post}{$post->get("forumPostId")} = $post;
	$self->getForum->incrementThreads($post->get("dateOfPost"),$post->get("forumPostId"));
	return $self;
}

#-------------------------------------------------------------------

=head2 decrementReplies ( )

Decrements the replies counter for this thread.

=cut

sub decrementReplies {
        my ($self) = @_;
        WebGUI::SQL->write("update forumThread set replies=replies-1 where forumThreadId=".quote($self->get("forumThreadId")));
	$self->getForum->decrementReplies;
}

#-------------------------------------------------------------------

=head2 get ( [ param ] )

Returns a hash reference containing all the properties of this thread.

=over

=item param

The name of a specific property. If specified only the value of that property will be return as a scalar.

=back

=cut

sub get {
	my ($self, $key) = @_;
	if ($key eq "") {
		return $self->{_properties};
	}
	return $self->{_properties}->{$key};
}

#-------------------------------------------------------------------

=head2 getForum ( )

Returns a forum object for the forum that is related to this thread.

=cut

sub getForum {
	my ($self) = @_;
	unless (exists $self->{_forum}) {
		$self->{_forum} = WebGUI::Forum->new($self->get("forumId"));
	}
	return $self->{_forum};
}

#-------------------------------------------------------------------

=head2 getNextThread ( )

Returns a thread object for the next (newer) thread in the same forum.

=cut

sub getNextThread {
	my ($self) = @_;
	unless (exists $self->{_next}) {
		my ($nextId) = WebGUI::SQL->quickArray("select lastPostId from forumThread where forumId=".quote($self->get("forumId"))." 
			and lastPostDate>".quote($self->get("lastPostDate")." order by lastPostDate asc"),WebGUI::SQL->getSlave);
		$self->{_next} = WebGUI::Forum::Thread->new($nextId);
	}
	return $self->{_next};
}

#-------------------------------------------------------------------

=head2 getPost ( postId ) 

Returns a post object.

=over

=item postId

The unique id of the post object you wish to retrieve.

=back

=cut

sub getPost {
	my ($self, $postId) = @_;
	unless (exists $self->{_post}{$postId}) {
		$self->{_post}{$postId} = WebGUI::Forum::Post->new($postId);
	}
	return $self->{_post}{$postId};
}

#-------------------------------------------------------------------

=head2 getPreviousThread ( )

Returns a thread object for the previous (older) thread in the same forum.

=cut

sub getPreviousThread {
	my ($self) = @_;
	unless (exists $self->{_previous}) {
		my ($nextId) = WebGUI::SQL->quickArray("select lastPostId from forumThread where forumId=".quote($self->get("forumId"))." 
			and lastPostDate<".quote($self->get("lastPostDate")." order by lastPostDate desc"),WebGUI::SQL->getSlave);
		$self->{_previous} = WebGUI::Forum::Thread->new($nextId);
	}
	return $self->{_previous};
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

=over

=item lastPostDate

The date of the reply that caused the replies counter to be incremented.

=item lastPostId

The id of the reply that caused the replies counter to be incremented.

=back

=cut

sub incrementReplies {
        my ($self, $dateOfReply, $replyId) = @_;
        WebGUI::SQL->write("update forumThread set replies=replies+1, lastPostId=".quote($replyId).", lastPostDate=$dateOfReply 
		where forumThreadId=".quote($self->get("forumThreadId")));
	$self->getForum->incrementReplies($dateOfReply,$replyId);
}

#-------------------------------------------------------------------

=head2 incrementViews ( )

Increments the views counter for this thread.

=cut

sub incrementViews {
        my ($self) = @_;
        WebGUI::SQL->write("update forumThread set views=views+1 where forumThreadId=".quote($self->get("forumThreadId")));
	$self->getForum->incrementViews;
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

=head2 isSubscribed ( [ userId ] )

Returns a boolean indicating whether the user is subscribed to this thread.

=over

=item userId

The unique id of the user to check. Defaults to the current user.

=back

=cut

sub isSubscribed {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	my ($isSubscribed) = WebGUI::SQL->quickArray("select count(*) from forumThreadSubscription where forumThreadId=".quote($self->get("forumThreadId"))
		." and userId=".quote($userId));
	return $isSubscribed;
}

#-------------------------------------------------------------------

=head2 lock ( )

Sets this thread to be locked from edits.

=cut

sub lock {
	my ($self) = @_;
	$self->set({isLocked=>1});
}

#-------------------------------------------------------------------

=head2 new ( threadId ) 

Constructor.

=over

=item threadId

The unique id of the thread object you wish to retrieve.

=back

=cut

sub new {
	my ($class, $forumThreadId) = @_;
	my $properties = WebGUI::SQL->getRow("forumThread","forumThreadId",$forumThreadId);
	if (defined $properties) {
		bless {_properties=>$properties}, $class;
	} else {
		return undef;
	}
}

#-------------------------------------------------------------------

=head2 recalculateRating ( )

Recalculates the average rating of this thread based upon all of the posts in the thread.

=cut

sub recalculateRating {
	my ($self) = @_;
        my ($count) = WebGUI::SQL->quickArray("select count(*) from forumPost where forumThreadId=".quote($self->get("forumThreadId"))." and rating>0");
        $count = $count || 1;
        my ($sum) = WebGUI::SQL->quickArray("select sum(rating) from forumPost where forumThreadId=".quote($self->get("forumThreadId"))." and rating>0");
        my $average = round($sum/$count);
        $self->set({rating=>$average});
	$self->getForum->recalculateRating;
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 set ( data ) 

Sets properties for this thread both to the object and to the database.

=over

=item data

A hash reference containing the properties to set. See the forumThread table for details.

=back

=cut

sub set {
	my ($self, $data) = @_;
	$data->{forumThreadId} = $self->get("forumThreadId") unless ($data->{forumThreadId});
	WebGUI::SQL->setRow("forumThread","forumThreadId",$data);
	foreach my $key (keys %{$data}) {
                $self->{_properties}{$key} = $data->{$key};
        }
}

#-------------------------------------------------------------------

=head2 setLastPost ( lastPostDate, lastPostId ) 

Sets the pertinent details for the last post. Can also be done directly using the set method.

=over

=item lastPostDate

The epoch date of the post.

=item lastPostId

The unique id of the post.

=back

=cut

sub setLastPost {
	my ($self, $postDate, $postId) = @_;
	$self->set({
		lastPostId=>$postId,
		lastPostDate=>$postDate
		});
	$self->getForum->setLastPost($postDate, $postId);
}

#-------------------------------------------------------------------

=head2 setStatusApproved ( )

Sets the status of this thread to approved.

=cut

sub setStatusApproved {
        my ($self) = @_;
        $self->set({status=>'approved'});
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 setStatusArchived ( )

Sets the status of this thread to archived.

=cut

sub setStatusArchived {
        my ($self) = @_;
        $self->set({status=>'archived'});
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 setStatusDeleted ( )

Sets the status of this thread to deleted.

=cut

sub setStatusDeleted {
        my ($self) = @_;
        $self->set({status=>'deleted'});
	$self->getForum->decrementThreads;
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 setStatusDenied ( )

Sets the status of this thread to denied.

=cut

sub setStatusDenied {
        my ($self) = @_;
        $self->set({status=>'denied'});
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 setStatusPending ( )

Sets the status of this thread to pending.

=cut

sub setStatusPending {
        my ($self) = @_;
        $self->set({status=>'pending'});
}

#-------------------------------------------------------------------

=head2 stick ( )

Makes this thread sticky.

=cut

sub stick {
	my ($self) = @_;
	$self->set({isSticky=>1});
}

#-------------------------------------------------------------------

=head2 subscribe ( [ userId ] )

Subscribes the user to this thread.

=over

=item userId

The unique id of the user. Defaults to the current user.

=back

=cut

sub subscribe {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	unless ($self->isSubscribed($userId)) {
		WebGUI::SQL->write("insert into forumThreadSubscription (forumThreadId, userId) values (".quote($self->get("forumThreadId")).",".quote($userId).")");
	}
}

#-------------------------------------------------------------------

=head2 unlock ( )

Negates the lock method.

=cut

sub unlock {
	my ($self) = @_;
	$self->set({isLocked=>0});
}

#-------------------------------------------------------------------

=head2 unstick ( )

Negates the stick method.

=cut

sub unstick {
	my ($self) = @_;
	$self->set({isSticky=>0});
}

#-------------------------------------------------------------------

=head2 unsubscribe ( [ userId ] ) 

Negates the subscribe method.

=over

=item userId

The unique id of the user to unsubscribe. Defaults to the current user.

=back

=cut

sub unsubscribe {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	if ($self->isSubscribed($userId)) {
		WebGUI::SQL->write("delete from forumThreadSubscription where forumThreadId=".quote($self->get("forumThreadId"))." and userId=".quote($userId));
	}
}


1;

