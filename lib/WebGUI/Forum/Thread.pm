package WebGUI::Forum::Thread;

use WebGUI::Forum;
use WebGUI::Forum::Post;
use WebGUI::Session;
use WebGUI::SQL;

sub addReply {
        my ($self, $dateOfReply) = @_;
        WebGUI::SQL->write("update forumThread set replies=replies+1, lastR where forumThreadId=".$self->get("forumThreadId"));
	#add method to notify users for subscriptions
}

sub addView {
        my ($self) = @_;
        WebGUI::SQL->write("update forumThread set views=views+1 where forumThreadId=".$self->get("forumThreadId"));
}

sub create {
	my ($self, $data, $postData) = @_;
	$data->{forumThreadId} = "new";
	my $forumThreadId = WebGUI::SQL->setRow("forumThread","forumThreadId",$data);
	$self = WebGUI::Forum::Thread->new($forumThreadId);
	$postData{forumThreadId} = $forumThreadId;
	$postData{parentId} = 0;
	my $post = WebGUI::Discuss::Post->create($postData);
	$self->set({
		rootPostId=>$post->get("forumPostId"),
		lastPostId=>$post->get("forumPostId"),
		lastPostDate=>$post->get("dateOfPost")
		});
	$self->{_post}{$post->{forumPostId}} = $post;
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

sub getPost {
	my ($self, $postId) = @_;
	unless (exists $self->{_post}{$postId}) {
		$self->{_post}{$postId} = WebGUI::Forum::Post->new($postId);
	}
	return $self->{_post}{$postId};
}

sub isLocked {
	my ($self) = @_;
	return $self->get("isLocked");
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

sub stick {
	my ($self) = @_;
	$self->set({isSticky=>1});
}

sub new {
	my ($self, $forumThreadId) = @_;
	my $properties = WebGUI::SQL->getRow("forumThread","forumThreadId",$forumThreadId);
	bless {_properties=>$properties}, $self;
}

sub set {
	my ($self, $data) = @_;
	$data->{forumThreadId} = $self->get("forumThreadId") unless ($data->{forumThreadId});
	WebGUI::SQL->setRow("forumThread","forumThreadId",$data);
	$self->{_properties} = $data;
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

