package WebGUI::Forum::Web;

use WebGUI::DateTime;
use WebGUI::Forum;
use WebGUI::Forum::Post;
use WebGUI::Forum::Thread;
use WebGUI::HTML::Filter;
use WebGUI::Session;
use WebGUI::Template;

sub getPostTemplateVars {
        my ($post, $thread, $forum) = @_;
        my %var;
        $var->{'post.subject'} = WebGUI::HTML::filter($post->get("subject"),"none");
        $var->{'post.message'} = WebGUI::HTML::filter($post->get("message"),$forum->get("filterPosts"));
        if ($forum->get("allowReplacements")) {
                my $sth = WebGUI::SQL->read("select pattern,replaceWith from forumReplacement");
                while (my ($pattern,$replaceWith) = $sth->array) {
                        $var->{'post.message'} =~ s/\Q$pattern/$replaceWith/g;
                }
                $sth->finish;
        }
        $var->{'post.date'} = WebGUI::DateTime::epochToHuman($post->get("dateOfPost"),"%z");
        $var->{'post.time'} = WebGUI::DateTime::epochToHuman($post->get("dateOfPost"),"%Z");
	$var->{'post.views'} = $post->get("views");
	$var->{'post.status'} = getStatus($post->get("status"));
	$var->{'post.isLocked'} = $post->isLocked;
	$var->{'post.isModerator'} = $forum->isModerator;
	$var->{'post.username'} = $post->get("username");
	$var->{'post.userId'} = $post->get("userId");
	$var->{'post.userProfile'} = WebGUI::URL::page("op=viewProfile&amp;uid=".$post->get("userId"));
	$var->{'post.id'} = $post->get("forumPostId");
	$var->{'post.full'} = WebGUI::Template::process(WebGUI::Template::get($forum->get("postTemplate"),"Forum/Post"), \%var); 
}

sub getStatus {

}

sub www_post {

}

sub www_postSave {
	my $forumId = $session{form}{forumId};
	my $threadId = $session{form}{forumThreadId};
	if ($session{form}{parentId} > 0) {
		my $parentPost = WebGUI::Forum::Post->new($session{form}{parentId});
		$forumId = $parentPost->getThread->get("forumId");
		$threadId = $parentPost->get("forumThreadId");
	}
	if ($threadId < 1) {
		$threadId = WebGUI::Forum::Thread->create({
			forumId=>$forumId
			});
	}
}

sub www_viewPost {

}


1;

