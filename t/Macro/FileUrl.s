#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::Macro_Config;
use WebGUI::Storage;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

unless ($session->config->get('macros')->{'FileUrl'}) {
	Macro_Config::insert_macro($session, 'FileUrl', 'FileUrl');
}

##Add more Asset configurations here.
my @testSets = (
	{
		comment => 'File Asset works with FileUrl',
		className => 'WebGUI::Asset::File',
		#          '1234567890123456789012'
		assetId => 'FileAsset00110011abc-e',
		title => 'Test File Asset',
		url => 'fileurltest-file',
		description => 'Test File Asset for the FileUrl macro test',
	},
	{
		className => 'Image Asset works with FileUrl',
		#          '1234567890123456789012'
		assetId => 'ImageAsset0110011abc-e',
		title => 'Test Image Asset',
		url => 'fileurltest-image',
		description => 'Test Image Asset for the FileUrl macro test',
	},
	{
		className => 'Article Asset does not work with FileUrl',
		#          '1234567890123456789012'
		assetId => 'ArticleAsset10011abc-e',
		title => 'Test Article Asset',
		url => 'fileurltest-Article',
		description => 'Test Article Asset for the FileUrl macro test',
	},
);


plan tests => scalar(@testSets) + 3; ##3 TODO tests

my $macroText = '^FileUrl("%s");';
my $output = $macroText;

my $homeAsset = WebGUI::Asset->getDefault($session);
my $versionTag;

($versionTag, @testSets) = setupTest($session, $homeAsset, @testSets);

foreach my $testSet (@testSets) {
	$session->asset($testSet->{asset});
	my $class = $testSet->{className};
	my $output = sprintf $macroText, $testSet->{url};
	WebGUI::Macro::process($session, \$output);
	my $comment = sprintf "Checking asset: %s", $class;
	is($output, $testSet->{fileUrl}, $comment);
}

TODO: {
	local $TODO = 'Things to do later';
	ok(0, 'Add tests for Assets with no Storage ID and check error message');
	ok(0, 'Add tests for bad URLs and check error message');
	ok(0, 'Talk to JT about how to handle Assets with StorageIds but no filename properties');
}

sub setupTest {
	my ($session, $homeAsset, @testSets) = @_;
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"FileUrl macro test"});
	my $testNum = 0;
	foreach my $testSet (@testSets) {

		my $storage = WebGUI::Storage->create($session);
		my $filename = join '.', 'fileName', $testNum;

		##Store the filename in the file, just for reference.
		$storage->addFileFromScalar($filename,$filename);
		$testSet->{fileUrl} = $storage->getUrl($filename);

		my %properties = %{ $testSet };
		$properties{storageId} = $storage->getId;
		$properties{filename} = $filename;

		my $asset = $homeAsset->addChild(\%properties, $properties{assetId});
		$testSet->{asset} = $asset;
		++$testNum;
	}
	$versionTag->commit;
	return $versionTag, @testSets;
}

END { ##Clean-up after yourself, always
	$versionTag->rollback;
}
