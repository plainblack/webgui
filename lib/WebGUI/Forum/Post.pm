package WebGUI::Forum::Post;

use strict;
use WebGUI::DateTime;
use WebGUI::Forum::Thread;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

sub canEdit {
        my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
        return ($self->getThread->getForum->isModerator || ($self->get("userId") == $userId && $userId != 1 
		&& $self->getThread->getForum->get("editTimeout") < (WebGUI::DateTime::time() - $self->get("dateOfPost"))));
}

sub create {
	my ($self, $data) = @_;
	$data->{dateOfPost} = WebGUI::DateTime::time();
	$data->{forumPostId} = "new";
	my $forumPostId = WebGUI::SQL->setRow("forumPost","forumPostId", $data);
	$self = WebGUI::Forum::Post->new($forumPostId);
	if ($self->getThread->getForum->get("moderatePosts")) {
		$self->setStatusPending;
	} else {
		$self->setStatusApproved;
	}
	return $self;
}

sub get {
	my ($self, $key) = @_;
	if ($key eq "") {
		return $self->{_properties};
	}
	return $self->{_properties}->{$key};
}

sub getReplies {
	my ($self) = @_;
	my @replies = ();
	my $sth = WebGUI::SQL->read("select forumPostId from forumPost where parentId=".$self->get("forumPostId")." order by forumPostId");
	while (my @data = $sth->array) {
		push(@replies,WebGUI::Forum::Post->new($data[0]));
	}
	$sth->finish;
	return \@replies;
}

sub getThread {
	my ($self) = @_;
	unless (exists $self->{_thread}) {
		$self->{_thread} = WebGUI::Forum::Thread->new($self->get("forumThreadId"));
	}
	return $self->{_thread};
}

sub hasRated {
	my ($self, $userId, $ipAddress) = @_;
	$userId = $session{user}{userId} unless ($userId);
	$ipAddress = $session{env}{REMOTE_ADDR} unless ($ipAddress);
	my ($flag) = WebGUI::SQL->quickArray("select count(*) from forumPostRating where forumPostId="
		.$self->get("forumPostId")." and ((userId=$userId and userId<>1) or (userId=1 and 
		ipAddress='$ipAddress'))");
	return $flag;
}

sub incrementViews {
	my ($self) = @_;
	WebGUI::SQL->write("update forumPost set views=views+1 where forumPostId=".$self->get("forumPostId"));
	$self->getThread->incrementViews;
}

sub isMarkedRead {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	my ($isRead) = WebGUI::SQL->quickArray("select count(*) from forumRead where userId=$userId and forumPostId=".$self->get("forumPostId"));
	return $isRead;
}

sub isReply {
	my ($self) = @_;
	if ($self->get("parentId") > 0) {
		return 1;
	} else {
		return 0;
	}
}

sub markRead {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	unless ($self->isMarkedRead($userId)) {
		WebGUI::SQL->write("insert into forumRead (userId, forumPostId, forumThreadId, lastRead) values ($userId,
			".$self->get("forumPostId").", ".$self->get("forumThreadId").", ".WebGUI::DateTime::time().")");
	}
	$self->incrementViews;
}

sub new {
	my ($class, $forumPostId) = @_;
	my $properties = WebGUI::SQL->getRow("forumPost","forumPostId",$forumPostId);
	if (defined $properties) {
		bless {_properties=>$properties}, $class;
	} else {
		return undef;
	}
}

sub rate {
	my ($self, $rating, $userId, $ipAddress) = @_;
	$userId = $session{user}{userId} unless ($userId);
	$ipAddress = $session{env}{REMOTE_ADDR} unless ($ipAddress);
	WebGUI::SQL->write("insert into forumPostRating (forumPostId,userId,ipAddress,dateOfRating,rating) values ("
		.$self->get("forumPostId").", $userId, ".quote($ipAddress).", ".WebGUI::DateTime::time().", $rating)");
	$self->recalculateRating;
}

sub recalculateRating {
	my ($self) = @_;
	my ($count) = WebGUI::SQL->quickArray("select count(*) from forumPostRating where forumPostId=".$self->get("forumPostId"));
        $count = $count || 1;
        my ($sum) = WebGUI::SQL->quickArray("select sum(rating) from forumPostRating where forumPostId=".$self->get("forumPostId"));
        my $average = round($sum/$count);
        $self->set({rating=>$average});
	$self->getThread->recalculateRating;
}

sub set {
	my ($self, $data) = @_;
	$data->{forumPostId} = $self->get("forumPostId") unless ($data->{forumPostId});
	WebGUI::SQL->setRow("forumPost","forumPostId",$data);
	foreach my $key (keys %{$data}) {
		$self->{_properties}{$key} = $data->{$key};
	}
}

sub setStatusApproved {
	my ($self) = @_;
	$self->set({status=>'approved'});
	$self->getThread->setStatusApproved if ($self->getThread->get("rootPostId") == $self->get("forumPostId"));
	if ($self->isReply) {
		$self->getThread->incrementReplies($self->get("dateOfPost"),$self->get("forumPostId"));
	}
}

sub setStatusDeleted {
	my ($self) = @_;
	$self->set({status=>'deleted'});
	$self->getThread->setStatusDeleted if ($self->getThread->get("rootPostId") == $self->get("forumPostId"));
	if ($self->getThread->get("lastPostId") == $self->get("forumPostId")) {
		my ($id, $date) = WebGUI::SQL->quickArray("select forumPostId,dateOfPost from forumPost where forumThreadId="
			.$self->get("forumThreadId")." and status='approved'");
		$self->getThread->setLastPost($id,$date);
	}
}

sub setStatusDenied {
	my ($self) = @_;
	$self->set({status=>'denied'});
	$self->getThread->setStatusDenied if ($self->getThread->get("rootPostId") == $self->get("forumPostId"));
}

sub setStatusPending {
	my ($self) = @_;
	$self->set({status=>'pending'});
	$self->getThread->setStatusPending if ($self->getThread->get("rootPostId") == $self->get("forumPostId"));
}

sub unmarkRead {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	WebGUI::SQL->write("delete from forumRead where userId=$userId and forumPostId=".$self->get("forumPostId"));
}

1;

