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
use WebGUI::Asset::Post;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	my $epoch = WebGUI::DateTime::time();
	my $a = WebGUI::SQL->read("select asset.lineage,Collaboration.archiveAfter from Collaboration left join asset on Collaboration.assetId=asset.assetId");
	while (my ($lineage, $archiveAfter) = $a->array) {
		my $archiveDate = $epoch - $archiveAfter;
		my $sql = "select * from Post left join asset on Post.assetId=asset.assetId left join Thread on Thread.assetId=Post.assetId
			where Post.dateUpdated<$archiveDate and Post.status='approved' and asset.lineage like ".quote($lineage."%");
		my $b = WebGUI::SQL->read($sql);
		while (my $properties = $b->hashRef) {
			my $post = WebGUI::Asset::Post->newByPropertyHashRef($properties);
			$post->setStatusArchived;
		}
		$b->finish;
	}
	$a->finish;
}

1;

