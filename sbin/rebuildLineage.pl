#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::SQL;


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
index that is used to make WebGUI run faster.

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
WebGUI::Session::open($webguiRoot,$configFile);
print "OK\n" unless ($quiet);

print "Rewriting existing lineage...\n" unless ($quiet);
WebGUI::SQL->write("update asset set lineage=concat('old___',lineage)");
my ($lineage) = WebGUI::SQL->quickArray("select lineage from asset where assetId='PBasset000000000000001'");

print "Rebuilding lineage...\n" unless ($quiet);
my ($oldRootLineage) = WebGUI::SQL->quickArray("select lineage from asset where assetId='PBasset000000000000001'");
printChange("Asset ID","Old Lineage","New Lineage");
printChange('PBasset000000000000001',$oldRootLineage,'000001');
WebGUI::SQL->write("update asset set lineage='000001' where assetId='PBasset000000000000001'");
recurseTree("PBasset000000000000001","000001");

print "Cleaning up..." unless ($quiet);
WebGUI::Session::end($session{var}{sessionId});
WebGUI::Session::close();
print "OK\n" unless ($quiet);

print "\nDon't forget to clear your cache.\n" unless ($quiet);


sub recurseTree {
	my $parentId = shift;
	my $parentLineage = shift;
	my $rank = 0;
	my $getChildren = WebGUI::SQL->prepare("select assetId, lineage from asset where parentId=? order by lineage");
	$getChildren->execute([$parentId]);
	while (my ($assetId, $oldLineage) = $getChildren->array) {
		$rank++;
		my $newLineage = $parentLineage.sprintf("%06d",$rank);
		printChange($assetId,$oldLineage,$newLineage);
		my $setLineage = WebGUI::SQL->prepare("update asset set lineage=? where assetId=?");
		$setLineage->execute([$newLineage,$assetId]);
		recurseTree($assetId,$newLineage);
	}
}

sub printChange {
	my $assetId = shift;
	my $oldLineage = shift;
	my $newLineage = shift;
	print sprintf("%-25s",$assetId).sprintf("%-51s",$oldLineage).sprintf("%-51s",$newLineage)."\n" unless ($quiet);
}

