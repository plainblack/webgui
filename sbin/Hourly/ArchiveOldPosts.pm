package Hourly::ArchiveOldPosts;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
	return ""; # disabled for the time being
	my $epoch = WebGUI::DateTime::time();
	my $a = WebGUI::SQL->read("select assetId,archiveAfter,masterForumId from forum");
	while (my $forum = $a->hashRef) {
		my $archiveDate = $epoch - $forum->{archiveAfter};
		my $b = WebGUI::SQL->read("select forumThreadId from forumThread where forumId=".quote($forum->{forumId})." and lastPostDate<$archiveDate");
		while (my ($threadId) = $b->array) {
			WebGUI::SQL->write("update forumPost set status='archived' where status='approved' and forumThreadId=".quote($threadId));
			WebGUI::SQL->write("update forumThread set status='archived' where status='approved' and forumThreadId=".quote($threadId));
		}
		$b->finish;
	}
	$a->finish;
}

1;

