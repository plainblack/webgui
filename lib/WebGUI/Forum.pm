package WebGUI::Forum;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2004 Plain Black LLC.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut
                                                                                                                                                             
use strict;
use WebGUI::Forum::Thread;
use WebGUI::Grouping;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;


=head1 NAME

Package WebGUI::Forum

=head1 DESCRIPTION

Data management class for forums.

=head1 SYNOPSIS

 use WebGUI::Forum;
 $forum = WebGUI::Forum->create(\%forumParams);
 $forum = WebGUI::Forum->new($forumId);

 $boolean = $forum->canPost;
 $boolean = $forum->canView;
 $scalar = $forum->get($param);
 $obj = $forum->getThread($threadId);
 $boolean = $forum->isModerator;
 $boolean = $forum->isSubscribed;

 $forum->decrementReplies;
 $forum->decrementThreads;
 $forum->incrementReplies($postDate, $postId);
 $forum->incrementThreads($postDate, $postId);
 $forum->incrementViews;
 $forum->purge;
 $forum->recalculateRating;
 $forum->set(\%data);
 $forum->setLastPost($epoch, $postId);
 $forum->subscribe;
 $forum->unsubscribe;

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 canPost ( [ userId ] )

Returns a boolean whether the user has the privileges required to post.

=over

=item userId

Defaults to $session{user}{userId}. Specify a user ID to check privileges for.

=back

=cut

sub canPost {
        my ($self, $userId) = @_;
        $userId = $session{user}{userId} unless ($userId);
        return (WebGUI::Grouping::isInGroup($self->get("groupToPost"),$userId) || $self->isModerator);
}

#-------------------------------------------------------------------

=head2 canView ( [ userId ] )

Returns a boolean whether the user has the privileges required to view the forum.

=over

=item userId

Defaults to $session{user}{userId}. Specify a user ID to check privileges for.

=back

=cut

sub canView {
        my ($self, $userId) = @_;
        $userId = $session{user}{userId} unless ($userId);
        return (WebGUI::Grouping::isInGroup($self->get("groupToView"),$userId) || $self->canPost);
}

#-------------------------------------------------------------------
                                                                                                                                                             
=head2 create ( forumParams )

Creates a new forum. Returns a forum object.

=over

=item forumParams

A hash reference containing a list of the parameters to default the forum to. The valid parameters are: 

addEditStampToPosts - boolean
filterPosts - A valid HTML::filter string.
karmaPerPost - integer
groupToPost - Group ID
groupToModerate - Group ID
editTimeout - interval
moderatePosts - boolean
attachmentsPerPost - integer
allowRichEdit - boolean
allowReplacements - boolean
forumTemplateId - Template ID
threadTemplateId - Template ID
postTemplateId - Template ID
postFormTemplateId - Template ID
searchTemplateId - Template ID
notificationTemplateId - Template ID
archiveAfter - interval
postsPerPage - integer
masterForumId - Forum ID
 
=back
 
=cut
 
sub create {
	my ($self, $data) = @_;
	$data->{forumId} = "new";
	my $forumId = WebGUI::SQL->setRow("forum","forumId",$data);
	return WebGUI::Forum->new($forumId);
}

#-------------------------------------------------------------------

=head2 decrementReplies ( )

Deccrements this forum's reply counter.

=cut

sub decrementReplies {
        my ($self) = @_;
        WebGUI::SQL->write("update forum set replies=replies-1 where forumId=".quote($self->get("forumId")));
}

#-------------------------------------------------------------------

=head2 decrementThreads ( )

Decrements this forum's thread counter.

=cut

sub decrementThreads {
        my ($self) = @_;
        WebGUI::SQL->write("update forum set threads=threads-1 where forumId=".quote($self->get("forumId")));
}

#-------------------------------------------------------------------
                                                                                                                                                             
=head2 get ( [ param ] )

Returns a hash reference containing all of the properties of the forum.

=over

=item param

If specified then this method will return the value of this one parameter as a scalar. Param is the name of the parameter to return. See the forum table for details.

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

=head2 getThread ( threadId )

Returns a thread object.

=over

=item threadId

The unique identifier of a thread in this forum.

=back

=cut

sub getThread {
	my ($self, $threadId) = @_;
	unless (exists $self->{_thread}{$threadId}) {
		$self->{_thread}{$threadId} = WebGUI::Forum::Thread->new($threadId);
	}
	return $self->{_thread}{$threadId};
}

#-------------------------------------------------------------------

=head2 isModerator ( [ userId ] )

Returns a boolean indicating whether the user is a moderator.

=over

=item userId

Defaults to $session{user}{userId}. A user id to test for moderator privileges.

=back

=cut

sub isModerator {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	return WebGUI::Grouping::isInGroup($self->get("groupToModerate"), $userId);
}

#-------------------------------------------------------------------

=head2 incrementReplies ( lastPostDate, lastPostId )

Increments this forum's reply counter.

=over

=item lastPostDate

The date of the post being added.

=item lastPostId

The unique identifier of the post being added.

=back

=cut

sub incrementReplies {
        my ($self, $lastPostDate, $lastPostId) = @_;
        WebGUI::SQL->write("update forum set replies=replies+1, lastPostId=$lastPostId, lastPostDate=$lastPostDate where forumId=".quote($self->get("forumId")));
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 incrementThreads ( lastPostDate, lastPostId )

Increments the thread counter for this forum.

=over

=item lastPostDate

The date of the post that was just added.

=item lastPostId

The unique identifier of the post that was just added.

=back

=cut

sub incrementThreads {
        my ($self, $lastPostDate, $lastPostId) = @_;
        WebGUI::SQL->write("update forum set threads=threads+1, lastPostId=$lastPostId, lastPostDate=$lastPostDate where forumId=".quote($self->get("forumId")));
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 incrementViews ( )

Increments the views counter on this forum.

=cut

sub incrementViews {
        my ($self) = @_;
        WebGUI::SQL->write("update forum set views=views+1 where forumId=".quote($self->get("forumId")));
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 isSubscribed ( [ userId ] )

Returns a boolean indicating whether the user is subscribed to the forum.

=over

=item userId

The user to check for the subscription. Defaults to $session{user}{userId}.

=back

=cut

sub isSubscribed {
	my ($self, $userId) = @_;
        $userId = $session{user}{userId} unless ($userId);
        my ($isSubscribed) = WebGUI::SQL->quickArray("select count(*) from forumSubscription where forumId=".quote($self->get("forumId"))." and userId=".quote($userId));
        return $isSubscribed;
}

#-------------------------------------------------------------------

=head2 new ( forumId )

Constructor.

=over

=item forumId

The unique identifier of the forum to retrieve the object for.

=back

=cut

sub new {
	my ($class, $forumId) = @_;
	my $properties = WebGUI::SQL->getRow("forum","forumId",$forumId);
	if ($properties->{masterForumId}) {
		my $master = WebGUI::SQL->getRow("forum","forumId",$properties->{masterForumId});
		$properties->{forumTemplateId} = $master->{forumTemplateId};
		$properties->{threadTemplateId} = $master->{threadTemplateId};
		$properties->{postTemplateId} = $master->{postTemplateId};
		$properties->{searchTemplateId} = $master->{searchTemplateId};
		$properties->{notificationTemplateId} = $master->{notificationTemplateId};
		$properties->{postFormTemplateId} = $master->{postFormTemplateId};
		$properties->{archiveAfter} = $master->{archiveAfter};
		$properties->{allowRichEdit} = $master->{allowRichEdit};
		$properties->{allowReplacements} = $master->{allowReplacements};
		$properties->{filterPosts} = $master->{filterPosts};
		$properties->{karmaPerPost} = $master->{karmaPerPost};
		$properties->{groupToPost} = $master->{groupToPost};
		$properties->{groupToModerate} = $master->{groupToModerate};
		$properties->{moderatePosts} = $master->{moderatePosts};
		$properties->{attachmentsPerPost} = $master->{attachmentsPerPost};
		$properties->{addEditStampToPosts} = $master->{addEditStampsToPost};
		$properties->{postsPerPage} = $master->{postsPerPage};
	}
	bless {_properties=>$properties}, $class;
}

#-------------------------------------------------------------------

=head2 purge ( ) 

Destroys this forum and everything it contains.

=cut

sub purge {
	my ($self) = @_;
	return unless ($self->get("forumId"));
	my $a = WebGUI::SQL->read("select * from forumThread where forumId=".quote($self->get("forumId")));
	while (my ($threadId) = $a->array) {
		my $b = WebGUI::SQL->read("select * from forumPost where forumThreadId=".quote($threadId));
		while (my ($postId) = $b->array) {
			WebGUI::SQL->write("delete from forumPostAttachment where forumPostId=".quote($postId));
			WebGUI::SQL->write("delete from forumPostRating where forumPostId=".quote($postId));
		}
		$b->finish;
		WebGUI::SQL->write("delete from forumThreadSubscription where forumThreadId=".quote($threadId));
		WebGUI::SQL->write("delete from forumRead where forumThreadId=".quote($threadId));
		WebGUI::SQL->write("delete from forumPost where forumThreadId=".quote($threadId));
	}
	$a->finish;
	WebGUI::SQL->write("delete from forumSubscription where forumId=".quote($self->get("forumId")));
	WebGUI::SQL->write("delete from forumThread where forumId=".quote($self->get("forumId")));
	WebGUI::SQL->write("delete from forum where forumId=".quote($self->get("forumId")));
}

#-------------------------------------------------------------------

=head2 recalculateRating ( )

Calculates the rating of this forum from its threads and stores the new value in the forum properties.

=cut

sub recalculateRating {
        my ($self) = @_;
        my ($count) = WebGUI::SQL->quickArray("select count(*) from forumThread where forumId=".quote($self->get("forumId"))." and rating>0");
        $count = $count || 1;
        my ($sum) = WebGUI::SQL->quickArray("select sum(rating) from forumThread where forumId=".quote($self->get("forumId"))." and rating>0");
        my $average = round($sum/$count);
        $self->set({rating=>$average});
}

#-------------------------------------------------------------------

=head2 set ( data )

Sets the forum properties both in the object and to the database.

=over

=item data

A hash reference containing the properties to set. See the forum table for details.

=back

=cut

sub set {
	my ($self, $data) = @_;
	$data->{forumId} = $self->get("forumId") unless ($data->{forumId});
	WebGUI::SQL->setRow("forum","forumId",$data);
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
}

#-------------------------------------------------------------------

=head2 subscribe ( [ userId ] )

Subscribes a user to this forum.

=over

=item userId

The unique identifier of the user to subscribe. Defaults to the current user.

=back

=cut

sub subscribe {
        my ($self, $userId) = @_;
        $userId = $session{user}{userId} unless ($userId);
        unless ($self->isSubscribed($userId)) {
                WebGUI::SQL->write("insert into forumSubscription (forumId, userId) values (".quote($self->get("forumId")).",".quote($userId).")");
        }
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 unsubscribe ( [ userId ] )

Unsubscribes a user from this forum.

=over

=item userId

The unique identifier of the user to unsubscribe. Defaults to the current user.

=back

=cut

sub unsubscribe {
        my ($self, $userId) = @_;
        $userId = $session{user}{userId} unless ($userId);
        if ($self->isSubscribed($userId)) {
                WebGUI::SQL->write("delete from forumSubscription where forumId=".quote($self->get("forumId"))." and userId=".quote($userId));
        }
}



1;

