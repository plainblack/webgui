#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

##The goal of this test is to diagnose problems in DataForms.
##  Orphaned DataForms with no Asset table entries

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 1; # increment this value for each test you create
use Test::Deep;

my $one = [1, 2, 3, 4];
my @two = ();

my $session = WebGUI::Test->session;

my $dataFormIds = $session->db->buildArrayRef("select asset.assetId, assetData.revisionDate from DataForm left join asset on asset.assetId=DataForm.assetId left join assetData on assetData.revisionDate=DataForm.revisionDate and assetData.assetId=DataForm.assetId where asset.state='published' and assetData.revisionDate=(SELECT max(revisionDate) from assetData where assetData.assetId=asset.assetId and (assetData.status='approved' or assetData.tagId=?)) order by assetData.title");

foreach my $table (qw/DataForm/) {
	my $tableIds = $session->db->buildArrayRef(sprintf ("select distinct(assetId) from %s", $table));
	cmp_bag($dataFormIds, $tableIds,
			sprintf("Orphaned assetIds in %s", $table));
}

