package Hourly::ArchiveOldPosts;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use strict;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	my $epoch = WebGUI::DateTime::time();
	my $a = WebGUI::SQL->read("select forumId,archiveAfter,masterForumId from forum");
	while (my $forum = $a->hashRef) {
		if ($forum->{masterForumId}) {
			($forum->{archiveAfter}) = WebGUI::SQL->quickArray("select archiveAfter from forum where masterForumId=$forum->{masterForumId}");
		}
		my $archiveDate = $epoch - $forum->{archiveAfter};
		my $b = WebGUI::SQL->read("select forumThreadId from forumThread where forumId=".$forum->{forumId}
			." and lastPostDate<$archiveDate");
		while (my ($threadId) = $b->array) {
			WebGUI::SQL->write("update forumPost set status='archived' where status='approved' and forumThreadId=$threadId");
			WebGUI::SQL->write("update forumThread set status='archived' where status='approved' and forumThreadId=$threadId");
		}
		$b->finish;
	}
	$a->finish;
}

1;

