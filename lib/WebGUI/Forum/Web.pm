package WebGUI::Discuss::Web;

use WebGUI::Discuss;
use WebGUI::Discuss::Post;
use WebGUI::Discuss::Thread;
use WebGUI::Session;


sub post {

}

sub postSave {
	my $forumId = $session{form}{forumId};
	my $threadId = $session{form}{forumThreadId};
	if ($session{form}{parentId} > 0) {
		my $parentPost = WebGUI::Discuss::Post->new($session{form}{parentId});
		$forumId = $parentPost->getThread->get("forumId");
		$threadId = $parentPost->get("forumThreadId");
	}
	if ($threadId < 1) {
		$threadId = WebGUI::Discuss::Thread->create({
			forumId=>$forumId
			});
	}
}

1;

