package Hourly::DeleteExpiredRevisions;

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
use WebGUI::Asset;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::DateTime;

#-----------------------------------------
sub process {
	if ($session{config}{DeleteExpiredRevisions_offset} ne "") {
		my $hour = WebGUI::DateTime::epochToHuman(time(),"%H");
		my $dow = WebGUI::DateTime::epochToHuman(time(),"%W");
		return unless ($hour == 3 && $dow eq "Sun");
		my $expireDate = (time()-(86400*$session{config}{DeleteExpiredRevisions_offset}));
		my $sth = WebGUI::SQL->read("select assetData.assetId,asset.className,assetData.revisionDate from asset left join assetData on asset.assetId=assetData.assetId where assetData.revisionDate<".$expireDate." order by assetData.revisionDate asc");
		while (my ($id, $class, $version) = $sth->array) {
			my $asset = WebGUI::Asset->new($id,$class,$version);
			if ($asset->getRevisionCount("approved") > 1) {
				$asset->purgeRevision;
			}
		}
		$sth->finish;
	}
}

1;

