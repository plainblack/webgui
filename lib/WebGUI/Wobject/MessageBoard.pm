package WebGUI::Wobject::MessageBoard;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::DateTime;
use WebGUI::Forum;
use WebGUI::Forum::UI;
use WebGUI::HTML;
use WebGUI::HTMLForm;
use WebGUI::Icon;
use WebGUI::International;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;
use WebGUI::Utility;
use WebGUI::Wobject;

our @ISA = qw(WebGUI::Wobject);


#-------------------------------------------------------------------
sub _formatControls {
	my $controls = deleteIcon("func=deleteForum&amp;wid=".$_[0]->get("wobjectId")."&amp;forumId=".$_[1])
		.editIcon("func=editForum&amp;wid=".$_[0]->get("wobjectId")."&amp;forumId=".$_[1])
		.moveUpIcon("func=moveForumUp&amp;wid=".$_[0]->get("wobjectId")."&amp;forumId=".$_[1])
		.moveDownIcon("func=moveForumDown&amp;wid=".$_[0]->get("wobjectId")."&amp;forumId=".$_[1]);
	return $controls;
}


#-------------------------------------------------------------------
sub name {
        return WebGUI::International::get(2,$_[0]->get("namespace"));
}

#-------------------------------------------------------------------
sub new {
        my $class = shift;
        my $property = shift;
        my $self = WebGUI::Wobject->new(
                -properties=>$property,
		-useTemplate=>1
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub www_deleteForum {
 	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        return $_[0]->confirm(WebGUI::International::get(76,$_[0]->get("namespace")),
                WebGUI::URL::page('func=deleteForumConfirm&wid='.$_[0]->get("wobjectId").'&forumId='.$session{form}{forumId}));
}

#-------------------------------------------------------------------
sub www_deleteForumConfirm {
 	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	my $forum = WebGUI::Forum->new($session{form}{forumId});
	$forum->purge;
	WebGUI::SQL->write("delete from MessageBoard_forums where forumId=".$session{form}{forumId});
}

#-------------------------------------------------------------------
sub www_edit {
	my $properties = WebGUI::HTMLForm->new;
	return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-headingId=>6,
		-helpId=>1
		);
}

#-------------------------------------------------------------------
sub www_editForum {
 	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	my $forumMeta;
	if ($session{form}{forumId} ne "new") {
		$forumMeta = WebGUI::SQL->quickHashRef("select title,description from MessageBoard_forums where forumId=".$session{form}{forumId});
	}
	my $forum = WebGUI::Forum->new($session{form}{forumId});
	my $f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name=>"wid",
		-value=>$_[0]->get("wobjectId")
		);
	$f->hidden(
		-name=>"func",
		-value=>"editForumSave"
		);
	$f->text(
		-name=>"title",
		-value=>$forumMeta->{title},
		-label=>WebGUI::International::get(99)
		);
	$f->HTMLArea(
		-name=>"description",
		-value=>$forumMeta->{description},
		-label=>WebGUI::International::get(85)
		);
	$f->raw(WebGUI::Forum::UI::forumProperties($forum->get("forumId")));
	$f->submit;
	return '<h1>'.WebGUI::International::get(77,$_[0]->get("namespace")).'</h1>'.$f->print;
}

#-------------------------------------------------------------------
sub www_editForumSave {
 	return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
	my $forumId = WebGUI::Forum::UI::forumPropertiesSave();
	if ($session{form}{forumId} eq "new") {
		my ($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from MessageBoard_forums where wobjectId=".$_[0]->get("wobjectId"));
		$seq++;
		WebGUI::SQL->write("insert into MessageBoard_forums (wobjectId, forumId, title, description, sequenceNumber) values ("
			.$_[0]->get("wobjectId").", ".$forumId.", ".quote($session{form}{title}).", ".quote($session{form}{description})
			.", ".$seq.")");
	} else {
		WebGUI::SQL->write("update MessageBoard_forums set title=".quote($session{form}{title}).", description="
			.quote($session{form}{description})." where forumId=".$forumId." and wobjectId=".$_[0]->get("wobjectId"));
	}
	return "";
}

#-------------------------------------------------------------------
sub www_moveForumDown {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralDown("MessageBoard_forums","forumId",$session{form}{forumId});
        return "";
}
                                                                                                                                                             
#-------------------------------------------------------------------
sub www_moveForumUp {
        return WebGUI::Privilege::insufficient() unless (WebGUI::Privilege::canEditWobject($_[0]->get("wobjectId")));
        $_[0]->moveCollateralUp("MessageBoard_forums","forumId",$session{form}{forumId});
        return "";
}

#-------------------------------------------------------------------
sub www_view {
	my $callback = WebGUI::URL::page("func=view&amp;wid=".$_[0]->get("wobjectId"));
	return WebGUI::Forum::UI::forumOp($callback) if ($session{form}{forumOp});
	my %var;
	$var{title} = $_[0]->get("title");
	$var{description} = $_[0]->get("description");
	$var{'forum.add.url'} = WebGUI::URL::page("func=editForum&amp;forumId=new&amp;wid=".$_[0]->get("wobjectId"));
	$var{'forum.add.label'} = WebGUI::International::get(75,$_[0]->get("namespace"));
	$var{'title.label'} = WebGUI::International::get(99);
	$var{'views.label'} = WebGUI::International::get(514);
	$var{'rating.label'} = WebGUI::International::get(1020);
	$var{'threads.label'} = WebGUI::International::get(1036);
	$var{'replies.label'} = WebGUI::International::get(1016);
	$var{'lastpost.label'} = WebGUI::International::get(1017);
	my $count = 1;
	my @forum_loop;
	my $sth = WebGUI::SQL->read("select * from MessageBoard_forums where wobjectId=".$_[0]->get("wobjectId")." order by sequenceNumber");
	while (my $forumMeta = $sth->hashRef) {
		my $forum = WebGUI::Forum->new($forumMeta->{forumId});
		if ($count == 1) {
			$var{'default.listing'} = WebGUI::Forum::UI::www_viewForum($callback,$forumMeta->{forumId});
			$var{'default.description'} = $forumMeta->{description};
			$var{'default.title'} = $forumMeta->{title};
			$var{'default.controls'} = $_[0]->_formatControls($forum->get("forumId"));
		}
		my $lastPost = WebGUI::Forum::Post->new($forum->get("lastPostId"));
		push(@forum_loop, {
			'forum.controls' => $_[0]->_formatControls($forum->get("forumId")),
			'forum.count' => $count,
			'forum.title' => $forumMeta->{title},
			'forum.description' => $forumMeta->{description},
			'forum.replies' => $forum->get("replies"),
			'forum.rating' => $forum->get("rating"),
			'forum.views' => $forum->get("views"),
			'forum.threads' => $forum->get("threads"),
			'forum.url' => WebGUI::Forum::UI::formatForumURL($callback,$forum->get("forumId")),
			'forum.lastPost.url' => WebGUI::Forum::UI::formatThreadURL($callback,$lastPost->get("forumPostId")),
			'forum.lastPost.date' => WebGUI::Forum::UI::formatPostDate($lastPost->get("dateOfPost")),
			'forum.lastPost.time' => WebGUI::Forum::UI::formatPostTime($lastPost->get("dateOfPost")),
			'forum.lastPost.epoch' => $lastPost->get("dateOfPost"),
			'forum.lastPost.subject' => WebGUI::Forum::UI::formatSubject($lastPost->get("subject")),
			'forum.lastPost.user.id' => $lastPost->get("userId"),
			'forum.lastPost.user.name' => $lastPost->get("username"),
			'forum.lastPost.user.profile' => WebGUI::Forum::UI::formatUserProfileURL($lastPost->get("userId")),
			'forum.lastPost.user.isVisitor' => ($lastPost->get("userId") == 1)
			});
		$count++;
	}
	$sth->finish;
	$var{areMultipleForums} = ($count > 1);
	$var{forum_loop} = \@forum_loop;
        return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
	

	my ($p, $data, %var, @message_loop, $rows, @last, $replies);

	$var{canPost} = WebGUI::Privilege::isInGroup($_[0]->get("groupToPost"));
	$var{"post.url"} = WebGUI::URL::page('func=post&mid=new&wid='.$_[0]->get("wobjectId"));
	$var{"post.label"} = WebGUI::International::get(17,$_[0]->get("namespace"));
	$var{"search.url"} = WebGUI::URL::page('func=search&wid='.$_[0]->get("wobjectId"));
	$var{"search.label"} = WebGUI::International::get(364);
	$var{"subject.label"} = WebGUI::International::get(229);
	$var{"user.label"} = WebGUI::International::get(15,$_[0]->get("namespace"));
	$var{"date.label"} = WebGUI::International::get(18,$_[0]->get("namespace"));
	$var{"views.label"} = WebGUI::International::get(514);
	$var{"replies.label"} = WebGUI::International::get(19,$_[0]->get("namespace"));
	$var{"last.label"} = WebGUI::International::get(20,$_[0]->get("namespace"));
	$p = WebGUI::Paginator->new(WebGUI::URL::page('wid='.$_[0]->get("wobjectId").'&func=view'),[],$_[0]->get("messagesPerPage"));
	$p->setDataByQuery("select messageId,subject,username,dateOfPost,userId,views,status
		from discussion where wobjectId=".$_[0]->get("wobjectId")." and pid=0 
		and (status='Approved' or userId=$session{user}{userId}) order by dateOfPost desc");
	$rows = $p->getPageData;
	foreach $data (@$rows) {
		@last = WebGUI::SQL->quickArray("select messageId,dateOfPost,username,subject,userId 
			from discussion where wobjectId=".$_[0]->get("wobjectId")." and rid=$data->{messageId} 
			and status='Approved' order by dateOfPost desc");
		($replies) = WebGUI::SQL->quickArray("select count(*) from discussion 
			where rid=$data->{messageId} and status='Approved'");
		$replies--;
		push (@message_loop,{
			"last.url" => WebGUI::URL::page('func=showMessage&mid='.$last[0].'&wid='.$_[0]->get("wobjectId")),
			"last.subject" => substr(WebGUI::HTML::filter($last[3],'all'),0,30),
			"last.date" => epochToHuman($last[1]),
			"last.userProfile" => WebGUI::URL::page('op=viewProfile&uid='.$last[4]),
			"last.username" => $last[2],
			"message.replies" => $replies,
			"message.url" => WebGUI::URL::page('func=showMessage&mid='.$data->{messageId}.'&wid='.$_[0]->get("wobjectId")),
			"message.subject" => substr($data->{subject},0,30),
			"message.currentUser" => ($data->{userId} == $session{user}{userId}),
			"message.status" => status($data->{status}),
			"message.userProfile" => WebGUI::URL::page('op=viewProfile&uid='.$data->{userId}),
			"message.username" => $data->{username},
			"message.date" => epochToHuman($data->{dateOfPost}),
			"message.views" => $data->{views}
			});
        }
	$var{message_loop} = \@message_loop;
        $var{firstPage} = $p->getFirstPageLink;
        $var{lastPage} = $p->getLastPageLink;
        $var{nextPage} = $p->getNextPageLink;
        $var{pageList} = $p->getPageLinks;
        $var{previousPage} = $p->getPreviousPageLink;
        $var{multiplePages} = ($p->getNumberOfPages > 1);
}

1;

