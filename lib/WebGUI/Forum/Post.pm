package WebGUI::Forum::Post;

use WebGUI::Discuss::Thread;
use WebGUI::Session;
use WebGUI::SQL;

sub addView {
	my ($self) = @_;
	WebGUI::SQL->write("update forumPost set views=views+1 where forumPostId=".$self->get("forumPostId"));
	$self->getThread->addView;
}

sub create {
	my ($self, $data) = @_;
	$data->{forumPostId} = "new";
	$data->{dateOfPost} = WebGUI::DateTime::time();
	my $forumPostId = WebGUI::SQL->setRow("forumPost","forumPostId",$data);
	$self = WebGUI::Forum::Post->new($forumPostId);
	if ($data->{parentId} > 0) {
		$self->getThread->addReply($forumPostId,$self->get("dateOfPost"));
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

sub getTemplateVars {
	my ($self) = @_;
	my $properties = $self->get;
	my %var = %{$properties};
	$var->{subject} = WebGUI::HTML::filter($var->{subject},"none");
	$var->{message} = WebGUI::HTML::filter($var->{subject},$self->getThread->getForum->get("filterPosts"));
	if ($self->getThread->getForum->get("allowReplacements")) {
		# do the replacement thing
	}
	$var->{dateOfPost} = WebGUI::DateTime::epochToHuman($var->{dateOfPost});
}

sub getThread {
	my ($self) = @_;
	unless (exists $self->{_thread}) {
		$self->{_thread} = WebGUI::Forum::Thread->new($self->get("forumThreadId"));
	}
	return $self->{_thread};
}

sub markRead {
	my ($self, $userId) = @_;
	$userId = $session{user}{userId} unless ($userId);
	my ($alreadyMarked) = WebGUI::SQL->quickArray("select count(*) from forumRead userId,forumPostId");
	unless ($alreadyMarked) {
		WebGUI::SQL->write("insert into forumRead (userId, forumPostId, lastRead) values ($userId,
			".$self->get("forumPostId").", ".WebGUI::DateTime::time().")");
	}
}

sub new {
	my ($self, $forumPostId) = @_;
	my $properties = WebGUI::SQL->getRow("forumPost","forumPostId",$forumPostId);
	bless {_properties=>$properties}, $self;
}

sub set {
	my ($self, $data) = @_;
	WebGUI::SQL->setRow("forumPost","forumPostId",$data);
	$self->{_properties} = $data;
}

1;

