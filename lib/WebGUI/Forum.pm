package WebGUI::Forum;

use strict;
use WebGUI::Forum::Thread;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Utility;

sub canPost {
        my ($self, $userId) = @_;
        $userId = $session{user}{userId} unless ($userId);
        return WebGUI::Privilege::isInGroup($self->get("groupToPost"));
}

sub create {
	my ($self, $data) = @_;
	$data->{forumId} = "new";
	my $forumId = WebGUI::SQL->setRow("forum","forumId",$data);
	return WebGUI::Forum->new($forumId);
}

sub get {
	my ($self, $key) = @_;
	if ($key eq "") {
		return $self->{_properties};
	}
	return $self->{_properties}->{$key};
}

sub getThread {
	my ($self, $threadId) = @_;
	unless (exists $self->{_thread}{$threadId}) {
		$self->{_thread}{$threadId} = WebGUI::Forum::Thread->new($threadId);
	}
	return $self->{_thread}{$threadId};
}

sub isModerator {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	return WebGUI::Privilege::isInGroup($self->get("groupToModerate"), $userId);
}

sub incrementReplies {
        my ($self) = @_;
        WebGUI::SQL->write("update forum set replies=replies+1 where forumId=".$self->get("forumId"));
}
                                                                                                                                                             
sub incrementViews {
        my ($self) = @_;
        WebGUI::SQL->write("update forum set views=views+1 where forumId=".$self->get("forumId"));
}
                                                                                                                                                             
sub isSubscribed {
	my ($self, $userId) = @_;
        $userId = $session{user}{userId} unless ($userId);
        my ($isSubscribed) = WebGUI::SQL->quickArray("select count(*) from forumSubscription where forumId=".$self->get("forumId")." and userId=$userId");
        return $isSubscribed;
}

sub new {
	my ($self, $forumId) = @_;
	my $properties = WebGUI::SQL->getRow("forum","forumId",$forumId);
	bless {_properties=>$properties}, $self;
}

sub purge {
	my ($self);
	my $a = WebGUI::SQL->read("select * from forumThread where forumId=".$self->get("forumId"));
	while (my ($threadId) = $a->array) {
		my $b = WebGUI::SQL->read("select * from forumPost where forumThreadId=".$threadId);
		while (my ($postId) = $b->array) {
			WebGUI::SQL->write("delete from forumPostAttachment where forumPostId=".$postId);
			WebGUI::SQL->write("delete from forumPostRating where forumPostId=".$postId);
			WebGUI::SQL->write("delete from forumBookmark where forumPostId=".$postId);
		}
		$b->finish;
		WebGUI::SQL->write("delete from forumThreadSubscription where forumThreadId=".$threadId);
		WebGUI::SQL->write("delete from forumRead where forumThreadId=".$threadId);
		WebGUI::SQL->write("delete from forumPost where forumThreadId=".$threadId);
	}
	$a->finish;
	WebGUI::SQL->write("delete from forumSubscription where forumId=".$self->get("forumId"));
	WebGUI::SQL->write("delete from forumThread where forumId=".$self->get("forumId"));
	WebGUI::SQL->write("delete from forum where forumId=".$self->get("forumId"));
}

sub recalculateRating {
        my ($self) = @_;
        my ($count) = WebGUI::SQL->quickArray("select count(*) from forumThread where forumId=".$self->get("forumId")." and rating>0");
        $count = $count || 1;
        my ($sum) = WebGUI::SQL->quickArray("select sum(rating) from forumThread where forumId=".$self->get("forumId")." and rating>0");
        my $average = round($sum/$count);
        $self->set({rating=>$average});
}

sub set {
	my ($self, $data) = @_;
	$data->{forumId} = $self->get("forumId") unless ($data->{forumId});
	WebGUI::SQL->setRow("forum","forumId",$data);
	foreach my $key (keys %{$data}) {
                $self->{_properties}{$key} = $data->{$key};
        }
}

sub subscribe {
        my ($self, $userId) = @_;
        $userId = $session{user}{userId} unless ($userId);
        unless ($self->isSubscribed($userId)) {
                WebGUI::SQL->write("insert into forumSubscription (forumId, userId) values (".$self->get("forumId").",$userId)");
        }
}
                                                                                                                                                             
sub unsubscribe {
        my ($self, $userId) = @_;
        $userId = $session{user}{userId} unless ($userId);
        if ($self->isSubscribed($userId)) {
                WebGUI::SQL->write("delete from forumSubscription where forumId=".$self->get("forumId")." and userId=$userId");
        }
}



1;

