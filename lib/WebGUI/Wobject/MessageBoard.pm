package WebGUI::Wobject::MessageBoard;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
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
sub getIndexerParams {
	my $self = shift;        
	my $now = shift;
	return {
		MessageBoard => {
                        sql => "select MessageBoard_forums.title,
                                        MessageBoard_forums.description,
                                        MessageBoard_forums.wobjectId as wid,
                                        wobject.namespace as namespace,
                                        wobject.addedBy as ownerId,
                                        page.urlizedTitle as urlizedTitle,
                                        page.languageId as languageId,
                                        page.pageId as pageId,
                                        page.groupIdView as page_groupIdView,
                                        wobject.groupIdView as wobject_groupIdView,
                                        7 as wobject_special_groupIdView
                                from MessageBoard_forums, wobject, page
                                where MessageBoard_forums.wobjectId = wobject.wobjectId
                                        and wobject.pageId = page.pageId
                                        and wobject.startDate < $now 
                                        and wobject.endDate > $now
                                        and page.startDate < $now
                                        and page.endDate > $now",
                        fieldsToIndex => ["title", "description"],
                        contentType => 'wobject',
                        url => '$data{urlizedTitle}."#".$data{wid}',
                        headerShortcut => 'select title from MessageBoard_forums where wobjectId = $data{wid}',
                        bodyShortcut => 'select description from MessageBoard_forums where wobjectId = $data{wid}',
                	},
        	MessageBoard_Forum => {
                        sql => "select  forumPost.forumPostId,
                                        forumPost.username,
                                        forumPost.subject,
                                        forumPost.message,
                                        forumPost.userId as ownerId,
                                        forumThread.forumId as forumId,
                                        MessageBoard_forums.wobjectId,
                                        wobject.namespace as namespace,
                                        wobject.wobjectId as wid,
                                        page.urlizedTitle as urlizedTitle,
                                        page.languageId as languageId,
                                        page.pageId as pageId,
                                        page.groupIdView as page_groupIdView,
                                        wobject.groupIdView as wobject_groupIdView,
                                        7 as wobject_special_groupIdView
                                from forumPost, forumThread, MessageBoard_forums, wobject, page
                                where forumPost.forumThreadId = forumThread.forumThreadId
                                        and forumThread.forumId = MessageBoard_forums.forumId
                                        and MessageBoard_forums.wobjectId = wobject.wobjectId
                                        and wobject.pageId = page.pageId
                                        and wobject.startDate < $now 
                                        and wobject.endDate > $now
                                        and page.startDate < $now
                                        and page.endDate > $now",
                        fieldsToIndex => ["username", "subject", "message"],
                        contentType => 'discussion',
                        url => 'WebGUI::URL::append($data{urlizedTitle},"func=view&wid=$data{wid}&forumOp=viewThread&forumPostId=$data{forumPostId}&forumId=$data{forumId}")',
                        headerShortcut => 'select subject from forumPost where forumPostId = $data{forumPostId}',
                        bodyShortcut => 'select message from forumPost where forumPostId = $data{forumPostId}',
        		}
		};
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
		-useTemplate=>1,
		-useMetaData=>1
                );
        bless $self, $class;
}

#-------------------------------------------------------------------
sub purge {
        my $sth = WebGUI::SQL->read("select forumId from MessageBoard_forums where wobjectId=".$_[0]->get("wobjectId"));
        while (my ($forumId) = $sth->array) {
		my ($inUseElsewhere) = WebGUI::SQL->quickArray("select count(*) from MessageBoard_forums where forumId=".$forumId);
                unless ($inUseElsewhere > 1) {
                	my $forum = WebGUI::Forum->new($forumId);
                	$forum->purge;
		}
        }	
        $sth->finish;
	WebGUI::SQL->write("delete from MessageBoard_forums where wobjectId=".$_[0]->get("wobjectId"));
        $_[0]->SUPER::purge();
}

#-------------------------------------------------------------------
sub www_deleteForum {
 	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        return $_[0]->confirm(WebGUI::International::get(76,$_[0]->get("namespace")),
                WebGUI::URL::page('func=deleteForumConfirm&wid='.$_[0]->get("wobjectId").'&forumId='.$session{form}{forumId}));
}

#-------------------------------------------------------------------
sub www_deleteForumConfirm {
 	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
	my ($inUseElsewhere) = WebGUI::SQL->quickArray("select count(*) from MessageBoard_forums where forumId=".$session{form}{forumId});
        unless ($inUseElsewhere > 1) {
		my $forum = WebGUI::Forum->new($session{form}{forumId});
		$forum->purge;
	}
	WebGUI::SQL->write("delete from MessageBoard_forums where forumId=".quote($session{form}{forumId})." and wobjectId=".$_[0]->get("wobjectId"));
	return "";
}

#-------------------------------------------------------------------
sub www_edit {
	my $properties = WebGUI::HTMLForm->new;
	return $_[0]->SUPER::www_edit(
		-properties=>$properties->printRowsOnly,
		-headingId=>6,
		-helpId=>"message board add/edit"
		);
}

#-------------------------------------------------------------------
sub www_editForum {
 	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $session{page}{useAdminStyle} = 1;
	my $forumMeta;
	if ($session{form}{forumId} ne "new") {
		$forumMeta = WebGUI::SQL->quickHashRef("select title,description from MessageBoard_forums where forumId=".quote($session{form}{forumId}));
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
	return helpIcon("forum add/edit",$_[0]->get("namespace")).'<h1>'.WebGUI::International::get(77,$_[0]->get("namespace")).'</h1>'.$f->print;
}

#-------------------------------------------------------------------
sub www_editForumSave {
 	return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
	my $forumId = WebGUI::Forum::UI::forumPropertiesSave();
	if ($session{form}{forumId} eq "new") {
		my ($seq) = WebGUI::SQL->quickArray("select max(sequenceNumber) from MessageBoard_forums where wobjectId=".quote($_[0]->get("wobjectId")));
		$seq++;
		WebGUI::SQL->write("insert into MessageBoard_forums (wobjectId, forumId, title, description, sequenceNumber) values ("
			.quote($_[0]->get("wobjectId")).", ".quote($forumId).", ".quote($session{form}{title}).", ".quote($session{form}{description})
			.", ".$seq.")");
	} else {
		WebGUI::SQL->write("update MessageBoard_forums set title=".quote($session{form}{title}).", description="
			.quote($session{form}{description})." where forumId=".quote($forumId)." and wobjectId=".quote($_[0]->get("wobjectId")));
	}
	return "";
}

#-------------------------------------------------------------------
sub www_moveForumDown {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $_[0]->moveCollateralDown("MessageBoard_forums","forumId",$session{form}{forumId});
        return "";
}
                                                                                                                                                             
#-------------------------------------------------------------------
sub www_moveForumUp {
        return WebGUI::Privilege::insufficient() unless ($_[0]->canEdit);
        $_[0]->moveCollateralUp("MessageBoard_forums","forumId",$session{form}{forumId});
        return "";
}

#-------------------------------------------------------------------
sub www_view {
	$_[0]->logView() if ($session{setting}{passiveProfilingEnabled});
	my %var;
	my $count = 1;
	my @forum_loop;
	my $caller;
	my $sth = WebGUI::SQL->read("select * from MessageBoard_forums where wobjectId=".quote($_[0]->get("wobjectId"))." order by sequenceNumber");
	while (my $forumMeta = $sth->hashRef) {
		my $callback = WebGUI::URL::page("func=view&wid=".$_[0]->get("wobjectId")."&forumId=".$forumMeta->{forumId});
		if ($session{form}{forumOp}) { 
			if ($session{form}{forumId} == $forumMeta->{forumId}) {
				$caller = {
					callback=>$callback,
					title=>$forumMeta->{title},
					description=>$forumMeta->{description},
					forumId=>$forumMeta->{forumId}
					};
			}
		} else {
			my $forum = WebGUI::Forum->new($forumMeta->{forumId});
			next unless ($forum->canView);
			if ($count == 1) {
				$var{'default.listing'} = WebGUI::Forum::UI::www_viewForum({
					callback=>$callback,
					title=>$forumMeta->{title},
					description=>$forumMeta->{description},
					forumId=>$forumMeta->{forumId}
					},$forumMeta->{forumId});
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
				'forum.lastPost.subject' => $lastPost->get("subject"),
				'forum.lastPost.user.id' => $lastPost->get("userId"),
				'forum.lastPost.user.name' => $lastPost->get("username"),
				'forum.lastPost.user.profile' => WebGUI::Forum::UI::formatUserProfileURL($lastPost->get("userId")),
				'forum.lastPost.user.isVisitor' => ($lastPost->get("userId") == 1),
				'forum.user.canView' => $forum->canView,
				'forum.user.canPost' => $forum->canPost
				});
			$count++;
		}
	}
	$sth->finish;
	if ($session{form}{forumOp}) {
		return WebGUI::Forum::UI::forumOp($caller);
	} else {
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
		$var{areMultipleForums} = ($count > 2);
		$var{forum_loop} = \@forum_loop;
        	return $_[0]->processTemplate($_[0]->get("templateId"),\%var);
	}
}

1;

