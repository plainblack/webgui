package WebGUI::Forum::Post;

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
use WebGUI::Forum::Thread;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Forum::Post

=head1 DESCRIPTION
                                                                                                                                                             
Data management class for forum posts.
                                                                                                                                                             
=head1 SYNOPSIS
                                                                                                                                                             
 use WebGUI::Forum::Post;
 $post = WebGUI::Forum::Post->create(\%params);
 $post = WebGUI::Forum::Post->new($postId);

 $boolean = $post->canEdit;
 $boolean = $post->canView;
 $scalar = $post->get("forumPostId");
 $arrayRef = $post->getReplies;
 $obj = $post->getThread;
 $boolean = $post->hasRated;
 $boolean = $post->isMarkedRead;
 $boolean = $post->isReply;

 $post->incrementViews;
 $post->markRead;
 $post->rate($rating);
 $post->recalculateRating;
 $post->set(\%data);
 $post->setStatusApproved;
 $post->setStatusArchived;
 $post->setStatusDeleted;
 $post->setStatusDenied;
 $post->setStatusPending;
 $post->unmarkRead;
                                                                                                                                                             
=head1 METHODS
                                                                                                                                                             
These methods are available from this class:
                                                                                                                                                             
=cut

#-------------------------------------------------------------------

=head2 canEdit ( [ userId ] )

Returns a boolean indicating whether the user can edit the current post.

=head3 userId

The unique identifier to check privileges against. Defaults to the current user.

=cut

sub canEdit {
        my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
        return ($self->getThread->getForum->isModerator || ($self->get("userId") eq $userId && $userId != 1 
		&& $self->getThread->getForum->get("editTimeout") > (WebGUI::DateTime::time() - $self->get("dateOfPost"))));
}

#-------------------------------------------------------------------

=head2 canView ( [ userId ] )

Returns a boolean indicating whether the user can view the current post.

=head3 userId

The unique identifier to check privileges against. Defaults to the current user.

=cut

sub canView {
        my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	if ($self->get("status") eq "approved" || $self->get("status") eq "archived") {
		return 1;
	} elsif ($self->get("status") eq "deleted") {
		return 0;
	} elsif ($self->get("status") eq "denied" && $userId eq $self->get("userId")) {
		return 1;
	} elsif ($self->getThread->getForum->isModerator) {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------

=head2 create ( [ data ] )

Creates a new post.

=head3 data

A hash reference containing the data to use to create the post. See the forumPost table for details.

=cut

sub create {
	my ($self, $data) = @_;
	$data->{dateOfPost} = WebGUI::DateTime::time();
	$data->{forumPostId} = "new";
	my $forumPostId = WebGUI::SQL->setRow("forumPost","forumPostId", $data);
	$self = WebGUI::Forum::Post->new($forumPostId);
	return $self;
}

#-------------------------------------------------------------------

=head2 get ( [ param ] )

Returns a hash reference containing all of the parameters of this post.

=head3 param

The name of a parameter to get. If specified then the method will return only the value for this parameter as a scalar.

=cut

sub get {
	my ($self, $key) = @_;
	if ($key eq "") {
		return $self->{_properties};
	}
	return $self->{_properties}->{$key};
}

#-------------------------------------------------------------------

=head2 getReplies ( )

Returns an array reference containing a list of post objects that are direct decendants to this post.

=cut

sub getReplies {
	my ($self) = @_;
	my @replies = ();
 	my $query = "select forumPostId from forumPost where parentId=".quote($self->get("forumPostId"))." and ";
        if ($self->getThread->getForum->isModerator) {
                $query .= "(status='approved' or status='pending' or status='denied'";
        } else {
                $query .= "(status='approved'";
        }
        $query .= " or userId=".quote($session{user}{userId}).")  order by dateOfPost";
	my $sth = WebGUI::SQL->read($query,WebGUI::SQL->getSlave);
	while (my @data = $sth->array) {
		push(@replies,WebGUI::Forum::Post->new($data[0]));
	}
	$sth->finish;
	return \@replies;
}

#-------------------------------------------------------------------

=head2 getThread ( )

Returns the thread object that is related to this post.

=cut

sub getThread {
	my ($self) = @_;
	unless (exists $self->{_thread}) {
		$self->{_thread} = WebGUI::Forum::Thread->new($self->get("forumThreadId"));
	}
	return $self->{_thread};
}

#-------------------------------------------------------------------

=head2 hasRated ( [ userId, ipAddress ] ) 

Returns a boolean indicating whether this user has already rated this post.

=head3 userId

A unique identifier for a user to check. Defaults to the current user.

=head3 ipAddress

If the user ID equals 1 (visitor) then an IP address is used to distinguish the user. Defaults to the current user's ip address.

=cut

sub hasRated {
	my ($self, $userId, $ipAddress) = @_;
	$userId = $session{user}{userId} unless ($userId);
	return 1 if ($userId != 1 && $userId eq $self->get("userId")); # is poster
	$ipAddress = $session{env}{REMOTE_ADDR} unless ($ipAddress);
	my ($flag) = WebGUI::SQL->quickArray("select count(*) from forumPostRating where forumPostId="
		.quote($self->get("forumPostId"))." and ((userId=".quote($userId)." and userId<>1) or (userId='1' and 
		ipAddress=".quote($ipAddress)."))");
	return $flag;
}

#-------------------------------------------------------------------

=head2 incrementViews ( )

Increments the views counter for this post.

=cut

sub incrementViews {
	my ($self) = @_;
	WebGUI::SQL->write("update forumPost set views=views+1 where forumPostId=".quote($self->get("forumPostId")));
	$self->getThread->incrementViews;
}

#-------------------------------------------------------------------

=head2 isMarkedRead ( [ userId ] )

Returns a boolean indicating whether this post is marked read for the user.

=head3 userId

A unique id for a user that you want to check. Defaults to the current user.

=cut

sub isMarkedRead {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	my ($isRead) = WebGUI::SQL->quickArray("select count(*) from forumRead where userId=".quote($userId)." and forumPostId=".quote($self->get("forumPostId")));
	return $isRead;
}

#-------------------------------------------------------------------

=head2 isReply ( )

Returns a boolean indicating whether this post is a reply or the root post in a thread.

=cut

sub isReply {
	my ($self) = @_;
	if ($self->get("parentId") ne "0") {
		return 1;
	} else {
		return 0;
	}
}

#-------------------------------------------------------------------

=head2 markRead ( [ userId ] )

Marks this post read for this user.

=head3 userId

A unique identifier for a user. Defaults to the current user.

=cut

sub markRead {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	unless ($self->isMarkedRead($userId)) {
		WebGUI::SQL->write("insert into forumRead (userId, forumPostId, forumThreadId, lastRead) values (".quote($userId).",
			".quote($self->get("forumPostId")).", ".quote($self->get("forumThreadId")).", ".WebGUI::DateTime::time().")");
	}
	$self->incrementViews;
}

#-------------------------------------------------------------------

=head2 new ( postId )

Constructor.

=head3 postId

The unique identifier for the post object you wish to retrieve.

=cut

sub new {
	my ($class, $forumPostId) = @_;
	my $properties = WebGUI::SQL->getRow("forumPost","forumPostId",$forumPostId);
	if (defined $properties) {
		bless {_properties=>$properties}, $class;
	} else {
		return undef;
	}
}

#-------------------------------------------------------------------

=head2 rate ( rating [ , userId, ipAddress ] )

Stores a rating against this post.

=head3 rating

An integer between 1 and 5 (5 being best) to rate this post with.

=head3 userId

The unique id for the user rating this post. Defaults to the current user.

=head3 ipAddress

The ip address of the user doing the rating. Defaults to the current user's IP.

=cut

sub rate {
	my ($self, $rating, $userId, $ipAddress) = @_;
	$userId = $session{user}{userId} unless ($userId);
	$ipAddress = $session{env}{REMOTE_ADDR} unless ($ipAddress);
	WebGUI::SQL->write("insert into forumPostRating (forumPostId,userId,ipAddress,dateOfRating,rating) values ("
		.quote($self->get("forumPostId")).", ".quote($userId).", ".quote($ipAddress).", ".WebGUI::DateTime::time().", $rating)");
	$self->recalculateRating;
}

#-------------------------------------------------------------------

=head2 recalculateRating ( )

Recalculates the average rating of the post from all the ratings and stores the result to the database.

=cut

sub recalculateRating {
	my ($self) = @_;
	my ($count) = WebGUI::SQL->quickArray("select count(*) from forumPostRating where forumPostId=".quote($self->get("forumPostId")));
        $count = $count || 1;
        my ($sum) = WebGUI::SQL->quickArray("select sum(rating) from forumPostRating where forumPostId=".quote($self->get("forumPostId")));
        my $average = round($sum/$count);
        $self->set({rating=>$average});
	$self->getThread->recalculateRating;
}

#-------------------------------------------------------------------

=head2 set ( data )

Sets properties to the database and the object.

=head3 data

A hash reference containing the properties to set. See the forumPost table for details.

=cut


sub set {
	my ($self, $data) = @_;
	$data->{forumPostId} = $self->get("forumPostId") unless ($data->{forumPostId});
	WebGUI::SQL->setRow("forumPost","forumPostId",$data);
	foreach my $key (keys %{$data}) {
		$self->{_properties}{$key} = $data->{$key};
	}
}

#-------------------------------------------------------------------

=head2 setStatusApproved ( )

Sets the status of this post to approved.

=cut


sub setStatusApproved {
	my ($self) = @_;
	$self->set({status=>'approved'});
	$self->getThread->setStatusApproved if ($self->getThread->get("rootPostId") eq $self->get("forumPostId"));
	if ($self->isReply) {
		$self->getThread->incrementReplies($self->get("dateOfPost"),$self->get("forumPostId"));
	}
}

#-------------------------------------------------------------------

=head2 setStatusArchived ( )

Sets the status of this post to archived.

=cut


sub setStatusArchived {
	my ($self) = @_;
	$self->set({status=>'archived'});
	$self->getThread->setStatusArchived if ($self->getThread->get("rootPostId") eq $self->get("forumPostId"));
	if ($self->isReply) {
		$self->getThread->incrementReplies($self->get("dateOfPost"),$self->get("forumPostId"));
	}
}

#-------------------------------------------------------------------

=head2 setStatusDeleted ( )

Sets the status of this post to deleted.

=cut

sub setStatusDeleted {
	my ($self) = @_;
	$self->set({status=>'deleted'});
	$self->getThread->decrementReplies;
	$self->getThread->setStatusDeleted if ($self->getThread->get("rootPostId") eq $self->get("forumPostId"));
	my ($id, $date) = WebGUI::SQL->quickArray("select forumPostId,dateOfPost from forumPost where forumThreadId="
		.quote($self->get("forumThreadId"))." and status='approved'");
	$self->getThread->setLastPost($date,$id);
}

#-------------------------------------------------------------------

=head2 setStatusDenied ( )

Sets the status of this post to denied.

=cut

sub setStatusDenied {
	my ($self) = @_;
	$self->set({status=>'denied'});
	$self->getThread->setStatusDenied if ($self->getThread->get("rootPostId") eq $self->get("forumPostId"));
}

#-------------------------------------------------------------------

=head2 setStatusPending ( )

Sets the status of this post to pending.

=cut

sub setStatusPending {
	my ($self) = @_;
	$self->set({status=>'pending'});
	$self->getThread->setStatusPending if ($self->getThread->get("rootPostId") eq $self->get("forumPostId"));
}


#-------------------------------------------------------------------

=head2 unmarkRead ( [ userId ] )

Negates the markRead method.

=head3 userId

The unique id of the user marking unread. Defaults to the current user.

=cut

sub unmarkRead {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	WebGUI::SQL->write("delete from forumRead where userId=".quote($userId)." and forumPostId=".quote($self->get("forumPostId")));
}

1;

