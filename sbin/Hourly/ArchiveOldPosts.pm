package Hourly::ArchiveOldPosts;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use strict;
use WebGUI::Asset::Post;
use WebGUI::Asset::Wobject::Collaboration;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	my $epoch = WebGUI::DateTime::time();
	my $a = WebGUI::SQL->read("select assetId from asset where className='WebGUI::Asset::Wobject::Collaboration'");
	while (my ($assetId) = $a->array) {
		my $cs = WebGUI::Asset::Wobject::Collaboration->new($assetId);
		my $archiveDate = $epoch - $cs->get("archiveAfter");
		my $sql = "select asset.assetId, assetData.revisionDate from Post left join asset on asset.assetId=Post.assetId 
			left join assetData on Post.assetId=assetData.assetId and Post.revisionDate=assetData.revisionDate
			where Post.dateUpdated<$archiveDate and assetData.status='approved' and asset.state='published'
			and asset.lineage like ".quote($cs->get("lineage").'%');
		my $b = WebGUI::SQL->read($sql);
		while (my ($id, $version) = $b->array) {
			my $post = WebGUI::Asset::Post->new($id,undef,$version);
			$post->setStatusArchived if (defined $post && $post->get("dateUpdated") < $archiveDate);
		}
		$b->finish;
	}
	$a->finish;
}

1;

