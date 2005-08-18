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
		my $sql = "select asset.assetId,asset.className, max(assetData.revisionDate) from Post left join asset on Post.assetId=asset.assetId 
			left join assetData on Post.assetId=assetData.assetId and assetData.revisionDate=Post.revisionDate
			where Post.dateUpdated<$archiveDate and assetData.status='approved' and asset.lineage like ".quote($lineage."%")." group by asset.assetId";
		my $b = WebGUI::SQL->read($sql);
		while (my ($id, $class, $version) = $b->array) {
			WebGUI::Asset::Post->new($id,$class,$version)->setStatusArchived;
		}
		$b->finish;
	}
	$a->finish;
}

1;

