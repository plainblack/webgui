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
my $i18n = WebGUI::International->new($session, 'Macro_FileUrl');

my @added_macros = ();
push @added_macros, WebGUI::Macro_Config::enable_macro($session, 'FileUrl', 'FileUrl');

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
		pass => 1,
	},
	{
		comment => 'Image Asset works with FileUrl',
		className => 'WebGUI::Asset::File::Image',
		#          '1234567890123456789012'
		assetId => 'ImageAsset0110011abc-e',
		title => 'Test Image Asset',
		url => 'fileurltest-image',
		description => 'Test Image Asset for the FileUrl macro test',
		pass => 1,
	},
	{
		comment => 'ZipArchive Asset works with FileUrl',
		className => 'WebGUI::Asset::File::ZipArchive',
		#          '1234567890123456789012'
		assetId => 'ZipArchive0110011ZYWXV',
		title => 'Test ZipArchive Asset',
		url => 'fileurltest-ziparchive',
		description => 'Test ZipArchive Asset for the FileUrl macro test',
		pass => 1,
	},
	{
		comment => 'Snippet Asset does not store files',
		className => 'WebGUI::Asset::Snippet',
		#          '1234567890123456789012'
		assetId => 'SnippetAsset01011abc-e',
		title => 'Test Snippet Asset',
		url => 'fileurltest-snippet',
		description => 'Test Snippet Asset for the FileUrl macro test',
		snippet => 'Test Snippet Asset for the FileUrl macro test',
		pass => 0,
		output => $i18n->get('no storage'),
	},
	{
		comment => 'Article Asset does not have a filename property',
		className => 'WebGUI::Asset::Wobject::Article',
		#          '1234567890123456789012'
		assetId => 'ArticleAsset01011abc-e',
		title => 'Test Article Asset',
		url => 'fileurltest-article',
		description => 'Test Article Asset for the FileUrl macro test',
		pass => 0,
		output => $i18n->get('no filename'),
	},
);


plan tests => scalar(@testSets) + 1;

my $macroText = '^FileUrl("%s");';

my $homeAsset = WebGUI::Asset->getDefault($session);
my $versionTag;

($versionTag, @testSets) = setupTest($session, $homeAsset, @testSets);

foreach my $testSet (@testSets) {
	my $output = sprintf $macroText, $testSet->{url};
	WebGUI::Macro::process($session, \$output);
	if ($testSet->{pass}) {
		is($output, $testSet->{fileUrl}, $testSet->{comment});
	}
	else {
		is($output, $testSet->{output}, $testSet->{comment});
	}
}

my $output = sprintf $macroText, "non-existant-url";
WebGUI::Macro::process($session, \$output);
is($output, $i18n->get('invalid url'), "Non-existant url returns error message");

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

	foreach my $macro (@added_macros) {
		next unless $macro;
		$session->config->deleteFromHash("macros", $macro);
	}
}
