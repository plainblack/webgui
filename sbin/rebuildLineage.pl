#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN { 
	$webguiRoot = "..";
	unshift (@INC, $webguiRoot."/lib"); 
}


$| = 1;

use Getopt::Long;
use strict;
use WebGUI::Session;
use WebGUI::Utility;

my $configFile;
my $help;
my $quiet;

GetOptions(
	'configFile=s'=>\$configFile,
        'help'=>\$help,
        'quiet'=>\$quiet,
);


if ($help || $configFile eq ""){
        print <<STOP;


Usage: perl $0 --configfile=<webguiConfig>

This utility will rebuild your WebGUI Lineage Tree. The lineage tree is an
index that is used to make WebGUI run faster. It will also detect and fix
orphan data, and detect cirular relationships in your tree.

WARNING: Use this tool only if you know what you're doing. It should only
be used if somehow your lineage tree has become corrupt (very rare) or if
you have done some massive reorganization of your asset tree and you want
to fill in the gaps between the ranks of your assets. A side effect of
using this utility can be that your assets may no longer be in the same rank
as they once were, which means that they may appear out of order in your
navigation.

        --configFile	WebGUI config file.

Options:

        --help		Display this help message and exit.

	--quiet		Disable output unless there's an error.

STOP
	exit;
}


print "Starting..." unless ($quiet);
my $session = WebGUI::Session->open($webguiRoot,$configFile);
print "OK\n" unless ($quiet);

print "Looking for descendant replationships...\n" unless ($quiet);
my @found = (); #descendants found
getDescendants("PBasset000000000000001");
print "Got the relationships.\n" unless ($quiet);
print "\nLooking for orphans...\n" unless ($quiet);
my $orphansFound = 0;
my $rs = $session->db->read("select assetId from asset order by lineage");
while (my ($id) = $rs->array) {
	unless (isIn($id, @found)) {
		print "\tFound an orphan with an assetId of $id. Moving it to the import node.\n";
		$session->db->write("update asset set parentId='PBasset000000000000002' where assetId=?",[$id]);
		getDescendants($id);
		$orphansFound++;
	}
}
if ($orphansFound) {
	print "Found and fixed $orphansFound orphan(s).\n" unless ($quiet);
} else {
	print "No orphans found.\n" unless ($quiet);
}
print "\nDisabling constraints on lineage...\n" unless ($quiet);
$session->db->write("drop index `lineage` on `asset`");

print "Rebuilding lineage...\n" unless ($quiet);
my ($oldRootLineage) = $session->db->quickArray("select lineage from asset where assetId='PBasset000000000000001'");
printChange("Asset ID","Old Lineage","New Lineage");
printChange('PBasset000000000000001',$oldRootLineage,'000001');
$session->db->write("update asset set lineage='000001' where assetId='PBasset000000000000001'");
recurseAndFixTree("PBasset000000000000001","000001");
print "\nRe-enabling constraints on lineage...\n" unless ($quiet);
$session->db->write("create unique index `lineage` on `asset` (`lineage`)");
print "\nRepairing search index...\n" unless ($quiet);
$session->db->write("update assetIndex inner join asset on asset.assetId=assetIndex.assetId set assetIndex.lineage=asset.lineage");

print "Cleaning up..." unless ($quiet);
$session->var->end;
$session->close;
print "OK\n" unless ($quiet);

print "\nDon't forget to clear your cache.\n" unless ($quiet);


sub getDescendants {
	my $parentId = shift;
    my $depth = shift || 0;
    if (isIn($parentId, @found)) {
		print "\nFound circular relationships involving $parentId. This requires manual intervention.\n" unless ($quiet);
		exit;
	}
    if (++$depth > 42) {
		print "\nFound asset greater than 42 levels deep: $parentId. This requires manual intervention.\n" unless ($quiet);
		exit;
    }
	push(@found, $parentId);
	my $getChildren = $session->db->prepare("select assetId, lineage from asset where parentId=? order by lineage");
	$getChildren->execute([$parentId]);
	while (my ($assetId) = $getChildren->array) {
		getDescendants($assetId, $depth);
	}
}

sub recurseAndFixTree {
	my $parentId = shift;
	my $parentLineage = shift;
	my $rank = 0;
	my $getChildren = $session->db->prepare("select assetId, lineage from asset where parentId=? order by lineage");
	$getChildren->execute([$parentId]);
	while (my ($assetId, $oldLineage) = $getChildren->array) {
		$rank++;
		my $newLineage = $parentLineage.sprintf("%06d",$rank);
		printChange($assetId,$oldLineage,$newLineage);
		my $setLineage = $session->db->prepare("update asset set lineage=? where assetId=?");
		$setLineage->execute([$newLineage,$assetId]);
		recurseAndFixTree($assetId,$newLineage);
	}
}

sub printChange {
	my $assetId = shift;
	my $oldLineage = shift;
	my $newLineage = shift;
	print sprintf("%-25s",$assetId).sprintf("%-51s",$oldLineage).$newLineage."\n" unless ($quiet);
}

