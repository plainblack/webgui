package WebGUI::Forum::Thread;

use strict;
use WebGUI::DateTime;
use WebGUI::Forum;
use WebGUI::Forum::Post;
use WebGUI::Session;
use WebGUI::SQL;

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
	return $self;
}

sub get {
	my ($self, $key) = @_;
	if ($key eq "") {
		return $self->{_properties};
	}
	return $self->{_properties}->{$key};
}

sub getForum {
	my ($self) = @_;
	unless (exists $self->{_forum}) {
		$self->{_forum} = WebGUI::Forum->new($self->get("forumId"));
	}
	return $self->{_forum};
}

sub getNextThread {
	my ($self) = @_;
	unless (exists $self->{_next}) {
		my ($nextId) = WebGUI::SQL->quickArray("select min(forumThreadId) from forumThread where forumThreadId>".$self->get("forumThreadId"));
		$self->{_next} = WebGUI::Forum::Thread->new($nextId);
	}
	return $self->{_next};
}

sub getPost {
	my ($self, $postId) = @_;
	unless (exists $self->{_post}{$postId}) {
		$self->{_post}{$postId} = WebGUI::Forum::Post->new($postId);
	}
	return $self->{_post}{$postId};
}

sub getPreviousThread {
	my ($self) = @_;
	unless (exists $self->{_previous}) {
		my ($nextId) = WebGUI::SQL->quickArray("select max(forumThreadId) from forumThread where forumThreadId<".$self->get("forumThreadId"));
		$self->{_previous} = WebGUI::Forum::Thread->new($nextId);
	}
	return $self->{_previous};
}

sub isLocked {
	my ($self) = @_;
	return $self->get("isLocked");
}

sub incrementReplies {
        my ($self, $dateOfReply, $replyId) = @_;
        WebGUI::SQL->write("update forumThread set replies=replies+1, lastPostId=$replyId, lastPostDate=$dateOfReply 
		where forumThreadId=".$self->get("forumThreadId"));
	#add method to notify users for subscriptions
}

sub incrementViews {
        my ($self) = @_;
        WebGUI::SQL->write("update forumThread set views=views+1 where forumThreadId=".$self->get("forumThreadId"));
}
                                                                                                                                                             
sub isSticky {
	my ($self) = @_;
	return $self->get("isSticky");
}

sub isSubscribed {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	my ($isSubscribed) = WebGUI::SQL->quickArray("select count(*) from forumThreadSubscription where forumThreadId=".$self->get("forumThreadId")
		." and userId=$userId");
	return $isSubscribed;
}

sub lock {
	my ($self) = @_;
	$self->set({isLocked=>1});
}

sub new {
	my ($class, $forumThreadId) = @_;
	my $properties = WebGUI::SQL->getRow("forumThread","forumThreadId",$forumThreadId);
	if (defined $properties) {
		bless {_properties=>$properties}, $class;
	} else {
		return undef;
	}
}

sub set {
	my ($self, $data) = @_;
	$data->{forumThreadId} = $self->get("forumThreadId") unless ($data->{forumThreadId});
	WebGUI::SQL->setRow("forumThread","forumThreadId",$data);
	foreach my $key (keys %{$data}) {
                $self->{_properties}{$key} = $data->{$key};
        }
}

sub setLastPost {
	my ($self, $postId, $postDate) = @_;
	$self->set({
		lastPostId=>$postId,
		lastPostDate=>$postDate
		});
}

sub setStatusApproved {
        my ($self) = @_;
        $self->set({status=>'approved'});
}
                                                                                                                                                             
sub setStatusDeleted {
        my ($self) = @_;
        $self->set({status=>'deleted'});
}
                                                                                                                                                             
sub setStatusDenied {
        my ($self) = @_;
        $self->set({status=>'denied'});
}
                                                                                                                                                             
sub setStatusPending {
        my ($self) = @_;
        $self->set({status=>'pending'});
}

sub stick {
	my ($self) = @_;
	$self->set({isSticky=>1});
}

sub subscribe {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	unless ($self->isSubscribed($userId)) {
		WebGUI::SQL->write("insert into forumThreadSubscription (forumThreadId, userId) values (".$self->get("forumThreadId").",$userId)");
	}
}

sub unlock {
	my ($self) = @_;
	$self->set({isLocked=>0});
}

sub unstick {
	my ($self) = @_;
	$self->set({isSticky=>0});
}

sub unsubscribe {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	if ($self->isSubscribed($userId)) {
		WebGUI::SQL->write("delete from forumThreadSubscription where forumThreadId=".$self->get("forumThreadId")." and userId=$userId");
	}
}


1;

